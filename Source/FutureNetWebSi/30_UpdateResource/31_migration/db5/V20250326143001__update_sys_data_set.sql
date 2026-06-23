DELETE FROM sys_data_set WHERE sql_cd IN (-500089);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500089, 'WITH bed_used_check AS (
SELECT CASE WHEN EXISTS (
  SELECT
    1
  FROM
    ord_main
  WHERE
    facility_cd = ''@facilityCd''
    AND treat_date = ''@treatDate''
    AND ind_kur_cd::text = ''@indKurCd''
    AND ind_kur_cd <> 0
    AND ind_bed_cd::text = ''@indBedCd''
    AND ord_no <> @ordNo
    AND is_del = ''0''
    )
    THEN ''0''
    ELSE ''@indBedCd''
    END AS bed_cd
  )
UPDATE ord_main 
SET
    ind_bed_cd = TO_NUMBER((SELECT bed_cd FROM bed_used_check), ''999999999999999999'')
  , up_date = CURRENT_TIMESTAMP 
  , up_user_id = CASE ''@userId'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@userId'', ''999999999999999999'') 
    END
WHERE
  ord_no = @ordNo', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受けベッド入れ替え処理用(UPDATE)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -500012, "field_name": "ind_bed_cd", "replace_var": "@indBedCd"}, {"sql_cd": -500082, "field_name": "kur_cd", "replace_var": "@indKurCd"}, {"sql_cd": -500086, "field_name": "user_id", "replace_var": "@userId"}]'::jsonb);