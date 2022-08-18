#!/bin/bash

# Version variables
dockerver=$(docker --version | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')
borgver=$(borg --version)
borgmaticver=$(borgmatic --version)
apprisever=$(apprise --version | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')
crontab=$(crontab -l)

# Wait for internet connection
    echo "Waiting for Internet connection...."
        ./wtfc.sh -Q -T 5 ping -c 4 www.google.com
    echo "Internet connection established"

# Check variable to see if present, echo result
if [ -z "$LIVEINSTALL" ]
	then
		echo "Installing Docker-CLI"
	else
		echo "Installing $LIVEINSTALL"
fi

# Installing packages
apk update -q && apk add --no-cache -q ${LIVEINSTALL:-docker-cli}

# Software versions
echo docker $dockerver
echo borgmatic $borgmaticver
echo $borgver
echo apprise $apprisever

# Generate Cron variables
CRON="${CRON:-"0 1 * * *"}"
CRON_COMMAND="${CRON_COMMAND:-"borgmatic --stats -v 0 2>&1"}"

# Apply cron variables
echo "$CRON $CRON_COMMAND" > /etc/crontabs/root
if [ -v EXTRA_CRON ]
then
   echo "$EXTRA_CRON" >> /etc/crontabs/root
fi

# Output cron settings to console
printf "Cron job set as: \n$crontab\n"

# Start Cron
/usr/sbin/crond -f -L /dev/stdout