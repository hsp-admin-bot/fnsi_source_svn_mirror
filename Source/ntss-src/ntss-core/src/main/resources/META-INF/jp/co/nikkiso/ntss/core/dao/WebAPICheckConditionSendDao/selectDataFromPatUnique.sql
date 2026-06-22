select
  pat.physical_info
from
	pat_unique pat,
	ord_main ord
where
  pat.pat_id = ord.pat_id
and
  ord.ord_no = /*ordNo*/1
