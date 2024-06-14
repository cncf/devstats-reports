#!/bin/bash
# PRINT_ITEM=1
# PRINT_DO=1
# STOP=1
# ITEMS='Alibaba Group@@NTT Corporation@@Huawei Technologies Co. Ltd@@Cockroach Labs@@Microsoft Corporation@@End Point Corporation@@Tencent Holdings Limited@@Apple Inc.@@System1@@Independent'
# DO='cleara@@SKIPDT=1 PG_DB=etcd ./sh/rep.sha quarters company_contributions_stripped {{type}} known {{company_name}} company_name {{company}} ##@@cat out.csv'

if [ -z "$ITEMS" ]
then
  echo "$0: you must specify '@@' separated list of items via: ITEMS='item 1@@item2@@a, b, c '"
  exit 1
fi

if [ -z "$DO" ]
then
  echo "$0: you must specify what to do via '@@' separated list of items via: DO='ls -l ##@@cat out', ## is the current item"
  exit 2
fi

ITEMS="${ITEMS//@@/⚤}"
IFS='⚤'
read -ra items <<< "$ITEMS"

DO="${DO//@@/⚤}"
read -ra dos <<< "$DO"

for item in ${items[@]}
do
  if [ ! -z "$PRINT_ITEM" ]
  then
    echo "item: $item"
  fi
  for d in ${dos[@]}
  do
    dd="${d//##/\'${item}\'}"
    if [ ! -z "$PRINT_DO" ]
    then
      echo "do: $dd"
    fi
    eval $dd
  done
  if [ ! -z "$STOP" ]
  then
    echo -n "item: $item finished, press enter to continue..."
    read
  fi
done
