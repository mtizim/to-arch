#!/usr/bin/env bash
# Inspired by mariuszkurek/convert.sh
# $1 - Phase

if [ "$(id -u)" == "0" ] && [ "$1" != "2" ]; then
	printf "This script should not be run as root.\nPermissions will be elevated automatically for system-wide tasks.\n"
	exit 1
fi
# Bash pipes commands parallelly on sync, so this exits every pipe running in the shell if running as root.
[ $? == 1 ] && exit 1;

# Let me tell you what the hell this 「phase system」is.
# You will probably use ./to_arch to run this. Other methods like bash to_arch will fail to use this.
# So if $1, the "option" kind of subcommand is not provided(-z), the script runs a parallel command called ./to_arch(which is $0) 1.
# Now if $1 is 1, the pre-script is executed, and so on.
if [ -z "$1" ]; then
	"$0" 1
	sudo "$0" 2 2>/dev/null
	"$0" 3
elif [ "$1" -eq 1 ]; then
## Phase 1
__PRESCRIPT__
elif [ "$1" -eq 2 ]; then
## Phase 2
__CONVERTSCRIPT__
elif [ "$1" -eq 3 ]; then
## Phase 3
__POSTSCRIPT__
fi
