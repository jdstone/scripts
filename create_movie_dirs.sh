#!/usr/bin/env bash

# create_movie_dirs.sh

#find . -type f \( -iname "*.mkv" -o -iname "*.mp4" \) | sed 's/\.\///' | cut -d "(" -f 1 | sed 's/\.$//' | sed 's/\./ /g'

i=0

####movie_root=/mnt/storage/videos/movies
movie_root=~/create_movie_directory_test
directory_file_count_limit=2

cd "$movie_root" || exit 1

RED='\033[0;31m'
# No Color
NC='\033[0m'

printf "${RED}!!!!  $(pwd) -- are you sure you want to continue with the current directory?  !!!!${NC}\n"
printf "${RED}!!!!  $movie_root -- are you sure you want to continue with the current movie_root?  !!!!${NC}\n\n"

read -p "Type Ctrl-c to exit or Enter to continue."
echo
read -p "Are you sure you pressed the correct key (Ctrl-c to exit or Enter to continue)?"
printf "\n\n"

echo $(echo !==== Creating the new movie folder structure and copying movies to their new location ====! | tr [:lower:] [:upper:])
echo
echo


for file in *.mkv *.mp4 *.avi; do
  movie_files=()
  movie_path="$(pwd)/$folder"
  new_movie_files=()
  cleanup_msg=$(echo "^^^^  Files could not be verified! No cleanup will be performed! ^^^^" | tr [:lower:] [:upper:])

  if [ $i = $directory_file_count_limit ]; then break; fi

  if ! ( [ "$file" = "*.mkv" ] || [ "$file" = "*.mp4" ] || [ "$file" = "*.avi" ] ); then
    movie_name=$(echo $file | sed 's/\.\///' | cut -d "(" -f 1 | sed 's/\.$//' | sed 's/\./ /g')
    file_name_wo_ext=${file%.*}
    folder_name=$(echo $file_name_wo_ext | sed 's/\./ /g')
    echo Movie Name: $movie_name
    echo File w/o extension: $file_name_wo_ext
    echo Folder name: $folder_name
    echo -- Creating movie directory...
    #mkdir "$movie_name"
    echo -- Moving all associated movie files to movie directory...
    #cp "$file_name_wo_ext"* "$movie_name"/
    echo
    i=$((i+1))
  fi
done
