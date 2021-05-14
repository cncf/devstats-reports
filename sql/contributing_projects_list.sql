select
  string_agg(sub.project, ',') as projects
from (
  select r.repo_group as project,
    count(distinct e.id) as contributions
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
    and (lower(e.dup_actor_login) {{exclude_bots}})
    and e.type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
  group by
    r.repo_group
  order by
    contributions desc,
    project asc
  limit {{lim}}
) sub
;
