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

# Configure Bash
rm ~/.bashrc
RC='\e[0m'
RED='\e[31m'
YELLOW='\e[33m'
GREEN='\e[32m'

checkEnv(){
    ## Check if the current directory is writable.
    GITPATH=$(pwd)
    if [[ ! -w ${GITPATH} ]];then
        echo -e "${RED}Can't write to ${GITPATH}${RC}"
        exit 1
    fi

    ## Check for requirements.
    REQUIREMENTS='curl apt groups sudo'
    if ! which ${REQUIREMENTS}>/dev/null;then
        echo -e "${RED}To run me, you need: ${REQUIREMENTS}${RC}"
        exit 1
    fi

    ## Check if member of the sudo group.
    if ! groups|grep sudo>/dev/null;then
        echo -e "${RED}You need to be a member of the sudo group to run me!"
        exit 1
    fi
}

installDepend(){
    ## Check for dependencies.
    DEPENDENCIES='autojump bash bash-completion'
    echo -e "${YELLOW}Installing dependencies...${RC}"
    sudo dpkg --configure -a
    sudo apt-get install -fyq ${DEPENDENCIES}
    sudo dpkg --configure -a
}

installStarship(){
    if ! curl -sS https://starship.rs/install.sh|sh;then
        echo -e "${RED}Something went wrong during starship install!${RC}"
        exit 1
    fi
}

linkConfig(){
    ## Check if a bashrc file is already there.
    OLD_BASHRC="${HOME}/.bashrc"
    if [[ -e ${OLD_BASHRC} ]];then
        echo -e "${YELLOW}Moving old bash config file to ${HOME}/.bashrc.bak${RC}"
        if ! mv ${OLD_BASHRC} ${HOME}/.bashrc.bak;then
            echo -e "${RED}Can't move the old bash config file!${RC}"
            exit 1
        fi
    fi

    echo -e "${YELLOW}Linking new bash config file...${RC}"
    ## Make symbolic link.
    ln -svf ${GITPATH}/.bashrc ${HOME}/.bashrc
    ln -svf ${GITPATH}/starship.toml ${HOME}/.config/starship.toml
}

checkEnv
installDepend
installStarship
if linkConfig;then
    echo -e "${GREEN}Done!\nrestart your shell to see the changes.${RC}"
else
    echo -e "${RED}Something went wrong!${RC}"
fi

# Add Custom Titus Rofi Deb Package
dpkg -i 'Custom Packages/rofi_1.7.0-1_amd64.deb'

# Update packages list
apt update

# Add base packages
apt install unzip picom bspwm polybar sddm rofi kitty thunar flameshot neofetch sxhkd git lxpolkit lxappearance xorg firefox pulseaudio pavucontrol -y
apt install papirus-icon-theme feh lxappearance fonts-noto-color-emoji fonts-firacode fonts-font-awesome libqt5svg5 qml-module-qtquick-controls qml-module-qtquick-controls2 variety breeze-cursor-theme -y

# Download Nordic Theme
cd /usr/share/themes/
git clone https://github.com/EliverLara/Nordic.git

# Fira Code Nerd Font variant needed
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v1.1.0/FiraCode.zip
unzip FiraCode.zip -d /usr/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v1.1.0/Meslo.zip
unzip Meslo.zip -d /usr/share/fonts
fc-cache -vf

# Get config files ready

mkdir /home/$username/.config
chown $(whoami): /home/$username/.config
mv /home/$username/debian-starterpack/dotconfig/* /home/$username/.config
mv home/$username/debian-starterpack/bg.jpg /home/$username/.config
mv /home/$username/debian-starterpack/.* /home/$username/
