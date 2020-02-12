#!/bin/bash
if [ -z "$PG_PASS" ]
then
  echo "$0: you need to specify PG_PASS=..."
  exit 1
fi
if [ -z "$1" ]
then
  echo "$0: you need to specify date from as a first arg"
  exit 2
fi
if [ -z "$2" ]
then
  echo "$0: you need to specify date to as a second arg"
  exit 3
fi
from="${1}"
to="${2}"
fn="data/data_cncf_update_${from}_${to}.csv"
echo 'project,key,value' > "${fn}"
if [ -z "$ONLY" ]
then
  all=`cat velocity/all_prod_dbs.txt`
else
  all="${ONLY}"
fi
for db in $all
do
  if [ "$db" = "allprj" ]
  then
    continue
  fi
  name=`db.sh psql "$db" -tAc "select value_s from gha_vars where name = 'full_name'"`
  echo "${db} -> ${name}"
  ./velocity/get_git_commits_count.sh "${db}" "${from}" "${to}"
  commits=`cat commits.txt`
  echo "${name} commits: ${commits}"
  echo "${name},commits,${commits}" >> "${fn}"
done
