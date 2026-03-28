#! /bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "You need to run this script as root"
    exit -1
fi

echo "Installing dependencies."
sudo pacman -Sy || echo "This is the arch linux script. If you're using another distro, please use the install.sh script." && exit 2

sudo pacman -S nmap metasploit

echo "Done."