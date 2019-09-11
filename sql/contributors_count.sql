select
  count(distinct e.dup_actor_login) as contributors
from
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
  and (lower(e.dup_actor_login) {{exclude_bots}})
  and e.type in (
    'PushEvent', 'PullRequestEvent', 'IssuesEvent',
    'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
  )
;
