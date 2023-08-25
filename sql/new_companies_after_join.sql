with existing_companies as (
  select distinct
    af.{{company_name}} as name
  from
    gha_events e,
    gha_actors_affiliations af
  where
    e.actor_id = af.actor_id
    and af.dt_from <= e.created_at
    and af.dt_to > e.created_at
    and e.created_at < '{{dtjoin}}'
    and (lower(e.dup_actor_login) {{exclude_bots}})
    and e.type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
    and af.{{company_name}} is not null
    and trim(af.{{company_name}}) != ''
), existing_contributors as (
  select distinct
    e.actor_id as id,
    e.dup_actor_login as login,
    e.dup_actor_login || '_' || e.actor_id::text as login_id
  from
    gha_events e
  where
    e.created_at < '{{dtjoin}}'
    and (lower(e.dup_actor_login) {{exclude_bots}})
    and e.type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
)
select
  s.new_companies as new_companies_count,
  (s.new_companies * 100.0) / s.all_companies as percent_new_companies_count,
  s.new_companies_contributions,
  (s.new_companies_contributions * 100.0) / s.all_companies_contributions as percent_new_companies_contributions,
  s.new_contributors as new_contributors_count,
  (s.new_contributors * 100.0) / s.all_contributors as percent_new_contributors_count,
  s.new_contributors_contributions,
  (s.new_contributors_contributions * 100.0) / s.all_contributors_contributions as percent_new_contributors_contributions
from (
  select
    -- those "all" values refer to dtfrom - dtto range
    -- for companies-related data we only consider events where affiliation is known
    count(distinct af.{{company_name}}) filter (where af.{{company_name}} is not null) as all_companies,
    count(distinct e.dup_actor_login || '_' || e.actor_id::text) as all_contributors,
    count(e.id) filter (where af.{{company_name}} is not null) as all_companies_contributions,
    count(e.id) as all_contributors_contributions,
    count(distinct af.{{company_name}}) filter (where af.{{company_name}} is not null and af.{{company_name}} not in (select name from existing_companies)) as new_companies,
    count(distinct e.dup_actor_login || '_' || e.actor_id::text) filter (where e.dup_actor_login || '_' || e.actor_id::text not in (select login_id from existing_contributors)) as new_contributors,
    count(e.id) filter (where af.{{company_name}} is not null and af.{{company_name}} not in (select name from existing_companies)) as new_companies_contributions,
    count(e.id) filter (where e.dup_actor_login || '_' || e.actor_id::text not in (select login_id from existing_contributors)) as new_contributors_contributions
  from
    gha_events e
  left join
    gha_actors_affiliations af
  on
    e.actor_id = af.actor_id
    and af.dt_from <= e.created_at
    and af.dt_to > e.created_at
  where
    e.created_at >= '{{dtfrom}}'
    and e.created_at < '{{dtto}}'
    and (lower(e.dup_actor_login) {{exclude_bots}})
    and e.type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
) s
;
