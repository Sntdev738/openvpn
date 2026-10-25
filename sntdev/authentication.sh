#!/bin/bash
SHELL=/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
wget -O /etc/active.sh "$API_LINK/active.php?key=$API_KEY"
sleep 5
wget -O /etc/inactive.sh "$API_LINK/inactive.php?key=$API_KEY"
sleep 5
wget -O /etc/deleted.sh "$API_LINK/deleted.php?key=$API_KEY"
sleep 15
bash /etc/active.sh
sleep 15
bash /etc/inactive.sh
sleep 15
bash /etc/deleted.sh