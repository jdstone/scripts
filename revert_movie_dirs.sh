#!/usr/bin/env bash

# revert_movie_dirs.sh

#find . -type f \( -iname "*.mkv" -o -iname "*.mp4" \) | sed 's/.\///' | cut -d "(" -f 1 | sed 's/\.$//' | sed 's/\./ /g'

i=0
j=0

####movie_root=/mnt/storage/videos/movies
movie_root=~/create_movie_directory_test

cd "$movie_root" || exit 1

RED='\033[0;31m'
# No Color
NC='\033[0m'

printf "${RED}!!!!  $(pwd) -- are you sure you want to continue with the current directory?  !!!!${NC}\n"
printf "${RED}!!!!  $movie_root -- are you sure you want to continue with the current movie_root?  !!!!${NC}\n\n"

read -p "Press Ctrl-c to exit or Enter to continue."
echo
read -p "Are you sure you pressed the correct key (Ctrl-c to exit or Enter to continue)?"
printf "\n\n"

echo $(echo !==== Reverting creation of movie directory changes ====! | tr [:lower:] [:upper:])
echo
echo


find . -maxdepth 1 ! -path . -type d | sed 's/.\///' | while read -r folder; do
  movie_files=()
  movie_path="$(pwd)/$folder"
  new_movie_files=()
  cleanup_msg=$(echo "^^^^  Files could not be verified! No cleanup wiill be performed! ^^^^" | tr [:lower:] [:upper:])

  for filepath in "$movie_path/"*; do
    # @TODO: Find everything between the last two dots of the filename. Ex: My.Awesome.Movie.(2000).1080p-fanart.jpg -- find "1080p-fanart" and assign everything before that to a variable. This will be the new $movie_path_w_movie_root_filename. Change all code following accordingly.
    # movie_path_w_movie_root_filename example: /home/jd/create_movie_directory_test/My Awesome Movie/My.Awesome.Movie
    movie_path_w_movie_root_filename=$(echo $filepath | sed 's/\.\///' | cut -d "(" -f 1 | sed 's/\.$//')
    # @TODO: Find everything between the last two dots of the filename. Ex: My.Awesome.Movie.(2000).1080p-fanart.jpg -- find "1080p-fanart" and assign everything before that to a variable. This will be the new $movie_root_filename. Change all code following accordingly.
    # movie_root_filename example: My.Awesome.Movie
    movie_root_filename=$(basename "$movie_path_w_movie_root_filename")
    movie_titlename=$(echo $movie_root_filename | sed 's/\./ /g')
    movie_titlename_upper=$(echo $movie_titlename | tr [:lower:] [:upper:])
    base_filename=$(basename "$filepath")
    new_movie_path="$movie_path/$movie_root_filename"
  done

  echo ===========================================================================
  echo "Processing \"$movie_titlename_upper\""
  echo "in $movie_path"
  echo ===========================================================================
  echo
  echo "    Processing \"$base_filename\""
  echo

  for filepath in "$movie_path/"*; do
    base_filename=$(basename "$filepath")
    movie_files+=("$base_filename")
  done

  echo "    Copying all associated movie files back to the $movie_root..."
  echo
  cp "$(pwd)/$folder/"* .
  echo "    Verifying files were successfully copied..."
  echo

  for filepath in "$new_movie_path"*; do
    new_base_filename=$(basename "$filepath")
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
    echo "    Cleaning up & deleting the movie folder..."
    echo
    echo
    rm -r "$(pwd)/$folder/"
  else
    echo
    echo -e "    ${RED}$cleanup_msg${NC}"
    echo
    echo
  fi
done

