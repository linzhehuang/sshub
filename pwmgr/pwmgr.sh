# POSIX

set -o errexit

. ./encrypt.sh
. ./datafile.sh

readonly _datafile="data.db"

# print_usage()
print_usage() {
  echo -e "Password Manager v0.0.1"
  echo -e ""
  echo -e "Usage: sh pwmgr.sh <password> <option> [...]"
  echo -e ""
  echo -e "  -a                             display all accounts"
  echo -e "  -s <site> <name> <password>    create/update account"
  echo -e "  -p <new_password>              update password"
  echo -e "  -d <site>                      delete account"
  echo -e ""
}

# print_all()
print_all() {
  print_line() {
    echo -ne "${1}\t\t"
    echo -ne "${2%,*}\t\t"
    echo -ne "${2#*,}\n"
  }
  echo -ne "SITE\t\tUSER\t\tPWD\n"
  echo -ne "-----------------------------------\n"
  foreach_values print_line
  echo ""
}

# set_site(site, user, password)
set_site() {
  set_value "${1}" "${2},${3}"
}

# delete_site(site)
delete_site() {
  delete_value "${1}"
}

# pwmgr(password,option, ...)
pwmgr() {
  if [ -z "${1}" ]; then
    print_usage
    return 1
  elif [ "${1}" = "-h" ]; then
    print_usage
    return 0
  fi

  if [ -z "${2}" ]; then
    print_usage
    return 1
  fi

  if [ ! -e "${_datafile}" ]; then
    echo -e "warning: datafile not exists"
    create_datafile "${_datafile}" "${1}"
    echo -e "create datafile success"
  fi



  open_datafile "${_datafile}" "${1}"
  case "${2}" in
    "-a" )
      print_all
      ;;
    "-s" )
      set_site "${3}" "${4}" "${5}"
      ;;
    "-p" )
      set_password "${3}"
      ;;
    "-d" )
      delete_site "${3}"
      ;;
    * )
      print_usage
      return 1
      ;;
  esac
  close_datafile
  return 0
}

pwmgr ${@}
