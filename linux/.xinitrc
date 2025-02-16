.config/polybar/launch.sh --$SYSTEM_THEME

xfce4-power-manager &
flameshot &
eval $(ssh-agent -s) &

xrdb -merge ~/.Xresources

exec i3 
#exec startplasma-x11
