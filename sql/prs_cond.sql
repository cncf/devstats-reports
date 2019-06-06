select
  count(distinct id) as prs
from
  gha_pull_requests
where
  created_at >= '{{dtfrom}}'
  and created_at < '{{dtto}}'
  and {{cond}}
;
