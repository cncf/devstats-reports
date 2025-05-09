#!/bin/bash
for row in 2014-01-01:2015-01-01 2015-01-01:2016-01-01 2016-01-01:2017-01-01 2017-01-01:2018-01-01 2018-01-01:2019-01-01 2019-01-01:2020-01-01 2020-01-01:2021-01-01 2021-01-01:2022-01-01 2022-01-01:2023-01-01 2023-01-01:2024-01-01 2024-01-01:2025-01-01
do
  row=${row//:/ }
  ary=($row)
  dfrom="${ary[0]}"
  dto=${ary[1]}
  df=${dfrom//-/ }
  ary=($df)
  y="${ary[0]}"
  GHA2DB_CSVOUT="/data/rust_projects_${y}.csv" ./sh/run.sh rust_projects "${dfrom}" "${dto}"
  GHA2DB_CSVOUT="/data/rust_projects_by_files_${y}.csv" ./sh/run.sh rust_projects_by_files "${dfrom}" "${dto}"
  GHA2DB_CSVOUT="/data/rust_projects_by_n_files_${y}.csv" ./sh/run.sh rust_projects_by_n_files "${dfrom}" "${dto}"
done
