#!/bin/bash

. ./path.config

if [[ $1 == "-wp" ]] ; then
  wp = true
  domainName = $2
else 
  domainName = $2
fi
