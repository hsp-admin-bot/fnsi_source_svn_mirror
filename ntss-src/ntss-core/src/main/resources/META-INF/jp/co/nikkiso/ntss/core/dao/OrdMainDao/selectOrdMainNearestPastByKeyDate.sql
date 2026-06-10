--  add #11276 キー日付に対するデータ引き当て仕様対応 高　start
select ord_no
from ord_main
where pat_id = /*patId*/0
  and treat_date <= /*fromDate*/''
  and facility_cd = /*facilityCd*/''
  and rst_dialysis_state !='0'
order by treat_date desc,ord_no desc
  limit 1;
--  add #11276 キー日付に対するデータ引き当て仕様対応 高　end
