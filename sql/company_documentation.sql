select
  count(distinct c.sha) as commits,
  count(distinct c.{{actor}}_id) as authors
from
  gha_events_commits_files ecf,
  gha_commits c,
  gha_actors_affiliations affs
where
  c.{{actor}}_id = affs.actor_id
  and affs.dt_from <= c.dup_created_at
  and affs.dt_to > c.dup_created_at
  and affs.{{company_name}} = '{{company}}'
  and c.sha = ecf.sha
  and (ecf.path like '%.md' or ecf.path like '%.MD')
  and c.dup_created_at >= '{{dtfrom}}'
  and c.dup_created_at < '{{dtto}}'
  and (lower(c.dup_{{actor}}_login) {{exclude_bots}})
