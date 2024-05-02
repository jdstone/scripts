#!/usr/bin/env bash

#title            :create_movie_dirs.sh
#description      :This script moves movie files organized in a single directory to their own directory.
#author           :J.D. Stone
#date             :20240502
#version          :1.0


i=0

## SET YOUR MOVIE DIRECTORY
movie_root=~/movie_directory
## SET A LIMIT FOR HOW MANY FILES YOU WANT TO PROCESS PER RUN
directory_file_count_limit=15

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

echo $(echo !==== Creating the new movie directory structure and copying movies to their new location ====! | tr [:lower:] [:upper:])
echo
echo


for file in *.mkv *.mp4 *.avi; do
  base_filename=$file

  if [ $i = $directory_file_count_limit ]; then break; fi

  if ! ( [ "$base_filename" = "*.mkv" ] || [ "$base_filename" = "*.mp4" ] || [ "$base_filename" = "*.avi" ] ); then
    movie_root_filename=$(echo $base_filename | sed 's/\.\///' | cut -d "(" -f 1 | sed 's/\.$//')
    movie_titlename=$(echo $movie_root_filename | sed 's/\./ /g')
    movie_titlename_upper=$(echo $movie_titlename | tr [:lower:] [:upper:])
    file_name_wo_ext=${base_filename%.*}
    echo ===========================================================================
    echo "Processing $movie_titlename_upper"
    echo ===========================================================================
    echo

    echo "    Creating movie directory..."
    mkdir "$movie_titlename"
    echo
    echo "    Moving all associated movie files to movie directory..."
    mv "$file_name_wo_ext"* "$movie_titlename"/
    echo
    echo
    i=$((i+1))
  fi
done

echo

if [ $i -gt 1 ] || [ $i -eq 0 ]; then
  echo "$i movies were processed." && printf "\n\n"
elif [ $i -eq 1 ]; then
  echo "$i movie was processed." && printf "\n\n"
fi

