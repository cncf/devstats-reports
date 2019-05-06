select
  count(distinct dup_{{actor}}_login) as committers
from
  gha_commits
where
  dup_created_at >= '{{dtfrom}}'
  and dup_created_at < '{{dtto}}'
  and dup_{{actor}}_login != ''
  and (lower(dup_{{actor}}_login) {{exclude_bots}})
;
