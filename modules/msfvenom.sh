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

declare -A OPTIONS
OPTIONS=(
    ["PAYLOAD"]=""
    ["ENCODER"]=""
    ["ITERATIONS"]=5
    ["FORMAT"]=""
    ["LPORT"]=1234
    ["LHOST"]=""
    ["OUTPUT_FILE"]=""
    ["ARCH"]=""
    ["PLATFORM"]=""
)
# Templates
source "modules/.config/msfvenom.conf"

if [ -z "msfvenom" ]; then
    echo -e "${RED}[!] Please use the install script. You don't have msf installed."
    exit 1
fi
delayedtext() {
    local text="$1"
    local delay=0.02 
    
    for (( i=0; i<${#text}; i++ )); do
        echo -n "${text:$i:1}"
        sleep $delay
    done
    for i in {1..3}; do
        echo -n "_"
        sleep 0.5
        echo -ne "\b \b" 
        sleep 0.5
    done
}

executeMsfVenomCmd() {
    local flags=""
    if [ "$LHOST" != "" ]; then
        flags+=" LHOST=${LHOST}"
    else
        echo -e "${RED}[!] → You need to have a Local Host configured.${RESET}"
        return 1
    fi 
    if [ "$LPORT" != "" ]; then
        flags+=" LPORT=${LPORT}"
    else
        echo -e "${RED}[!] → You need to have a Local Port configured.${RESET}"
        return 2
    fi 

    if [ "$ARCH" != "" ]; then
        flags+=" -a ${ARCH}"
    else
        echo -e "${YELLOW}${BOLD}[-]${RESET} → No architecture specified. MsfVenom will automatically detect the script's architecture"
    fi

    if [ "$PLATFORM" != "" ]; then
        flags+=" --platform ${PLATFORM}"
    else
        echo -e "${YELLOW}${BOLD}[-]${RESET} → No platform specified, msfvenom will automatically detect the script's platform"
    fi
    if [ "$PAYLOAD" != "" ]; then
        flags+=" -p ${PAYLOAD}"
    else
        echo -e "${RED}[!] → There's no payload configured.${RESET}"
        return 3
    fi
    if [ "$ENCODER" != "" ]; then
        flags+=" -e ${ENCODER}"
        if [ "$ITERATIONS" != "" ]; then
            flags+=" -i ${ITERATIONS}"
        else
            echo -e "${YELLOW}${BOLD}[-] → There's no specific encoding iterations. Will default to 5."
            ITERATIONS=5
            flags+=" -i ${ITERATIONS}"
        fi
    else
        echo -e "${YELLOW}${BOLD}[-] → There's no encoder configured, raw binary will be output."
    fi
    
    if [ "$OUTPUT_FILE" != "" ]; then
        flags+=" -o ${OUTPUT_FILE}"
    else
        echo "${RED}${BOLD}[!!] → FATAL: No output file specificated. Please use 'set output /path/to/file'"
        return -1
    fi

    if [ "$FORMAT" != "" ]; then
        flags+=" -f ${FORMAT}"
    else
        echo "${YELLOW}${BOLD}[-] → No format specified. Outputting raw payload"
    fi

    # Execute msfvenom
    eval "msfvenom ${flags}"
}

loadTemplate() {
    declare -n template=$1
    if [ -z "$1" ]; then
        echo -e "${RED}[!] → Unknown template ${RESET}"
    fi

    # Add all the configuration.
    for opt in ${!OPTIONS[@]}; do
        OPTIONS["$opt"]="${template[$opt]}"
    done
    echo -e "${BLUE}[*]${RESET} Template ${template['name']} successfully loaded"
    echo -e "${GREEN}${BOLD}[·]${RESET} Remember to set the LHOST and output variables"
}

function show_options() {
    echo -e "\n${BLUE}${BOLD}Netcat Module Options:${RESET}"
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

parseShell() {
    case "$1" in
        "exit")
            exit 0
        ;;

        "set"*)
            local text="$1"
            local option="${text:4}"
            if [[ "${option}" = "payload"* ]]; then
                PAYLOAD="${option:8}"
                echo -e "${BLUE}[*]${RESET} Set payload → ${OPTIONS['PAYLOAD']}"
            elif [[ "${option}" = "LPORT"* ]]; then
                OPTIONS["LPORT"]="${option:6}"
                echo -e "${BLUE}[*]${RESET} Set LPORT → ${OPTIONS['LPORT']}"
            elif [[ "${option}" = "LHOST"* ]]; then
                OPTIONS["LHOST"]="${option:6}"
                echo -e "${BLUE}[*]${RESET} Set LHOST → ${OPTIONS['LHOST']}"
            elif [[ "${option}" = "encoder"* ]]; then
                OPTIONS["ENCODER"]="${option:8}"
                echo -e "${BLUE}[*]${RESET} Set encoder → ${OPTIONS['ENCODER']}"
            elif [[ "${option}" = "iterations"* ]]; then
                if [ "${ENCODER}" = "" ]; then
                    echo -e "${YELLOW}${BOLD}[-]${RESET} → Encoder not specified, remember to specify it."
                fi

                OPTIONS["ITERATIONS"]="${option:11}"
                echo -e "${BLUE}[*]${RESET} Set iterations → ${OPTIONS['ITERATIONS']}"
            elif [[ "${option}" = "format"* ]]; then
                OPTIONS["FORMAT"]="${option:6}"
                echo -e "${BLUE}[*]${RESET} Set format → ${OPTIONS['FORMAT']}"
            elif [[ "${option}" = "output"* ]]; then
                OUTPUT["OUTPUT_FILE"]="${option:7}"
                echo -e "${BLUE}[*]${RESET} Set output path → ${OPTIONS['OUTPUT_FILE']}"
            elif [[ "${option}" = "arch"* ]]; then
                OUTPUT["ARCH"]="${option:5}"
                echo -e "${BLUE}[*]${RESET} Set arch → ${OPTIONS['ARCH']}"
            else
                echo -e "${RED}[!] → No option selected."
            fi
        ;;

        "run")
            executeMsfVenomCmd
        ;;
        
        "exec"*)
            local text="$1"
            local option="${text:5}"
            echo -e "${BLUE}[*]${RESET} Executing '${option}'"
            eval "${option}"
        ;;

        "help")
            echo -e "${BOLD}${GREEN}→ MsfVenom Helper Help."
            echo -e "Commands:"
            echo -e "show options - see the options available."
            echo -e "set <option> - Set a variable"
            echo -e "run - Start generating the payload."
            echo -e "exec <linux command> - Use any command while being in the msfvenom shell"
            echo -e "use <template> - Load a template. Templates are "
        ;;
        
        "show options")
            show_options
        ;;

        "use"*)
            local text="$1"
            local selected_template="${text:4}"
            loadTemplate "$selected_template"
        ;;
        "*")
            echo -e "${RED}[!] → Unknown command"
        ;;
    esac
}

clear

delayedtext "→ Initializing Msfvenom Helper"


echo -e "\n${RED}========================"
echo -e "¦${BLUE}${BOLD}MsfVenom Helper ${RED}      ¦"
echo -e "========================"

sleep 1
while true; do
    echo -n -e "${BLUE}MsfVenom → ${RESET}"
    read -r choice
    parseShell "$choice"
done