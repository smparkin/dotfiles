git_branch_info() {
	# This runs in every repo you cd into, including ones whose .git came from an
	# archive or shared drive. A repo's own config and hooks can make `git status`
	# run commands (fsmonitor, post-index-change, filter drivers), so disable the
	# first two and skip status entirely if the repo defines its own filters.
	local -a git=(git -c core.fsmonitor=false -c core.hooksPath=/dev/null --no-optional-locks)
	local git_status_full
	if "${git[@]}" config --show-scope --get-regexp '^filter\.' 2>/dev/null | grep -qvE '^(system|global)[[:space:]]'; then
		git_status_full="# branch.head $("${git[@]}" symbolic-ref --short -q HEAD)"
	else
		git_status_full=$("${git[@]}" status --porcelain=v2 --branch --ignore-submodules -z 2>/dev/null)
	fi
	[[ -n "$git_status_full" ]] || return

	local branch=""
	local status_indicators=""
	local line
	local -a status_lines=("${(0)git_status_full}")

	for line in $status_lines; do
		case $line in
		\#' 'branch.head' '*)
			branch=${line##* }
			continue
			;;
		\#' 'branch.ab' '*)
			local -a counts=("${(s: :)line}")
			[[ ${counts[3]#+} -gt 0 ]] && status_indicators+="%B%F{magenta}↑%f%b"
			[[ ${counts[4]#-} -gt 0 ]] && status_indicators+="%B%F{green}↓%f%b"
			;;
		'?'*) ((untracked)) || {
			untracked=1
			status_indicators+="%B%F{white}●%f%b"
		} ;;
		'u'*) ((unmerged)) || {
			unmerged=1
			status_indicators+="%B%F{red}✕%f%b"
		} ;;
		[12]' '*)
			if [[ ${line[3]} != "." && $staged -eq 0 ]]; then
				staged=1
				status_indicators+="%B%F{green}●%f%b"
			fi
			if [[ ${line[4]} != "." && $unstaged -eq 0 ]]; then
				unstaged=1
				status_indicators+="%B%F{red}●%f%b"
			fi
			;;
		esac
	done

	[[ -n "$branch" ]] && echo " %B%F{white}‹ %B%F{yellow}${(V)branch//\%/%%}%f${status_indicators:+ $status_indicators}%B%F{white}%f ›"
}

local CACHED_PWD=""
local CACHED_SHORT_PWD=""
# Sets CACHED_SHORT_PWD rather than echoing, so it must not be called in $(...)
# or the cache is lost with the subshell.
shrink_path() {
	if [[ $CACHED_PWD != $PWD ]]; then
		CACHED_PWD=$PWD
		local directory=${PWD/#$HOME/\~}
		if [[ $directory == '~' || $directory == '/' ]]; then
			CACHED_SHORT_PWD=$directory
			return
		fi
		local parts=("${(@s:/:)directory}")
		local output=()
		for part in $parts[1,-2]; do
			if [[ -n $part && $part != "~" ]]; then
				output+=$part[1]
			else
				output+=$part
			fi
		done
		output+=$parts[-1]
		CACHED_SHORT_PWD=${(j:/:)output}
	fi
}

# SSH connection indicator
ssh_connection() {
	if [[ -n $SSH_CONNECTION ]]; then
		echo "%B%F{red}(ssh)%f%b "
	fi
}

# Command duration tracking
_cmd_start_time=0
_cmd_duration=""
preexec() { _cmd_start_time=$SECONDS; }
precmd() {
	if ((_cmd_start_time > 0)); then
		local elapsed=$(($SECONDS - _cmd_start_time))
		if ((elapsed >= 5)); then
			local hours=$((elapsed / 3600))
			local mins=$(((elapsed % 3600) / 60))
			local secs=$((elapsed % 60))
			if ((hours > 0)); then
				_cmd_duration="${hours}h${mins}m${secs}s"
			elif ((mins > 0)); then
				_cmd_duration="${mins}m${secs}s"
			else
				_cmd_duration="${secs}s"
			fi
		else
			_cmd_duration=""
		fi
		_cmd_start_time=0
	fi

	# Print first info line: left-aligned content with right-aligned duration.
	# Print the duration at column (COLUMNS - len), then \r back and overwrite with the left side.
	if [[ -n $_cmd_duration ]]; then
		local right="took $_cmd_duration"
		printf "\e[%dG\e[38;5;245m%s\e[0m\r" $((COLUMNS - ${#right})) "$right"
	fi
	# Branch and directory names are untrusted: print -P must not run $(...) in them
	# (no_prompt_subst), and (V) / %% stop control characters and prompt escapes.
	setopt localoptions no_prompt_subst
	shrink_path
	print -P "$(ssh_connection)%B%F{green}%n@%m%f%b$(git_branch_info) %f%b: ${(V)CACHED_SHORT_PWD//\%/%%}"
}

# Prompt configuration — first info line is printed by precmd above
PROMPT='[%(?:%B%F{green}%?%f%b:%B%F{red}%?%f%b)]  '
RPROMPT=''
