#!/usr/bin/env bash
# Safe to re-run: every step checks the current state and only acts (or asks)
# when something is missing.
#
# Packages: Homebrew on macOS, from brew/$(hostname -s) if it exists, otherwise
# brew/base (override with e.g. `BREWFILE=italica ./setup.sh`); apt on Debian,
# from apt/base.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
OS="$(uname -s)"

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
	fi
	command -v brew &>/dev/null
}

login_shell() {
	if [[ $OS == Darwin ]]; then
		dscl . -read "/Users/$(id -un)" UserShell | awk '{print $2}'
	else
		getent passwd "$(id -un)" | cut -d: -f7
	fi
}

if [[ $OS == Darwin ]]; then
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
elif command -v apt-get &>/dev/null; then
	missing=()
	while read -r pkg; do
		# dpkg-query's own ${...} format, not a shell expansion
		# shellcheck disable=SC2016
		if [[ $(dpkg-query -W -f='${db:Status-Abbrev}' "$pkg" 2>/dev/null) != ii* ]]; then
			missing+=("$pkg")
		fi
	done < <(grep -vE '^(#|$)' "$DOTFILES/apt/base")
	if ((${#missing[@]} == 0)); then
		echo "apt/base is satisfied"
	elif ask "Install ${missing[*]} with apt?"; then
		sudo apt-get update
		sudo apt-get install -y "${missing[@]}"
	fi
fi

# zsh plugins come from Homebrew or apt now. Remove the git clones an older
# version of this script made, once the packaged copy is there.
for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
	clone="$HOME/.zsh/plugins/$plugin"
	if [[ -d $clone/.git && (-f ${HOMEBREW_PREFIX:-/opt/homebrew}/share/$plugin/$plugin.zsh || -f /usr/share/$plugin/$plugin.zsh) ]]; then
		rm -rf "$clone"
		echo "Removed $clone (now from a package)"
	fi
done
rmdir "$HOME/.zsh/plugins" "$HOME/.zsh" 2>/dev/null || true

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

# The OS's own zsh: macOS ships one, and Debian's comes from apt/base
if [[ $OS == Darwin ]]; then
	zsh_path=/bin/zsh
else
	zsh_path=/usr/bin/zsh
fi
if [[ -x $zsh_path && $(login_shell) != "$zsh_path" ]] && ask "Change login shell to $zsh_path?"; then
	chsh -s "$zsh_path"
fi
