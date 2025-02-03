#!/bin/bash
for y in 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 2025
do
  wget "https://devstats.cncf.io/backups/rust_projects_${y}.csv"
  wget "https://devstats.cncf.io/backups/rust_projects_cumulative_${y}.csv"
done
