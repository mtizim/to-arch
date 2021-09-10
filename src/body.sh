#!/usr/bin/env bash
# https://www.gnu.org/licenses/old-licenses/gpl-2.0.html, from mariuszkurek/convert.sh
# $1 - Phase

if [ "$(id -u)" -eq 0 ] && [ "$1" -ne 2 ]; then
	printf "This script should not be run as root.\nPermissions will be eleveted automatically for system-wide tasks.\n"
	exit 1
fi

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
