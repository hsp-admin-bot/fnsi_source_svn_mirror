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
WHERE 1=1
     AND is_del = '0'
     /*%if journal.facilityCd != null*/
      and facility_cd=/*journal.facilityCd*/''
    /*%end*/
    /*%if journal.coopCd != null*/
      and coop_cd = /*journal.coopCd*/''
    /*%end*/
    /*%if journal.ordNo != null*/
      and ord_no = /*journal.ordNo*/''
    /*%end*/
    /*%if journal.direction != null*/
      and direction = /*journal.direction*/''
    /*%end*/
    /*%if journal.patId != null*/
      and pat_id=/*journal.patId*/''
    /*%end*/
    /*%if journal.hospPatId != null*/
      and hosp_pat_id=/*journal.hospPatId*/''
    /*%end*/
    /*%if journal.coopOrdNo != null*/
      and coop_ord_no=/*journal.coopOrdNo*/''
    /*%end*/
    /*%if journal.anaResult != null*/
      and ana_result in /*journal.anaResult*/('0')
    /*%end*/
    /*%if journal.coopResult != null*/
      and coop_result in /*journal.coopResult*/('0')
    /*%end*/
    /*%if journal.coopVersion != null*/
      and coop_version =/*journal.coopVersion*/''
    /*%end*/
    /*%if journal.regDate != null*/
      and reg_date <=/*journal.regDate*/''
    /*%end*/

