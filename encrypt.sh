# POSIX

# encrypt(input, output, password)
encrypt() {
  # read_file(file)
  # usage: eval data=$( read_file "file")
  read_file() {
    local _format='16/1 "%02x" " "'
    local data=$( hexdump -v -e "${_format}" "${1}" )
    local data_size=${#data}
    datasize=$(( data_size - 1 ))
    echo -n "(${data:0:${data_size}})"
  }

  # get_md5(value)
  get_md5() {
    local ret=$( echo -n "${1}"|md5sum )
    echo -n "${ret%  -*}"
  }

  local data md5 block block_size out_data
  local i l r
  md5=$( get_md5 "${3}" )
  out_data=""

  eval data=$( read_file "${1}") # read file as array
  for block in ${data[@]}; do
    block_size=${#block}
    for i in $( seq 0 2 $(( block_size - 1 )) ); do
      l="${block:${i}:2}"
      r="${md5:${i}:2}"
      l=$(( 16#${l} ^ 16#${r} ))

      out_data="${out_data}$( printf '\\x%02x' "${l}" )"
    done
  done

  # write data to file
  echo -ne "${out_data}" > "${2}"
}
