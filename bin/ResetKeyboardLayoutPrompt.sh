#!/bin/sh
# Useful to trigger the "unknown keyboard layout" prompt on login if macOS
# slips into thinking the wrong layout is active.

sudo rm /Library/Preferences/com.apple.keyboardtype.plist
echo "Preference deleted, now reboot"
