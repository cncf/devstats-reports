with events as (
  select actor_id,
    dup_actor_login as actor,
    id as event_id
  from
    gha_events
  where
    type in (
      'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewCommentEvent'
    )
    and (lower(dup_actor_login) {{exclude_bots}})
), unknown_events as (
  select distinct e.actor_id,
    e.dup_actor_login as actor,
    e.id as event_id
  from
    gha_events e
  left join
    gha_actors_affiliations aa
  on
    e.actor_id = aa.actor_id
  where
    e.type in (
      'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewCommentEvent'
    )
    and (lower(e.dup_actor_login) {{exclude_bots}})
    and aa.actor_id is null
), issuers as (
  select actor,
    count(distinct event_id) as events
  from
    events
  group by
    actor
  order by
    events desc
), unknown_issuers as (
  select actor,
    count(distinct event_id) as events
  from
    unknown_events
  group by
    actor
  order by
    events desc
), all_issuers as (
  select sum(events) as cnt
  from
    issuers
)
select
  row_number() over cumulative_events as rank_number,
  c.actor,
  c.events,
  round((c.events * 100.0) / a.cnt, 5) as percent,
  sum(c.events) over cumulative_events as cumulative_sum,
  round((sum(c.events) over cumulative_events * 100.0) / a.cnt, 5) as cumulative_percent,
  a.cnt as all_events
from
  unknown_issuers c,
  all_issuers a
window
  cumulative_events as (
    order by c.events desc, c.actor asc
    range between unbounded preceding
    and current row
  )
;
