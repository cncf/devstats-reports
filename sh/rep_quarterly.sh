#!/bin/bash
if [ -z "$PG_PASS" ]
then
  echo "$0: you need to set PG_PASS=..."
  exit 1
fi
if [ -z "$1" ]
then
  echo "$0: you need to provide report name, for example developers_count"
  exit 2
fi
data='2014-04-01:2014-07-01 2014-07-01:2014-10-01 2014-10-01:2015-01-01 2015-01-01:2015-04-01 2015-04-01:2015-07-01 2015-07-01:2015-10-01 2015-10-01:2016-01-01 2016-01-01:2016-04-01 2016-04-01:2016-07-01 2016-07-01:2016-10-01 2016-10-01:2017-01-01 2017-01-01:2017-04-01 2017-04-01:2017-07-01 2017-07-01:2017-10-01 2017-10-01:2018-01-01 2018-01-01:2018-04-01 2018-04-01:2018-07-01 2018-07-01:2018-10-01 2018-10-01:2019-01-01 2019-01-01:2019-04-01 2019-04-01:2019-07-01'
for row in $data
do
  row=${row//:/ }
  ary=($row)
  echo "Range ${ary[0]} ${ary[1]}"
  GHA2DB_CSVOUT="${ary[0]}_${ary[1]}.csv" "./sh/${1}.sh" "${ary[0]}" "${ary[1]}"
done
hdr=''
for row in $data
do
  row=${row//:/ }
  ary=($row)
  if [ -z "$hdr" ]
  then
    hdr=`head -n 1 "${ary[0]}_${ary[1]}.csv"`
    hdr="from,to,${hdr}"
    echo $hdr > out.csv
  fi
  rows=`tail -n +2 "${ary[0]}_${ary[1]}.csv"`
  echo "${ary[0]},${ary[1]},$rows" >> out.csv
done
