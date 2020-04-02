#include "sbassert.h"
#include "secure-boot/peripherals.h"

static void unsuccessful_secure_boot() {
    SB_ASSERT(0, "unsuccessful secure boot");
}

void bootrom_main(void) {
    if (!secure_boot_measure_peripherals()) {
        unsuccessful_secure_boot();
    }
    successful_secure_boot();
}
