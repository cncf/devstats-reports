-- k exec -in devstats-prod devstats-postgres-2 -- psql etcd < top_rolls.sql > top_rolls.csv
copy (
with contributors as (
  select
    committer_id as actor_id,
    dup_created_at as created_at,
    event_id
  from
    gha_commits
  where
    committer_id is not null
    and lower(dup_committer_login) not ilike all(
      select
        pattern
      from
        gha_bot_logins
    )
  union
  select
    author_id as actor_id,
    dup_created_at as created_at,
    event_id
  from
    gha_commits
  where
    author_id is not null
    and lower(dup_author_login) not ilike all(
      select
        pattern
      from
        gha_bot_logins
    )
  union
  select
    actor_id,
    created_at,
    id as event_id
  from
    gha_events
  where
    type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
    and lower(dup_actor_login) not ilike all(
      select
        pattern
      from
        gha_bot_logins
    )
), top_contributors as (
  select
    c.actor_id,
    count(distinct c.event_id) as contributions
  from
    contributors c
  group by
    c.actor_id
  having
    count(distinct c.event_id) >= 100
  order by
    contributions desc
)
select distinct
  a.login as github_handle,
  a.name,
  tc.contributions,
  count(distinct c.event_id) as company_contributions,
  aa.company_name as company,
  aa.original_company_name as company_no_acquisitions,
  date(aa.dt_from) as affiliated_from,
  date(aa.dt_to) as affiliated_to
from
  top_contributors tc
inner join
  contributors c
on
  c.actor_id = tc.actor_id
inner join
  gha_actors a
on
  tc.actor_id = a.id
inner join
  gha_actors_affiliations aa
on
  c.actor_id = aa.actor_id
  and c.created_at >= aa.dt_from
  and c.created_at < aa.dt_to
where
  aa.company_name not in ('(Robots)')
group by
  a.login,
  a.name,
  tc.contributions,
  aa.company_name,
  aa.original_company_name,
  date(aa.dt_from),
  date(aa.dt_to)
order by
  tc.contributions desc,
  github_handle,
  affiliated_from,
  affiliated_to
) to stdout with csv header
