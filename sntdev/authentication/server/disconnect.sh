#!/bin/bash
. /etc/openvpn/login/config.sh

# You can set server IP if you want to record it; otherwise ignore or remove
server_ip="YOUR_SERVER_PUBLIC_IP"

# Get times
tm=$(date +%s)
dt=$(date +"%Y-%m-%d %H:%M:%S")
timestamp=$(date +"%FT%TZ")

# Update the bandwidth record to offline
mysql -u "$USER" -p"$PASS" -D "$DB" -h "$HOST" -e \
  "UPDATE bandwidth_logs 
   SET bytes_received='$bytes_received',
       bytes_sent='$bytes_sent',
       time_out='$dt',
       status='offline'
   WHERE username='$common_name'
     AND status='online'"

# Update user status
mysql -u "$USER" -p"$PASS" -D "$DB" -h "$HOST" -e \
  "UPDATE users 
   SET is_connected='0',
       active_address='',
       active_date=''
   WHERE user_name='$common_name'"
