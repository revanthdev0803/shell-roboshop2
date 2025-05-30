#!/bin/bash

source ./common.sh

app_name=catalogue

check_root

validate

app_setup

nodejs_setup

systemd_setup


dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Installed Mongodb"

#To check wethere DB already exists or not 1 means exists lesser than 1 means not exists
STATUS=$(mongosh --host mongodb.chinni.fun --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $STATUS -lt 0 ]
then
    mongosh --host mongodb.chinni.fun </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Loaded data"
else
    echo -e "Catalogue DB already exists... $M SKIPPING $N"
fi

print_time