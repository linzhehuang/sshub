#!/bin/sh

show_all_path () {
  local i=1
  while true;do
    var=`echo $PATH|cut -d ':' -f $i`
    if [ "${var}" == "" ];then
      break
    else
      echo -ne "${i}\t"
      echo "${var}"
    fi
    i=$(( i+1 ))
  done
}

show_all_path
