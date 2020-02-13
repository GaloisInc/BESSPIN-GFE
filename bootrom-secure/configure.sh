#!/usr/bin/env bash

# Get the path to the root folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

if [[ -z "$1" || -z "$2" ]]; then
    echo "usage: configure.sh <sha256sum> <size>"
    exit 1
fi

cd $BASE_DIR/secure-boot/peripherals
cat config.py.tmpl | awk -v sizetmpl="<SIZE>" -v size="$2" -v shatmpl="<SHA256SUM>" -v sha="$1" '{ sub(sizetmpl,size,$0); sub(shatmpl,sha,$0); print $0 }' > config.py
