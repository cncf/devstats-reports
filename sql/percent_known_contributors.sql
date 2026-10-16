select
  sub.known_contributors as known_contributors_max,     -- known here is anybody who have at least 1 known contribution
  sub.unknown_contributors as unknown_contributors_max, -- unknown here is anybody with at least 1 unknown contribution
  sub.all_contributors - sub.unknown_contributors as known_contributors_min,
  sub.all_contributors - sub.known_contributors as unknown_contributors_min,
  (sub.known_contributors + sub.unknown_contributors) - sub.all_contributors as mixed_contributors, -- those who have both known and unknown contributions
  sub.all_contributors,
  (sub.known_contributors * 100.0) / case sub.all_contributors when 0 then 1 else sub.all_contributors end as percent_known_max,
  (sub.unknown_contributors * 100.0) / case sub.all_contributors when 0 then 1 else sub.all_contributors end as percent_unknown_max,
  ((sub.all_contributors - sub.unknown_contributors) * 100.0) / case sub.all_contributors when 0 then 1 else sub.all_contributors end as percent_known_min,
  ((sub.all_contributors - sub.known_contributors) * 100.0) / case sub.all_contributors when 0 then 1 else sub.all_contributors end as percent_unknown_min,
  (((sub.known_contributors + sub.unknown_contributors) - sub.all_contributors) * 100.0) / case sub.all_contributors when 0 then 1 else sub.all_contributors end as percent_mixed
