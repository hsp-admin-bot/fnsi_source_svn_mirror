--Add for #6993-profile連携で受信した生存の有無登録 周 20230204
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
     is_del = '0'
     /*%if journal.facilityCd != null*/
      AND facility_cd=/*journal.facilityCd*/''
    /*%end*/
    /*%if journal.direction != null*/
      AND direction = /*journal.direction*/''
    /*%end*/
    /*%if journal.coopCd != null*/
      AND coop_cd = /*journal.coopCd*/''
    /*%end*/
    /*%if journal.ordNo != null*/
      AND ord_no = /*journal.ordNo*/0
    /*%end*/
    /*%if journal.patId != null*/
      AND pat_id=/*journal.patId*/0
    /*%end*/
    --mod by #8744 既にスキップと判断されているexam_ordのイベントがprofileの定時処理で処理されてup_dateが更新される lmf 2023-06-02 start
  --AND (ana_result = 'H' OR coop_result IN ('0', 'S'))
  AND
  (
      (ana_result = 'H' AND coop_result = '0')
      OR
      (ana_result = '9' AND coop_result = '0')
    )
  --mod by #8744 既にスキップと判断されているexam_ordのイベントがprofileの定時処理で処理されてup_dateが更新される lmf 2023-06-02 end
    /*%if journal.coopVersion != null*/
      AND coop_version =/*journal.coopVersion*/''
    /*%end*/
;
