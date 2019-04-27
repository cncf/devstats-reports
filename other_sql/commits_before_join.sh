#!/bin/bash
GHA2DB_CSVOUT=out.csv GHA2DB_LOCAL=1 GHA2DB_SKIPTIME=1 GHA2DB_SKIPLOG=1 runq other_sql/commits_before_join.sql {{exclude_bots}} "`cat ~/dev/go/src/github.com/cncf/devstats/util_sql/exclude_bots.sql`" {{actor}} author
