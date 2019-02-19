#pragma once

#include <stdbool.h>

// This function will return true if the secure boot succeeded, and false
// if it failed.
bool secure_boot_measure_peripherals();

// Start the selected operating system.
// (Actually implemented in peripherals_generated_code.c, not peripherals.c!)
void successful_secure_boot();
