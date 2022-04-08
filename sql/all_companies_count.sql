select
  count(distinct sub.company_name) as num_companis
from (
  select
    af.company_name
  from
    gha_events e,
    gha_actors_affiliations af
  where
    e.actor_id = af.actor_id
    and af.dt_from <= e.created_at
    and af.dt_to > e.created_at
    and af.company_name not in ('Independent', 'Unknown', 'NotFound', '')
    and e.type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
  union select
    af.company_name
  from
    gha_actors_affiliations af,
    gha_commits c
  where
    (
      c.author_id = af.actor_id
      or c.committer_id = af.actor_id
    )
    and af.dt_from <= c.dup_created_at
    and af.dt_to > c.dup_created_at
    and af.company_name not in ('Independent', 'Unknown', 'NotFound', '')
) sub
;
