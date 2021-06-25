#!/bin/sh

export SDKS_DIR="${HOME}/Code/SDKs/"
mkdir -p "${SDKS_DIR}"
pushd "${SDKS_DIR}"

git clone https://github.com/flutter/flutter.git

FLUTTER_BIN="${SDKS_DIR}/flutter/bin/flutter"
#"${FLUTTER_BIN}" channel dev # Only necessary if not checking out dev branch above
"${FLUTTER_BIN}" upgrade
"${FLUTTER_BIN}" config --enable-macos-desktop
"${FLUTTER_BIN}" doctor

echo "Done! Reload ZSH config to update path"
