#!/usr/bin/env bash

dir="$HOME/.config/polybar/panels"
themes=(`ls --hide="launch.sh" $dir`)

# TODO: Write additional funcitons for rest of the polybars
function open_on_all_monitors_default() {
    echo $1
    theme="light"

    if [[ $1 == "--light" ]]; then
        theme="light"
    elif [[ $1 == "--dark" ]]; then
        theme="dark"
    fi

    if type "xrandr"; then
        for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
            MONITOR=$m polybar -q main -c "$dir/$theme-config.ini" &
        done
    else
        polybar -q main -c "$dir/$theme-config.ini" &
    fi
}

function launch_bar() {
    if [ "$1" != "--light" ] && [ "$1" != "--dark" ]; then
        echo "Invalid argument. Please use --light or --dark"
        exit 1
    fi

    # Terminate already running bar instances
    killall -q polybar

    # Wait until the processes have been shut down
    while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

    open_on_all_monitors_default $1
}

launch_bar $1
