
setxkbmap -option 'grp:alt_shift_toggle' -layout us,ru
setxkbmap -option 'grp:shift_alt_toggle' -layout us,ru

xfce4-power-manager &
flameshot &
# picom -b & 

xrandr --auto 
xrandr --output HDMI-0 --auto --primary --right-of eDP-1-2

# xrandr --output eDP-1-2 --auto --primary --output HDMI-0 --off

xrdb -merge ~/.Xresources


exec i3
#exec startplasma-x11
