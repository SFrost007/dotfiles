#!/bin/sh
# Sets up common preferences for new macOS installs
# Great resources:
#     https://github.com/kevinSuttle/macOS-Defaults
#     http://mths.be/macos
#     https://raw.githubusercontent.com/nnja/new-computer/master/setup.sh
#     https://github.com/sobolevn/dotfiles/blob/master/macos
#     https://macos-defaults.com/

# Close PrefPanes to prevent them overwriting these settings
osascript -e 'tell application "System Preferences" to quit'


# Reveal folders hidden by default
chflags nohidden ~/Library
sudo chflags nohidden /Volumes

# Global preferences
defaults write com.apple.desktopservices DSDontWriteNetworkStores true # DS_Store files on networks
defaults write com.apple.LaunchServices LSQuarantine -bool false # Disable "Are you sure" on new apps
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true # Expanded Save dialog


# Keyboard preferences
# Setup MS keyboard, PC layout and modifiers manually
# Modifiers = Control: Command, Option: Control, Command: Option
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3 # Full UI tab-key access


# Trackpad preferences - several of these don't work since Catalina, and only set the UI state
# of the checkbox in System Preferences without actually changing the behaviour
defaults write com.apple.AppleMultitouchTrackpad ActuationStrength -int 0 # Silent clicking
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false # Disable "Natural" scrolling

# Finder preferences
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv" # List view
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf" # Search current folder
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder ShowRecentTags -boolean false
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write -g AppleShowAllExtensions -bool true
defaults write NSGlobalDomain NSToolbarTitleViewRolloverDelay -float 0.1
defaults write com.apple.finder QLEnableTextSelection -bool true # QuickLook selection
# Show proxy icons
defaults write com.apple.finder NSWindowSupportsAutomaticInlineTitle -bool false
# Set desktop to snap-to-grid mode
/usr/libexec/PlistBuddy -c \
  "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid"\
  ~/Library/Preferences/com.apple.finder.plist


# Dock preferences
defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.dock show-recents -bool FALSE
defaults write com.apple.dock tilesize -int 40 # Dock icon size
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock largesize -int 48
defaults write com.apple.dock mru-spaces -bool false # Don't reorder spaces
defaults write com.apple.dock orientation -string right
defaults write com.apple.dock autohide-time-modifier -float 0.25
defaults write com.apple.dock autohide-delay -float 0


# Restart apps to take effect
killall Dock Finder SystemUIServer
echo "'Unnatural' scrolling will only take effect after a reboot"


# Flags which used to work but no longer do (as of Big Sur). Would be good to
# find working alternatives to these..
#
# Self-explanatory settings:
#defaults write com.apple.menuextra.battery ShowPercent YES
#defaults write com.apple.finder ShowPathbar -bool true
#
# Tap-to-click.
# These tick the box in System Preferences but don't actually change the behaviour :(
#defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
#defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
#defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

