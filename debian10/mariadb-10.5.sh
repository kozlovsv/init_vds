#!/bin/bash

#
# Automate mysql MariaDB installation and secure installation for debian-baed systems
# 
#  - You can set a password for root accounts.
#  - You can remove root accounts that are accessible from outside the local host.
#  - You can remove anonymous-user accounts.
#  - You can remove the test database (which by default can be accessed by all users, even anonymous users), 
#    and privileges that permit anyone to access databases with names that start with test_. 
#  For details see documentation: http://dev.mysql.com/doc/refman/5.7/en/mysql-secure-installation.html
#
# @version 13.08.2014 00:39 +03:00
# Tested on Debian 7.6 (wheezy)
#
# Usage:
#  Setup mysql root password:  ./install_mariadb_debian.sh 'your_new_root_password'
#  Change mysql root password: ./install_mariadb_debian.sh 'your_old_root_password' 'your_new_root_password'"
#

wget https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
echo "87b5498305ac32da5bafc161f3bc58d3d3331bf13b5601dda6940f1fb3fd2fbc mariadb_repo_setup" \
    | sha256sum -c -
chmod +x mariadb_repo_setup
sudo ./mariadb_repo_setup \
   --mariadb-server-version="mariadb-10.5"    
apt update   
apt -y -q install mariadb-server mariadb-backup

# Delete package expect when script is done
# 0 - No; 
# 1 - Yes.
PURGE_EXPECT_WHEN_DONE=0

#
# Check the bash shell script is being run by root
#
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

#
# Check input params
#
if [ -n "${1}" -a -z "${2}" ]; then
    # Setup root password
    CURRENT_MYSQL_PASSWORD=''
    NEW_MYSQL_PASSWORD="${1}"
elif [ -n "${1}" -a -n "${2}" ]; then
    # Change existens root password
    CURRENT_MYSQL_PASSWORD="${1}"
    NEW_MYSQL_PASSWORD="${2}"
else
    echo "Usage:"
    echo "  Setup mysql root password: ${0} 'your_new_root_password'"
    echo "  Change mysql root password: ${0} 'your_old_root_password' 'your_new_root_password'"
    exit 1
fi

#
# Check is expect package installed
#
if [ $(dpkg-query -W -f='${Status}' expect 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    echo "Can't find expect. Trying install it..."
    apt -y install expect

fi

SECURE_MYSQL=$(expect -c "
set timeout 3
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"$CURRENT_MYSQL_PASSWORD\r\"
expect \"root password?\"
send \"y\r\"
expect \"New password:\"
send \"$NEW_MYSQL_PASSWORD\r\"
expect \"Re-enter new password:\"
send \"$NEW_MYSQL_PASSWORD\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")

#
# Execution mysql_secure_installation
#
echo "${SECURE_MYSQL}"

if [ "${PURGE_EXPECT_WHEN_DONE}" -eq 1 ]; then
    # Uninstalling expect package
    apt -y remove expect
fi

mysql < init_db.sql
exit 0