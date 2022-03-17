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
    echo "Install Homebrew? [y/n]"
    read homebrew
    if [ "$homebrew" = "y" ]; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo "Restore from Brewfile? [y/n]"
        read bundle
        if [ "$bundle" = "y" ]; then
            brew bundle install --file=Brewfile
        else
            brew install coreutils neofetch vim zsh jq python3
        fi
    fi
fi

# silence login message
touch ~/.hushlogin

# get ohmyzsh setup
git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh/

# remove common files and symlink new files
rm ~/.zshrc ~/.vimrc ~/.tmux.conf
mkdir ~/.zsh.d
ln -s ~/dotfiles/aliases ~/.zsh.d/aliases
ln -s ~/dotfiles/functions ~/.zsh.d/functions
ln -s ~/dotfiles/zshrc ~/.zshrc
ln -s ~/dotfiles/gitconfig ~/.gitconfig
ln -s ~/dotfiles/gitignore_global ~/.gitignore_global
ln -s ~/dotfiles/newstephen.zsh-theme ~/.oh-my-zsh/custom/themes/newstephen.zsh-theme
ln -s ~/dotfiles/tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/vimrc ~/.vimrc

mkdir ~/Development

echo "Change shell to zsh? [y/n]"
read shell
if [ "$shell" = "y" ]; then
    chsh -s /bin/zsh
fi
exit
