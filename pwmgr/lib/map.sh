# insertPair(map, pair)
map_insertPair() {
  if [ "${1}" == "" ]; then
    echo -n ${2}
  else
    echo -n ${1}"|"${2}
  fi
}

# getPairByKey(map, key)
map_getPairByKey() {
  local key ret
  key=${2}
  callback() {
    if [ "`pair_getKey ${1}`" == "${key}" ]; then
      ret=${1}
    fi
  }
  str_for_each ${1} "|" callback
  echo -n ${ret}
}

# removePairByKey(map, key)
map_removePairByKey() {
  local left pair ret
	left=${1}
  ret=""
	while true; do
		pair=${left%%"|"*}
    if [ ! "`pair_getKey ${pair}`" == "${2}" ]; then
      ret=`map_insertPair "${ret}" "${pair}"`
    fi
		if [ "${left}" == "${left#*"|"}" ]; then
			break
		else
			left=${left#*"|"}
		fi
	done
  echo -n ${ret}
}

# updatePair(map, pair)
map_updatePair() {
  local key ret
  key=`pair_getKey ${2}`
  ret=`map_removePairByKey "${1}" "${key}"`
  ret=`map_insertPair "${ret}" "${2}"`
  echo -n ${ret}
}

# foreach(map, callback)
map_foreach() {
  local left
	left=${1}
  while true; do
		${2} "${left%%"|"*}"
		if [ "${left}" == "${left#*"|"}" ]; then
			break
		else
			left=${left#*"|"}
		fi
	done
}
