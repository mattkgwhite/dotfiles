Dotfiles
===

Configuration files for backup/sync between systems.

## Usage

 1. Clone: `git clone --recursive git@github.com:mattkgwhite/dotfiles.git ~/.etc`
 2. Backup: `~/.etc/link.sh/link.sh -u ~/.etc/.link.conf -b`
 3. Link: `~/.etc/link.sh/link.sh -u ~/.etc/.link.conf -wf`

### Remove user@hostname from prompt
_~/.etc/zsh/zsh-os-conf/local-pre/00-bullettrain.zsh_
```
BULLETTRAIN_CONTEXT_DEFAULT_USER=$USER
DEFAULT_USER=$USER
```

### Colour Render Command - Terminal

This command is from the powerlevel10k github repo, [found here](https://github.com/romkatv/powerlevel10k#change-the-color-palette-used-by-your-terminal). This command generates a colour table, to show an example of how colours will look on your terminal.

```shell
for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}; done
```


#### iTerm config
- Tomorrow Night (included; tomorrow-night.itermcolor)
- Operator Mono 14pt (ASCII)
- monofur for Powerline 14pt (non-ASCII)

