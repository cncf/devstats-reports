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
GHA2DB_LOCAL=1 GHA2DB_SKIPTIME=1 GHA2DB_SKIPLOG=1 runq sql/prs.sql {{dtfrom}} "$1" {{dtto}} "$2" {{exclude_bots}} "`cat ~/dev/go/src/github.com/cncf/devstats/util_sql/exclude_bots.sql`"
