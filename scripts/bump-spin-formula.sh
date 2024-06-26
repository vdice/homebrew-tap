#!/bin/bash
set -eoux pipefail

VERSION=$1
FORMULA=${2:-Formula/spin.rb}

# -i syntax differs between GNU and Mac sed; this usage is supported by both
SED_INPLACE='sed -i.bak'

# cleanup
trap 'rm checksums.txt **/*.bak' EXIT

usage() {
    echo "Usage: $0 <VERSION> [<FORMULA_PATH>]"
    echo "Updates the Spin Formula for the specified release version"
    echo "Example: $0 v3.0.0"
}

if [ $# -ne 1 ]; then
    usage
    exit 1
fi

# Ensure the version is prefixed with 'v'
if [[ $VERSION != v* ]]; then
    VERSION="v$VERSION"
fi

# Get the checksum file for the release
wget -qO checksums.txt "https://github.com/vdice/spin/releases/download/$VERSION/checksums-$VERSION.txt"

# Check if failed to download the checksum file
if [ $? -ne 0 ]; then
    echo "Checksum file not found for version $VERSION"
    exit 1
fi

# Remove the 'v' prefix from the version
ERSION="${VERSION:1}"
$SED_INPLACE -e "s/version \"[^\"]*\"/version \"$ERSION\"/" $FORMULA
# Update the sha256 checksums for each OS/Arch
while read -r line; do
    filename=$(echo "$line" | awk '{print $2}')
    sha256=$(echo "$line" | awk '{print $1}')
    os_arch=$(echo ${filename} | sed "s/spin-v${ERSION}-//g")
    if grep -q "$os_arch" $FORMULA; then
        $SED_INPLACE -E "/url \".*$os_arch\"/ { n; s/sha256 \"[^\"]*\"/sha256 \"$sha256\"/; }" $FORMULA
    fi
done < checksums.txt

echo "Formula updated to version $VERSION with new checksums."
