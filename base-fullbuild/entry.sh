#!/bin/sh
# Import your cron file
/usr/bin/crontab /etc/borgmatic.d/crontab.txt
#Variables
borgver=$(borg --version)
borgmaticver=$(borgmatic --version)
#Software versions
echo borgmatic $borgmaticver
echo $borgver
# Start cron
/usr/sbin/crond -f -L /dev/stdout
