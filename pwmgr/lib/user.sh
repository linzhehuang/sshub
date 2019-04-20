# new(username, password)
user_new() {
  echo -n ${1}","${2}
}

# getUsername(user)
user_getUsername() {
  echo -n ${1%,*}
}

# getPassword(user)
user_getPassword() {
  echo -n ${1#*,}
}
