-- kubectl exec -in devstats-prod devstats-postgres-0 -- psql allprj < sql/company_project_commits_stats.sql
with commits_data as (
  select
    rg.repo_group as project,
    af.company_name as company,
    c.sha
  from
    gha_repo_groups rg,
    gha_commits c,
    gha_actors_affiliations af
  where
    rg.id = c.dup_repo_id
    and rg.name = c.dup_repo_name
    and c.dup_actor_id = af.actor_id
    and af.dt_from <= c.dup_created_at
    and af.dt_to > c.dup_created_at
    -- and (lower(c.dup_actor_login) {{exclude_bots}})
    -- and c.dup_created_at >= '{{from}}'
    -- and c.dup_created_at < '{{to}}'
  union select
    rg.repo_group as project,
    af.company_name as company,
    c.sha
  from
    gha_repo_groups rg,
    gha_commits c,
    gha_actors_affiliations af
  where
    rg.id = c.dup_repo_id
    and rg.name = c.dup_repo_name
    and c.author_id = af.actor_id
    and af.dt_from <= c.dup_created_at
    and af.dt_to > c.dup_created_at
    and c.author_id is not null
    and c.dup_author_login is not null
    -- and (lower(c.dup_author_login) {{exclude_bots}})
    -- and c.dup_created_at >= '{{from}}'
    -- and c.dup_created_at < '{{to}}'
  union select
    rg.repo_group as project,
    af.company_name as company,
    c.sha
  from
    gha_repo_groups rg,
    gha_commits c,
    gha_actors_affiliations af
  where
    rg.id = c.dup_repo_id
    and rg.name = c.dup_repo_name
    and c.committer_id = af.actor_id
    and af.dt_from <= c.dup_created_at
    and af.dt_to > c.dup_created_at
    and c.committer_id is not null
    and c.dup_committer_login is not null
    -- and (lower(c.dup_committer_login) {{exclude_bots}})
    -- and c.dup_created_at >= '{{from}}'
    -- and c.dup_created_at < '{{to}}'
), company_project_commits as (
  select
    company,
    project,
    count(distinct sha) as commits
  from
    commits_data
  group by
    company,
    project
), company_commits as (
  select
    company,
    count(distinct sha) as commits
  from
    commits_data
  group by
    company
  order by
    commits desc
  limit
    10
    -- {{limit}}
)
select
  cpc.company,
  cpc.project,
  cpc.commits,
  cc.commits as all_commits,
  (cpc.commits * 100.0) / cc.commits as percent_commits
from
  company_project_commits cpc,
  company_commits cc
where
  cpc.company = cc.company
order by
  all_commits desc,
  cpc.company,
  percent_commits desc
;
