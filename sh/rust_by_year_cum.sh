#!/bin/bash
for row in 2014-01-01:2015-01-01 2015-01-01:2016-01-01 2016-01-01:2017-01-01 2017-01-01:2018-01-01 2018-01-01:2019-01-01 2019-01-01:2020-01-01 2020-01-01:2021-01-01 2021-01-01:2022-01-01 2022-01-01:2023-01-01 2023-01-01:2024-01-01 2024-01-01:2025-01-01
do
  row=${row//:/ }
  ary=($row)
  dfrom="${ary[0]}"
  dto=${ary[1]}
  df=${dto//-/ }
  ary=($df)
  y="${ary[0]}"
  GHA2DB_CSVOUT="/data/rust_projects_cumulative_${y}.csv" ./sh/run.sh rust_projects "2014-01-01" "${dto}"
  GHA2DB_CSVOUT="/data/rust_projects_by_files_cumulative_${y}.csv" ./sh/run.sh rust_projects_by_files "2014-01-01" "${dto}"
  GHA2DB_CSVOUT="/data/rust_projects_by_n_files_cumulative_${y}.csv" ./sh/run.sh rust_projects_by_n_files "2014-01-01" "${dto}"
done
