@echo off
mklink %HOMEPATH%\.config %CD%\config
mklink %HOMEPATH%\.aliases %CD%\aliases
mklink %HOMEPATH%\.bashrc %CD%\bashrc
mklink %HOMEPATH%\.bash_profile %CD%\bashprofile
mklink %HOMEPATH%\.exports %CD%\exports
mklink %HOMEPATH%\.functions %CD%\functions
mklink %HOMEPATH%\.gdbinit %CD%\functions
mklink %HOMEPATH%\.gitconfig %CD%\gitconfig
mklink %HOMEPATH%\.gitignore_global %CD%\gitignore_global
mklink %HOMEPATH%\.path %CD%\path
mklink %HOMEPATH%\.rvmrc %CD%\rvmrc
mklink %HOMEPATH%\.tmux.conf %CD%\tmux.conf
mklink %HOMEPATH%\.vimrc %CD%\vimrc
mklink %HOMEPATH%\.zprofile %CD%\zprofile
mklink %HOMEPATH%\.zshrc %CD%\zshrc

REM Hide the links
attrib /L +h %HOMEPATH%\.config
attrib /L +h %HOMEPATH%\.aliases
attrib /L +h %HOMEPATH%\.bashrc
attrib /L +h %HOMEPATH%\.bash_profile
attrib /L +h %HOMEPATH%\.exports
attrib /L +h %HOMEPATH%\.functions
attrib /L +h %HOMEPATH%\.gdbinit
attrib /L +h %HOMEPATH%\.gitconfig
attrib /L +h %HOMEPATH%\.gitignore_global
attrib /L +h %HOMEPATH%\.path
attrib /L +h %HOMEPATH%\.rvmrc
attrib /L +h %HOMEPATH%\.tmux.conf
attrib /L +h %HOMEPATH%\.vimrc
attrib /L +h %HOMEPATH%\.zprofile
attrib /L +h %HOMEPATH%\.zshrc

REM TODO: SSHConfig?
