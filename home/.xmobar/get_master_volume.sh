#!/bin/bash
volume=`amixer get Master | grep -m1 "Playback [0-9]* \[[0-9]*%\]"`

if echo "$volume" | grep "\[off\]" &>/dev/null ; then
	output="mute"
else
	output=`echo "${volume}" | sed 's/^.*\[\([0-9]\+%\)\].*$/\1/'`
fi

echo "Vol: ${output}"
