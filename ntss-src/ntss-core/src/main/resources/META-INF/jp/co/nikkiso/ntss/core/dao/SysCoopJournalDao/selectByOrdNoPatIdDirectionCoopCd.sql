SELECT
    facility_cd
  , ctl_no
  , coop_cd
  , TRIM(coop_cd_index) AS coop_cd_index
-- add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  , coop_version
-- add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
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
FROM
  sys_coop_journal
WHERE
  ord_no = /* ordNo */''
  and
  pat_id= /* patId */''
  and
  direction=/* direction */''
  and
  coop_cd=/* coopCd */''
  and
  facility_cd=/* facilityCd */''
-- add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  and coop_version =/* coopVersion */''
-- add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  and
  coop_result in /* coopResultList */('0')
AND
  is_del = '0'
