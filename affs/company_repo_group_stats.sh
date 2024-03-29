#!/bin/bash
if [ -z "$PG_PASS" ]
then
  echo "$0: you need to set PG_PASS=..."
  exit 1
fi
if [ -z "$PG_DB" ]
then
  echo "$0: you need to set PG_DB=..., for example PG_DB=allprj"
  exit 2
fi
GHA2DB_LOCAL=1 GHA2DB_SKIPTIME=1 GHA2DB_CSVOUT="data/${PG_DB}_company_repo_group_stats.csv" runq sql/company_repo_group_stats.sql {{exclude_bots}} "`cat /etc/gha2db/util_sql/exclude_bots.sql`" {{company_name}} company_name
