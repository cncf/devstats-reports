select
  split_part(name, '$$', 1) as "Project/Repository Group",
  substring(series from 5) as "Metric",
  value as "BF",
  split_part(name, '$$', 2)::numeric as "BF percent",
  split_part(name, '$$', 3) as "Bus/Elephant Factor",
  split_part(name, '$$', 4)::numeric as "Oth. #",
  split_part(name, '$$', 5)::numeric as "Oth. percent",
  split_part(name, '$$', 6) as "Top 10",
  split_part(name, '$$', 7)::numeric as "Top 10 percent",
  split_part(name, '$$', 8) as "Top",
  split_part(name, '$$', 9)::numeric as "Rem. #",
  split_part(name, '$$', 10)::numeric as "Rem. percent"
from
  shbf
where
  period = '{{period}}'
  and lower(name) like '{{project}}%'
order by
  series
;
