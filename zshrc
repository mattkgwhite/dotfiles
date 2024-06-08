

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.zsh/oh-my-zsh"
export ZSH_CUSTOM=$HOME/.zsh/custom
# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="dracula"
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

# User configuration

# Personal Aliases
#export VAULT_ADDR=https://vault.*
export VAULT_ADDR=localhost:8200

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
#oh-my-posh
eval "$(oh-my-posh init zsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/kushal.omp.json')"

# Personal Functions

## pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

## Online?
function online() {
    host="${1}"
    ports="${2:-22,80,443}"

    if [[ "$host" == "" ]]; then
        echo "Define a host in this function"
        echo ""
        return
    fi

    nmap -Pn $host -p $ports
}

## getCert
function getCert() {
    URL="$1"
    PORT="${2:=443}"
    echo | openssl s_client -connect ${URL}:${PORT} | openssl x509 -noout -text
}
