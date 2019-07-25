#include <stdio.h>
#include <stdint.h>
#include "riscv_counters.h"

typedef uint64_t datum;     /* Set the data bus width to 64 bits. */

#define AES_BASE_ADDRESS (volatile datum *) 0x6fff0000

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
	pio->key_1 = 0x00000001;
	pio->key_2 = 0x00000002;
	pio->key_3 = 0x00000003;
	pio->key_4 = 0x00000004;
	pio->key_5 = 0x00000005;
	pio->key_6 = 0x00000006;
	pio->key_7 = 0x00000007;

	fence();

	// Read the accelerator state 
	printf ("pio->cmd %x\n", pio->cmd);
	printf ("pio->acc_state_lsw %x\n", pio->acc_state_lsw);
	printf ("pio->acc_state_msw %x\n", pio->acc_state_msw);
	printf ("pio->init_vector_0 %x\n", pio->init_vector_0);
	printf ("pio->init_vector_1 %x\n", pio->init_vector_1);
	printf ("pio->init_vector_2 %x\n", pio->init_vector_2);
	printf ("pio->init_vector_3 %x\n", pio->init_vector_3);
	printf ("pio->key_0 %x\n", pio->key_0);
	printf ("pio->key_6 %x\n", pio->key_6);

	// Check some of these values
	if (pio->key_0 != 0xdeadbeef) {
		TEST_FAIL
	}

	TEST_PASS

    return 0;
}
