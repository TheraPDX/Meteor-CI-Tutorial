#!/bin/bash
#

export green='\e[0;32m'
export flashingRed='\e[5;31m'
export endColor='\e[0m';

function existingMeteor() {

  EXISTING_METEOR_PID=$(ps aux | grep meteor | grep -v grep | grep -c ~/.meteor/packages)
  if [[  ${EXISTING_METEOR_PID} -gt 0  ]]; then
    echo ""
    echo ""
    echo "A Meteor process was started earlier.  Find it and stop it."
    echo "If you cannot find it, in a separate terminal window, stop it now with :"
    echo "   kill -9 ${EXISTING_METEOR_PID}"
    echo ""
    echo -e "After you have stopped the old Meteor process hit <enter> to start the new one.  "
    read -n 1 -r USER_ANSWER
  fi

}

# P1 : the url to verify
# P2 : additional commands to meteor. Eg; test-packages
function launchMeteorProcess()
{
  METEOR_URL=$1;
  STARTED=false;

  until wget -q --spider ${METEOR_URL};
  do
    echo "Waiting for ${METEOR_URL}";
    if ! ${STARTED}; then
      meteor $2 &
      STARTED=true;
    fi;
    sleep 2;
  done

  echo "Meteor is running on ${METEOR_URL}";
}

function killMeteorProcess()
{
  EXISTING_METEOR_PIDS=$(ps aux | grep meteor  | grep -v grep | grep ~/.meteor/packages | awk '{print $2}')
  for pid in ${EXISTING_METEOR_PIDS}; do
    echo "Kill Meteor process : ${pid}";
    kill -9 ${pid};
  done;
}


function saveUserData()
{
cat << UDATA > udata.sh
export PARENT_DIR="${PARENT_DIR}"
export PROJECT_NAME="${PROJECT_NAME}"
export PKG_NAME="${PKG_NAME}"
export GITHUB_ORGANIZATION_NAME="${GITHUB_ORGANIZATION_NAME}"
export PACKAGE_DEVELOPER="${PACKAGE_DEVELOPER}"
export YOUR_EMAIL="${YOUR_EMAIL}"
export YOUR_UID="${YOUR_UID}"
export YOUR_FULLNAME="${YOUR_FULLNAME}"
UDATA
}

function getUserData()
{

  if [ -f ./udata.sh ]; then
    source ./udata.sh
  else
    export PARENT_DIR=""
    export PROJECT_NAME=""
    export PKG_NAME=""
    export GITHUB_ORGANIZATION_NAME=""
    export PACKAGE_DEVELOPER=""
    export YOUR_EMAIL=""
    export YOUR_UID=""
    export YOUR_FULLNAME=""
  fi


  CHOICE="n"
  while [[ ! "X${CHOICE}X" == "XyX" ]]
  do

    echo -e "${FRAME// /\~}"
    echo "Projects folder in ${HOME} directory : ${PARENT_DIR}"
    echo "Project name : ${PROJECT_NAME}"
    echo "Package name : ${PKG_NAME}"
    echo "GitHub organization name : ${GITHUB_ORGANIZATION_NAME}"
    echo "GutHub user id: ${PACKAGE_DEVELOPER}"
    echo "GutHub user full name : ${YOUR_FULLNAME}"
    echo "Project owner local user id : ${YOUR_UID}"
    echo "Project owner email : ${YOUR_EMAIL}"

    read -ep "Is this correct? (y/n/q) ::  " -n 1 -r USER_ANSWER
    CHOICE=$(echo ${USER_ANSWER:0:1} | tr '[:upper:]' '[:lower:]')
    if [[ "X${CHOICE}X" == "XqX" ]]; then
      echo skip out
      return 1;
    elif [[ ! "X${CHOICE}X" == "XyX" ]]; then

      echo -e "\n Please supply the following details :\n";
      read -p "Your directory for projects in the ${HOME} directory :  :: " -e -i "${PARENT_DIR}" INPUT
      if [ ! "X${INPUT}X" == "XX" ]; then PARENT_DIR=${INPUT}; fi;

      read -p "The exact project name for use in GitHub :: " -e -i "${PROJECT_NAME}" INPUT
      if [ ! "X${INPUT}X" == "XX" ]; then PROJECT_NAME=${INPUT}; fi;

      read -p "The exact package name for use in GitHub :: " -e -i "${PKG_NAME}" INPUT
      if [ ! "X${INPUT}X" == "XX" ]; then PKG_NAME=${INPUT}; fi;

      read -p "The exact name for the GitHub organization :: " -e -i "${GITHUB_ORGANIZATION_NAME}" INPUT
      if [ ! "X${INPUT}X" == "XX" ]; then GITHUB_ORGANIZATION_NAME=${INPUT}; fi;

      read -p "The project owner user id in GitHub :: " -e -i "${PACKAGE_DEVELOPER}" INPUT
      if [ ! "X${INPUT}X" == "XX" ]; then PACKAGE_DEVELOPER=${INPUT}; fi;

      read -p "The project owner full name to use to publish it in GitHub :: " -e -i "${YOUR_FULLNAME}" INPUT
      if [ ! "X${INPUT}X" == "XX" ]; then YOUR_FULLNAME=${INPUT}; fi;

      read -p "The email address for the project owner in GitHub :: " -e -i "${YOUR_EMAIL}" INPUT
      if [ ! "X${INPUT}X" == "XX" ]; then YOUR_EMAIL=${INPUT}; fi;

      read -p "The project owner name to use within the project :: " -e -i "${YOUR_UID}" INPUT
      if [ ! "X${INPUT}X" == "XX" ]; then YOUR_UID=${INPUT}; fi;

    fi;
    echo "  "
  done;
  saveUserData;
  return;
}

