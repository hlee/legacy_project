#!/bin/sh
ps ax |grep mongrel | awk '{print $1}' |xargs kill -9 > /dev/null 2> /dev/null
rm -rf /sunrise/www/realworx-rails/current/tmp/pids/*.pid 


