#!/usr/bin/env bash

# =========================
# Configuration

BASE_DIR=..
TEST_DIR=$BASE_DIR/riscv-tests

RESULTS_DIR_PREFIX=results

# =========================
# Arguments

PROCNAME=$1

if [ $# -ne 1 ]; then
    echo "Usage: $0 <procname>"
    exit 1
fi

# =========================

if [[ $PROCNAME =~ ^(chisel|bluespec)_p(1|2|3)$ ]]; then
    PROCTYPE=${BASH_REMATCH[1]}
    PROCNUM=${BASH_REMATCH[2]}
else
    echo "Processor '$PROCNAME' not recognized or does not support TV"
    exit 1
fi

if [ $PROCNUM -eq 1 ]; then
    XLEN=32
    PRIV=mu
    ISA=imu
    ENV='p'
else
    XLEN=64
    PRIV=msu
    ISA=imafdc
    ENV='p v'
fi

# =========================

RESULTS_DIR=${RESULTS_DIR_PREFIX}_$PROCNAME

# Make sure that we're working with a clean output directories
rm -rf $RESULTS_DIR
mkdir $RESULTS_DIR

# Save the current directory
# so that we can return if we execute commands elsewhere
RUNDIR=`pwd`

# Make sure that the tests have been compiled
echo "Compiling riscv-tests..."
cd $BASE_DIR/riscv-tests
CC=riscv64-unknown-elf-gcc ./configure --with-xlen=${XLEN} --target=riscv64-unknown-elf \
  >$RUNDIR/$RESULTS_DIR/riscv-tests-configure.log 2>&1
make >$RUNDIR/$RESULTS_DIR/riscv-tests-make.log 2>&1
retVal=$?
cd $RUNDIR
if [[ $retVal -ne 0 ]]; then
    echo 'Failed to make isa tests'
    exit 1
fi

# Program the FPGA with the appropriate bitstream
echo "Programming the FPGA with '$PROCNAME'..."
cd $BASE_DIR
./pyprogram_fpga.py $PROCNAME >$RUNDIR/$RESULTS_DIR/program_fpga.log 2>&1
if [[ $? -ne 0 ]]; then
    echo 'Programming the FPGA failed'
    exit 1
fi
cd $RUNDIR
sleep 1

# Bring the PCIe endpoint and BlueNoC bridge online
echo "Performing BlueNoC PCIe hotswap..."
bluenoc_hotswap >$RESULTS_DIR/bluenoc_hotswap.log 2>&1
if [ $? -ne 0 ]; then
   echo 'ERROR: PCIe hotswap did not bring up a valid BlueNoC device'
   echo '       (Perhaps a reset of the host is needed?)'
   exit 1
fi

#echo Testing $PROCNAME on all relevant ISA tests...

NUMTESTS=0
PASSCOUNT=0
SCFAILCOUNT=0
TVFAILCOUNT=0
UNEXPCOUNT=0
SKIPCOUNT=0
SCFAILLIST=
TVFAILLIST=
UNEXPLIST=
SKIPLIST=

for e in $ENV; do
    for f in `ls $TEST_DIR/isa/rv$XLEN[$PRIV][$ISA]-$e-* | grep -vE ".dump$" | sort`; do
	echo
	# Count the number of tests
	NUMTESTS=$(( $NUMTESTS + 1 ))
	# Skip tests that are known not to work
	if [[ $f =~ -sbreak$ ]]; then
	    echo "Skipping $f"
	    SKIPCOUNT=$(( $SKIPCOUNT + 1 ))
	    SKIPLIST="$SKIPLIST $f"
	    continue
	fi
	./test_tv_one_isa.sh $PROCNAME $f $RESULTS_DIR
	retVal=$?
	if [ $retVal -eq 0 ]; then
	    PASSCOUNT=$(( $PASSCOUNT + 1 ))
	else
	    if [ $retVal -eq 2 ]; then
		# Self-check failure
		SCFAILCOUNT=$(( $SCFAILCOUNT + 1 ))
		SCFAILLIST="$SCFAILLIST $f"
	    else
		if [ $retVal -eq 3 ]; then
		    # TV check failure
		    TVFAILCOUNT=$(( $TVFAILCOUNT + 1 ))
		    TVFAILLIST="$TVFAILLIST $f"
		else
		    # Unexpected behavior (fail or invalid test)
		    UNEXPCOUNT=$(( $UNEXPCOUNT + 1 ))
		    UNEXPLIST="$UNEXPLIST $f"
		fi
	    fi
	fi
    done
done

echo
echo '-------------------------'
echo "Finished running $NUMTESTS tests"
echo
echo "Pass count: $PASSCOUNT"
echo "Skip count: $SKIPCOUNT"
echo "Self-check fail count: $SCFAILCOUNT"
echo "TV check fail count: $TVFAILCOUNT"
echo "Unexpected behavior count: $UNEXPCOUNT"
if [[ $SKIPCOUNT -gt 0 ]]; then
    echo
    echo 'Skipped tests:'
    for f in $SKIPLIST; do
	echo "    $f"
    done
fi
if [[ $SCFAILCOUNT -gt 0 ]]; then
    echo
    echo 'Self-check failed tests:'
    for f in $SCFAILLIST; do
	echo "    $f"
    done
fi
if [[ $TVFAILCOUNT -gt 0 ]]; then
    echo
    echo 'TV check failed tests:'
    for f in $TVFAILLIST; do
	echo "    $f"
    done
fi
if [[ $UNEXPCOUNT -gt 0 ]]; then
    echo
    echo 'Unexpected behavior tests:'
    for f in $UNEXPLIST; do
	echo "    $f"
    done
fi
echo -------------------------

# TODO: Return non-zero if any tests didn't PASS?
exit 0
# =========================

