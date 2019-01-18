# See LICENSE for license details.

#*****************************************************************************
# uart.S
#-----------------------------------------------------------------------------
#
# Test add instruction.
#

#include "riscv_test.h"
#include "test_macros.h"
#include "gfe_macros.h"

RVTEST_RV64U
RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # UART SCRATCH TEST
  #-------------------------------------------------------------

  # Test that the UART scratch register can be written/read
  li t0, UART_BASE
  li t1, 0xBE
  li t2, 0x0
  addi t3, t0, UART_SCR
  sw t1, 0(t3)
  fence
  lw t2, 0(t3)
  TEST_CASE(1, t2, 0xBE, )


  #-------------------------------------------------------------
  # SETUP UART 
  #-------------------------------------------------------------

  # UART_LCR = 0x80
  # This configures the DLAB bit, which allows writing into the Divisor Latch 
  # least significant and most significant bytes.
  li t1, 0x80
  addi t3, t0, UART_LCR
  sw t1, 0(t3)
  # UART_DLL = 0xA3
  # Write to the Divisor Latch least significant byte and write
  # 0x0000_0000 to the Divisor Latch most significant byte in that order.
  li t1, 0xA3
  addi t3, t0, UART_DLL
  sw t1, 0(t3)
  # UART_DLM = 0x0
  li t1, 0x0
  addi t3, t0, UART_DLM
  sw t1, 0(t3)
  # UART_LCR = 0x1F
  # This configures word length to 8 bits,
  # number of stop bits to 2, parity is enabled and set to even parity and the 
  # DLAB bit is set to 0 to enable the use of the Transmitter Holding register
  # and Receiver Buffer register data for transmission and reception
  li t1, 0x1F
  addi t3, t0, UART_LCR
  sw t1, 0(t3)

  #-------------------------------------------------------------
  # LOOP BACK UART VALUES
  #-------------------------------------------------------------

  # Return characters sent over UART
  addi t3, t0, UART_LSR

  # Transmit characters until a response is received
check_for_data:

  # Check if data was received
  lw t1, 0(t3)
  andi t1, t1, UART_LSR_DR
  beq t1, x0, check_for_data

  # Transmit the received single character
  fence
  addi t4, t0, UART_BUFFER
  lw t2, 0(t4)
  fence
  sw t2, 0(t4)
  fence
  j check_for_data

  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END
