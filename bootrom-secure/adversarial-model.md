In order to make any guarantees about the execution of a piece of
software running on a system, we must ensure that the system is
executing exactly the expected software, and nothing else. Being sure of
this requires an intricate chain of trust, of which the software itself
is only the final link. The software can only be trusted if the
operating system is one we trust to behave properly; the operating
system can only be trusted if the bootloader is one we trust to behave
properly; and the bootloader can only be trusted only if the hardware
itself, the initial link in the chain, is trustworthy.

Below we discuss one link in this chain, our custom secure boot
mechanism, which sits in the space broadly categorized as "bootloaders"
above. It is the first piece of code executed when the system starts,
and is in charge of performing system checks and launching the operating
system. We will explore the guarantees it demands of the hardware, and
the guarantees it promises to the operating system. We discuss the types
of attacks it protects against, and the types of attacks that it
_cannot_ protect against.

# Demands

Broadly, secure boot assumes that the hardware it is operating on is exactly
the system we designed, and that it is not malfunctioning or suborned. Giving a
complete specification is well beyond the scope of this small document, but
includes the following style of assumptions:

* The processor behaves according to the RISC-V ISA spec [1]; we provide two
  variants of secure boot, one that will work correctly on the RV32I base
  instruction set, and one that will work correctly on the RV64I base
  instruction set.
* There is a read-only memory (ROM) containing the secure boot process we have
  written, and these instructions are correctly transferred to the processor
  and executed before anything else.
* RAM faithfully stores values: reading from an address returns the last value
  written to that address.
* The JTAG hardware debugger interface is disabled or otherwise unavailable.
* The peripherals attached to the system exactly match the following list. For
  each peripheral on the list, the associated documentation is accurate (the
  device really does behave as described) and complete (there are no
  undocumented interfaces that can affect the device's behavior).

[//]: # (TODO: list the peripherals and their documentations. UART+Ethernet+AXI
bus(?)+what else?)

However, we explicitly do not demand that the non-volatile memory storing the
operating system remain uncompromised. As this is a sensitive and easily
modified or replaced peripheral, we take extra care in its treatment.

[//]: # (In particular, we should take care to copy the operating system into
RAM at the same time we're hashing it, not read it from non-volatile memory
once for the hash and once to put it in memory, to prevent an adversarial
non-volatile memory from producing different operating system material between
the two reads. This may take the form of tying closely into the ELF loader, to
check things along the way, rather than as a single monolithic hash. Nothing in
*this* document should have to change as a result, though -- this is just a
reminder about some code we will have to eventually write to live up to the
promises of this document.)

RAM comes a close second for sensitivity and ease of replacement, but there
seems to be little that can be done in the face of sufficiently adversarial
RAM. We therefore include it in our collection of trusted hardware; other
mechanisms than secure boot (such as a tamper-evident enclosure or oblivious
RAM) must be used if modifications to the RAM chips are a concern. Such
mechanisms may also incidentally provide additional protection for the
non-volatile memory; a good outcome from the perspective of defense in depth.

# Guarantees

The secure boot process guarantees that the system will eventually enter one
of the following two states:

1. The _error_ state. Software access to useful computation or to peripherals is
prevented in this state.

2. The _boot_ state. In this state, we guarantee that the peripherals are in a
known-good state (which reduces the number of control flow paths and initial
conditions that need to be tested in the operating system) and that control has
passed to an address in RAM at which is stored exactly the operating system
chosen by the secure boot creator.

The secure boot process also guarantees that no information retrieved
from any peripheral is sent to any other peripheral except RAM, and that
no control flow decisions are made on the basis of information retrieved
from peripherals except the final decision about whether to enter the
error or boot state.

[//]: # (TODO: Future versions of this document should also promise something
about memory protection flags (e.g. as given by the ELF image being loaded) and
MMU stuff.)

# Discussion

In this section we will discuss a handful of system attacks, and how the
adversarial model informs our stance towards these attacks.

## Supply-chain and Installation-time Attacks

Example 1: A corrupted chip fab company inserts a backdoor into the processor
that executes a homebrew operating system instead of the intended one.

Example 2: A corrupted courier captures the ROM chips containing the secure
boot code, replacing them mid-shipment with modified ROMs.

Example 3: An adversary swaps out parts of the system while installing or
configuring it.

Example 4: An adversary attaches a power-glitching module to the
processor to trick it into recording failed sanity checks as successful
instead.

Example 5: An adversary overwrites the nonvolatile memory with corrupted
software.

There is little secure boot can do to protect against the scenarios in examples
1-4. Indeed, with the corrupted courier in example 2, the secure boot code is
not even executed in the first place! These considerations motivate our
reliance on the hardware behaving to specification. Mechanisms other than
secure boot must be used if these possibilities are a concern.

If the corrupted software in example 5 includes the operating system image,
secure boot will detect the attack and refuse to boot the system; if the
operating system is left intact, secure boot may not notice the corruption,
relying on the operating system's own internal software execution security
policies to prevent further problems.

## Exfiltration Attacks

Example 6: An adversary inserts a bump-in-wire keylogger between the keyboard
and computer.

Example 7: An adversary attaches monitoring hardware to the power
supply.

The vast majority of the time the system would be under attack in such
scenarios, the system will be under the control of the operating system.
Therefore the bulk of the protection against such scenarios will be under the
purview of other protection mechanisms.

That said, while we guarantee little about such attacks during secure boot's
execution, we do not anticipate secure boot being involved in handling any
sensitive material -- no private keys are needed to verify the correctness of
the peripherals -- rendering such attacks relatively pointless during secure
boot.

## Software Exploits

Example 8: An adversary exploits a buffer overrun vulnerability in the
running software to surreptitiously patch the software, then reboots the
system to force the corrupted software to take effect.

Example 9: A corrupted system on the network abuses a bug in the
Ethernet driver to gain write access to the boot media, overwriting the
operating system with a corrupted kernel, then signals a confederate to
boot the affected system into the modified OS.

Example 10: A bug in the UART driver accidentally sets the hardware
default rate instead of the current rate; on the next system startup,
the operating system consequently doesn't detect that the UART exists,
takes an untested code path in its initialization procedure, and skips
some critical security check.

Secure boot may not protect the system from the attack in example 8
(which modifies system software, but not the operating system itself);
its role is to ensure that the operating system that's booted is exactly
the intended one, and the OS is expected to enforce further, potentially
more complicated policies on the software it allows to run.

The attacks in examples 9 and 10 (which corrupt the operating system or
other critical nonvolatile hardware state) will be addressed by secure
boot protections; the former by its check of operating system integrity,
and the latter by its check of initial peripheral state. Frequent
enforced hard resets could encourage fault discovery by forcing these
checks often.

[1]
https://github.com/riscv/riscv-isa-manual/releases/download/draft-20190314-bf8dbdb/riscv-spec.pdf