function checkNotRoot() {
  if [[ $EUID -eq 0 ]]; then
    echo -e "This script SHOULD NOT be run with 'sudo' (as root). ";
    exit 1;
  fi;
}

function checkForVirtualMachine() {
  echo -e "Attempting to confirm we're running in a virtual machine . . .";
  VIRTUAL=false;

  MSG="Found a '%s' virtual machine.\n\n";

  if [[ -d /proc/vz ]]; then
    if [[ -f /proc/vz/veinfo ]]; then
      printf "${MSG}" "Virtuozzo"; return 0;
    fi;
  fi;

  DMESG_CHK=$(dmesg | grep -i virtual);
  if [[ 0 < $(echo "${DMESG_CHK}" | grep -c drive) ]]; then  printf "${MSG}" "Microsoft VirtualPC"; return 0; fi;
  if [[ 0 < $(dmesg | grep -i xen) ]]; then  printf "${MSG}" "Xen"; return 0; fi;
  if [[ 0 < $(echo "${DMESG_CHK}" | grep -c QEMU) ]]; then  printf "${MSG}" "QEMU"; return 0; fi;
  if [[ 0 < $(echo "${DMESG_CHK}" | grep -c KVM) ]]; then  printf "${MSG}" "KVM"; return 0; fi;


  echo " **PLEASE PLEASE PLEASE**";
  echo " Only run these scripts on a Virtual Machine running Ubuntu 12.04LTS or newer";
  echo " ";
  echo " I have made no attempt to validate the script in other environments,";
  echo " so failure and damage are the likely result if you do not respect this warning.";
  echo " ";
  echo " ";

  exit 1;

}

function endOfSectionScript() {

  printf "\n\n\n  Done! You have finished part #%d, '%s', of the tutorial.\n
             Are you ready to begin part #%d, '%s'.?
               If so, hit [y]es, or <Enter>.
               If NOT then hit [n]o or <ctrl-c>.\n\n" \
          ${1} ${2} $(($1+1)) ${3}
  printf -v NEWSCRIPT "Tutorial%02d_%s.sh" $(($1+1)) ${3}
  read -p "  'y' or 'n' ::  " -n 1 -r USER_ANSWER
  CHOICE=$(echo ${USER_ANSWER:0:1} | tr '[:upper:]' '[:lower:]')
  if [[ "X${CHOICE}X" == "XyX"  || "X${CHOICE}X" == "XX" ]]; then
    echo -e "\n\nStarting Part #${SECTNUM}.";
    echo bash ./scripts/${NEWSCRIPT};
  fi;

}

PROJECT_NAME="  ** NOT DEFINED ** ";
if [ -f ./udata.sh ]; then
  source ./udata.sh
  echo "Project name : '${PROJECT_NAME}'"
fi

#############################
