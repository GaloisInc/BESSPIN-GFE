 # Tandem Verification for Chisel and Bluespec Processors #

## Running TV ##

**VERILATOR SIMULATION**

By default, the Verilator simulators write a TV trace file (trace_out.dat).
We use the script for running and verifying the ISA tests as an example of how
to check the traces thus produced.  When running the isa tests, e.g. by
```bash
./pytest_processor.sh --isa --sim <proc_name>
```
the trace files are left in `verilator_simulators/run/Logs`, named
`<test_name>.trace_data`.  There is a script, `check_traces.sh` in
`verilator_simulators/run`, which will verify these traces. It is called by
```bash
./check_traces.sh <proc_name>
```
and proceeds as follows:

1. Scans the log directory for trace_data files

2. For each file, writes a .memhex file from the test's .elf file

3. Preloads the verifier with that .memhex file

4. Runs the relevant TV_trace_checker verifier (e.g. TV-trace_checker_bluespec_p1)
```bash
<gfe directory>/TV-hostside/TV-trace_checker_<proc_name>
	    --show-trace \
	    --show-state \
	    -b <memhex file for bootrom> \
	    -m <memhex file for test program> \
	    --start-pc 0x70000000 \
	    <name of trace file> \
	    ><name of log file> 2>&1
```

Please use the -h flag to get more information about these ane other flags
from the checker programs themselves.

**VCU118**

Note that generating TV traces from the FPGA needs an operational connection
using the VCU118's PCIe fingers.  See the main README.md file for instructions
about setting this up.

Again we use the isa tests as an example.  There is a script in the testing_tv
directory, test_tv_isa.sh, which in turn invokes a script test_tv_one_isa.sh
for each test.  Please use these scripts as examples for other uses.

`test_tv_isa.sh` does the following:

1. Compiles the tests if necessary

2. Programs the FPGA with the appropriate bitstream

3. Does `bluenoc_hotswap` to bring the PCIe connection online

4. Applies `test_tv_one_isa.sh` to each relevant test

5. Collects pass/fail statistics.

Note that this requires the `bluenoc_hotswap` program (a) to be in the PATH,
and (b) to work on your motherboard.  If this is not the case, you will need
to adapt the procedure to program the FPGA manually, and then to reboot the
host machine, with either a cold or warm reboot as needed.

For each test, `test_tv_one_isa.sh` does the following:

1. Generates a gdb script for the test

2. Generates a `.memhex` file to preload the verifier

3. Resets the PCIe/bluenoc link

4. Starts the trace writer to record traces received over the link
```bash
<gfe directory>/TV-hostside/TV-trace_writer
```
(This will record traces it receives in a file named "trace_data.dat".)

5. Runs the gdb script, which

   (a) resets the processor

   (b) loads the RISC-V .elf file into the board's  memory

   (c) sets a gdb breakpoint to detect termination of the test

   (d) gives the command to instruct the SoC to transmit traces

   (e) "continue"s the program

   (f) when the breakpoint happens, gives the command to stop trace transmission

   (g) prints "PASS", "FAIL" etc.

6. Stops the trace writer program

7. Runs the verifier and files its output
```bash
<gfe directory>/TV-hostside/TV-trace_checker_<proc_name>
	    --show-trace \
	    --show-state \
	    -m <memhex file for test program> \
	    --start-pc 0xC0000000 \
	    <name of trace file> \
	    ><name of log file> 2>&1
```

8. Reports the result

Note that for 5(d) and 5(f) above, the gdb command to instruct that transmission of traces start is

