#!/usr/bin/env bash

#title            :update-run_chef-client.sh
#description      :This script automates the installation/updating and running of Chef-client across any
#                  server in any environment.
#author           :J.D. Stone
#date             :20210611
#version          :0.4
#usage            :See usage below.
#notes            :SSH must be installed to run this script.
#tested on bash   :5.1.8(1)-release
#
# Usage: ./update-run_chef-client.sh [-v chef_version] [-e environment] [-s server_name] [-a] [-p] [-c] [-r] [-w] [-h] [-l]
#
#     ./update-run_chef-client.sh -v chef_version      Whole number versions are accepted (i.e. 15, 16, 17, etc.)
#     ./update-run_chef-client.sh -e environment       For batch-install, specify 'stage' or 'prod'.
#     ./update-run_chef-client.sh -s server_name       One-time install of chef-client on specified server.
#     ./update-run_chef-client.sh -a                   Accept Chef-client license agreement.
#     ./update-run_chef-client.sh -p                   Accept Chef-client license agreement, this time only.
#     ./update-run_chef-client.sh -c                   Confirm execution of actions.
#     ./update-run_chef-client.sh -r                   Don't install 'chef-client', just run it.
#     ./update-run_chef-client.sh -w                   Run 'chef-client' with the '--why-run' option.
#     ./update-run_chef-client.sh -l                   Download logs.
#     ./update-run_chef-client.sh -h                   Display this help message.
#
#     Examples:
#               ./update-run_chef-client.sh -v 14 -e prod
#               ./update-run_chef-client.sh -v 14 -e prod -a
#               ./update-run_chef-client.sh -v 15 -s stage-server1
#
# Reference:
#
# https://unix.stackexchange.com/questions/405250/passing-and-setting-variables-in-a-heredoc
# https://bencane.com/2014/09/02/understanding-exit-codes-and-how-to-use-them-in-bash-scripts/
# https://www.cyberciti.biz/faq/how-to-redirect-output-and-errors-to-devnull/
# https://sookocheff.com/post/bash/parsing-bash-script-arguments-with-shopts/
#==============================================================================


declare -a TEST_SERVER=("stage-server1")

declare -a STAGE_SERVERS=("stage-server1" "stage-server2" "stage-server3" "stage-server4"
                          "stage-server5" "stage-server6" "stage-server7" "stage-server8"
                         )

declare -a PROD_SERVERS=("prod-1" "prod-2" "prod-3" "prod-4"
                         "prod-5" "prod-6" "prod-7" "prod-8"
                        )


