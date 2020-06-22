#!/bin/zsh

export ANDROID_HOME="$HOME/Library/Android/sdk"
addPathDir $ANDROID_HOME/platform-tools
addPathDir $ANDROID_HOME/cmdline-tools/latest
addPathDir $ANDROID_HOME/emulator
