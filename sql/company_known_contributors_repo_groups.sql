with contributions as (
  select
    rg.repo_group,
    c.committer_id as actor_id,
    c.dup_committer_login as actor,
    c.event_id
  from
    gha_repo_groups rg,
    gha_commits c,
    gha_actors_affiliations aa
  where
    aa.actor_id = c.committer_id
    and c.dup_repo_id = rg.id
    and c.dup_repo_name = rg.name
    and c.dup_created_at >= aa.dt_from
    and c.dup_created_at < aa.dt_to
    and c.committer_id is not null
    and (lower(c.dup_committer_login) {{exclude_bots}})
  union
  select
    rg.repo_group,
    c.author_id as actor_id,
    c.dup_author_login as actor,
    c.event_id
  from
    gha_repo_groups rg,
    gha_commits c,
    gha_actors_affiliations aa
  where
    aa.actor_id = c.author_id
    and c.dup_repo_id = rg.id
    and c.dup_repo_name = rg.name
    and c.dup_created_at >= aa.dt_from
    and c.dup_created_at < aa.dt_to
    and c.author_id is not null
    and (lower(c.dup_author_login) {{exclude_bots}})
  union
  select
    rg.repo_group,
    e.actor_id,
    e.dup_actor_login as actor,
    e.id as event_id
  from
    gha_repo_groups rg,
    gha_events e,
    gha_actors_affiliations aa
  where
    aa.actor_id = e.actor_id
    and e.repo_id = rg.id
    and e.dup_repo_name = rg.name
    and e.created_at >= aa.dt_from
    and e.created_at < aa.dt_to
    and e.type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
    and (lower(e.dup_actor_login) {{exclude_bots}})
), known_contributions as (
  select distinct
    rg.repo_group,
    c.committer_id as actor_id,
    c.dup_committer_login as actor,
    c.event_id,
    c.dup_created_at as created_at,
    aa.dt_from,
    aa.dt_to,
    a.country_name,
    coalesce(string_agg(distinct an.name, ', '), '-') as names
  from
    gha_repo_groups rg,
    gha_commits c,
    gha_actors_affiliations aa,
    gha_actors a
  left join
    gha_actors_names an
  on
    an.actor_id = a.id
  where
    c.committer_id is not null
    and c.dup_repo_id = rg.id
    and c.dup_repo_name = rg.name
    and c.committer_id = a.id
    and c.dup_committer_login = a.login
    and (lower(c.dup_committer_login) {{exclude_bots}})
    and c.committer_id = aa.actor_id
    and c.dup_created_at >= aa.dt_from
    and c.dup_created_at < aa.dt_to
    and aa.{{company_name}} = '{{company}}'
  group by
    1, 2, 3, 4, 5, 6, 7, 8
  union
  select distinct
    rg.repo_group,
    c.author_id as actor_id,
    c.dup_author_login as actor,
    c.event_id,
    c.dup_created_at as created_at,
    aa.dt_from,
    aa.dt_to,
    a.country_name,
    coalesce(string_agg(distinct an.name, ', '), '-') as names
  from
    gha_repo_groups rg,
    gha_commits c,
    gha_actors_affiliations aa,
    gha_actors a
  left join
    gha_actors_names an
  on
    an.actor_id = a.id
  where
    c.author_id is not null
    and c.dup_repo_id = rg.id
    and c.dup_repo_name = rg.name
    and c.author_id = a.id
    and c.dup_author_login = a.login
    and (lower(c.dup_author_login) {{exclude_bots}})
    and c.author_id = aa.actor_id
    and c.dup_created_at >= aa.dt_from
    and c.dup_created_at < aa.dt_to
    and aa.{{company_name}} = '{{company}}'
  group by
    1, 2, 3, 4, 5, 6, 7, 8
  union
  select distinct
    rg.repo_group,
    e.actor_id,
    e.dup_actor_login as actor,
    e.id as event_id,
    e.created_at,
    aa.dt_from,
    aa.dt_to,
    a.country_name,
    coalesce(string_agg(distinct an.name, ', '), '-') as names
  from
    gha_repo_groups rg,
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
    and e.repo_id = rg.id
    and e.dup_repo_name = rg.name
    and e.actor_id = a.id
    and e.dup_actor_login = a.login
    and (lower(e.dup_actor_login) {{exclude_bots}})
    and e.actor_id = aa.actor_id
    and e.created_at >= aa.dt_from
    and e.created_at < aa.dt_to
    and aa.{{company_name}} = '{{company}}'
  group by
    1, 2, 3, 4, 5, 6, 7, 8
), contributors as (
  select
    repo_group,
    actor,
    count(distinct event_id) as contributions
  from
    contributions
  group by
    repo_group,
    actor
  order by
    contributions desc
), known_contributors as (
  select
    repo_group,
    actor,
    names,
    country_name,
    to_char(min(created_at), 'MM/DD/YYYY') as first_contribution,
    to_char(max(created_at), 'MM/DD/YYYY') as last_contribution,
    to_char(min(dt_from), 'MM/DD/YYYY') as affiliated_from,
    to_char(max(dt_to), 'MM/DD/YYYY') as affiliated_to,
    count(distinct event_id) as contributions
  from
    known_contributions
  group by
    repo_group,
    actor,
    names,
    country_name
  order by
    contributions desc
), all_contributions as (
  select
    repo_group,
    sum(contributions) as cnt
  from
    contributors
  group by
    repo_group
)
select
  c.repo_group as project,
  row_number() over cumulative_contributions as rank_number,
  c.actor,
  c.names as actor_names,
  c.country_name,
  c.contributions,
  round((c.contributions * 100.0) / a.cnt, 5) as percent_of_all,
  sum(c.contributions) over cumulative_contributions as cumulative_sum,
  round((sum(c.contributions) over cumulative_contributions * 100.0) / a.cnt, 5) as cumulative_percent,
  first_contribution,
  last_contribution,
  case affiliated_from = '01/01/1900' when true then '' else affiliated_from end as affiliated_from,
  case affiliated_to = '01/01/2100' when true then '' else affiliated_to end as affiliated_to,
  a.cnt as all_contributions
from
  known_contributors c,
  all_contributions a
where
  c.repo_group = a.repo_group
window
  cumulative_contributions as (
    partition by
      c.repo_group
    order by
      c.repo_group asc,
      c.contributions desc,
      c.actor asc
    range between
      unbounded preceding
      and current row
  )
;
