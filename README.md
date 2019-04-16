# devstats-reports

Various reports generated from DevStats databases

# Running reports

- For available reports, do: `ls sql/`. Use any file without `.sql` extension, for example: developers, issues, prs, commits etc.
- Running single report: `PG_PASS=...  ./sh/run.sh (developers|issues|prs|..|contributing_companies_list) 2016-01-01 2017-01-01`.
- Some reports require passing additional parameters, example: `PG_PASS=...  ./sh/run.sh company_contributions 2016-01-01 2017-01-01 {{company}} Google`.
- Running report for multiple date ranges: `[SKIPDT=1] PG_PASS=... ./sh/rep.sh (quarters|years|join) (developers|developers_count|...|contributing_companies_list)`.
- Additional parameters example: `SKIPDT=1 PG_PASS=... ./sh/rep.sh years company_contributions`.
