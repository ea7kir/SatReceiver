#!/bin/bash

/usr/bin/sudo killall -w longmynd > /dev/null 2>&1
cd /home/pirec/longmynd/
/usr/bin/sudo /home/pirec/longmynd/longmynd "$1" "$2" "$3" "$4" "$5" "$6" "$7" > /dev/null 2>&1 &
exit 0
