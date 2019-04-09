# devstats-reports

Various reports generated from DevStats databases

# Running reports

- Running report for multiple date ranges: `[SKIPDT=1] PG_PASS=... ./sh/rep.sh (quarters|years|join) (developers|developers_count|...|contributing_companies_list)`
- Developers details: `PG_PASS=... ./sh/developers.sh 2016-01-01 2017-01-01`.
- Developers count: `PG_PASS=... ./sh/developers_count.sh 2016-01-01 2017-01-01`.
- Developers list: `PG_PASS=... ./sh/developers_list.sh 2016-01-01 2017-01-01`.
- Contributing companies details: `PG_PASS=... ./sh/contributing_companies.sh 2016-01-01 2017-01-01`.
- Contributing companies count: `PG_PASS=... ./sh/contributing_companies_count.sh 2016-01-01 2017-01-01`.
- Contributing companies list: `PG_PASS=... ./sh/contributing_companies_list.sh 2016-01-01 2017-01-01`.
- Number of contributions: `PG_PASS=... ./sh/contributions.sh 2016-01-01 2017-01-01`.
- Number of opened PRs: `PG_PASS=... ./sh/prs.sh 2016-01-01 2017-01-01`.
