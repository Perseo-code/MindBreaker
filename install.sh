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

SELECTED_RC=".bashrc" # or .zshrc (Also pretty optional, but recommended if developing scripts)
MINDBREAKER_PATH="/opt/MindBreaker"

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}${BOLD}→ You need to run this script as root${RESET}"
    exit 1
fi



echo -e "${CYAN}→ Installing missing dependencies...←${RESET}"
declare -A DEPENDENCIES
DEPENDENCIES=( ["nmap"]="nmap" ["metasploit-framework"]="msfconsole" ["netcat"]="nc" ["git"]="git" )
PKG_MANAGER=""
NC_CMD="nc"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [ -f /etc/debian_version ]; then
        PKG_MANAGER="apt install -y"
        PKG_UPDATE="apt update"
        NC_PKG="netcat-traditional"
		echo -e "${CYAN}→ !Debian / based OS detected! ←${RESET}"
    elif [ -f /etc/arch-release ]; then
        PKG_MANAGER="pacman -S --noconfirm"
        PKG_UPDATE="pacman -Sy"
        NC_PKG="gnu-netcat"
		echo -e "${CYAN}→ Arch Linux / based OS detected! ←${RESET}"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    PKG_MANAGER="brew install"
    PKG_UPDATE="brew update"
	echo -e "${CYAN}→ MacOS detected ←${RESET}"
else
	echo -e "${RED}${BOLD}→ Your OS is not compatible with MindBreaker! ←${RESET}"
	exit 2
fi

DEPENDENCIES["$NC_PKG"]="$NC_CMD"
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

echo -e "${CYAN}→ Done installing missing dependencies!${RESET}"


echo -e "${CYAN}→ Adding environment variables in the shell..."

cat << EOF >> /home/$SUDO_USER/$SELECTED_RC
export MODULEDIR="$MINDBREAKER_PATH/modules"
export MINDBREAKER_PATH="$MINDBREAKER_PATH"
EOF

if [ -e "$MINDBREAKER_PATH" ]; then
    echo -e "${CYAN}${BOLD}→ MindBreaker folder detected!"
    echo -e "→ Starting update... ←${RESET}"
    cd "$MINDBREAKER_PATH"
    git pull || echo "${RED}${BOLD}→ Something went wrong during the installation... ←" && exit -1

    echo -e "${GREEN}${BOLD}→ MindBreaker successfully updated & ready to go! ←${RESET}"
    exit 0
fi

echo -e "${CYAN}→ Installing scripts...${RESET}"
cd /opt
git clone https://github.com/Perseo-code/MindBreaker.git
cd MindBreaker

echo -e "${CYAN}→ Creating launcher...${RESET}"

cat << EOF > /usr/bin/mindbreaker
#! /bin/bash

cd "$MINDBREAKER_PATH"
bash mindbreaker.sh

EOF

echo -e "${CYAN}→ Changing permissions and ownership...${RESET}"
chmod +x /usr/bin/mindbreaker
chown -R $SUDO_USER:$SUDO_USER $MINDBREAKER_PATH

echo -e "${GREEN}${BOLD}→ Installation Finished successfully!${RESET}"
echo -e "${GREEN}${BOLD}→ The location of the files is in $MINDBREAKER_PATH"