select
  count(distinct i.id) as prs
from
  gha_issues i,
  gha_actors_affiliations af
where
  i.user_id = af.actor_id
  and af.dt_from <= i.created_at
  and af.dt_to > i.created_at
  and af.{{company_name}} = '{{company}}'
  and i.is_pull_request = true
  and i.created_at >= '{{dtfrom}}'
  and i.created_at < '{{dtto}}'
;
