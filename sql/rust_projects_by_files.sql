select
  i.project,
  100.0 * (i.rust_files::float / i.files::float) as percent_rust_files
from (
  select
    repo_group as project,
    count(distinct path) as files,
    count(distinct path) filter (where lower(ext) = 'rs') as rust_files
  from
    gha_events_commits_files
  where
    dt >= '{{dtfrom}}'
    and dt < '{{dtto}}'
  group by
    repo_group
  union select
    'All' as project,
    count(distinct path) as files,
    count(distinct path) filter (where lower(ext) = 'rs') as rust_files
  from
    gha_events_commits_files
  where
    dt >= '{{dtfrom}}'
    and dt < '{{dtto}}'
  ) i
where
  i.rust_files > 0
  and i.files > 0
order by
  (i.rust_files::float / i.files::float) desc
;
