--#8350  add ini_dial連携受信時のprofile連携（要求）が処理されず患者属性の更新ができないことがある 卓 2023-04-26 start
SELECT
count(1)
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
  and ord_no=/* ordNo */0
/*%end*/
/*%if patId != null*/
  and pat_id=/* patId */0
/*%end*/
  -- add by chamaojia 2023-02-01 [7050] クエリー条件の追加  --end
AND
  is_del = '0'
/*%if direction == "S" */
AND EXISTS (
-- mod #6174 連携失敗通知が大量発生でサーバがダウン start
SELECT
  1
        FROM (
            SELECT max(dd) AS dd , coop_cd FROM (
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
--#8350  add ini_dial連携受信時のprofile連携（要求）が処理されず患者属性の更新ができないことがある 卓 2023-04-26 end

