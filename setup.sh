#!/bin/bash

# Backup configuration files
mv $HOME/.bashrc $HOME/.bashrc.BACKUP
mv $HOME/.config $HOME/.config.BACKUP
mv $HOME/.gtkrc-2.0 $HOME/.gtkrc-2.0.BACKUP
# Install packages for configuration
sudo pacman -Sy --needed --noconfirm git wget sudo

# Setup dotfiles git and pull configuration
git init --bare $HOME/.dotfiles -b main
git --git-dir=$HOME/.dotfiles --work-tree=$HOME config --local status.showUntrackedFiles no
git --git-dir=$HOME/.dotfiles --work-tree=$HOME remote add origin https://github.com/ichbinderwooj/dotfiles.git
git --git-dir=$HOME/.dotfiles --work-tree=$HOME pull origin main

# Install jluttine/rofi-power-menu
sudo wget https://raw.githubusercontent.com/jluttine/rofi-power-menu/master/rofi-power-menu -O /usr/local/bin/rofi-power-menu
sudo chmod +x /usr/local/bin/rofi-power-menu

# Install material icons
mkdir $HOME/.fonts
wget https://raw.githubusercontent.com/google/material-design-icons/master/font/MaterialIcons-Regular.ttf -O $HOME/.fonts/MaterialIcons-Regular.ttf

# Install packages
sudo pacman -S --needed --noconfirm xorg-server lightdm lightdm-slick-greeter bspwm sxhkd kitty polybar picom rofi feh maim materia-gtk-theme papirus-icon-theme ttf-liberation ttf-liberation-mono-nerd

# Install drivers
lspci -k | grep -A 2 -E "(VGA|3D)" | grep NVIDIA
if [ $? -eq 0 ];
then
  pacman -Qqe linux-lts
  if [ $? -eq 1 ];
  then
    sudo pacman -S nvidia
  else
    sudo pacman -S nvidia-lts
  fi
  sudo sed -i 's/kms//' /etc/mkinitcpio.conf
  sudo mkinitcpio -P
fi

# LightDM configuration
sudo sed -i 's/#greeter-session=example-gtk-gnome/greeter-session=lightdm-slick-greeter/' /etc/lightdm/lightdm.conf
sudo sed -i 's/#user-session=default/user-session=bspwm/' /etc/lightdm/lightdm.conf
echo "
[Greeter]
background=/usr/share/backgrounds/background.png
theme-name=Materia-dark
icon-theme-name=Papirus-Dark
" | sudo tee /etc/lightdm/slick-greeter.conf
sudo systemctl enable lightdm.service

# Keyboard
sudo localectl set-x11-keymap de
