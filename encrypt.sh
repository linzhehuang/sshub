d2h() {
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

encrypt_field() {
  local src i ret t
  ret=""
  src=${1}
  for i in `seq 0 2 $(( ${#1} - 1 ))`; do
    t=$(( 16#${src:${i}:2} ^ 16#${md5:${i}:2} ))
    t=`d2h t`
    t=`left_fill_zero ${t} 2`
    ret=${ret}"\x"${t}
  done
  output=${output}${ret}
}

decrypt_field() {
  local dsr i ret t
  ret=""
  dst=${1}
  for i in `seq 0 2 $(( ${#1} - 1 ))`; do
    t=$(( 16#${dst:${i}:2} ^ 16#${md5:${i}:2} ))
    t=`d2h t`
    t=`left_fill_zero ${t} 2`
    ret=${ret}"\x"${t}
  done
  output=${output}${ret}
}

left_fill_zero() {
  local l i ret
  ret=${1}
  l=$(( ${2} - ${#1} ))
  for i in `seq 1 ${l}`;do
    ret="0"${ret}
  done
  echo -n ${ret}
}

str_split () {
	local cur left
	left=${1}
	while true; do
		${3} ${left%%${2}*}
		if [ "${left}" == "${left#*${2}}" ]; then
			break
		else
			left=${left#*${2}}
		fi
	done
}

read_file() {
  hexdump -e '16/1 "%02x" "|"' ${1}
}

encrypt() {
  local input
  input=`read_file ${1}`
  str_split "${input}" "|" encrypt_field
  echo -ne "${output}" > ${2}
}

decrypt() {
  local input
  input=`read_file ${1}`
  str_split "${input}" "|" decrypt_field
  echo -ne "${output}" > ${2}
}

output=""

if [ ${1} == "-d" ]; then
  password="${4}"
  md5=`echo -n "${password}"|md5sum`
  md5=${md5%  -*}
  decrypt ${2} ${3}
else
  password="${3}"
  md5=`echo -n "${password}"|md5sum`
  md5=${md5%  -*}
  encrypt ${1} ${2}
fi
