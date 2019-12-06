#!/bin/bash
if [ -z "$PG_PASS" ]
then
  echo "$0: you need to specify PG_PASS env variable"
  exit 1
fi
./contributors/contributors_and_emails.sh || exit 2
./contributors/contributing_actors.sh || exit 3
./contributors/contributing_actors_data.sh || exit 4
./contributors/k8s_contributors_and_emails.sh || exit 5
./contributors/top_50_k8s_yearly_contributors.sh || exit 6
./contributors/k8s_yearly_contributors_with_50.sh || exit 7
if [ -z "$NOZIP" ]
then
  zip -9 /data/contrib.zip /data/contributors_and_emails.csv /data/contributing_actors.csv /data/contributing_actors_data.csv /data/k8s_contributors_and_emails.csv /data/top_50_k8s_yearly_contributors.csv /data/k8s_yearly_contributors_with_50.csv || exit 8
fi
echo 'OK'
