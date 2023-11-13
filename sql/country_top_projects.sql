with data as (
  select
    c.event_id as id,
    r.repo_group,
    c.dup_created_at as created_at,
    c.author_id as actor_id,
    c.dup_author_login as dup_actor_login
  from
    gha_commits c,
    gha_repo_groups r
  where
    c.author_id is not null
    and c.dup_repo_id = r.id
    and c.dup_repo_name = r.name
  union select
    c.event_id as id,
    r.repo_group,
    c.dup_created_at as created_at,
    c.committer_id as actor_id,
    c.dup_committer_login as dup_actor_login
  from
    gha_commits c,
    gha_repo_groups r
  where
    c.committer_id is not null
    and c.dup_repo_id = r.id
    and c.dup_repo_name = r.name
  union select
    e.id,
    r.repo_group,
    e.created_at,
    e.actor_id,
    e.dup_actor_login
  from
    gha_events e,
    gha_repo_groups r
  where
    e.type in ('IssuesEvent', 'PullRequestEvent', 'PushEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent')
    and e.repo_id = r.id
    and e.dup_repo_name = r.name
)
select
  repo_group as project,
  count(distinct id) as contributions
from
  data
where
  actor_id in (select id from gha_actors where country_id = '{{country_code}}')
  and lower(dup_actor_login) {{exclude_bots}}
  and created_at >= now() - '{{time_range}}'::interval
group by
  project
order by
  contributions desc
;
