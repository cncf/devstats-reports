#!/bin/bash
if [ -z "$PG_PASS" ]
then
  echo "$0: you need to specify PG_PASS env variable"
  exit 1
fi
if [ -z "$1" ]
then
  echo "$0: you need to specify DB as a 1st arg, example: gha, allprj, prometheus"
  exit 2
fi
if [ -z "$2" ]
then
  echo "$0: you need to specify date from as a 2nd argument, example: \"'2020-01-01'\", \"now()-'1 year'::interval\""
  exit 3
fi
if [ -z "$3" ]
then
  echo "$0: you need to specify date to as a 3rd argument, example: \"'2020-10-01'\", \"now()-'1 day'::interval\""
  exit 4
fi
if [ -z "$4" ]
then
  echo "$0: you need to specify N as a 4th argument, example: 10, 20, 50, 100"
  exit 5
fi
.  ./sh/bots.sh
GHA2DB_LOCAL=1 GHA2DB_SKIPTIME=1 GHA2DB_SKIPLOG=1 PG_DB="${1}" GHA2DB_CSVOUT="/data/${1}_contributors_with_${4}.csv" runq contributors/sql/contributors_with_n_dtrange.sql {{exclude_bots}} "$bots" {{from}} "${2}" {{to}} "${3}" {{n}} "${4}"
