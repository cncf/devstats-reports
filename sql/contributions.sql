select
  count(id) as contributions
from
  gha_events
where
  created_at >= '{{dtfrom}}'
  and created_at < '{{dtto}}'
  and (lower(dup_actor_login) {{exclude_bots}})
  and type in (
    'PushEvent', 'PullRequestEvent', 'IssuesEvent',
    'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
  )
;
