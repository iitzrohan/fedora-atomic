#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

dnf5 -y install niri fcft gtk-layer-shell libmpdclient nanosvg xcb-util-cursor --setopt=install_weak_deps=False

echo "::endgroup::"
