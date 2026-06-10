select
  A.pat_id,
  A.ord_no,
  A.result_exam_date,
  A.exam_result_info,
  A.reg_order_class,
  A.up_date
from pat_exam_main A
where
  A.pat_id in /* patIdList */(null)
  and A.facility_cd = /*facilityCd*/null
  and A.exam_result_info is not null
  and A.is_del = '0'
 AND (
       (   A.reg_exam_date    >= TO_TIMESTAMP(/* startDate */null, 'YYYY-MM-DD')::timestamp  -- 登録時検査日時
       --mod FNSI-7676 【デグレ】抽出期間の不正 劉全航 start
       -- AND A.reg_exam_date    <= TO_TIMESTAMP(/* endDate   */null, 'YYYY-MM-DD')::timestamp) -- 登録時検査日時
       AND A.reg_exam_date    <= TO_TIMESTAMP(/* endDate   */null, 'YYYY-MM-DD HH24:MI:SS')::timestamp)
       --mod FNSI-7676 【デグレ】抽出期間の不正 劉全航 end
    OR (   A.result_exam_date >= TO_TIMESTAMP(/* startDate */null, 'YYYY-MM-DD')::timestamp  -- 結果時検査日時
       --mod FNSI-7676 【デグレ】抽出期間の不正 劉全航 start
       -- AND A.result_exam_date <= TO_TIMESTAMP(/* endDate   */null, 'YYYY-MM-DD')::timestamp) -- 結果時検査日時
       AND A.result_exam_date <= TO_TIMESTAMP(/* endDate   */null, 'YYYY-MM-DD HH24:MI:SS')::timestamp)
       --mod FNSI-7676 【デグレ】抽出期間の不正 劉全航 end
   )
-- add FNSI6516-テンプレート：検査結果の表示順不正 周 start
ORDER BY
  pat_id,
  up_date
-- add FNSI6516-テンプレート：検査結果の表示順不正 周 end
;
