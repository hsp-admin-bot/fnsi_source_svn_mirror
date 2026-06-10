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
  , ord_no
  , coop_ord_no
  , pat_id
  , hosp_pat_id
  , TRIM(dump_path) AS dump_path
  , dump
  , is_editable
  , reg_date
  , up_date
  , is_del
  , user_id
  , temp_content
-- add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  , accept_no
  , ope_cd
  , key0
  , coop_version
-- add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
FROM
  sys_coop_journal
WHERE
/*%if toSkipAnaResult != null*/
  ana_result  in /* toSkipAnaResult */('')
  and
/*%end*/
  coop_result=/* coopResult */''
  and
  direction=/* direction */''
  and
  facility_cd=/* facilityCd */''
  /*%if hospPatId != null*/
  and
  hosp_pat_id=/* hospPatId */''
  /*%end*/
-- add by chamaojia 2023-02-01 [7050] クエリー条件の追加  --start
/*%if ordNo != null*/
  and ord_no=/* ordNo */0
/*%end*/
/*%if patId != null*/
  and pat_id=/* patId */0
/*%end*/
-- add by chamaojia 2023-02-01 [7050] クエリー条件の追加  --start
/*%if crud != null*/
  and crud=/* crud */0
/*%end*/
/*%if coopCd != null && !coopCd.isEmpty() */
  and coop_cd=/* coopCd */''
/*%end*/
-- del #10336 DBが高負荷になる（外部連携由来）2 start
-- --mod 2023-4-14 #8388 #7237 卓 start
-- /*%if crud != null && crud!="D"*/
-- 	and (ord_no,pat_id)
--             in
--         (SELECT ord_no, pat_id
--          from (select count(1) cnt, ord_no, pat_id
--                from sys_coop_journal
--                WHERE ana_result in('9', '0')
--                  and coop_result = '0'
--                  and facility_cd =/* facilityCd */''
--                  and crud =/* crud */0
--                GROUP BY ord_no, pat_id
--                HAVING count(1) > 1) s)
-- /*%end*/
-- del #10336 DBが高負荷になる（外部連携由来）2 end
/*%if ordNo == null && patId == null && hospPatId==null */
AND EXISTS (
SELECT
  1
FROM
-- modify by chamaojia 2023-06-16 [8637] 問合せ条件補充  start
-- modify by chamaojia 2023-05-23 [8637] jsonb関数を使用した解析に変更  --start
  ( SELECT jsonb_array_elements ( ( common_setting :: jsonb ->> 'coop_ord_cd' ) :: jsonb ) AS setting FROM mst_coop_facility WHERE facility_cd = /* facilityCd */'999999' and is_del = '0' ) b
-- modify by chamaojia 2023-05-23 [8637] jsonb関数を使用した解析に変更  --end
-- modify by chamaojia 2023-06-16 [8637] 問合せ条件補充  end
WHERE
  b.setting ->> 'coop_cd' = sys_coop_journal.coop_cd
AND now( ) :: TIMESTAMP + ( COALESCE ( b.setting ->> 'effect_days', '0' ) || ' day' ) :: INTERVAL >= to_date( sys_coop_journal.base_date, 'yyyyMMdd' )
)
/*%end*/
--mod 2023-4-14 #8388 #7237  連携journalが登録されて電文作成に取り掛かるまでが遅い 卓 end
AND
  is_del = '0'
FOR UPDATE