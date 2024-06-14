copy (
with vendor_data as (
  select
    aa.company_name as vendor,
    count(distinct e.dup_actor_login) as contributors,
    count(distinct e.id) as contributions
  from
    gha_events e
  inner join
    gha_actors_affiliations aa
  on
    e.actor_id = aa.actor_id
    and e.created_at >= aa.dt_from
    and e.created_at < aa.dt_to
    and aa.company_name not in (
      '(Robots)', 'Independent', 'CNCF'
    )
  where
    e.type in (
      'IssuesEvent', 'PullRequestEvent', 'PushEvent', 'CommitCommentEvent',
      'IssueCommentEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent'
    )
    and e.dup_actor_login not ilike all(
      select
        pattern
      from
        gha_bot_logins
    )
  group by
    aa.company_name
), top_vendors_by_contributions as (
  select
    vendor
  from
    vendor_data
  order by
    contributions desc
  limit
    10
), top_vendors_by_contributors as (
  select
    vendor
  from
    vendor_data
  order by
    contributors desc
  limit
    10
), top_vendors as (
  select
    vendor
  from
    top_vendors_by_contributions
  union
  select
    vendor
  from
    top_vendors_by_contributors
)
select
  extract(year from i.created_at) as year,
  v.vendor as vendor,
  count(distinct i.dup_user_login) as pr_authors,
  count(distinct i.dup_repo_name || i.number) as prs
from
  gha_issues i
inner join
  gha_actors_affiliations aa
on
  i.user_id = aa.actor_id
  and i.created_at >= aa.dt_from
  and i.created_at < aa.dt_to
  and aa.company_name not in (
    '(Robots)', 'Independent', 'CNCF'
  )
inner join
  top_vendors v
on
  v.vendor = aa.company_name
where
  i.dup_user_login not ilike all(
    select
      pattern
    from
      gha_bot_logins
  )
  and i.is_pull_request = true
group by
  year,
  vendor
order by
  year asc,
  pr_authors desc
) to stdout with csv header
