#!/bin/bash

yes | apt-get autoremove

apt-get clean

rm /var/lib/apt/lists/deb.*

# Remove foreign language man files
rm -rf /usr/share/man/??
rm -rf /usr/share/man/??_*

# Remove locale directory
rm -rf /usr/share/locale/

# Remove documentation
rm -rf /usr/share/doc/

# Remove dictionary
rm -rf /usr/share/dict/
