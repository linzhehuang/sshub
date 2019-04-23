# It is a batch file example , and also a shell script.
# It provides following functions to operate datafile:
#   set_account <site> <user> <password> # same as -s
#   delete_account <site>                # same as -d
#   print_all                            # same as -a
#   set_password <new_password>          # same as -p
#

# recommend using single quote to
# avoid the special characters effect
set_account 'site' 'user' '123'
print_all
delete_account 'site'
