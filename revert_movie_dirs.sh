#!/usr/bin/env bash

#title            :revert_movie_dirs.sh
#description      :This script moves movie files organized in their own directory to a single directory.
#                  Reverts process completed by create_movie_dirs.sh.
#author           :J.D. Stone
#date             :20240502
#version          :1.0


i=0
j=0

## SET YOUR MOVIE DIRECTORY
movie_root=~/movie_directory

cd "$movie_root" || exit 1

RED='\033[0;31m'
# No Color
NC='\033[0m'

echo
printf "${RED}!!!!  $(pwd) -- Are you sure you want to continue with this movie directory?  !!!!${NC}\n"

read -p "Press Ctrl-C to exit or Enter to continue"
echo
read -p "Are you sure you pressed the correct key (Ctrl-C to exit or Enter to continue)?"
printf "\n\n"

echo $(echo !==== Reverting creation of individual movie directory changes ====! | tr [:lower:] [:upper:])
echo
echo


find . -maxdepth 1 ! -path . -type d | sed 's/.\///' | while read -r directory; do
  movie_files=()
  movie_path="$(pwd)/$directory"
  new_movie_files=()
  cleanup_msg=$(echo "^^^^  Files could not be verified! No cleanup wiill be performed! ^^^^" | tr [:lower:] [:upper:])

  for file_w_path in "$movie_path/"*; do
    movie_path_wo_file_ext=$(echo $file_w_path | sed 's/\.\///' | cut -d "(" -f 1 | sed 's/\.$//')
    file_name_wo_ext=$(basename "$movie_path_wo_file_ext")
    movie_titlename=$(echo $file_name_wo_ext | sed 's/\./ /g')
    movie_titlename_upper=$(echo $movie_titlename | tr [:lower:] [:upper:])
    base_filename=$(basename "$file_w_path")
    new_movie_path="$movie_path/$file_name_wo_ext"
  done

  echo ===========================================================================
  echo "Processing $movie_titlename_upper"
  echo "in \"$movie_path\""
  echo ===========================================================================
  echo

  for file_w_path in "$movie_path/"*; do
    base_filename=$(basename "$file_w_path")
    movie_files+=("$base_filename")
    echo "    Processing \"$base_filename\"..."
  done

  echo
  echo "    Copying all associated movie files back to the $movie_root..."
  echo
  cp "$(pwd)/$directory/"* .
  echo "    Verifying files were successfully copied..."
  echo

  for file_w_path in "$new_movie_path"*; do
    new_base_filename=$(basename "$file_w_path")
    new_movie_files+=("$new_base_filename")
  done

  match=0

  for i in "${movie_files[@]}"; do
    for j in "${new_movie_files[@]}"; do
      if [ "$i" == "$j" ]; then
        ((match+=1))
      fi
    done
  done

  if [ "${#movie_files[@]}" -eq "$match" ]; then
    echo "    Files were successfully verified!"
    echo
    echo "    Cleaning up & deleting the movie directory..."
    echo
    echo
    rm -r "$(pwd)/$directory/"
  else
    echo
    echo -e "    ${RED}$cleanup_msg${NC}"
    echo
    echo
  fi
done

echo "Process is complete."
echo
echo

