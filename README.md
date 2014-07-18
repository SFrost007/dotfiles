# Simon's dotfiles

## Installation

### Using Git and the install script

Clone the repository anywhere, though `~/Code/TerminalUtils/dotfiles` is my convention.

```bash
git clone https://github.com/sfrost007/dotfiles.git && cd dotfiles && source install.sh
```

To update:

```bash
cd dotfiles && git pull && source install.sh
```

### Git-free install

To install these dotfiles without Git (untested but should work):

```bash
curl -#L https://github.com/sfrost007/dotfiles/tarball/master | tar -xzv --strip-components 1 --exclude={README.md} && cd dotfiles && source install.sh
```

### Handling

Rather than have a single install script which explicitly links any dotfiles into the correct place, the installer takes a more generic approach based on filename suffixes:

* ** *.symlink**: Any file/folder ending with `.symlink` will be prefixed with a dot and symlinked into `$HOME`
* ** *.configdir**: Any file/folder ending with `.configdir` will be symlinked into `$HOME/.config`

Interactive prompts will be shown for any file which already exists (unless matching the target symlink), allowing skip/overwrite/backup options.

As per the entry in `shell/paths`, any items in `scripts` will be made available on the path (assuming the dotfiles have been cloned to `~/Code/TerminalUtils/dotfiles/`).


### Special cases

* If a file exists at ssh/config (not committed), this will be symlinked into $HOME/.ssh/.
* TODO: Sublime handling


### Thanks to:

* [Zach Holman](https://github.com/holman/dotfiles) for the install.sh inspiration
* [Mathias Bynens](http://github.com/mathiasbynens/dotfiles) for the README inspiration
* Anyone else who I stole any of the useful commands/aliases/scripts from (sorry for forgetting you!)
