wearch
===

<h3> wearch v1.0.1 small tool designed to make word search in urls by curl the website and use the specific word to looke for it </h3> 


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
-u : url search 
-f : file content search
-w : search word 
## $ ./wearch.sh -u https://exemple.com -w password
```
