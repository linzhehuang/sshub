#global variables
g_data="${1}"
g_biWidth="${2}"
g_biHeight="${3}"

#
function draw_grid() {
  echo -n "${1}"
}
function bgr_to_gray() {
  local gray=$(( ( $3*299 + $2*587 + $1*114 + 500 ) / 1000 ))
  echo -n "${gray}"
}
function bgr_to_color() {
  local gray index symbols symbol
  symbols=" .!1723046958@#"
  gray=`bgr_to_gray "${1}" "${2}" "${3}"`
  #convert gray to index
  index="$(( gray / 17 ))"
  index="$(( index?$(( index-1 )):0 ))"
  #echo -n $index
  symbol="${symbols:$index:1}"
  echo -n "${symbol}${symbol}"
}
#
function draw() {
  local i j offset color blue green red
  for i in `seq 0 $(( g_biHeight-1 ))`;do
    for j in `seq 0 $(( g_biWidth-1 ))`;do
      offset="$(( ( i * g_biWidth * 3 ) + ( j * 3 ) + 1 ))"
      blue=`echo "${g_data}"|cut -d " " -f $(( offset+1 ))`
      green=`echo "${g_data}"|cut -d " " -f $(( offset+2 ))`
      red=`echo "${g_data}"|cut -d " " -f $(( offset+3 ))`
      
      bgr_to_color "${blue}" "${green}" "${red}"
    done
    echo ""
  done
}

draw

