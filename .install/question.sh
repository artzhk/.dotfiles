function question() {
        q=$*
        a=false

        echo "$q"
        select opt in "y" "n"; do
            case $a in
                y ) opt="y"; break ;;
                n ) opt="n"; break ;;
            esac
        done

        echo "$a"
        return $a == "y"
}

question $1
