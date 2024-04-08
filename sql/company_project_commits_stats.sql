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
    and af.company_name not in ('Independent', '(Robots)', 'CNCF')
    and rg.repo_group not in ('CNCF')
    and (lower(c.dup_actor_login) {{exclude_bots}})
    and c.dup_created_at >= '{{dtfrom}}'
    and c.dup_created_at < '{{dtto}}'
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
    and af.company_name not in ('Independent', '(Robots)', 'CNCF')
    and rg.repo_group not in ('CNCF')
    and (lower(c.dup_author_login) {{exclude_bots}})
    and c.dup_created_at >= '{{dtfrom}}'
    and c.dup_created_at < '{{dtto}}'
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
    and af.company_name not in ('Independent', '(Robots)', 'CNCF')
    and rg.repo_group not in ('CNCF')
    and (lower(c.dup_committer_login) {{exclude_bots}})
    and c.dup_created_at >= '{{dtfrom}}'
    and c.dup_created_at < '{{dtto}}'
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
    {{limit_companies}}
), project_commits as (
  select
    project,
    count(distinct sha) as commits
  from
    commits_data
  group by
    project
  order by
    commits desc
  limit
    {{limit_projects}}
), by_company as (
  select
    row_number() over (order by i.all_company_commits desc, i.percent_of_all_company_commits desc, i.project asc) as row_num,
    i.*
  from (
    select
      'by company' as metric,
      cpc.company,
      cpc.project,
      cpc.commits,
      cc.commits as all_company_commits,
      pc.commits as all_project_commits,
      (cpc.commits * 100.0) / cc.commits as percent_of_all_company_commits,
      (cpc.commits * 100.0) / pc.commits as percent_of_all_project_commits
    from
      company_project_commits cpc,
      company_commits cc,
      project_commits pc
    where
      cpc.company = cc.company
      and cpc.project = pc.project
  ) i
), by_project as (
  select
    row_number() over (order by i.all_project_commits desc, i.percent_of_all_project_commits desc, i.project asc) as row_num,
    i.*
  from (
      select
      'by project' as metric,
      cpc.company,
      cpc.project,
      cpc.commits,
      cc.commits as all_company_commits,
      pc.commits as all_project_commits,
      (cpc.commits * 100.0) / cc.commits as percent_of_all_company_commits,
      (cpc.commits * 100.0) / pc.commits as percent_of_all_project_commits
    from
      company_project_commits cpc,
      company_commits cc,
      project_commits pc
    where
      cpc.company = cc.company
      and cpc.project = pc.project
    ) i
)
select
  row_num,
  metric,
  company,
  project,
  commits,
  all_company_commits,
  all_project_commits,
  percent_of_all_company_commits,
  percent_of_all_project_commits
from
  by_company
union select
  row_num,
  metric,
  company,
  project,
  commits,
  all_company_commits,
  all_project_commits,
  percent_of_all_company_commits,
  percent_of_all_project_commits
from
  by_project
order by
  metric,
  row_num
;
