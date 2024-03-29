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
if [ -z "${1}" ]
then
  echo "$0: you need to specify 'new' period as a 1st arg, example '1 week'"
  exit 3
fi
GHA2DB_LOCAL=1 GHA2DB_SKIPTIME=1 GHA2DB_CSVOUT="data/${PG_DB}_issuers_new.csv" runq sql/issuers_new.sql {{exclude_bots}} "`cat /etc/gha2db/util_sql/exclude_bots.sql`" {{ago}} "${1}"
