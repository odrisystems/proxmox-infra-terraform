#!/bin/bash
# progress bar
"$@" &
printf "Packages are being installed..."
until grep "The system is finally up"  /var/log/cloud-init-output.log
do
  printf '\nplease wait...' > /dev/tty
  sleep 30
done
printf '\ninstallation complete.\n' > /dev/tty