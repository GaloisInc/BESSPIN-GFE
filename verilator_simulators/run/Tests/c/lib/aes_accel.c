#include <stdio.h>
#include <stdint.h>
#include "riscv_counters.h"
#include "aes_accel.h"

static struct aes_pio * pio = (void*)AES_BASE_ADDRESS;

int run_aes_blocking(uint32_t *key, uint32_t key_length,
  uint32_t *data, uint32_t data_length, uint32_t buffer) {

  // ----- Validate the inputs -----
  if ( (key_length != 4) & (key_length != 8) ) {
    printf("Key length %d bytes not supported\n", key_length * sizeof(*key));
    return -1;
  }

  if ( (buffer != 0) & (buffer != 1) ) {
    printf("buffer %d not supported. Valid buffers are 0 and 1\n", buffer);
    return -1;
  }

  if (data_length > (AES_INBUF_0_SIZE / sizeof(*data))) {
    printf("Data length %d bytes larger than input buffer size %d bytes\n",
      data_length * sizeof(*data), AES_INBUF_0_SIZE);
    return -1;
  }

  if (data_length > (AES_OUTBUF_0_SIZE / sizeof(*data))) {
    printf("Data length %d bytes larger than output buffer size %d bytes\n",
      data_length * sizeof(*data), AES_OUTBUF_0_SIZE);
    return -1;
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

  // TODO: Pass init vector 
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
  // while (pio-> is busy) {}
  return 0;
}
