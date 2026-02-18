#! /bin/bash

OSTYPE=$(uname -s)

if [ "$OSTYPE" = "Linux" ]; then
    echo "Package manager: "
    read packm
    if [ "$packm" = "apt" ]; then
        sudo apt update
        sudo apt install coreutils vim zsh jq python3 -y
        sudo apt upgrade -y
    elif [ "$packm" = "yum" ]; then
        sudo yum update
        sudo yum install coreutils vim zsh jq python3 -y
    elif [ "$packm" = "pacman" ]; then
        sudo pacman -Syu
        sudo pacman -Sy coreutils vim zsh jq python3
    else
        echo "Unknown package manager, continuing..."
    fi
elif [ "$OSTYPE" = "Darwin" ]; then
    mkdir -p ~/Developer
    echo "Install Homebrew? [y/n]"
    read homebrew
    if [ "$homebrew" = "y" ]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo "Restore from Brewfile? [y/n]"
        read bundle
        if [ "$bundle" = "y" ]; then
            brew bundle install
        else
            brew install coreutils fastfetch vim zsh jq python3
        fi
    fi
fi

# Clone zsh plugins
PLUGIN_DIR="$HOME/.zsh/plugins"
mkdir -p "$PLUGIN_DIR"
if [ ! -d "$PLUGIN_DIR/zsh-autosuggestions" ]; then
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$PLUGIN_DIR/zsh-autosuggestions"
fi
if [ ! -d "$PLUGIN_DIR/zsh-syntax-highlighting" ]; then
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$PLUGIN_DIR/zsh-syntax-highlighting"
fi

# silence login message
touch ~/.hushlogin

# remove common files and symlink new files
rm -f ~/.zshrc ~/.vimrc ~/.tmux.conf ~/.gitconfig ~/.gitignore_global
rm -rf ~/.zsh.d
mkdir ~/.zsh.d
ln -s ~/dotfiles/zsh/aliases ~/.zsh.d/aliases
ln -s ~/dotfiles/zsh/functions ~/.zsh.d/functions
ln -s ~/dotfiles/zsh/theme ~/.zsh.d/theme
ln -s ~/dotfiles/zsh/zshrc ~/.zshrc
ln -s ~/dotfiles/git/gitconfig ~/.gitconfig
ln -s ~/dotfiles/git/gitignore_global ~/.gitignore_global
ln -s ~/dotfiles/tmux/tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/vim/vimrc ~/.vimrc

echo "Change shell to zsh? [y/n]"
read shell
if [ "$shell" = "y" ]; then
    chsh -s /bin/zsh
fi
exit
