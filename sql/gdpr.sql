select
  'gha_actors: login: ' || login as hit
from
  gha_actors
where
  lower(login) {{cond}}
union select
  'gha_actors: name: ' || name as hit
from
  gha_actors
where
  lower(name) {{cond}}
union select
  'gha_actors_names: name: ' || name as hit
from
  gha_actors_names
where
  lower(name) {{cond}}
union select
  'gha_actors_emails: email: ' || email as hit
from
  gha_actors_emails
where
  lower(email) {{cond}}
;
