#!/bin/bash

set -e
set -u
#set -x

if ! (type storcli &> /dev/null); then
 echo "storcli is not installed"
 exit 1
else
 STORCLI=$(which storcli)
fi

array=()
IFS="
"

CTRLINSTALLED=$($STORCLI show | grep "Number of Controllers" | awk '{print $5}')
CTRLCOUNT=$((CTRLINSTALLED-1))

while (( "$CTRLCOUNT" < "$CTRLINSTALLED" ));
 do
  while read line
  do
   if grep -qv Optl <<< "$line";
    then
     array+=" Failure on: Controller $CTRLCOUNT $line"
    else
     array[0]="1"
   fi
 done < <($STORCLI /c$CTRLCOUNT /vall show | grep RAID | tr -s ' ' | cut -d " " -f-3)
(( CTRLCOUNT = CTRLCOUNT + 1 ))
done

if [ ${#array[0]} -eq 1 ]; then
 echo 0
 exit 0
else
 printf '%s\n' "${array[@]}" | cut -c 2-
 exit 0
fi
