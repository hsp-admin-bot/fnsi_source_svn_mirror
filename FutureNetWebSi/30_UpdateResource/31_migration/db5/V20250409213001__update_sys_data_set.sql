delete FROM "sys_data_set" WHERE sql_cd IN (-307086);

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
            ''CATEGORY_NAME'',
            ''PRESCRIPTION_DETAILS'',
            ''PRESCRIPTION_XML_MEDICINE_INFO'',
            ''PRESCRIPTION_XML_INJECTION_INFO'',
            ''PRESCRIPTION_XML_TREATMENT_INFO'',
            ''PRESCRIPTION_XML_SURGERY_INFO'',
            ''PRESCRIPTION_XML_OXYGEN_INFO'',
            ''PRESCRIPTION_XML_RECE_HOLI_INFO'',
            ''PRESCRIPTION_XML_RECE_DIAL_INFO'',
            ''PRESCRIPTION_XML_RECE_MNG_INFO''
        )
)
SELECT
    (SELECT value FROM all_values WHERE key1 = ''PRES_XML_BASIC_INFO'' AND key2 = ''S_VERSION'') AS s_version,
    (SELECT value FROM all_values WHERE key1 = ''PRES_XML_BASIC_INFO'' AND key2 = ''DEVICE_IDENTIFIER'') AS device_identifier,
    (SELECT value FROM all_values WHERE key1 = ''PRES_XML_BASIC_INFO'' AND key2 = ''VISIT_CATEGORY'') AS visit_category,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''MEDICINE'') AS category_name_medicine,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''INJECTION'') AS category_name_injection,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''TREATMENT'') AS category_name_treatment,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''HOLIDAY'') AS category_name_holiday,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''DIALYSIS'') AS category_name_dialysis,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''CONSULTATION'') AS category_name_consultation,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''SURGERY'') AS category_name_surgery,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''EXAMINATION'') AS category_name_examination,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''ORAL'') AS prescription_details_oral,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''PRN'') AS prescription_details_prn,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''EXTERNAL'') AS prescription_details_external,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''SELF_INJECTION'') AS prescription_details_self_injection,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''IV_INJECTION'') AS prescription_details_iv_injection,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''IM_INJECTION'') AS prescription_details_im_injection,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''ID_INJECTION'') AS prescription_details_id_injection,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''SC_INJECTION'') AS prescription_details_sc_injection,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''IV_DRIP'') AS prescription_details_iv_drip,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''CUSTOM_MADE_MEDICATION'') AS prescription_details_custom_made_medication,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''TREATMENT'') AS prescription_details_treatment,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''OXYGEN'') AS prescription_details_oxygen,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''HOLIDAY'') AS prescription_details_holiday,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''DIALYSIS'') AS prescription_details_dialysis,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''CONSULTATION'') AS prescription_details_consultation,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''SURGERY'') AS prescription_details_surgery,
    LPAD(@ordNo || (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_MEDICINE_INFO'' AND key2 = ''ORDER_UNITS_ID_00''), 10, ''0'') AS order_units_id_00,
    LPAD(@ordNo || (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_MEDICINE_INFO'' AND key2 = ''ORDER_UNITS_ID_01''), 10, ''0'') AS order_units_id_01,
    LPAD(@ordNo || (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_MEDICINE_INFO'' AND key2 = ''ORDER_UNITS_ID_02''), 10, ''0'') AS order_units_id_02,
    LPAD(@ordNo || (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_MEDICINE_INFO'' AND key2 = ''ORDER_UNITS_ID_03''), 10, ''0'') AS order_units_id_03,
    LPAD(@ordNo || (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_INJECTION_INFO'' AND key2 = ''ORDER_UNITS_ID_20''), 10, ''0'') AS order_units_id_20,
    LPAD(@ordNo || (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_INJECTION_INFO'' AND key2 = ''ORDER_UNITS_ID_21''), 10, ''0'') AS order_units_id_21,
    LPAD(@ordNo || (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_INJECTION_INFO'' AND key2 = ''ORDER_UNITS_ID_22''), 10, ''0'') AS order_units_id_22,
    LPAD(@ordNo || (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_INJECTION_INFO'' AND key2 = ''ORDER_UNITS_ID_23''), 10, ''0'') AS order_units_id_23,
    LPAD(@ordNo || (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_INJECTION_INFO'' AND key2 = ''ORDER_UNITS_ID_24''), 10, ''0'') AS order_units_id_24,
    LPAD(@ordNo || (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_INJECTION_INFO'' AND key2 = ''ORDER_UNITS_ID_25''), 10, ''0'') AS order_units_id_25,
    LPAD(@ordNo || (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_TREATMENT_INFO'' AND key2 = ''ORDER_UNITS_ID''), 10, ''0'') AS order_units_id_treatment,
    LPAD(@ordNo || (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_SURGERY_INFO'' AND key2 = ''ORDER_UNITS_ID''), 10, ''0'') AS order_units_id_surgery,
    LPAD(@ordNo || (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_OXYGEN_INFO'' AND key2 = ''ORDER_UNITS_ID''), 10, ''0'') AS order_units_id_oxygen,
    LPAD(@ordNo || (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_RECE_HOLI_INFO'' AND key2 = ''ORDER_UNITS_ID''), 10, ''0'') AS order_units_id_rece_holi,
    LPAD(@ordNo || (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_RECE_DIAL_INFO'' AND key2 = ''ORDER_UNITS_ID''), 10, ''0'') AS order_units_id_rece_dial
',2,'[]','0','{"applications": [4]}',NULL,NULL,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);
