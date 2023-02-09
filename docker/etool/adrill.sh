#!/bin/bash

set -e
err_report() {
  echo "$APPI, error on line $1"
}
trap 'err_report $LINENO' ERR

die() { echo "$*" 1>&2 ; exit 1; }


# Convert $DRILL -file to $FLIP file
if [ $# != 1 ]; then
    die "Usage $0 PTH_FILE"
fi    

PTH_DRILL=$1; shift

pth_file=$(basename $PTH_DRILL)
ext="${pth_file##*.}"
stem="${pth_file%.*}"
ALIGN_DRILL=$(dirname $PTH_DRILL)/$stem-ALIGN.$ext
DEPTH="Z-4.5000"
echo PTH_DRILL=$PTH_DRILL, ALIGN_DRILL=$ALIGN_DRILL

# Modify drilling dept

awk -v depth="$DEPTH" -v input=$(basename $PTH_DRILL) -v output=$(basename $ALIGN_DRILL) '

# start FST 
# - drilling
#   0 : process non -drilling actions
#   1 : G81 seen && processed
#   2 : drilling actions

BEGIN {
    print "( Drill file "  input  " converted to alignement drilling file "  output " )"
    print "( Drilling actions along X=0 retained, and drill to depth " depth " )"
}

drilling==0 && /G81/ { 
      drilling=1
      print "( " $0 " )"
      pat=sprintf( "\\1 %s \\3", depth )
      r=gensub( /(.*)(Z[^ ]*)(.*)/, pat, "g")
      # r=gensub( /(.*)(Z[^ ]*)(.*)/, "\\1 -Z4.5000 \\3", "g")
      print r

}
/G80/ { 
      drilling=0
}

# FST output
drilling==0 {
   # non -drilling actions -> output
   print $0
}
drilling==2 && ! /X-?0\.00.*/ {
  # reject drillings outsize X0.00
  print "(  " $0 " )"
}
drilling==2 && /X-?0\.00.*/ {
   # drilling on Y-axis --> output
   print $0
}
drilling==1 {
   drilling=2
}
' $PTH_DRILL  > $ALIGN_DRILL
