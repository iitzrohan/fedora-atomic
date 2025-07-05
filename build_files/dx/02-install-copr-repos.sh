#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

dnf5 -y copr enable atim/ubuntu-fonts
dnf5 -y copr enable gmaglione/podman-bootc
dnf5 -y copr enable medzik/jetbrains
dnf5 -y install adoptium-temurin-java-repository

dnf5 config-manager setopt adoptium-temurin-java-repository.enabled=1
dnf5 config-manager setopt docker-ce-stable.enabled=1
dnf5 config-manager setopt code.enabled=1
dnf5 config-manager setopt tailscale-stable.enabled=1

echo "::endgroup::"
