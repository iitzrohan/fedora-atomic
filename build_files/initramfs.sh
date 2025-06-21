#!/usr/bin/bash

set -eoux pipefail

KERNEL_VERSION="$(rpm -q --queryformat="%{evr}.%{arch}" kernel-core)"

# Install signing tools
dnf5 -y install sbsigntools openssl

# Sign kernel
PUBKEY_PATH="/tmp/certs/public_key.der"
PRIVKEY_PATH="/tmp/certs/private_key.priv"
CRT_PATH="/tmp/certs/public_key.crt"

STRIP="false"

if [[ "${STRIP}" == "true" ]]; then
    EXISTING_SIGNATURES="$(sbverify --list /usr/lib/modules/$KERNEL_VERSION/vmlinuz | grep '^signature \([0-9]\+\)$' | sed 's/^signature \([0-9]\+\)$/\1/')" || true
    if [[ -n $EXISTING_SIGNATURES ]]; then
        for SIGNUM in $EXISTING_SIGNATURES
        do
            echo "Found existing signature at signum $SIGNUM, removing..."
            sbattach --remove /usr/lib/modules/$KERNEL_VERSION/vmlinuz
        done
    fi
fi

sbsign --cert $CRT_PATH --key $PRIVKEY_PATH /usr/lib/modules/$KERNEL_VERSION/vmlinuz --output /usr/lib/modules/$KERNEL_VERSION/vmlinuz
sbverify --list /usr/lib/modules/$KERNEL_VERSION/vmlinuz

# Ensure Initramfs is generated
export DRACUT_NO_XATTR=1
/usr/bin/dracut --no-hostonly --kver "${KERNEL_VERSION}" --reproducible -v --add ostree -f "/lib/modules/${KERNEL_VERSION}/initramfs.img"
chmod 0600 "/lib/modules/${KERNEL_VERSION}/initramfs.img"
