select
  count(distinct c.sha) as commits,
  count(distinct c.{{actor}}_id) as authors,
  count(distinct affs.{{company_name}}) as companies
from
  gha_events_commits_files ecf,
  gha_commits c
left join
  gha_actors_affiliations affs
on
  c.{{actor}}_id = affs.actor_id
  and affs.dt_from <= c.dup_created_at
  and affs.dt_to > c.dup_created_at
  and affs.{{company_name}} != ''
where
  c.sha = ecf.sha
  and lower(ecf.path) like '%.rst'
  and c.dup_created_at >= '{{dtfrom}}'
  and c.dup_created_at < '{{dtto}}'
  and (lower(c.dup_{{actor}}_login) {{exclude_bots}})
