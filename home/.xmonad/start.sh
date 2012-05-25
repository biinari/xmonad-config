#!/bin/bash

# Set up an icon tray
trayer --edge top --align right --SetDockType true --SetPartialStrut true \
	--expand true --width 10 --transparent true --tint 0x191999 --height 12 &

# Startup apps
if [ -x /usr/bin/nm-applet ] ; then
	/usr/bin/dbus-launch nm-applet --sm-disable &
fi

# Not needed as it is present in /etc/xdg/autostart
if [ -x /usr/bin/wicd-client ] ; then
	/usr/bin/wicd-client --tray &>/dev/null &
fi

if [ -x /usr/bin/gnome-power-manager ] ; then
	/usr/bin/gnome-power-manager &
fi

#if [ -x /usr/bin/gnome-sound-applet ] ; then
#	/usr/bin/gnome-sound-applet &
#fi

if [ -x /usr/bin/dropbox ] ; then
	/usr/bin/dropbox start
fi

if [ -x /usr/bin/dropboxd ] ; then
	/usr/bin/dropboxd &
fi

#if [ -x ${HOME}/.dropbox-dist/dropboxd ] ; then
#	${HOME}/.dropbox-dist/dropboxd &
#fi

if [ -x /usr/bin/xscreensaver ] ; then
	/usr/bin/xscreensaver &
fi

if [ -x /usr/bin/amixer ] ; then
	/usr/bin/amixer set Master 40% unmute
fi
