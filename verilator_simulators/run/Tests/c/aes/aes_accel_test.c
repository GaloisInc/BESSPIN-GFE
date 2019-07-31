#include <stdio.h>
#include <stdint.h>
#include "riscv_counters.h"

typedef uint64_t datum;     /* Set the data bus width to 64 bits. */

#define AES_BASE_ADDRESS 0x6fff0000

#define AES_INBUF_0_ADDR (AES_BASE_ADDRESS + 0x1000)
#define AES_INBUF_1_ADDR (AES_BASE_ADDRESS + 0x2000)
#define AES_OUTBUF_0_ADDR (AES_BASE_ADDRESS + 0x3000)
#define AES_OUTBUF_1_ADDR (AES_BASE_ADDRESS + 0x4000)

#define AES_INBUF_0_SIZE 0x1000
#define AES_INBUF_1_SIZE 0x1000
#define AES_OUTBUF_0_SIZE 0x1000
#define AES_OUTBUF_1_SIZE 0x1000

struct __attribute__ ((aligned (4))) aes_pio
{
  // 0x000
  volatile uint32_t cmd __attribute__ ((aligned (4)));
  // 0x004 - 0x00c
  volatile uint32_t cmd_unused_0 __attribute__ ((aligned (4)));
  volatile uint32_t cmd_unused_1 __attribute__ ((aligned (4)));
  volatile uint32_t cmd_unused_2 __attribute__ ((aligned (4)));

  // 0x010
  volatile uint32_t start_buf_0 __attribute__ ((aligned (4)));
  // 0x014 - 0x01f
  // TODO: Fix this hack to insert unused addresses 
  volatile uint32_t start_buf_0_unused_0 __attribute__ ((aligned (4)));
  volatile uint32_t start_buf_0_unused_1 __attribute__ ((aligned (4)));
  volatile uint32_t start_buf_0_unused_2 __attribute__ ((aligned (4)));

  // 0x020
  volatile uint32_t start_buf_1 __attribute__ ((aligned (4)));
  // 0x024 - 0x02f
  volatile uint32_t start_buf_1_unused_0 __attribute__ ((aligned (4)));
  volatile uint32_t start_buf_1_unused_1 __attribute__ ((aligned (4)));
  volatile uint32_t start_buf_1_unused_2 __attribute__ ((aligned (4)));

   // 0x030
  volatile uint32_t acc_state_lsw __attribute__ ((aligned (4)));
  // 0x034
  volatile uint32_t acc_state_msw __attribute__ ((aligned (4)));
  // 0x038 - 0x03f
  volatile uint32_t acc_state_unused_0 __attribute__ ((aligned (4)));
  volatile uint32_t acc_state_unused_1 __attribute__ ((aligned (4)));

   // 0x040
  volatile uint32_t buffer_0_page_size __attribute__ ((aligned (4)));
  // 0x044 - 0x04f
  volatile uint32_t buffer_0_page_size_unused_0 __attribute__ ((aligned (4)));
  volatile uint32_t buffer_0_page_size_unused_1 __attribute__ ((aligned (4)));
  volatile uint32_t buffer_0_page_size_unused_2 __attribute__ ((aligned (4)));

  // 0x050
  volatile uint32_t buffer_1_page_size __attribute__ ((aligned (4)));
  // 0x054 - 0x05f
  volatile uint32_t buffer_1_page_size_unused_0 __attribute__ ((aligned (4)));
  volatile uint32_t buffer_1_page_size_unused_1 __attribute__ ((aligned (4)));
  volatile uint32_t buffer_1_page_size_unused_2 __attribute__ ((aligned (4)));

  // 0x060 - 0x6f
  volatile uint32_t init_vector_0 __attribute__ ((aligned (4)));
  volatile uint32_t init_vector_1 __attribute__ ((aligned (4)));
  volatile uint32_t init_vector_2 __attribute__ ((aligned (4)));
  volatile uint32_t init_vector_3 __attribute__ ((aligned (4)));

  // 0x070 - 0x7f
  volatile uint32_t unused_0 __attribute__ ((aligned (4)));
  volatile uint32_t unused_1 __attribute__ ((aligned (4)));
  volatile uint32_t unused_2 __attribute__ ((aligned (4)));
  volatile uint32_t unused_3 __attribute__ ((aligned (4)));

