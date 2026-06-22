--mod #12096 データリストにてDWおよび目標体重を登録するとサーバダウン zrx start
-- select
--     ord_no,
--     pat_id,
--     treat_date,
--     rst_weight_info,
--     rst_start_date,
--     rst_end_date,
--     rst_treatment_cd,
--     rst_dialysis_state
-- from
--   ord_main A
-- where
--   A.pat_id = /*patId*/0
-- --     mod FNSI-6478 劉全航 start
-- -- and A.rst_dialysis_state in ( '1','2','3','4','5','6' )
-- and A.rst_dialysis_state in ( '1','2','3','4','5' )
-- --     mod FNSI-6478 劉全航 end
-- and A.facility_cd =  /*facilityCd*/''
-- order by
--   A.pat_id, A.treat_date, A.rst_dialysis_state
-- ;
with temp_pat_id(pat_id) as (
    values
    /*%for patId : patIdList */
    (/*patId*/0)/*%if patId_has_next*/,/*%end*/
    /*%end*/
)
select
    A.ord_no,
    A.pat_id,
    A.treat_date,
    A.rst_weight_info,
    A.rst_start_date,
    A.rst_end_date,
    A.rst_treatment_cd,
    A.rst_dialysis_state
from ord_main A
     join temp_pat_id T on A.pat_id = T.pat_id
where
     A.facility_cd = /*facilityCd*/''
    and A.rst_dialysis_state in ('1','2','3','4','5')
order by
    A.facility_cd, A.pat_id, A.treat_date, A.rst_dialysis_state
;
--mod #12096 データリストにてDWおよび目標体重を登録するとサーバダウン zrx end
