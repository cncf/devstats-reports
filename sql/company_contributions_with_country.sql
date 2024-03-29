select
  c.name as country,
  count(e.id) as country_contributions
from
  gha_events e,
  gha_actors a,
  gha_countries c,
  gha_actors_affiliations af
where
  e.actor_id = a.id
  and e.dup_actor_login = a.login
  and e.created_at >= '{{dtfrom}}'
  and e.created_at < '{{dtto}}'
  and (lower(e.dup_actor_login) {{exclude_bots}})
  and e.type in (
    'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
    'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
  )
  and a.country_id is not null
  and a.country_id != ''
  and a.country_id = c.code
  and e.actor_id = af.actor_id
  and af.dt_from <= e.created_at
  and af.dt_to > e.created_at
  and af.{{company_name}} = '{{company}}'
group by
  c.name
order by
  country_contributions desc
;
