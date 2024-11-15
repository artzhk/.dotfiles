autorandr --change 4k-single
setxkbmap -option 'grp:alt_shift_toggle' -layout us,ru -variant real-programmer-dvorak,
setxkbmap -option 'grp:shift_alt_toggle' -layout us,ru -variant real-programmer-dvorak,

setxkbmap -option caps:escape

xfce4-power-manager &
flameshot &
eval $(ssh-agent -s) &

xrdb -merge ~/.Xresources

exec i3 
#exec startplasma-x11
