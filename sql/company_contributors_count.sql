with events as (
  select
    e.dup_actor_login as actor,
    af.{{company_name}}
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
  union select
    c.dup_author_login as actor,
    af.{{company_name}}
  from
    gha_commits c
  left join
    gha_actors_affiliations af
  on
    c.author_id = af.actor_id
    and af.dt_from <= c.dup_created_at
    and af.dt_to > c.dup_created_at
  where
    c.author_id is not null
    and c.dup_author_login is not null
    and c.dup_created_at >= '{{dtfrom}}'
    and c.dup_created_at < '{{dtto}}'
    and (lower(c.dup_author_login) {{exclude_bots}})
  union select
    c.dup_committer_login as actor,
    af.{{company_name}}
  from
    gha_commits c
  left join
    gha_actors_affiliations af
  on
    c.committer_id = af.actor_id
    and af.dt_from <= c.dup_created_at
    and af.dt_to > c.dup_created_at
  where
    c.committer_id is not null
    and c.dup_committer_login is not null
    and c.dup_created_at >= '{{dtfrom}}'
    and c.dup_created_at < '{{dtto}}'
    and (lower(c.dup_committer_login) {{exclude_bots}})
)
select
  sub.company_contributors as contributors
  -- (sub.company_contributors * 100.0) / sub.{{type}}_distinct_contributors as percent_contributors,
  -- (sub.known_contributors * 100.0) / sub.all_contributors as data_quality
from (
  select count(distinct actor) filter (where {{company_name}} = '{{company}}') as company_contributors,
    count(distinct actor) filter (where {{company_name}} is not null) as known_distinct_contributors,
    count(distinct actor) as all_distinct_contributors,
    count(actor) filter (where {{company_name}} is not null) as known_contributors,
    count(actor) as all_contributors
  from
    events
) sub
;
