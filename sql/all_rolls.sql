copy (
select distinct
  a.login as github_handle,
  a.name,
  aa.company_name as company,
  aa.original_company_name as company_no_acquisitions,
  date(aa.dt_from) as affiliated_from,
  date(aa.dt_to) as affiliated_to
from
  gha_actors a
inner join
  gha_actors_affiliations aa
on
  a.id = aa.actor_id
order by
  github_handle,
  affiliated_from,
  affiliated_to
) to stdout with csv header
