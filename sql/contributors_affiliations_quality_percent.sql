select
  sub.known_contributors as known_contributors_max,     -- known here is anybody who have at least 1 known contribution
  sub.unknown_contributors as unknown_contributors_max, -- unknown here is anybody with at least 1 unknown contribution
  sub.all_contributors - sub.unknown_contributors as known_contributors_min,
  sub.all_contributors - sub.known_contributors as unknown_contributors_min,
  (sub.known_contributors + sub.unknown_contributors) - sub.all_contributors as mixed_contributors, -- those who have both known and unknown contributions
  sub.all_contributors,
  (sub.known_contributors * 100.0) / case sub.all_contributors when 0 then 1 else sub.all_contributors end as percent_known_max,
  (sub.unknown_contributors * 100.0) / case sub.all_contributors when 0 then 1 else sub.all_contributors end as percent_unknown_max,
  ((sub.all_contributors - sub.unknown_contributors) * 100.0) / case sub.all_contributors when 0 then 1 else sub.all_contributors end as percent_known_min,
  ((sub.all_contributors - sub.known_contributors) * 100.0) / case sub.all_contributors when 0 then 1 else sub.all_contributors end as percent_unknown_min,
  (((sub.known_contributors + sub.unknown_contributors) - sub.all_contributors) * 100.0) / case sub.all_contributors when 0 then 1 else sub.all_contributors end as percent_mixed
from (
  select
    count(distinct c.actor) as all_contributors,
    count(distinct c.actor) filter (where c.{{company_name}} is null) as unknown_contributors,
    count(distinct c.actor) filter (where c.{{company_name}} is not null) as known_contributors
    -- can also use 'c.actor_id::text || c.actor' as actor ident
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
      c.dup_created_at >= '{{dtfrom}}'
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
      c.dup_created_at >= '{{dtfrom}}'
      and c.dup_created_at < '{{dtto}}'
      and (lower(c.dup_author_login) {{exclude_bots}})
  ) c
) sub
;
