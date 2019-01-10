#!/usr/bin/env python

import gfetester

uart_status_reg = 0x62300008
gfe = gfetester.gfetester()
print(gfe.riscvRead32(0x62300008))
