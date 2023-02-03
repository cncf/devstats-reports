-- {{type}}: event_id - contributions, login - contributors
select
  -- round(sqrt(count(distinct sub.{{type}})::numeric), 0) as "value",
  count(distinct sub.{{type}}) as "value",
  coalesce(sub.country_id, '') as "name"
from (
  select
    a.login,
    e.id as event_id,
    coalesce(a.country_id, '') as country_id
  from
    gha_actors a,
    gha_events e,
    gha_repos r
  where
    e.repo_id = r.id
    and e.dup_repo_name = r.name
    and (r.repo_group in ('{{repo_group}}') or '{{repo_group}}' = '')
    and e.dup_actor_login = a.login
    and e.type in ('IssuesEvent', 'PullRequestEvent', 'PushEvent', 'PullRequestReviewCommentEvent', 'IssueCommentEvent', 'CommitCommentEvent')
    and e.created_at between '{{dtfrom}}' and '{{dtto}}'
    and (lower(a.login) {{exclude_bots}})
  union select
    a.login,
    c.event_id,
    coalesce(a.country_id, '') as country_id
  from
    gha_actors a,
    gha_commits c,
    gha_repos r
  where
    c.dup_repo_id = r.id
    and c.dup_repo_name = r.name
    and (r.repo_group in ('{{repo_group}}') or '{{repo_group}}' = '')
    and c.dup_author_login = a.login
    and c.dup_created_at between '{{dtfrom}}' and '{{dtto}}'
    and (lower(a.login) {{exclude_bots}})
  union select
    a.login,
    c.event_id,
    coalesce(a.country_id, '') as country_id
  from
    gha_actors a,
    gha_commits c,
    gha_repos r
  where
    c.dup_repo_id = r.id
    and c.dup_repo_name = r.name
    and (r.repo_group in ('{{repo_group}}') or '{{repo_group}}' = '')
    and c.dup_committer_login = a.login
    and c.dup_created_at between '{{dtfrom}}' and '{{dtto}}'
    and (lower(a.login) {{exclude_bots}})
) sub
where
  sub.country_id != ''
group by
  sub.country_id
;
