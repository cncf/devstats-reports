select
  count(distinct sha) as commits
from
  gha_commits
where
  dup_created_at >= '{{dtfrom}}'
  and dup_created_at < '{{dtto}}'
  and (lower({{actor}}) {{exclude_bots}})
  and (lower({{actor2}}) {{exclude_bots}})
;
