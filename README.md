# devstats-reports

Various reports generated from DevStats databases

# Running reports

On bare metal:

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

- Create reports pod: `helm install devstats-test-reports ./devstats-helm --set skipSecrets=1,skipPVs=1,skipBackupsPV=1,skipVacuum=1,skipBackups=1,skipBootstrap=1,skipProvisions=1,skipCrons=1,skipAffiliations=1,skipGrafanas=1,skipServices=1,skipPostgres=1,skipIngress=1,skipStatic=1,skipNamespaces=1,reportsPod=1,projectsOverride='+cncf\,+opencontainers\,+istio\,+knative\,+zephyr\,+linux\,+rkt\,+sam\,+azf\,+riff\,+fn\,+openwhisk\,+openfaas\,+cii\,+prestodb'`
- Shell into reports pod: `../devstats-k8s-lf/util/pod_shell.sh devstats-reports` and then run some report: (see `cncf/devstats-reports:README.md`: example: `PG_DB=cii ./affs/unknown_committers.sh`). To shell from different namespace: `k exec -it -n devstats-test devstats-reports -- /bin/bash`.
- If you move any generated CSV file into the `/data` directory (which is RWX PV mount) - that file will be available at: `https://teststats.cncf.io/backups/`.
- Finally delete reporting pod: `helm delete devstats-test-reports` (but you can leave it running, it is just sleeping forever waiting for shell connection).


# Contributors

- Shell into the reports pod and execute `./contributors/update_contributors.sh`.
- Follow uploading to google sheets part of [this](https://github.com/cncf/devstats/blob/master/CONTRIBUTORS.md#kubernetes) documentation.


# Data for Prometheus report

Company contributions:

- `` PG_DB=prometheus PG_PASS=...  ./sh/run.sh contributing_companies_list 2014-01-01 2020-01-01 {{lim}} 8 ``.
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


# Company contributors

- `` clear; PG_DB=allprj ./affs/company_contributors.sh Apple ``.


# Contributors having at least N

Contributors having at least N=20 contributions in PROJ=opentelementry project during the last year:

- `./contributors/contributors_with_n_dtrange.sh opentelemetry "now()-'1 year'::interval" 'now()' 20`.

# GDPR requests

- `./sh/gdpr.sh 'Identity 1' 'name 2' 'email 3' ...`.
