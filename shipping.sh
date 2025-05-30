#!/bin/bash

source ./common.sh
app_name=

check_root
validate

echo "please enter root password"
read -s MYSQL_ROOT_PASSWORD



app_setup
maven_setup
systemd_setup

dnf install mysql -y
VALIDATE $? "installing mysql" 

mysql -h mysql.chinni.fun -u root -p$MYSQL_ROOT_PASSWORD -e 'use cities'
if [ $? -ne 0 ]
then
    mysql -h mysql.chinni.fun -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/schema.sql
    mysql -h mysql.chinni.fun -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/app-user.sql  
    mysql -h mysql.chinni.fun -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/master-data.sql
else 
    echo -e "data is already loaded into mysql...$Y skipping $N"
fi

systemctl restart shipping 

print_time