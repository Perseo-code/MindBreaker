#! /bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
RESET='\033[0m'
BOLD='\033[1m'


if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}${BOLD}→ You need to run this script as root${RESET}"
    exit 1
fi

echo -e "${CYAN}!Installing dependencies...!${RESET}"
declare -A DEPENDENCIES
DEPENDENCIES=( ["nmap"]="nmap" ["metasploit-framework"]="msfconsole" )
PKG_MANAGER=""

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [ -f /etc/debian_version ]; then
        PKG_MANAGER="apt install -y"
        PKG_UPDATE="apt update"
		echo -e "${CYAN}→ !Debian / based OS detected!${RESET}"
    elif [ -f /etc/arch-release ]; then
        PKG_MANAGER="pacman -S --noconfirm"
        PKG_UPDATE="pacman -Sy"
		echo -e "${CYAN}→ !Arch Linux / based OS detected!${RESET}"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    PKG_MANAGER="brew install"
    PKG_UPDATE="brew update"
	echo -e "${CYAN}→ !MacOS detected!${RESET}"
else
	echo -e "${RED}${BOLD}→ Your OS is not compatible with MindBreaker!${RESET}"
	exit 2
fi

eval "$PKG_UPDATE"

for d in "${!DEPENDENCIES[@]}"; do
    if command -v "${DEPENDENCIES[$d]}" >/dev/null 2>&1; then
        echo -e "${GREEN}${BOLD}→ Dependency $d already installed.${RESET}"
    else
        echo -e "${YELLOW}→ Installing dependency $d...${RESET}"
        
        if [ "$d" = "metasploit-framework" ]; then
            curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
            chmod 755 msfinstall
            ./msfinstall
            rm msfinstall 
        else
            echo -e "${YELLOW}→ Installing $d using detected package manager...${RESET}"
            eval "$PKG_MANAGER $d"
        fi

        
        STATUS=$?
        if [ $STATUS -ne 0 ]; then
            echo -e "${RED}${BOLD}→ Error! Error code: $STATUS${RESET}"
            exit 1
        else
            echo -e "${GREEN}${BOLD}→ Dependency $d successfully installed!${RESET}"
        fi
    fi    
done

echo -e "${CYAN}!Done installing dependencies!${RESET}"

echo -e "${CYAN}!Installing scripts...!${RESET}"
cd /opt
git clone https://github.com/Perseo-code/MindBreaker.git
cd MindBreaker

MINDBREAKER_PATH="/opt/MindBreaker"
echo -e "${CYAN}!Creating launcher...!${RESET}"

cat << EOF > /usr/bin/mindbreaker
#! /bin/bash

cd "$MINDBREAKER_PATH"
bash mindbreaker.sh

EOF

chmod +x /usr/bin/mindbreaker