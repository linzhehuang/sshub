# POSIX

readonly _prefix='PWMGR'
readonly _buffer='buffer'
data=""
datafile=""
password=""
opened=0

# create_datafile(datafile, password)
create_datafile() {
  # get_md5(value)
  get_md5() {
    local ret=$( echo -n "${1}"|md5sum )
    echo -n "${ret%  -*}"
  }

  if [ -e "${1}" ]; then
    echo "create datafile failed: can't overwrite exist file." >&2
    return 1  # can't overwrite exist file
  fi

  if [ -z "${2}" ]; then
    echo "create datafile failed: empty password." >&2
    return 2
  fi

  echo -n "$( get_md5 "${2}" )()" > "${_buffer}"
  encrypt "${_buffer}" "${_buffer}" "${2}"
  echo -n "${_prefix}" > "${1}"

  # The hexdump on android doesn't support "\" character in format string,
  # therefore it uses "." character and then replace with "\\x".
  # Following two lines same as the code :
  # local temp=$( hexdump -v -e '1/1 "\\%02x" ""' "${_buffer}" )
  local temp=$( hexdump -v -e '1/1 ".%02x" ""' "${_buffer}" )
  temp="${temp//./\\x}"

  echo -ne "${temp}" >> "${1}"

  rm -f "${_buffer}"

  return 0  # success
}

# open(datafile, password)
open_datafile() {
  # get_md5(value)
  get_md5() {
    local ret=$( echo -n "${1}"|md5sum )
    echo -n "${ret%  -*}"
  }

  if [ ${opened} -eq 1 ]; then
    return 0
  fi

  local prefix_size=${#_prefix} prefix_cmp=""
  local temp=""

  temp=$( hexdump -v -e '1/1 ".%02x" ""' "${1}" )
  temp="${temp//./\\x}"
  prefix_cmp="${temp:0:$(( ${prefix_size}*4 ))}"

  if [ ! $( echo -ne "${prefix_cmp}" ) = "${_prefix}" ]; then
    echo "open datafile failed: not a data file." >&2
    return 1  # not a data file
  fi

  echo -ne "${temp:$(( ${prefix_size}*4 ))}" > "${_buffer}"
  encrypt "${_buffer}" "${_buffer}" "${2}"
  temp=$( cat "${_buffer}" )
  if [ ! "${temp:0:32}"  = $( get_md5 "${2}" ) ]; then
    rm -f "${_buffer}"
    echo "open datafile failed: bad password." >&2
    return 2  # bad password
  fi

  data="${temp:32}"
  eval data="${data}"  # convet string to array
  datafile="${1}"
  password="${2}"
  opened=1
  rm -f "${_buffer}"

  return 0  # success
}

# close()
close_datafile() {
  # get_md5(value)
  get_md5() {
    local ret=$( echo -n "${1}"|md5sum )
    echo -n "${ret%  -*}"
  }

  if [ ${opened} -eq 0 ]; then
    echo "close datafile failed: datafile do not opened." >&2
    return 1
  fi

  echo -n $( get_md5 "${password}" ) > "${_buffer}"
  echo -n "(${data[@]})" >> "${_buffer}"
  encrypt "${_buffer}" "${_buffer}" "${password}"
  echo -n "${_prefix}" > "${datafile}"

  local temp=$( hexdump -v -e '1/1 ".%02x" ""' "${_buffer}" )
  temp="${temp//./\\x}"
  echo -ne "${temp}" >> "${datafile}"
  # cat "${_buffer}" >> "${datafile}"

  data=""
  datafile=""
  password=""
  opened=0

  rm -f "${_buffer}"

  return 0  # success
}

# set_password(password)
set_password() {
  if [ ${opened} -eq 0 ]; then
    echo "set password failed: datafile do not opened." >&2
    return 1
  fi
  if [ -z "${1}" ]; then
    echo "set password failed: empty password." >&2
    return 2
  fi
  if [ "${1}" = "${password}" ]; then
    echo "set password failed: same password." >&2
    return 3
  fi
  password="${1}"
  return 0
}

# get_value(key)
get_value() {
  if [ ${opened} -eq 0 ]; then
    echo "get value failed: datafile do not opened." >&2
    return 1
  fi
  if [ -z "${1}" ]; then
    echo "get value failed: empty key." >&2
    return 2
  fi

  local pair=""
  for pair in ${data[@]}; do
    if [ "${pair%=*}" = "${1}" ]; then
      echo -n "${pair#*=}"  # return value
      return 0
    fi
  done

  echo -n 'nil' # return nil value

  return 0
}

# delete_value(key)
delete_value() {
  if [ ${opened} -eq 0 ]; then
    echo "delete value failed: datafile do not opened." >&2
    return 1
  fi
  if [ -z "${1}" ]; then
    echo "delete value failed: empty key." >&2
    return 2
  fi

  local pair="" i=0
  for pair in ${data[@]}; do
    if [ "${pair%=*}" = "${1}" ]; then
      unset data[${i}]  # delete value
      return 0
    fi
    i=$(( ${i} + 1 ))
  done

  return 0
}

# set_value(key, value)
set_value() {
  if [ ${opened} -eq 0 ]; then
    echo "set value failed: datafile do not opened." >&2
    return 1
  fi
  if [ -z "${1}" ]; then
    echo "set value failed: empty key." >&2
    return 2
  fi

  local pair="" i=0
  for pair in ${data[@]}; do
    if [ "${pair%=*}" = "${1}" ]; then
      data[${i}]="${1}=${2}" # update value
      return 0
    fi
    i=$(( ${i} + 1 ))
  done

  data[${i}]="${1}=${2}" # create new pair

  return 0
}

# foreach_values(callback)
foreach_values() {
  if [ ${opened} -eq 0 ]; then
    echo "foreach values failed: datafile do not opened." >&2
    return 1
  fi

  if [ -z "${1}" ]; then
    echo "foreach values failed: no callback function." >&2
    return 2
  fi

  local pair="" i=0
  for pair in ${data[@]}; do
    ${1} "${pair%=*}" "${pair#*=}" ${i}
    i=$(( ${i} + 1 ))
  done

  return 0
}