from (
  select
    count(distinct c.actor) as all_contributors,
    count(distinct c.actor) filter (where c.company_name is null) as unknown_contributors,
    count(distinct c.actor) filter (where c.company_name is not null) as known_contributors
    -- can also use 'c.actor_id::text || c.actor' as actor ident
  from (
    select
      e.id,
      e.actor_id,
      e.dup_actor_login as actor,
      af.company_name
    from
      gha_events e
    left join
      gha_actors_affiliations af
    on
      e.actor_id = af.actor_id
      and af.dt_from <= e.created_at
      and af.dt_to > e.created_at
    where
      (lower(e.dup_actor_login) not like all(array['alighrobot', 'amplabjenkins', 'angular-builds', 'appveyorbot', 'architectbot', 'asfgit', 'athenabot', 'atlantisbot', 'auto', 'blackduck-serv-builder', 'blueorangutan', 'bosh-ci-push-pull', 'buildhive', 'cadvisorjenkinsbot', 'cf-buildpacks-eng', 'changelogbot', 'ci', 'claude', 'cloudbees-pull-request-builder', 'clrbuilder', 'codelingobot', 'codex', 'codspeedbot', 'containersshbuilder', 'coreosbot', 'covbot', 'coveralls', 'cubic-dev-ai', 'cvp-ops', 'damn good b0t', 'devolutionsbot', 'devstats-sync', 'dosu', 'ericwittbot', 'fermybot', 'fluxcdbot', 'fossabot', 'gemini-code-assist', 'getporterbot', 'gitcoinbot', 'github-cncf-landscape-notifs', 'github-harold_pins', 'gocursor', 'goodluckbot', 'googlebot', 'gopherbot', 'goreleaserbot', 'gprasath', 'grafanabot', 'greptileai', 'grpc-kokoro', 'heptibot', 'hubot', 'infraq', 'intellij-rainbow-brackets', 'invalid-email-address', 'iptecharch-builder', 'issuehuntbot', 'jenkinsadmin', 'jfrogbot', 'jreleaserbot', 'jsdelivrbot', 'k3aibot', 'kaipilotbot', 'katacontainersbot', 'kernelprbot', 'krkn-chaos', 'kuasar-io-dev', 'kubescapebot', 'l5io', 'letsusegerrit', 'litmusbot', 'maxio', 'megaeasebot', 'megaeasex', 'mentatbot', 'modular-magician', 'monkeycode-ai', 'msftclas', 'msftgits', 'nsmbot', 'oai-codex', 'oceanjxbot', 'opencontrail-ci-admin', 'openebs-pro-sa', 'openfeaturebot', 'openssl-machine', 'opentelemetrybot', 'oss-sentinel-ai', 'oss-taishan-ai', 'otcbot', 'ovsrobot', 'pckgrbot', 'persesbot', 'pikbot', 'podmanbot', 'poiana', 'pouchrobot', 'projectstacker', 'prowbot', 'rancherbot', 'repobirdbot', 'rktbot', 'securitylab-codeanalysis', 'sizebot', 'sourcery-ai', 'spellarbot', 'spinframeworkbot', 'spinnakerbot', 'spinnakerbot2', 'stacklokbot', 'startxfr', 'stateful-wombot', 'streamnativebot', 'thelinuxfoundation', 'thinkbotbot', 'ti-srebot', 'titanium-octobot', 'travisbuddy', 'tremorbot', 'twbs-grunt', 'unownbot', 'vmwghbot', 'vsxen', 'waxobot', 'weaveworksbot', 'web-flow', 'weblate', 'wingetbot', 'yahoocla', 'zephyr-github', 'zephyrbot', 'actions%', 'claassistant%', 'cncf-bot%', 'codecov%', 'coderabbit%', 'copilot%', 'dependabot%', 'github %', 'github-action%', 'imgbot%', 'jenkins-%', 'k8s-%', 'mergify%', 'qodo-%', 'snyk%', 'strimzi%', 'svc%', 'travis%bot', 'prom%bot', 'promptless%', '%-bot', '%-robot', '%bot-%', '%[%bot]%', '%ci%bot', '%cla%bot%', '%autobot', '%buildbot%', '%copybara%', '%renovate%', '%envoy-filter-example%', '%automat%', '%agent', '%-ci', '%-gerrit', '%-infra', '%-jenkins', '%-release', '%-service%', '%-team%', '%-testing', '% bot', '% ci', '% team', '% releaser', '%machine account%']))
      and e.type in (
        'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
        'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
      )
    union select
      c.event_id, 
      c.committer_id,
      c.dup_committer_login,
      af.company_name
    from
      gha_commits c
    left join
      gha_actors_affiliations af
    on
      c.committer_id = af.actor_id
      and af.dt_from <= c.dup_created_at
      and af.dt_to > c.dup_created_at
    where 
      c.committer_id is not null
      and (lower(c.dup_committer_login) not like all(array['alighrobot', 'amplabjenkins', 'angular-builds', 'appveyorbot', 'architectbot', 'asfgit', 'athenabot', 'atlantisbot', 'auto', 'blackduck-serv-builder', 'blueorangutan', 'bosh-ci-push-pull', 'buildhive', 'cadvisorjenkinsbot', 'cf-buildpacks-eng', 'changelogbot', 'ci', 'claude', 'cloudbees-pull-request-builder', 'clrbuilder', 'codelingobot', 'codex', 'codspeedbot', 'containersshbuilder', 'coreosbot', 'covbot', 'coveralls', 'cubic-dev-ai', 'cvp-ops', 'damn good b0t', 'devolutionsbot', 'devstats-sync', 'dosu', 'ericwittbot', 'fermybot', 'fluxcdbot', 'fossabot', 'gemini-code-assist', 'getporterbot', 'gitcoinbot', 'github-cncf-landscape-notifs', 'github-harold_pins', 'gocursor', 'goodluckbot', 'googlebot', 'gopherbot', 'goreleaserbot', 'gprasath', 'grafanabot', 'greptileai', 'grpc-kokoro', 'heptibot', 'hubot', 'infraq', 'intellij-rainbow-brackets', 'invalid-email-address', 'iptecharch-builder', 'issuehuntbot', 'jenkinsadmin', 'jfrogbot', 'jreleaserbot', 'jsdelivrbot', 'k3aibot', 'kaipilotbot', 'katacontainersbot', 'kernelprbot', 'krkn-chaos', 'kuasar-io-dev', 'kubescapebot', 'l5io', 'letsusegerrit', 'litmusbot', 'maxio', 'megaeasebot', 'megaeasex', 'mentatbot', 'modular-magician', 'monkeycode-ai', 'msftclas', 'msftgits', 'nsmbot', 'oai-codex', 'oceanjxbot', 'opencontrail-ci-admin', 'openebs-pro-sa', 'openfeaturebot', 'openssl-machine', 'opentelemetrybot', 'oss-sentinel-ai', 'oss-taishan-ai', 'otcbot', 'ovsrobot', 'pckgrbot', 'persesbot', 'pikbot', 'podmanbot', 'poiana', 'pouchrobot', 'projectstacker', 'prowbot', 'rancherbot', 'repobirdbot', 'rktbot', 'securitylab-codeanalysis', 'sizebot', 'sourcery-ai', 'spellarbot', 'spinframeworkbot', 'spinnakerbot', 'spinnakerbot2', 'stacklokbot', 'startxfr', 'stateful-wombot', 'streamnativebot', 'thelinuxfoundation', 'thinkbotbot', 'ti-srebot', 'titanium-octobot', 'travisbuddy', 'tremorbot', 'twbs-grunt', 'unownbot', 'vmwghbot', 'vsxen', 'waxobot', 'weaveworksbot', 'web-flow', 'weblate', 'wingetbot', 'yahoocla', 'zephyr-github', 'zephyrbot', 'actions%', 'claassistant%', 'cncf-bot%', 'codecov%', 'coderabbit%', 'copilot%', 'dependabot%', 'github %', 'github-action%', 'imgbot%', 'jenkins-%', 'k8s-%', 'mergify%', 'qodo-%', 'snyk%', 'strimzi%', 'svc%', 'travis%bot', 'prom%bot', 'promptless%', '%-bot', '%-robot', '%bot-%', '%[%bot]%', '%ci%bot', '%cla%bot%', '%autobot', '%buildbot%', '%copybara%', '%renovate%', '%envoy-filter-example%', '%automat%', '%agent', '%-ci', '%-gerrit', '%-infra', '%-jenkins', '%-release', '%-service%', '%-team%', '%-testing', '% bot', '% ci', '% team', '% releaser', '%machine account%']))
    union select
      c.event_id, 
      c.author_id,
      c.dup_author_login,
      af.company_name
    from
      gha_commits c
    left join
      gha_actors_affiliations af
    on
      c.author_id = af.actor_id
      and af.dt_from <= c.dup_created_at
      and af.dt_to > c.dup_created_at
    where 
      c.author_id is not null
      and (lower(c.dup_author_login) not like all(array['alighrobot', 'amplabjenkins', 'angular-builds', 'appveyorbot', 'architectbot', 'asfgit', 'athenabot', 'atlantisbot', 'auto', 'blackduck-serv-builder', 'blueorangutan', 'bosh-ci-push-pull', 'buildhive', 'cadvisorjenkinsbot', 'cf-buildpacks-eng', 'changelogbot', 'ci', 'claude', 'cloudbees-pull-request-builder', 'clrbuilder', 'codelingobot', 'codex', 'codspeedbot', 'containersshbuilder', 'coreosbot', 'covbot', 'coveralls', 'cubic-dev-ai', 'cvp-ops', 'damn good b0t', 'devolutionsbot', 'devstats-sync', 'dosu', 'ericwittbot', 'fermybot', 'fluxcdbot', 'fossabot', 'gemini-code-assist', 'getporterbot', 'gitcoinbot', 'github-cncf-landscape-notifs', 'github-harold_pins', 'gocursor', 'goodluckbot', 'googlebot', 'gopherbot', 'goreleaserbot', 'gprasath', 'grafanabot', 'greptileai', 'grpc-kokoro', 'heptibot', 'hubot', 'infraq', 'intellij-rainbow-brackets', 'invalid-email-address', 'iptecharch-builder', 'issuehuntbot', 'jenkinsadmin', 'jfrogbot', 'jreleaserbot', 'jsdelivrbot', 'k3aibot', 'kaipilotbot', 'katacontainersbot', 'kernelprbot', 'krkn-chaos', 'kuasar-io-dev', 'kubescapebot', 'l5io', 'letsusegerrit', 'litmusbot', 'maxio', 'megaeasebot', 'megaeasex', 'mentatbot', 'modular-magician', 'monkeycode-ai', 'msftclas', 'msftgits', 'nsmbot', 'oai-codex', 'oceanjxbot', 'opencontrail-ci-admin', 'openebs-pro-sa', 'openfeaturebot', 'openssl-machine', 'opentelemetrybot', 'oss-sentinel-ai', 'oss-taishan-ai', 'otcbot', 'ovsrobot', 'pckgrbot', 'persesbot', 'pikbot', 'podmanbot', 'poiana', 'pouchrobot', 'projectstacker', 'prowbot', 'rancherbot', 'repobirdbot', 'rktbot', 'securitylab-codeanalysis', 'sizebot', 'sourcery-ai', 'spellarbot', 'spinframeworkbot', 'spinnakerbot', 'spinnakerbot2', 'stacklokbot', 'startxfr', 'stateful-wombot', 'streamnativebot', 'thelinuxfoundation', 'thinkbotbot', 'ti-srebot', 'titanium-octobot', 'travisbuddy', 'tremorbot', 'twbs-grunt', 'unownbot', 'vmwghbot', 'vsxen', 'waxobot', 'weaveworksbot', 'web-flow', 'weblate', 'wingetbot', 'yahoocla', 'zephyr-github', 'zephyrbot', 'actions%', 'claassistant%', 'cncf-bot%', 'codecov%', 'coderabbit%', 'copilot%', 'dependabot%', 'github %', 'github-action%', 'imgbot%', 'jenkins-%', 'k8s-%', 'mergify%', 'qodo-%', 'snyk%', 'strimzi%', 'svc%', 'travis%bot', 'prom%bot', 'promptless%', '%-bot', '%-robot', '%bot-%', '%[%bot]%', '%ci%bot', '%cla%bot%', '%autobot', '%buildbot%', '%copybara%', '%renovate%', '%envoy-filter-example%', '%automat%', '%agent', '%-ci', '%-gerrit', '%-infra', '%-jenkins', '%-release', '%-service%', '%-team%', '%-testing', '% bot', '% ci', '% team', '% releaser', '%machine account%']))
  ) c
) sub
;
