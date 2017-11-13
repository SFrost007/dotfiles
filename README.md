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
interactive setup script.

_Note: Ubuntu doesn't install curl as default; run `sudo apt install curl` first._

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/sfrost007/dotfiles/master/tools/install.sh)"
```

### Manual install
1. Install git, with either `xcode-select --install` or `sudo apt install git`
2. Clone the repository wherever desired
3. Edit `DOTFILES_DIR` in tools/install.sh (TODO: Only set if not in ENV)
4. Run tools/install.sh


# Functional overview
* Setup script is modular (see README in tools/setup-modules for details)
* Mainly built for zsh. Config will auto-load any .zsh files in the zsh folder
* Custom scripts/binaries live in the `bin` folder
* Symlinks are defined explicitly in a setup module

# TODO
* Actually write setup-modules' README
* Git pull hooks to automatically re-run update scripts
* Setup module to generate SSH key and replace git origin with ssh version
* App install via package managers (see packages folder)

### Thanks to:
* [Zach Holman](http://github.com/holman/dotfiles) for the dotfiles inspiration
* Various people/sources mentioned in script headers in `bin`
* Anyone else who I stole useful things from and forgot about (please shout!)
