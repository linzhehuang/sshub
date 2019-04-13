#!/bin/sh

str_split () {
	local cur left
	left=${1}
	while true; do
		echo ${left%%${2}*}
		if [ "${left}" == "${left#*${2}}" ]; then
			break
		else
			left=${left#*${2}}
		fi
	done
}

str_split "$@"
