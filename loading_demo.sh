#-- pipe operations --#
create_pipe () {
  PIPE_FILE="${HOME}/$$.pipe"
  if [ -f "${PIPE_FILE}" ];then
    rm "${PIPE_FILE}"
  fi
  # create pipe file
  touch "${PIPE_FILE}"
}
destory_pipe () {
  if [ -f "${PIPE_FILE}" ];then
    rm "${PIPE_FILE}"
  else
    exit
  fi
}
#-- loop function --#
loop () {
  #-- stop or not--#
  if [ "`cat ${PIPE_FILE}`" = "stop" ];then
    destory_pipe
    return
  fi
  #-- draw loading image --#
  local symbol
  for symbol in '-' '\\' '|' '/';do
    clear
    echo -e "Loading...    \e[31m${symbol}\e[0m"
    sleep 0.1
  done
  loop
  wait
}
#-- main function --#
main () {
  #ls -R / 2> /dev/null 1>/dev/null
  sleep 10
  echo -n "stop" > $PIPE_FILE
  wait
}

create_pipe

loop &
main &
wait