downloadLog () {
  local HOST_NAME=$1
  local ENV=$2

  ssh -T $HOST_NAME <<-ENDSSH
sudo tail -n 600 /var/log/chef/client.log > ${HOST_NAME}_chef_client_run_log.txt
ENDSSH
  if [ "${ENV}" == "stage" ] || [ "${ENV}" == "test" ]; then
    if [ "${INSTALL}" == "true" ]; then
      scp $HOST_NAME:${HOST_NAME}_chef_client_install_log.txt ${STAGE_LOG_DIR_UP}/
      if [ "${WHY_RUN}" == "true" ]; then
        scp $HOST_NAME:${HOST_NAME}_chef_client_manual_why_run_log.txt ${STAGE_LOG_DIR_UP}/
      else
        scp $HOST_NAME:${HOST_NAME}_chef_client_run_log.txt ${STAGE_LOG_DIR_UP}/
        scp $HOST_NAME:${HOST_NAME}_chef_client_manual_run_log.txt ${STAGE_LOG_DIR_UP}/
      fi
    else
      if [ "${WHY_RUN}" == "true" ]; then
        scp $HOST_NAME:${HOST_NAME}_chef_client_manual_why_run_log.txt ${STAGE_LOG_DIR_RUN}/
      else
        scp $HOST_NAME:${HOST_NAME}_chef_client_run_log.txt ${STAGE_LOG_DIR_RUN}/
        scp $HOST_NAME:${HOST_NAME}_chef_client_manual_run_log.txt ${STAGE_LOG_DIR_RUN}/
      fi
    fi
  elif [ "${ENV}" == "prod" ]; then
    if [ "${INSTALL}" == "true" ]; then
      scp $HOST_NAME:${HOST_NAME}_chef_client_install_log.txt ${PROD_LOG_DIR_UP}/
      if [ "${WHY_RUN}" == "true" ]; then
        scp $HOST_NAME:${HOST_NAME}_chef_client_manual_why_run_log.txt ${PROD_LOG_DIR_UP}/
      else
        scp $HOST_NAME:${HOST_NAME}_chef_client_run_log.txt ${PROD_LOG_DIR_UP}/
        scp $HOST_NAME:${HOST_NAME}_chef_client_manual_run_log.txt ${PROD_LOG_DIR_UP}/
      fi
    else
      if [ "${WHY_RUN}" == "true" ]; then
        scp $HOST_NAME:${HOST_NAME}_chef_client_manual_why_run_log.txt ${PROD_LOG_DIR_RUN}/
      else
        scp $HOST_NAME:${HOST_NAME}_chef_client_run_log.txt ${PROD_LOG_DIR_RUN}/
        scp $HOST_NAME:${HOST_NAME}_chef_client_manual_run_log.txt ${PROD_LOG_DIR_RUN}/
      fi
    fi
  elif [ "${ENV}" == "single" ]; then
    if [ "${INSTALL}" == "true" ]; then
      scp $HOST_NAME:${HOST_NAME}_chef_client_install_log.txt ${SINGLE_RUN_LOG_DIR_UP}/
      if [ "${WHY_RUN}" == "true" ]; then
        scp $HOST_NAME:${HOST_NAME}_chef_client_manual_why_run_log.txt ${SINGLE_RUN_LOG_DIR_UP}/
      else
        scp $HOST_NAME:${HOST_NAME}_chef_client_run_log.txt ${SINGLE_RUN_LOG_DIR_UP}/
        scp $HOST_NAME:${HOST_NAME}_chef_client_manual_run_log.txt ${SINGLE_RUN_LOG_DIR_UP}/
      fi
    else
      if [ "${WHY_RUN}" == "true" ]; then
        scp $HOST_NAME:${HOST_NAME}_chef_client_manual_why_run_log.txt ${SINGLE_RUN_LOG_DIR_UP}/
      else
        scp $HOST_NAME:${HOST_NAME}_chef_client_run_log.txt ${SINGLE_RUN_LOG_DIR_RUN}/
        scp $HOST_NAME:${HOST_NAME}_chef_client_manual_run_log.txt ${SINGLE_RUN_LOG_DIR_RUN}/
      fi
    fi
  fi
}

cleanup () {
  local HOST_NAME=$1

  ssh -T $HOST_NAME <<-ENDSSH
rm -rf chef_install/ ${HOST_NAME}_chef_client_run_log.txt ${HOST_NAME}_chef_client_install_log.txt ${HOST_NAME}_chef_client_manual_why_run_log.txt ${HOST_NAME}_chef_client_manual_run_log.txt
ENDSSH
}

onetime_run () {
  if [ "${CONFIRM}" ==  "true" ]; then
    read -p "Would you like to connect to \"${SERVER}\" and continue? " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      run_main_content $SERVER "single"
    fi
  else
    run_main_content $SERVER "single"
  fi
}

install_stage () {
  for i in "${STAGE_SERVERS[@]}"; do
    if [ "${CONFIRM}" ==  "true" ]; then
      read -p "Would you like to connect to \"${i}\" and continue? " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        run_main_content $i "stage"
      fi
    else
      run_main_content $i "stage"
    fi
  done
}

install_prod () {
  for i in "${PROD_SERVERS[@]}"; do
    if [ "${CONFIRM}" ==  "true" ]; then
      read -p "Would you like to connect to \"${i}\" and continue? " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        run_main_content $i "prod"
      fi
    else
      run_main_content $i "prod"
    fi
  done
}

