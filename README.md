Dotfiles
===

Configuration files for backup/sync between systems.

## Usage

 1. Clone: `git clone --recursive git@github.com:mattkgwhite/etc.git ~/.etc`
 2. Backup: `~/.etc/link.sh/link.sh -u ~/.etc/.link.conf -b`
 3. Link: `~/.etc/link.sh/link.sh -u ~/.etc/.link.conf -wf`

### Remove user@hostname from prompt
_~/.etc/zsh/zsh-os-conf/local-pre/00-bullettrain.zsh_
```
BULLETTRAIN_CONTEXT_DEFAULT_USER=$USER
DEFAULT_USER=$USER
```

#### iTerm config
- Tomorrow Night (included; tomorrow-night.itermcolor)
- Operator Mono 14pt (ASCII)
- monofur for Powerline 14pt (non-ASCII)
