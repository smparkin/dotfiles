function shownetinfo() {
	OSTYPE=$(uname -s)
	LANIP=""
	WANIP=""
	ROUTR=""

	if [ "$OSTYPE" = "Linux" ]; then
		LANIP=$(ip addr show | grep -v "127.0.0.1" | grep "inet " | head -1 | cut -d " " -f6 | cut -d "/" -f1)
		ROUTR=$(ip route | grep default | cut -d " " -f3)
		if [ "$ROUTR" != "" ]; then
			WANIP=$(timeout 0.25s curl -s ipv4.icanhazip.com)
		fi
	elif [ "$OSTYPE" = "Darwin" ]; then
		ROUTR=$(system_profiler SPNetworkDataType | grep "Router:" | cut -c 19-30 | head -1)
		LANIP=$(ifconfig | grep -v "127.0.0.1" | grep "inet " | head -1 | cut -d " " -f2)
		if [ "$ROUTR" != "" ]; then
			WANIP=$(timeout 0.25s curl -s ipv4.icanhazip.com)
		fi
	fi
	tput setaf 7
	tput bold
	echo -en "Net: "
	tput sgr0
	tput setaf 7
	echo -en "internal $LANIP"
	if [ "$ROUTR" != "" ]; then
		echo -en ", external $WANIP"
		echo -e ", router $ROUTR"
	fi
	tput sgr0
}
