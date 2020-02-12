#!/bin/bash
if [ -z "$PG_PASS" ]
then
  echo "$0: you need to set PG_PASS=..."
  exit 1
fi
if [ -z "$1" ]
then
  echo "$0: you need to provide 1st argument date-from in YYYY-MM-DD format"
  exit 2
fi
if [ -z "$2" ]
then
  echo "$0: you need to provide 2nd date-to in YYYY-MM-DD format"
  exit 3
fi
GHA2DB_LOCAL=1 GHA2DB_SKIPTIME=1 GHA2DB_SKIPLOG=1 GHA2DB_CSVOUT="data/linux_commits.csv" PG_DB=linux runq velocity/count_distinct_commits.sql {{dtfrom}} "$1" {{dtto}} "$2" {{exclude_bots}} "`cat /etc/gha2db/util_sql/exclude_bots.sql`" || exit 4
GHA2DB_LOCAL=1 GHA2DB_SKIPTIME=1 GHA2DB_SKIPLOG=1 GHA2DB_CSVOUT="data/linux_pushes.csv" PG_DB=linux runq velocity/count_pushes.sql {{dtfrom}} "$1" {{dtto}} "$2" {{exclude_bots}} "`cat /etc/gha2db/util_sql/exclude_bots.sql`" || exit 5
