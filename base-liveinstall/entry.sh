#!/bin/sh

# Variables
borgver=$(borg --version)
borgmaticver=$(borgmatic --version)

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

# Import your cron file
/usr/bin/crontab /etc/borgmatic.d/crontab.txt

# Software versions
docker --version
echo borgmatic $borgmaticver
echo $borgver

# Start cron
/usr/sbin/crond -f -L /dev/stdout