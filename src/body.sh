#!/usr/bin/env bash
# From mariuszkurek/convert.sh
# $1 - Phase

if [ "$(id -u)" == "0" ] && [ "$1" != "2" ]; then
	printf "This script should not be run as root.\nPermissions will be elevated automatically for system-wide tasks.\n"
	exit 1
fi
# Bash pipes commands parallelly on sync, so this exits every pipe running in the shell if running as root.
[ $? == 1 ] && exit 1;

if [ -z "$1" ]; then
	"$0" 1
	sudo "$0" 2
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
