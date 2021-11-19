select
  rep.project || ',' || rep.num_countries
from (
  select
    sub.repo_group as project,
    count(distinct sub.country_id) as num_countries
  from (
    select
      r.repo_group,
      a.country_id
    from
      gha_events e,
      gha_actors a,
      gha_repos r
    where
      e.actor_id = a.id
      and e.type in (
        'PushEvent', 'PullRequestEvent', 'IssuesEvent',
        'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
      )
      and e.created_at >= '{{dtfrom}}'
      and e.created_at < '{{dtto}}'
      and e.repo_id = r.id
      and e.dup_repo_name = r.name
    union select
      r.repo_group,
      a.country_id
    from
      gha_actors a,
      gha_commits c,
      gha_repos r
    where
      (
        c.author_id = a.id
        or c.committer_id = a.id
      )
      and c.dup_created_at >= '{{dtfrom}}'
      and c.dup_created_at < '{{dtto}}'
      and c.dup_repo_id = r.id
      and c.dup_repo_name = r.name
  ) sub
  where
    sub.repo_group is not null
    and trim(sub.repo_group) != ''
  group by
    sub.repo_group
) rep
order by
  rep.num_countries desc
;
