with commits_data as (
  select
    c.dup_actor_login as actor,
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
    c.dup_author_login as actor,
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
    c.dup_committer_login as actor,
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
), commits as (
  select
    count(distinct sha) as commits
  from
    commits_data
), prs as (
  select
    count(distinct pr.id) as prs
  from
    gha_pull_requests pr,
    gha_actors_affiliations af
  where
    pr.user_id = af.actor_id
    and af.dt_from <= pr.created_at
    and af.dt_to > pr.created_at
    and af.{{company_name}} = '{{company}}'
    and pr.created_at >= '{{dtfrom}}'
    and pr.created_at < '{{dtto}}'
), issues as (
  select
    count(distinct id) as issues
  from
    gha_issues i,
    gha_actors_affiliations af
  where
    i.user_id = af.actor_id
    and af.dt_from <= i.created_at
    and af.dt_to > i.created_at
    and af.{{company_name}} = '{{company}}'
    and i.is_pull_request = false
    and i.created_at >= '{{dtfrom}}'
    and i.created_at < '{{dtto}}'
), authors as (
  select
    count(distinct actor) as authors
  from
    commits_data
)
select
  c.commits,
  p.prs,
  i.issues,
  a.authors
from
  commits c,
  prs p,
  issues i,
  authors a
;
