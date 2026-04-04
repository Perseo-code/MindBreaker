# Netcat module

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
RESET='\033[0m'
BOLD='\033[1m'

declare -A MODES
MODES=( 
    ["LISTEN"]="" # Server mode (IP will be ignored if this is true)
    ["PORT"]="" # The port will be ignored if this becomes false 
    ["VERBOSE"]="" # Will show additional information. 
    ["NUMERIC"]="" # Will avoid DNS resolution, only 'raw' IPs allowed 
    ["ZERO-IO"]="" # Scan mode. ["UDP"]="" # Forces netcat to use the UDP protocol 
    ["EXECUTE"]="" # Executes something after successful connection (deprecated) 
    ["WAIT"]="" 
    ["KEEP-OPEN"]=""
    ["IP"]="" # Client mode. (Listen must be false)
)

function build_nc_command() {
    local cmd="nc"
    local target_ip=$1
    local flags=""

    [[ "${MODES[LISTEN]}" == "true" ]]    && flags+=" -l"
    [[ "${MODES[VERBOSE]}" == "true" ]]   && flags+=" -v"
    [[ "${MODES[NUMERIC]}" == "true" ]]   && flags+=" -n"
    [[ "${MODES[ZERO-IO]}" == "true" ]]   && flags+=" -z"
    [[ "${MODES[UDP]}" == "true" ]]       && flags+=" -u"
    [[ "${MODES[KEEP-OPEN]}" == "true" ]] && flags+=" -k"

    [[ -n "${MODES[WAIT]}" ]]    && flags+=" -w ${MODES[WAIT]}"
    [[ -n "${MODES[EXECUTE]}" ]] && flags+=" -e ${MODES[EXECUTE]}"

    cmd+="$flags"

    local final_port="${MODES[PORT]:-$LISTENPORT}"

    if [[ "${MODES[LISTEN]}" == "true" ]]; then
        echo -e "${YELLOW}→ Initializing server on port $final_port...${RESET}"
        eval $cmd -p "$final_port"
    else
        if [[ -z "$target_ip" ]]; then
            echo -e "${RED}→ Error: The client mode requires a target IP.${RESET}"
            return 1
        fi
        echo -e "${GREEN}→ Connecting to $target_ip:$final_port...${RESET}"
        eval $cmd "$target_ip" "$final_port"
    fi
}

function show_options() {
    echo -e "\n${BLUE}${BOLD}Netcat Module Options:${RESET}"
    echo -e "${WHITE}==========================================${RESET}"
    printf "${CYAN}%-15s %-20s${RESET}\n" "OPTION" "CURRENT VALUE"
    echo -e "${WHITE}------------------------------------------${RESET}"

    for opt in "${!MODES[@]}"; do
        local val="${MODES[$opt]}"
        
        # English status labels
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
        "show options")
            show_options
        ;;

        "set"*)
            local text="$1"
            local content="${text:4}" 
            
            for o in "${!MODES[@]}"; do
                if [[ "$content" == "$o"* ]]; then
                    
                    local len=${#o}
                    local value="${content:$((len + 1))}"
                    MODES[$o]=$(echo "$value" | xargs)
                    
                    echo -e "${GREEN}→ Configured $o = ${MODES[$o]}${RESET}"
                    return
                fi
            done
            echo -e "${RED}→ Unknown option.${RESET}"
        ;;

        "run")
            build_nc_command
        ;;

        "netcat-help")
            nc --help
        ;;

        "help")
            echo -e "${PURPLE}→ Help; ${RESET}"
            echo -e "help - Shows this help"
            echo -e "netcat-help - Shows the netcat official help generated with the command nc --help"
            echo -e "set <option> - Will configure an option"
            echo -e "show options - Shows the configured options."
            echo -e "run - executes the generated netcat command"
            echo -e "exit - exits the netcat helper."
        ;;

        "exit")
            exit 0
        ;;
    esac
}

while true; do
    echo -e -n "NetCat → "
    read -r choice
    parseShell "$choice"
done
