#!/bin/bash

# Count the number of failed logins by IP address.
# If there are any IPs with over LIMIT failures, display the count, IP, and location.


LIMIT='10'
LOG_FILE="${1}"

# Requires that a file is provided as an argument. If a file is not provided or it cannot be read,
# then the script will display an error message and exit with a status of 1.
if [[ ! -e "${LOG_FILE}" ]]
then
  echo "Cannot open log file: ${LOG_FILE}" >&2
  exit 1
fi

# Produces output in CSV (comma-separated values) format with a header of
# "Count,IP,Location".
echo 'Count,IP,Location'


# Counts the number of failed login attempts by IP address. If there are any IP addresses with
# more than 10 failed login attempts, the number of attempts made, the IP address from which
# those attempts were made, and the location of the IP address will be displayed.
# Hint: use the geoiplookup command to find the location of the IP address.

# Loop through the list of failed attempts and corresponding IP addresses.
grep Failed ${LOG_FILE} | awk '{print $(NF - 3)}' | sort | uniq -c | sort -nr |  while read COUNT IP
do
  # If the number of failed attempts is greater than the limit, display count, IP, and location.
  if [[ "${COUNT}" -gt "${LIMIT}" ]]
  then
    LOCATION=$(geoiplookup ${IP} | awk -F ', ' '{print $2}')
    echo "${COUNT},${IP},${LOCATION}"
  fi
done
exit 0





