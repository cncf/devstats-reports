with before as (
  select
    count(id) as contributions
  from
    gha_events
  where
    created_at < '{{dtto}}'
    and (lower(dup_actor_login) {{exclude_bots}})
    and type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
), after as (
  select
    count(id) as contributions
  from
    gha_events
  where
    created_at >= '{{dtto}}'
    and (lower(dup_actor_login) {{exclude_bots}})
    and type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
)
select
  b.contributions as before,
  a.contributions as after,
  a.contributions - b.contributions as delta,
  case b.contributions = 0
    when true then 100.0
    else 100.0 * (a.contributions - b.contributions)::float / b.contributions::float
  end as percent_change
from
  before b,
  after a
;
