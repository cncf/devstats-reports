with comms as (
  select
    c.sha
  from
    gha_commits c,
    gha_actors_affiliations af
  where
    c.dup_actor_id = af.actor_id
    and af.dt_from <= c.dup_created_at
    and af.dt_to > c.dup_created_at
    and af.{{company_name}} = '{{company}}'
    and c.dup_created_at >= '{{dtfrom}}'
    and c.dup_created_at < '{{dtto}}'
    and (lower(c.dup_actor_login) {{exclude_bots}})
  union select
    c.sha
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
    c.sha
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
  count(distinct sha) as commits
from
  comms
;
