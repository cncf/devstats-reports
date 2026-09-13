with c_data as (
  select
    a.country_name as "Country",
      count(distinct a.login) as "Contributors",
      count(e.id) as "Contributions"
  from
    gha_events e, 
    gha_actors a
  where
    e.actor_id = a.id
    and e.dup_actor_login = a.login
    and lower(a.login) not like all(array['alighrobot', 'angular-builds', 'appveyorbot', 'architectbot', 'asfgit', 'athenabot', 'atlantisbot', 'auto', 'blueorangutan', 'bosh-ci-push-pull', 'cadvisorjenkinsbot', 'cf-buildpacks-eng', 'changelogbot', 'claude', 'clrbuilder', 'codex', 'containersshbuilder', 'coreosbot', 'covbot', 'coveralls', 'cubic-dev-ai', 'devolutionsbot', 'devstats-sync', 'dosu', 'fermybot', 'fluxcdbot', 'fossabot', 'gemini-code-assist', 'getporterbot', 'gitcoinbot', 'github-cncf-landscape-notifs', 'github-harold_pins', 'goodluckbot', 'googlebot', 'goreleaserbot', 'gprasath', 'greptileai', 'infraq', 'invalid-email-address', 'kaipilotbot', 'katacontainersbot', 'kernelprbot', 'kuasar-io-dev', 'kubescapebot', 'litmusbot', 'megaeasex', 'nsmbot', 'openebs-pro-sa', 'openfeaturebot', 'openssl-machine', 'opencontrail-ci-admin', 'opentelemetrybot', 'ovsrobot', 'pckgrbot', 'pikbot', 'podmanbot', 'poiana', 'pouchrobot', 'prowbot', 'rktbot', 'securitylab-codeanalysis', 'sizebot', 'sourcery-ai', 'spinframeworkbot', 'spinnakerbot', 'startxfr', 'stateful-wombot', 'streamnativebot', 'thelinuxfoundation', 'thinkbotbot', 'ti-srebot', 'titanium-octobot', 'travisbuddy', 'tremorbot', 'unownbot', 'web-flow', 'weblate', 'wingetbot', 'zephyr-github', 'zephyrbot', 'actions%', 'claassistant%', 'cncf-bot%', 'codecov%', 'coderabbit%', 'copilot%', 'dependabot%', 'github %', 'github-action%', 'imgbot%', 'jenkins-%', 'k8s-%', 'mergify%', 'qodo-%', 'snyk%', 'strimzi%', 'svc%', 'travis%bot', 'prom%bot', '%-bot', '%-robot', '%bot-%', '%[%bot]%', '%ci%bot', '%cla%bot%', '%autobot', '%buildbot%', '%copybara%', '%renovate%', '%envoy-filter-example%', '%automat%', '%agent', '%-ci', '%-gerrit', '%-infra', '%-jenkins', '%-release', '%-service%', '%-team%', '%-testing', '% bot', '% ci', '% team'])
    and length(a.country_id) = 2
  group by
    a.country_name
) 
/*
select 
  row_number() over (order by s."Contributors" desc) as "Rank",
  s."Country",
  s."Contributors"
from
  c_data s
order by
  s."Contributors" desc
limit 100;
*/
select 
  row_number() over (order by s."Contributions" desc) as "Rank",
  s."Country",
  s."Contributions"
from
  c_data s
order by
  s."Contributions" desc
limit 100;
