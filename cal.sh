#!/bin/bash

cd
mkdir -p cal
cd cal

sweep() {
  N=$RANDOM
  let "N %= 255"
  nmap -p 23 --open -oG hosts_$N 10.5.$N.0/24
  sed -En -iX 's/^Host: ([0-9.]+) .+Ports:.+$/\1/p'
  
  
}

sweep
