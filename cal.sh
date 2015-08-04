#!/bin/sh

# cd
# mkdir -p cal
# cd cal

MYSUBNET=`route -n | sed -nE 's/^(10\.[0-9]+)\.[0-9]+\.[0-9]+ .+$/\1/p'`

talk() {
  sleep 2
  echo root
  sleep 2
  echo whoami
  sleep 5
  echo exit
}

connectTo() {
  echo connecting to $1:23 >2
  talk | nc -w 5 $1 23
}

sweep() {
  if [ -z "$1" ] ; then
    N=$RANDOM
    let "N %= 255"
    SCAN=$MYSUBNET.$N.0/24
  else
    SCAN="$1"
    N=localhost
  fi
  echo scanning $SCAN:23 >2
  nmap -p 23 --open -oG hosts_$N $SCAN >/dev/null 2>&1
  sed -En -i 's/^Host: ([0-9.]+) .+Ports:.+$/\1/p' hosts_$N
  for H in `cat hosts_$N` ; do connectTo $H ; done
}

echo testing sweep with localhost
sweep 127.0.0.1

echo scanning subnet $MYSUBNET.0.0/16 >2
while true ; do sweep ; done
