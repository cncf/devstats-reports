select
  aa.{{company_name}} as company,
  r.repo_group as project,
  count(distinct e.id) as contributions,
  count(distinct e.actor_id) as contributors
from
  gha_events e,
  gha_repos r,
  gha_actors_affiliations aa
where
  e.repo_id = r.id
  and e.actor_id = aa.actor_id
  and e.created_at >= aa.dt_from
  and e.created_at < aa.dt_to
  and e.type in (
    'PushEvent', 'PullRequestEvent', 'IssuesEvent',
    'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
  )
  and (lower(dup_actor_login) {{exclude_bots}})
group by
  aa.{{company_name}},
  r.repo_group
order by
  aa.{{company_name}},
  r.repo_group
;
