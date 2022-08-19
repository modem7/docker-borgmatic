#!/bin/bash

# Version variables
dockerver=$(docker --version | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')
borgver=$(borg --version)
borgmaticver=$(borgmatic --version)
apprisever=$(apprise --version | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')

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

# Current crontab var
crontab=$(crontab -l)

# Output cron settings to console
printf "Cron job set as: \n$crontab\n"

# Start Cron
/usr/sbin/crond -f -L /dev/stdout
