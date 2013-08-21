#!/bin/bash

# New machine setup script. Installs:
#  - Homebrew
#  - TextMate
#  - wget
#  - cloc
#  - tree
#  - TODO: Adium, RVM & Gems
#  - TODO: Generate SSH keys & upload to appropriate servers?
#  - TODO: Figure out RVM stuff
#  - TODO: Configure Apache/PHP?
#  - TODO: Fluid? DiffMerge? Handbrake? iExplorer? PhoneClean? RestClient? ScreenFlow? Sencha/Cordova tools? Spotify? VirtualBox? VLC?
#  - TODO: Developer Certs
#  - TODO: Create script for FullScreenIfying Outlook


# Call external script to set OSX options
sh ./OSX_Config.sh
# TODO: sh ./SetupDotfiles.sh

# Set up Homebrew
ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"
brew doctor

# Install commonly used brew recipes/gemspecs
brew install cloc
brew install tree
brew install wget

# TODO: Re-check Gem options once RVM is sussed out
#gem install compass
#gem install pygmentize



echo '' && echo 'Fetching latest TextMate release...'
wget https://api.textmate.org/downloads/release -O textmate.tbz
if [ -f textmate.tbz ];
then
	tar -xjf textmate.tbz && rm textmate.tbz
	mv TextMate.app/ /Applications
	cp /Applications/TextMate.app/Contents/Resources/mate /usr/local/bin
	# TODO: Add HTML snippet
else
	echo ' ***** Failed to download TextMate ***** '
fi



# TODO: Install MySql
	#brew install mysql #TODO: Do we want this? May need more setup
	#setup daemon
	#mkdir -p ~/Library/LaunchAgents && cp /usr/local/Cellar/mysql/5.5.20/homebrew.mxcl.mysql.plist ~/Library/LaunchAgents/ && launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
	#Set up databases to run as your user account
	#unset TMPDIR && mysql_install_db --verbose --user=`whoami` --basedir="$(brew --prefix mysql)" --datadir=/usr/local/var/mysql --tmpdir=/tmp
	#start mysql
	#mysql.server start
	#secure mysql
	#/usr/local/Cellar/mysql/5.5.20/bin/mysql_secure_installation



echo '' && echo 'Fetching latest iTerm2 nightly release...'
wget http://www.iterm2.com/nightly/latest -O iTerm.zip
if [ -f iTerm.zip];
then
	unzip -q iTerm.zip && rm iTerm.zip
	mv iTerm.app /Applications
	# TODO: Use plistbuddy to set winshade options and hide from Dock
else
	echo ' ***** Failed to download iTerm ***** '
fi



# TODO: Download/install Adium



# Clone command line tools
mkdir -p ~/Code/TerminalUtils && pushd ~/Code/TerminalUtils
git clone https://github.com/robbyrussell/oh-my-zsh.git
git clone https://github.com/Lokaltog/powerline.git
git clone https://github.com/Lokaltog/powerline-fonts.git
git clone git://github.com/altercation/solarized.git
# TODO: open solarized.terminal, sleep 1, then set as default with:
# defaults write com.apple.terminal "Default Window Settings" -string "Mathias"
# defaults write com.apple.terminal "Startup Window Settings" -string "Mathias"
# TODO: Run setup scripts for above, including installing fonts
# curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh
# curl -o ~/.oh-my-zsh/themes/powerline.zsh-theme https://raw.github.com/jeremyFreeAgent/oh-my-zsh-powerline-theme/master/powerline.zsh-theme
popd

