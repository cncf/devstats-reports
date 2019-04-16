#!/bin/bash
# SKIPDT=1 - skip from,to ranges in the final out.csv output file.
if [ -z "$PG_PASS" ]
then
  echo "$0: you need to set PG_PASS=..."
  exit 1
fi

if [ -z "$1" ]
then
  echo "$0: you need to provide 1st argument - report type: join, quarters, years"
  exit 2
fi

if [ -z "$2" ]
then
  echo "$0: you need to provide 2nd argument - report name, for example developers_count"
  exit 2
fi

data=''
if [ "$1" = "quarters" ]
then
  data='2014-04-01:2014-07-01 2014-07-01:2014-10-01 2014-10-01:2015-01-01 2015-01-01:2015-04-01 2015-04-01:2015-07-01 2015-07-01:2015-10-01 2015-10-01:2016-01-01 2016-01-01:2016-04-01 2016-04-01:2016-07-01 2016-07-01:2016-10-01 2016-10-01:2017-01-01 2017-01-01:2017-04-01 2017-04-01:2017-07-01 2017-07-01:2017-10-01 2017-10-01:2018-01-01 2018-01-01:2018-04-01 2018-04-01:2018-07-01 2018-07-01:2018-10-01 2018-10-01:2019-01-01 2019-01-01:2019-04-01 2019-04-01:2019-07-01'
fi
if [ "$1" = "years" ]
then
  data='2014-01-01:2015-01-01 2015-01-01:2016-01-01 2016-01-01:2017-01-01 2017-01-01:2018-01-01 2018-01-01:2019-01-01 2019-01-01:2020-01-01'
fi
if [ "$1" = "join" ]
then
  data='2010-01-01:2016-03-10 2016-03-10:2080-01-01'
fi

for row in $data
do
  row=${row//:/ }
  ary=($row)
  echo "Range ${ary[0]} ${ary[1]}"
  GHA2DB_CSVOUT="${ary[0]}_${ary[1]}.csv" ./sh/run.sh "${2}" "${ary[0]}" "${ary[1]}" "${@:3:99}"
done
hdr=''
for row in $data
do
  row=${row//:/ }
  ary=($row)
  if [ -z "$hdr" ]
  then
    hdr=`head -n 1 "${ary[0]}_${ary[1]}.csv"`
    if [ -z "$SKIPDT" ]
    then
      hdr="from,to,${hdr}"
    fi
    echo $hdr > out.csv
  fi
  rows=`tail -n +2 "${ary[0]}_${ary[1]}.csv"`
  for row in $rows
  do
    if [ -z "$SKIPDT" ]
    then
      echo "${ary[0]},${ary[1]},$row" >> out.csv
    else
      echo "$row" >> out.csv
    fi
  done
done
