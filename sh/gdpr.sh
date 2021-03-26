#!/bin/bash
cond='ilike any (array['
for f in "$@"
do
  f="%`echo "${f}" | tr '[:upper:]' '[:lower:]' | sed -e 's/\(\s\+\|@\)/%/g'`%"
  f=`echo "${f}" | sed -e 's/%\+/%/g'`
  cond="${cond}'${f}',"
done
cond="${cond:0:${#cond}-1}])"
echo $cond
PG_DB=allprj GHA2DB_LOCAL=1 GHA2DB_SKIPTIME=1 GHA2DB_SKIPLOG=1 runq "sql/gdpr.sql" {{cond}} "${cond}"