  // 0x080 - 0x9f
  volatile uint32_t key_0 __attribute__ ((aligned (4)));
  volatile uint32_t key_1 __attribute__ ((aligned (4)));
  volatile uint32_t key_2 __attribute__ ((aligned (4)));
  volatile uint32_t key_3 __attribute__ ((aligned (4)));
  volatile uint32_t key_4 __attribute__ ((aligned (4)));
  volatile uint32_t key_5 __attribute__ ((aligned (4)));
  volatile uint32_t key_6 __attribute__ ((aligned (4)));
  volatile uint32_t key_7 __attribute__ ((aligned (4)));
};

static struct aes_pio * pio = (void*)AES_BASE_ADDRESS;

void check_uint32_eq(uint32_t a, uint32_t b) {
  if (a != b)
  {
    printf("%x != %x\n", a, b);
    TEST_FAIL
  }
}

void test_unique_output() {
  // Setup the accelerator state
  pio->key_0 = 0xdeadbeef;
  pio->key_1 = 0xdeadbeef;
  pio->key_2 = 0xaaaaaaaa;
  pio->key_3 = 0xaaaaaaaa;
  pio->init_vector_0 = 0x00000001;
  pio->init_vector_1 = 0x00000001;
  pio->init_vector_2 = 0x00000002;
  pio->init_vector_3 = 0x00000002;
  pio->buffer_0_page_size = 0x0;
  pio->buffer_1_page_size = 0x0;

  // Load the input data
  io_write32 (AES_INBUF_0_ADDR, 0xfeedbead);
  io_write32 (AES_INBUF_0_ADDR + 0x8, 0xcccccccc);
  io_write32 (AES_INBUF_1_ADDR, 0x12345678);
  io_write32 (AES_INBUF_1_ADDR + 0x8, 0xdddddddd);

  fence();

  // Start encrypting
  pio->start_buf_0 = 1;
  pio->start_buf_1 = 1;

  uint32_t result_buf_0 = io_read32(AES_OUTBUF_0_ADDR);
  uint32_t result_buf_1 = io_read32(AES_OUTBUF_1_ADDR);

  // Check some of these values
  if (pio->key_0 != 0xdeadbeef) {
    printf ("read unexpected data from key_0\n");
    TEST_FAIL
  }

  // Check the output
  if (result_buf_0 == result_buf_1) {
    printf("Unexpected collision\n");
    TEST_FAIL
  }
}

void test_wr_registers() {
  uint32_t key_init_0 = 0x12345678;
  uint32_t key_init_1 = 0xabcddeef;
  uint32_t key_init_2 = 0xfeedbead;
  uint32_t key_init_3 = 0x7282eea3;

  uint32_t init_vector_init_0 = 0xa2e45608;
  uint32_t init_vector_init_1 = 0x8bcddeef;
  uint32_t init_vector_init_2 = 0xfeefb3ad;
  uint32_t init_vector_init_3 = 0x1282e9a3;

  pio->key_0 = key_init_0;
  pio->key_1 = key_init_1;
  pio->key_2 = key_init_2;
  pio->key_3 = key_init_3;

  pio->init_vector_0 = init_vector_init_0;
  pio->init_vector_1 = init_vector_init_1;
  pio->init_vector_2 = init_vector_init_2;
  pio->init_vector_3 = init_vector_init_3;

  check_uint32_eq(pio->key_0, key_init_0);
  check_uint32_eq(pio->key_1, key_init_1);
  check_uint32_eq(pio->key_2, key_init_2);
  check_uint32_eq(pio->key_3, key_init_3);

  check_uint32_eq(pio->init_vector_0, init_vector_init_0);
  check_uint32_eq(pio->init_vector_1, init_vector_init_1);
  check_uint32_eq(pio->init_vector_2, init_vector_init_2);
  check_uint32_eq(pio->init_vector_3, init_vector_init_3);
}

