#!/bin/bash

yes | apt-get autoremove

apt-get clean

rm /var/lib/apt/lists/*debian*
