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
#include <unistd.h>

#include "riscv_counters.h"
#include "aes.xc"

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

void encrypt_sw (uint8_t key [16], uint8_t intext [], uint8_t outtext [])
{
    uint64_t cycle0, cycle1;

    printf ("Encrypting in SW\n");

    aes_context ctx_enc;
    aes_setkey_enc (& ctx_enc, key, 128);

    cycle0 = read_cycle ();

    for (int j = 0; j < n_blocks; j++) {
	aes_crypt_ecb (& ctx_enc, AES_ENCRYPT,
		       & (intext  [j << 4]),
		       & (outtext [j << 4]));
    }
    cycle1 = read_cycle ();
    show_text ("    encrypted_text_sw", outtext, n_blocks * 16);
    printf ("    Encryption_sw cycles: %0ld\n", cycle1 - cycle0);
}

// ================================================================

void decrypt_sw (uint8_t key [16], uint8_t intext [], uint8_t outtext [])
{
    uint64_t cycle0, cycle1;

    printf ("Decrypting in SW\n");

    aes_context ctx_dec;
    aes_setkey_dec (& ctx_dec, key, 128);

    cycle0 = read_cycle ();
    for (int j = 0; j < n_blocks; j++) {
	aes_crypt_ecb (& ctx_dec, AES_DECRYPT,
		       & (intext  [j << 4]),
		       & (outtext [j << 4]));
    }
    cycle1 = read_cycle ();
    show_text ("    decrypted_text_sw", outtext, n_blocks * 16);
    printf ("    Decryption_sw cycles: %0ld\n", cycle1 - cycle0);
}

// ================================================================

void setkey_hw (uint8_t key [16])
{
    volatile uint64_t status;

    printf ("Setting key in HW\n");

    aes_ip [csr_index_key_addr] = (uint64_t) (& (key [0]));
    fence ();
    aes_ip [csr_index_command]  = 1;    // expand key
    // Poll for completion
    while (1) {
	status = aes_ip [csr_index_status];
	if (status != 1) break;
    }

    if (status)
	printf ("    Accel status after key expansion: %0d\n", status);
}

// ================================================================

void encrypt_hw (uint8_t intext [], uint8_t outtext [])
{
    uint64_t cycle0, cycle1;
    volatile uint64_t status;

    printf ("Encrypting in HW\n");

    cycle0 = read_cycle ();
    aes_ip [csr_index_intext_addr]  = (uint64_t) (& (intext [0]));
    aes_ip [csr_index_outtext_addr] = (uint64_t) (& (outtext [0]));
    aes_ip [csr_index_n_blocks]     = n_blocks;
    fence ();
    aes_ip [csr_index_command]      = 2;
    // Poll for completion
    while (1) {
	status = aes_ip [csr_index_status];
	if (status != 1) break;
    }
    fence ();
    cycle1 = read_cycle ();

    if (status != 0)
	printf ("    Accel status after encrypt: %0d\n", status);

    show_text ("    encrypted_text_hw", outtext, n_blocks * 16);
    printf ("    Encryption_hw cycles: %0ld\n", cycle1 - cycle0);
}

// ================================================================

void decrypt_hw (uint8_t intext [], uint8_t outtext [])
{
    uint64_t cycle0, cycle1;
    volatile uint64_t status;

    printf ("Decrypting in HW\n");

    cycle0 = read_cycle ();
    aes_ip [csr_index_intext_addr]  = (uint64_t) (& (intext [0]));
    aes_ip [csr_index_outtext_addr] = (uint64_t) (& (outtext [0]));
    aes_ip [csr_index_n_blocks]     = n_blocks;
    fence ();
    aes_ip [csr_index_command]      = 3;
    // Poll for completion
    while (1) {
	status = aes_ip [csr_index_status];
	if (status != 1) break;
    }
    fence ();
    cycle1 = read_cycle ();

    if (status != 0)
	printf ("    Accel status after decrypt: %0d\n", status);

    show_text ("    decrypted_text_hw", outtext, n_blocks * 16);
    printf ("    Decryption_hw cycles: %0ld\n", cycle1 - cycle0);
}

// ================================================================

int main (int argc, char *argv[])
{
    show_text ("key_text", key, 16);
    show_text ("original_text", original_text, n_blocks * 16);
    /*
    // SW AES encrypt and decrypt
    encrypt_sw (key, original_text,     encrypted_text_sw);
    decrypt_sw (key, encrypted_text_sw, decrypted_text_sw);
    */
    // HW AES encrypt and decrypt
    aes_ip = (uint64_t *) base_addr;    // base addr of CSRs of accelerator
    setkey_hw (key);
    encrypt_hw (original_text,     encrypted_text_hw);
    decrypt_hw (encrypted_text_hw, decrypted_text_hw);

    printf ("\n");
    check_equal ("original_text",     original_text,     "decrypted_text_sw", decrypted_text_sw);
    check_equal ("original_text",     original_text,     "decrypted_text_hw", decrypted_text_hw);
    check_equal ("encrypted_text_sw", encrypted_text_sw, "encrypted_text_hw", encrypted_text_hw);
    printf ("FINISHED\n");
}

// ================================================================
