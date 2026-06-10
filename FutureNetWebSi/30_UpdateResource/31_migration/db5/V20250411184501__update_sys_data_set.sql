DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (
	-307128,-307129
	);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307128, ' SELECT 1 FROM pat_personal_main
WHERE
  pat_id = @patId
  AND facility_cd = @facilityCd
  AND NOT(
    in_out_class = 1
    -- 入院対応使用有無 0:使用しない 1:使用する,入院患者処方データ出力有無 0：出力しない　1：出力する
    AND @admissionSupported = 1
    AND @inPatientOutputSet = 0
  );', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入院患者の制御', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307129, "field_name": "admission_supported", "replace_var": "@admissionSupported"}, {"sql_cd": -307129, "field_name": "in_patient_output_set", "replace_var": "@inPatientOutputSet"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307129, 'WITH admission_supported AS(
    SELECT
        COALESCE(
            NULLIF(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) AS value
    FROM
        ntss.mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''KARTE_ORD_SEND''
        AND info ->> ''key2'' = ''ADMISSION_SUPPORTED''
),
in_patient_output_set AS(
    SELECT
        COALESCE(
            NULLIF(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) AS value
    FROM
        ntss.mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''PRESCRIPTION_INFO''
        AND info ->> ''key2'' = ''IN_PATIENT_OUTPUT_SET''
)

SELECT 
	(SELECT value FROM admission_supported) as admission_supported,
	(SELECT value FROM in_patient_output_set) as in_patient_output_set', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入院患者の制御', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);