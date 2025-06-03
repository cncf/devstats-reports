#!/bin/bash
# 
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
if [ -z "${2}" ]
then
  echo "$0: you should specify a project name (or repository group) as a 2nd agrument, for example 'Kubernetes', existing"
  exit 2
fi
if [ -z "${3}" ]
then
  echo "$0: you should specify a recent time range a 3rd agrument, for example '3 years', existing"
  exit 3
fi
country="${1// /_}"
repo_group="${2// /_}"
range="${3// /_}"
echo "Will write to /data/${country}_${repo_group}_contributors_last_${range}_in_${PG_DB}.csv"
GHA2DB_CSVOUT="/data/${country}_${repo_group}_contributors_last_${range}_in_${PG_DB}.csv" GHA2DB_LOCAL=1 runq sql/top_project_country_contributors.sql {{exclude_bots}} "`cat /etc/gha2db/util_sql/exclude_bots.sql`" {{country}} "${1}" {{project}} "${2}" {{time_range}} "${3}"
