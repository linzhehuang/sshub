#global variables
g_file="${1}"
g_pwd=$( cd `dirname "${0}"`;pwd )

#---basic functions---#
function fread() {
  #params:offset size
  echo `hexdump -ve '/'${2}' "%01d "' -s "${1}" -n "${2}" "${g_file}"`
}

function get_bit() {
  #params:byte offset
  echo "$(( (${1} >> ${2} )&1 ))"
}
function get_half_byte() {
  #params:byte offset
  echo "$(( (${1} >> (4*${2}) )&0xf ))"
}
function get_byte() {
  #params:offset
  echo "${g_raw}"|cut -d " " -f "$(( ${1}+1 ))"
}
function get_short() {
  #params:offset
  local low high
  low=`get_byte "${1}"`
  high=`get_byte "$(( ${1}+1 ))"`
  echo "$(( (high << 8) + low ))"
}
function get_long() {
  #params:offset
  local low high
  low=`get_short "${1}"`
  high=`get_short "$(( ${1}+2 ))"`
  echo "$(( (high << 16) + low ))"
}
#---prepare functions---#
function read_all() {
  #params:(none)
  g_raw=`hexdump -ve '/1 "%01d "' "${g_file}"`
}
function read_header() {
  g_bfSize=`get_long 2`
  g_bfOffBits=`get_long 10`
}
function read_info_header() {
  g_biSize=`get_long 14`
  g_biWidth=`get_long 18`
  g_biHeight=`get_long 22`
  g_biBitCount=`get_short 28`
  g_biCompression=`get_long 30`
  g_biSizeImage=`get_long 34`
}
function read_color_table() {
  local offset size end i color
  offset=$(( g_biSize+14 ))
  size=$(( g_bfOffBits-g_biSize-14 ))
  end=$(( offset+size-1 ))
  for i in `seq $offset $end`;do
    color=`get_byte "${i}"`
    g_colors="${g_colors} ${color}"
  done
}
function index_to_color() {
  local offset blue green red
  offset="$(( ${1}*4+1 ))"
  blue=`echo "${g_colors}"|cut -d " " -f "$(( offset+1 ))"`
  green=`echo "${g_colors}"|cut -d " " -f "$(( offset+2 ))"`
  red=`echo "${g_colors}"|cut -d " " -f "$(( offset+3 ))"`
  echo "${blue} ${green} ${red}"
}

function one_bit_mode() {
  local i byte pixel line
  for i in `seq 0 $(( g_biWidth-1 ))`;do
    byte=`get_byte "$(( ${1}+i/8 ))"`
    pixel=`get_bit "${byte}" "$(( 7-i%8 ))"`
    pixel=`index_to_color "${pixel}"`
    line="${line} ${pixel}"
  done
  echo "${line}"
}
function four_bits_mode() {
  local i byte pixel line
  for i in `seq 0 $(( g_biWidth-1 ))`;do
    byte=`get_byte "$(( ${1}+i/2 ))"`
    pixel=`get_half_byte "${byte}" "$(( i%2 ))"`
    pixel=`index_to_color "${pixel}"`
    line="${line} ${pixel}"
  done
  echo "${line}"
}
function read_line() {
  local line
  if [ "${g_biBitCount}" -eq 1 ];then
    line=`one_bit_mode "${1}"`
  elif [ "${g_biBitCount}" -eq 4 ];then
    line=`four_bits_mode "${1}"`
  fi
  echo "${line}"
}
function read_data() {
  local i line size
  size=$(( (g_biWidth*g_biBitCount+31)/32*4 ));
  echo 'Total line = '${g_biHeight}
  for i in `seq 0 $(( g_biHeight-1 ))`;do
    echo 'Current line  = '${i}
    line=`read_line "$(( g_bfOffBits+size*i ))"`
    g_data="${line}${g_data}"
  done
}

#
function main() {
  echo -n 'Parse header ...'
  read_all
  read_header
  read_info_header
  echo 'Done'
  #
  echo 'Parse data ...'
  if [ "${g_biBitCount}" -lt 16 ];then
    read_color_table
  fi
  read_data
  echo 'Done'
  echo 'Rendering ...'
  sh "${g_pwd}/draw-bmp.sh" "${g_data}" "${g_biWidth}" "${g_biHeight}"
}
#
main
