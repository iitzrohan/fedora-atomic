#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

# Remove dnf5 versionlocks
dnf5 versionlock clear

# Enable Update Timers
systemctl enable uupd.timer
systemctl enable tailscaled.service
systemctl enable podman.socket

# Remove coprs
dnf5 -y copr remove ublue-os/staging
dnf5 -y copr remove ublue-os/packages
dnf5 -y copr remove kylegospo/oversteer

# Disable Negativo17 Fedora Multimedia
# This needs to be a whole organiztion change
# dnf5 config-manager setopt fedora-multimedia.enabled=0

echo "::endgroup::"