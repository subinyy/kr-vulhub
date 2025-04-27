#!/bin/bash

service mysql start

mysql -u root -e "UPDATE mysql.user SET plugin='mysql_native_password', password=PASSWORD('wrongpass') WHERE User='root'; FLUSH PRIVILEGES;"

tail -f /dev/null
