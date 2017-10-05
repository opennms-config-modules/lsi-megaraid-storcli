#!/bin/bash

set -e
set -u
#set -x

if ! (type storcli &> /dev/null); then
 echo "storcli is not installed"
 exit 0
else
 STORCLI=$(which storcli)
fi

array=()
IFS="
"

CTRLINSTALLED=$($STORCLI show | grep "Number of Controllers" | awk '{print $5}')
CTRLCOUNT=$((CTRLINSTALLED-1))

while (( "$CTRLCOUNT" < "$CTRLINSTALLED" )); do
 for t in $($STORCLI /c"$CTRLCOUNT"/eALL/sALL show all | grep -e '^Drive.*State :' | awk {'print $2'}); do
   if  [[ $($STORCLI "$t" show all | grep "Predictive Failure Count" | awk {'print $5'}) != 0 ]]; then
     array+=" Failure on $t;"
    else
     array[0]="1"
   fi
 done
(( CTRLCOUNT = CTRLCOUNT + 1 ))
done

if [ ${#array[0]} -eq 1 ]; then
 echo "0"
else
 printf '%s\n' "${array[@]}" | cut -c 2-
fi
