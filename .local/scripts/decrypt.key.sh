#!/bin/bash
# Purpose: Display 2FA code on screen
# Author: Vivek Gite {https://www.cyberciti.biz/} under GPL v 2.x or above
# --------------------------------------------------------------------------
# Path to gpg2 binary
_gpg2="/usr/bin/gpg2"
_oathtool="/usr/bin/oathtool"
 
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
 
# Build CLI arg
s="$1"
k="${dir}/${s}/.key"
kg="${k}.gpg"
 
# failsafe stuff
[ "$1" == "" ] && { echo "Usage: $0 service"; exit 1; }
[ ! -f "$kg" ] && { echo "Error: Encrypted file \"$kg\" not found."; exit 2; }
 
# Get totp secret for given service
totp=$($_gpg2 --quiet -u "${kid}" -r "${uid}" --decrypt "$kg")
 
# Generate 2FA totp code and display on screen
echo "Your code for $s is ..."
code=$($_oathtool -b --totp "$totp")
## Copy to clipboard too ##
## if xclip command found  on Linux system ##
type -a xclip &>/dev/null
[ $? -eq 0 ] && { echo $code | xclip -sel clip; echo "*** Code copied to clipboard too ***"; }
echo "$code"
 
# Make sure we don't have .key file in plain text format ever #
[ -f "$k" ] && echo "Warning - Plain text key file \"$k\" found."
