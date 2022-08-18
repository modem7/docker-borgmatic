#!/bin/sh

# Generate Cron variables
export CRON=${CRON:-"0 1 * * *"}
export CRON_COMMAND=${CRON_COMMAND:-"borgmatic --stats -v 0 2>&1"}

# Variables
dockerver=$(docker --version | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')
borgver=$(borg --version)
borgmaticver=$(borgmatic --version)
apprisever=$(apprise --version | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')

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

# Output cron settings to console
echo "Cron job set as: \"$CRON $CRON_COMMAND\""

# Software versions
echo docker $dockerver
echo borgmatic $borgmaticver
echo $borgver
echo apprise $apprisever

# Start cron
echo "$CRON $CRON_COMMAND" > /etc/crontabs/root
/usr/sbin/crond -f -L /dev/stdout
