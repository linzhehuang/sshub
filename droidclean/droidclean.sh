#options
DEFAULT_RULE="
*log,f *log.txt,f
*cache*,f *cache*,d
*tmp,f *tmp,d
*temp,f *temp,d
"
DAYS=2
CMDS="dirname pwd find xargs awk rmdir"
STORAGE_PATH=""
BEFORE_SIZE=""
AFTER_SIZE=""

#log system
log() {
  local color prefix
  #--judge log type--#
  case "${1}" in
    "1") prefix="Err";color=31 ;;
    "2") prefix="Msg";color=32 ;;
    "3") prefix="Warn";color=33 ;;
  esac
  #--add log--#
  LOGS="${LOGS}\e[${color}m${prefix}:\e[0m${2}\n"
  #--print logs--#
  clear;echo -ne "${LOGS}"
}
#abort the script
abort() {
  echo -e "\033[41;37m---Abort---\033[0m"
  exit
}
#find storage path
find_storage() {
  local basename key_dir power name list max i
  basename=$(cd `dirname $0`;pwd)
  key_dir="Android DCIM Download tencent"
  #list probable path
  while [ "${basename}" != "" ]
  do
    power=0
    for name in $key_dir
    do
      if [ -d "${basename}/${name}" ];then
        power=$(( power+1 ))
      fi
    done
    list="${list} ${power},${basename}"
    basename=${basename%/*}
  done
  #select path from list
  max=0
  for i in ${list};do
    if [ ${i%,*} -ge "${max}" ];then
      max=${i%,*}
      STORAGE_PATH=${i#*,}
    fi
  done
}
#check if the command exist
check() {
  local i result
  for i in ${CMDS};do
    result=`which "${i}"`
    if [ -z "${result}" ];then
      log 1 "Command '${i}' not found!"
      abort
    fi
  done
}
#clean all rubbish according to RULE
clean_all() {
  local i
  for i in ${RULE};do
    log 2 "Clean '${i}' ..."
    find ${STORAGE_PATH}/ -iname "${i%,*}" -type "${i#*,}" 2>/dev/null |xargs rm -rf
  done
}
clean_empty_dir() {
  log 2 "Clean empty directory ..."
  find ${STORAGE_PATH}/ -iname "*" -type d 2>/dev/null |xargs rmdir -p >/dev/null 2>/dev/null
}
clean_wechat() {
  local wechat_path i wechat_user sns_path
  wechat_path="${STORAGE_PATH}/tencent/MicroMsg"
  if [ ! -d "${wechat_path}" ];then
    log 3 "Wechat path not found!"
    unset wechat_path
    return
  fi
  #find wechat user path
  key_dir="emoji favorite image2 sns"
  for i in ${key_dir};do
    wechat_user=`find "${wechat_path}" -name "${i}"`
    if [ -n "${wechat_user}" ];then
      wechat_user=${wechat_user%/*}
      break
    fi
  done
  #clean sns
  sns_path="${wechat_user}/sns"
  if [ ! -d "${sns_path}" ];then
    log 3 "Wechat sns path not found!"
  else
    log 2 "Clean wechat sns ..."
    find "${sns_path}/" -mtime +${DAYS} -type f|xargs rm -rf
  fi
}
#
get_storarge_size() {
  df 2>/dev/null|grep /data/media|awk '{ print $4 }'
}
#
load_rule_conf() {
  local basename conf_file
  basename=$(cd `dirname $0`;pwd)
  conf_file="${basename}/rule.conf"
  if [ -f "${conf_file}" ];then
    log 2 "Load 'rule.conf' file ..."
    source "${conf_file}"
  else
    log 3 "File 'rule.conf' not found!"
    log 2 "Using default rule."
    RULE="${DEFAULT_RULE}"
  fi
}

#
log 2 "Prepare ..."
check

BEFORE_SIZE=`get_storarge_size`
find_storage
log 2 "Before $(( BEFORE_SIZE /1024 ))MB."

load_rule_conf
clean_all
clean_wechat
clean_empty_dir

AFTER_SIZE=`get_storarge_size`
log 2 "After $(( AFTER_SIZE/1024 ))MB."

CLEANED_SIZE=$(( ($AFTER_SIZE - $BEFORE_SIZE)/1024 ))
log 2 "Clean ${CLEANED_SIZE}MB rubbish."
log 2 "Clean finished."

