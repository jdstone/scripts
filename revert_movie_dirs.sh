#!/usr/bin/env bash

#title            :revert_movie_dirs.sh
#description      :This script moves movie files organized in their own directory to a single directory.
#                  Reverts process completed by create_movie_dirs.sh.
#author           :J.D. Stone
#date             :20240703
#version          :2.0
#usage:           :./revert_movie_dirs.sh -d <directory> [-h]
#
#     ./revert_movie_dirs.sh -d <directory>     Set the movie directory on which the script should process.
#     ./revert_movie_dirs.sh [-h]               Display this help message.
#
#     Examples:
#               ./revert_movie_dirs.sh -d ~/my_movies
#==============================================================================


## CLI Options
opt_d=0
# opt_c=0
## Red Color
RED='\033[0;31m'
## Green Color
GREEN='\033[0;32m'
## No Color
NC='\033[0m'

main () {
  local j=0
  local k=0

  cd "$movie_root"

  echo
  printf "${RED}!!!!  $(pwd) -- Are you sure you want to continue with this movie directory?  !!!!${NC}\n"

  read -p "Press Ctrl-C to exit or Enter to continue"
  echo
  read -p "Are you sure you pressed the correct key (Ctrl-C to exit or Enter to continue)?"
  printf "\n\n"

  echo $(echo !==== Reverting creation of individual movie directory changes ====! | tr [:lower:] [:upper:])
  echo
  echo


  ## process one movie title at a time
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

    ## loop through each individual movie dir and create an array
    ## with all filenames associated with this specific movie
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

    ## loop through the single movie dir and create an array
    ## with all filenames associated with this specific movie
    for file_w_path in "$new_movie_path"*; do
      new_base_filename=$(basename "$file_w_path")
      new_movie_files+=("$new_base_filename")
    done

    local match=0

    ## loop through original array of movies (movies in individual dirs -- $movie_files)
    ## compare each item with each item in the new_movie_files (movies in a single movie directory)
    ## if the file is the same in each array, increment the 'match' variable
    ## (the 'match' var is set to the number of files that each movie title is composed of)
    for j in "${movie_files[@]}"; do
      for k in "${new_movie_files[@]}"; do
        if [ "$j" == "$k" ]; then
          ((match+=1))
        fi
      done
    done

    if [ "${#movie_files[@]}" -eq "$match" ]; then
      printf "    ${GREEN}Files were successfully verified!${NC}\n"
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
}

usage () {
  echo "Usage: ${0} -d <directory> [-h]"
  echo
  echo "    ${0} -d <directory>     Set the movie directory on which the script should process."
  echo "    ${0} [-h]               Display this help message."
  echo
  echo "    Examples:"
  echo "              ${0} -d ~/my_movies"
}

# while getopts "c:d:h" opt; do
while getopts "d:h" opt; do
  case ${opt} in
    # c )
    #   opt_c=1
    #   directory_file_count_limit=${OPTARG}
    #   if [[ ( ! ${directory_file_count_limit} =~ ^[0-9]+$ ) ]]; then
    #     printf "${RED}[!]${NC}  ${OPTARG} is an invalid argument for option -${opt}\n" 1>&2
    #     printf "${RED}[!]${NC}  a file count (number) must be specified when using the -${opt} option\n"
    #     echo
    #     usage
    #     exit 1
    #   fi
    #   ;;
    d )
      opt_d=1
      movie_root="${OPTARG}"
      if [[ ! -d "${movie_root}" ]]; then
        printf "${RED}[!]${NC}  '${movie_root}' is not a valid directory\n"
        echo
        usage
        exit 1
      fi
      ;;
    : )
      echo "illegal option -- ${OPTARG} requires an argument" 1>&2
      if [[ "${OPTARG}" == "d" ]]; then
        printf "${RED}[!]${NC}  a directory must be specified when using the -${opt} option\n"
        echo
      # elif [[ "${OPTARG}" == "c" ]]; then
      #   printf "${RED}[!]${NC}  a file count (number) must be specified when using the -${opt} option\n"
      #   echo
      else
        echo
      fi
      usage
      exit 1
      ;;
    * | h )
      echo
      usage
      exit 0
      ;;
  esac
done
shift $((OPTIND -1))

## decision logic
if [[ ${opt_d} == 1 ]]; then
  main
elif [[ ( $# -eq 0 || $# -gt 0 ) || ( ! ${opt_d} ) ]]; then
  usage
  exit 0
fi

