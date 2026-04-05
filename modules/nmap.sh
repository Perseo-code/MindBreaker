# An nmap-based console
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
RESET='\033[0m'
BOLD='\033[1m'

if [ $EUID -ne 0 ]; then
    echo -e "${RED}[!] You need to run as root. Some commands require root privileges.${RESET}"
    sleep 2
    exit 1
fi



declare -A OPTIONS

OPTIONS=(
    ["ip"]=""
    ["flags"]=""
)

clear
echo -e "${BLUE}${BOLD}"
cat << EOF
 _   _                         __  __           _ 
| \ | |_ __ ___   __ _ _ __   |  \/  | ___   __| |
|  \| | '_   _ \ / _  | '_ \  | |\/| |/ _ \ / _  |
| |\  | | | | | | (_| | |_) | | |  | | (_) | (_| |
|_| \_|_| |_| |_|\__,_| .__/  |_|  |_|\___/ \__,_|
                      |_|                   
EOF
echo -e "${RESET}"


function executeNmapCommand() {
    local flags="${OPTIONS['flags']}"
    local ip="${OPTIONS['ip']}"
    if [[ -z "${OPTIONS['ip']}" ]]; then
        echo -e "${RED}[!] Error: Debes configurar una IP antes de ejecutar 'run'.${RESET}"
        return
    fi

    if [[ "$flags" =~ "-O" ]]; then
        sudo nmap $flags $ip
    else
        nmap $flags $ip
    fi
}

function show_options() {
    echo -e "\n${BLUE}${BOLD}Nmap Module Options:${RESET}"
    echo -e "${WHITE}==========================================${RESET}"
    printf "${CYAN}%-15s %-20s${RESET}\n" "OPTION" "CURRENT VALUE"
    echo -e "${WHITE}------------------------------------------${RESET}"

    for opt in "${!OPTIONS[@]}"; do
        local val="${OPTIONS[$opt]}"
        
        if [[ -z "$val" ]]; then
            val="${YELLOW}[Not Set]${RESET}"
        else
            val="${GREEN}$val${RESET}"
        fi

        printf "%-15s %b\n" "$opt" "$val"
    done
    
    echo -e "${WHITE}==========================================${RESET}\n"
}

function parseShell() {
    case "$1" in
        "exit")
            exit 0
        ;;

        "show options")
            show_options
        ;;
        "set "*)
            local text=$1
            # REMEMBER: Think about the space.
            local option=${text:4}
            
            if [[ "${option}" = "ip"* ]]; then
                OPTIONS["ip"]=${text:7}
                echo -e "${CYAN}[+] IP set to: ${OPTIONS['ip']}"
            elif [[ "${option}" = "flags"* ]]; then
                OPTIONS["flags"]=${text:10}
                echo -e "${CYAN}[+] FLAGS set to: ${OPTIONS['flags']}"
            else
                echo -e "${RED}[!] set: Unknown option"
            fi
        ;;

        "run")
            executeNmapCommand $FLAGS $RHOST
        ;;

        "help")
            echo -e "${BLUE}Nmap module help:"
            echo -e "${BOLD}${YELLOW}Options:"
            echo -e "flags: nmap config session (See nmap config)"
            echo -e "E.g. set flags -sn"
            echo -e "${CYAN}Running the command:"
            echo -e "run"
            echo -e "${RESET}"
        ;;

        "nmap-help")
            nmap --help
        ;;

        *) 
            echo -e "${RED}[!] Unknown option"
        ;;

    esac
}

while true; do
    echo -n -e "${RED}Nmap → ${RESET}"
    read -r command
    parseShell "$command"
done


