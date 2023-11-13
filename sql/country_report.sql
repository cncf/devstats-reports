with all_dates as (
  select
    '2014-01-01'::timestamp as "Date from",
    '2015-01-01'::timestamp as "Date to"
  union select
    '2015-01-01', '2016-01-01'
  union select
    '2016-01-01', '2017-01-01'
  union select
    '2017-01-01', '2018-01-01'
  union select
    '2018-01-01', '2019-01-01'
  union select
    '2019-01-01', '2020-01-01'
  union select
    '2020-01-01', '2021-01-01'
  union select
    '2021-01-01', '2022-01-01'
  union select
    '2022-01-01', '2023-01-01'
  union select
    '2023-01-01', '2024-01-01'
  union select
    '2014-01-01', '2024-01-01'
), dates as (
  select
    *
  from
    all_dates
  where
    1 = 1
    {{extra_cond}}
    -- you can limit this
    -- and "Date from" = '2014-01-01'
    -- and "Date to" = '2024-01-01'
), c_data as (
  select
    d."Date from",
    d."Date to",
    r.repo_group as "CNCF Project",
    a.country_name as "Country",
    count(distinct a.login) as "Contributors",
    count(e.id) as "Contributions"
  from
    gha_events e,
    gha_actors a,
    gha_repo_groups r,
    dates d
  where
    e.actor_id = a.id
    and e.dup_actor_login = a.login
    and e.repo_id = r.id
    and e.dup_repo_name = r.name
    and (lower(a.login) {{exclude_bots}})
    and e.created_at > d."Date from"
    and e.created_at < d."Date to"
    and length(a.country_id) = 2
    and r.repo_group != 'CNCF'
    and r.repo_group is not null
    and r.repo_group != ''
  group by
    d."Date from",
    d."Date to",
    r.repo_group,
    a.country_name
  union select
    d."Date from",
    d."Date to",
    'All Repo Groups' as "CNCF Project",
    a.country_name as "Country",
    count(distinct a.login) as "Contributors",
    count(e.id) as "Contributions"
  from
    gha_events e,
    gha_actors a,
    dates d
  where
    e.actor_id = a.id
    and e.dup_actor_login = a.login
    and (lower(a.login) {{exclude_bots}})
    and e.created_at > d."Date from"
    and e.created_at < d."Date to"
    and length(a.country_id) = 2
    and r.repo_group != 'CNCF'
    and r.repo_group is not null
    and r.repo_group != ''
  group by
    d."Date from",
    d."Date to",
    a.country_name
), country_data as (
  select
    *,
    row_number() over (
      partition by
        "Date from",
        "Date to",
        "CNCF Project"
      order by
        "Contributors" desc
    ) as "Contributors Rank",
    row_number() over (
      partition by
        "Date from",
        "Date to",
        "CNCF Project"
      order by
        "Contributions" desc
    ) as "Contributions Rank"
  from
    c_data
), all_data as (
  select
    d."Date from",
    d."Date to",
    r.repo_group as "CNCF Project",
    count(distinct a.login) as "Contributors",
    count(e.id) as "Contributions"
  from
    gha_events e,
    gha_actors a,
    gha_repo_groups r,
    dates d
  where
    e.actor_id = a.id
    and e.dup_actor_login = a.login
    and e.repo_id = r.id
    and e.dup_repo_name = r.name
    and (lower(a.login) {{exclude_bots}})
    and e.created_at > d."Date from"
    and e.created_at < d."Date to"
    and length(a.country_id) = 2
    and r.repo_group != 'CNCF'
    and r.repo_group is not null
    and r.repo_group != ''
  group by
    d."Date from",
    d."Date to",
    r.repo_group
  union select
    d."Date from",
    d."Date to",
    'All Repo Groups' as "CNCF Project",
    count(distinct a.login) as "Contributors",
    count(e.id) as "Contributions"
  from
    gha_events e,
    gha_actors a,
    dates d
  where
    e.actor_id = a.id
    and e.dup_actor_login = a.login
    and (lower(a.login) {{exclude_bots}})
    and e.created_at > d."Date from"
    and e.created_at < d."Date to"
    and length(a.country_id) = 2
    and r.repo_group != 'CNCF'
    and r.repo_group is not null
    and r.repo_group != ''
  group by
    d."Date from",
    d."Date to"
)
select
  cd."Date from",
  cd."Date to",
  cd."CNCF Project",
  cd."Contributors" as "{{country}} Contributors",
  cd."Contributions" as "{{country}} Contributions",
  ad."Contributors" as "All Contributors",
  ad."Contributions" as "All Contributions",
  (100.0 * cd."Contributors") / ad."Contributors" as "{{country}} Contributors Percent",
  (100.0 * cd."Contributions") / ad."Contributions" as "{{country}} Contributions Percent",
  cd."Contributors Rank" as "{{country}} Contributors Rank",
  cd."Contributions Rank" as "{{country}} Contributions Rank"
from
  country_data cd,
  all_data ad
where
  cd."CNCF Project" = ad."CNCF Project"
  and cd."Date from" = ad."Date from"
  and cd."Date to" = ad."Date to"
  and cd."Country" = '{{country}}'
order by
  cd."Date from",
  cd."Date to",
  "{{country}} Contributors Percent" desc
;
