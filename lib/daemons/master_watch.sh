#!/bin/sh


MSTR_CTL=/sunrise/www/realworx-rails/current/lib/daemons/master_ctl
date 
ps aux | grep master.rb | grep -v grep > /dev/null || {
  echo "master is dead"
  $MSTR_CTL start || { 
      echo "failed to start master.rb"
      exit 1
   }
   echo "started master.rb successfully"
   exit 0 
}
echo "master is alive!"

