#!/usr/bin/env bash

#title          :create_movie_dirs.sh
#description    :This script reorganizes/moves movie (and associated) files organized in a single directory to their own directory.
#author         :J.D. Stone
#date           :20240702
#version        :2.2.1
#usage: ./create_movie_dirs.sh -d <directory> [-c <count>] [-h]
#
#     ./create_movie_dirs.sh -d <directory>     Set the movie directory on which the script should process.
#     ./create_movie_dirs.sh [-c <count>]       Set the number of files to process. Default is 15.
#     ./create_movie_dirs.sh [-h]               Display this help message.
#
#     Examples:
#               ./create_movie_dirs.sh -d ~/my_movies
#               ./create_movie_dirs.sh -d ~/my_movies -c 25
#
#TODO:
# - add option for extensions to process
#==============================================================================


## OPTIONS
opt_d=0
opt_c=0
## SET A LIMIT FOR HOW MANY FILES YOU WANT TO PROCESS PER RUN
directory_file_count_limit=25
# Red Color
RED='\033[0;31m'
# No Color
NC='\033[0m'

main () {
  local i=0

  cd "$movie_root"

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
}

usage () {
  echo "Usage: ${0} -d <directory> [-c <count>] [-h]"
  echo
  echo "    ${0} -d <directory>     Set the movie directory on which the script should process."
  echo "    ${0} [-c <count>]       Set the number of files to process. Default is 15."
  echo "    ${0} [-h]               Display this help message."
  echo
  echo "    Examples:"
  echo "              ${0} -d ~/my_movies"
  echo "              ${0} -d ~/my_movies -c 25"
}

while getopts "c:d:h" opt; do
  case ${opt} in
    c )
      opt_c=1
      directory_file_count_limit=${OPTARG}
      if [[ ( ! ${directory_file_count_limit} =~ ^[0-9]+$ ) ]]; then
        printf "${RED}[!]${NC}  ${OPTARG} is an invalid argument for option -${opt}\n" 1>&2
        printf "${RED}[!]${NC}  a file count (number) must be specified when using the -${opt} option\n"
        echo
        usage
        exit 1
      fi
      ;;
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
      elif [[ "${OPTARG}" == "c" ]]; then
        printf "${RED}[!]${NC}  a file count (number) must be specified when using the -${opt} option\n"
        echo
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

# decision logic
if [[ ${opt_d} == 1 ]]; then
  main
elif [[ ( $# -eq 0 || $# -gt 0 ) || ( ! ${opt_d} ) ]]; then
  usage
  exit 0
fi

