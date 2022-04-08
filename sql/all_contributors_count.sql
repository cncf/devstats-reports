with contributors as (
  select dup_committer_login as actor
  from
    gha_commits
  where
    dup_created_at >= '{{dtfrom}}'
    and dup_created_at < '{{dtto}}'
    and committer_id is not null
    and (lower(dup_committer_login) {{exclude_bots}})
  union select dup_author_login as actor
  from
    gha_commits
  where
    dup_created_at >= '{{dtfrom}}'
    and dup_created_at < '{{dtto}}'
    and author_id is not null
    and (lower(dup_author_login) {{exclude_bots}})
  union select dup_actor_login as actor
  from
    gha_events
  where
    created_at >= '{{dtfrom}}'
    and created_at < '{{dtto}}'
    and type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
    and (lower(dup_actor_login) {{exclude_bots}})
)
select
  count(distinct actor) as cnt
from
  contributors
;
