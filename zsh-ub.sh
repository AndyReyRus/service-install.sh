#!/bin/bash


sudo sh -c 'apt update && apt install zsh git curl -y'


if [ -f ~/.zshrc ]; then
    cp ~/.zshrc ~/.zshrc.backup
    echo "----- Backup created: ~/.zshrc.backup -----"
fi

git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
git clone https://github.com/tom-auger/cmdtime ~/.oh-my-zsh/custom/plugins/cmdtime


cat <<EOF> ~/.zshrc
export ZSH="\$HOME/.oh-my-zsh"
export VISUAL=nano
export EDITOR="\$VISUAL"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

ZSH_THEME="lukerandall"

plugins=(
git
zsh-autosuggestions
fast-syntax-highlighting
dirhistory
history
cmdtime
)

source \$ZSH/oh-my-zsh.sh
EOF

chsh -s $(which zsh)
exec zsh

rm ./zsh-ub.sh
