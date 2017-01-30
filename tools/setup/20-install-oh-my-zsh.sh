#!/bin/bash

# Install Oh-my-zsh and clone any custom plugins/themes
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k

# Install custom fonts required for Powerline
cp -r ../fonts/* ~/Library/Fonts

# Switch to zsh as the shell
chsh -s /bin/zsh
