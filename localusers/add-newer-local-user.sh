#!/bin/bash
#
# This script creates a new user on the local system.
# You must supply a username as an argument to the script.
# Optionally, you can also provide a comment for the account as an argument.
# A password will be automatically generated for the account.
# The username, password, and host for the account will be displayed.

# Enforces that it be executed with superuser (root) privileges. If the script is not executed
# with superuser privileges it will not attempt to create a user and returns an exit status of 1.
# All messages associated with this event will be displayed on standard error.
UID_OF_ROOT='0'
if [[ "${UID}" -ne "${UID_OF_ROOT}" ]]
then
  echo "Your are not root."  >&2
  echo 'Please run with sudo or as root.' >&2
  exit 1
fi

NUMBER_OF_PARAMETERS="${#}"
echo "You supplied ${NUMBER_OF_PARAMETERS} argument(s) on the command line."
# Provides a usage statement much like you would find in a man page if the user does not
# supply an account name on the command line and returns an exit status of 1.
# All messages associated with this event will be displayed on standard error.
if [[ "${NUMBER_OF_PARAMETERS}" -lt 1 ]]
then
  echo "Usage: ${0} USER_NAME [COMMENT]..."  >&2
  echo 'Create an account on the local system with the name of USER_NAME and a comments field of COMMENT.'  >&2
  exit 1
fi

# Uses the first argument provided on the command line as the username for the account.
USER_NAME="${1}"
# Any remaining arguments on the command line will be treated as the comment for the account.
shift
COMMENT="${@}"

# Automatically generates a password for the new account.
PASSWORD=$(date +%s%N | sha256sum | head -c48)

# Informs the user if the account was not able to be created for some reason. If the account is
# not created, the script is to return an exit status of 1.
# All messages associated with this event will be displayed on standard error.
useradd -c "${COMMENT}" -m ${USER_NAME} &> /dev/null
if [[ "${?}" -ne 0 ]]
then
  echo 'The account could not be created.' >&2
  exit 1
fi

# Check to see if the passwd command succeeded.
echo ${PASSWORD} | passwd --stdin ${USER_NAME} &> /dev/null
if [[ "${?}" -ne 0 ]]
then
  echo 'The password for the account could not be set.' >&2
  exit 1
fi

# Force password change on first login.
passwd -e ${USER_NAME} &> /dev/null

# Displays the username, password, and host where the account was created. This way the
# help desk staff can copy the output of the script in order to easily deliver the information 
# to the new account holder.
# echo 
echo "username: ${USER_NAME}"
echo "comment: ${COMMENT}"
echo "password: ${PASSWORD}"
echo "host: ${HOSTNAME}"
exit 0




