function shownetinfo() {
	local os=$(uname -s)
	local LANIP=""
	local WANIP=""
	local ROUTR=""

	if [ "$os" = "Linux" ]; then
		LANIP=$(ip addr show | grep -v "127.0.0.1" | grep "inet " | head -1 | cut -d " " -f6 | cut -d "/" -f1)
		ROUTR=$(ip route | grep default | cut -d " " -f3)
	elif [ "$os" = "Darwin" ]; then
		ROUTR=$(route -n get default 2>/dev/null | awk '/gateway:/{print $2}')
		LANIP=$(ifconfig | grep -v "127.0.0.1" | grep "inet " | head -1 | cut -d " " -f2)
	fi
	if [ "$ROUTR" != "" ]; then
		WANIP=$(timeout 0.25s curl -s https://ipv4.icanhazip.com)
		# printed with echo -e, so only accept something shaped like an IPv4 address
		[[ $WANIP =~ '^[0-9.]+$' ]] || WANIP=""
	fi
	tput setaf 7
	tput bold
	echo -en "Net: "
	tput sgr0
	tput setaf 7
	echo -en "internal $LANIP"
	if [ "$ROUTR" != "" ]; then
		echo -en ", external $WANIP"
		echo -en ", router $ROUTR"
	fi
	echo
	tput sgr0
}

# Update Homebrew packages, then list anything installed that this host's
# Brewfile doesn't have, so it can be added there or uninstalled
function brewup() {
	clear
	brew update && brew upgrade && brew cleanup -s && brew autoremove || return
	brew doctor --verbose | grep -A 1 --color=never "Homebrew Version"
	local brewfile=~/dotfiles/brew/$(hostname -s)
	[[ -f $brewfile ]] || brewfile=~/dotfiles/brew/base
	brew bundle cleanup --file="$brewfile"
}
