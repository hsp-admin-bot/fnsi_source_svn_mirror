DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307086;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307139;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307140;

INSERT INTO ntss.sys_data_set (sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
	 (-307086,'WITH all_values AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
        info ->> ''key1'' AS key1,
        info ->> ''key2'' AS key2
    FROM mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' IN (
            ''PRES_XML_BASIC_INFO'',
            ''PRESCRIPTION_INFO'',
            ''CATEGORY_NAME'',
            ''PRESCRIPTION_DETAILS'',
            ''PRESCRIPTION_XML_TREATMENT_INFO'',
            ''PRESCRIPTION_XML_OXYGEN_INFO'',
            ''PRESCRIPTION_XML_RECE_HOLI_INFO'',
            ''PRESCRIPTION_XML_RECE_DIAL_INFO''
        )
)
SELECT
    (SELECT value FROM all_values WHERE key1 = ''PRES_XML_BASIC_INFO'' AND key2 = ''S_VERSION'') AS s_version,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_INFO'' AND key2 = ''MODEL_TYPE'') AS device_identifier,
    (SELECT value FROM all_values WHERE key1 = ''PRES_XML_BASIC_INFO'' AND key2 = ''VISIT_CATEGORY'') AS visit_category,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''MEDICINE'') AS category_name_medicine,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''INJECTION'') AS category_name_injection,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''TREATMENT'') AS category_name_treatment,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''HOLIDAY'') AS category_name_holiday,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''DIALYSIS'') AS category_name_dialysis,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''CONSULTATION'') AS category_name_consultation,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''SURGERY'') AS category_name_surgery,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''EXAMINATION'') AS category_name_examination,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''TREATMENT'') AS prescription_details_treatment,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''OXYGEN'') AS prescription_details_oxygen,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''HOLIDAY'') AS prescription_details_holiday,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''DIALYSIS'') AS prescription_details_dialysis,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''CONSULTATION'') AS prescription_details_consultation,
    LPAD(@ordNo || (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_TREATMENT_INFO'' AND key2 = ''ORDER_UNITS_ID''), 10, ''0'') AS order_units_id_treatment,
    LPAD(@ordNo || (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_OXYGEN_INFO'' AND key2 = ''ORDER_UNITS_ID''), 10, ''0'') AS order_units_id_oxygen,
    LPAD(@ordNo || (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_RECE_HOLI_INFO'' AND key2 = ''ORDER_UNITS_ID''), 10, ''0'') AS order_units_id_rece_holi,
    LPAD(@ordNo || (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_RECE_DIAL_INFO'' AND key2 = ''ORDER_UNITS_ID''), 10, ''0'') AS order_units_id_rece_dial
',2,'[]','0','{"applications": [4]}',NULL,NULL,'2025-04-14 09:28:09.234',CURRENT_TIMESTAMP,NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307139, 'select
  @modelType || 
  ''_'' ||
  ppm.hosp_pat_id ||
  ''_'' ||
  @rstStartDate ||
  ''_'' ||
  to_char(current_timestamp, ''YYYYMMDDHH24MISS_'') ||
  ''0001'' ||
  ''.xml'' as filename
from
  ntss.pat_personal_main as ppm
where
  pat_id = @patId', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 新規/更新 ファイル名取得用', current_timestamp, current_timestamp, '[{"sql_cd": -307140, "field_name": "rst_start_date", "replace_var": "@rstStartDate"}, {"sql_cd": -307140, "field_name": "model_type", "replace_var": "@modelType"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307140, 'with model_type as (
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) as info
    where ini.facility_cd = @facilityCd
        and ini.is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_INFO''
        and info->>''key2'' = ''MODEL_TYPE''
)

select
  to_char(ord.rst_start_date,''YYYYMMDDHH24MISS'') as rst_start_date,--透析開始日時
  (select value from model_type) as model_type--モデルタイプ
from
  ord_main as ord
where
  ord.ord_no = @ordNo', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, current_timestamp, current_timestamp, NULL);