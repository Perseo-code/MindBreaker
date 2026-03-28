#! /bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "You need to run this script as root"
    exit -1
fi

echo "Installing dependencies."

sudo dnf upgrade
sudo dnf install nmap

echo "Done."