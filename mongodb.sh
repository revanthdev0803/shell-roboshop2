#!/bin/bash

source ./common.sh
app_name=mongodb
check_root
validate

cp mongo.repo /etc/yum.repos.d/mongodb.repo
VALIDATE $? "coping Mongodb repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "installing mongo db server"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "enabiling mongo"

systemctl start mongod &>>$LOG_FILE
VALIDATE $? "starting mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "EDITING MONGODB CONF FILE FOR REMOTE CONNECTIONS"

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "Restarting Mongodb" 

print_time