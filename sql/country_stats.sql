select
  time,
  "{{country}}"
from
  scountries{{cumulative}}
where
  time >= '{{dtfrom}}'
  and time < '{{dtto}}'
  and period = '{{period}}'
  and series = 'countries{{cumulative}}{{repogroup}}{{metric}}'
order by
  time asc
;
