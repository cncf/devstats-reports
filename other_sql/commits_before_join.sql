select
  sub.company,
  sub.commit_{{actor}},
  sub.commits
from (
  select af.company_name as company,
    c.dup_{{actor}}_login as commit_{{actor}},
    count(distinct c.sha) as commits
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
      dup_created_at < '2016-03-10'
  ) c
  left join
    gha_actors_affiliations af
  on
    c.{{actor}}_id = af.actor_id
    and af.dt_from <= c.dup_created_at
    and af.dt_to > c.dup_created_at
  where
    lower(c.dup_{{actor}}_login) {{exclude_bots}}
  group by
    af.company_name,
    c.dup_{{actor}}_login
  ) sub
order by
  sub.commits desc,
  sub.company asc,
  sub.commit_{{actor}} asc
;
