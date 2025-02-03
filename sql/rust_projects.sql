select
  i.project,
  100.0 * (i.rust_file_activities::float / i.file_activities::float) as percent_rust_activity
from (
  select
    repo_group as project,
    count(distinct sha) as file_activities,
    count(distinct sha) filter (where lower(ext) = 'rs') as rust_file_activities
  from
    gha_events_commits_files
  where
    dt >= '{{dtfrom}}'
    and dt < '{{dtto}}'
  group by
    repo_group
  union select
    'All' as project,
    count(distinct sha) as file_activities,
    count(distinct sha) filter (where lower(ext) = 'rs') as rust_file_activities
  from
    gha_events_commits_files
  where
    dt >= '{{dtfrom}}'
    and dt < '{{dtto}}'
  ) i
where
  i.rust_file_activities > 0
  and i.file_activities > 0
order by
  (i.rust_file_activities::float / i.file_activities::float) desc
;
