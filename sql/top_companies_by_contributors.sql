select
  aa.company_name as company,
  count(distinct e.dup_actor_login) as contributors,
  count(distinct e.id) as contributions
from
  gha_events e
inner join
  gha_actors_affiliations aa
on
  e.actor_id = aa.actor_id
  and e.created_at >= aa.dt_from
  and e.created_at < aa.dt_to
  and aa.company_name not in (
    '(Robots)', 'Independent', 'CNCF'
  )
where
  e.type in (
    'IssuesEvent', 'PullRequestEvent', 'PushEvent', 'CommitCommentEvent',
    'IssueCommentEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent'
  )
  and lower(e.dup_actor_login) not ilike any(
    select
      pattern
    from
      gha_bot_logins
  )
group by
  aa.company_name
order by
  contributors desc
limit
  255
;
