# Sublime setup instructions

Manually:
* Set licence key
* Install package control: https://packagecontrol.io/installation
* Link dotfiles:
```
TARGET_DIR="~/Library/Application Support/Sublime Text 3/Packages/User"
mkdir -p "${TARGET_DIR}"
ln -s "~/.dotfiles/sublime/Package Control.sublime-settings" "${TARGET_DIR}"
ln -s "~/.dotfiles/sublime/Preferences.sublime-settings" "${TARGET_DIR}"
```