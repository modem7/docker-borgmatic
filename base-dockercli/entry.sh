#!/bin/sh

# Import your cron file
/usr/bin/crontab /etc/borgmatic.d/crontab.txt

#Variables
dockerver=$(docker --version | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')
borgver=$(borg --version)
borgmaticver=$(borgmatic --version)
apprisever=$(apprise --version | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')

#Software versions
echo docker $dockerver
echo borgmatic $borgmaticver
echo $borgver
echo apprise $apprisever

# Start cron
/usr/sbin/crond -f -L /dev/stdout
