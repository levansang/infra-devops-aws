#!/bin/bash 
# This script install Gitlab in your RHEL/Centos7 System

function install_gitlab {
    sudo yum update -y
    sudo yum install postfix -y
    sudo systemctl enable postfix
    sudo systemctl start postfix

    # Add the GitLab package repository
    curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash
    sudo EXTERNAL_URL="http://git.demo.akawork.io" yum install -y gitlab-ee
    echo "[SUCCESS] Gitlab installed complete!" >> $LOG_INSTALL
}

function check_service {
    if pgrep -x "$SERVICE" >/dev/null
    then
        echo "$SERVICE is running"
    else
        echo "$SERVICE stopped"
    fi
}

function main {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root" >> $LOG_INSTALL
        exit 1
    fi

    if [[ $OS == "centos" || $OS == "amazon" ]];
    then
        install_gitlab
    else
        echo "[ERROR] This operating system is not supported." >> $LOG_INSTALL
    fi
}

OS=$( cat /etc/*-release | grep 'NAME' | tr [:upper:] [:lower:] | grep -Poi '(ubuntu|centos|fedora|amazon)' | uniq )
SERVICE="gitlab"
LOG_INSTALL='/tmp/install_gitlab.log'
main

