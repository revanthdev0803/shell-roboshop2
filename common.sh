#!/bin/bash

START_TIME=$(date +%s)
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
M="\e[35m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)       #It will split the scriptName and gives only 10-logs which is field 1
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo -e "$M Script executing at : $N $(date)"  | tee -a $LOG_FILE

#we are checking that if user was not equal to zero or not
#root user id will be zero,if not we will give error
app_setup(){
    id roboshop &>>$LOG_FILE
    if [ $? -ne 0 ]
    then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
        VALIDATE $? "Created roboshop user"
    else
        echo -e "Roboshop User already exists... $Y SKIPPING $N"
    fi

    mkdir -p /app &>>$LOG_FILE
    VALIDATE $? "Created app dir"


    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOG_FILE
    VALIDATE $? "Downloaded the $app_name service"

    rm -rf /app/*
    cd /app 
    unzip /tmp/$app_name.zip &>>$LOG_FILE
    VALIDATE $? "Unzipped the $app_name service"

}


nodejs_setup(){
    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "Disabled existing nodejs version"

    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "Enabled required nodejs version"

    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "Installed nodejs"

    npm install &>>$LOG_FILE
    VALIDATE $? "Installed npm pkgm"
}

systemd_setup(){

    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service &>>$LOG_FILE
    VALIDATE $? "$app_name service pasted in systemd"

    systemctl daemon-reload &>>$LOG_FILE
    VALIDATE $? "Loaded the service"

    systemctl enable $app_name &>>$LOG_FILE
    systemctl start $app_name &>>$LOG_FILE
    VALIDATE $? "$app_name service started"

}



maven_setup(){

    dnf install maven -y
    VALIDATE $? "installing maven"
    mvn clean package 
    VALIDATE $? "packing the shipping"

    mv target/shipping-1.0.jar shipping.jar 
    VALIDATE $? "moving and renaming jar file"

}
check_root(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$R Erorr....$N please run with root user" | tee -a $LOG_FILE 
        exit 1 #give any number except zero for checking status
    else
        echo "you are the root user" |&>>$LOG_FILE
    fi
}

 #we use this function if given one is installed or not ,to reduce the steps we use this
 #here we are sending two arguments to the function one is exit status as $1=$? $2=is the package name to install
VALIDATE(){

    if [ $1 -eq 0 ]
    then
        echo -e "$2 is $G succesfull $N" | tee -a $LOG_FILE 
    else
        echo "$2 is fail" | tee -a $LOG_FILE 
        exit 1
    fi
}

print_time(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(($END_TIME - $START_TIME))
    echo -e "SCript executed sucessfully. $Y Time taken: $TOTAL_TIME seconds $N"

}



