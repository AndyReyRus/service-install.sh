#!/bin/bash


# https://github.com/fastfetch-cli/fastfetch/releases
VERSION="2.54.0"


mkdir -p ~/tools/fastfetch
cd ~/tools/fastfetch

wget https://github.com/fastfetch-cli/fastfetch/releases/download/$VERSION/fastfetch-linux-amd64.tar.gz
tar -xzf fastfetch-linux-amd64.tar.gz

# Закоментировать не нужное
echo 'set -gx PATH ~/tools/fastfetch/fastfetch-linux-amd64/usr/bin $PATH' >> ~/.config/fish/config.fish
source ~/.config/fish/config.fish

# Закоментировать не нужное
echo 'set -gx PATH ~/tools/fastfetch/fastfetch-linux-amd64/usr/bin $PATH' >> ~/.zshrc
source ~/.zshrc

fastfetch

rm -rf ~/tools/fastfetch/fastfetch-linux-amd64.tar.gz
rm ./fastfetch-ub.sh
