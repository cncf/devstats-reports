#!/bin/bash
if [ -z "$PG_PASS" ]
then
  echo "$0: you need to specify PG_PASS env variable"
  exit 1
fi
.  ./sh/bots.sh
GHA2DB_LOCAL=1 GHA2DB_SKIPTIME=1 GHA2DB_SKIPLOG=1 PG_DB=gha GHA2DB_CSVOUT="/data/k8s_yearly_contributors_with_50.csv" runq ./contributors/sql/k8s_yearly_contributors_with_50.sql {{exclude_bots}} "$bots"
