#pragma once
#include "secure-boot/peripheral_commands.h"

world_t secure_boot_measure_peripherals_internal(world_t world, bool* no_failures);
void successful_secure_boot();
