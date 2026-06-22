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
  , accept_no
  , ope_cd
  , key0
  , coop_version
FROM
  sys_coop_journal
WHERE
  ctl_no in /* ctlNoList */(0)
AND
  is_del = '0'
