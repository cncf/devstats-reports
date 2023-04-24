with commits_data as (
  select dup_repo_name,
    sha,
    dup_created_at,
    dup_actor_id as actor_id
  from
    gha_commits
  where
    dup_created_at >= '{{dtfrom}}'
    and dup_created_at < '{{dtto}}'
    and (lower(dup_actor_login) {{exclude_bots}})
  union select dup_repo_name,
    sha,
    dup_created_at,
    author_id as actor_id
  from
    gha_commits
  where
    author_id is not null
    and dup_created_at >= '{{dtfrom}}'
    and dup_created_at < '{{dtto}}'
    and (lower(dup_author_login) {{exclude_bots}})
  union select dup_repo_name,
    sha,
    dup_created_at,
    committer_id as actor_id
  from
    gha_commits
  where
    committer_id is not null
    and dup_created_at >= '{{dtfrom}}'
    and dup_created_at < '{{dtto}}'
    and (lower(dup_committer_login) {{exclude_bots}})
)
select
  dup_repo_name as repo,
  count(distinct sha) as commits
from
  commits_data
group by
  dup_repo_name
order by
  commits desc
;
