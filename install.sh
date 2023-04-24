#!/bin/bash

# Check if Script is Run as Root
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to run this script, please run sudo ./install.sh" 2>&1
  exit 1
fi

# Change Debian to SID Branch
cp /etc/apt/sources.list /etc/apt/sources.list.bak
cp sources.list /etc/apt/sources.list


username=$(id -u -n 1000)
builddir=$(pwd)

# Add Custom Titus Rofi Deb Package
dpkg -i 'Custom Packages/rofi_1.7.0-1_amd64.deb'

# Update packages list
apt update

# Add base packages
apt install vim unzip picom bspwm awesome openbox polybar lxsession lxpanel lightdm rofi kitty terminator thunar flameshot neofetch sxhkd git lxpolkit lxappearance xorg firefox-esr pulseaudio pavucontrol -y
apt install tar papirus-icon-theme nitrogen lxappearance breeze fonts-noto-color-emoji fonts-firacode fonts-font-awesome libqt5svg5 qml-module-qtquick-controls qml-module-qtquick-controls2 variety -y

# Purge LXDE
apt purge openbox-lxde-session -y

# Download Nordic Theme

cd /usr/share/themes/
git clone https://github.com/EliverLara/Nordic.git
mkdir -p /home/$username/.themes
cp /home/$username/koenos-debian/Nord-Openbox.tar.xz /home/$username/.themes
tar -xf /home/$username/Nord-Openbox.tar.xz

# Fira Code Nerd Font variant needed

wget https://github.com/ryanoasis/nerd-fonts/releases/download/v1.1.0/FiraCode.zip
unzip FiraCode.zip -d /usr/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v1.1.0/Meslo.zip
unzip Meslo.zip -d /usr/share/fonts
fc-cache -vf

# Wallpapers
git clone https://github.com/phoenixstaryt/koenos-Wallpapers /home/$username/.wallpaper

# Making .config and Moving config files

cd $builddir
mkdir -p /home/$username/.config
mkdir -p /home/$username/.fonts
cp .Xresources /home/$username
cp .Xnord /home/$username
cp -R dotconfig/* /home/$username/.config/
mv user-dirs.dirs /home/$username/.config
chown -R $username:$username /home/$username

# Autoremove
apt autoremove
