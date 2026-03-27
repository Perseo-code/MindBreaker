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
    echo -e "${RED}[!] You need to run as root. Some commands require root privileges"
    sleep 2
    exit 1
fi



OPTIONS=(
    "ip"
    "flags"
)

RHOST=""
FLAGS=""
function executeNmapCommand() {
    local flags="$FLAGS"
    local ip="$RHOST"
    if [[ "$flags" =~ "-O" ]]; then
        sudo nmap $ip $flags || echo -e "${RED} Error."
    fi
    nmap $flags $ip || echo -e "${RED} Error."
}

function parseShell() {
    case "$1" in
        "exit")
            exit 0
        ;;
        "set "*)
            local text=$1
            # REMEMBER: Think about the space.
            local option=${text:4}
            
            if [[ "${option}" = "ip"* ]]; then
                RHOST=${text:7}
                echo -e "${CYAN}[+] IP set to: $RHOST"
            elif [[ "${option}" = "flags"* ]]; then
                FLAGS=${text:10}
                echo -e "${CYAN}[+] FLAGS set to: $FLAGS"
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
    echo -e "${RED}========================"
    echo -e "¦${BLUE}${BOLD}Nmap Module ${RED}¦"
    echo -e "========================"
    echo -n -e "${RED}Nmap > ${RESET}"
    read -r command
    parseShell "$command"
done


