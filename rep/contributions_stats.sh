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
GHA2DB_LOCAL=1 GHA2DB_SKIPTIME=1 GHA2DB_CSVOUT="data/${PG_DB}_contributions_stats.csv" runq util_sql/contributions_stats.sql {{exclude_bots}} "`cat util_sql/exclude_bots.sql`"
