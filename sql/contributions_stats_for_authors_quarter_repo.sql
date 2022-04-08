select
  sub.actor,
  sub.type,
  count(distinct sub.event_id) as n
from (
select
  dup_actor_login as actor,
  id as event_id,
  type
from
  gha_events
where
  type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
  and dup_actor_login in (
    'dims', 'neolit123', 'MadhavJivrajani', 'endocrimes'
  )
  and created_at >= now() - '3 months'::interval
  and dup_repo_name = 'kubernetes/kubernetes'
union select
  dup_author_login as actor,
  event_id,
  'CommmitAuthored' as type
from
  gha_commits
where
  dup_author_login in (
    'dims', 'neolit123', 'MadhavJivrajani', 'endocrimes'
  )
  and dup_created_at >= now() - '3 months'::interval
  and dup_repo_name = 'kubernetes/kubernetes'
union select
  dup_committer_login as actor,
  event_id,
  'Commmitied' as type
from
  gha_commits
where
  dup_committer_login in (
    'dims', 'neolit123', 'MadhavJivrajani', 'endocrimes'
  )
  and dup_created_at >= now() - '3 months'::interval
  and dup_repo_name = 'kubernetes/kubernetes'
) sub
group by
  sub.actor,
  sub.type
order by
  n desc
;
