select
  count(distinct r.repo_group) as projects
from
  gha_events e,
  gha_repos r,
  gha_actors_affiliations af
where
  e.actor_id = af.actor_id
  and af.dt_from <= e.created_at
  and af.dt_to > e.created_at
  and af.{{company_name}} = '{{company}}'
  and e.created_at >= '{{dtfrom}}'
  and e.created_at < '{{dtto}}'
  and e.repo_id = r.id
  and e.dup_repo_name = r.name
  and r.repo_group is not null
  and (lower(e.dup_actor_login) {{exclude_bots}})
  and e.type in (
    'PushEvent', 'PullRequestEvent', 'IssuesEvent',
    'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
  )
;
