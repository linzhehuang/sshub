#--basic functions--#
function display_help() {
  echo -e "Usage: urlcnv [-D|E] -[type [tfq]] [URL]\n
Encode or decode the Thunder/FlashGet/QQCyclone url.
Operation:\n
\t-D\tDecode the url.(Default)
\t-E\tEncode the url.\n
\t-type\tThe type of url.
\t t\tThunder(Default)
\t f\tFlashGet
\t q\tQQ Cyclone
  "
  exit
}
function judge_type() {
  case $1 in
    "t")
    g_url_type=1
    ;;
    "f") 
    g_url_type=2
    ;;
    "q")
    g_url_type=3
    ;;
    *)
    display_help
    ;;
  esac
}

#--decode functions--#
function decode() {
  echo -n "${1}"|base64 -d
}
function decode_t() {
  g_url="${g_url#thunder://}"
  g_url=`decode "${g_url}"`
  g_url="${g_url#AA}"
  g_url="${g_url%ZZ}"
  echo -n "${g_url}"
}
function decode_f() {
  g_url="${g_url#flashget://}"
  g_url="${g_url%&*}"
  g_url=`decode "${g_url}"`
  g_url="${g_url#[FLASHGET]}"
  g_url="${g_url%[FLASHGET]}"
  echo -n "${g_url}"
}
function decode_q() {
  g_url="${g_url#qqdl://}"
  g_url=`decode "${g_url}"`
  echo -n "${g_url}"
}

#--encode functions--#
function encode() {
  echo -n "${1}"|base64
}
function encode_t() {
  g_url="AA${g_url}ZZ"
  g_url=`encode "${g_url}"`
  g_url="thunder://${g_url}"
  echo -n "${g_url}"
}
function encode_f() {
  g_url="[FLASHGET]${g_url}[FLASHGET]"
  g_url=`encode "${g_url}"`
  g_url="flashget://${g_url}"
  echo -n "${g_url}"
}
function encode_q() {
  g_url=`encode "${g_url}"`
  g_url="qqdl://${g_url}"
  echo -n "${g_url}"
}

#--process the arguments--#
g_cnv_flag=1  #(decode/endcode)--(1/2)
g_url_type=1  #(Thunder/FlashGet/QQCyclone)--(1/2/3)
g_is_type=0  #judge the type argument
g_url=""

for arg in $*;do
  if [ "${g_is_type}" -eq "1" ];then
    judge_type "$arg"
    g_is_type=0
  else
    if [ "${arg}" == "-type" ];then
      g_is_type=1
    elif [ "${arg}" == "-D" ];then
      g_cnv_flag=1
    elif [ "${arg}" == "-E" ];then
      g_cnv_flag=2
    else
      if [ "${g_url}" == "" ];then
        g_url="${arg}"
      else
        display_help
      fi
    fi
  fi
done
if [ "${g_url}" == "" ];then
  display_help
fi
unset g_is_type arg
#--
if [ "${g_cnv_flag}" == 1 ];then
  case "${g_url_type}" in
    "1")
    decode_t "${g_url}"
    ;;
    "2") 
    decode_f "${g_url}"
    ;;
    "3")
    decode_q "${g_url}"
    ;;
  esac
else
  case "${g_url_type}" in
    "1")
    encode_t "${g_url}"
    ;;
    "2") 
    encode_f "${g_url}"
    ;;
    "3")
    encode_q "${g_url}"
    ;;
  esac
fi