install_test () {
  for i in "${TEST_SERVER[@]}"; do
    if [ "${CONFIRM}" ==  "true" ]; then
      read -p "Would you like to connect to \"${i}\" and continue? " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        run_main_content $i "test"
      fi
    else
      run_main_content $i "test"
    fi
  done
}

ssh_to_server () {
  local HOST_NAME=$1

  ssh -T $HOST_NAME <<-ENDSSH
if [ "${RUN_ONLY}" != "true" ]; then
  echo "Updating chef-client to the latest version of chef-client v${CHEF_VERSION}."
  mkdir chef_install
  wget https://chef.io/chef/install.sh -P chef_install/ > /dev/null 2>&1
  chmod +x chef_install/install.sh
  mkdir chef_install/chef_download
  sudo chef_install/install.sh -v ${CHEF_VERSION} -d chef_install/chef_download/ > ${HOST_NAME}_chef_client_install_log.txt 2>&1
  if [ $? -eq 0 ]; then
    echo "Successfully installed chef-client v${CHEF_VERSION}."
  else
    echo "Failed to install chef-client v${CHEF_VERSION}." >&2
  fi
  echo
fi

if [ "${ACCEPT_LICENSE}" == "true" ] && [ "${WHY_RUN}" == "true" ]; then
  echo "Running chef-client --why-run...this may take 2-3 minutes."
  sudo CHEF_LICENSE="accept" chef-client --why-run | tee -a ${HOST_NAME}_chef_client_manual_why_run_log.txt 2>&1
elif [ "${ACCEPT_LICENSE}" == "true" ]; then
  echo "Running chef-client...this may take 2-3 minutes."
  sudo CHEF_LICENSE="accept" chef-client | tee -a ${HOST_NAME}_chef_client_manual_run_log.txt 2>&1
elif [ "${ACCEPT_LICENSE_NO_PERSIST}" == "true" ] && [ "${WHY_RUN}" == "true" ]; then
  echo "Running chef-client --why-run...this may take 2-3 minutes."
  sudo CHEF_LICENSE="accept-no-persist" chef-client --why-run | tee -a ${HOST_NAME}_chef_client_manual_why_run_log.txt 2>&1
elif [ "${ACCEPT_LICENSE_NO_PERSIST}" == "true" ]; then
  echo "Running chef-client...this may take 2-3 minutes."
  sudo CHEF_LICENSE="accept-no-persist" chef-client | tee -a ${HOST_NAME}_chef_client_manual_run_log.txt 2>&1
elif [ "${WHY_RUN}" == "true" ]; then
  echo "Running chef-client --why-run...this may take 2-3 minutes."
  sudo chef-client --why-run | tee -a ${HOST_NAME}_chef_client_manual_why_run_log.txt 2>&1
else
  echo "Running chef-client...this may take 2-3 minutes."
  sudo chef-client | tee -a ${HOST_NAME}_chef_client_manual_run_log.txt 2>&1
fi
if [ $? -eq 0 ]; then
  echo "Running chef-client completed successfully."
else
  echo "Running chef-client FAILED to complete." >&2
fi
ENDSSH
}

