# Sublime setup instructions

Manually:
* Set licence key
* Install package control: https://packagecontrol.io/installation
* Link dotfiles:
```
PACKAGES_DIR="~/Library/Application Support/Sublime Text 3/Packages"
mkdir -p "${PACKAGES_DIR}"
ln -s "~/.dotfiles/sublime/" "${PACKAGES_DIR}/User"
```