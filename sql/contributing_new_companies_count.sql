select
  count(distinct af.{{company_name}}) as companies
from
  gha_events e,
  gha_actors_affiliations af
where
  e.actor_id = af.actor_id
  and af.dt_from <= e.created_at
  and af.dt_to > e.created_at
  and af.{{company_name}} != 'Independent'
  and af.{{company_name}} != ''
  and e.created_at >= '{{dtfrom}}'
  and e.created_at < '{{dtto}}'
  and (lower(e.dup_actor_login) {{exclude_bots}})
  and e.type in (
    'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
    'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
  )
  and e.actor_id not in (
    select
      i.actor_id
    from
      gha_events i
    where
      i.created_at < '{{dtfrom}}'
      and (lower(i.dup_actor_login) {{exclude_bots}})
      and i.type in (
        'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
        'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
      )
  )
;
