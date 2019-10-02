select
  count(distinct sha) as commits
from
  gha_commits
where
  dup_created_at >= '{{dtfrom}}'
  and dup_created_at < '{{dtto}}'
  and (lower(dup_{{actor}}_login) {{exclude_bots}})
  and dup_repo_name != 'lyft/envoy'
;
