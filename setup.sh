#! /bin/bash

OSTYPE=$(uname -s)

if [ "$OSTYPE" = "Linux" ]; then
    DISTRO=$(lsb_release -i -s)
    if [ "$DISTRO" = "Ubuntu" ]; then
        sudo apt update
        sudo apt install coreutils vim zsh jq python3 python3-pip -y
        sudo apt upgrade -y
    else
        # pretty safe assumption that if not ubuntu its arch
        sudo pacman -Syu
        sudo pacman -Sy coreutils vim zsh jq python3
    fi
elif [ "$OSTYPE" = "Darwin" ]; then
    echo "Install Nix? [y/n]"
    read install_nix
    if [ "$install_nix" = "y" ]; then
	sh <(curl -L https://nixos.org/nix/install)
fi

# silence login message
touch ~/.hushlogin

# remove common files and symlink new files
rm ~/.zshrc ~/.vimrc ~/.tmux.conf

mkdir ~/Developer

echo "Change shell to zsh? [y/n]"
read shell
if [ "$shell" = "y" ]; then
    chsh -s /bin/zsh
fi
exit
