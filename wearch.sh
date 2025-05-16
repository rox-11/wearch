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
    echo -e "${CYAN}Usage: $0 [-u url] [-f file] [-w word] [-o outputfile]"
    echo "  -u URL        : Specify a URL to search"
    echo "  -f FILE       : Specify a file containing URLs (one per line)"
    echo "  -w WORD       : Specify the word to search for (case-insensitive)"
    echo "  -o OUTPUTFILE : Save output to this file (optional)"
    echo "  -h            : Show this help message${NC}"
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
output=""

while getopts ":u:f:w:o:h" o; do
    case "${o}" in
        u) url="${OPTARG}" ;;
        f) file="${OPTARG}" ;;
        w) word="${OPTARG}" ;;
        o) output="${OPTARG}" ;;
        h) show_help; exit 0 ;;
        *) show_help; exit 1 ;;
    esac
done

output_print() {
    if [[ -n "$output" ]]; then
        # Strip ANSI color codes before writing to file
        echo -e " $1" | sed 's/\x1b\[[0-9;]*m//g' >> "$output"
    else
        echo -e "$1"
    fi
}

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
    matches_plain=$(echo "$result" | grep -io "${word}")
    if [[ -n "$matches_plain" ]]; then
        count=$(echo "$matches_plain" | wc -l)
        TOTAL_MATCHES=$((TOTAL_MATCHES + count))
        matches_colored=$(echo "$result" | grep -io --color=always "${word}" | sed "s/^/found: /")
        output_print "$matches_colored"
    else
        output_print "${RED}No matches found.${NC}"
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
        output_print "${YELLOW}Searching '${word}' in URL: ${line}${NC}"
        result=$(curl -s "${line}")
        if [[ $? -ne 0 ]]; then
            output_print "${RED}Failed to fetch ${line}${NC}"
            continue
        fi
        matches_plain=$(echo "$result" | grep -io "${word}")
        if [[ -n "$matches_plain" ]]; then
            count=$(echo "$matches_plain" | wc -l)
            TOTAL_MATCHES=$((TOTAL_MATCHES + count))
            matches_colored=$(echo "$result" | grep -io --color=always "${word}" | sed "s/^/found : /")
            output_print "$matches_colored"
        else
            output_print "${RED}No matches found.${NC}"
        fi
        output_print "${GREEN}>>>>>>>  task done : -----------------------------------------------${NC}"
    done < "${file}"

else 
    echo -e "${RED}Please specify either a URL (-u) or a file (-f) and a word (-w) to search${NC}"
    show_help
    exit 1
fi

output_print "\n${GREEN}Total matches found: ${TOTAL_MATCHES}${NC}"

