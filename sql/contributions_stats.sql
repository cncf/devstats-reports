select
  v1.title || ' - ' || v2.title as range,
  e.dup_actor_login as author,
  count(e.id) as contributions
from
  gha_events e,
  sannotations v1,
  sannotations v2
where
  v1.description like 'Kubernetes official release v1.1%'
  and v2.description like 'Kubernetes official release v1.1%'
  and substring(v2.title from 4 for 2)::integer = substring(v1.title from 4 for 2)::integer + 1
  and e.created_at >= v1.time
  and e.created_at < v2.time
  and e.type in (
    'PushEvent', 'PullRequestEvent', 'IssuesEvent',
    'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
  )
  and (lower(e.dup_actor_login) {{exclude_bots}})
group by
  e.dup_actor_login,
  v1.title,
  v2.title
union select
  v.title || ' - now' as range,
  e.dup_actor_login as author,
  count(e.id) as contributions
from
  gha_events e, (
  select title, time
  from
    sannotations
  where
    description like 'Kubernetes official release v1.1%'
  order by
    time desc
  limit 1
  ) v
where
  e.created_at >= v.time
  and e.type in (
    'PushEvent', 'PullRequestEvent', 'IssuesEvent',
    'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
  )
  and (lower(e.dup_actor_login) {{exclude_bots}})
group by
  v.title,
  e.dup_actor_login
order by
  range asc,
  contributions desc,
  author asc
;
