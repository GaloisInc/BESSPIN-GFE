Copyright (c) 2019 Bluespec, Inc.  All rights reserved.

This is an example to drive an AES accelerator.

- encrypts 4 blocks of text in hardware (in the accelerator);
- decrypts 4 blocks of text in hardware (in the accelerator);

- performs check that encryption and decryption are inverses.

Also reports elapsed # of cycles for each step.

This version uses "interrupts" to detect completion of each step.
