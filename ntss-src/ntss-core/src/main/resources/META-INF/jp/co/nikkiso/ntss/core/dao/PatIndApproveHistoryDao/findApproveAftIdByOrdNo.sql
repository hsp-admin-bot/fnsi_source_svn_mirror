select approve_aft_id
from pat_ind_approve_history
where ord_no = /* ordNo */0
and approve_kind = /* approveKind */null
order by up_date desc 
limit 1;
