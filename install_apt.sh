#! /bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "You need to run this script as root"
    exit -1
fi

echo "Installing dependencies."

sudo apt update && sudo apt upgrade -y

sudo apt install nmap snap -y
sudo snap install metasploit-framework

echo "Done."