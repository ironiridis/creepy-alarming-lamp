#!/bin/sh

# cd
# mkdir -p cal
# cd cal

MYSUBNET=`route -n | sed -nE 's/^(10\.[0-9]+)\.[0-9]+\.[0-9]+ .+$/\1/p'`

connect() {
  echo would connect to $1
  
}

sweep() {
  N=$RANDOM
  let "N %= 255"
  echo looking for open port 23 in $MYSUBNET.$N.0/24
  nmap -p 23 --open -oG hosts_$MYSUBNET.$N $MYSUBNET.$N.0/24
  sed -En -i X 's/^Host: ([0-9.]+) .+Ports:.+$/\1/p' hosts_$MYSUBNET.$N
  for H in `cat hosts_$MYSUBNET.$N`
  do connect $H
  done
}

echo will scan subnet $MYSUBNET.0.0/16

while true
do sweep ; sleep 10 ; done
