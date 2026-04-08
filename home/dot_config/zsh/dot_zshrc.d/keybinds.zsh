#!/bin/zsh

autoload -U edit-command-line
zle -N edit-command-line
bindkey -M vicmd e edit-command-line

bindkey -M menuselect ' ' accept-and-infer-next-history
bindkey -M menuselect '^?' undo

bindkey "\e\e[D" backward-word # alt + <-
bindkey "\e\e[C" forward-word # alt + ->
