#!/bin/bash
# EXTRA_COND="and \"Date from\" = '2023-01-01' and \"Date to\" = '2024-01-01'"
if [ -z "$PG_DB" ]
then
  echo "$0: you should specify PG_DB=db-name, using the default PG_DB=allprj"
  export PG_DB=allprj
fi
if [ -z "${1}" ]
then
  echo "$0: you should specify a country name as a 1st agrument, for example 'Poland', existing"
  exit 1
fi
GHA2DB_CSVOUT="/data/${1}_country_ranks_in_${PG_DB}.csv" GHA2DB_LOCAL=1 runq sql/country_report.sql {{extra_cond}} "${EXTRA_COND}" {{exclude_bots}} "`cat /etc/gha2db/util_sql/exclude_bots.sql`" {{country}} "${1}"
