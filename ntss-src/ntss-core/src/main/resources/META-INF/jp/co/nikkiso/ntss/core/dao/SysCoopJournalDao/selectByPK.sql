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
--add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 start
  , temp_content
--add add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 end
-- add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  , accept_no
  , ope_cd
  , key0
  , coop_version
-- add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  , retry_cnt
FROM
  sys_coop_journal
WHERE
  ctl_no = /* ctlNo */''
AND
  is_del = '0'
