#!/bin/sh

# Use 'source ${your_script_path}/shell_JSON.sh' in your shell script.

shell_JSON_setContent() {
  shell_JSON_content="${1}"
  shell_JSON_formatContent
  shell_JSON_parseContent
}

shell_JSON_formatContent() {
  # The token values.
  local STRING_BEGIN=1 STRING_END=-1
  local token="${STRING_END}"
  # Delete '{' and '}' .
  local content="${shell_JSON_content}"
  content="${content#*\{*}"
  content="${content%*\}}"
  # Getting content's length.
  content_len="${#content}"
  # Clear 'shell_JSON_content'.
  shell_JSON_content=""

  # Delete extra space and LF.
  local i char
  for i in `seq 0 $(( content_len-1 ))`;do
    char="${content:i:1}"
    # Changing token if necessary.
    if [ "${char}" == '"' ];then
      token="$(( -token ))"
    fi
    # Converting.
    if [ "${token}" == "${STRING_END}" ];then
      case "${char}" in
        $' ')
          char=$'\0' ;;
        $'\012')
          char=$'\0' ;;
      esac
    fi
    # Buliding new content.
    shell_JSON_content="${shell_JSON_content}${char}"
  done

  # Output formated content. Use for debug
  #echo -ne "${shell_JSON_content}"
}

shell_JSON_parseContent() {
  # The tokens.
  local \
  STRING_START=1 STRING_END=1 \
  OBJECT_START=2 OBJECT_END=-2 \
  ARRAY_START=3  ARRAY_END=-3  \
  local token=0  # Set the inital token(0).
  changeToken() {
    if [ $token -le 0 ]; then
      case $1 in
        '"' )
          token=$STRING_START ;;
        '{' )
         token=$OBJECT_START ;;
        '[' )
          token=$ARRAY_START ;;
      esac
    else
      case $1 in
        '"' )
          if [ $token -ne $OBJECT_START -a $token -ne $ARRAY_START ]; then
            token=$(( -token ))
          fi ;;
        '}' )
          if [ $token -ne $STRING_START -a $token -ne $ARRAY_START ]; then
            token=$(( -token ))
          fi ;;
        ']' )
          if [ $token -ne $STRING_START -a $token -ne $OBJECT_START ]; then
            token=$(( -token ))
          fi ;;
      esac
    fi
  }

  # Converting.
  local content="${shell_JSON_content}"
  local content_len=${#content}
  # Clear 'shell_JSON_content'.
  shell_JSON_content=""

  local i char
  for i in `seq 0 $(( content_len-1 ))`;do
    char="${content:$i:1}"
    changeToken "$char"
    # Converting , to \054
    if [ "${char}" == "," -a ${token} -gt 0 ]; then
      char='\0054'
    fi
    # Buliding new content.
    shell_JSON_content="${shell_JSON_content}${char}"
  done

  # Output formated content. Use for debug
  #echo -n "${shell_JSON_content}"
}
shell_JSON_getValueByKey() {
  local key='"'${1}'"'
  local key_tmp pair i=1
  while true; do
    pair=`echo -n "${shell_JSON_content}"|cut -d "," -f ${i}`
    i=$(( i+1 ))
    if [ "${pair}" == "" ];then
      break
    fi

    key_tmp="${pair%%:*}"
    if [ ${key_tmp} == ${key} ];then
      echo -en "${pair#*:}"
    fi
  done
}
