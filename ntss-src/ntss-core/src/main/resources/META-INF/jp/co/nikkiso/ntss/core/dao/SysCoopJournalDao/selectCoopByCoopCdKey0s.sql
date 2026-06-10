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
  , accept_no
  , ope_cd
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
-- add by chamaojia 2023-05-22 検査結果1 file多患者受信時のデータ分割処理とIFedgeファイル移動処理の競合   --start
/*%if ctlNoList.size() > 0 */
AND
  ctl_no IN /*ctlNoList*/(0)
/*%end*/
-- add by chamaojia 2023-05-22 検査結果1 file多患者受信時のデータ分割処理とIFedgeファイル移動処理の競合   --end
  --  upd #8567 （#8179问题调查结果）外部連携全般に必要な機能が制限されている改正 ztc 0508 start
-- AND
-- /*%if coopCdsAndKey0s != null && coopCdsAndKey0s.size() != 0*/
--     /*%for  item : coopCdsAndKey0s*/
--     ( coop_cd = /* item.coopCd */'' AND key0 = /* item.key0 */'' )
--     /*%if item_has_next */
--         /*# "or" */
--     /*%end*/
--     /*%end*/
-- /*%end*/
  --  upd #8567 （#8179问题调查结果）外部連携全般に必要な機能が制限されている改正 ztc 0508 end
AND
  is_del = '0'
ORDER BY
  ctl_no
