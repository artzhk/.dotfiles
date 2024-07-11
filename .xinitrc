setxkbmap -option 'grp:alt_shift_toggle' -layout us,ru
setxkbmap -option 'grp:shift_alt_toggle' -layout us,ru

flameshot &
xfce4-power-manager & 
xrdb ~/.Xresources

xrandr --auto 
xrandr --output HDMI-0 --auto --primary --right-of eDP-1-2

# xrandr --output eDP-1-2 --auto --primary --output HDMI-0 --off

exec i3
# exec startplasma-x11
