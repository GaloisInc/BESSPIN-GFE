#!/usr/bin/env bash
set -e

# apt-get cleanup
apt-get autoremove -y
apt-get clean
rm -f /var/lib/apt/lists/*debian*
