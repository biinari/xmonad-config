#!/bin/bash

shutdown="Shut Down"
timeout=10
if pm-is-supported --suspend ; then
	suspend=",Suspend:4"
else
	suspend=""
fi
if pm-is-supported --hibernate; then
	hibernate=",Hibernate:5"
else
	hibernate=""
fi
if pm-is-supported --suspend-hybrid; then
	hybrid=",Hybrid Suspend:6"
else
	hybrid=""
fi
if [ -x /usr/bin/gxmessage ]; then
	xmessage=/usr/bin/gxmessage
	cancel=",GTK_STOCK_CANCEL:7"
else
	xmessage=/usr/bin/xmessage
	cancel=",Cancel:7"
fi

$xmessage -buttons "${shutdown}:3${suspend}${hibernate}${hybrid}${cancel}" \
	-default "${shutdown}" -timeout $timeout -center -name "Shut Down" \
	"Are you sure you want to Shut down? Will cancel after ${timeout} seconds"
code=$?

case $code in
	0 | 3)
		echo "Shutting down"
		sudo poweroff
		;;
	4)
		if [ -n $suspend ]; then
			echo "Suspending"
			sudo pm-suspend
		else
			echo "Suspend is not supported."
			exit 1
		fi
		;;
	5)
		if [ -n $hibernate ]; then
			echo "Hibernating"
			sudo pm-hibernate
		else
			echo "Hibernate is not supported."
			exit 1
		fi
		;;
	6)
		if [ -n $hybrid ]; then
			echo "Hybrid Suspending"
			sudo pm-suspend-hybrid
		else
			echo "Hybrid Suspend is not supported."
			exit 1
		fi
		;;
	7)
		# Cancel
		;;
	1)
		# xmessage quit unexpectedly
		exit 1
		;;
	*)
		echo "Unrecognised exit code from xmessage: ${code}"
		exit 1
		;;
esac

exit 0
