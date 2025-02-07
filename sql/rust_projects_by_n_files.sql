select
  i.project,
  i.rust_files
from (
  select
    repo_group as project,
    count(distinct path) as rust_files
  from
    gha_events_commits_files
  where
    lower(ext) = 'rs'
    and dt >= '{{dtfrom}}'
    and dt < '{{dtto}}'
  group by
    repo_group
  union select
    'All' as project,
    count(distinct path) as rust_files
  from
    gha_events_commits_files
  where
    lower(ext) = 'rs'
    and dt >= '{{dtfrom}}'
    and dt < '{{dtto}}'
  ) i
where
  i.rust_files > 0
  and i.project is not null
  and i.project != ''
order by
  i.rust_files desc
;
