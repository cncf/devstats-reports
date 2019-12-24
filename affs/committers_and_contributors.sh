#!/bin/bash
if [ -z "$PG_PASS" ]
then
  echo "$0: you need to set PG_PASS=..."
  exit 1
fi
if [ -z "$PG_DB" ]
then
  echo "$0: you need to set PG_DB=..., for example PG_DB=cii"
  exit 2
fi
./affs/contributors.sh || exit 3
./affs/known_contributors.sh || exit 4
./affs/unknown_contributors.sh || exit 5
./affs/committers.sh || exit 6
./affs/known_committers.sh || exit 7
./affs/unknown_committers.sh || exit 8
