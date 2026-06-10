select
	pat_id,
	physical_info

from
  pat_unique
where
  is_del = '0'
and
  pat_id = /*patId*/0
;
