#!/bin/bash
bots="`cat ~/dev/go/src/github.com/cncf/devstats/util_sql/exclude_bots.sql 2>/dev/null`"
if [ -z "$bots" ]
then
  bots="`cat /data/go/src/github.com/cncf/devstats/util_sql/exclude_bots.sql 2>/dev/null`"
fi
if [ -z "$bots" ]
then
  bots="`cat /etc/gha2db/util_sql/exclude_bots.sql`"
fi
