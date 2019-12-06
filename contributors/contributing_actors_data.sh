#!/bin/bash
if [ -z "$PG_PASS" ]
then
  echo "$0: you need to specify PG_PASS env variable"
  exit 1
fi
.  ./sh/bots.sh
GHA2DB_LOCAL=1 GHA2DB_SKIPTIME=1 GHA2DB_SKIPLOG=1 PG_DB=allprj GHA2DB_CSVOUT="/data/contributing_actors_data.csv" runq contributors/sql/contributing_actors_data.sql {{exclude_bots}} "$bots"
