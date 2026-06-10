delete from "sys_data_set" where "sql_cd" in (9309,9308,9305);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9309, 'WITH data_nec AS ( 
  SELECT
    ''Rp'' || ''@prescriptionDetail.rp'' AS rp
    , TO_NUMBER( COALESCE(NULLIF(''@prescriptionDetail.quantity'', ''''), ''0''), ''FM99'') AS f5
    , ''@prescriptionDetail.medicineCode'' AS medicine_cd
) 
, data_nec_json AS ( 
  SELECT
    json_build_object( 
      ''R'', COALESCE(med.medicine_name, ''不明'')
      , ''F1'', COALESCE(med.medicine_name, ''不明'')
      , ''F2'', ''''
      , ''F3'', ''''
      , ''F4'', ''''
      , ''F5'', nec.F5
      , ''F6'', COALESCE(med.unit, '''')
      , ''Rp'', nec.Rp
      , ''type'', 1
      , ''unchg'', ''''
      , ''medicine_cd'', COALESCE(med.medicine_cd, 0)
      , ''medicine_type'', ''''
      , ''medicine_unit1'', COALESCE(med.unit, '''')
      , ''medicine_unit2'', COALESCE(med.unit_second, '''')
    ) AS json_one 
  FROM
    data_nec AS nec
    LEFT OUTER JOIN mst_medicine AS med ON med.is_del = ''0'' AND med.facility_cd = ''@facilityCd'' AND med.in_hospital_cd_1 = nec.medicine_cd:: TEXT
) 
, prescription_detail_new AS ( 
  SELECT
    CASE 
      WHEN COALESCE(NULLIF(prescription_detail, NULL), ''[]'') = ''[]'' 
        THEN ''{"R": "────────以下、余白─────────", "F1": "", "F2": "", "F3": "", "F4": "", "F5": "", "F6": "", "Rp": "", "type": "E", "unchg": "", "medicine_cd": "", "medicine_type": ""}''
      ELSE jsonb_array_elements(prescription_detail) 
      END AS prescription_detail 
  FROM
    ord_prescription 
  WHERE
    is_del = ''0'' 
    AND prescription_type = ''2'' 
    AND pat_id = @patId 
    AND facility_cd = ''@facilityCd'' 
    AND issue_date = ''@issueDate'' 
    AND ord_prescription_no = @ordPrescriptionNo 
  UNION 
  SELECT
    json_one ::JSONB AS prescription_detail 
  FROM
    data_nec_json
) 
, prescription_detail_new_sort AS ( 
  SELECT
    prescription_detail 
  FROM
    prescription_detail_new 
  ORDER BY
    NULLIF(prescription_detail ->> ''Rp'', '''') ASC NULLS LAST
    , prescription_detail ->> ''Type'' ASC
) 
, prescriptionDetailInfo AS ( 
  SELECT
    array_to_json(ARRAY_AGG(prescription_detail)) AS prescription_detail_new 
  FROM
    prescription_detail_new_sort
) 
UPDATE ord_prescription 
SET
  prescription_detail = COALESCE( 
    NULLIF( 
      ( 
        SELECT
          prescription_detail_new 
        FROM
          prescriptionDetailInfo
      ) ::TEXT
      , ''''
    ) 
    , ''[]''
  ) ::JSONB 
WHERE
  is_del = ''0'' 
  AND prescription_type = ''2'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND issue_date = ''@issueDate'' 
  AND ord_prescription_no = @ordPrescriptionNo
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NEC処方情報連携の処方情報(処方詳細の薬剤部分)の新規登録(ord_prescription)', '2021-11-23 12:12:12', '2021-11-23 12:12:12', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9308, 'WITH data_nec AS ( 
  SELECT
    ''Rp'' || ''@prescriptionDetail.rp'' AS rp
    , TO_NUMBER( COALESCE(NULLIF(''@prescriptionDetail.period'', ''''), ''0''), ''FM99'') AS f5
    , ''@prescriptionDetail.dosageName'' AS f1
) 
, data_nec_json AS ( 
  SELECT
    json_build_object( 
      ''R'', nec.F1
      , ''F1'', nec.F1
      , ''F2'', ''''
      , ''F3'', ''''
      , ''F4'', ''''
      , ''F5'', nec.F5
      , ''F6'', ''日分''
      , ''Rp'', nec.Rp
      , ''type'', 2
      , ''unchg'', ''''
      , ''medicine_unit1'', ''''
      , ''medicine_unit2'', ''''
    ) AS json_one 
  FROM
    data_nec AS nec
) 
, prescription_detail_new AS ( 
  SELECT
    CASE 
      WHEN COALESCE(NULLIF(prescription_detail, NULL), ''[]'') = ''[]'' 
        THEN ''{"R": "────────以下、余白─────────", "F1": "", "F2": "", "F3": "", "F4": "", "F5": "", "F6": "", "Rp": "", "type": "E", "unchg": "", "medicine_cd": "", "medicine_type": ""}''
      ELSE jsonb_array_elements(prescription_detail) 
      END AS prescription_detail 
  FROM
    ord_prescription 
  WHERE
    is_del = ''0'' 
    AND prescription_type = ''2'' 
    AND pat_id = @patId 
    AND facility_cd = ''@facilityCd'' 
    AND issue_date = ''@issueDate'' 
    AND ord_prescription_no = @ordPrescriptionNo 
  UNION 
  SELECT
    json_one ::JSONB AS prescription_detail 
  FROM
    data_nec_json
) 
, prescription_detail_new_sort AS ( 
  SELECT
    prescription_detail 
  FROM
    prescription_detail_new 
  ORDER BY
    NULLIF(prescription_detail ->> ''Rp'', '''') ASC NULLS LAST
    , prescription_detail ->> ''Type'' ASC
) 
, prescriptionDetailInfo AS ( 
  SELECT
    array_to_json(ARRAY_AGG(prescription_detail)) AS prescription_detail_new 
  FROM
    prescription_detail_new_sort
) 
UPDATE ord_prescription 
SET
  prescription_detail = COALESCE( 
    NULLIF( 
      ( 
        SELECT
          prescription_detail_new 
        FROM
          prescriptionDetailInfo
      ) ::TEXT
      , ''''
    ) 
    , ''[]''
  ) ::JSONB 
WHERE
  is_del = ''0'' 
  AND prescription_type = ''2'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND issue_date = ''@issueDate'' 
  AND ord_prescription_no = @ordPrescriptionNo
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NEC処方情報連携の処方情報(処方詳細の用法部分)の新規登録(ord_prescription)', '2021-11-23 12:12:12', '2021-11-23 12:12:12', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9305, 'INSERT INTO ord_prescription( 
  facility_cd
  , pat_id
  , prescription_type
  , issue_date
  , issue_state
  , expiration_date
  , prescription_detail
  , is_disp
  , is_del
  , reg_date
  , up_date 
) 
VALUES (
  ''@facilityCd''
  , @patId
  , ''@prescriptionType''
  , ''@issueDate''
  , ''@issueState''
  , ''@expirationDate''
  , ''@prescriptionDetailValue''
  , ''1''
  , ''0''
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NEC処方情報連携の処方情報の新規登録(ord_prescription)', '2020-05-25 18:21:40.841', '2020-05-25 18:21:40.841', NULL);
