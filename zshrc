# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH=$HOME/bin:/usr/local/bin:/opt/homebrew/bin:$PATH

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


#oh-my-posh
eval "$(oh-my-posh init zsh --config 'https://raw.githubusercontent.com/mattkgwhite/dotfiles/main/omp-configs/easy-term.omp.json')"
# to test configuration enable this and copy config locally and reference location. 
# eval "$(oh-my-posh init zsh --config '')"

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


## Docker Container Management

function dockerallconstart() {
  #!/bin/bash
  # Start all stopped containers
  docker start $(docker ps -aq)
}

function dockerallconstop() {
  #!/bin/bash
  # Stop all running containers
  docker stop $(docker ps -q)
}

function dockerremoveconstop() {
  #!/bin/bash
  # Remove all stopped containers
  docker rm $(docker ps -aq -f "status=exited")
}

function dockerrmdangimages() {
  #!/bin/bash
  # Remove dangling images
  docker rmi $(docker images -q -f "dangling=true")
}

function dockerbackupcontainerdata() {
  #!/bin/bash
  # Backup a containers data
  CONTAINER_ID=$1
  BACKUP_FILE="${CONTAINER_ID}_backup_$(date + %F).tar"
  docker export $CONTAINER_ID > $BACKUP_FILE
  echo "Backup saved to $BACKUP_FILE"
}

function dockerrestorecontainerdata() {
  #!/bin/bash
  # Restore a container from a tar backup
  BACKUP_FILE=$1
  docker import $BACKUP_FILE restored_container:latest
  echo "Container restored as 'restored_container:latest'"
}

function dockercontainerusage() {
  #!/bin/bash
  # Monitor resource usage of all running containers
  containers
  docker stats --all
}

function dockerrestartcontainerauto() {
  #!/bin/bash
  # Restart a container with a restart policy
  CONTAINER_NAME=$1
  docker update --restart always $CONTAINER_NAME
  echo "$CONTAINER_NAME will now restart automatically on failure."
}

function dockerrunandtidy() {
  #!/bin/bash
  # Run a container and clean up
  IMAGE_NAME=$1
  docker run --rm $IMAGE_NAME
}

function dockeralllogs() {
  #!/bin/bash
  # Display logs of all containers
  docker ps -q | xargs -I {} docker logs {}
}

function dockerautoprune() {
  #!/bin/bash
  # Prune unused resources
  docker system prune -f --volumes
}

function dockerupdatrunning() {
  #!/bin/bash
  # Update a running container
  CONTAINER_NAME=$1
  IMAGE_NAME=$(docker inspect --format='{{.Config.Image}}' $CONTAINER_NAME)
  docker pull $IMAGE_NAME
  docker stop $CONTAINER_NAME
  docker rm $CONTAINER_NAME
  docker run -d --name $CONTAINER_NAME $IMAGE_NAME
}

function dockercpfilesfromcontainer() {
  #!/bin/bash
  # Copy files from a container
  CONTAINER_ID=$1
  SOURCE_PATH=$2
  DEST_PATH=$3
  docker cp $CONTAINER_ID:$SOURCE_PATH $DEST_PATH
  echo "Copied $SOURCE_PATH from $CONTAINER_PATH to $DEST_PATH"
}

function dockerrestartallcontainers() {
  #!/bin/bash
  # Restart all containers
  docker restart $(docker ps -q)
}

function dockerlistallexposedports() {
  #!/bin/bash
  # List all exposed ports
  docker ps --format '{{.ID}} {{.Name}}: {{.Ports}}'
}