run_main_content () {
  local HOST_NAME=$1
  local TYPE_OF_RUN=$2

  echo "Connecting to \"${HOST_NAME}\"..."
  echo
  ssh_to_server $HOST_NAME
  if [ $? -ne 0 ]; then
    echo "Failed to connect to \"${HOST_NAME}\"."
    exit 1
  fi
  echo
  if [ "${DOWNLOAD_LOGS}" == "true" ]; then
    echo "Downloading logs..."
    downloadLog $HOST_NAME $TYPE_OF_RUN
    echo
    echo "<===================================================================>"
    echo "              Logs are available in"
    if [ "${TYPE_OF_RUN}" == "single" ]; then
      if [ "${INSTALL}" == "true" ]; then
        echo " ${SINGLE_RUN_LOG_DIR_UP}"
      else
        echo " ${SINGLE_RUN_LOG_DIR_RUN}"
      fi
    elif [ "${TYPE_OF_RUN}" == "stage" ] || [ "${TYPE_OF_RUN}" == "test" ]; then
      if [ "${INSTALL}" == "true" ]; then
        echo " ${STAGE_LOG_DIR_UP}"
      else
        echo " ${STAGE_LOG_DIR_RUN}"
      fi
    elif [ "${TYPE_OF_RUN}" == "prod" ]; then
      if [ "${INSTALL}" == "true" ]; then
        echo " ${PROD_LOG_DIR_UP}"
      else
        echo " ${PROD_LOG_DIR_RUN}"
      fi
    fi
    echo "<===================================================================>"
    echo
  fi
  echo "Cleaning up..."
  cleanup $HOST_NAME
  echo "Cleanup complete."
  echo
  echo
}

create_log_dirs () {
  ROOT_DIR=~/chef-client_install
  STAGE_LOG_DIR_UP=~/chef-client_install/stage_logs_for_v${CHEF_VERSION}_update
  STAGE_LOG_DIR_RUN=~/chef-client_install/stage_logs_for_run
  PROD_LOG_DIR_UP=~/chef-client_install/prod_logs_for_v${CHEF_VERSION}_update
  PROD_LOG_DIR_RUN=~/chef-client_install/prod_logs_for_run
  SINGLE_RUN_LOG_DIR_UP=~/chef-client_install/single_run_logs_for_v${CHEF_VERSION}_update
  SINGLE_RUN_LOG_DIR_RUN=~/chef-client_install/single_run_logs_for_run

  if [ ! -d "${ROOT_DIR}" ]; then
    mkdir ${ROOT_DIR}
  fi

  if [ "${ENV}" == "stage" ] || [ "${ENV}" == "test" ]; then
    if [ "${INSTALL}" == "true" ]; then
      if [ ! -d "${STAGE_LOG_DIR_UP}" ]; then
        mkdir ${STAGE_LOG_DIR_UP}
      fi
    else
      if [ ! -d "${STAGE_LOG_DIR_RUN}" ]; then
        mkdir ${STAGE_LOG_DIR_RUN}
      fi
    fi
  fi
  if [ "${ENV}" == "prod" ]; then
    if [ "${INSTALL}" == "true" ]; then
      if [ ! -d "${PROD_LOG_DIR_UP}" ]; then
        mkdir ${PROD_LOG_DIR_UP}
      fi
    else
      if [ ! -d "${PROD_LOG_DIR_RUN}" ]; then
        mkdir ${PROD_LOG_DIR_RUN}
      fi
    fi
  fi

  if [ ! -z "${SERVER}" ]; then
    if [ "${INSTALL}" == "true" ]; then
      if [ ! -d "${SINGLE_RUN_LOG_DIR_UP}" ]; then
        mkdir ${SINGLE_RUN_LOG_DIR_UP}
      fi
    else
      if [ ! -d "${SINGLE_RUN_LOG_DIR_RUN}" ]; then
        mkdir ${SINGLE_RUN_LOG_DIR_RUN}
      fi
    fi
  fi
}

make_vars_lowercase () {
  SERVER="$(echo "${SERVER}" | tr '[:upper:]' '[:lower:]')"
  ENV="$(echo "${ENV}" | tr '[:upper:]' '[:lower:]')"
}

