msgbox() {
  eval `resize`
  WIDTH=${2:-24}
  COLOR=${3:-41}
  function draw_blank() {
    local i
    for i in `seq 1 $1`;do
      echo -n " "
    done
  }
  function draw_line() {
    LENGTH=${#1}
    PADDING=$(( (WIDTH-LENGTH)/2 ))
    MARGIN=$(( (COLUMNS-WIDTH)/2 ))
    EXTRA=$(( WIDTH-(PADDING*2+LENGTH) ))
    #drawing
    draw_blank $MARGIN
    echo -ne "\e[$COLOR;37m"
    draw_blank $PADDING
    echo -ne $1
    draw_blank $(( PADDING+EXTRA ))
    echo -ne "\e[0m"
    draw_blank $MARGIN
    echo ""
    unset LENGTH PADDING MARGIN EXTRA
  }
  STR=${1}
  while [ "${#STR}" -gt "${WIDTH}" ];do
    draw_line "${STR:0:${WIDTH}}"
    STR="${STR:$(( WIDTH+1 ))}"
  done
  draw_line "${STR}"
  unset STR WIDTH COLOR
}

#msgbox $@

# Uncomment the following code.
# The screen will print the classic image “FBI WARNING” O(∩_∩)O .

# msgbox "FBI WARNING" 15 41
# msgbox "Federal law provides severe civil and criminal penalties for the unauthorized reproduction,distribution,or exhibition of copyrighted motion prictures(Title 17, United States Code, Sections 501 and 508). The federal bureau of Investigation investigate allegations of criminal copyright infringement." 45 40
# msgbox "(Title 17, United States Code, Section 506)" 45 40
