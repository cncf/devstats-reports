select
  count(distinct sub.country_id) as num_countries
from (
  select
    a.country_id
  from
    gha_events e,
    gha_actors a
  where
    e.actor_id = a.id
    and e.type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
  union select
    a.country_id
  from
    gha_actors a,
    gha_commits c
  where
    c.author_id = a.id
    or c.committer_id = a.id
) sub
;
