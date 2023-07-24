with all_dates as (
select
2014-01-01'::timestamp as "Date from",
2015-01-01'::timestamp as "Date to"
union select
2015-01-01', '2016-01-01'
union select
2016-01-01', '2017-01-01'
union select
2017-01-01', '2018-01-01'
union select
2018-01-01', '2019-01-01'
union select
2019-01-01', '2020-01-01'
union select
2020-01-01', '2021-01-01'
union select
2021-01-01', '2022-01-01'
union select
2022-01-01', '2023-01-01'
union select
2023-01-01', '2024-01-01'
union select
2014-01-01', '2024-01-01'
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
and lower(a.login) not like all(array['claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci'])
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
Date from,
Date to,
CNCF Project
order by
Contributors desc
) as "Contributors Rank",
row_number() over (
partition by
Date from,
Date to,
CNCF Project
order by
Contributions desc
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
and lower(a.login) not like all(array['claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci'])
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
cd."Contributors" as "Israel Contributors",
cd."Contributions" as "Israel Contributions",
ad."Contributors" as "All Contributors",
ad."Contributions" as "All Contributions",
(100.0 * cd."Contributors") / ad."Contributors" as "Israel Contributors Percent",
(100.0 * cd."Contributions") / ad."Contributions" as "Israel Contributions Percent",
cd."Contributors Rank" as "Israel Contributors Rank",
cd."Contributions Rank" as "Israel Contributions Rank"
from
country_data cd,
all_data ad
where
cd."CNCF Project" = ad."CNCF Project"
and cd."Date from" = ad."Date from"
and cd."Date to" = ad."Date to"
and cd."Country" = 'Israel'
order by
cd."Date from",
cd."Date to",
Israel Contributors Percent desc
;
