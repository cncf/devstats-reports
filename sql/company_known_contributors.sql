with contributions as (
  select c.committer_id as actor_id,
    c.dup_committer_login as actor,
    c.event_id
  from
    gha_commits c,
    gha_actors_affiliations aa
  where
    aa.actor_id = c.committer_id
    and c.dup_created_at >= aa.dt_from
    and c.dup_created_at < aa.dt_to
    -- and aa.{{company_name}} = '{{company}}'
    and c.committer_id is not null
    and (lower(c.dup_committer_login) {{exclude_bots}})
  union select c.author_id as actor_id,
    c.dup_author_login as actor,
    c.event_id
  from
    gha_commits c,
    gha_actors_affiliations aa
  where
    aa.actor_id = c.author_id
    and c.dup_created_at >= aa.dt_from
    and c.dup_created_at < aa.dt_to
    -- and aa.{{company_name}} = '{{company}}'
    and c.author_id is not null
    and (lower(c.dup_author_login) {{exclude_bots}})
  union select e.actor_id,
    e.dup_actor_login as actor,
    e.id as event_id
  from
    gha_events e,
    gha_actors_affiliations aa
  where
    aa.actor_id = e.actor_id
    and e.created_at >= aa.dt_from
    and e.created_at < aa.dt_to
    -- and aa.{{company_name}} = '{{company}}'
    and e.type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
    and (lower(e.dup_actor_login) {{exclude_bots}})
), known_contributions as (
  select distinct c.committer_id as actor_id,
    c.dup_committer_login as actor,
    c.event_id,
    coalesce(string_agg(distinct an.name, ', '), '-') as names
  from
    gha_commits c,
    gha_actors_affiliations aa,
    gha_actors a
  left join
    gha_actors_names an
  on
    an.actor_id = a.id
  where
    c.committer_id is not null
    and c.committer_id = a.id
    and c.dup_committer_login = a.login
    and (lower(c.dup_committer_login) {{exclude_bots}})
    and c.committer_id = aa.actor_id
    and c.dup_created_at >= aa.dt_from
    and c.dup_created_at < aa.dt_to
    and aa.{{company_name}} = '{{company}}'
  group by
    1, 2, 3
  union select distinct c.author_id as actor_id,
    c.dup_author_login as actor,
    c.event_id,
    coalesce(string_agg(distinct an.name, ', '), '-') as names
  from
    gha_commits c,
    gha_actors_affiliations aa,
    gha_actors a
  left join
    gha_actors_names an
  on
    an.actor_id = a.id
  where
    c.author_id is not null
    and c.author_id = a.id
    and c.dup_author_login = a.login
    and (lower(c.dup_author_login) {{exclude_bots}})
    and c.author_id = aa.actor_id
    and c.dup_created_at >= aa.dt_from
    and c.dup_created_at < aa.dt_to
    and aa.{{company_name}} = '{{company}}'
  group by
    1, 2, 3
  union select distinct e.actor_id,
    e.dup_actor_login as actor,
    e.id as event_id,
    coalesce(string_agg(distinct an.name, ', '), '-') as names
  from
    gha_events e,
    gha_actors_affiliations aa,
    gha_actors a
  left join
    gha_actors_names an
  on
    an.actor_id = a.id
  where
    e.type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
    and e.actor_id = a.id
    and e.dup_actor_login = a.login
    and (lower(e.dup_actor_login) {{exclude_bots}})
    and e.actor_id = aa.actor_id
    and e.created_at >= aa.dt_from
    and e.created_at < aa.dt_to
    and aa.{{company_name}} = '{{company}}'
  group by
    1, 2, 3
), contributors as (
  select actor,
    count(distinct event_id) as contributions
  from
    contributions
  group by
    actor
  order by
    contributions desc
), known_contributors as (
  select
    actor,
    names,
    count(distinct event_id) as contributions
  from
    known_contributions
  group by
    actor,
    names
  order by
    contributions desc
), all_contributions as (
  select sum(contributions) as cnt
  from
    contributors
)
select
  row_number() over cumulative_contributions as rank_number,
  c.actor,
  c.names,
  c.contributions,
  round((c.contributions * 100.0) / a.cnt, 5) as percent,
  sum(c.contributions) over cumulative_contributions as cumulative_sum,
  round((sum(c.contributions) over cumulative_contributions * 100.0) / a.cnt, 5) as cumulative_percent,
  a.cnt as all_contributions
from
  known_contributors c,
  all_contributions a
window
  cumulative_contributions as (
    order by
      c.contributions desc,
      c.actor asc
    range between
      unbounded preceding
      and current row
  )
;
