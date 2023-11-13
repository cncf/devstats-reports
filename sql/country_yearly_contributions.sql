with data as (
  select
    event_id as id,
    dup_created_at as created_at,
    author_id as actor_id,
    dup_author_login as dup_actor_login
  from
    gha_commits
  where
    author_id is not null
  union select
    event_id as id,
    dup_created_at as created_at,
    committer_id as actor_id,
    dup_committer_login as dup_actor_login
  from
    gha_commits
  where
    committer_id is not null
  union select
    id,
    created_at,
    actor_id,
    dup_actor_login
  from
    gha_events
  where
    type in ('IssuesEvent', 'PullRequestEvent', 'PushEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent')
)
select
  extract(year from created_at) as year,
  count(distinct id) as contributions
from
  data
where
  actor_id in (select id from gha_actors where country_id = '{{country_code}}')
  and lower(dup_actor_login) {{exclude_bots}}
group by
  year
order by
  year desc
;
