select
  COALESCE(jsonb_array_length(rst_treatment_info), 0) as count
from
  ord_main
where
  ord_no = /*ordNo*/1
;

