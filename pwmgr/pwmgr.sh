source ./lib/datafile.sh
source ./lib/encrypt.sh
source ./lib/map.sh
source ./lib/pair.sh
source ./lib/user.sh

store_file="./store"
password="${1}"
operator="${2}"

pair_key=""
user_username=""
user_password=""


if [ "${password}" == "" ]; then
  echo "Password empty." >&2
  exit 1
fi

# insert()
insert() {
  local map pair user
  user=`user_new ${user_username} ${user_password}`
  pair=`pair_new ${pair_key} ${user}`
  map=`dataFile_getMap ${data} ${password}`
  map=`map_insertPair "${map}" "${pair}"`
  data=`dataFile_setMap ${map} ${password}`
  dataFile_write ${password} ${store_file} ${data}
}

# delete()
delete() {
  local map
  map=`dataFile_getMap ${data} ${password}`
  map=`map_removePairByKey "${map}" "${pair_key}"`
  data=`dataFile_setMap "${map}" "${password}"`
  dataFile_write "${password}" "${store_file}" "${data}"
}

# dispaly_all()
dispaly_all() {
  callback() {
    local value
    value=`pair_getValue ${1}`
    echo -ne `pair_getKey ${1}`"\t\t"
    echo -ne `user_getUsername ${value}`"\t\t"
    echo -ne `user_getPassword ${value}`"\n"
  }
  local map
  map=`dataFile_getMap ${data} ${password}`
  echo -e "SITE\t\tUSER\t\tPWD"
  map_foreach ${map} callback
}

case "${operator}" in
  "-c")
    if [ -e "${store_file}" ]; then
      echo "File exists:"${store_file} >&2
    else
      dataFile_create ${password} ${store_file}
    fi
    exit 1
    ;;
esac

if [ ! -e "${store_file}" ]; then
  echo "File don't exists:"${store_file} >&2
  exit 1
fi

if [ "`dataFile_verify ${store_file}`" == "true" ]; then
  data=`dataFile_read ${password} ${store_file}`
  if [ "`dataFile_verifyPassword ${data} ${password}`" == "true" ]; then
    case "${operator}" in
      "-i") # insert site username password
        pair_key="${3}"
        user_username="${4}"
        user_password="${5}"
        insert ;;
      "-d")
        pair_key="${3}"
        delete ;;
      "-all")
        dispaly_all ;;
      "")
        dispaly_all ;;
    esac
  else
    echo "Incorrect password:"${password} >&2
  fi
else
  echo "Not a data file:"${store_file} >&2
fi

dataFile_cleanup
