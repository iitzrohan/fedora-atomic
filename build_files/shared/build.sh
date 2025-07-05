#!/usr/bin/env bash

echo "::group:: Copy Files"

set -ouex pipefail

# Copy System Files onto root
rsync -rvK /ctx/sys_files/shared/ /
rsync -rvK /ctx/sys_files/"${SOURCE_IMAGE}"/ /
rsync -rvK /ctx/certs/ /tmp/certs/
rsync -rvK /ctx/scripts/ /tmp/scripts/

# make root's home
mkdir -p /var/roothome

# Install dnf5 if not installed
if ! rpm -q dnf5 >/dev/null; then
    rpm-ostree install dnf5 dnf5-plugins
fi

/ctx/build_files/base/02-install-copr-repos.sh

if [[ "$IMAGE_NAME" =~ "dx" ]]; then
    /ctx/build_files/dx/02-install-copr-repos.sh
fi

/ctx/build_files/base/03-install-kernel-akmods.sh

/ctx/build_files/base/04-override-install.sh

/ctx/build_files/base/05-packages.sh

if [[ "$IMAGE_NAME" =~ "dx" ]]; then
    /ctx/build_files/dx/05-packages.sh
fi

if [ "${BUILD_NVIDIA}" == "Y" ]; then
    AKMODNV_PATH=/tmp/akmods-nv-rpms /ctx/build_files/base/06-nvidia-install.sh
fi

/ctx/build_files/base/08-firmware.sh

/ctx/build_files/base/17-cleanup.sh

if [[ "$IMAGE_NAME" =~ "dx" ]]; then
    /ctx/build_files/dx/17-cleanup.sh
fi

/ctx/build_files/base/18-workarounds.sh

/ctx/build_files/base/19-initramfs.sh

/ctx/build_files/base/20-sign-kernel-modules.sh

# use CoreOS' generator for emergency/rescue boot
# see detail: https://github.com/ublue-os/main/issues/653
CSFG=/usr/lib/systemd/system-generators/coreos-sulogin-force-generator
curl -sSLo ${CSFG} https://raw.githubusercontent.com/coreos/fedora-coreos-config/refs/heads/stable/overlay.d/05core/usr/lib/systemd/system-generators/coreos-sulogin-force-generator
chmod +x ${CSFG}

## install packages direct from github
/ctx/build_files/shared/github-release-install.sh sigstore/cosign x86_64

echo "::group:: Cleanup"

/ctx/build_files/shared/clean-stage.sh

echo "::endgroup::"