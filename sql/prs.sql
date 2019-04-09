select
  count(distinct id) as prs
from
  gha_issues
where
  is_pull_request = true
  and created_at >= '{{dtfrom}}'
  and created_at < '{{dtto}}'
;
