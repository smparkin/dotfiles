#! /bin/bash

echo "Install Homebrew? [y/n]"
read homebrew
if [ "$homebrew" = "y" ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "Restore from Brewfile? [y/n]"
    read bundle
    if [ "$bundle" = "y" ]; then
        echo "Available Brewfiles:"
        ls ~/dotfiles/brew/
        echo "Brewfile name: "
        read brewfile
        brew bundle install --file=~/dotfiles/brew/"$brewfile"
    else
        brew install coreutils fastfetch vim zsh jq python3
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

mkdir -p ~/Developer

echo "Change shell to zsh? [y/n]"
read shell
if [ "$shell" = "y" ]; then
    chsh -s /bin/zsh
fi
exit
