#!/bin/bash
if [ -z "$PG_PASS" ]
then
  echo "$0: you need to specify PG_PASS=..."
  exit 1
fi
if [ -z "${1}" ]
then
  echo "$0: you need to specify 'recent' period as a 1st arg, example '1 week'"
  exit 2
fi
if [ -z "$ONLY" ]
then
  all=`cat velocity/all_prod_dbs.txt`
else
  all="${ONLY}"
fi
if [ -z "$TASKS" ]
then
  tasks='committers unknown_committers known_committers contributors unknown_contributors known_contributors issuers unknown_issuers known_issuers'
else
  tasks="${TASKS}"
fi
for script in $tasks
do
  script="${script}_recent"
  for db in $all
  do
    echo "${db} ${script}"
    PG_DB="${db}" "./affs/${script}.sh" "${1}" 1>/dev/null
  done
done
