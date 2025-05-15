#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

firstascii(){
echo  "                                                                                                    
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
                                                      ▎▏▍▏  "
sleep 1.5 
clear
}

firstascii
echo -e " ${CYAN}                     
                             _     
__      _____  __ _ _ __ ___| |__  
\ \ /\ / / _ \/ _  |  __/ __|  _ \ 
 \ V  V /  __/ (_| | | | (__| | | |
  \_/\_/ \___|\__,_|_|  \___|_| |_|
  			        v1.0.1 ${NC} "

while getopts ":u:f:w:" o; do
    case "${o}" in
        u)
            url="${OPTARG}"
            ;;
        f)
            file="${OPTARG}"
            ;;
        w)
            word="${OPTARG}"
            ;;
        *)
	    echo -e "${RED}Usage: $0 [-u url] [-f file] [-w word]${NC}"
            exit 1
            ;;
    esac
done

# curl from file or just typing url in u arg to grep the word value 
if [ ! -z "${url}" ]; then
    if [ -z "${word}" ]; then
        echo -e "${RED}Please specify a word to search with -w${NC}"
        exit 1
    fi
    curl -s "${url}" | grep -io --color=always "${word}"
elif [ ! -z "${file}" ]; then
    if [ -z "${word}" ]; then
        echo -e "${RED}Please specify a word to search with -w${NC}"
        exit 1
    fi
    while read -r line;do
	    echo -e "${YELLOW}search on the url${NC}: ${line}"
	   curl -s "${line}" | grep -io --color=always "${word}"
	   echo -e "${GREEN}>>>>>>>  task done : -----------------------------------------------${NC}"
    done < "${file}"
else
    echo -e "${RED}Please specify either a URL (-u) or a file (-f) and a word (-w) to search${NC}"
    exit 1
fi

