show_help() {
    echo -e "${CYAN}Usage: $0 [-u url] [-f file] [-w word] [-l wordlist] [-s] [-o outputfile]"
    echo "  -u URL        : Specify a URL to search"
    echo "  -f FILE       : Specify a file containing URLs (one per line)"
    echo "  -w WORD       : Specify a single word to search (case-insensitive)"
    echo "  -l WORDLIST   : Specify a file with words to search (one per line)"
    echo "  -s            : Search and extract all links from the URL(s)"
    echo "  -o OUTPUTFILE : Save output to this file (optional)"
    echo "  -h            : Show this help message${NC}"
}
export show_help
