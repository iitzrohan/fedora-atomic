#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

systemctl enable docker.socket

# Remove coprs
dnf5 -y copr remove gmaglione/podman-bootc
dnf5 -y copr remove atim/ubuntu-fonts
dnf5 -y copr remove medzik/jetbrains
dnf5 -y copr remove che/nerd-fonts

# Remove java repository
dnf5 config-manager setopt adoptium-temurin-java-repository.enabled=0
dnf5 -y remove adoptium-temurin-java-repository

# Disable vscode and docker-ce repos
dnf5 config-manager setopt docker-ce-stable.enabled=0
dnf5 config-manager setopt code.enabled=0
dnf5 config-manager setopt tailscale-stable.enabled=0

echo "::endgroup::"