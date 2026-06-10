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
    /*%if isOnlyRst */
  AND A.rst_dialysis_state in ('1','2','3', '4', '5', '6')
    /*%else*/
  -- mod #10076 データリストで実績がある場合に表示されない zrx start
  -- AND A.rst_dialysis_state = '0'
  AND A.rst_dialysis_state in ('0','1','2','3', '4', '5', '6')
  -- mod #10076 データリストで実績がある場合に表示されない zrx end
    /*%end*/
order by
    A.pat_id, A.treat_date, A.rst_dialysis_state, A.ord_no
    --del #11034 データリストにてテンプレートに「治療予定・治療記録」をつかっているレイアウトでは最大50件までしか表示されない start
--     limit /*limit*/0
-- offset /*offset*/0
--del #11034 データリストにてテンプレートに「治療予定・治療記録」をつかっているレイアウトでは最大50件までしか表示されない end
;
