# Path to your oh-my-zsh installation.
OSTYPE=$(uname -s)
if [ "$OSTYPE" = "Linux" ]; then
	export ZSH="/home/smparkin/.oh-my-zsh"
elif [ "$OSTYPE" = "Darwin" ]; then
	export ZSH="/Users/smparkin/.oh-my-zsh"
fi

# Set name of the theme to load
ZSH_THEME="newstephen"

# Hyphen-insensitive completion
HYPHEN_INSENSITIVE="true"

# Disable marking untracked files under git as dirty
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Which plugins would you like to load?
plugins=(
  colored-man-pages
  iterm2
  zsh_reload
  zsh-navigation-tools
  shrink-path
)

source $ZSH/oh-my-zsh.sh
source ~/.zsh.d/functions
source ~/.zsh.d/aliases
if [ "$OSTYPE" = "Darwin" ]; then
    source ~/.iterm2_shell_integration.zsh
fi

export EDITOR="/usr/local/bin/vim"
export PATH="/usr/local/sbin:$PATH"
export PATH="/usr/local/opt/openssl/bin:$PATH"
export CLASSPATH="/Users/smparkin/java/junit-4.12.jar:/Users/smparkin/java/processing-core.jar:${CLASSPATH}"
export PATH="/usr/local/flutter/bin:$PATH"
shownetinfo
lab
batt
