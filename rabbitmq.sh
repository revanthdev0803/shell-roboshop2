#!/bin/bash

source ./common.sh
check_root
app_name=rabbitmq

echo "please enter  password"
read -s RABBITMQ_PASSWD

systemd_setup

rabbitmqctl add_user roboshop $RABBITMQ_PASSWD
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"