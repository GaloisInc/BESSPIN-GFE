#! /bin/bash

# This script is meant to be run from inside of the `install`
# directory, not from a relative path.

# Check that this script is being run from within install, else fail:
if [ $(pwd | tail -c 8) != "install" ]; then
  echo "Please run this script from within the install directory. Exiting"
  exit 1
fi

# Linux and OS X ?
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     
	SED=sed
	MD5=md5sum
	;;
   
    Darwin*)    
	SED=gsed
	MD5='md5 -r'
	;;
	    
   *)
	echo "Unknown machine. "; exit 1;;
esac

# Hash Test. Assumes riscv-gnu-toolchains.tar.gz will be in cd if it is installed
if [ -f riscv-gnu-toolchains.tar.gz ]; then
	val1=`$MD5 riscv-gnu-toolchains.tar.gz | awk '{print $1}'`
	
	# https://drive.google.com/a/galois.com/file/d/1r6Oh5e13DInJ33_KQSbQ5YSmbZCGhX26/view?usp=sharing
	fileid='1r6Oh5e13DInJ33_KQSbQ5YSmbZCGhX26'
	filename='riscv-toolchains-hash.txt'
	
	echo "Downloading Hash File..."

	wget -O $filename 'https://docs.google.com/uc?export=download&id='$fileid
	
	if [ "$?" -ne 0 ]; then
		echo "Failed to Download Hash File. Quitting."
		exit 1
	fi

	val2=`cat riscv-toolchains-hash.txt | tr -d '\n'`

	# convert to values that bash can compare...
	tmpval="Z${val1}" ; val1="${tmpval}"; tmpval="Z${val2}"; val2="${tmpval}"
	
	rm riscv-toolchains-hash.txt

	if [ "$val1" = "$val2" ]; then
		echo "Server version has same hash as local version."
		exit 0
	else
		echo "Server has a new version. Downloading now."
		rm riscv-gnu-toolchains.tar.gz
	fi
fi 

# Google Drive download adapted from
# https://www.matthuisman.nz/2019/01/download-google-drive-files-wget-curl.html
fileid='1aw2VKZG05-Pa2q57T4Z7ffJG_qe9-h2I'
filename='riscv-gnu-toolchains.tar.gz'

tmp_file="$filename.$$.file"
tmp_cookies="$filename.$$.cookies"
tmp_headers="$filename.$$.headers"

url='https://docs.google.com/uc?export=download&id='$fileid

echo "Downloading confirmation cookie..."
wget --save-cookies "$tmp_cookies" -q -S -O - $url 2> "$tmp_headers" 1> "$tmp_file"
if [[ ! $(find "$tmp_file" -type f -size +10000c 2>/dev/null) ]]; then
   confirm=$(cat "$tmp_file" | "$SED" -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1/p')
fi
if [ ! -z "$confirm" ]; then
   url='https://docs.google.com/uc?export=download&id='$fileid'&confirm='$confirm
   echo "Downloading file:" $url
   wget --load-cookies "$tmp_cookies" -q -S -O - $url 2> "$tmp_headers" 1> "$tmp_file"
fi

rm -f "$filename"
mv "$tmp_file" "$filename"
rm -f "$tmp_cookies" "$tmp_headers"
echo "Saved: $filename"

# Unpack into /opt/riscv/ -- not automated here
exit 0
