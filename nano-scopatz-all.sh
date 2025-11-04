#!/bin/bash


USER=ar4
sudo -v -t 180

sudo cp /etc/nanorc /etc/nanorc.backup
sudo sed -i '/^[^#]/ s/^/# /' /etc/nanorc


mkdir -p /home/$USER/.config/nano
cp /etc/nanorc /home/$USER/.config/nano/nanorc

sudo mkdir -p /root/.config/nano
sudo cp /etc/nanorc /root/.config/nano/nanorc


curl https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh | sh

sudo cp -r /home/$USER/.nano /root/ 


# Исправляем ошибку в nanorc.nanorc
sudo sed -i 's/^icolor brightnormal " brightnormal"/# &/' /root/.nano/nanorc.nanorc


cat <<EOF>> /home/$USER/.config/nano/nanorc 
#
#
set indicator
set historylog
set locking
set mouse
#set linenumbers

# Указываем темы для подсветки синтаксиса всевозможных фрматов
include "/home/$USER/.nano/*.nanorc"
EOF


sudo tee -a /root/.config/nano/nanorc <<EOF
#
#
set indicator
set historylog
set locking
set mouse
#set linenumbers

# Указываем темы для подсветки синтаксиса всевозможных форматов
include "/root/.nano/*.nanorc"
EOF

rm ./nano-scopatz-all.sh
