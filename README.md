<p align="center">
<img src="https://i.imgur.com/fEyo7tU.png">
</p>

This is my collection of dotfiles, configs, scripts, fonts and everything that
makes development nice on the machines I use. This is primarily intended to work
on macOS; many of the required utils are not yet installed on Ubuntu/Raspbian.
Support for WSL would be nice at some point too..

### Automatic install

The easiest install method is to execute the install script directly. This will
ensure pre-requisites are met, clone the repo to `~/.dotfiles` and run the
install script.

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/SFrost007/dotfiles/master/install.sh)"
```
Or on Ubuntu, where `curl` doesn't exist out-of-box:
```bash
bash -c "$(wget -qO - https://raw.githubusercontent.com/SFrost007/dotfiles/master/install.sh)"
```


### Manual install
1. Install git, with either `xcode-select --install` or `sudo apt install git`
2. Clone the repository wherever desired
3. Set the `DOTFILES_DIR` environment variable (if not `$HOME/.dotfiles`)
4. Run `install.sh`


# Functional overview
* Mainly built for zsh. Config will auto-load any .zsh files in the zsh folder
* Custom scripts/binaries live in the `bin` folder
* TODO warnings remain in `install.sh` for missing functionality

# TODO
* Git pull hooks to automatically re-run update scripts
* Setup module to generate SSH key and replace git origin with ssh version
* Dynamic iTerm profiles ([See here](https://github.com/juliantellez/up))
* More extensive macOS defaults
* Support for Ubuntu/Raspbian/Alpine

### Thanks to:
* [Zach Holman](http://github.com/holman/dotfiles) for the original inspiration
* [Mina Markham](https://github.com/minamarkham/formation) for install script bits
* Various people/sources mentioned in script headers in `bin`
* Anyone else who I stole useful things from and forgot about (please shout!)
