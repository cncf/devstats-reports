with data as (
  select
    event_id
  from
    gha_commits
  where
    dup_actor_login = '{{github_id}}'
  union select
    event_id
  from
    gha_commits
  where
    dup_author_login = '{{github_id}}'
  union select
    event_id
  from
    gha_commits
  where
    dup_committer_login = '{{github_id}}'
  union select
    event_id
  from
    gha_commits_roles
  where
    actor_login = '{{github_id}}'
  union select
    id as event_id
  from
    gha_events
  where
    dup_actor_login = '{{github_id}}'
    and type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
)
select
  count(distinct event_id) as contributions
from
  data
