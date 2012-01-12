#!/bin/sh
ps ax |grep master | awk '{print $1}' |xargs kill -9 > /dev/null 2> /dev/null
ps ax |grep monitor | awk '{print $1}' |xargs kill -9 > /dev/null 2> /dev/null
./master_watch.sh
/usr/bin/sudo /usr/bin/mysql -u root realworx_production -e "update analyzers set status=10, processing = null , exception_msg=''" 


