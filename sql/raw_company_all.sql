\copy (
  select
    a.login,
    a.name,
    a.country_name,
    aa.dt_from as affiliated_from,
    aa.dt_to as affiliatied_to,
    min(date(e.created_at)) as first_contribution,
    max(date(e.created_at)) as last_contribution,
    count(distinct e.id) as contributions
  from
    gha_actors a,
    gha_actors_affiliations aa
  left join
    gha_events e
  on
    aa.actor_id = e.actor_id
    and e.created_at >= aa.dt_from
    and e.created_at < aa.dt_to
  where
    aa.actor_id = a.id
    and lower(aa.company_name) = '{{company}}'
    and (e.type is null or e.type in ('IssuesEvent', 'PullRequestEvent', 'PushEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'))
  group by
    a.login,
    a.name,
    a.country_name,
    aa.dt_from,
    aa.dt_to
  order by
    contributions desc
) to '/tmp/all_{{company}}.csv' with csv delimiter ',' header;
