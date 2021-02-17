select
  sub.company_contributors as contributors,
  (sub.company_contributors * 100.0) / sub.{{type}}_distinct_contributors as percent_contributors,
  (sub.known_contributors * 100.0) / sub.all_contributors as data_quality
from (
  select count(distinct e.dup_actor_login) filter (where af.{{company_name}} = '{{company}}') as company_contributors,
    count(distinct e.dup_actor_login) filter (where af.{{company_name}} is not null) as known_distinct_contributors,
    count(distinct e.dup_actor_login) as all_distinct_contributors,
    count(e.dup_actor_login) filter (where af.{{company_name}} is not null) as known_contributors,
    count(e.dup_actor_login) as all_contributors
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