void run_aes_blocking(uint32_t *key, uint32_t key_length,
  uint32_t *data, uint32_t data_length, uint32_t buffer) {

  // ----- Validate the inputs -----
  if ( (key_length != 4) & (key_length != 8) ) {
    printf("Key length %d bytes not supported\n", key_length * sizeof(*key));
    TEST_FAIL
  }

  if ( (buffer != 0) & (buffer != 1) ) {
    printf("buffer %d not supported. Valid buffers are 0 and 1\n", buffer);
    TEST_FAIL
  }

  if (data_length > (AES_INBUF_0_SIZE / sizeof(*data))) {
    printf("Data length %d bytes larger than input buffer size %d bytes\n",
      data_length * sizeof(*data), AES_INBUF_0_SIZE);
    TEST_FAIL
  }

  if (data_length > (AES_OUTBUF_0_SIZE / sizeof(*data))) {
    printf("Data length %d bytes larger than output buffer size %d bytes\n",
      data_length * sizeof(*data), AES_OUTBUF_0_SIZE);
    TEST_FAIL
  }

  // ----- End input validation -----

  // Setup the accelerator state
  pio->key_0 = key[0];
  pio->key_1 = key[1];
  pio->key_2 = key[2];
  pio->key_3 = key[3];
  if (key_length > 4) {
    pio->key_4 = key[4];
    pio->key_5 = key[5];
    pio->key_6 = key[6];
    pio->key_7 = key[7];
  }

  // TODO: Pass init vector as an input
  pio->init_vector_0 = 0x00000001;
  pio->init_vector_1 = 0x00000002;
  pio->init_vector_2 = 0x00000003;
  pio->init_vector_3 = 0x00000004;

  uint32_t aes_inbuf_addr;
  uint32_t aes_outbuf_addr;
  uint32_t aes_bufsize;
  if (buffer == 0){
    pio->buffer_0_page_size = data_length * sizeof(*data);
    aes_inbuf_addr = AES_INBUF_0_ADDR;
    aes_outbuf_addr = AES_OUTBUF_0_ADDR;
    aes_bufsize = AES_INBUF_0_SIZE;
  } else {
    pio->buffer_1_page_size = data_length * sizeof(*data);
    aes_inbuf_addr = AES_INBUF_1_ADDR;
    aes_outbuf_addr = AES_OUTBUF_1_ADDR;
    aes_bufsize = AES_INBUF_1_SIZE;
  }

  // Copy input data into the buffer
  for (int i = 0; i < data_length; ++i) {
    io_write32(aes_inbuf_addr, data[i]);
    aes_inbuf_addr = aes_inbuf_addr + sizeof(*data);
  }

  fence();

  // Start aes
  if (buffer == 0) {
    pio->start_buf_0 = 1;
  } else {
    pio->start_buf_1 = 1;
  }

  // Wait until aes is done processing
  // while (pio->)
}

void test_aes_128_single (uint32_t buffer) {
  uint32_t key[(16/sizeof(uint32_t))] = {0x00000001, 0x00000000, 0x00000000, 0x00000000};
  uint32_t data[(16/sizeof(uint32_t))] = {0x00000002, 0x00000000, 0x00000000, 0x00000000};
  uint32_t result[(16/sizeof(uint32_t))] = {0x5147A2DF, 0x33A42EE9, 0x7C44182C, 0x9592D775};

  run_aes_blocking(key, (16/sizeof(uint32_t)), data, (16/sizeof(uint32_t)), buffer);

  uint32_t outbuf_addr;
  uint32_t result_chunk;

  if (buffer == 0) {
    outbuf_addr = AES_OUTBUF_0_ADDR;
  } else {
    outbuf_addr = AES_OUTBUF_1_ADDR;
  }

  for (int i = 0; i < (16/sizeof(uint32_t)); ++i) {
    result_chunk = io_read32(outbuf_addr);
    if (result_chunk != result[i]) {
      printf("Result %x @ %x does not match expected output %x. i = %d\n",
        result_chunk, outbuf_addr, result[i], i);
      TEST_FAIL;
    }
    outbuf_addr += sizeof(uint32_t);
  }

}

int main (int argc, char *argv[])
{
	
  printf("Testing reading and writing to some AES registers\n");
  test_wr_registers();
  printf("Testing for unique AES outputs\n");
  test_unique_output();

  uint32_t test_buffer = 0;
  printf("Testing single AES operation on buffer %d \n", test_buffer);
  test_aes_128_single(test_buffer);

	TEST_PASS

    return 0;
}
