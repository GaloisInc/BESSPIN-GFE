#include <stdio.h>
#include <stdint.h>
#include "riscv_counters.h"
#include "aes_accel.h"

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

void test_aes_128_single (uint32_t buffer) {
  uint32_t key[(16/sizeof(uint32_t))] = {0x00000001, 0x00000000, 0x00000000, 0x00000000};
  uint32_t data[(16/sizeof(uint32_t))] = {0x00000002, 0x00000000, 0x00000000, 0x00000000};
  uint32_t result[(16/sizeof(uint32_t))] = {0x5147A2DF, 0x33A42EE9, 0x7C44182C, 0x9592D775};

  int run_code = run_aes_blocking(key, (16/sizeof(uint32_t)), data, (16/sizeof(uint32_t)), buffer);
  if (run_code != 0){
    printf("run_aes_blocking failed with error code %d\n", run_code);
    TEST_FAIL
  }

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
