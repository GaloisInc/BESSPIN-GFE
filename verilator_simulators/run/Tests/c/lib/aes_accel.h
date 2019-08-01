
#ifndef __AES_ACCEL__
#define __AES_ACCEL__

#ifndef AES_BASE_ADDRESS
// Replace soft reset in verilator simulation
#define AES_BASE_ADDRESS 0x6fff0000
// Real base address
// #define AES_BASE_ADDRESS 0x62350000
#endif

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

// enum __attribute__ ((__packed__)) msr_t
// {
//   MSR_DCTS = 1,
//   MSR_DDSR = 2,
//   MSR_TERI = 4,
//   MSR_DDCD = 8,
//   MSR_CTS = 0x10,
//   MSR_DSR = 0x20,
//   MSR_RI = 0x40,
//   MSR_DCD = 0x80,
// };

int run_aes_blocking(uint32_t *key, uint32_t key_length, uint32_t *data,
  uint32_t data_length, uint32_t buffer);

#endif
