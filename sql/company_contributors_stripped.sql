select
  sub.company_contributors as contributors
  -- (sub.company_contributors * 100.0) / case sub.{{type}}_contributors when 0 then 1 else sub.{{type}}_contributors end as percent_contributors,
  -- (sub.known_contributors * 100.0) / case sub.all_contributors when 0 then 1 else sub.all_contributors end as data_quality
from (
  select count(distinct e.actor_id) filter (where af.{{company_name}} = '{{company}}') as company_contributors,
    count(distinct e.actor_id) filter (where af.{{company_name}} is not null) as known_contributors,
    count(distinct e.actor_id) as all_contributors
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
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
) sub
;
