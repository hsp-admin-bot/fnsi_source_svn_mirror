select
  /*%expand "A" */*
from
  ord_main A
where
  A.pat_id in /*patIdList*/(null)
  and A.facility_cd = /*facilityCd*/null
  -- del FNSi6523DWが登録されているのにも関わらず、DWの欄に「未登録」と表示される 周 start
  --and (A.rst_dialysis_state = '0' OR A.rst_dialysis_state = '6')
  -- del FNSi6523DWが登録されているのにも関わらず、DWの欄に「未登録」と表示される 周 end
AND (
   (   treat_date     >= REPLACE(/*startDate*/NULL,'-','')                           -- 治療日
   AND treat_date     <= REPLACE(/*endDate*/NULL,'-',''))                            -- 治療日
OR (   rst_start_date >= TO_TIMESTAMP(/* startDate */null, 'YYYY-MM-DD')::timestamp  -- 実績：治療開始日時
   AND rst_start_date <= TO_TIMESTAMP(/* endDate   */null, 'YYYY-MM-DD')::timestamp) -- 実績：治療開始日時
OR (   rst_end_date   >= TO_TIMESTAMP(/* startDate */null, 'YYYY-MM-DD')::timestamp  -- 実績：治療終了日時
   AND rst_end_date   <= TO_TIMESTAMP(/* endDate   */null, 'YYYY-MM-DD')::timestamp) -- 実績：治療終了日時
)
order by
  A.pat_id, A.treat_date, A.rst_dialysis_state, A.ord_no
;
