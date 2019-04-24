select
  count(distinct id) as issues
from
  gha_issues
where
  is_pull_request = false
  and created_at >= '{{dtfrom}}'
  and created_at < '{{dtto}}'
;
