with data as (
  select
    dup_actor_login as id,
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
    count(distinct id) as al,
    count(distinct id) filter (where dt < '{{dtto}}') as before,
    count(distinct id) filter (where dt >= '{{dtto}}') as after,
    count(distinct id) filter (where dt >= '{{dtto}}' and id not in (select id from data where dt < '{{dtto}}')) as new
  from
    data
)
select
  al,
  before,
  after,
  new
from
  aggs
;
