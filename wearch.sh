#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

source logo.sh
firstascii

source help.sh

echo -e " ${CYAN}                     
                             _     
__      _____  __ _ _ __ ___| |__  
\ \ /\ / / _ \/ _  |  __/ __|  _ \ 
 \ V  V /  __/ (_| | | | (__| | | |
  \_/\_/ \___|\__,_|_|  \___|_| |_|
  			        v1.0.1 ${NC} "

TOTAL_MATCHES=0
output=""
search_links=0

while getopts ":u:f:w:l:o:sh" o; do
    case "${o}" in
        u) url="${OPTARG}" ;;
        f) file="${OPTARG}" ;;
        w) word="${OPTARG}" ;;
        l) wordlist="${OPTARG}" ;;
        o) output="${OPTARG}" ;;
        s) search_links=1 ;;
        h) show_help; exit 0 ;;
        *) show_help; exit 1 ;;
    esac
done

output_print() {
    if [[ -n "$output" ]]; then
        # Strip ANSI color codes before writing to file
        echo -e "$1" | sed 's/\x1b\[[0-9;]*m//g' >> "$output"
    else
        echo -e "$1"
    fi
}

extract_links_from_url() {
    local url="$1"
    output_print "${YELLOW}Extracting links from ${url}...${NC}"
    content=$(curl -s "$url")
    if [[ $? -ne 0 ]]; then
        output_print "${RED}Failed to fetch ${url}${NC}"
        return
    fi
    # Extract href links (basic, may miss some edge cases)
    links=$(echo "$content" | grep -oP '(?i)href=["'\''][^"'\''#>]+["'\'']' | sed -E 's/href=["'\'']([^"'\''#>]+)["'\'']/\1/' | sort -u)
    if [[ -n "$links" ]]; then
        if [[ -n "$output" ]]; then
            output_print "URL: ${url}"
        fi
        output_print "$links"
    else
        output_print "${RED}No links found in ${url}.${NC}"
    fi
}

search_word_in_url() {
    local url="$1"
    local word="$2"

    output_print "${YELLOW}Searching '${word}' in ${url}...${NC}"
    result=$(curl -s "$url")
    if [[ $? -ne 0 ]]; then
        output_print "${RED}Failed to fetch ${url}${NC}"
        return
    fi

    matches_plain=$(echo "$result" | grep -io "${word}")
    if [[ -n "$matches_plain" ]]; then
        count=$(echo "$matches_plain" | wc -l)
        TOTAL_MATCHES=$((TOTAL_MATCHES + count))
        if [[ -n "$output" ]]; then
            output_print "URL: ${url}"
            output_print "Word: ${word}"
        else
            output_print "${CYAN}URL: ${url}${NC}"
            output_print "${CYAN}Word: ${word}${NC}"
        fi
        matches_colored=$(echo "$result" | grep -io --color=always "${word}" | sed "s/^/found: /")
        output_print "$matches_colored"
    else
        output_print "${RED}No matches found for '${word}'.${NC}"
    fi
}

if [[ "$search_links" -eq 1 ]]; then
    # Link extraction mode
    if [[ -n "$url" ]]; then
        extract_links_from_url "$url"
    elif [[ -n "$file" ]]; then
        if [[ ! -f "$file" || ! -r "$file" ]]; then
            echo -e "${RED}File '${file}' does not exist or is not readable.${NC}"
            exit 1
        fi
        while read -r url_line; do
            [[ -z "$url_line" ]] && continue
            extract_links_from_url "$url_line"
            output_print "${GREEN}>>>>>>>  task done for ${url_line} : -----------------------------------------------${NC}"
        done < "$file"
    else
        echo -e "${RED}Please specify a URL (-u) or a file (-f) when using -s to search links.${NC}"
        exit 1
    fi
else
    # Existing search logic for word or wordlist
    if [[ -n "$url" ]]; then
        if [[ -n "$wordlist" ]]; then
            if [[ ! -f "$wordlist" || ! -r "$wordlist" ]]; then
                echo -e "${RED}Wordlist file '${wordlist}' does not exist or is not readable.${NC}"
                exit 1
            fi
            while read -r w; do
                [[ -z "$w" ]] && continue
                search_word_in_url "$url" "$w"
            done < "$wordlist"

        elif [[ -n "$word" ]]; then
            search_word_in_url "$url" "$word"
        else
            echo -e "${RED}Please specify a word (-w) or a wordlist (-l) to search.${NC}"
            exit 1
        fi

    elif [[ -n "$file" ]]; then
        if [[ ! -f "$file" || ! -r "$file" ]]; then
            echo -e "${RED}File '${file}' does not exist or is not readable.${NC}"
            exit 1
        fi
        if [[ -n "$wordlist" ]]; then
            if [[ ! -f "$wordlist" || ! -r "$wordlist" ]]; then
                echo -e "${RED}Wordlist file '${wordlist}' does not exist or is not readable.${NC}"
                exit 1
            fi
            while read -r url_line; do
                [[ -z "$url_line" ]] && continue
                while read -r w; do
                    [[ -z "$w" ]] && continue
                    search_word_in_url "$url_line" "$w"
                done < "$wordlist"
                output_print "${GREEN}>>>>>>>  task done for ${url_line} : -----------------------------------------------${NC}"
            done < "$file"

        elif [[ -n "$word" ]]; then
            while read -r url_line; do
                [[ -z "$url_line" ]] && continue
                search_word_in_url "$url_line" "$word"
                output_print "${GREEN}>>>>>>>  task done for ${url_line} : -----------------------------------------------${NC}"
            done < "$file"
        else
            echo -e "${RED}Please specify a word (-w) or a wordlist (-l) to search.${NC}"
            exit 1
        fi

    else 
        echo -e "${RED}Please specify either a URL (-u) or a file (-f) and a word (-w) or wordlist (-l) to search${NC}"
        show_help
        exit 1
    fi
fi

output_print "\n${GREEN}Total matches found: ${TOTAL_MATCHES}${NC}"
