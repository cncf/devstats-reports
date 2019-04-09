select
  max(watchers) as watchers
from
  gha_forkees
where
  dup_created_at >= '{{dtfrom}}'
  and dup_created_at < '{{dtto}}'
