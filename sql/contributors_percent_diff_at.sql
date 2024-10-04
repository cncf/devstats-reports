with data as (
  select
    dup_actor_login as id,
    min(created_at) as midt,
    max(created_at) as madt
  from
    gha_events
  where
    (lower(dup_actor_login) {{exclude_bots}})
    and type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
  group by
    id
), aggs as (
  select
    count(distinct id) as al,
    count(distinct id) filter (where midt < '{{dtto}}') as before,
    count(distinct id) filter (where madt >= '{{dtto}}') as after
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
