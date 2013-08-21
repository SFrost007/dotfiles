#!/usr/bin/env bash

# Script to set as many OSX configuration options as possible.
# Several of these configurations only take effect after a reboot.
# Cribbed together from mathiasbynens, 


# TODO:
#  - Change Finder sidebar items
#  - Set Finder to list mode as default
#  - Power options
#  - Dock to left
#  - Dock to use grid stacks as default
#  - Dock minimise into icon
#  - Dock magnification
#  - Set startup apps?


# Hostname options, if required - should be different for each machine so commented
#sudo scutil --set ComputerName "SimonsMBP"
#sudo scutil --set HostName "SimonsMBP"
#sudo scutil --set LocalHostName "SimonsMBP"
#sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "SimonsMBP"




###############################################################################
# Input hardware
###############################################################################

# Trackpad: Correct scroll direction
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Trackpad: enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Trackpad: Set mouse speed
defaults write NSGlobalDomain com.apple.mouse.scaling -float 3
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 3

# Keyboard: Enable key repeat rather than input menu
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Keyboard: Enable tab-focusing in dialogs
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3




###############################################################################
# Finder
###############################################################################

# Make sidebar icons smaller
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1

# Disable the "Are you sure you want to open this application?" dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Show connected servers and removable media on desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Show filename extensions, and disable warning when changing extension
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Show status bar and path bar
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true

# Allow text selection in QuickLook
defaults write com.apple.finder QLEnableTextSelection -bool true

# Search in the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Avoid creating .DS_Store files on network stores
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Skip verifying disk images
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

# Automatically open a new window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# Set default view mode to grid for desktop and list elsewhere
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
#/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy list" ~/Library/Preferences/com.apple.finder.plist
#defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Show the ~/Library folder
chflags nohidden ~/Library




###############################################################################
# Dock
###############################################################################
echo 'Setting Dock preferences'

# Make the dock icons a bit smaller
defaults write com.apple.dock tilesize -int 48

# Set highlight when hovering over stack items
defaults write com.apple.dock mouse-over-hilite-stack -bool true

# Ensure running app indicators are visible
defaults write com.apple.dock show-process-indicators -bool true

# Clear out all standard dock icons, and add a few spacer items
# Destructive if script is run again, so move behind prompt
read -p 'Reset Dock items? ' -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
	defaults write com.apple.dock persistent-apps -array
	defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
	defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
	defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
fi




###############################################################################
# Mission Control/Expose/Hot Corners
###############################################################################

# Disable Dashboard and remove from Spaces
defaults write com.apple.dashboard mcx-disabled -bool true
defaults write com.apple.dock dashboard-in-overlay -bool true

# Don’t automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# Set up hot corners
defaults write com.apple.dock wvous-tl-corner -int 2
defaults write com.apple.dock wvous-tr-corner -int 4
defaults write com.apple.dock wvous-bl-corner -int 10
defaults write com.apple.dock wvous-br-corner -int 5




###############################################################################
# Misc apps
###############################################################################

# TextEdit: Default to plain text
#defaults write com.apple.TextEdit RichText -int 0

# TextEdit: Hide the ruler as default
#defaults write com.apple.TextEdit ShowRuler 0

# DiskUtility: Show debug menu and advanced options
defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
defaults write com.apple.DiskUtility advanced-image-options -bool true

# Safari: Enable debug menu and developer options
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

# TimeMachine: Prevent prompting for use of new drives for backup
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# App Store: Enable debug menus
defaults write com.apple.appstore WebKitDeveloperExtras -bool true
defaults write com.apple.appstore ShowDebugMenu -bool true

# Chrome: Allow extensions from Github and Userscripts
defaults write com.google.Chrome ExtensionInstallSources -array "https://*.github.com/*" "http://userscripts.org/*"

# Transmission: Trash .torrent file when adding, and hide warnings
defaults write org.m0k.transmission DeleteOriginalTorrent -bool true
defaults write org.m0k.transmission WarningDonate -bool false
defaults write org.m0k.transmission WarningLegal -bool false



