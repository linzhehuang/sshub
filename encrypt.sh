# d2h(decimal)
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

# left_fill_zero(src, length)
left_fill_zero() {
  local l i ret
  ret=${1}
  l=$(( ${2} - ${#1} ))
  for i in `seq 1 ${l}`;do
    ret="0"${ret}
  done
  echo -n ${ret}
}

# operator(src, md5)
operator() {
  local ret i t
  ret=""
  for i in `seq 0 2 $(( ${#1} - 1 ))`; do
    t=$(( 16#${1:${i}:2} ^ 16#${2:${i}:2} ))
    t=`d2h t`
    t=`left_fill_zero ${t} 2`
    ret=${ret}"\x"${t}
  done
  echo -n ${ret}
}

# get_md5(password)
get_md5() {
  local ret
  ret=`echo -n ${1}|md5sum`
  echo -n ${ret%  -*}
}

# str_for_each(str, split, callback)
str_for_each () {
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

# read_file(file, split, bytes)
read_file() {
  local ret
  ret=`hexdump -v -e ${3}'/1 "%02x" "'${2}'"' ${1}`
  ret=${ret:0:$(( ${#ret} - 1))}
  echo -n ${ret}
}

# write_file(data, file)
write_file() {
  echo -ne ${1} > ${2}
}

# process_file(intput_file, output_file, password)
process_file() {
  local SPLIT md5 output input
  # task(str)
  task() {
    output=${output}`operator ${1} ${md5}`
  }
  SPLIT="|"
  md5=`get_md5 ${3}`
  output=""
  intput=`read_file ${1} ${SPLIT} $(( ${#md5} / 2 ))`

  str_for_each ${intput} ${SPLIT} task
  write_file ${output} ${2}
}

process_file ${1} ${2} ${3}
