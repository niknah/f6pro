#!/bin/bash

# To install...
# pacman -S xorg-xinput xorg-xrandr onboard zenity

# To use...
# bash rotate.sh auto
# bash rotate.sh manual

# bash rotate.sh left
# bash rotate.sh right
# bash rotate.sh invert
# bash rotate.sh noKeyboard
# ...

# * Back to normal...
# bash rotate.sh

# If you lose the keyboard, press Ctrl-Alt-F8, ALT-F2, login and run....
# DISPLAY=:0 xinput enable "AT Translated Set 2 keyboard"


ACCEL_FILE=/sys/bus/iio/devices/iio\:device0/in_accel_


[[ `xinput | grep 'Goodix Capacitive TouchScreen'` =~ id=([0-9]+) ]];
TOUCHSCREEN_ID=${BASH_REMATCH[1]}

[[ `xinput | grep 'Touchpad'` =~ id=([0-9]+) ]];
TOUCHPAD_ID=${BASH_REMATCH[1]}

function setRotation {
	read X <"${ACCEL_FILE}x_raw"
	read Y <"${ACCEL_FILE}y_raw"
	read Z <"${ACCEL_FILE}z_raw"
	FLIP=0
	POS='normal'
	if test $X -gt 256; then
		POS='right';
	elif test $X -le -256; then
		POS='left';
	elif test $Y -le 0; then
		POS='invert';
	fi

	if test $POS != "normal"; then
		FLIP=1
	fi
}


function rotateInput {
	xinput --set-prop $TOUCHPAD_ID "Coordinate Transformation Matrix" $*
	xinput --set-prop $TOUCHSCREEN_ID "Coordinate Transformation Matrix" $*
}

function keyboard {
	xinput enable "AT Translated Set 2 keyboard"
	dbus-send --type=method_call --dest=org.onboard.Onboard /org/onboard/Onboard/Keyboard org.onboard.Onboard.Keyboard.Hide >/dev/null
	sleep 1;  # it takes a second for the keyboard to disappear
}

function noKeyboard {
	onboard
	if test $? -eq 0; then
		xinput disable "AT Translated Set 2 keyboard"
	fi
}

function rotate {
	# https://wiki.ubuntu.com/X/InputCoordinateTransformation

	case $POS in
	right)
		xrandr --output eDP1 --rotate right
		rotateInput 0 1 0 -1 0 1 0 0 1
		;;
	left)
		xrandr --output eDP1 --rotate left
		rotateInput  0 -1 1 1 0 0 0 1
		;;
	flip)
		noKeyboard
		xrandr --output eDP1 --rotate inverted
		rotateInput -1 0 1 0 -1 1 0 0 1
		;;
	invert)
		xrandr --output eDP1 --rotate inverted
		rotateInput -1 0 1 0 -1 1 0 0 1
		;;
	keyboard)
		keyboard
		;;
	noKeyboard)
		noKeyboard
		;;
	*)
		xrandr --output eDP1 --rotate normal
		rotateInput 1 0 0 0 1 0 0 0 1
		keyboard
		;;
	esac;
}


function flip {
	if test $FLIP -eq 0; then
		keyboard
	else
		noKeyboard
	fi;
}

function auto {
	setRotation
	flip
	rotate
}

function loop {
	CHANGED=0
	auto
	while sleep 1; do
		setRotation
		if test "$OLD_POS" != "$POS" -o "$OLD_FLIP" != "$FLIP"; then
			CHANGED=$(($CHANGED+1));
			if test $CHANGED -gt 1; then
				flip
				rotate
				OLD_POS=$POS;
				OLD_FLIP=$FLIP;
				sleep 5;
			fi;
		else
			CHANGED=0
		fi;
	done;
}

if test "$1" = "" -o "$1" = "loop"; then
	loop
elif test "$1" = "auto"; then
	auto
	echo $POS;
	echo $FLIP;
else
	if test "$1" = "manual"; then
		POS=`zenity --list --height=260 --hide-header --column=a flip left right invert normal keyboard noKeyboard`
	else
		POS=$1
	fi
	rotate
fi

