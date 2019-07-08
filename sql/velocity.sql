with commits as (
  select
    count(distinct sha) as commits
  from
    gha_commits
  where
    dup_created_at >= '{{dtfrom}}'
    and dup_created_at < '{{dtto}}'
    and (lower(dup_{{actor}}_login) {{exclude_bots}})
), prs as (
  select
    count(distinct id) as prs
  from
    gha_pull_requests
  where
    created_at >= '{{dtfrom}}'
    and created_at < '{{dtto}}'
), issues as (
  select
    count(distinct id) as issues
  from
    gha_issues
  where
    is_pull_request = false
    and created_at >= '{{dtfrom}}'
    and created_at < '{{dtto}}'
), authors as (
  select
    count(distinct dup_{{actor}}_login) as authors
  from
    gha_commits
  where
    dup_created_at >= '{{dtfrom}}'
    and dup_created_at < '{{dtto}}'
    and dup_{{actor}}_login != ''
    and (lower(dup_{{actor}}_login) {{exclude_bots}})
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
