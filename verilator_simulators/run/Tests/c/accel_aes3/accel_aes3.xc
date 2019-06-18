// Copyright (c) 2019 Bluespec, Inc.  All Rights Reserved
// Author: Rishiyur S. Nikhil

// ================================================================
// AES Accelerator Demo.

// Run the following, once purely in SW, once using HW AES accelerator:
// SW:  original_text     -> encrypted_text_sw
// SW:  encrypted_text_sw -> decrypted_text_sw
// HW:  original_text     -> encrypted_text_hw
// HW:  encrypted_text_hw -> decrypted_text_hw
// Check original_text == decrypted_text_sw
// Check original_text == decrypted_text_hw
// Check encrypted_text_sw == encrypted_text_hw
// Report cycle times for each encryption/decryption

// ================================================================

#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include <ctype.h>
#include <stdbool.h>
#include <unistd.h>

#include "riscv_counters.h"

// ================================================================
// Headers for assembly-language functions

extern uint64_t csrr_mie (void);
extern void csrw_mie (uint64_t x);
extern void csrs_mie (uint64_t x);
extern void csrc_mie (uint64_t x);

extern uint64_t csrr_mstatus (void);
extern void csrw_mstatus (uint64_t x);
extern void csrs_mstatus (uint64_t x);
extern void csrc_mstatus (uint64_t x);

// ================================================================

// 128b key
uint8_t key               [16] =  "OpenSesameShazam";

uint8_t original_text     [64] = ("Ali Baba and the"
				  " forty thieves' "
				  "hidden cave with"
				  " treasure'n gold");
uint64_t n_blocks = 4;

uint8_t encrypted_text_sw [64];
uint8_t decrypted_text_sw [64];
uint8_t encrypted_text_hw [64];
uint8_t decrypted_text_hw [64];

// ================================================================

// Base address of the AES accelerator IP
const uint64_t base_addr = 0x62400000;

// Pointer to array of AES IP CSRs
uint64_t *aes_ip;

// Indexes of AES IP CSRs
const int csr_index_command      = 0;
const int csr_index_status       = 1;
const int csr_index_key_addr     = 2;
const int csr_index_intext_addr  = 3;
const int csr_index_outtext_addr = 4;
const int csr_index_n_blocks     = 5;

volatile bool interrupt_received = false;

// ================================================================

void show_text (char *title, uint8_t text[], int len)
{
    printf ("%s: \'", title);
    for (int j = 0; j < len; j++) {
	uint8_t ch = text [j];
	if (isprint (ch)) printf ("%c", ch);
	else printf ("[\\%02x]", ch);
    }
    printf ("\'\n");
}

// ================================================================

void check_equal (char *title1, uint8_t text1 [], char *title2, uint8_t text2 [])
{
    int j;

    for (j = 0; j < n_blocks * 16; j++)
	if (text1 [j] != text2 [j]) goto report_error;

    printf ("OK: %s == %s\n", title1, title2);
    return;

  report_error:
    printf ("    ERROR\n");
    show_text (title1, text1, n_blocks * 16);
    show_text (title2, text2, n_blocks * 16);
}

// ================================================================

void wait_for_completion (void)
{
    while (! interrupt_received) {
	// OLD:
	// status = aes_ip [csr_index_status];
	// if (status != 1) break;
    }
    interrupt_received = false;
}

// ================================================================

void setkey_hw (uint8_t key [16])
{
    printf ("Setting key in HW\n");

    aes_ip [csr_index_key_addr] = (uint64_t) (& (key [0]));
    fence ();
    aes_ip [csr_index_command]  = 1;    // expand key
    wait_for_completion ();
}

// ================================================================

void encrypt_hw (uint8_t intext [], uint8_t outtext [])
{
    uint64_t cycle0, cycle1;

    printf ("Encrypting in HW\n");

    cycle0 = read_cycle ();
    aes_ip [csr_index_intext_addr]  = (uint64_t) (& (intext [0]));
    aes_ip [csr_index_outtext_addr] = (uint64_t) (& (outtext [0]));
    aes_ip [csr_index_n_blocks]     = n_blocks;
    fence ();

    aes_ip [csr_index_command]      = 2;

    wait_for_completion ();

    fence ();
    cycle1 = read_cycle ();

    show_text ("    encrypted_text_hw", outtext, n_blocks * 16);
    printf ("    Encryption_hw cycles: %0ld\n", cycle1 - cycle0);
}

// ================================================================

