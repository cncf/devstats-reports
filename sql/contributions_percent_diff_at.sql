with data as (
  select
    id,
    created_at as dt
  from
    gha_events
  where
    (lower(dup_actor_login) {{exclude_bots}})
    and type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
), aggs as (
  select
    count(id) as al,
    count(id) filter (where dt < '{{dtto}}') as before,
    count(id) filter (where dt >= '{{dtto}}') as after
  from
    data
)
select
  al,
  before,
  after
from
  aggs
;
