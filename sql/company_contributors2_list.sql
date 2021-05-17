with events as (
  select
    e.dup_actor_login as actor,
    e.id as event_id
  from
    gha_events e,
    gha_actors_affiliations af
  where
    e.actor_id = af.actor_id
    and af.dt_from <= e.created_at
    and af.dt_to > e.created_at
    and af.{{company_name}} = '{{company}}'
    and e.created_at >= '{{dtfrom}}'
    and e.created_at < '{{dtto}}'
    and (lower(e.dup_actor_login) {{exclude_bots}})
    and e.type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
  union select
    c.dup_author_login as actor,
    c.event_id
  from
    gha_commits c,
    gha_actors_affiliations af
  where
    c.author_id = af.actor_id
    and af.dt_from <= c.dup_created_at
    and af.dt_to > c.dup_created_at
    and af.{{company_name}} = '{{company}}'
    and c.author_id is not null
    and c.dup_author_login is not null
    and c.dup_created_at >= '{{dtfrom}}'
    and c.dup_created_at < '{{dtto}}'
    and (lower(c.dup_author_login) {{exclude_bots}})
  union select
    c.dup_committer_login as actor,
    c.event_id
  from
    gha_commits c,
    gha_actors_affiliations af
  where
    c.committer_id = af.actor_id
    and af.dt_from <= c.dup_created_at
    and af.dt_to > c.dup_created_at
    and af.{{company_name}} = '{{company}}'
    and c.committer_id is not null
    and c.dup_committer_login is not null
    and c.dup_created_at >= '{{dtfrom}}'
    and c.dup_created_at < '{{dtto}}'
    and (lower(c.dup_committer_login) {{exclude_bots}})
)
select
  sub.contributor,
  sub.contributions
from (
  select actor as contributor,
    count(distinct event_id) as contributions
  from
    events e
  group by
    actor
) sub
order by
  sub.{{order}},
  sub.contributions desc,
  sub.contributor asc
;
