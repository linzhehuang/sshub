d2h() {
  usage() {
    echo -e "Usage: d2h <num>\n"
    echo -e "Convert number decimal to hexadecimal.\n"
    echo -e "-h or -help\t Display help.\n"
  }
  #parse arguments
  if [ "${1}" == "" ];then
    echo -e "No input number!"
    usage
    return
  elif [ "${1}" == "-h" -o "${1}" == "--help" ];then
    usage
    return
  fi

  local d_num=${1} h_num= r_num=
  local nums="123456789abcdef"

  if [ $d_num == 0 ];then
    echo $d_num
    return
  fi
  while [ $d_num != 0 ];do
    r_num=$(( d_num % 16 ))
    if [ ${r_num} != 0 ];then
      h_num=${nums:$(( r_num - 1 )):1}${h_num}
    else
      h_num=0${h_num}
    fi
    d_num=$(( d_num / 16 ))
  done
  echo $h_num
}

ascii() {
  local i
  local chars="NUL|SOH|STX|ETX|EOT|ENQ|ACK|BEL|BS|HT|LF|VT|FF|CR|SO|SI|DLE|DC1|DC2|DC3|DC4|NAK|SYN|ETB|CAN|EM|SUB|ESC|FS|GS|RS|US|DEL|"
  echo -e "#Control Character#"
  echo -e "Ascii\tDec\tHex"

  for i in `seq 0 126`;do
    if [ $i == 32 ];then
      echo -e "\n#Display Character#"
      echo -e "Ascii\tDec\tHex"
    fi
    if [ $i -le  31 ];then
      tmp() {
        echo ${chars}|cut -d \| -f $(( $1+1 ))
      }
      echo -n `tmp $i`
    else
      echo -ne "\x`d2h ${i}`"
    fi
    echo -e "\t${i}\t`d2h ${i}`H"
  done
}

ascii
