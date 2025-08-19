#
#!/usr/bin/env bash
#

GREEN="\e[32m"
BOLD="\e[1m"
BLUE="\e[34m"
NC="\e[0m" # No color

function help() {
	echo -e "${BOLD}install.sh${NC} <src-path> <dst-path>"
	echo -e "${BOLD}-> Specify path without \"/\" at the end${NC}\n"
	echo -e "${BOLD}==PARAMETERS==${NC}"
	echo -e "       ${BOLD}--default -d${NC} - uses src-path=~/.dotfiles dst-path=~"
	echo -e "       ${BOLD}--help -h${NC} - uses to display this help"
}

SRC_PATH=""
DST_PATH=""

if [[ -z $2 && -z $1 ]]; then
	help
	exit 1
fi

if [[ $1 =~ ^-.*$ ]]; then
	if [[ "$1" == "--default" || "$1" == "-d" ]]; then
		echo -e "${BLUE}-> Using default parameters${NC}"
		echo -e "       ${BOLD}src=~/.dotfiles dst=~${NC}"

		SRC_PATH=~/.dotfiles
		DST_PATH=~
	else
		help
		exit 1
	fi
fi

if [[ ! -z "$1" && -z "$DST_PATH" && -z "$SRC_PATH" ]]; then
	SRC_PATH=~/.dotfiles
	echo -e "${BOLD}-> Setting src-path to $SRC_PATH ${NC}"
	DST_PATH=$1
	echo -e "${BOLD}-> Setting dst-path to $DST_PATH ${NC}"

	if [[ ! -z "$2" ]]; then
		SRC_PATH=$1
		DST_PATH=$2
		echo -e "${BOLD}-> Resetting dst-path to $DST_PATH ${NC}"
		echo -e "${BOLD}-> Resetting src-path to $SRC_PATH ${NC}"
	fi
fi

echo -e "${BLUE}Installing essentials...${NC}"

function setup() {
	path=$1
	mode=$2
	bash $SRC_PATH/.install/install.sh $SRC_PATH/$path $DST_PATH/$path $mode
}

bash $SRC_PATH/.install/install.sh $SRC_PATH $DST_PATH

setup .local/scripts
setup .local/scripts/fedora
setup .emacs.d

for i in $(ls -a $SRC_PATH/.config | grep -P "^[A-z]+"); do
	setup .config/$i cp
done


