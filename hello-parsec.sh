#!/usr/bin/env sh

# Copyright 2022 Contributors to the Parsec project.
# SPDX-License-Identifier: Apache-2.0

ping_parsec() {
    echo "Checking for availability of the Parsec service on your system... "
    $PARSEC_TOOL ping > /dev/null
}

PARSEC_SERVICE_ENDPOINT="${PARSEC_SERVICE_ENDPOINT:-unix:/run/parsec/parsec.sock}"
PARSEC_TOOL="${PARSEC_TOOL:-$(which parsec-tool)}"
KEY_NAME=HelloParsecDemoKey
export RUST_LOG="${RUST_LOG:-error}"

if ! ping_parsec; then
    echo "Could not connect to a working Parsec service on this system."
    echo "This could mean:"
    echo "    [1] - The Parsec service has not been installed or is not running."
    echo "    [2] - Parsec's domain socket service endpoint is not visible to this container because it has not been mounted."
    exit 1;
fi

# Getting to here means that we have a working Parsec service, so display the banner and run the demo.
cat ./parsec_banner.txt

echo "Parsec back-end providers enabled (the topmost entry is the default):-"
$PARSEC_TOOL list-providers 2>/dev/null | grep "^ID:" | grep -v "0x00"

echo "Running RSA encryption demo. Three 'Hello Parsec' messages should appear below..."
echo

$PARSEC_TOOL create-rsa-key --key-name $KEY_NAME
$PARSEC_TOOL encrypt --key-name $KEY_NAME "Hello Parsec from Rust!" | $HELLO_DECRYPT_RUST
$PARSEC_TOOL encrypt --key-name $KEY_NAME "Hello Parsec from Go!" | $HELLO_DECRYPT_GO
$PARSEC_TOOL encrypt --key-name $KEY_NAME "Hello Parsec from the Parsec CLI Tool!" > ./encrypt.out
$PARSEC_TOOL decrypt --key-name $KEY_NAME $(cat ./encrypt.out)
$PARSEC_TOOL delete-key --key-name $KEY_NAME

echo
echo "Finished!"
