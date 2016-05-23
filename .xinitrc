xset -b
xset dpms 180 300 600

setxkbmap -option compose:ralt

# Temporarily disable touchpad on keypress
syndaemon -dKi 0.5

# Turn on Number Lock
numlockx&

# Background
feh --bg-fill ~/.i3/img/dragon_light.jpg

# Composter
compton -b

exec i3
