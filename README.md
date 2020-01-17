# Simon's dotfiles

This is my collection of dotfiles, configs, scripts, fonts and everything that
makes development nice on the machines I use. This is intended to work on:
* macOS (High Sierra)
* Ubuntu (16.04)
* Windows (under WSL)
* Raspbian (Jessie x86, Stretch ARM)

### Automatic install

The easiest install method is to execute the install script directly. This will
ensure pre-requisites are met, clone the repo to `~/.dotfiles` and run the
install script.

```bash
bash -c "$(curl -fsSL https://git.io/JvTkt)"
```
Or on Ubuntu, where `curl` doesn't exist out-of-box:
```bash
bash -c "$(wget -qO - https://git.io/JvTkt)"
```
(The above shortened URL is a Github redirect to `install.sh` in this repo).


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

### Thanks to:
* [Zach Holman](http://github.com/holman/dotfiles) for the dotfiles inspiration
* Various people/sources mentioned in script headers in `bin`
* Anyone else who I stole useful things from and forgot about (please shout!)
