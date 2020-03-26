#include "secure-boot/peripherals_generated_code.h"

bool secure_boot_measure_peripherals() {
    bool no_failures = true;
    world_t world = 0;
    secure_boot_measure_peripherals_internal(world, &no_failures);
    return no_failures;
}
