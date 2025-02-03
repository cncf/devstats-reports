# devstats-reports

Various reports generated from DevStats databases

# Running reports

On bare metal:

- For available reports, do: `ls sql/`. Use any file without `.sql` extension, for example: developers, issues, prs, commits etc.
- Running single report: `PG_PASS=... ./sh/run.sh (developers|issues|prs|..|contributing_companies_list) 2016-01-01 2017-01-01`.
- Some reports require passing additional parameters, example: `PG_PASS=... ./sh/run.sh company_contributions 2016-01-01 2017-01-01 {{type}} known {{company}} Google`.
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
- Some country stats: `PG_PASS=... ./sh/rep.sh years country_stats {{country}} 'United States' {{cumulative}} 'cum' {{period}} m {{repogroup}} all {{metric}} contributions`.
- Yearly contributors with know country: `PG_PASS=... SKIPDT=1 CUMULATIVE=2012-01-01 ./sh/rep.sh years contributors_count_with_country`.
- Yearly contributions from contributors with known country: `PG_PASS=... SKIPDT=1 CUMULATIVE=2012-01-01 ./sh/rep.sh years contributions_with_country`.
- After report is processed `out.csv` file is generated - it can be used for creating charts and other data analysis.
- Velocity metrics: `PG_PASS=... ./sh/rep.sh quarters velocity {{actor}} author`.
- Documentation commits, committers and companies: `PG_PASS=... CUMULATIVE=2014-01-01 ./sh/rep.sh quarters documentation {{actor}} author`.
- Committers stats: `PG_DB=cii PG_PASS=... ./affs/committers.sh`.

# Kubernetes

- Go to `cncf/devstats-helm` repo and follow instructions from `test/README.md` file, especially `Create reports pod` section.
- Once you shell into the reports pod, you can act just like on the bare metal server. Putting any CSV files generated while reporting in `/data` directory will make them available at: `https://teststats.cncf.io/backups/`.

Details about running reports pod:

- Create reports pod: `helm install devstats-test-reports ./devstats-helm --set skipSecrets=1,skipPVs=1,skipBackupsPV=1,skipVacuum=1,skipBackups=1,skipBootstrap=1,skipProvisions=1,skipCrons=1,skipAffiliations=1,skipGrafanas=1,skipServices=1,skipPostgres=1,skipIngress=1,skipStatic=1,skipNamespaces=1,reportsPod=1,projectsOverride='+cncf\,+opencontainers\,+istio\,+zephyr\,+linux\,+rkt\,+sam\,+azf\,+riff\,+fn\,+openwhisk\,+openfaas\,+cii\,+prestodb\,+opentracing'`
- Shell into reports pod: `../devstats-k8s-lf/util/pod_shell.sh devstats-reports` and then run some report: (see `cncf/devstats-reports:README.md`: example: `PG_DB=cii ./affs/unknown_committers.sh`). To shell from different namespace: `k exec -it -n devstats-test devstats-reports -- /bin/bash`.
- If you move any generated CSV file into the `/data` directory (which is RWX PV mount) - that file will be available at: `https://teststats.cncf.io/backups/`.
- Finally delete reporting pod: `helm delete devstats-test-reports` (but you can leave it running, it is just sleeping forever waiting for shell connection).


# Contributors

