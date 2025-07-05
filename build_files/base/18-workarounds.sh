#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

## Pins and Overrides
## Use this section to pin packages in order to avoid regressions
# Remember to leave a note with rationale/link to issue for each pin!
#
# Example:
#if [ "$FEDORA_VERSION" -eq "41" ]; then
#    Workaround pkcs11-provider regression, see issue #1943
#    rpm-ostree override replace https://bodhi.fedoraproject.org/updates/FEDORA-2024-dd2e9fb225
#fi

# Enable getty on tty1 for image with no Display Manager
if [[ "$IMAGE_NAME" =~ "base" ]]; then
    systemctl enable getty@tty1
fi

# Workaround: Rename just's CN readme to README.zh-cn.md
mv '/usr/share/doc/just/README.中文.md' '/usr/share/doc/just/README.zh-cn.md'

# Fix cjk fonts
ln -s "/usr/share/fonts/google-noto-sans-cjk-fonts" "/usr/share/fonts/noto-cjk"

# Hide Desktop Files. Hidden removes mime associations
for file in htop nvtop; do
    if [[ -f "/usr/share/applications/$file.desktop" ]]; then
        sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nHidden=true@g' /usr/share/applications/"$file".desktop
    fi
done

# Prevent partial QT upgrades that may break SDDM/KWin
if [[ "$IMAGE_NAME" =~ "kinoite" ]]; then
    dnf5 versionlock add "qt6-*"
fi

echo "::endgroup::"
