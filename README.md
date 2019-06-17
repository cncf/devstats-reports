# devstats-reports

Various reports generated from DevStats databases

# Running reports

- For available reports, do: `ls sql/`. Use any file without `.sql` extension, for example: developers, issues, prs, commits etc.
- Running single report: `PG_PASS=...  ./sh/run.sh (developers|issues|prs|..|contributing_companies_list) 2016-01-01 2017-01-01`.
- Some reports require passing additional parameters, example: `PG_PASS=...  ./sh/run.sh company_contributions 2016-01-01 2017-01-01 {{type}} known {{company}} Google`.
- Running report for multiple date ranges: `[SKIPDT=1] PG_PASS=... ./sh/rep.sh (quarters|years|join|YYYY-MM-DD) (developers|developers_count|...|contributing_companies_list) {{actor}} author`.
- Running cumulative report: `CUMULATIVE=2014-01-01 PG_PASS=... ./sh/rep.sh (quarters|years|join|YYYY-MM-DD) (developers|developers_count|...|contributing_companies_list) {{actor}} author`.
- Additional parameters example: `SKIPDT=1 PG_PASS=... ./sh/rep.sh years company_contributions {{type}} all {{company}} 'Red Hat'`.
- Example with limits: `SKIPDT=1 PG_PASS=... CUMULATIVE=2012-01-01 ./sh/rep.sh quarters contributing_companies_list {{lim}} 8`.
- Company commits percent: `SKIPDT=1 PG_PASS=... ./sh/rep.sh 2015-07-21 company_commits {{type}} known {{actor}} author {{company}} 'Red Hat'`.
- Company committers list: `SKIPDT=1 PG_PASS=... ./sh/rep.sh 2016-03-10 company_committers_list {{order}} 'commits desc' {{actor}} author`.
- Company committers percent: `SKIPDT=1 PG_PASS=... ./sh/rep.sh 2016-03-10 company_committers_percent {{type}} all {{actor}} author {{company}} 'Google'`.
- Stats for all CNCF projects: `PG_PASS=... ./sh/all.sh ./sh/rep.sh all contributors_count`.
- Example contributors stats: `PG_PASS=... ./sh/all.sh ./sh/rep.sh all company_contributors {{type}} known {{company}} Apple`.
- Company committers per CNCF projects: `SKIPDT=1 PG_PASS=... ./sh/all.sh ./sh/rep.sh all company_committers_percent {{type}} known {{company}} Apple {{actor}} author`.
- Company committers emails for all CNCF projects: `SKIPDT=1 PG_DB=allprj CSV=emails.csv PG_PASS=... ./sh/rep.sh all company_committers_emails {{type}} known {{company}} Apple {{actor}} author`.
- List company's individual commits: `SKIPDT=1 PG_DB=allprj PG_PASS=... CSV=commits_links.csv ./sh/rep.sh all company_commits_links {{type}} known {{company}} Apple {{actor}} author`.
- After report is processed `out.csv` file is generated - it can be used for creating charts and other data analysis.
