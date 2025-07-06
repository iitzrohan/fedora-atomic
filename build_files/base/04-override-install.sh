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

# Starship Shell Prompt
curl --retry 3 -Lo /tmp/starship.tar.gz "https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-gnu.tar.gz"
tar -xzf /tmp/starship.tar.gz -C /tmp
install -c -m 0755 /tmp/starship /usr/bin
# shellcheck disable=SC2016
echo "alias cat='bat --paging=never --style=plain'" >> /etc/bashrc
echo 'alias ls="lsd --date=relative --group-dirs=first --size=short"' >> /etc/bashrc
echo 'eval "$(starship init bash)"' >> /etc/bashrc
echo 'eval "$(zoxide init --cmd cd bash)"' >> /etc/bashrc

# Install Zellij Terminal Multiplexer
PACKAGE="zellij-x86_64-unknown-linux-musl.tar.gz"
DOWNLOAD_URL=$(curl --retry 3 https://api.github.com/repos/zellij-org/zellij/releases | jq --arg pkg "$PACKAGE" -r '.[0].assets[] | select(.name==$pkg) | .browser_download_url')
curl --retry 3 -Lo /tmp/$PACKAGE "$DOWNLOAD_URL"
mkdir -p /tmp/zellij
tar --no-same-owner --no-same-permissions --no-overwrite-dir -xvzf /tmp/$PACKAGE -C /tmp/zellij
mv /tmp/zellij/zellij /usr/bin/
rm -rf /tmp/zellij*

# Register Fonts
fc-cache -f /usr/share/fonts/ubuntu
fc-cache -f /usr/share/fonts/inter

echo "::endgroup::"