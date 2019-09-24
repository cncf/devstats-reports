select
  sub2.*
from (
  select sub.contributor,
    count(distinct sub.contribution) as contributions,
    string_agg(distinct ae.email, ',') as emails
  from (
    select dup_actor_login as contributor,
      actor_id as contributor_id,
      id as contribution
    from
      gha_events
    where
      created_at >= '{{dtfrom}}'
      and created_at < '{{dtto}}'
      and (lower(dup_actor_login) {{exclude_bots}})
      and type in (
        'PushEvent', 'PullRequestEvent', 'IssuesEvent',
        'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
      )
    union select dup_author_login as contributor,
      author_id as contributor_id,
      event_id as contribution
    from
      gha_commits
    where
      dup_created_at >= '{{dtfrom}}'
      and dup_created_at < '{{dtto}}'
      and (lower(dup_author_login) {{exclude_bots}})
      and dup_author_login != ''
      and author_id is not null
    union select dup_committer_login as contributor,
      committer_id as contributor_id,
      event_id as contribution
    from
      gha_commits
    where
      dup_created_at >= '{{dtfrom}}'
      and dup_created_at < '{{dtto}}'
      and (lower(dup_committer_login) {{exclude_bots}})
      and dup_committer_login != ''
      and committer_id is not null
    ) sub
  left join
    gha_actors_emails ae
  on
    ae.actor_id = sub.contributor_id
    and ae.email not like '%users.noreply.github.com'
  group by
    sub.contributor
  ) sub2
where
  sub2.contributions >= {{top_n}}
order by
  contributions desc,
  sub2.contributor asc
;
