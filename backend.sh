#!/bin/bash

LOGS_DIR="/var/log/expense"
LOG_FILE_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
LOG_FILE=${LOGS_DIR}/${LOG_FILE_NAME}-${TIMESTAMP}.log

mkdir -p "$LOGS_DIR"

user_id=$(id -u)

validate_user(){
    if [ $1 -ne 0 ]; then
        log_error "please run the script with root preveledges"
        exit 1; 
    fi
}



validate(){
    if [ $1 -ne 0 ]; then
        log_error "$2 is FAILED."
        exit 1;
    else
        log_info "$2 is SUCCESS"
    fi
}


G=[32m
Y=[33m
R=[31m
N=[0m

log_info() {
    echo -e "\033$G $(date +'%Y-%m-%d %H:%M:%S') [INFO] $1\033$N"  | tee -a "$LOG_FILE" # Green for info
}

log_warning() {
    echo -e "\033[33m $(date +'%Y-%m-%d %H:%M:%S') [WARNING] $1\033[0m" | tee -a "$LOG_FILE" # Yellow for warnings
}

log_error() {
    echo -e "\033[7;31m $(date +'%Y-%m-%d %H:%M:%S') [ERROR] $1\033[0m" | tee -a "$LOG_FILE"  # Red for errors
}

echo "script started executing..."

validate_user $user_id

dnf module disable nodejs -y  &>>$LOG_FILE
validate $? "disable default nodejs version"

dnf module enable nodejs:20 -y  &>>$LOG_FILE
validate $? "enable nodejs:20 version"

dnf list installed nodejs &>>$LOG_FILE

if [ $? -ne 0 ]; then
    dnf install nodejs -y  &>>$LOG_FILE
    validate $? "installing nodejs"
else
    log_info "nodejs already installed"
fi

id expense &>>$LOG_FILE

if [ $? -eq 0 ]; then
    validate $? "user already existed"
else
    useradd expense  &>>$LOG_FILE
    validate $? "creating expense user"
fi
