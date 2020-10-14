with contributions as (
  select id as event_id,
    actor_id as actor_id,
    dup_actor_login as login
  from
    gha_events
  where
    type in (
      'PullRequestReviewCommentEvent', 'PushEvent', 'PullRequestEvent',
      'IssuesEvent', 'IssueCommentEvent', 'CommitCommentEvent'
    )
    and (lower(dup_actor_login) {{exclude_bots}})
    and created_at >= {{from}}
    and created_at < {{to}}
  union select event_id,
    author_id as actor_id,
    dup_author_login as login
  from
    gha_commits
  where
    (lower(dup_author_login) {{exclude_bots}})
    and dup_created_at >= {{from}}
    and dup_created_at < {{to}}
  union select event_id,
    committer_id as actor_id,
    dup_committer_login as login
  from
    gha_commits
  where
    (lower(dup_committer_login) {{exclude_bots}})
    and dup_created_at >= {{from}}
    and dup_created_at < {{to}}
)
select
  sub.id,
  sub.contributions,
  sub.emails
from (
  select s.id,
    avg(s.contributions)::int as contributions,
    coalesce(string_agg(s.email, ', '), '-') as emails
  from (
    select distinct a.login as id,
      count(distinct c.event_id) as contributions,
      ae.email
    from
      contributions c,
      gha_actors a
    left join
      gha_actors_emails ae
    on
      ae.actor_id = a.id
      and ae.email not like '%@users.noreply.github.com'
    where
      (c.actor_id = a.id or c.login = a.login)
    group by
      a.login,
      ae.email
    order by
      id asc,
      email asc
    ) s
  group by
    s.id
) sub
where
  sub.contributions >= {{n}}
order by
  sub.contributions desc
;
