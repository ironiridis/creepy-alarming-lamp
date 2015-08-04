#!/bin/sh

# cd
# mkdir -p cal
# cd cal

connect() {
  echo would connect to $1
  
}

sweep() {
  N=$RANDOM
  let "N %= 255"
  nmap -p 23 --open -oG hosts_$N 10.5.$N.0/24
  sed -En -i X 's/^Host: ([0-9.]+) .+Ports:.+$/\1/p' hosts_$N
  for H in `cat hosts_$N`
  do connect $H
  done
}

while true
do sweep ; sleep 10 ; done
