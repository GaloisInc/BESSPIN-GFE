#!/usr/bin/env bash

# =========================
# Arguments

PROCNAME=$1

if [ $# -ne 1 ]; then
    echo "Usage: $0 <procname>"
    exit 1
fi

# =========================
# Configuration

BASE_DIR=../..
ELF_TO_HEX=$BASE_DIR/TV-hostside/elf_to_hex
TEST_DIR=$BASE_DIR/riscv-tests
RESULTS_DIR_BASE=Logs/$PROCNAME
PF='pass fail'

if [ `echo $PROCNAME | grep -c "_p1"` -gt 0 ]; then
    XLEN=32
    BOOTROM=TV_bootrom_P1.hex
else
    XLEN=64
    BOOTROM=TV_bootrom_P2.hex
fi

TRACE_CHECKER=$BASE_DIR/TV-hostside/TV-trace_checker_$PROCNAME
echo "Checker is TV-trace_checker_$PROCNAME"

OUTDIR=./tmp
mkdir -p $OUTDIR

for e in $PF; do
    for f in `ls $RESULTS_DIR_BASE/$e | grep -E "\.trace_data$" | sort`; do
	echo
	TEST_NAME="$(basename $f .trace_data)"
	TEST_MEMHEX=$OUTDIR/$TEST_NAME.memhex
	ELF_TO_HEX_LOG=$OUTDIR/elf_to_hex.log
	TEST_TV_LOG=$RESULTS_DIR_BASE/$e/$TEST_NAME.tv_log
	TEST_FILENAME=$TEST_DIR/isa/$TEST_NAME

	echo "Found '$f' ..."
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

	# Run the TV Engine and record its output to a file
	echo 'Running the trace checker'
	$TRACE_CHECKER \
	    --show-trace \
	    --show-state \
	    -b $BOOTROM \
	    -m $TEST_MEMHEX \
	    --start-pc 0x70000000 \
	    $RESULTS_DIR_BASE/$e/$f \
	    >$TEST_TV_LOG 2>&1
	if [ $? -ne 0 ]; then
	    echo 'UNEXPECTED: Failure running the trace checker'
	    exit 1
	fi

	grep -q -i -E \(compare\|error\|warning\) $TEST_TV_LOG
	retVal=$?
	if [ $retVal -eq 0 ]; then
	    echo 'FAIL: TV log has mismatches'
	fi
    done
done

# TODO: Return non-zero if any tests didn't PASS?
exit 0
# =========================
