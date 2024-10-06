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
        log_error "$1 is FAILED."
    else
        log_info "$2 is SUCCESS"
    fi
}


G=[32m
Y=[33m
R=[31m
N=[0m

#\033 or \e we can use 

# log_info() {
#     echo -e "\033$G $(date +'%Y-%m-%d %H:%M:%S') [INFO] $1\033$N"  &>>"$LOG_FILE" # Green for info
# }

# log_warning() {
#     echo -e "\033[33m $(date +'%Y-%m-%d %H:%M:%S') [WARNING] $1\033[0m" &>>"$LOG_FILE" # Yellow for warnings
# }

# log_error() {
#     echo -e "\033[7;31m $(date +'%Y-%m-%d %H:%M:%S') [ERROR] $1\033[0m" &>>"$LOG_FILE"  # Red for errors
# }



log_info() {
    echo -e "\033$G $(date +'%Y-%m-%d %H:%M:%S') [INFO] $1\033$N"  | tee -a "$LOG_FILE" # Green for info
}

log_warning() {
    echo -e "\033[33m $(date +'%Y-%m-%d %H:%M:%S') [WARNING] $1\033[0m" | tee -a "$LOG_FILE" # Yellow for warnings
}

log_error() {
    echo -e "\033[7;31m $(date +'%Y-%m-%d %H:%M:%S') [ERROR] $1\033[0m" | tee -a "$LOG_FILE"  # Red for errors
}

validate_user $user_id

dnf list installed mysql-server &>>$LOG_FILE
if [ $? -eq 0 ]; then
    log_info "mysql-server aleady installed"
    exit 1;
fi

dnf install mysql-server -y &>>$LOG_FILE
validate $? "installing Mysql server"

systemctl enable mysqld &>>$LOG_FILE
validate $? "Enabling mysql service"

systemctl start mysqld &>>$LOG_FILE
validate $? "Starting mysql service"

mysql_secure_installation --set-root-pass ExpenseApp@1