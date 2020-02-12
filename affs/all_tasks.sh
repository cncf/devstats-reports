#!/bin/bash
if [ -z "$PG_PASS" ]
then
  echo "$0: you need to specify PG_PASS=..."
  exit 1
fi
if [ -z "$ONLY" ]
then
  all=`cat velocity/all_prod_dbs.txt`
else
  all="${ONLY}"
fi
for script in committers unknown_committers known_committers contributors unknown_contributors known_contributors
do
  for db in $all
  do
    echo "${db} ${script}"
    PG_DB="${db}" "./affs/${script}.sh" 1>/dev/null
  done
done