usage () {
  echo "Usage: ./update-run_chef-client.sh [-v chef_version] [-e environment] [-s server_name] [-a] [-p] [-c] [-r] [-w] [-h] [-l]"
  echo
  echo "    ./update-run_chef-client.sh -v chef_version      Whole number versions are accepted (i.e. 15, 16, 17, etc.)"
  echo "    ./update-run_chef-client.sh -e environment       For batch-install, specify 'stage' or 'prod'."
  echo "    ./update-run_chef-client.sh -s server_name       One-time install of chef-client on specified server."
  echo "    ./update-run_chef-client.sh -a                   Accept Chef-client license agreement."
  echo "    ./update-run_chef-client.sh -p                   Accept Chef-client license agreement, this time only."
  echo "    ./update-run_chef-client.sh -c                   Confirm execution of actions."
  echo "    ./update-run_chef-client.sh -r                   Don't install 'chef-client', just run it."
  echo "    ./update-run_chef-client.sh -w                   Run 'chef-client' with the '--why-run' option."
  echo "    ./update-run_chef-client.sh -l                   Download logs."
  echo "    ./update-run_chef-client.sh -h                   Display this help message."
  echo
  echo "    Examples:"
  echo "              ./update-run_chef-client.sh -v 14 -e prod"
  echo "              ./update-run_chef-client.sh -v 14 -e prod -a"
  echo "              ./update-run_chef-client.sh -v 15 -s stage-server1"
  exit 0
}

run_server_decision () {
  if [ "${ENV}" == "stage" ]; then
    install_stage
  elif [ "${ENV}" == "prod" ]; then
    install_prod
  elif [ "${ENV}" == "test" ]; then
    install_test
  fi
}


while getopts ":v:e:s:apcrwhl" opt; do
  case ${opt} in
    v )
      CHEF_VERSION=${OPTARG}
      INSTALL="true"
      ;;
    e )
      ENV=${OPTARG}
      ;;
    s )
      SERVER=${OPTARG}
      ;;
    a )
      ACCEPT_LICENSE="true"
      ;;
    p )
      ACCEPT_LICENSE_NO_PERSIST="true"
      ;;
    c )
      CONFIRM="true"
      ;;
    r )
      RUN_ONLY="true"
      ;;
    w )
      WHY_RUN="true"
      ;;
    l )
      DOWNLOAD_LOGS="true"
      ;;
    h )
      usage
      ;;
    \? )
      echo "illegal option -- ${OPTARG}" 1>&2
      echo
      usage
      echo
      exit 1
      ;;
    : )
      echo "illegal option -- ${OPTARG} requires an argument" 1>&2
      echo
      usage
      echo
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))


if [ "${ACCEPT_LICENSE_NO_PERSIST}" == "true" ] && [ "${ACCEPT_LICENSE}" == "true" ]; then
  echo "You cannot specify both '-a' AND '-p' options -- please choose one or the other."
  exit 0
elif [ ! -z "${CHEF_VERSION}" ] && [ "${RUN_ONLY}" == "true" ]; then
  echo "You cannot specify both '-v chef_version' AND '-r' options -- please choose one or the other."
  exit 0
elif [ ! -z "${SERVER}" ] && ( [ ! -z "${CHEF_VERSION}" ] || [ ! -z "${RUN_ONLY}" ] ); then
  make_vars_lowercase
  if [ "${DOWNLOAD_LOGS}" == "true" ]; then
    create_log_dirs
  fi
  onetime_run
elif [ ! -z "${ENV}" ] && ( [ ! -z "${CHEF_VERSION}" ] || [ ! -z "${RUN_ONLY}" ] ); then
  make_vars_lowercase
  if [ "${DOWNLOAD_LOGS}" == "true" ]; then
    create_log_dirs
  fi
  run_server_decision
elif [ ! -z "${CHEF_VERSION}" ]; then
  echo "Incorrect usage. You must also specify an \"environment\" OR \"server_name\"."
  echo
  usage
elif [ ! -z "${SERVER}" ]; then
  echo "Incorrect usage. You must also specify a \"chef_version\" OR the \"run-only\" option (-r)."
  echo
  usage
elif [ ! -z "${ENV}" ]; then
  echo "Incorrect usage. You must also specify a \"chef_version\" OR the \"run-only\" option (-r)."
  echo
  usage
else
  echo "Incorrect usage."
  echo
  usage
fi

