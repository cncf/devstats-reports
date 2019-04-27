select
  sub.company_commits as commits,
  (sub.company_commits * 100.0) / sub.{{type}}_commits as percent_commits
from (
  select count(distinct c.sha) filter (where af.company_name = '{{company}}') as company_commits,
    count(distinct c.sha) filter (where af.company_name is not null) as known_commits,
    count(distinct c.sha) as all_commits
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