```bash
set *((int *) 0x6FFF0000) = 0x100
```
and to stop them it is
```bash
set *((int *) 0x6FFF0000) = 0x200
```
(or writing 1 or 2 respectively to byte 0x6FFF0001 in the SoC's address space).


## Tandem Verification results summary ##

The following tables provide the summary of the state mismatches between the FPGA traces captured for \<proc\> and `./TV-trace_checker_<proc_name>`. The traces can be found in the directory `testing_tv`. All processors pass all of their ISA tests. These mismatches result from a more rigorous comparison of DUT internal state with a reference model. Mismatches occur for one of several reasons:
1. The DUT behavior is legal but the `./TV-trace_checker_<proc_name>` does not model the DUT exactly.
2. The DUT has a bug.
3. The DUT has a bug in its trace generation.
The mismatches will be evaluated and fixes provided if the benefit justifies the effort. Otherwise, the mismatch will be documented as a known acceptable difference.



| Item | Chisel P1 TV Mismatch | Tests Affected |
|-----:|:-------------------------|:---------------|
| - | none | none |


| Item | Chisel P1/P2 TV Mismatch | Tests Affected |
|-----:|:-------------------------|:---------------|
| 1 | chisel_p{1,2} appears to support hardware breakpoints via the TDATA1 CSRs. This feature could be added to TV-trace_checker_chisel_p{1,2} but it will take some thought. | rv{32,64}mi-p-breakpoint |
| 2 | chisel_p{1,2} allows MISA.C to be written, TV-trace_checker_chisel_p{1,2} do not. Consider updating TV-trace_checker_chisel_p{1,2} to match chisel_p{1,2} behavior. | rv{32,64}mi-p-ma_fetch |
| 3 | chisel_p{1,2} gives the wrong trace for MSTATUS on xRET instructions at the start of every test and in the middle for some tests, because TV-trace_checker_chisel_p{1,2} is forced to overwrite its correct value with this bad trace value. | All tests. |
| 4 | chisel_p{1,2} gives wrong trace for MSTATUS on ECALL instructions which happens at the end of every test. | All tests. |
| 5 | chisel_p{1,2} is missing trace for M-extension instructions. For REM/DIV/MUL instructions, the entire line of trace is missing; and there seem to be other issues that pop up related to instructions executed around it (such as duplicated lines of trace). | rv32um-* |
| 6 | chisel_p{1,2} gives wrong trace for CSRRC[I] and CSRRS[I] instructions. | rv{32,64}mi-p-csr |

| Item | Chisel P2 TV Mismatch | Tests Affected |
|-----:|:----------------------|:---------------|
| 7 | The bad xRET/ECALL trace (mentioned in #3 and #4 for Chisel P1/P2) causes additional problems for p2 because it implements all three privilege modes instead of just one.  When TV-trace_checker_chisel_p2 is forced to accept the wrong privilege mode (because the chisel_p2's trace had the wrong mode) then everything goes wrong after that and there are many mismatches. The workaround requires some careful thinking. This mismatch occurs every -v- test because virtual addresses depend on the correct privilege mode. | All -v- tests. |
| 8 | chisel_p2 provides no trace for F and D instructions (similar to the M-extension instruction in #5 for Chisel P1/P2). When TV-trace_checker_chisel_p2 is forced to match, everything goes wrong for later F/D instructions, rendering those tests impossible to read. | rv64u{d,f}-* |
| 9 | The chisel_p2 is missing trace for SFENCE.VMA. | rv64si-p-dirty |
| 10|  chisel_p2 has a missing trace and a duplicate trace in the LR/SC test (A-extension). | rv64ua-{p,v}-lrsc |
| 11|  chisel_p2 might have a timer going off before tests are run, and nothing in the test is clearing these before a test begins, so there's a mismatch in the MIP CSR. (Or possibly there's a bug that the chisel_p2 isn't reporting the MIP change in its trace.)(#7 in the p3 list) | rv64mi-p-illegal |
| 12|  The trace for a CSR write seems to be returning a value from the future! (a value from a later instruction, so possibly a bug in how values at various points in the pipeline are gathered). | rv64u{d,f}-* |
| 13|  chisel_p2 appears to be truncating some addresses, even for valid addresses and not just invalid addresses.  For virtual PCs, some addresses with FFFFFFFF in the upper 32 bits are truncated to just have FF. | All -v- tests. |
| 14|  chisel_p2 emits bad trace when there's an instruction fetch exception; specifically, the chisel_p2 still tries to include a trace of the instruction, but no bits were retrieved, so it reports a bogus instruction. This affects all the -v- tests, where the first fetch to a virtual address is a trap that causes the handler to populate the translation table. | rv64mi-p-illegal and all -v- tests |
| 15| chisel_p2 trace bug when executing JALR on an invalid address. | rv64mi-p-access |

| Item | Chisel P3 TV Mismatch | Tests Affected |
|-----:|:----------------------|:---------------|
| 1 | chisel_p3 doesn't send trace for EBREAK memory writes. Possible solutions: (a) TV checker ignores that kind of mismatch; (b) use an "out of band" means to tell the TV checker where to insert an EBREAK in memory (a flag, or perhaps even encoding it directly in the memhex file loaded into the model's memory). | All -v- tests. |
| 2 | chisel_p3 allows MISA.C bit to be written, TV-trace_checker_chisel_p3 and Bluespec processors do not. Both behaviors are valid. (Same issue as #2 for chisel_p{1,2} | rv64mi-p-ma_fetch |
| 3 | chisel_p3 has MISA.X bit set, TV-trace_checker_chisel_p3 does not. TV-trace_checker_chisel_p3 could be made to also set this bit. What is less clear is that the chisel_p3 also occasionally sets MSTATUS.XS to indicate when the X state is dirty, and for TV-trace_checker_chisel_p3 to model that we'd need to know how the chisel_p3 is deciding that. Would need to understand why chisel_p3 has X and what it's used for. | rv64mi-p-{csr,ma_fetch,mcsr} |
| 4 | chisel_p3 writing to MSTATUS.FS seems to cause the FS field to be set to dirty. Potential chisel_p3 bug.  | rv64u{d,f}-* |
| 5 | chisel_p3 trace bug when executing JALR on an invalid address. | rv64mi-p-access |
| 6 | chisel_p3 shortens invalid addresses when writing them to MEPC and MTVAL. TV-trace_checker_chisel_p3 could be adjusted to match this. It's unclear what chisel_p3's function for this from the trace mismatches or by inspecting the DUR source code. | rv64mi-p-access |
| 7 | chisel_p3 might have a timer going off before tests are run, and nothing in the test is clearing these before a test begins, so there's a mismatch in the MIP CSR. (Or possibly there's a bug that the chisel_p3 isn't reporting the MIP change in its trace.) (same issue as chisel_p2 #11.) | rv64mi-p-illegal |
| 8 | Apparent chisel_p3 trace bug on interrupt by not giving the right MCAUSE. (Interestingly, chisel_p2 gets the MCAUSE correct, and doesn't take the IRQ until later when the context changes, presumably into a context where the IRQs are now enabled; maybe chisel_p3 is incorrectly taking the IRQ at this point?) This appears in one test, but only because of the MIP issue above; as far as we know, no test intentionally tests interrupts, so we wouldn't ordinarily be testing this trace. | rv64mi-p-illegal |
| 9 | chisel_p3 opts to not store instruction bits in MTVAL on illegal instruction traps.  We can make TV-trace_checker_chisel_p3 match this behavior. (Maybe the Chisel core could have been generated to behave differently?) | rv64mi-p-{csr,illegal} |
| 10|  Possible difference in how the chisel_p3 and TV-trace_checker_chisel_p3 update MEPC values when the minimum instruction width changes (that is, MISA.C is turned off or on). Currently TV-trace_checker_chisel_p3 isn't allowing that, so we don't know, but when that's fixed we might uncover a new mismatch to be addressed. | rv64mi-p-illegal |
| 11|  chisel_p3 appears to have a bug when tracing FCVT instructions, printing a change in FFLAGS at the wrong time. Maybe a bug in how the out-of-order execution is handled. | rv64u{d,f}-{p,v}-fvct* |


| Item | Bluespec P1 TV Mismatch | Tests Affected |
|-----:|:------------------------|:---------------|
| - | none | none |


| Item | Bluespec P2 TV Mismatch | Tests Affected |
|-----:|:------------------------|:---------------|
| 1 | On CSRR* writes to FCSR, bluespec_p2 is marking the FP state as dirty (in MSTATUS) but isn't send a trace update for MSTATUS.  This only shows up in the -p- tests, where the write causes a change from initial to dirty; in the -v- tests, prior instructions have already marked the state as dirty, so the write does not cause a change that needs to be reported. | rv64u{f,d}-p-* |
| 2 | Bluespec_p2 is incorrectly reporting an update to FFLAGS on FMV.X.F and FMV.X.D instructions. | rv64u{f,d}-{p,v}-{fadd,fdiv,fmadd,fmin} and rv64ud-{p,v}-recoding |
| 3 | Bluespec_p2 is reporting an incorrect FFLAGS value on an FADD.S instruction. | rv64ud-{p,v}-recoding |

| Item | Bluespec P3 TV Mismatch | Tests Affected |
|-----:|:------------------------|:---------------|
| - | none | none |
