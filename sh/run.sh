#!/bin/bash
if [ -z "$PG_PASS" ]
then
  echo "$0: you need to set PG_PASS=..."
  exit 1
fi
if [ -z "$1" ]
then
  echo "$0: you need to provide 1st argument - report type: developers, commits, prs, issues, contributing_companies_count etc"
  exit 2
fi
if [ -z "$2" ]
then
  echo "$0: you need to provide 2nd argument date-from in YYYY-MM-DD format"
  exit 3
fi
if [ -z "$3" ]
then
  echo "$0: you need to provide 3rd date-to in YYYY-MM-DD format"
  exit 4
fi
.  ./sh/bots.sh
GHA2DB_LOCAL=1 GHA2DB_SKIPTIME=1 GHA2DB_SKIPLOG=1 runq "sql/${1}.sql" {{dtfrom}} "${2}" {{dtto}} "${3}" {{exclude_bots}} "$bots" "${@:4:99}"
