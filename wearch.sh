#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

firstascii(){
cat <<'EOF'
                                                                                                    
                                                     ▏▍▁▁▁▁▁▁▁▁▍▏                                   
                                                   ▍▂▇██▅▄▊▋▌▄▄█▅▌                                  
                                                 ▏▉█▆▄▇████▇▆█▇█▄▃▊                                 
                                                 ▋▊ ▍▅▆▊▅██████▉▇▄▊▉▏                               
                                                 ▃  ▋▆███▆▌▇██▅▅██▏▊▊                               
                                                 ▃   ▏▍▁▌▏▍████▆▅▍  ▁▌                              
                                                 ▃      ▌▋▂▂▂▂▁▁▊▊▌ ▎▂                              
                                                 ▁▌                 ▎▁                              
                                               ▏▎▂▅▉▎               ▊▉                              
                                             ▎▁▄██▆█▇▃▊▏             ▉▊                             
                                         ▏▌▁▄██▅▆▃▂▁▂▆▅▅▍            ▏▉▋                            
                                     ▏▉▂▇█████▅▁▄▉▅▇▆▁▄▌▎             ▋▊                            
                               ▏▎▁▁▄████████▃▇███▄▃▃▂▂█▃▎             ▉▌                            
                             ▎▂██████████████▃▇███████▇▊▏             ▃                             
                        ▊▊▄▅▆███████████████████████▅▂▎             ▎▂▎                             
                        ▊▂▄▇▇▄▃▃▃▃▃▃▆████████▆▅▃▅▅▋▍              ▎▉▋▏                              
                                     ▌▂▅██▅▉▎▏▌▍▏▏▏▌▋ ▏▏   ▏▎▎▊▌▉▉▊▏                                
                                       ▏▌▄▇█▁▂▉▂▉▊▎▍▅▉▋▃▄▄▆▆█▇▆▂▄▏                                  
                                         ▍▃▍   ▎▊██████▅▍▍▌▍▇▄▅▇▌                                   
                                       ▏▍▁▍ ▋▉▊▊▌▌▍▍▊▄█▇▃▌  ▍▉▊                                     
                                       ▍▁▃▃▉▍▏       ▎▆▅▄▊                                          
                                                      ▎▏▍▏  
EOF
sleep 1.5
clear
}

show_help() {
    echo -e "${CYAN}Usage: $0 [-u url] [-f file] [-w word]"
    echo "  -u URL   : Specify a URL to search"
    echo "  -f FILE  : Specify a file containing URLs (one per line)"
    echo "  -w WORD  : Specify the word to search for (case-insensitive)"
    echo "  -h       : Show this help message${NC}"
}

firstascii
echo -e " ${CYAN}                     
                             _     
__      _____  __ _ _ __ ___| |__  
\ \ /\ / / _ \/ _  |  __/ __|  _ \ 
 \ V  V /  __/ (_| | | | (__| | | |
  \_/\_/ \___|\__,_|_|  \___|_| |_|
  			        v1.0.1 ${NC} "

TOTAL_MATCHES=0

while getopts ":u:f:w:h" o; do
    case "${o}" in
        u) url="${OPTARG}" ;;
        f) file="${OPTARG}" ;;
        w) word="${OPTARG}" ;;
        h) show_help; exit 0 ;;
        *) show_help; exit 1 ;;
    esac
done

if [[ -n "${url}" ]]; then
    if [[ -z "${word}" ]]; then
        echo -e "${RED}Please specify a word to search with -w${NC}"
        exit 1
    fi
    echo -e "${YELLOW}Searching '${word}' in ${url}...${NC}"
    result=$(curl -s "${url}")
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Failed to fetch ${url}${NC}"
        exit 1
    fi
    matches=$(echo "$result" | grep -io --color=always "${word}")
    if [[ -n "$matches" ]]; then
        count=$(echo "$matches" | wc -l)
        TOTAL_MATCHES=$((TOTAL_MATCHES + count))
        echo "$matches" | sed "s/^/found: /"
    else
        echo -e "${RED}No matches found.${NC}"
    fi

elif [[ -n "${file}" ]]; then
    if [[ -z "${word}" ]]; then
        echo -e "${RED}Please specify a word to search with -w${NC}"
        exit 1
    fi
    if [[ ! -f "${file}" || ! -r "${file}" ]]; then
        echo -e "${RED}File '${file}' does not exist or is not readable.${NC}"
        exit 1
    fi
    while read -r line; do
        [[ -z "$line" ]] && continue
        echo -e "${YELLOW}Searching '${word}' in URL: ${line}${NC}"
        result=$(curl -s "${line}")
        if [[ $? -ne 0 ]]; then
            echo -e "${RED}Failed to fetch ${line}${NC}"
            continue
        fi
        matches=$(echo "$result" | grep -io --color=always "${word}")
        if [[ -n "$matches" ]]; then
            count=$(echo "$matches" | wc -l)
            TOTAL_MATCHES=$((TOTAL_MATCHES + count))
            echo "$matches" | sed "s/^/found: /"
        else
            echo -e "${RED}No matches found.${NC}"
        fi
        echo -e "${GREEN}>>>>>>>  task done : -----------------------------------------------${NC}"
    done < "${file}"

else 
    echo -e "${RED}Please specify either a URL (-u) or a file (-f) and a word (-w) to search${NC}"
    show_help
    exit 1
fi

echo -e "\n${GREEN}Total matches found: ${TOTAL_MATCHES}${NC}"

