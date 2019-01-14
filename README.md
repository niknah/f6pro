
This is for rotating the screen of Teclast F6 pro laptops on Manjaro linux.


## To install...
`pacman -S xorg-xinput xorg-xrandr onboard zenity`

The module here was compiled on 4.19.13-1-MANJARO.  It is in the latest 5.0-rc1 kernel but not 4.20.1.  Load it up by running...
`insmod ./kxcjk-1013.ko.xz`

The driver only detects the position of the screen.  The rotation of the keyboard is unknown.  I've just made it so that when the screen is facing the normal laptop rotation it'll enable the physical keyboard.


## To use...
```
# Wait for rotation
bash rotate.sh

# auto detect
bash rotate.sh auto
# manual choice
bash rotate.sh manual

bash rotate.sh left
bash rotate.sh right
bash rotate.sh invert
bash rotate.sh noKeyboard

# back to normal
bash rotate.sh normal
...
```




## Other things here
Copy etc/sysctl.d/swappiness to reduce swappiness so you don't wear out the cheap SSD.


