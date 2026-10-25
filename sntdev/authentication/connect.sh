#!/bin/bash
. /etc/openvpn/login/config.sh

my_public_ip=$(curl -s https://api.ipify.org)
server_id=$(mysql -u "$USER" -p"$PASS" -D "$DB" -h "$HOST" -N -s -e "SELECT server_id FROM server_list WHERE server_ip = '$my_public_ip' LIMIT 1;")

if [ -z "$server_id" ]; then
    server_id="$my_public_ip"
fi

dt=$(date +'%Y-%m-%d %H:%M:%S')
ts=$(date +%s)
bytes_received=${bytes_received:-0}
bytes_sent=${bytes_sent:-0}

mysql -u "$USER" -p"$PASS" -D "$DB" -h "$HOST" <<SQL
INSERT INTO bandwidth_logs (
    server,
    server_ip,
    server_port,
    since_connected,
    username,
    ipaddress,
    bytes_received,
    bytes_sent,
    bandwidth,
    time,
    time_in,
    time_out,
    status,
    timestamp,
    category
)
VALUES (
    '$server_id',
    '$trusted_ip',
    '$trusted_port',
    '$dt',
    '$common_name',
    '$trusted_ip:$trusted_port',
    '$bytes_received',
    '$bytes_sent',
    '0',
    '$dt',
    '$dt',
    '$dt',
    'online',
    '$ts',
    'premium'
)
ON DUPLICATE KEY UPDATE
    server_ip='$trusted_ip',
    server_port='$trusted_port',
    since_connected='$dt',
    time='$dt',
    time_in='$dt',
    status='online',
    timestamp='$ts',
    category='premium';

UPDATE users SET
    is_connected='1',
    login_status='online',
    device_connected='1',
    active_address='$my_public_ip',
    active_date='$dt',
    last_active_time='$dt'
WHERE user_name='$common_name';
SQL