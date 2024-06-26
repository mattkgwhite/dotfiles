#!/bin/bash

apt install python3 python3-pip fzf 

pip3 install virtualenvwrapper

# install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# install oh-my-posh
curl -s https://ohmyposh.dev/install.sh | bash -s