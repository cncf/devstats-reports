#!/bin/bash
if [ -z "$PG_PASS" ]
then
  echo "$0: you need to specify PG_PASS=..."
  exit 1
fi
if [ -z "$1" ]
then
  echo "$0: you need to specify date from as a first arg"
  exit 2
fi
if [ -z "$2" ]
then
  echo "$0: you need to specify date to as a second arg"
  exit 3
fi
