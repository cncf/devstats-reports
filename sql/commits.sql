select
  count(distinct dup_committer_login) as committers
from
  gha_commits
where
  dup_created_at >= '{{dtfrom}}'
  and dup_created_at < '{{dtto}}'
  and dup_committer_login != ''
  and (lower(dup_committer_login) {{exclude_bots}})
;
