#!/usr/bin/bash

set -eoux pipefail

KERNEL_VERSION="$(rpm -q --queryformat="%{evr}.%{arch}" kernel-core)"
SIGNING_KEY="/tmp/certs/signing_key.pem"
PUBLIC_CHAIN="/tmp/certs/public_key.crt"

# Verify certificates exist before proceeding
if [ ! -f "${SIGNING_KEY}" ] || [ ! -f "${PUBLIC_CHAIN}" ]; then
    echo "ERROR: Certificate files not found at ${SIGNING_KEY} or ${PUBLIC_CHAIN}"
    ls -la /tmp/certs || echo "Directory /tmp/certs does not exist"
    exit 1
fi

# Sign kernel modules
for module in $(find /usr/lib/modules/"${KERNEL_VERSION}"/extra/ -name "*.ko*"); do
    module_basename=${module:0:-3}
    module_suffix=${module: -3}
    if [[ "$module_suffix" == ".xz" ]]; then
        xz --decompress "$module"
        openssl cms -sign -signer "${SIGNING_KEY}" -binary -in "$module_basename" -outform DER -out "${module_basename}.cms" -nocerts -noattr -nosmimecap
        /usr/src/kernels/"${KERNEL_VERSION}"/scripts/sign-file -s "${module_basename}.cms" sha256 "${PUBLIC_CHAIN}" "${module_basename}"
        /tmp/scripts/sign-check.sh "${KERNEL_VERSION}" "${module_basename}" "${PUBLIC_CHAIN}"
        xz -C crc32 -f "${module_basename}"
        rm -f "${module_basename}.cms"
    elif [[ "$module_suffix" == ".gz" ]]; then
        gzip -d "$module"
        openssl cms -sign -signer "${SIGNING_KEY}" -binary -in "$module_basename" -outform DER -out "${module_basename}.cms" -nocerts -noattr -nosmimecap
        /usr/src/kernels/"${KERNEL_VERSION}"/scripts/sign-file -s "${module_basename}.cms" sha256 "${PUBLIC_CHAIN}" "${module_basename}"
        /tmp/scripts/sign-check.sh "${KERNEL_VERSION}" "${module_basename}" "${PUBLIC_CHAIN}"
        gzip -9f "${module_basename}"
        rm -f "${module_basename}.cms"
    else
        openssl cms -sign -signer "${SIGNING_KEY}" -binary -in "$module" -outform DER -out "${module}.cms" -nocerts -noattr -nosmimecap
        /usr/src/kernels/"${KERNEL_VERSION}"/scripts/sign-file -s "${module}.cms" sha256 "${PUBLIC_CHAIN}" "${module}"
        /tmp/scripts/sign-check.sh "${KERNEL_VERSION}" "${module}" "${PUBLIC_CHAIN}"
        rm -f "${module}.cms"
    fi
done