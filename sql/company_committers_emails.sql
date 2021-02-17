select distinct 
  af.{{company_name}} as company,
  c.dup_{{actor}}_login as commit_{{actor}},
  ae.email as commit_{{actor}}_email,
  count(distinct sha) as commit_{{actor}}_commits
from (
  select sha,
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
  ) c,
  gha_actors_affiliations af,
  gha_actors_emails ae
where
  c.{{actor}}_id = af.actor_id
  and af.dt_from <= c.dup_created_at
  and af.dt_to > c.dup_created_at
  and af.{{company_name}} = '{{company}}'
  and c.{{actor}}_id = ae.actor_id
  and lower(ae.email) not like '%users.noreply.github.com'
  and (lower(c.dup_{{actor}}_login) {{exclude_bots}})
group by
  af.{{company_name}},
  c.dup_{{actor}}_login,
  ae.email
order by
  commit_{{actor}}_commits desc,
  commit_{{actor}} asc,
  commit_{{actor}}_email asc
;
