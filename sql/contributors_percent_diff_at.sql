with before as (
  select
    count(distinct dup_actor_login) as contributors
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
    count(distinct dup_actor_login) as contributors
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
  b.contributors as before,
  a.contributors as after,
  a.contributors - b.contributors as delta,
  case b.contributors = 0
    when true then 100.0
    else 100.0 * (a.contributors - b.contributors)::float / b.contributors::float
  end as percent_change
from
  before b,
  after a
;