void decrypt_hw (uint8_t intext [], uint8_t outtext [])
{
    uint64_t cycle0, cycle1;

    printf ("Decrypting in HW\n");

    cycle0 = read_cycle ();
    aes_ip [csr_index_intext_addr]  = (uint64_t) (& (intext [0]));
    aes_ip [csr_index_outtext_addr] = (uint64_t) (& (outtext [0]));
    aes_ip [csr_index_n_blocks]     = n_blocks;
    fence ();

    aes_ip [csr_index_command]      = 3;

    wait_for_completion ();

    fence ();
    cycle1 = read_cycle ();

    show_text ("    decrypted_text_hw", outtext, n_blocks * 16);
    printf ("    Decryption_hw cycles: %0ld\n", cycle1 - cycle0);
}

// ================================================================
// Set up PLIC (Platform-Level Interrupt Controller)

uint64_t  plic_addr_base               = 0x0C000000;
uint64_t  plic_source_2_priority       = 0x00000008;
uint64_t  plic_pending                 = 0x00001000;
uint64_t  plic_target_0_enables        = 0x00002000;
uint64_t  plic_target_0_threshold      = 0x00200000;
uint64_t  plic_target_0_claim_complete = 0x00200004;

void setup_plic (void)
{
    uint32_t *p;

    // Enable interrupts for (source 2, target 0)
    printf ("setup_plic: enable interrupts for source 1 target 0\n");
    p = (uint32_t *) (plic_addr_base + plic_target_0_enables);
    *p = 0x4;

    // Set priority for (source 2, target 0)
    printf ("setup_plic: set priority for source 1 target 0\n");
    p = (uint32_t *) (plic_addr_base + plic_source_2_priority);
    *p = 0x7;

    // Set priority threshold for target 0
    printf ("setup_plic: set priority threshold for target 0\n");
    p = (uint32_t *) (plic_addr_base + plic_target_0_threshold);
    *p = 0x0;
}

void exception_handler (uint64_t mstatus, uint64_t mepc, uint64_t mcause, uint64_t mtval)
{
    printf ("exception_handler: mstatus %0x mepc %0x mcause %0x mtval %0x\n",
	    mstatus, mepc, mcause, mtval);

    if ((mcause >> 63) == 1) {
	interrupt_received = true;

	// Claim the interrupt at the PLIC
	printf ("Claiming interrupt from PLIC\n");
	uint32_t *p = (uint32_t *) (plic_addr_base + plic_target_0_claim_complete);
	uint32_t interrupt_source_id = *p;
	printf ("Interrupt claimed: id = 0x%0x\n", interrupt_source_id);

	// Write NOOP command to Accel so it can drop its interrupt
	aes_ip [csr_index_command] = 0;
	// Readback command to ensure it's done
	while (1) {
	    volatile uint64_t command = aes_ip [csr_index_command];
	    if (command == 0) break;
	}

	// Signal completion of interrupt handling
	printf ("Completing interrupt at PLIC\n");
	*p = interrupt_source_id;
    }
    else
	printf ("exception_handler: not an interrupt\n");
}

// ================================================================
// Interrupt management

void enable_mie_meie (void)
{
    uint64_t mie = csrr_mie ();
    printf ("Enable MIE interrupts: %0x => %0x\n", mie, (mie | 0x800));
    csrs_mie (0x800);
}

void disable_mie_meie (void)
{
    uint64_t mie = csrr_mie ();
    printf ("Disable MIE interrupts: %0x => %0x\n", mie, (mie & (~ 0x800)));
    csrc_mie (0x800);
}

void enable_mstatus_mie (void)
{
    uint64_t mstatus = csrr_mstatus ();
    printf ("Enable MSTATUS interrupts: %0x => %0x\n", mstatus, (mstatus | 0x8));
    csrs_mstatus (0x8);
}

// ================================================================

int main (int argc, char *argv[])
{
    setup_plic ();            // Set up the PLIC to accept interrupts from Accel_AES
    enable_mie_meie ();       // Enable M-privilege external interrupts in MIE CSR
    enable_mstatus_mie ();    // Enable M-privilege external interrupts in MSTATUS CSR

    show_text ("key_text", key, 16);
    show_text ("original_text", original_text, n_blocks * 16);

    // HW AES encrypt and decrypt
    aes_ip = (uint64_t *) base_addr;    // base addr of CSRs of accelerator
    setkey_hw (key);
    encrypt_hw (original_text,     encrypted_text_hw);
    decrypt_hw (encrypted_text_hw, decrypted_text_hw);

    printf ("\n");
    check_equal ("original_text",     original_text,     "decrypted_text_hw", decrypted_text_hw);
    printf ("FINISHED\n");
}

// ================================================================
