#!/usr/bin/env bash

# =========================
# Configuration

BASE_DIR=..

# =========================
# Arguments

PROCNAME=$1
TEST_FILENAME=$2

if [ $# -lt 2 ] || [ $# -gt 4 ]; then
    echo "Usage: $0 <procname> <test_filename> [<output_dir>] [<test_num>]"
    exit 1
fi

if [[ $# -gt 2 ]]; then
    OUTDIR=$3
else
    OUTDIR=.
fi

if [[ $# -gt 3 ]]; then
    TESTNUM=$4
else
    TESTNUM=
fi

echo "Testing $PROCNAME on $TEST_FILENAME"

# =========================
# Naming conventions

TEST_NAME="$(basename -- $TEST_FILENAME)"

TEST_MEMHEX=$OUTDIR/$TEST_NAME.memhex
TEST_GDB_OUTPUT=$OUTDIR/$TEST_NAME$TESTNUM.gdb_log
TEST_TRACE_DATA=$OUTDIR/$TEST_NAME$TESTNUM.gdb_log.trace_data
TEST_TV_LOG=$OUTDIR/$TEST_NAME$TESTNUM.tv_log

TEST_GDB_SCRIPT=$OUTDIR/$TEST_NAME.gdb

# OK to overwrite these log files
ELF_TO_HEX_LOG=$OUTDIR/elf_to_hex.log
NOHUP_LOG=$OUTDIR/nohup.log
GDB_REMOTE_LOG=$OUTDIR/gdb-remote.log
GDB_CLIENT_LOG=$OUTDIR/gdb-client.log
OPENOCD_LOG=$OUTDIR/openocd.log

# =========================
# Tool locations

ELF_TO_HEX=$BASE_DIR/TV-hostside/elf_to_hex
TRACE_WRITER=$BASE_DIR/TV-hostside/TV-trace_writer

GDB=riscv64-unknown-elf-gdb

if [ `echo $PROCNAME | grep -c "_p1"` -gt 0 ]; then
    XLEN=32
else
    XLEN=64
fi

TRACE_CHECKER=$BASE_DIR/TV-hostside/TV-trace_checker_$PROCNAME
echo "Checker is TV-trace_checker_$PROCNAME"

# =========================
# GDB configuration

# Execute -v- and -p- tests differently
if [ `echo $TEST_NAME | grep -c -- "-v-"` -gt 0 ]; then
    #echo "V test"
    BREAKPOINT="terminate"
    RESULTVAR='$a0'
    EXPECTED_PC='(0xffffffffffe00000 | ((unsigned long long)&terminate & 0x1fffff))'
else
    #echo "P test"
    BREAKPOINT="write_tohost"
    RESULTVAR='$gp'
    EXPECTED_PC='&write_tohost'
fi

echo 'Generating GDB script...'
cat >$TEST_GDB_SCRIPT <<EOF
set architecture riscv:rv$XLEN
set remotetimeout 5000
set remotelogfile $GDB_REMOTE_LOG
set logging overwrite
set logging file $GDB_CLIENT_LOG
set logging on
set pagination off

target remote | openocd --debug --log_output $OPENOCD_LOG --command "gdb_port pipe" --file $BASE_DIR/testing/targets/ssith_gfe.cfg

define soft_reset
  set *((int *) 0x6FFF0000) = 1
end

define traces_on
  set *((int *) 0x6FFF0000) = 0x100
end

define traces_off
  set *((int *) 0x6FFF0000) = 0x200
end

define run_test
  dont-repeat

  soft_reset
  monitor reset halt

  delete
  printf "Loading \$arg0\n"
  file \$arg0
  load

  # Force gdb to break at this exact address
  # (otherwise, it tends to skip over function prologue instructions)
  break *(& $BREAKPOINT)

  traces_on
  continue
  traces_off

  if \$pc == $EXPECTED_PC
    if $RESULTVAR == 1
      printf "PASS\n"
    else
      printf "FAIL (tohost=%x)\n", $RESULTVAR
    end
  else
    printf "UNEXPECTED BREAK (pc=%x)\n", \$pc
  end
end

run_test $TEST_FILENAME

#soft_reset
monitor reset halt
disconnect
quit
EOF

# =========================
# Test steps

# Generate <test_name>.memhex
# XXX Do this once and store it with the ELF file
echo "Generating '$TEST_MEMHEX' file..."
$ELF_TO_HEX \
    --bytes-per-word 4 \
    --abs-addressing \
    --base-addr 0x80000000 \
    --mem-size 0x80000000 \
    $TEST_FILENAME \
    $TEST_MEMHEX \
    >$ELF_TO_HEX_LOG 2>&1
if [ $? -ne 0 ]; then
    echo 'UNEXPECTED: Failure running elf_to_hex'
    exit 1
fi
rm -f symbol_table.txt

# Reset bluenoc
echo 'Resetting BlueNoC...'
bluenoc reset
if [ $? -ne 0 ]; then
    echo 'UNEXPECTED: Failure resetting BlueNoC'
    exit 1
fi

# Start the trace writer
echo 'Starting the trace writer...'
nohup $TRACE_WRITER >$NOHUP_LOG 2>&1 &
writer_pid=$!
sleep 1

# Run gdb and record its output to a file
echo 'Running gdb...'
$GDB --batch -x $TEST_GDB_SCRIPT >$TEST_GDB_OUTPUT 2>&1
if [ $? -ne 0 ]; then
    echo 'UNEXPECTED: Failure running gdb'
    exit 1
fi

# Kill the trace writer
# XXX is this needed?
echo "Stopping the trace writer (pid $writer_pid)..."
sleep 1
kill $writer_pid
wait $writer_pid

# Rename the trace
mv trace_data.dat $TEST_TRACE_DATA

# Run the TV Engine and record its output to a file
echo 'Running the trace checker'
$TRACE_CHECKER \
    --show-trace \
    --show-state \
    -m $TEST_MEMHEX \
    --start-pc 0xc0000000 \
    $TEST_TRACE_DATA \
    >$TEST_TV_LOG 2>&1
if [ $? -ne 0 ]; then
    echo 'UNEXPECTED: Failure running the trace checker'
    exit 1
fi

# -------------------------
# Report test result

# Return value of
#   0 = PASS
#   1 = UNEXPECTED (not PASS, possibly FAIL or invalid test)
#   2 = FAIL Self-check
#   3 = FAIL TV check

# Self-check

grep -q -L -E \^FAIL $TEST_GDB_OUTPUT
retVal=$?
if [ $retVal -eq 0 ]; then
    echo 'FAIL: Self-check failed'
    exit 2
else
    grep -q -L -E \^PASS\$$ $TEST_GDB_OUTPUT
    retVal=$?
    if [ $retVal -ne 0 ]; then
	echo 'UNEXPECTED: Self-check did not report PASS or FAIL'
	exit 1
    else
	echo 'Self-check passed'
    fi
fi

# TV check

grep -q -i -E \(compare\|error\|warning\) $TEST_TV_LOG
retVal=$?
if [ $retVal -eq 0 ]; then
    echo 'FAIL: TV log has mismatches'
    exit 3
else
    echo 'No TV mismatches'
fi

# Success
echo 'PASS'
exit 0

# =========================
