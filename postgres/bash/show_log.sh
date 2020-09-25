#!/bin/bash

function clean {
  pidstart=$(awk {'print $22'} < /proc/$notifpid/stat)
  #echo clean_pidstart = $pidstart
  #echo clean_notifstart = $notifstart
  if [ "$notifstart" == "$pidstart" ]
  then
    echo Stopping process $notifpid
    kill -s SIGKILL $notifpid
  fi
  cd $initdir
}

trap clean EXIT

# man tput, man terminfo
BOLD=`tput bold`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
ORANGE=`tput setaf 3`
MAGENTA=`tput setaf 5`
NOCOLOR=`tput op`

initdir=`pwd`
cd /var/lib/pgsql/log
while :
do

  curlog=`ls -t1 | grep -E "^.*\.log$" | head -1`
  echo ----------- going to next log: $curlog -----------------
  # check inotifywait exists
  hash inotifywait 2>/dev/null
  result=$?
  if [ $result != 0 ]; then
    echo 'Fails to start inotifywait. Fallback to one file tail...'
    tail -f $curlog | \
          sed -u "s/ERROR/${RED}${BOLD}&${NOCOLOR}/g" | \
          sed -u "s/LOG/${GREEN}${BOLD}&${NOCOLOR}/g" | \
          sed -u "s/NOTICE/${ORANGE}${BOLD}&${NOCOLOR}/g" | \
          sed -u "s/FATAL/${MAGENTA}${BOLD}&${NOCOLOR}/g"
    exit 1
  fi
  # show log in a smart way<F2>
  inotifywait -e create . &
  notifpid=$!
  notifstart=$(awk {'print $1'} < /proc/uptime | sed -e 's/\.//g')
  #echo notifpid = $notifpid
  #echo notifstart = $notifstart
  tail --pid=$notifpid -f $curlog | \
        sed -u "s/ERROR/${RED}${BOLD}&${NOCOLOR}/g" | \
        sed -u "s/LOG/${GREEN}${BOLD}&${NOCOLOR}/g" | \
        sed -u "s/NOTICE/${ORANGE}${BOLD}&${NOCOLOR}/g" | \
        sed -u "s/FATAL/${MAGENTA}${BOLD}&${NOCOLOR}/g"

done
cd $initdir

