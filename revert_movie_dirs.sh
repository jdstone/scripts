#!/usr/bin/env bash

#title            :revert_movie_dirs.sh
#description      :This script moves movie files organized in their own directory to a single directory.
#                  Reverts process completed by create_movie_dirs.sh.
#author           :J.D. Stone
#date             :20240705
#version          :2.1.0
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
  ## variables
  local j
  j=0
  local k
  k=0
  local movie_root_wo_trailing_slash
  movie_root_wo_trailing_slash=$(echo "$movie_root" | sed 's/\///4')

  cd "$movie_root" || exit

  echo
  echo -e "${RED}!!!!  $(pwd) -- Are you sure you want to continue with this movie directory?  !!!!${NC}\n"

  read -r -p "Press Ctrl-C to exit or Enter to continue"
  echo
  read -r -p "Are you sure you pressed the correct key (Ctrl-C to exit or Enter to continue)?"
  echo; echo;

  echo "!==== Reverting creation of individual movie directory changes ====!" | tr "[:lower:]" "[:upper:]"
  echo
  echo


  ## process one movie title at a time
  find . -maxdepth 1 ! -path . -type d | sed 's/.\///' | while read -r directory; do
    movie_files=()
    movie_directory_path="$(pwd)/$directory"
    new_movie_files=()
    cleanup_msg=$(echo "^^^^  Files could not be verified! No cleanup wiill be performed! ^^^^" | tr "[:lower:]" "[:upper:]")

    ## E.g.: full_file_name_w_path = /home/user/my_movies/Rush Hour/Rush.Hour.(1998).1080p.mp4
    ## E.g.: movie_directory_path = /home/user/my_movies/Rush Hour
    for full_file_name_w_path in "$movie_directory_path/"*; do
      ## E.g.: root_movie_file_path_wo_ext = /home/user/my_movies/Rush Hour/Rush.Hour
      root_movie_file_path_wo_ext=$(echo "$full_file_name_w_path" | sed 's/\.\///' | cut -d "(" -f 1 | sed 's/\.$//')
      ## E.g.: base_file_name_wo_ext = Rush.Hour
      base_file_name_wo_ext=$(basename "$root_movie_file_path_wo_ext")
      ## E.g.: movie_titlename = Rush Hour
      movie_titlename=$(echo "$base_file_name_wo_ext" | sed 's/\./ /g')
      ## E.g.: movie_titlename_upper = RUSH HOUR
      movie_titlename_upper=$(echo "$movie_titlename" | tr "[:lower:]" "[:upper:]")
      ## E.g.: base_file_name_w_ext = Rush.Hour.(1998).1080p.mp4
      base_file_name_w_ext=$(basename "$full_file_name_w_path")
      ## E.g.: new_movie_path = /home/user/my_movies/Rush.Hour
      new_movie_path="$movie_root_wo_trailing_slash/$base_file_name_wo_ext"
    done

    echo ===========================================================================
    echo "Processing $movie_titlename_upper"
    echo "in \"$movie_directory_path\""
    echo ===========================================================================
    echo

    ## loop through each individual movie dir and create an array
    ## with all file names associated with this specific movie
    ## E.g.: full_file_name_w_path = /home/user/my_movies/Rush Hour/Rush.Hour.(1998).1080p.mp4
    ## E.g.: movie_directory_path = /home/user/my_movies/Rush Hour
    for full_file_name_w_path in "$movie_directory_path/"*; do
      ## E.g.: base_file_name_w_ext = Rush.Hour.(1998).1080p.mp4
      base_file_name_w_ext=$(basename "$full_file_name_w_path")
      movie_files+=("$base_file_name_w_ext")
      echo "    Processing \"$base_file_name_w_ext\"..."
    done

    echo
    echo "    Copying all associated movie files back to the $movie_root directory..."
    echo
    cp "$(pwd)/$directory/"* .
    echo "    Verifying files were successfully copied..."
    echo

    ## loop through the movie root directory (contains all movies in a single directory)
    ## and create an array with all file names associated with each movie
    ## E.g.: new_movie_path* = /home/user/my_movies/Rush.Hour*
    ## (with asterisk added to end of path to find all files starting with 'Rush.Hour')
    ## E.g.: full_file_name_w_path = /home/user/my_movies/Rush.Hour.(1998).1080p.mp4
    for full_file_name_w_path in "$new_movie_path"*; do
      ## E.g.: new_base_file_name = Rush.Hour.(1998).1080p.mp4
      new_base_file_name=$(basename "$full_file_name_w_path")
      new_movie_files+=("$new_base_file_name")
    done

    local match=0

    ## loop through original array of movies (movies in individual directories -- $movie_files)
    ## compare each item with each item in the new_movie_files array (movies in their own [individual] movie directory)
    ## if the file is the same in each array, increment the 'match' variable
    ## (the 'match' var is set to the number of files that each movie title is composed of)
    for j in "${movie_files[@]}"; do
      for k in "${new_movie_files[@]}"; do
        if [ "$j" == "$k" ]; then
          ((match+=1))
        fi
      done
    done

    ## if the total number of movies in the 'movie_files' array is the same as the
    ## value of the match variable, then remove each individual movie directory
    if [ "${#movie_files[@]}" -eq "$match" ]; then
      echo -e "    ${GREEN}Files were successfully verified!${NC}"
      echo
      echo "    Cleaning up & deleting the movie directory..."
      echo
      echo
      present_working_dir=$(pwd)
      rm -r "${present_working_dir:?}/$directory/"
    else
      echo
      echo -e "    ${RED}$cleanup_msg${NC}"
      echo
      echo
    fi
  done

  echo -e "${GREEN}Process is complete.${NC}"
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
    #     echo -e "${RED}[!]${NC}  ${OPTARG} is an invalid argument for option -${opt}\n" 1>&2
    #     echo -e "${RED}[!]${NC}  a file count (number) must be specified when using the -${opt} option\n"
    #     echo
    #     usage
    #     exit 1
    #   fi
    #   ;;
    d )
      opt_d=1
      movie_root="${OPTARG}"
      if [[ ! -d "${movie_root}" ]]; then
        echo -e "${RED}[!]${NC}  '${movie_root}' is not a valid directory\n"
        echo
        usage
        exit 1
      fi
      ;;
    : )
      echo "illegal option -- ${OPTARG} requires an argument" 1>&2
      if [[ "${OPTARG}" == "d" ]]; then
        echo -e "${RED}[!]${NC}  a directory must be specified when using the -${opt} option\n"
        echo
      # elif [[ "${OPTARG}" == "c" ]]; then
      #   echo -e "${RED}[!]${NC}  a file count (number) must be specified when using the -${opt} option\n"
      #   echo
      else
        echo
      fi
      usage
      exit 1
      ;;
    h | * )
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

