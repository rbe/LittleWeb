#!/usr/bin/env bash

echo -n "* Starting fcgiwrap... "
fcgiwrap -s unix:/var/run/fcgiwrap.socket -f &
sleep 5
chown nginx:nginx /var/run/fcgiwrap.socket
echo "done"
