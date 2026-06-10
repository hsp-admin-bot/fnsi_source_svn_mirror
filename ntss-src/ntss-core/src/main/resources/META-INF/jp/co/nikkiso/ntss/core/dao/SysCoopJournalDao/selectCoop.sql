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
-- add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
AND key0 = /* key0 */''
-- add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
AND
  direction = /* direction */''
AND
  ana_result = /* anaResult */''
AND
  coop_result = /* coopResult */''
AND
  coop_cd = /* coop_cd */''
AND
  is_del = '0'
ORDER BY
  ctl_no
