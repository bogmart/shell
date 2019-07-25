#!/bin/bash
for filename in  raw_output/*.txt  *.txt  ; do
  name=${filename##*/}
  name="${name%.*}"
  if [[ ${name} == *"_sort"* ]] ||  [[ -z "$name" ]]; then
     continue;
  fi
  echo "${filename}" 
  cat "${filename}" | sort -V | grep -E "debug|\[|0x" | sed 's/__/:/g' > "${name}_sort.txt"
done
