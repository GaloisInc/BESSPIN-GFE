#! /bin/bash

# Google Drive download adapted from
# https://www.matthuisman.nz/2019/01/download-google-drive-files-wget-curl.html
fileid='1aw2VKZG05-Pa2q57T4Z7ffJG_qe9-h2I'
filename='riscv-gnu-toolchains.tar.gz'

tmp_file="$filename.$$.file"
tmp_cookies="$filename.$$.cookies"
tmp_headers="$filename.$$.headers"

url='https://docs.google.com/uc?export=download&id='$fileid

echo Downloading confirmation cookie...
wget --save-cookies "$tmp_cookies" -q -S -O - $url 2> "$tmp_headers" 1> "$tmp_file"
if [[ ! $(find "$tmp_file" -type f -size +10000c 2>/dev/null) ]]; then
   confirm=$(cat "$tmp_file" | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1/p')
fi
if [ ! -z "$confirm" ]; then
   url='https://docs.google.com/uc?export=download&id='$fileid'&confirm='$confirm
   echo Downloading file: $url
   wget --load-cookies "$tmp_cookies" -q -S -O - $url 2> "$tmp_headers" 1> "$tmp_file"
fi

mv "$tmp_file" "install/$filename"
rm -f "$tmp_cookies" "$tmp_headers"
echo Saved: "install/$filename"

# Unpack into /opt/riscv/ -- not automated here
# tar -C /opt -xf "install/$filename"
