#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

curl --retry 3 -Lo /tmp/minikube-latest.x86_64.rpm "https://storage.googleapis.com/minikube/releases/latest/minikube-latest.x86_64.rpm"
dnf5 -y install /tmp/minikube-latest.x86_64.rpm

# GitHub Monaspace Font
DOWNLOAD_URL=$(curl --retry 3 https://api.github.com/repos/githubnext/monaspace/releases/latest | jq -r '.assets[] | select(.name| test(".*.zip$")).browser_download_url')
curl --retry 3 -Lo /tmp/monaspace-font.zip "$DOWNLOAD_URL"

unzip -qo /tmp/monaspace-font.zip -d /tmp/monaspace-font
mkdir -p /usr/share/fonts/monaspace
mv /tmp/monaspace-font/monaspace-v*/fonts/variable/* /usr/share/fonts/monaspace/
rm -rf /tmp/monaspace-font*

fc-cache -f /usr/share/fonts/monaspace
fc-cache --system-only --really-force --verbose

# ls-iommu helper tool for listing devices in iommu groups (PCI Passthrough)
DOWNLOAD_URL=$(curl https://api.github.com/repos/HikariKnight/ls-iommu/releases/latest | jq -r '.assets[] | select(.name| test(".*x86_64.tar.gz$")).browser_download_url')
curl --retry 3 -Lo /tmp/ls-iommu.tar.gz "$DOWNLOAD_URL"
mkdir /tmp/ls-iommu
tar --no-same-owner --no-same-permissions --no-overwrite-dir -xvzf /tmp/ls-iommu.tar.gz -C /tmp/ls-iommu
mv /tmp/ls-iommu/ls-iommu /usr/bin/
rm -rf /tmp/ls-iommu*

# CNI plugin for Podman
DOWNLOAD_URL=$(curl --retry 3 https://api.github.com/repos/containernetworking/plugins/releases/latest | jq -r '.assets[] | select(.name| test("cni-plugins-linux-amd64-.*\\.tgz$")).browser_download_url')
curl --retry 3 -Lo /tmp/cni-plugins.tgz "$DOWNLOAD_URL"
mkdir /tmp/cni-plugins
tar --no-same-owner --no-same-permissions --no-overwrite-dir -xvzf /tmp/cni-plugins.tgz -C /tmp/cni-plugins
mkdir -p /usr/libexec/cni
mv /tmp/cni-plugins/* /usr/libexec/cni/
rm -rf /tmp/cni-plugins*

echo "::endgroup::"
