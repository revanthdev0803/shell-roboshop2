#!/bin/bash

source ./common.sh

check_root
validate
app_name=payment


dnf install python3 gcc python3-devel -y &>>$LOG_FILE
VALIDATE $? "Installing python 3"

app_setup

pip3 install -r requirements.txt
VALIDATE $? "Installing pip3"

systemd_setup