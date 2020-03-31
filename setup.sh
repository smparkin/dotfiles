#! /bin/bash

OSTYPE=$(uname -s)

# get package manager up to date
if [ "$OSTYPE" = "Linux" ]; then
	sudo apt update
	sudo apt install fortune cowsay lolcat zsh -y
	sudo apt upgrade -y
elif [ "$OSTYPE" = "Darwin" ]; then
	echo "Install Homebrew? [y/n]"
	read homebrew
	if [ "$homebrew" = "y" ]; then
		/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        	brew bundle install --file=Brewfile
	fi
fi

# get ohmyzsh setup
git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh/

# symlink files
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
git clone https://github.com/smparkin/SpotifyCLI.git ~/Development/SSiTerm
cd ~/Development/SSiTerm
pip3 install -r requirements.txt
cd ~/

echo "Change shell to zsh? [y/n]"
read shell
if [ "$shell" = "y" ]; then
	chsh -s /bin/zsh
fi
exit
