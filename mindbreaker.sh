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

MOD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/modules" && pwd)"
declare -a MODFILES

for module in "${MOD_DIR}"/*.sh; do
    if [[ -f "$module" ]]; then
        # Erases the file path
        name="${module##*/}"
        # Removes the .sh extension
        noextname="${name%.sh}"
        
        MODFILES+=("$noextname")
    fi
done

function banner() {
    echo -e "${GREEN} ${BOLD}"
    cat <<EOF
     __  __ _           _ ____                 _             
    |  \/  (_)         | |  _ \               | |            
    | \  / |_ _ __   __| | |_) |_ __ ___  __ _| | _____ _ __ 
    | |\/| | | '_ \ / _  |  _ <| '__/ _ \/ _  | |/ / _ \ '__|
    | |  | | | | | | (_| | |_) | | |  __/ (_| |   <  __/ |   
    |_|  |_|_|_| |_|\__,_|____/|_|  \___|\__,_|_|\_\___|_|
EOF
}

function main() {

    while true; do
        clear
        banner
        echo -e "${BLUE}Options:"

        echo -e "${RED}========================"
        echo -e "¦ ${BLUE}${BOLD}Main menu ${RED}           ¦"
        echo -e "========================" 
        count=1

        # Show the menu
        echo -e "${CYAN} 0) ${PURPLE} exit"
        for i in "${MODFILES[@]}"; do
            echo -e "${CYAN} ${count}) ${PURPLE} ${i}"
            ((count++))
        done

        echo -e "${RESET}"
        read -r choice

        # Selection logic
        if [[ "$choice" == "0" ]]; then
            echo "Exiting..."
            exit 0
        elif [[ "$choice" -gt 0 && "$choice" -le ${#MODFILES[@]} ]]; then
            # Subtract 1 because the index starts in 0
            index=$((choice - 1))
            echo -e "${BLUE}[*] Opening module ${MODFILES[$index]}${RESET}"
            bash "${MOD_DIR}/${MODFILES[$index]}.sh"
        else
            echo "Not a valid option"
            sleep 1
        fi

    done
}

main