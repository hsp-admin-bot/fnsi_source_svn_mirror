SELECT
    facility_cd
  , ctl_no
  , coop_cd
  , TRIM(coop_cd_index) AS coop_cd_index
  , crud
  , direction
  , ana_result
  , base_date
  , out_reg_date
  , out_ana_date
  , coop_result
  , in_reg_date
  , in_ana_date
  , TRIM(dump_path) AS dump_path
  , dump
  , is_editable
  , reg_date
  , up_date
  , is_del
  , pat_id
  , ord_no
  , coop_ord_no
  , hosp_pat_id
  , report_cd
  , user_id
-- add #5890:Medicom連携ができない(検査オーダ(exam_ord)) 孫 start
  , accept_no
  , ope_cd
-- add #5890:Medicom連携ができない(検査オーダ(exam_ord)) 孫 end
-- add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  , key0
  , coop_version
-- add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
FROM
  sys_coop_journal
WHERE
  facility_cd = /* facilityCd */'999999'
AND
  direction = /* direction */''
AND
  ana_result = /* anaResult */''
AND
  coop_result = /* coopResult */''
-- add by chamaojia 2023-01-10 [7050] クエリー条件の追加  --start
/*%if ctlNoList.size() > 0 */
AND
  ctl_no IN /*ctlNoList*/(0)
/*%end*/
-- add by chamaojia 2023-01-10 [7050] クエリー条件の追加  --end
-- add by chamaojia 2023-02-01 [7050] クエリー条件の追加  --start
/*%if ordNo != null*/
  AND ord_no=/* ordNo */0
/*%end*/
/*%if patId != null*/
  AND pat_id=/* patId */0
/*%end*/
  -- add by chamaojia 2023-02-01 [7050] クエリー条件の追加  --end
AND
  is_del = '0'
/*%if direction == "S" */
-- mod #6174 連携失敗通知が大量発生でサーバがダウン start
AND EXISTS (
SELECT
  1
        FROM (
            SELECT MAX(dd) AS dd , coop_cd FROM (
                SELECT now( ) :: TIMESTAMP + ( COALESCE ( b.setting ->> 'effect_days', '0' ) || ' day' ) :: INTERVAL dd, b.setting ->> 'coop_cd' coop_cd FROM (
                   SELECT json_array_elements ( ( common_setting :: json ->> 'coop_ord_cd' ) :: json ) AS setting FROM mst_coop_facility WHERE facility_cd = /* facilityCd */'999999' AND is_del = '0'
                ) b
            ) cc GROUP BY coop_cd 
        ) bb
WHERE
          bb.coop_cd = sys_coop_journal.coop_cd
        AND bb.dd >= TO_DATE( sys_coop_journal.base_date, 'yyyyMMdd' )
)
-- mod #6174 連携失敗通知が大量発生でサーバがダウン end
/*%end*/
ORDER BY
  ctl_no
