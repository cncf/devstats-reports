select
  count(distinct e.actor_id) as country_contributors
from
  gha_events e,
  gha_actors a,
  gha_countries c
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
  and c.name = '{{country}}'
union select 0 as country_contributors
order by
  country_contributors desc
limit 1
;

