#!/usr/bin/env bash
# Safe to re-run: every step checks the current state and only acts (or asks)
# when something is missing.
#
# Brewfile: brew/$(hostname -s) if it exists, otherwise brew/base.
# Override with e.g. `BREWFILE=italica ./setup.sh`.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

ask() {
	local reply
	read -r -p "$1 [y/n] " reply || return 1
	[[ $reply == [yY]* ]]
}

# Symlink $DOTFILES/$1 to $2. A real file already at $2 is moved to $BACKUP_DIR.
link() {
	local src="$DOTFILES/$1" dst="$2"
	if [[ -L $dst && $(readlink "$dst") == "$src" ]]; then
		return
	fi
	if [[ -L $dst ]]; then
		rm "$dst"
	elif [[ -e $dst ]]; then
		local backup="$BACKUP_DIR/${dst#"$HOME"/}"
		mkdir -p "$(dirname "$backup")"
		mv "$dst" "$backup"
		echo "Backed up $dst to $backup"
	fi
	mkdir -p "$(dirname "$dst")"
	ln -s "$src" "$dst"
	echo "Linked $dst -> $src"
}

load_brew() {
	if [[ -x /opt/homebrew/bin/brew ]]; then
		eval "$(/opt/homebrew/bin/brew shellenv)"
	elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
		eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
	fi
	command -v brew &>/dev/null
}

login_shell() {
	if [[ $(uname -s) == Darwin ]]; then
		dscl . -read "/Users/$(id -un)" UserShell | awk '{print $2}'
	else
		getent passwd "$(id -un)" | cut -d: -f7
	fi
}

# Homebrew
if ! load_brew && ask "Install Homebrew?"; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	load_brew
fi

if command -v brew &>/dev/null; then
	brewfile="$DOTFILES/brew/${BREWFILE:-$(hostname -s)}"
	if [[ ! -f $brewfile ]]; then
		if [[ -n ${BREWFILE:-} ]]; then
			echo "No such Brewfile: $brewfile" >&2
			exit 1
		fi
		brewfile="$DOTFILES/brew/base"
	fi
	if brew bundle check --no-upgrade --file="$brewfile" &>/dev/null; then
		echo "Brewfile brew/${brewfile##*/} is satisfied"
	elif ask "Install missing packages from brew/${brewfile##*/}?"; then
		brew bundle install --no-upgrade --file="$brewfile"
	fi
fi

# Clone zsh plugins
for repo in zsh-users/zsh-autosuggestions zsh-users/zsh-syntax-highlighting; do
	dir="$HOME/.zsh/plugins/${repo#*/}"
	[[ -d $dir ]] || git clone --depth=1 "https://github.com/$repo" "$dir"
done

# silence login message
[[ -e $HOME/.hushlogin ]] || touch "$HOME/.hushlogin"

link zsh/zshrc "$HOME/.zshrc"
link zsh/aliases.zsh "$HOME/.zsh.d/aliases"
link zsh/functions.zsh "$HOME/.zsh.d/functions"
link zsh/theme.zsh "$HOME/.zsh.d/theme"
link git/gitconfig "$HOME/.gitconfig"
link git/gitignore_global "$HOME/.gitignore_global"
link tmux/tmux.conf "$HOME/.tmux.conf"
link vim/vimrc "$HOME/.vimrc"

mkdir -p "$HOME/Developer"

if command -v chsh &>/dev/null && command -v zsh &>/dev/null; then
	zsh_path="$(command -v zsh)"
	if [[ $(login_shell) != "$zsh_path" ]] && ask "Change login shell to $zsh_path?"; then
		# chsh refuses shells that aren't listed in /etc/shells (e.g. Homebrew's zsh)
		grep -qxF "$zsh_path" /etc/shells || echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
		chsh -s "$zsh_path"
	fi
fi
