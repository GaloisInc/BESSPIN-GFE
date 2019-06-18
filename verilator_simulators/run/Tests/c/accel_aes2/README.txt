Copyright (c) 2019 Bluespec, Inc.  All rights reserved.

This is an example to drive an AES accelerator.

- encrypts 4 blocks of text in software;
- decrypts 4 blocks of text in software;
- encrypts 4 blocks of text in hardware (in the accelerator);
- decrypts 4 blocks of text in hardware (in the accelerator);

- performs various checks that encryption via SW and HW do the same
  thing, and that encryption and decryption are inverses.

Also reports elapsed # of cycles for each step, demonstrating
acceleration by the HW.

This version uses "polling" to detect completion of each step.
