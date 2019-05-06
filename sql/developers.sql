select
  dup_{{actor}}_login as {{actor}},
  count(distinct sha) as commits
from
  gha_commits
where
  dup_created_at >= '{{dtfrom}}'
  and dup_created_at < '{{dtto}}'
  and dup_{{actor}}_login != ''
  and (lower(dup_{{actor}}_login) {{exclude_bots}})
group by
  dup_{{actor}}_login
order by
  commits desc,
  {{actor}} asc
;
