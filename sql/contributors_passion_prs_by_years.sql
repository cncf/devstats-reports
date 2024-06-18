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
      '(Robots)', 'Independent'
    )
  where
    e.type in (
      'IssuesEvent', 'PullRequestEvent', 'PushEvent', 'CommitCommentEvent',
      'IssueCommentEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent'
    )
    and lower(e.dup_actor_login) not ilike any(
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
  i.dup_user_login as username,
  coalesce(aa.company_name, '') as vendor,
  tv.vendor is null as passion,
  count(distinct i.dup_repo_name || i.number) as prs
from
  gha_issues i
left join
  gha_actors_affiliations aa
on
  i.user_id = aa.actor_id
  and i.created_at >= aa.dt_from
  and i.created_at < aa.dt_to
left join
  top_vendors tv
on
  aa.company_name = tv.vendor
where
  lower(i.dup_user_login) not ilike any(
    select
      pattern
    from
      gha_bot_logins
  )
  and coalesce(aa.company_name, '') not in ('(Robots)')
  and i.is_pull_request = true
group by
  year,
  username,
  aa.company_name,
  tv.vendor
order by
  year asc,
  prs desc
) to stdout with csv header
