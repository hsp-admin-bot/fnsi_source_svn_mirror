DROP INDEX IF EXISTS idx_ord_main_06;
create index idx_ord_main_06
on ntss.ord_main (facility_cd, pat_id, rst_start_date desc, ord_no desc)
include (treat_date, rst_weight_info, rst_treatment_cd)
where is_del = '0'
    and rst_dialysis_state = '6'
    and pat_id is not null;