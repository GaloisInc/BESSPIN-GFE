from lib import *

# TODO: optional parameters:PFC, frame_filter_available, half_duplex_capable, statistics_counters_available, capable_1g, capable_100m, capable_10m


def Ethernet(base, size):
    d = Device('Ethernet', base, size)
    ETH_BASE = base
    # For the device specified in
    # https://www.xilinx.com/support/documentation/ip_documentation/axi_ethernet/v7_0/pg138-axi-ethernet.pdf and https://www.xilinx.com/support/documentation/ip_documentation/tri_mode_ethernet_mac/v8_2/pg051-tri-mode-eth-mac.pdf

    # Our documentation of the assurance case, is explaining why we don't either
    # read or write some bit.
    # NOTE: our device is little-endian

    # We start with the pg138 ethernet device

    # Reset and Address Filter Register
    d.read32(ETH_BASE + 0x0, 0b11111111111111111101000000000001, 0)
    d.write32(ETH_BASE + 0x0, 0b00000000000000000101111111111110, 0)

    # Transmit Pause Frame Register
    d.read32(ETH_BASE + 0x4, 0b11111111111111110000000000000000, 0)
    d.write32(ETH_BASE + 0x4, 0b00000000000000001111111111111111, 0)

    # Transmit Inter Frame Gap Adjustment Register
    d.read32(ETH_BASE + 0x8, 0xffffff00, 0)
    d.write32(ETH_BASE + 0x8, 0x000000ff, 0)

    # Interrupt Status Register
    d.read32(ETH_BASE + 0xC, 0b11111111111111111111111000000000, 0)
    # Bit 7 doesn't have a stable reset value.
    d.write32(ETH_BASE + 0xC, 0b101111111, 0b001000000)

    # Interrupt Pending Register
    d.read32(ETH_BASE + 0x10, 0b11111111111111111111111000000000, 0)
    d.write32(ETH_BASE + 0x10, 0b111111111, 0)

    # Interrupt Enable Register
    d.read32(ETH_BASE + 0x14, 0b11111111111111111111111000000000, 0)
    d.write32(ETH_BASE + 0x14, 0b111111111, 0)

    # TODO: Optionally Enabled Things:
    # - Transmit/Receive VLAN Tag Register
    # - Unicast Address Word Lower Register
    # - VLAN TPID Word 0 Register
    # - VLAN TPID Word 1 Register
    # - PCS PMA TEMAC REGISTER

    # 0x034-0x1FC are reserved, so we don't touch them.
    # Now we move onto the pg051-tri-mode-eth-mac device
    # 0x1FD-0x200 aren't defined.
    # 0x200-0x364 are counters which might be nonzero even on a secure boot after a
    # soft reset.
    # 0x368-0x3FC are reserved.
    # 0x3FD-0x400 aren't defined.

    # Pause frame MAC Source Address
    d.write32(ETH_BASE + 0x400, 0xffffffff, 0xffffffff)
    # Receiver Configuration word
    # Setting this bit resets the rest of this register to defaults.
    d.write32(ETH_BASE + 0x404, 0b10000000000000000000000000000000,
              0b10000000000000000000000000000000)
    # Transmitter Configuration Word
    # Setting this bit resets the rest of this register to defaults.
    d.write32(ETH_BASE + 0x408, 0b10000000000000000000000000000000,
              0b10000000000000000000000000000000)
    # TODO: optional features
    #if PFC:
    #    # Flow Control Configuration Word
    #    d.write32(ETH_BASE + 0x40c, 0b01100110000100001111111111111111,
    #              0b01100000000100001111111111111111)
    # MAC Speed Configuration Word
    d.write32(ETH_BASE + 0x410, 0b11000000000000000000000000000000,
              0b10000000000000000000000000000000)
    # RX Max Frame Configuration Word
    d.write32(ETH_BASE + 0x414, 0b00000000000000010111111111111111,
              0b00000000000000000000011111010000)
    # TX Max Frame Configuration Word
    d.write32(ETH_BASE + 0x418, 0b00000000000000010111111111111111,
              0b00000000000000000000011111010000)
    # TODO: optionally enabled features:
    #if PFC:
    #    # Per Priority Quanta
    #    # The same register format is repeated 7 times.
    #    for idx in range(7):
    #        d.write32(ETH_BASE + 0x480 + (idx * 4), 0xffffffff,
    #                  (0xff00 << 16) | 0xffff)
    #    # Legacy Pause Refresh Register
    #    d.write32(ETH_BASE + 0x4A0, 0b11111111111111110000000000000000,
    #              0xFF00 << 16)
    # ID Register
    # You will likely need to change this value, since it measures the patch-
    # level of the ethernet device.
    #d.read32(ETH_BASE + 0x4F8, 0b11111111111111110000000011111111, 42)
    # Abilty Register
    #d.read32(
    #    ETH_BASE + 0x4FC, 0b00000000000000010000011100000111, (int(PFC) << 16)
    #    | (int(frame_filter_available) << 10) | (int(half_duplex_capable) << 9)
    #    | (int(statistics_counters_available) << 8) | ((int(capable_1g) << 2)))
    # MDIO Configuration Registers
    # MDIO Setup Word
    # TODO: finish up the remainder of the optionally-enabled and configuration-dependent features

    # Interrupt Controller
    # We can't verify the status of interrupts, but we can clear existing interrupts and make sure they're enabled.
    d.write32(ETH_BASE + 0x620, 0xffffff, 0)
    d.write32(ETH_BASE + 0x630, 0xffffff, 0)

    # TODO: more optional features
    # - frame-filter configuration
    # - AVB endpoint
    # - RTC configuration

    return d
