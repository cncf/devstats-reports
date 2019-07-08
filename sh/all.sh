#!/bin/bash
if [ -z "${PG_PASS}" ]
then
  echo "You need to set PG_PASS environment variable to run this script"
  exit 1
fi
export LIST_FN_PREFIX="../devstats/devel/all_"
. all_dbs.sh || exit 2
for db in $all
do
  CSV="${db}.csv" PG_DB="$db" "${@}" || exit 3
  if [ -z "$hdr" ]
  then
    echo -n "project," > all.csv
    head -n 1 "${db}.csv" >> all.csv
    hdr=1
  fi
  echo -n "$db," >> all.csv
  sed -n '1d;p' "${db}.csv" >> all.csv
done
echo 'OK'
