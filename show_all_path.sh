#!/bin/sh

show_all_path () {
  local i=1
  while true;do
    var=`echo $PATH|cut -d ':' -f $i`
    i=$(( i+1 ))
    if [ "${var}" == "" ];then
      break
    else
      echo -ne "${i}\t"
      echo "${var}"
    fi
  done
}

show_all_path
