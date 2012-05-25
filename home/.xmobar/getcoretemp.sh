#!/bin/bash
sens=`sensors`

core0=`echo "$sens" | grep -m1 "Core0" | sed 's/^.*Core0\s*Temp:\s*+\([0-9]*\)\..*$/\1/'`
core1=`echo "$sens" | grep -m1 "Core1" | sed 's/^.*Core1\s*Temp:\s*+\([0-9]*\)\..*$/\1/'`
red="<fc=red>"
green="<fc=green>"
endcolour="</fc>"
#if [ "$core0" -gt 60 ]; then
#	$core0="${red}${core0}${endcolour}"
#elif [ "$core0" -gt 40 ]; then
#	$core0="${green}${core0}${endcolour}"
#fi
#if [ "$core1" -gt 60 ]; then
#	$core1="${red}${core1}${endcolour}"
#elif [ "$core1" -gt 40 ]; then
#	$core1="${green}${core1}${endcolour}"
#fi
#core0="${core0}°C"
#core1="${core1}°C"
core0="${core0}C"
core1="${core1}C"
echo "${core0} ${core1}"
