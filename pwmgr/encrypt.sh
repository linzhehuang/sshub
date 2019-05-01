# POSIX

# encrypt(input, output, password)
encrypt() {
  # read_file(file)
  read_file() {
    local data=$( hexdump -v -e '1/1 "%02x" " "' "${1}" )
    echo -ne "${data:0:$(( ${#data} - 1 ))}"
  }

  # get_md5(value)
  get_md5() {
    local ret=$( echo -n "${1}"|md5sum )
    echo -n "${ret%  -*}"
  }

  local data md5 out_data
  md5=$( get_md5 "${3}" )
  out_data=""

  data=$( read_file "${1}" ) # read file
  out_data=$( echo -ne "${data}"|awk -v "md5=${md5}" '
  BEGIN {
    # preprocess md5
    for (i = 1; i < 32; i += 2) {
      num = "0x"substr(md5, i, 2);
      arr[int(i/2)+1] = num + 0;
    }
  }
  {
    data_size = split($0, data, " ");
    for (i = 1; i <= data_size; i++) {
      r = "0x"data[i]; r = r + 0;
      l = arr[(i-1)%16 + 1];

      #printf("%d %d\n", r, l);

      #ret = r xor l
      ret = 0;
  		bit = 0;
      while (l != 0 && r != 0) {
        t = ((l % 2) == (r % 2)) ? 0 : 1;
        ret = ret + (2^bit)*t;
        l = int(l / 2);
        r = int(r / 2);
        bit++;
      }
      while (l != 0) {
        t = ((l % 2) == 0) ? 0 : 1;
        ret = ret + (2^bit)*t;
        l = int(l / 2);
        bit++;
      }
      while (r != 0) {
        t = ((r % 2) == 0) ? 0 : 1;
        ret = ret + (2^bit)*t;
        r = int(r / 2);
        bit++;
      }
      printf("\\x%02x", ret);

    }
  }
  ' )

  # write data to file
  echo -ne "${out_data}" > "${2}"
}
