#!/bin/bash

# This script creates an account on the local system.
# You will be prompted for the account name and password.

# Enforces that it be executed with superuser (root) privileges. If the script is not executed
# with superuser privileges it will not attempt to create a user and returns an exit status of 1.

echo "Your UID is ${UID}"

UID_OF_ROOT='0'
if [[ "${UID}" -ne "${UID_OF_ROOT}" ]]
then
  echo "Your are not root."
  echo 'Please run with sudo or as root.'
  exit 1
fi

# Prompts the person who executed the script to enter the username (login), the name for
# person who will be using the account, and the initial password for the account.
read -p 'Enter the username to create: ' USER_NAME
read -p 'Enter the name of the person who this account is for: ' COMMENT
read -p 'Enter the password to use for the account: ' PASSWORD

# Creates a new user on the local system with the input provided by the user.
useradd -c "${COMMENT}" -m ${USER_NAME}
# Informs the user if the account was not able to be created for some reason.
# If the account is not created, the script is to return an exit status of 1.
if [[ "${?}" -ne 0 ]]
then
  echo 'The account could not be created.'
  exit 1
fi

# Set the password.
echo ${PASSWORD} | passwd --stdin ${USER_NAME}
# Check to see if the passwd command succeeded.
if [[ "${?}" -ne 0 ]]
then
  echo 'The password for the account could not be set.'
  exit 1
fi

# Force password change on first login.
passwd -e ${USER_NAME}

# Displays the username, password, and host where the account was created.
echo
echo "Your username is ${USER_NAME}"
echo "Your password is ${PASSWORD}"
# echo "where the account was created $(pwd)" /vagrant
echo "where the account was created ${HOSTNAME}"

exit 0
