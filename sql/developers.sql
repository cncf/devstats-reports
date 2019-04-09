select
  dup_committer_login as committer,
  count(distinct sha) as commits
from
  gha_commits
where
  dup_created_at >= '{{dtfrom}}'
  and dup_created_at < '{{dtto}}'
  and dup_committer_login != ''
  and (lower(dup_committer_login) {{exclude_bots}})
group by
  dup_committer_login
order by
  commits desc,
  committer asc
;
