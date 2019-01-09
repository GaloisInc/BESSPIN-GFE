import gfetester

gfe = gfetester.gfetester()
status_reg = gfe.riscvRead32(0x62300008)