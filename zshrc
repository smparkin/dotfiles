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
shownetinfo
if [ "$OSTYPE" = "Linux" ]; then
    echo ""
elif [ "$OSTYPE" = "Darwin" ]; then
    ssh-add -K ~/.ssh/id_rsa 2>/dev/null
    batt
fi
# configure homebrew for arm and x86
if [ "$OSTYPE" = "Darwin" ]; then
    ARCH=$(uname -m)
    if [ "$ARCH" = "arm64" ]; then
        export PATH="/opt/homebrew/bin:$PATH"
        export PATH="/opt/homebrew/sbin:$PATH"
        export PATH="/Users/smparkin/Library/Python/3.9/bin:$PATH"
    elif [ "$ARCH" = "x86_64" ]; then
        export PATH="/usr/local/bin:$PATH"
        export PATH="/usr/local/sbin:$PATH"
    fi
fi
