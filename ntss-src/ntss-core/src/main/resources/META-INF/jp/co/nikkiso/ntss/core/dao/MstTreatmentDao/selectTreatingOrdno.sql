select
ord_no
from ord_main
where pat_id = /*patId*/1
and rst_dialysis_state in /*stateList*/(null)
and is_del = '0'
