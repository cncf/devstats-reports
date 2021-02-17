select
  sub.company_commits as commits,
  (sub.company_commits * 100.0) / sub.{{type}}_distinct_commits as percent_commits,
  (sub.known_commits * 100.0) / sub.all_commits as data_quality
from (
  select count(distinct c.sha) filter (where af.{{company_name}} = '{{company}}') as company_commits,
    count(distinct c.sha) filter (where af.{{company_name}} is not null and c.dup_{{actor}}_login != '') as known_distinct_commits,
    count(distinct c.sha) as all_distinct_commits,
    count(c.sha) filter (where af.{{company_name}} is not null and c.dup_{{actor}}_login != '') as known_commits,
    count(c.sha) as all_commits
  from (
    select
      sha,
      dup_created_at,
      dup_actor_id as actor_id,
      author_id,
      committer_id,
      dup_actor_login,
      dup_author_login,
      dup_committer_login
    from
      gha_commits
    where
      dup_created_at >= '{{dtfrom}}'
      and dup_created_at < '{{dtto}}'
  ) c
  left join
    gha_actors_affiliations af
  on
    c.{{actor}}_id = af.actor_id
    and af.dt_from <= c.dup_created_at
    and af.dt_to > c.dup_created_at
  where
    lower(c.dup_{{actor}}_login) {{exclude_bots}}
) sub
;
