-- this gives a project statistic - how many % a given company has in a given project
select
  -- sub.project_contributions as contributions
  (sub.project_contributions * 100.0) / case sub.{{type}}_contributions when 0 then 1 else sub.{{type}}_contributions end as percent_contributions
  -- (sub.known_contributions * 100.0) / case sub.all_contributions when 0 then 1 else sub.all_contributions end as data_quality
from (
  select count(e.id) filter (where r.repo_group = '{{project}}') as project_contributions,
    count(e.id) filter (where r.repo_group is not null) as known_contributions,
    count(e.id) as all_contributions
  from
    gha_repos r,
    gha_events e
  left join
    gha_actors_affiliations af
  on
    e.actor_id = af.actor_id
    and af.dt_from <= e.created_at
    and af.dt_to > e.created_at
  where
    e.created_at >= '{{dtfrom}}'
    and e.created_at < '{{dtto}}'
    and e.repo_id = r.id
    and e.dup_repo_name = r.name
    and af.{{company_name}} = '{{company}}'
    and (lower(e.dup_actor_login) {{exclude_bots}})
    and e.type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
) sub
;
