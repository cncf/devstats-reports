with all_dates as (
select
'2014-01-01'::timestamp as "Date from",
'2015-01-01'::timestamp as "Date to"
union select
'2015-01-01', '2016-01-01'
union select
'2016-01-01', '2017-01-01'
union select
'2017-01-01', '2018-01-01'
union select
'2018-01-01', '2019-01-01'
union select
'2019-01-01', '2020-01-01'
union select
'2020-01-01', '2021-01-01'
union select
'2021-01-01', '2022-01-01'
union select
'2022-01-01', '2023-01-01'
union select
'2023-01-01', '2024-01-01'
union select
'2014-01-01', '2024-01-01'
), dates as (
select
*
from
all_dates
where
1 = 1
-- and "Date from" = '2014-01-01'
-- and "Date to" = '2024-01-01'
), c_data as (
select
d."Date from",
d."Date to",
r.repo_group as "CNCF Project",
a.country_name as "Country",
count(distinct a.login) as "Contributors",
count(e.id) as "Contributions"
from
gha_events e,
gha_actors a,
gha_repos r,
dates d
where
e.actor_id = a.id
and e.dup_actor_login = a.login
and e.repo_id = r.id
and e.dup_repo_name = r.name
and lower(a.login) not like all(array['alighrobot', 'angular-builds', 'appveyorbot', 'architectbot', 'asfgit', 'athenabot', 'atlantisbot', 'auto', 'blueorangutan', 'bosh-ci-push-pull', 'cadvisorjenkinsbot', 'cf-buildpacks-eng', 'changelogbot', 'ci', 'claude', 'clrbuilder', 'codex', 'containersshbuilder', 'coreosbot', 'covbot', 'coveralls', 'cubic-dev-ai', 'damn good b0t', 'devolutionsbot', 'devstats-sync', 'dosu', 'fermybot', 'fluxcdbot', 'fossabot', 'gemini-code-assist', 'getporterbot', 'gitcoinbot', 'github-cncf-landscape-notifs', 'github-harold_pins', 'gocursor', 'goodluckbot', 'googlebot', 'goreleaserbot', 'gprasath', 'greptileai', 'grpc-kokoro', 'infraq', 'invalid-email-address', 'iptecharch-builder', 'kaipilotbot', 'katacontainersbot', 'kernelprbot', 'krkn-chaos', 'kuasar-io-dev', 'kubescapebot', 'l5io', 'litmusbot', 'megaeasex', 'modular-magician', 'monkeycode-ai', 'nsmbot', 'oai-codex', 'opencontrail-ci-admin', 'openebs-pro-sa', 'openfeaturebot', 'openssl-machine', 'opentelemetrybot', 'oss-sentinel-ai', 'oss-taishan-ai', 'ovsrobot', 'pckgrbot', 'persesbot', 'pikbot', 'podmanbot', 'poiana', 'pouchrobot', 'projectstacker', 'prowbot', 'rktbot', 'securitylab-codeanalysis', 'sizebot', 'sourcery-ai', 'spinframeworkbot', 'spinnakerbot', 'spinnakerbot2', 'startxfr', 'stateful-wombot', 'streamnativebot', 'thelinuxfoundation', 'thinkbotbot', 'ti-srebot', 'titanium-octobot', 'travisbuddy', 'tremorbot', 'unownbot', 'web-flow', 'weblate', 'wingetbot', 'zephyr-github', 'zephyrbot', 'actions%', 'claassistant%', 'cncf-bot%', 'codecov%', 'coderabbit%', 'copilot%', 'dependabot%', 'github %', 'github-action%', 'imgbot%', 'jenkins-%', 'k8s-%', 'mergify%', 'qodo-%', 'snyk%', 'strimzi%', 'svc%', 'travis%bot', 'prom%bot', 'promptless%', '%-bot', '%-robot', '%bot-%', '%[%bot]%', '%ci%bot', '%cla%bot%', '%autobot', '%buildbot%', '%copybara%', '%renovate%', '%envoy-filter-example%', '%automat%', '%agent', '%-ci', '%-gerrit', '%-infra', '%-jenkins', '%-release', '%-service%', '%-team%', '%-testing', '% bot', '% ci', '% team', '% releaser', '%machine account%'])
and e.created_at > d."Date from"
and e.created_at < d."Date to"
and length(a.country_id) = 2
group by
d."Date from",
d."Date to",
r.repo_group,
a.country_name
), country_data as (
select
*,
row_number() over (
partition by
"Date from",
"Date to",
"CNCF Project"
order by
"Contributors" desc
) as "Contributors Rank",
row_number() over (
partition by
"Date from",
"Date to",
"CNCF Project"
order by
"Contributions" desc
) as "Contributions Rank"
from
c_data
), all_data as (
select
d."Date from",
d."Date to",
r.repo_group as "CNCF Project",
count(distinct a.login) as "Contributors",
count(e.id) as "Contributions"
from
gha_events e,
gha_actors a,
gha_repos r,
dates d
where
e.actor_id = a.id
and e.dup_actor_login = a.login
and e.repo_id = r.id
and e.dup_repo_name = r.name
and lower(a.login) not like all(array['alighrobot', 'angular-builds', 'appveyorbot', 'architectbot', 'asfgit', 'athenabot', 'atlantisbot', 'auto', 'blueorangutan', 'bosh-ci-push-pull', 'cadvisorjenkinsbot', 'cf-buildpacks-eng', 'changelogbot', 'ci', 'claude', 'clrbuilder', 'codex', 'containersshbuilder', 'coreosbot', 'covbot', 'coveralls', 'cubic-dev-ai', 'damn good b0t', 'devolutionsbot', 'devstats-sync', 'dosu', 'fermybot', 'fluxcdbot', 'fossabot', 'gemini-code-assist', 'getporterbot', 'gitcoinbot', 'github-cncf-landscape-notifs', 'github-harold_pins', 'gocursor', 'goodluckbot', 'googlebot', 'goreleaserbot', 'gprasath', 'greptileai', 'grpc-kokoro', 'infraq', 'invalid-email-address', 'iptecharch-builder', 'kaipilotbot', 'katacontainersbot', 'kernelprbot', 'krkn-chaos', 'kuasar-io-dev', 'kubescapebot', 'l5io', 'litmusbot', 'megaeasex', 'modular-magician', 'monkeycode-ai', 'nsmbot', 'oai-codex', 'opencontrail-ci-admin', 'openebs-pro-sa', 'openfeaturebot', 'openssl-machine', 'opentelemetrybot', 'oss-sentinel-ai', 'oss-taishan-ai', 'ovsrobot', 'pckgrbot', 'persesbot', 'pikbot', 'podmanbot', 'poiana', 'pouchrobot', 'projectstacker', 'prowbot', 'rktbot', 'securitylab-codeanalysis', 'sizebot', 'sourcery-ai', 'spinframeworkbot', 'spinnakerbot', 'spinnakerbot2', 'startxfr', 'stateful-wombot', 'streamnativebot', 'thelinuxfoundation', 'thinkbotbot', 'ti-srebot', 'titanium-octobot', 'travisbuddy', 'tremorbot', 'unownbot', 'web-flow', 'weblate', 'wingetbot', 'zephyr-github', 'zephyrbot', 'actions%', 'claassistant%', 'cncf-bot%', 'codecov%', 'coderabbit%', 'copilot%', 'dependabot%', 'github %', 'github-action%', 'imgbot%', 'jenkins-%', 'k8s-%', 'mergify%', 'qodo-%', 'snyk%', 'strimzi%', 'svc%', 'travis%bot', 'prom%bot', 'promptless%', '%-bot', '%-robot', '%bot-%', '%[%bot]%', '%ci%bot', '%cla%bot%', '%autobot', '%buildbot%', '%copybara%', '%renovate%', '%envoy-filter-example%', '%automat%', '%agent', '%-ci', '%-gerrit', '%-infra', '%-jenkins', '%-release', '%-service%', '%-team%', '%-testing', '% bot', '% ci', '% team', '% releaser', '%machine account%'])
and e.created_at > d."Date from"
and e.created_at < d."Date to"
and length(a.country_id) = 2
group by
d."Date from",
d."Date to",
r.repo_group
)
select
cd."Date from",
cd."Date to",
cd."CNCF Project",
cd."Contributors" as "China Contributors",
cd."Contributions" as "China Contributions",
ad."Contributors" as "All Contributors",
ad."Contributions" as "All Contributions",
(100.0 * cd."Contributors") / ad."Contributors" as "China Contributors Percent",
(100.0 * cd."Contributions") / ad."Contributions" as "China Contributions Percent",
cd."Contributors Rank" as "China Contributors Rank",
cd."Contributions Rank" as "China Contributions Rank"
from
country_data cd,
all_data ad
where
cd."CNCF Project" = ad."CNCF Project"
and cd."Date from" = ad."Date from"
and cd."Date to" = ad."Date to"
and cd."Country" = 'China'
order by
cd."Date from",
cd."Date to",
"China Contributors Percent" desc
;
