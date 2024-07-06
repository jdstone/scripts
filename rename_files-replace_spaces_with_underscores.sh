#!/usr/bin/env bash

#title            :rename_files-replace_spaces_with_underscores.sh
#description      :Rename all files, replacing all spaces with underscores.
#author           :J.D. Stone
#usage            :Copy this script to the directory containing the files you want renamed and then run the script.


SCRIPT_FILENAME=$(basename "$0")

for file in *; do
  if [ "$file" != "${SCRIPT_FILENAME}" ]; then
    mv "$file" "$(echo "$file" | tr ' ' '_')"
  fi
done
