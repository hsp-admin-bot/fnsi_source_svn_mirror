UPDATE sys_coop_journal
SET ana_result = 'S',
    in_ana_date = CURRENT_TIMESTAMP,
    out_ana_date = CURRENT_TIMESTAMP,
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
WHERE facility_cd = /* scjParam.facilityCd */''
AND key0 = /* scjParam.key0 */''
AND direction = 'S'
AND pat_id = /* scjParam.patId */0
AND ord_no = /* scjParam.ordNo */0
AND coop_cd = /* scjParam.coopCd */''
AND coop_cd_index = /* scjParam.coopCdIndex */''
AND coop_version = /* scjParam.coopVersion */''
AND crud = /* scjParam.crud */''
;
