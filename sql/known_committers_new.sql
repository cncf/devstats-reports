with commits as (
  select committer_id as actor_id,
    dup_committer_login as actor,
    event_id
  from
    gha_commits
  where
    committer_id is not null
    and (lower(dup_committer_login) {{exclude_bots}})
    and dup_created_at >= now() - '{{ago}}'::interval
    and committer_id not in (select committer_id from gha_commits where dup_created_at < now() - '{{ago}}'::interval)
  union select author_id as actor_id,
    dup_author_login as actor,
    event_id
  from
    gha_commits
  where
    author_id is not null
    and (lower(dup_author_login) {{exclude_bots}})
    and dup_created_at >= now() - '{{ago}}'::interval
    and author_id not in (select author_id from gha_commits where dup_created_at < now() - '{{ago}}'::interval)
  union select actor_id,
    dup_actor_login as actor,
    id as event_id
  from
    gha_events
  where
    type in ('PushEvent')
    and (lower(dup_actor_login) {{exclude_bots}})
    and created_at >= now() - '{{ago}}'::interval
    and actor_id not in (select actor_id from gha_events where type = 'PushEvent' and created_at < now() - '{{ago}}'::interval)
), known_commits as (
  select distinct c.committer_id as actor_id,
    c.dup_committer_login as actor,
    c.event_id
  from
    gha_commits c,
    gha_actors_affiliations aa
  where
    c.committer_id is not null
    and (lower(c.dup_committer_login) {{exclude_bots}})
    and c.dup_created_at >= now() - '{{ago}}'::interval
    and c.committer_id not in (select committer_id from gha_commits where dup_created_at < now() - '{{ago}}'::interval)
    and c.committer_id = aa.actor_id
  union select distinct c.author_id as actor_id,
    c.dup_author_login as actor,
    c.event_id
  from
    gha_commits c,
    gha_actors_affiliations aa
  where
    c.author_id is not null
    and (lower(c.dup_author_login) {{exclude_bots}})
    and c.dup_created_at >= now() - '{{ago}}'::interval
    and c.author_id not in (select author_id from gha_commits where dup_created_at < now() - '{{ago}}'::interval)
    and c.author_id = aa.actor_id
  union select distinct e.actor_id,
    e.dup_actor_login as actor,
    e.id as event_id
  from
    gha_events e,
    gha_actors_affiliations aa
  where
    e.type in ('PushEvent')
    and (lower(e.dup_actor_login) {{exclude_bots}})
    and e.created_at >= now() - '{{ago}}'::interval
    and e.actor_id not in (select actor_id from gha_events where type = 'PushEvent' and created_at < now() - '{{ago}}'::interval)
    and e.actor_id = aa.actor_id
), committers as (
  select actor,
    count(distinct event_id) as commits
  from
    commits
  group by
    actor
  order by
    commits desc
), known_committers as (
  select actor,
    count(distinct event_id) as commits
  from
    known_commits
  group by
    actor
  order by
    commits desc
), all_commits as (
  select sum(commits) as cnt
  from
    committers
)
select
  row_number() over cumulative_commits as rank_number,
  c.actor,
  c.commits,
  round((c.commits * 100.0) / a.cnt, 5) as percent,
  sum(c.commits) over cumulative_commits as cumulative_sum,
  round((sum(c.commits) over cumulative_commits * 100.0) / a.cnt, 5) as cumulative_percent,
  a.cnt as all_commits
from
  known_committers c,
  all_commits a
window
  cumulative_commits as (
    order by c.commits desc, c.actor asc
    range between unbounded preceding
    and current row
  )
;
