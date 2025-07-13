#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

dnf5 -y copr enable ryanabx/cosmic-epoch

dnf5 config-manager setopt copr:copr.fedorainfracloud.org:ryanabx:cosmic-epoch.priority=90

dnf5 -y update cosmic*

dnf5 -y copr remove ryanabx/cosmic-epoch

dnf5 -y copr enable yalter/niri-git 

# Set higher priority
dnf5 config-manager setopt copr:copr.fedorainfracloud.org:yalter:niri-git.priority=90

dnf5 -y install niri fcft gtk-layer-shell libmpdclient nanosvg xcb-util-cursor --setopt=install_weak_deps=False

dnf5 -y copr remove yalter/niri-git 

echo "::endgroup::"
