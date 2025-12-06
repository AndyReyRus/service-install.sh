#!/bin/fish
set -e

# https://github.com/fastfetch-cli/fastfetch/releases
VERSION="2.54.0"


mkdir -p ~/tools/fastfetch
cd ~/tools/fastfetch

wget https://github.com/fastfetch-cli/fastfetch/releases/download/$VERSION/fastfetch-linux-amd64.tar.gz
tar -xzf fastfetch-linux-amd64.tar.gz

grep -q 'fastfetch-linux-amd64/usr/bin' "$HOME/.zshrc" 2>/dev/null || \
echo 'export PATH="$HOME/tools/fastfetch/fastfetch-linux-amd64/usr/bin:$PATH"' >> "$HOME/.config/fish/config.fish"
source ~/.config/fish/config.fish

fastfetch

rm -rf ~/tools/fastfetch/fastfetch-linux-amd64.tar.gz
