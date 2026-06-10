-- 指定したオーダー番号より古い治療状態が3:透析中以降の治療記録から直近/同一曜日を指定件数取得する
-- #7691「実績：治療方法」が特殊血液浄化 の透析実績は取得対象外とする
select
 A.ord_no
 , A.rst_edition
 , A.rst_start_date
from
 ord_main A,
 (select
   pat_id,
   coalesce(rst_start_date, rst_cond_send_date, rst_accept_date)  as rst_start_date
  from
   ord_main
  where
   ord_no = /* ordNo */5
 ) B
 -- modify by chamaojia 2025-02-27 [11471] The value of 【rst】 does not need to be associated --start
--  (select
--    treatment_cd,
--    device_mode
--   from
--    mst_treatment
--   where
--    is_del = '0'
--  ) C
where
  A.pat_id = B.pat_id
and
  A.rst_start_date < B.rst_start_date
and
  A.rst_dialysis_state >= '3'
and
  A.is_del = '0'
-- and
--   A.rst_treatment_cd = C.treatment_cd
and
--   C.device_mode != 9
  A.rst_device_mode != 9
  -- modify by chamaojia 2025-02-27 [11471] The value of 【rst】 does not need to be associated --end
/*%if mode == 1 */
and
  extract(dow from A.rst_start_date) = extract(dow from B.rst_start_date)
/*%end*/
order by A.rst_start_date desc
LIMIT /* limitCount */3 OFFSET 0
;