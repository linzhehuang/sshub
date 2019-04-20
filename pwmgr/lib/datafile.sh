dataFile_prefix="PWMGR"
dataFile_tmpFile="tmp"

# create(password, file)
dataFile_create() {
  local tmp
  echo -n `get_md5 ${1}` > ${dataFile_tmpFile}
  process_file ${dataFile_tmpFile} ${2} ${1}
  tmp=`cat ${2}`
  echo -n ${dataFile_prefix}${tmp} > ${2}
}

# read(password, file)
dataFile_read() {
  local ret tmp
  tmp=`cat ${2}`
  echo -n ${tmp:${#dataFile_prefix}} > ${dataFile_tmpFile}
  process_file ${dataFile_tmpFile} ${dataFile_tmpFile} ${1}
  ret=`cat ${dataFile_tmpFile}`
  echo -n ${ret}
}

# write(password, file, data)
dataFile_write() {
  local tmp
  echo -n "${3}" > ${dataFile_tmpFile}
  process_file ${dataFile_tmpFile} ${dataFile_tmpFile} ${1}
  tmp=`cat ${dataFile_tmpFile}`
  echo -n ${dataFile_prefix}${tmp} > ${2}
}

# verify(file)
dataFile_verify() {
  local tmp
  tmp=`cat ${1}`
  if [ "${tmp:0:${#dataFile_prefix}}" == "${dataFile_prefix}" ]; then
    echo -n "true"
  else
    echo -n "false"
  fi
}

# verifyPassword(data, password)
dataFile_verifyPassword() {
  local md5
  md5=`get_md5 ${2}`
  if [ "${1:0:${#md5}}" == "${md5}" ]; then
    echo -n "true"
  else
    echo -n "false"
  fi
}

# getMap(data, password)
dataFile_getMap() {
  local md5
  md5=`get_md5 ${2}`
  echo -n ${1:${#md5}}
}

# setMap(map, password)
dataFile_setMap() {
  local md5
  md5=`get_md5 ${2}`
  echo -n ${md5}${1}
}

# cleanup()
dataFile_cleanup() {
  if [ -e "${dataFile_tmpFile}" ]; then
    rm ${dataFile_tmpFile}
  fi
}
