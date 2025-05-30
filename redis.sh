#!/bin/bash

source ./common.sh
check_root
validate

dnf module disable redis -y
VALIDATE $? "disabling redis"

dnf module enable redis:7 -y
VALIDATE $? "enabling redis"

dnf install redis -y 
VALIDATE $? "installing redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "edited redis.conf to accept remote connections".

systemctl enable redis
VALIDATE $? "enabling redis"

systemctl start redis
VALIDATE $? "starting redis"

print_time
