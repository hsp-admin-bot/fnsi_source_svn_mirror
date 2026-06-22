SELECT
 facility_cd
  , ctl_no
  , coop_cd
  ,  coop_cd_index
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
  , dump_path
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
 from(
(SELECT
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
  coop_result='0'
  and
  direction='S'
  and
  facility_cd=/* facilityCd */'999998'
  /*%if ordNo != null*/
  and ord_no=/* ordNo */0
/*%end*/
/*%if patId != null*/
  and pat_id=/* patId */0
/*%end*/
AND
  is_del = '0')  a
	LEFT JOIN
	(
	SELECT
  t.facility_cd as ofacility_cd,
	t.pat_id as opat_id,
	t.hosp_pat_id as ohosp_pat_id,
	t.ord_no as oord_no,
	t.coop_cd as ocoop_cd,
	t.coop_version  as ocoop_version
FROM
  ord_coop_no t
WHERE
  is_del = '0'
and
  facility_cd=/* facilityCd */'999998'
GROUP BY t.facility_cd,t.pat_id,t.hosp_pat_id,t.ord_no,t.coop_cd,t.coop_version) o
	ON  a.facility_cd=o.ofacility_cd
	AND a.pat_id=o.opat_id
	AND a.hosp_pat_id=o.ohosp_pat_id
	AND a.ord_no=o.oord_no
	AND a.coop_cd=o.ocoop_cd
	AND a.coop_version=o.ocoop_version

) where ofacility_cd ISNULL
