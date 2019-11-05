#!/bin/bash
if [ -z "$PG_PASS" ]
then
  echo "$0: you need to set PG_PASS=..."
  exit 1
fi
if [ -z "$PG_DB" ]
then
  echo "$0: you need to set PG_DB=..., for example PG_DB=cii"
  exit 2
fi
if [ -z "$1" ]
then
  echo "$0: you need to specify top N, for example 3"
  exit 3
fi
GHA2DB_LOCAL=1 GHA2DB_SKIPTIME=1 GHA2DB_CSVOUT="data/${PG_DB}_top_${1}_repos_committers.csv" runq sql/top_repos_committers.sql {{exclude_bots}} "`cat /etc/gha2db/util_sql/exclude_bots.sql`" {{n}} "$1"