- Shell into the reports pod and execute `./contributors/update_contributors.sh`.
- Follow uploading to google sheets part of [this](https://github.com/cncf/devstats/blob/master/CONTRIBUTORS.md#kubernetes) documentation.


# Data for Prometheus report

Company contributions:

- `` PG_DB=prometheus PG_PASS=... ./sh/run.sh contributing_companies_list 2014-01-01 2020-01-01 {{lim}} 8 ``.
- `` PG_DB=prometheus PG_PASS=... ./sh/rep.sh quarters company_contributions {{type}} known {{company}} 'Robust Perception' ``.
- `` SKIPDT=1 PG_DB=prometheus PG_PASS=... ./sh/rep.sh quarters company_contributions {{type}} known {{company}} 'Red Hat' ``.

Company percent contributions:

- `` SKIPDT=1 PG_DB=prometheus PG_PASS=... ./sh/rep.sh quarters company_contributions {{type}} known {{company}} 'Robust Perception' ``.

Contributing companies:

- `` SKIPDT=1 CUMULATIVE=2012-01-01 PG_DB=prometheus PG_PASS=... ./sh/rep.sh quarters contributing_companies_count; cat out.csv ``.
- `` PG_DB=prometheus PG_PASS=... ./sh/rep.sh prometheus_join contributing_companies_count ``.

Contributors:

- `` SKIPDT=1 CUMULATIVE=2012-01-01 PG_DB=prometheus PG_PASS=... ./sh/rep.sh quarters contributors_count; cat out.csv ``.
- `` PG_DB=prometheus PG_PASS=... ./sh/rep.sh prometheus_join contributors_count ``.

Countries contributors:

- `` SKIPDT=1 PG_DB=prometheus PG_PASS=... ./sh/rep.sh months country_stats {{cumulative}} cum {{period}} m {{repogroup}} all {{metric}} contributors {{country}} Poland ``.
- `` CUMULATIVE=2012-01-01 PG_DB=prometheus PG_PASS=... ./sh/rep.sh prometheus_join contributors_with_country ``.
- `` CUMULATIVE=2012-01-01 SKIPDT=1 PG_DB=prometheus PG_PASS=... ./sh/rep.sh months country_contributors {{country}} 'United States' ``.
- `` CUMULATIVE=2012-01-01 PG_DB=prometheus SKIPDT=1 PG_PASS=... ./sh/rep.sh months contributors_count_with_country ``.

Countries contributions:

- `` SKIPDT=1 PG_DB=prometheus PG_PASS=... ./sh/rep.sh months country_stats {{cumulative}} cum {{period}} m {{repogroup}} all {{metric}} contributions {{country}} Poland ``.
- `` CUMULATIVE=2012-01-01 PG_DB=prometheus PG_PASS=... ./sh/rep.sh prometheus_join contributions_with_country ``.
- `` CUMULATIVE=2012-01-01 SKIPDT=1 PG_DB=prometheus PG_PASS=... ./sh/rep.sh months country_contributions {{country}} 'United States' ``.
- `` CUMULATIVE=2012-01-01 PG_DB=prometheus SKIPDT=1 PG_PASS=... ./sh/rep.sh months contributions_by_country ``.

PRs:

- `` CUMULATIVE=2012-01-01 SKIPDT=1 PG_DB=prometheus PG_PASS=... ./sh/rep.sh months prs ```.
- `` CUMULATIVE=2012-01-01 SKIPDT=1 PG_DB=prometheus PG_PASS=... ./sh/rep.sh quarters prs ```.
- `` CUMULATIVE=2012-01-01 SKIPDT=1 PG_DB=prometheus PG_PASS=... ./sh/rep.sh years prs ```.
- `` SKIPDT='' PG_DB=prometheus PG_PASS=... ./sh/rep.sh prometheus_join prs ``.

Commits:

- `` CUMULATIVE=2012-01-01 SKIPDT=1 PG_DB=prometheus PG_PASS=... ./sh/rep.sh months commits {{actor}} author ``.
- `` SKIPDT='' PG_DB=prometheus PG_PASS=... ./sh/rep.sh prometheus_join commits {{actor}} author ``.

Velocity:

- `` PG_PASS=... CUMULATIVE=2010-01-01 PG_DB=prometheus ./sh/rep.sh months velocity {{actor}} author ``.
- `` PG_PASS=... PG_DB=prometheus ./sh/rep.sh prometheus_join velocity {{actor}} author ``.

Documentation:

- `` PG_PASS=... CUMULATIVE=2010-01-01 SKIPDT='' PG_DB=prometheus ./sh/rep.sh months documentation {{actor}} author ``.


# Company reports

- `` clear; PG_DB=allprj ./affs/company_contributors.sh Apple ``.
- `` clear; PG_DB=allprj ./affs/company_contributors_repo_groups.sh 'Adobe Inc.' ``.
- They generate files for download, like: `` wget https://devstats.cncf.io/backups/allprj_Adobe_Inc__contributors.csv ``.

PRs:
- Company PRs monthly chart: `` PG_DB=allprj ./sh/rep.sh months company_prs {{company_name}} company_name {{company}} 'Adobe Inc.'; mv out.csv /data/adobe_monthly_prs.csv ``. Then `` wget https://devstats.cncf.io/backups/adobe_monthly_prs.csv ``.
- Company PRs total value: `` PG_DB=allprj ./sh/run.sh company_prs 2014-01-01 2024-01-01 {{company_name}} company_name {{company}} 'Adobe Inc.' ``.
- Company PRs monthly chart (cumulative): `` PG_DB=allprj CUMULATIVE=2010-01-01 ./sh/rep.sh months company_prs {{company_name}} company_name {{company}} 'Adobe Inc.'; mv out.csv /data/adobe_monthly_prs_cum.csv ``. Then `` wget https://devstats.cncf.io/backups/adobe_monthly_prs_cum.csv ``.

Commits:
- Company commits monthly chart: `` PG_DB=allprj ./sh/rep.sh months company_commits {{company_name}} company_name {{company}} 'Adobe Inc.' {{type}} known {{actor}} actor|author|committer; mv out.csv /data/adobe_monthly_commits.csv ``. Then `` wget https://devstats.cncf.io/backups/adobe_monthly_commits.csv ``.
- Company commits total value: `` PG_DB=allprj ./sh/run.sh company_commits 2014-01-01 2024-01-01 {{company_name}} company_name {{company}} 'Adobe Inc.' {{type}} known {{actor}} actor ``.
- Company commits monthly chart (cumulative): `` PG_DB=allprj CUMULATIVE=2010-01-01 ./sh/rep.sh months company_commits {{company_name}} company_name {{company}} 'Adobe Inc.' {{type}} known {{actor}} actor; mv out.csv /data/adobe_monthly_commits_cum.csv ``. Then `` wget https://devstats.cncf.io/backups/adobe_monthly_commits_cum.csv ``.


# Contributors having at least N

Contributors having at least N=20 contributions in PROJ=opentelementry project during the last year:

- `./contributors/contributors_with_n_dtrange.sh opentelemetry "now()-'1 year'::interval" 'now()' 20`.


# GDPR requests

- SSH into `node-0` DevStats node.
- Create reporting pod: `helm install devstats-prod-reports ./devstats-helm --set skipSecrets=1,skipPVs=1,skipBackupsPV=1,skipVacuum=1,skipBackups=1,skipBootstrap=1,skipProvisions=1,skipCrons=1,skipAffiliations=1,skipGrafanas=1,skipServices=1,skipPostgres=1,skipIngress=1,skipStatic=1,skipAPI=1,skipNamespaces=1,reportsPod=1,namespace='devstats-prod'`.
- Shell into reports pod: `../devstats-k8s-lf/util/pod_shell.sh devstats-reports` and then run some report: (see `cncf/devstats-reports:README.md`: example: `PG_DB=cii ./affs/unknown_committers.sh`). To shell from different namespace: `k exec -it -n devstats-prod devstats-reports -- /bin/bash`.
- `./sh/gdpr.sh 'Identity 1' 'name 2' 'email 3' ...`.
- You don't need to downcase names, remove spaces, @, ! etc.
- Finally delete reporting pod: `helm delete devstats-prod-reports` (but you can leave it running, it is just sleeping forever waiting for shell connection).


# World map

While in reporting pod:
- `clear && GHA2DB_CSVOUT=/data/world_map.csv GHA2DB_QOUT=1 PG_DB=gha ./sh/run.sh world_map 2014-01-01 2023-02-04 {{repo_group}} '' {{type}} login` - contributors.
- `clear && GHA2DB_CSVOUT=/data/world_map2.csv PG_DB=allprj ./sh/run.sh world_map 2014-01-01 2023-02-04 {{repo_group}} 'Kubernetes' {{type}} event_id` - contributions.

Locally:
- `wget https://devstats.cncf.io/backups/world_map.csv` - to download.


# Country ranks

This calculates country ranks (by the number of contributors and contributions):

- `` [EXTRA_COND="and \"Date from\" = '2023-01-01' and \"Date to\" = '2024-01-01'"] PG_DB=allprj ./sh/country_ranks.sh Poland ``.
- Then get the generated CSV: `` wget https://devstats.cncf.io/backups/Poland_country_ranks_in_allprj.csv ``.
- Make a copy of [this China report](https://docs.google.com/spreadsheets/d/1yjPjQIlW4i9frl103bmb66ibNt-G2CIre-hWJtYHNgc/edit#gid=0) and replace with some other country stats.
- Example report for [India](https://docs.google.com/spreadsheets/d/18qfMVFIUkaBpVhXvvidWXyxG1IGdnMwUhTw-WdZoPmA/edit?usp=sharing).


# Known/unknown contributors/contributions

For contributors we can have 3 situations:
- contributor without any affiliations defined - all his/her contributions are unknown.
- contributor with fully defined affiliations - all his/her contributions are affiliated to a company or marked as independent.
- contributor has partial affiliations defined (date ranges does not cover all time) and some of his/her contributions are known and others unknown - we call this mixed affiliation.
- You can run SQL to generate this data for any CNCF project for all time: `sql/percent_known_contributors.sql`.
- You can also run for a specific time range and CNCF project: `` PG_DB=allprj ./sh/run.sh contributions_affiliations_quality_percent 2023-01-01 2024-01-01 {{company_name}} company_name ``.
- Example result for all CNCF projects combined for all time:

```
devstats-reports:/# PG_DB=allprj ./sh/run.sh contributors_affiliations_quality_percent 2014-01-01 2024-01-01 {{company_name}} company_name
Compiled 2023-10-12_04:48:13AM, commit: 989cef61420a093e10d0a251408b6a4986133996 on Linux_darkstar_5.4.0-81-generic_#91-Ubuntu_SMP_Thu_Jul_15_19:09:17_UTC_2021_x86_64_x86_64_x86_64_GNU/Linux using go_version_go1.20.3_linux/amd64
/----------------------+------------------------+----------------------+------------------------+------------------+----------------+-------------------+-------------------+-------------------+-------------------+----------------------\
|known_contributors_max|unknown_contributors_max|known_contributors_min|unknown_contributors_min|mixed_contributors|all_contributors|percent_known_max  |percent_unknown_max|percent_known_min  |percent_unknown_min|percent_mixed         |
+----------------------+------------------------+----------------------+------------------------+------------------+----------------+-------------------+-------------------+-------------------+-------------------+----------------------+
|40729                 |186059                  |40715                 |186045                  |14                |226774          |17.9601718010001147|82.0460017462319314|17.9539982537680686|82.0398281989998853|0.00617354723204600175|
\----------------------+------------------------+----------------------+------------------------+------------------+----------------+-------------------+-------------------+-------------------+-------------------+----------------------/
Rows: 1
Time: 1m6.445201838s
```

This means that we know about 17.95% - 17.96% of all contributors (note that this number will be much higer for contributions, for contributors there is a very long tail of contributors making 1-3 contributions that were not checked yet).


For contributions we can have a similar 3 situaltions:
- contribution (like commit) can have up to 3 contributors: pusher/actor, committer and author.
- if all contribution's contributors affiliations are known at the contribution's create time then contribution is known.
- if none of contribution's contributors affiliations are known at that date then contribution is unknown.
- if we know affiliation details for some contributors and don't know for others then that contribution is mixed.
- You can run SQL to generate this data for any CNCF project for all time: `sql/percent_known_contributors.sql`.
- You can also run for a specific time range and CNCF project: `` PG_DB=grpc ./sh/run.sh contributors_affiliations_quality_percent 2020-01-01 2022-01-01 {{company_name}} company_name ``.
- Example result for all CNCF projects combined for all time:

```
devstats-reports:/# PG_DB=allprj ./sh/run.sh contributions_affiliations_quality_percent 2014-01-01 2024-01-01 {{company_name}} company_name
Compiled 2023-10-12_04:48:13AM, commit: 989cef61420a093e10d0a251408b6a4986133996 on Linux_darkstar_5.4.0-81-generic_#91-Ubuntu_SMP_Thu_Jul_15_19:09:17_UTC_2021_x86_64_x86_64_x86_64_GNU/Linux using go_version_go1.20.3_linux/amd64
/-----------------------+-------------------------+-----------------------+-------------------------+-----------------+-------------------+-------------------+-------------------+-------------------+-------------------+----------------------\
|known_contributions_max|unknown_contributions_max|known_contributions_min|unknown_contributions_min|all_contributions|mixed_contributions|percent_known_max  |percent_unknown_max|percent_known_min  |percent_unknown_min|percent_mixed         |
+-----------------------+-------------------------+-----------------------+-------------------------+-----------------+-------------------+-------------------+-------------------+-------------------+-------------------+----------------------+
|13333382               |1862500                  |13236307               |1765425                  |15098807         |97075              |88.3075199252497234|12.3354116653057424|87.6645883346942576|11.6924800747502766|0.64293159055546573978|
\-----------------------+-------------------------+-----------------------+-------------------------+-----------------+-------------------+-------------------+-------------------+-------------------+-------------------+----------------------/
Rows: 1
Time: 24.820014137s
```

This means that we know about 87.66% - 88.3% affilaitions of all contributions across all CNCF projects and across all time.

So as of 12/22/2023 we know company affiliations for about 88% of all contributions and we know about 18% of all contributors contributiong to all projects - and those a bit less than 20% contributors made almost 90% of all contributions across all time and all projects.


# Commits stats for projects and companies

While in the reporting pod run:
- `` PG_DB=allprj GHA2DB_CSVOUT=/data/company_project_commits_stats.csv ./sh/run.sh company_project_commits_stats 2014-01-01 2025-01-01 {{limit_companies}} 50 {{limit_projects}} 50 ``.

Locally:
- `` wget https://devstats.cncf.io/backups/company_project_commits_stats.csv `` - to download results.


# New companies after/since CNCF join

Example:

- `` PG_DB=etcd GHA2DB_CSVOUT=/data/etcd_new_companies.csv ./sh/custom.sh new_companies_list_after_date {{company_name}} company_name {{dtjoin}} 2018-12-11 ``.
- `` wget https://devstats.cncf.io/backups/etcd_new_companies.csv ``.


# Rust projects

While in the reporting pod run:
- `` PG_DB=allprj GHA2DB_CSVOUT=/data/rust_projects.csv ./sh/run.sh rust_projects 2000-01-01 2026-01-01 ``.
- `` PG_DB=allprj GHA2DB_CSVOUT=/data/rust_projects_by_files.csv ./sh/run.sh rust_projects_by_files 2000-01-01 2026-01-01 ``.

Locally:
- `` wget https://devstats.cncf.io/backups/rust_projects.csv `` - to download results.
- `` wget https://devstats.cncf.io/backups/rust_projects_by_files.csv `` - to download results.


For over-time (yearly) report use: `` PG_DB=allprj ./sh/rust_by_year.sh ``, `` PG_DB=allprj ./sh/rust_by_year_cumulative.sh `` on the reporting pod.

And then `` ./sh/get_rust_by_year.sh `` locally.
