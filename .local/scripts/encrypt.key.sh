#!/bin/bash
# Purpose: Encrypt the totp secret stored in $dir/$service/.key file
# Author: Vivek Gite {https://www.cyberciti.biz/} under GPL v 2.x or above
# Modified: 2026-09-11T22+02:00 Artem Zhukovskyi under GPL v 2.x or above
# --------------------------------------------------------------------------
# https://stackoverflow.com/questions/29436275/how-to-prompt-for-yes-or-no-in-bash
function yes_or_no {
    while true; do
        read -p "$* [y/n]: " yn
        case $yn in
            [Yy]*) return 0  ;;  
            [Nn]*) echo "Aborted" ; return  1 ;;
        esac
    done
}
# column -t -s $'\t' - format
usage() {
  cat <<EOF
Usage: encrypt.key.sh [-h] [-v] CODE SECRET [OPTIONS]

Positional:

SOURCE        input path (required)
DEST          output path (required)
Options:

-d DIRECTORY  dir to store auth keys, default is "$HOME/.2fa"
-u ID         GnuPG user id        
-k ID         GnuPG key id
-h            show help
-v            verbose

EOF
  exit 0;
}

# Path to gpg2 binary
_gpg2="/usr/bin/gpg2"

# TODO: store stuff in the ramfs
## run: gpg --list-secret-keys --keyid-format LONG to get uid and kid ##
# GnuPG user id 
uid=""
# GnuPG key id 
kid=""
# Directory that stores encrypted key for each service 
dir="$HOME/.2fa"

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -d|--dir)
      dir="$2"
      shift # past argument
      shift # past value
      ;;
    -u|--uid)
      uid="$2"
      shift # past argument
      shift # past value
      ;;
    -k|--kid)
      kid="$2"
      shift # past argument
      shift # past value
      ;;
    -h|--help)
        usage
      ;;
    -*|--*)
      usage
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

# Now build CLI args
c="$1"
s="$2"
k="${dir}/${s}/.key"
kg="${k}.gpg"
 
# failsafe stuff
[ -z "$s" ] && { echo "Usage: $0 service"; exit 2; }
[ -z "$c" ] && { echo "$0 - Error: code is not provided"; exit 2; } 

# if dir not exist, then file is empty => write and exit
d="${dir}/${s}"
[ ! -d "${dir}/${s}" ] && \
    {
	mkdir -p "${d}";
	echo -n "${c}" > "${k}";
	$_gpg2 -u "${kid}" -r "${uid}" --encrypt "$k" && rm -i "$k";
	exit 0;
    }

# if .key has more than 0 bytes prompt for override
[ -s "${k}" ] && \
    {
	echo "$0 - MSG: .key exist, override? [Y/n]";
	yes_or_no
    }

echo -n "${c}" > "${k}";

# Encrypt your service .key file 
$_gpg2 -u "${kid}" -r "${uid}" --encrypt "$k" && rm -i "$k" 
