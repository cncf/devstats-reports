-- {{by}} = 'Project start date' - by start date
-- {{by}} = 'CNCF join date' - by join date
select
  count(distinct period) as projects
from
  sannotations_shared
where
  title in ('{{by}}')
  and time < '{{dtto}}'
  and period not in (
    select
      period
    from
      sannotations_shared
    where
      title = 'Archived'
      and time < '{{dtto}}'
  )
;
