# Set up oh-my-zsh
curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh

# Download and install Powerline for OMZ
curl -o ~/.oh-my-zsh/themes/powerline.zsh-theme https://raw.github.com/jeremyFreeAgent/oh-my-zsh-powerline-theme/master/powerline.zsh-theme

# Set up Homebrew
ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"

# Install commonly used brew recipes/gemspecs
brew install wget
brew install cloc
gem install pygmentize

