select
  dup_actor_login as issuer,
  count(id) as events
from
  gha_events
where
  created_at >= '{{dtfrom}}'
  and created_at < '{{dtto}}'
  and (lower(dup_actor_login) {{exclude_bots}})
  and type in (
    'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewCommentEvent'
  )
group by
  dup_actor_login
order by
  events desc,
  issuer asc
;
