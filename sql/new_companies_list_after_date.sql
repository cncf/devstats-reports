with existing_companies as (
  select
    af.{{company_name}} as name
  from
    gha_events e,
    gha_actors_affiliations af
  where
    e.actor_id = af.actor_id
    and af.dt_from <= e.created_at
    and af.dt_to > e.created_at
    and e.created_at < '{{dtjoin}}'
    and (lower(e.dup_actor_login) {{exclude_bots}})
    and e.type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
    and af.{{company_name}} is not null
    and trim(af.{{company_name}}) != ''
  union select
    af.{{company_name}} as name
  from
    gha_commits c,
    gha_actors_affiliations af
  where
    c.author_id = af.actor_id
    and af.dt_from <= c.dup_created_at
    and af.dt_to > c.dup_created_at
    and c.dup_created_at < '{{dtjoin}}'
    and (lower(c.dup_author_login) {{exclude_bots}})
    and af.{{company_name}} is not null
    and trim(af.{{company_name}}) != ''
  union select
    af.{{company_name}} as name
  from
    gha_commits c,
    gha_actors_affiliations af
  where
    c.committer_id = af.actor_id
    and af.dt_from <= c.dup_created_at
    and af.dt_to > c.dup_created_at
    and c.dup_created_at < '{{dtjoin}}'
    and (lower(c.dup_committer_login) {{exclude_bots}})
    and af.{{company_name}} is not null
    and trim(af.{{company_name}}) != ''
), new_companies as (
  select
    af.{{company_name}} as name,
    e.id
  from
    gha_events e,
    gha_actors_affiliations af
  left join
    existing_companies ec
  on
    af.{{company_name}} = ec.name
  where
    ec.name is null
    and e.actor_id = af.actor_id
    and af.dt_from <= e.created_at
    and af.dt_to > e.created_at
    and e.created_at >= '{{dtjoin}}'
    and (lower(e.dup_actor_login) {{exclude_bots}})
    and e.type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
    and af.{{company_name}} is not null
    and trim(af.{{company_name}}) != ''
  union select
    af.{{company_name}} as name,
    c.event_id
  from
    gha_commits c,
    gha_actors_affiliations af
  left join
    existing_companies ec
  on
    af.{{company_name}} = ec.name
  where
    ec.name is null
    and c.author_id = af.actor_id
    and af.dt_from <= c.dup_created_at
    and af.dt_to > c.dup_created_at
    and c.dup_created_at >= '{{dtjoin}}'
    and (lower(c.dup_author_login) {{exclude_bots}})
    and af.{{company_name}} is not null
    and trim(af.{{company_name}}) != ''
  union select
    af.{{company_name}} as name,
    c.event_id
  from
    gha_commits c,
    gha_actors_affiliations af
  left join
    existing_companies ec
  on
    af.{{company_name}} = ec.name
  where
    ec.name is null
    and c.committer_id = af.actor_id
    and af.dt_from <= c.dup_created_at
    and af.dt_to > c.dup_created_at
    and c.dup_created_at >= '{{dtjoin}}'
    and (lower(c.dup_committer_login) {{exclude_bots}})
    and af.{{company_name}} is not null
    and trim(af.{{company_name}}) != ''
)
select
  name,
  count(distinct id) as contributions
from
  new_companies
group by
  name
order by
  contributions desc
;
