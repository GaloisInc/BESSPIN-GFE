#include <stdio.h>
#include <stdint.h>
#include "riscv_counters.h"

typedef uint64_t datum;     /* Set the data bus width to 64 bits. */

#define AES_BASE_ADDRESS 0x6fff0000

#define AES_INBUF_0_ADDR 0x1000 + AES_BASE_ADDRESS
#define AES_INBUF_1_ADDR 0x2000 + AES_BASE_ADDRESS
#define AES_OUTBUF_0_ADDR 0x3000 + AES_BASE_ADDRESS
#define AES_OUTBUF_1_ADDR 0x4000 + AES_BASE_ADDRESS

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

int main (int argc, char *argv[])
{
	// Perform read write checks on basic registers
	pio->key_0 = 0xdeadbeef;
	pio->key_2 = 0xaaaaaaaa;
	pio->init_vector_0 = 0x00000001;
	pio->init_vector_2 = 0x00000002;
	pio->buffer_0_page_size = 0x0;
	pio->buffer_1_page_size = 0x0;

	// Load the input data
	io_write32 (AES_INBUF_0_ADDR, 0xfeedbead);
	io_write32 (AES_INBUF_0_ADDR + 0x8, 0xcccccccc);
	io_write32 (AES_INBUF_1_ADDR, 0x12345678);
	io_write32 (AES_INBUF_1_ADDR + 0x8, 0xdddddddd);

	printf("%x @ AES_OUTBUF_0_ADDR\n", io_read32(AES_OUTBUF_0_ADDR));

	fence();

	// Start encrypting
	pio->start_buf_0 = 1;
	pio->start_buf_1 = 1;

	printf ("pio->acc_state_lsw %x\n", pio->acc_state_lsw);

	uint32_t result_buf_0 = io_read32(AES_OUTBUF_0_ADDR);
	uint32_t result_buf_1 = io_read32(AES_OUTBUF_1_ADDR);
	printf("%x @ AES_OUTBUF_0_ADDR\n", result_buf_0);
	printf("%x @ AES_OUTBUF_1_ADDR\n", result_buf_1);

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

	TEST_PASS

    return 0;
}
