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
  echo "$0: you need to set company as a 1st argument, for example $0 'Apple'"
  exit 2
fi
GHA2DB_LOCAL=1 GHA2DB_SKIPTIME=1 GHA2DB_CSVOUT="data/${PG_DB}_company_contributors.csv" runq sql/company_known_contributors.sql {{exclude_bots}} "`cat /etc/gha2db/util_sql/exclude_bots.sql`" {{company}} "${1}"
