# new(key, value)
pair_new() {
  echo -n ${1}"="${2}
}

# getKey(pair)
pair_getKey() {
  echo -n ${1%=*}
}

# getValue(pair)
pair_getValue() {
  echo -n ${1#*=}
}
