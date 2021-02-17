with commits as (
  select c.committer_id as actor_id,
    c.dup_committer_login as actor,
    r.repo_group as repo,
    c.dup_created_at as created_at,
    c.sha
  from
    gha_commits c,
    gha_repos r
  where
    c.dup_repo_id = r.id
    and c.dup_repo_name = r.name
    and r.repo_group is not null
    and c.committer_id is not null
    and (lower(c.dup_committer_login) {{exclude_bots}})
  union select c.author_id as actor_id,
    c.dup_author_login as actor,
    r.repo_group as repo,
    c.dup_created_at as created_at,
    c.sha
  from
    gha_commits c,
    gha_repos r
  where
    c.dup_repo_id = r.id
    and c.dup_repo_name = r.name
    and r.repo_group is not null
    and c.author_id is not null
    and (lower(c.dup_author_login) {{exclude_bots}})
  union select c.dup_actor_id as actor_id,
    c.dup_actor_login as actor,
    r.repo_group as repo,
    c.dup_created_at as created_at,
    c.sha
  from
    gha_commits c,
    gha_repos r
  where
    c.dup_repo_id = r.id
    and c.dup_repo_name = r.name
    and r.repo_group is not null
    and c.dup_actor_id is not null
    and (lower(c.dup_actor_login) {{exclude_bots}})
), committers as (
  select c.actor,
    c.repo,
    coalesce(aa.{{company_name}}, '(Unknown)') as company,
    count(distinct c.sha) as commits
  from
    commits c
  left join
    gha_actors_affiliations aa
  on
    c.actor_id = aa.actor_id
    and c.created_at >= aa.dt_from
    and c.created_at < aa.dt_to
  group by
    actor,
    repo,
    company
  order by
    commits desc
), all_commits as (
  select sum(commits) as cnt
  from
    committers
), data as (
  select c.repo,
    row_number() over cumulative_commits as rank_number,
    c.actor,
    c.company,
    c.commits,
    round((c.commits * 100.0) / a.cnt, 5) as percent,
    a.cnt as all_commits
  from
    committers c,
    all_commits a
  window
    cumulative_commits as (
      partition by c.repo
      order by c.commits desc, c.actor asc
      range between unbounded preceding
      and current row
    )
)
select
  *
from
  data
where
  rank_number <= {{n}}
;
