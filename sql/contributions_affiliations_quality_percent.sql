select
  sub.known_contributions as known_contributions_max,     -- known here is any contribution having at least 1 known actor (commit has 3 actors: actor (pusher), committer, author)
  sub.unknown_contributions as unknown_contributions_max, -- unknown here is any contribution that has at least 1 unknown actor
  sub.all_contributions - sub.unknown_contributions as known_contributions_min,
  sub.all_contributions - sub.known_contributions as unknown_contributions_min,
  sub.all_contributions,
  (sub.known_contributions + sub.unknown_contributions) - sub.all_contributions as mixed_contributions,
  (sub.known_contributions * 100.0) / case sub.all_contributions when 0 then 1 else sub.all_contributions end as percent_known_max,
  (sub.unknown_contributions * 100.0) / case sub.all_contributions when 0 then 1 else sub.all_contributions end as percent_unknown_max,
  ((sub.all_contributions - sub.unknown_contributions) * 100.0) / case sub.all_contributions when 0 then 1 else sub.all_contributions end as percent_known_min,
  ((sub.all_contributions - sub.known_contributions) * 100.0) / case sub.all_contributions when 0 then 1 else sub.all_contributions end as percent_unknown_min,
  (((sub.known_contributions + sub.unknown_contributions) - sub.all_contributions) * 100.0) / case sub.all_contributions when 0 then 1 else sub.all_contributions end as percent_mixed
from (
  select
    count(distinct c.id) as all_contributions,
    count(distinct c.id) filter (where c.{{company_name}} is null) as unknown_contributions,
    count(distinct c.id) filter (where c.{{company_name}} is not null) as known_contributions
  from (
    select
      e.id,
      e.actor_id,
      e.dup_actor_login as actor,
      af.company_name
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
    union select
      c.event_id,
      c.committer_id,
      c.dup_committer_login,
      af.company_name
    from
      gha_commits c
    left join
      gha_actors_affiliations af
    on
      c.committer_id = af.actor_id
      and af.dt_from <= c.dup_created_at
      and af.dt_to > c.dup_created_at
    where
      c.committer_id is not null
      and c.dup_created_at >= '{{dtfrom}}'
      and c.dup_created_at < '{{dtto}}'
      and (lower(c.dup_committer_login) {{exclude_bots}})
    union select
      c.event_id,
      c.author_id,
      c.dup_author_login,
      af.company_name
    from
      gha_commits c
    left join
      gha_actors_affiliations af
    on
      c.author_id = af.actor_id
      and af.dt_from <= c.dup_created_at
      and af.dt_to > c.dup_created_at
    where
      c.author_id is not null
      and c.dup_created_at >= '{{dtfrom}}'
      and c.dup_created_at < '{{dtto}}'
      and (lower(c.dup_author_login) {{exclude_bots}})
  ) c
) sub
;
