#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

# Pano clipboard-manager
DOWNLOAD_URL=$(curl --retry 3 https://api.github.com/repos/oae/gnome-shell-pano/releases | jq -r '.[0].assets[0].browser_download_url')
curl --retry 3 -Lo /tmp/pano@elhan.io.zip "$DOWNLOAD_URL"
mkdir -p /tmp/pano@elhan.io
unzip /tmp/pano@elhan.io.zip -d /tmp/pano@elhan.io
cp /tmp/pano@elhan.io/schemas/org.gnome.shell.extensions.pano.gschema.xml /usr/share/glib-2.0/schemas/
mv /tmp/pano@elhan.io /usr/share/gnome-shell/extensions/
rm -rf /tmp/pano@elhan.io*

# Alphabetical app grid
DOWNLOAD_URL=$(curl --retry 3 https://api.github.com/repos/stuarthayhurst/alphabetical-grid-extension/releases | jq -r '.[0].assets[0].browser_download_url')
curl --retry 3 -Lo /tmp/AlphabeticalAppGrid@stuarthayhurst.shell-extension.zip "$DOWNLOAD_URL"
mkdir -p /tmp/AlphabeticalAppGrid@stuarthayhurst
unzip /tmp/AlphabeticalAppGrid@stuarthayhurst.shell-extension.zip -d /tmp/AlphabeticalAppGrid@stuarthayhurst
glib-compile-schemas /tmp/AlphabeticalAppGrid@stuarthayhurst/schemas
cp /tmp/AlphabeticalAppGrid@stuarthayhurst/schemas/org.gnome.shell.extensions.AlphabeticalAppGrid.gschema.xml /usr/share/glib-2.0/schemas/
mv /tmp/AlphabeticalAppGrid@stuarthayhurst /usr/share/gnome-shell/extensions/
rm -rf /tmp/AlphabeticalAppGrid@stuarthayhurst*

# Hot edge
DOWNLOAD_URL="https://github.com/jdoda/hotedge/archive/refs/heads/main.zip"
curl --retry 3 -Lo /tmp/hotedge@jonathan.jdoda.ca.zip "$DOWNLOAD_URL"
mkdir -p /tmp/hotedge@jonathan.jdoda.ca
unzip /tmp/hotedge@jonathan.jdoda.ca.zip -d /tmp/hotedge@jonathan.jdoda.ca
mv /tmp/hotedge@jonathan.jdoda.ca/hotedge-main/* /tmp/hotedge@jonathan.jdoda.ca/
rm -rf /tmp/hotedge@jonathan.jdoda.ca/hotedge-main
glib-compile-schemas /tmp/hotedge@jonathan.jdoda.ca/schemas
cp /tmp/hotedge@jonathan.jdoda.ca/schemas/org.gnome.shell.extensions.hotedge.gschema.xml /usr/share/glib-2.0/schemas/
mv /tmp/hotedge@jonathan.jdoda.ca /usr/share/gnome-shell/extensions/
rm -rf /tmp/hotedge@jonathan.jdoda.ca*

# Automatic wallpaper changing by month
HARDCODED_RPM_MONTH="12"
sed -i "/picture-uri/ s/${HARDCODED_RPM_MONTH}/$(date +%m)/" "/usr/share/glib-2.0/schemas/zz0-bluefin-modifications.gschema.override"
glib-compile-schemas /usr/share/glib-2.0/schemas

# Add Mutter experimental-features
MUTTER_EXP_FEATS="'scale-monitor-framebuffer', 'xwayland-native-scaling'"
if [[ "${BUILD_NVIDIA}" == "Y" ]]; then
    MUTTER_EXP_FEATS="'kms-modifiers', ${MUTTER_EXP_FEATS}"
fi
tee /usr/share/glib-2.0/schemas/zz1-bluefin-modifications-mutter-exp-feats.gschema.override << EOF
[org.gnome.mutter]
experimental-features=[${MUTTER_EXP_FEATS}]
EOF

# Test bluefin gschema override for errors. If there are no errors, proceed with compiling bluefin gschema, which includes setting overrides.
mkdir -p /tmp/bluefin-schema-test
find /usr/share/glib-2.0/schemas/ -type f ! -name "*.gschema.override" -exec cp {} /tmp/bluefin-schema-test/ \;
cp /usr/share/glib-2.0/schemas/zz0-bluefin-modifications.gschema.override /tmp/bluefin-schema-test/
cp /usr/share/glib-2.0/schemas/zz1-bluefin-modifications-mutter-exp-feats.gschema.override /tmp/bluefin-schema-test/
echo "Running error test for bluefin gschema override. Aborting if failed."
# We should ideally refactor this to handle multiple GNOME version schemas better
glib-compile-schemas --strict /tmp/bluefin-schema-test
echo "Compiling gschema to include bluefin setting overrides"
glib-compile-schemas /usr/share/glib-2.0/schemas &>/dev/null

echo "::endgroup::"
