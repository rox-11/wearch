wearch
===

<h3> wearch v1.0.1 small tool designed to make word search in URL(s) by curl the website and use the specific word to looke for it and extract links in the URL(s)  </h3> 


## INSTALLATION :

```bash 
$ git clone https://github.com/rox-11/wearch
$ cd /wearch
$ chmod +x wearch.sh
```
if you dont have curl and grep: 

```bash
$ sudo pacman -S curl grep 
```
## USAGE :

```bash

-u URL        : Specify a URL to search"
-f FILE       : Specify a file containing URLs (one per line)
-w WORD       : Specify a single word to search (case-insensitive)
-l WORDLIST   : Specify a file with words to search (one per line)
-o OUTPUTFILE : Save output to this file (optional)
-s URL_SEARCH : Search and extract all link from the URL(s)
-h HELP       : Show this help message

$ ./wearch.sh -u https://exemple.com -w password -o output.txt
$ ./wearch.sh -f endpoint.txt -l list.txt -o output.txt
$ ./wearch.sh -u https://exemple.com -s

```
