-- Should be called with:
-- {{actor}} dup_actor_login
-- {{actor2}} dup_author_login
-- {{actor3}} dup_committer_login
select
  count(distinct sha) as commits
from
  gha_commits
where
  dup_created_at >= '{{dtfrom}}'
  and dup_created_at < '{{dtto}}'
  and (
    (lower({{actor}}) {{exclude_bots}})
    or (lower({{actor2}}) {{exclude_bots}})
    or (lower({{actor3}}) {{exclude_bots}})
  )
;
