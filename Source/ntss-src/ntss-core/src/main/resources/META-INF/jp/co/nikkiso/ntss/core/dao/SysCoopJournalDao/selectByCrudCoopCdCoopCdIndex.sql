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
  crud=/*crud*/''
  and
  coop_cd=/* coopCd */''
  and
  coop_cd_index=/* coopCdIndex */''
  and
  ord_no = /* ordNo */''
  and
  pat_id= /* patId */''
  and
  direction=/* direction */''
  and
  facility_cd=/* facilityCd */''
  and
  coop_version= /* coopVersion */''
  and
  ana_result in /* anaResult */('')
  and
  coop_result= /* coopResult */''
    /*%if regDate != null*/
    and reg_date <=/*regDate*/''
    /*%end*/
--   and reg_date<=/*regDate*/0
    AND
      is_del = '0'
  order by ctl_no desc
