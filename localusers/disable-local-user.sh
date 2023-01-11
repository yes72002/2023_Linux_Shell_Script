#!/bin/bash
#
# This script disables, deletes, and/or archives users on the local system.
#

ARCHIVE_DIR='/archive'

# Provides a usage statement much like you would find in a man page if the user does not
# supply an account name on the command line and returns an exit status of 1.
# All messages associated with this event will be displayed on standard error.
usage() {
  echo "Usage: ${0} [-dra] USER [USERN]..." >&2
  echo 'Disable a local Linux account.' >&2
  echo '  -d  Deletes accounts instead of disabling them.' >&2
  echo '  -r  Removes the home directory associated with the account(s).' >&2
  echo '  -a  Creates an archive of the home directory associated with the account(s)' >&2
  exit 1
}

# Enforces that it be executed with superuser (root) privileges. If the script is not executed
# with superuser privileges it will not attempt to create a user and returns an exit status of 1.
# All messages associated with this event will be displayed on standard error.
# Run as root.
if [[ "${UID}" -ne 0 ]]
then
   echo 'Please run with sudo or as root.' >&2
   exit 1
fi

# Allows the user to specify the following options:
# -d Deletes accounts instead of disabling them.
# -r Removes the home directory associated with the account(s).
# -a Creates an archive of the home directory associated with the accounts(s) and stores
#    the archive in the /archives directory. (NOTE: /archives is not a directory that exists
#    by default on a Linux system. The script will need to create this directory if it does
#    not exist.)
# Any other option will cause the script to display a usage statement and exit with an exit
# status of 1.
while getopts dra OPTION
do
  case ${OPTION} in
    d)
      # userdel ${USER_NAME}
      # echo "The account ${USER_NAME} was deleted."
      DELETE_USER='true' ;;
    r)
      # userdel -r ${USER_NAME}
      REMOVE_OPTION='-r' ;;
    a)
      # mkdir archives
      # tar -vcf /archive/account.tar /home/
      ARCHIVE='true' ;;
    ?)
      usage
      ;;
  esac
done

# Remove the options while leaving the remaining arguments.
shift "$(( OPTIND - 1 ))"

# If the user doesn't supply at least one argument, give them help.
if [[ "${#}" -lt 1 ]]
then
  usage
fi

# Loo through all the usernames supplied as arguments.
# Accepts a list of usernames as arguments. At least one username is required or the script
# will display a usage statement much like you would find in a man page and return an exit
# status of 1.
# All messages associated with this event will be displayed on standard error.
for USER_NAME in "${@}"
do
  echo "Processing user: ${USER_NAME}"
  
  # Make sure the UID of the account is at least 1000.
  # Refuses to disable or delete any accounts that have a UID less than 1,000.
  #   Only system accounts should be modified by system administrators.
  #   Only allow the help desk team to change user accounts.
  USER_ID=$(id -u ${USER_NAME})
  if [[ "${USER_ID}" -lt 1000 ]]
  then
    echo "Refusing to remove the ${USER_NAME} account with UID ${USER_ID}." >&2
    exit 1
  fi

  # Create an archive if requested to do so.
  if [[ "${ARCHIVE}" = 'true' ]]
  then
    # Make sure the ARCHIVE_DIR directory exists.
    if [[ ! -d "${ARCHIVE_DIR}" ]]
    then
      echo "Creating ${ARCHIVE_DIR} directory."
      mkdir -p ${ARCHIVE_DIR}
      if [[ "${?}" -ne 0 ]]
      then
        echo "The archive directory ${ARCHIVE_DIR} could not be created." >&2
        exit 1
      fi
    fi
    
    # Archive the user's home directory and move it into the ARCHIVE_DIR
    HOME_DIR="/home/${USER_NAME}"
    ARCHIVE_FILE="${ARCHIVE_DIR}/${USER_NAME}.tgz"
    if [[ -d "${HOME_DIR}" ]]
    then
      echo "Archiving ${HOME_DIR} to ${ARCHIVE_FILE}"
      tar -zcf ${ARCHIVE_FILE} ${HOME_DIR} &> /dev/null
      if [[ "${?}" -ne 0 ]]
      then
        echo "Could not create ${ARCHIVE_FILE}." >&2
        exit 1
      fi
    else
      echo "${HOME_DIR} does not exist or is not a directory." >&2
      exit 1
    fi
  fi # END of if "${ARCHIVE}" = 'true'
  
  if [[ "${DELETE_USER}" = 'true' ]]
  then
    # Delete the user.
    userdel ${REMOVE_OPTION} ${USER_NAME}
    
    # Check to see if the userdel command succeeded.
    # We don't want to tell the user that an account was deleted when it hasn't been.
    if [[ "${?}" -ne 0 ]]
    then
      echo "The account ${USER_NAME} was not deleted." >&2
      exit 1
    fi
    echo "The account ${USER_NAME} was deleted."
  else # Disables (expires/locks) accounts by default.
    chage -E 0 ${USER_NAME}
    
    # Check to see if the chage command succeeded.
    # We don't want to tell the user that an account was disabled when it hasn't been.
    if [[ "${?}" -ne 0 ]]
    then
      echo "The account ${USER_NAME} was not disabled." >&2
      exit 1
    fi
    echo "The account ${USER_NAME} was disabled."
  fi # END of if "${DELETE_USER}" = 'true'
done
      
exit 0


























