#!/bin/bash
# OpenVPN authentication script with bcrypt
# Make sure python3-bcrypt is installed: sudo apt-get install python3-bcrypt -y

# Load DB config
. /etc/openvpn/login/config.sh

# Environment variables from OpenVPN
username="$username"
password="$password"

# 1. Fetch stored bcrypt hash for this user
Query="SELECT user_pass FROM users
       WHERE user_name='$username'
         AND is_freeze='0'
         AND duration > 0
       LIMIT 1"

stored_hash=$(mysql -u "$USER" -p"$PASS" -D "$DB" -h "$HOST" -sN -e "$Query")

# 2. Fail if user not found
if [ -z "$stored_hash" ]; then
    echo "authentication failed."
    exit 1
fi

# 3. Verify bcrypt using Python
is_valid=$(python3 - <<EOF
import bcrypt, sys
password = sys.argv[1].encode()
stored = sys.argv[2].encode()
print("ok" if bcrypt.checkpw(password, stored) else "fail")
EOF "$password" "$stored_hash")

# 4. Decide
if [ "$is_valid" = "ok" ]; then
    echo "user : $username"
    echo "authentication ok."
    exit 0
else
    echo "authentication failed."
    exit 1
fi
