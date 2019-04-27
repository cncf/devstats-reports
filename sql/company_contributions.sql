select
  sub.company_contributions as contributions,
  (sub.company_contributions * 100.0) / sub.{{type}}_contributions as percent_contributions
from (
  select count(e.id) filter (where af.company_name = '{{company}}') as company_contributions,
    count(e.id) filter (where af.company_name is not null) as known_contributions,
    count(e.id) as all_contributions
  from
    gha_events e
  left join
    gha_actors_affiliations af
  on
    e.actor_id = af.actor_id
    and af.dt_from <= e.created_at
    and af.dt_to > e.created_at
  where
    e.created_at >= '{{dtfrom}}'
    and e.created_at < '{{dtto}}'
    and (lower(e.dup_actor_login) {{exclude_bots}})
    and e.type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
) sub
;
