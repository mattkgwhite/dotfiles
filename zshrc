
Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Powerlevel10k Config
export P10K="$HOME/.etc/powerlevel10k/powerlevel10k"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.zsh/oh-my-zsh"
export ZSH_CUSTOM=$HOME/.zsh/custom
# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="dracula"
ZSH_AUTOSUGGEST_USE_ASYNC=true
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=15

# Exports
export SHOW_AWS_PROMPT=false
export SHOW_AWS_PROMPT=false
export ZSH_HOME="$HOME/.zsh"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="false"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
1password
argocd
aws
bat
docker
docker-compose
dotenv
fzf
git
golang
helm
kubectl
minikube
npm
nvm
pip
pipenv
python
sudo
tmux
vault
virtualenvwrapper
vscode
zsh-completions
)

## Battery - battery
# comes from .p10k.zsh file

## IP - public_ip_address
# comes from .p10k.zsh file

## VPN IP - vpn_ip
# comes from .p10k.zsh file

ZSH_TMUX_AUTOSTART=true

case $(uname -s) in
  *Darwin*)
    source $HOME/.zsh/zsh-os-conf/osx-pre-omz.zsh
    ;;
  *Linux*)
    source $HOME/.zsh/zsh-os-conf/linux-pre-omz.zsh
    ;;
esac


source $ZSH/oh-my-zsh.sh
#source ~/powerlevel10k/powerlevel10k.zsh-theme # original binding
source $P10K/powerlevel10k.zsh-theme

# User configuration

# Personal Aliases
#export VAULT_ADDR=https://vault.*
export VAULT_ADDR=localhost:8200



# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

