#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

# mitigate upstream packaging bug: https://bugzilla.redhat.com/show_bug.cgi?id=2332429
# swap the incorrectly installed OpenCL-ICD-Loader for ocl-icd, the expected package
dnf5 -y swap --repo='fedora' \
    OpenCL-ICD-Loader ocl-icd

# Install ublue-os pacakges, fedora archives,and zstd
dnf5 -y install \
    ublue-os-just \
    ublue-os-luks \
    ublue-os-udev-rules \
    /tmp/akmods-rpms/*.rpm \
    fedora-repos-archive \
    zstd

# use override to replace mesa and others with less crippled versions
OVERRIDES=(
    "libva"
    "intel-gmmlib"
    "intel-vpl-gpu-rt"
    "intel-mediasdk"
    "libva-intel-media-driver"
    "mesa-dri-drivers"
    "mesa-filesystem"
    "mesa-libEGL"
    "mesa-libGL"
    "mesa-libgbm"
    "mesa-va-drivers"
    "mesa-vulkan-drivers"
)

dnf5 distro-sync -y --repo='fedora-multimedia' "${OVERRIDES[@]}"
dnf5 versionlock add "${OVERRIDES[@]}"

echo "::endgroup::"