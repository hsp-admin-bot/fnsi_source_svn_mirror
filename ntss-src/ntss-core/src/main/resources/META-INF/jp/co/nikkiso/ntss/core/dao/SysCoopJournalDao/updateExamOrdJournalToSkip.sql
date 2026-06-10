--Add for #6993-profile連携で受信した生存の有無登録 周 20230204
UPDATE sys_coop_journal
--mod by #8744 既にスキップと判断されているexam_ordのイベントがprofileの定時処理で処理されてup_dateが更新される lmf 2023-06-02 start
SET ana_result =
      CASE
        WHEN ana_result = '0' or ana_result = 'H' THEN
          'S' ELSE ana_result
        END,
    in_ana_date =
      CASE
        WHEN ana_result = '0' or ana_result = 'H' THEN
            CURRENT_TIMESTAMP ELSE in_ana_date
        END,
    out_ana_date =
      CASE
        WHEN ana_result = '0' or ana_result = 'H' THEN
            CURRENT_TIMESTAMP ELSE out_ana_date
        END,
    coop_result =
      CASE
        WHEN ana_result = '9' THEN
          'S' ELSE coop_result
        END,
    in_reg_date =
      CASE
        WHEN ana_result = '9' THEN
            CURRENT_TIMESTAMP ELSE in_reg_date
        END,
    out_reg_date =
      CASE
        WHEN ana_result = '9' THEN
            CURRENT_TIMESTAMP ELSE out_reg_date
        END,
    up_date = CURRENT_TIMESTAMP
    --ana_result = 'S', coop_result = 'S', up_date = now()
--mod by #8744 既にスキップと判断されているexam_ordのイベントがprofileの定時処理で処理されてup_dateが更新される lmf 2023-06-02 end
WHERE facility_cd = /* scjParam.facilityCd */''
AND key0 = /* scjParam.key0 */''
AND direction = 'S'
AND pat_id = /* scjParam.patId */0
AND ord_no = /* scjParam.ordNo */0
AND coop_cd = /* scjParam.coopCd */''
AND coop_version = /* scjParam.coopVersion */''
AND (ana_result = 'H' OR coop_result = '0')
;
