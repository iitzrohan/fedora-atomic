#!/usr/bin/bash

set -ouex pipefail

# Enable getty on tty1 for image with no Display Manager
if [[ "$IMAGE_NAME" =~ "base" ]]; then
    systemctl enable getty@tty1
fi

# Workaround: Rename just's CN readme to README.zh-cn.md
mv '/usr/share/doc/just/README.中文.md' '/usr/share/doc/just/README.zh-cn.md'

# Remove dnf5 versionlocks
dnf5 versionlock clear

# Enable Update Timers
systemctl enable rpm-ostreed-automatic.timer
systemctl enable flatpak-system-update.timer
systemctl enable tailscaled.service
if rpm -q docker-ce >/dev/null; then
    systemctl enable docker.socket
fi
systemctl enable podman.socket
systemctl --global enable flatpak-user-update.timer

# Configure staged updates for rpm-ostree
cp /usr/share/ublue-os/update-services/etc/rpm-ostreed.conf /etc/rpm-ostreed.conf

# Fix cjk fonts
ln -s "/usr/share/fonts/google-noto-sans-cjk-fonts" "/usr/share/fonts/noto-cjk"

# Remove coprs
dnf5 -y copr remove ublue-os/staging
dnf5 -y copr remove ublue-os/packages
dnf5 -y copr remove kylegospo/oversteer
dnf5 -y copr remove gmaglione/podman-bootc
dnf5 -y copr remove atim/ubuntu-fonts
dnf5 -y copr remove medzik/jetbrains


# Remove java repository
dnf5 config-manager setopt adoptium-temurin-java-repository.enabled=0
dnf5 -y remove adoptium-temurin-java-repository

# Disable vscode and docker-ce repos
dnf5 config-manager setopt docker-ce-stable.enabled=0
dnf5 config-manager setopt code.enabled=0
dnf5 config-manager setopt tailscale-stable.enabled=0

# Disable Negativo17 Fedora Multimedia
# This needs to be a whole organiztion change
# dnf5 config-manager setopt fedora-multimedia.enabled=0

# Cleanup
# Remove tmp files and everything in dirs that make bootc unhappy
rm -rf /tmp/* || true
rm -rf /usr/etc
rm -rf /boot && mkdir /boot
# Preserve cache mounts
find /var/* -maxdepth 0 -type d \! -name cache \! -name log -exec rm -rf {} \;
find /var/cache/* -maxdepth 0 -type d \! -name libdnf5 -exec rm -rf {} \;

# Make sure /var/tmp is properly created
mkdir -p /var/tmp
chmod -R 1777 /var/tmp

# Check to make sure important packages are present
/ctx/check-build.sh

# ostree checks
ostree container commit
