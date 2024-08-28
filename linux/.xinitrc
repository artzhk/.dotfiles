setxkbmap -option 'grp:alt_shift_toggle' -layout us,ru -variant real-programmer-dvorak,
setxkbmap -option 'grp:shift_alt_toggle' -layout us,ru -variant real-programmer-dvorak,

xfce4-power-manager &
flameshot &
eval $(ssh-agent -s) &

xrandr --auto 
xrandr --output HDMI-0 --auto --primary --right-of eDP-1-2
# xrandr --output eDP-1-2 --auto --primary --output HDMI-0 --off

xrdb -merge ~/.Xresources


exec i3 
#exec startplasma-x11
