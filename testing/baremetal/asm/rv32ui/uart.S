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
  # Arithmetic tests
  #-------------------------------------------------------------

  # Check that uart registers can be accessed
  li t0, UART_BASE
  li t1, ULITE_STATUS
  lw t2, 0(t1)
  TEST_CASE(1, t2, 0x4, )

  # TODO: Flesh this out. ADD TX and RX commands


  # UART receive

  # Check that the same character was received

  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END
