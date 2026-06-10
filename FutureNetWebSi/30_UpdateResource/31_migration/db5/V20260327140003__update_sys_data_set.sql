DELETE FROM ntss.sys_data_set WHERE sql_cd=-604182;
DELETE FROM ntss.sys_data_set WHERE sql_cd=-604183;
DELETE FROM ntss.sys_data_set WHERE sql_cd=-604184;
DELETE FROM ntss.sys_data_set WHERE sql_cd=-604185;
DELETE FROM ntss.sys_data_set WHERE sql_cd=-604186;
DELETE FROM ntss.sys_data_set WHERE sql_cd=-604187;
DELETE FROM ntss.sys_data_set WHERE sql_cd=-604188;
DELETE FROM ntss.sys_data_set WHERE sql_cd=-604189;
DELETE FROM ntss.sys_data_set WHERE sql_cd=-604190;
DELETE FROM ntss.sys_data_set WHERE sql_cd=-604191;
DELETE FROM ntss.sys_data_set WHERE sql_cd=-604192;
DELETE FROM ntss.sys_data_set WHERE sql_cd=-604193;
DELETE FROM ntss.sys_data_set WHERE sql_cd=-604194;
DELETE FROM ntss.sys_data_set WHERE sql_cd=-604195;
DELETE FROM ntss.sys_data_set WHERE sql_cd=-604196;
DELETE FROM ntss.sys_data_set WHERE sql_cd=-604197;

INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-604182, '-- 【SQL_CD=-604182】
WITH latest_journal AS (
    SELECT convert_from(dump, ''SJIS'')::xml AS dump_xml
    FROM sys_coop_journal
    WHERE facility_cd = @facilityCd
        AND ord_no = @ordNo
        AND pat_id = @patId
        AND coop_cd = ''rst_dial''
        AND crud in (''C'', ''U'')
        AND ana_result = ''9''
        AND coop_result = ''9''
        AND ctl_no < @ctlNo
    ORDER BY ctl_no DESC
    LIMIT 1
)
SELECT
    (xpath(''//PAT_BASIC_INFO/DISP_PATID/text()'', dump_xml))[1]::text          AS disp_pat_id,
    (xpath(''//PAT_BASIC_INFO/PATID/text()'', dump_xml))[1]::text                AS pat_id,
    (xpath(''//PAT_BASIC_INFO/NAME/text()'', dump_xml))[1]::text                 AS pat_name,
    (xpath(''//PAT_BASIC_INFO/DOCTOR_CD1/text()'', dump_xml))[1]::text           AS doctor_cd1,
    (xpath(''//PAT_BASIC_INFO/DOCTOR_CD2/text()'', dump_xml))[1]::text           AS doctor_cd2,
    (xpath(''//PAT_BASIC_INFO/MST_PAT_GROUP/IN_HOSPITAL_CD/text()'', dump_xml))[1]::text  AS pat_group_in_hospital_cd,
    (xpath(''//PAT_BASIC_INFO/DIAL_START_DATE/text()'', dump_xml))[1]::text      AS dial_start_date,
    (xpath(''//PAT_BASIC_INFO/DIAL_DIFF/text()'', dump_xml))[1]::text            AS dial_diff,
    (xpath(''//PAT_BASIC_INFO/MST_DIAL_DIFF_COMENT/DIAL_DIFF_COMMENT/text()'', dump_xml))[1]::text  AS dial_diff_comment,
    (xpath(''//PAT_BASIC_INFO/INOUT_FLG/text()'', dump_xml))[1]::text            AS in_out_class,
    (xpath(''//PAT_BASIC_INFO/MST_WARD/IN_HOSPITAL_CD/text()'', dump_xml))[1]::text       AS ward_in_hospital_cd_1
FROM latest_journal;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績 最新新規電文のdumpタグ取得(PAT_BASIC_INFO)', current_timestamp, current_timestamp, NULL);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-604183, '-- 【SQL_CD=-604183】
WITH latest_journal AS (
    SELECT convert_from(dump, ''SJIS'')::xml AS dump_xml
    FROM sys_coop_journal
    WHERE facility_cd = @facilityCd
        AND ord_no = @ordNo
        AND pat_id = @patId
        AND coop_cd = ''rst_dial''
        AND crud in (''C'', ''U'')
        AND ana_result = ''9''
        AND coop_result = ''9''
        AND ctl_no < @ctlNo
    ORDER BY ctl_no DESC
    LIMIT 1
)
SELECT
    (xpath(''//RST_DIALYSIS_HST/DIALYSIS_NO/text()'', dump_xml))[1]::text           AS rst_dialysis_no,
    (xpath(''//RST_DIALYSIS_HST/EDITION/text()'', dump_xml))[1]::text                AS rst_edition,
    (xpath(''//RST_DIALYSIS_HST/START_DATE/text()'', dump_xml))[1]::text             AS rst_start_date,
    (xpath(''//RST_DIALYSIS_HST/END_DATE/text()'', dump_xml))[1]::text               AS rst_end_date,
    (xpath(''//RST_DIALYSIS_HST/BED_NO/text()'', dump_xml))[1]::text                 AS bed_no,
    (xpath(''//RST_DIALYSIS_HST/MST_KUR/KUR_NAME/text()'', dump_xml))[1]::text       AS kur_name,
    (xpath(''//RST_DIALYSIS_HST/DIALYSIS_TIME/text()'', dump_xml))[1]::text          AS rst_dialysis_time,
    (xpath(''//RST_DIALYSIS_HST/WARD_CD/text()'', dump_xml))[1]::text                AS ward_cd,
    (xpath(''//RST_DIALYSIS_HST/MST_WARD/IN_HOSPITAL_CD/text()'', dump_xml))[1]::text AS ward_in_hospital_cd_1
FROM latest_journal;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績 最新新規電文のdumpタグ取得(RST_DIALYSIS_HST)', current_timestamp, current_timestamp, NULL);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-604184, '-- 【SQL_CD=-604184】
WITH latest_journal AS (
    SELECT convert_from(dump, ''SJIS'')::xml AS dump_xml
    FROM sys_coop_journal
    WHERE facility_cd = @facilityCd
        AND ord_no = @ordNo
        AND pat_id = @patId
        AND coop_cd = ''rst_dial''
        AND crud in (''C'', ''U'')
        AND ana_result = ''9''
        AND coop_result = ''9''
        AND ctl_no < @ctlNo
    ORDER BY ctl_no DESC
    LIMIT 1
)
SELECT
    (xpath(''//RST_DIALYSIS_EDITION/DECIDER/text()'', dump_xml))[1]::text                    AS decider,
    (xpath(''//RST_DIALYSIS_EDITION/MST_STAFF/STAFF_CD/text()'', dump_xml))[1]::text         AS staff_cd,
    (xpath(''//RST_DIALYSIS_EDITION/MST_STAFF/JOB_CLASS_CD/text()'', dump_xml))[1]::text     AS job_class_cd
FROM latest_journal;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績 最新新規電文のdumpタグ取得(RST_DIALYSIS_EDITION)', current_timestamp, current_timestamp, NULL);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-604185, '-- 【SQL_CD=-604185】
WITH latest_journal AS (
    SELECT convert_from(dump, ''SJIS'')::xml AS dump_xml
    FROM sys_coop_journal
    WHERE facility_cd = @facilityCd
        AND ord_no = @ordNo
        AND pat_id = @patId
        AND coop_cd = ''rst_dial''
        AND crud in (''C'', ''U'')
        AND ana_result = ''9''
        AND coop_result = ''9''
        AND ctl_no < @ctlNo
    ORDER BY ctl_no DESC
    LIMIT 1
),
memo_nodes AS (
    SELECT
        row_number() OVER () AS seq,
        memo_node
    FROM (
        -- unnest を先にサブクエリで展開してから row_number を振る
        SELECT unnest(xpath(''//RST_RECEIPT_MEMO_HST'', dump_xml)) AS memo_node
        FROM latest_journal
    ) expanded
)
SELECT
    seq,
    (xpath(''//RST_RECEIPT_MEMO_HST/@NAME'',
        (''<root>'' || memo_node::text || ''</root>'')::xml
    ))[1]::text                                                           AS detail_id,
    regexp_replace(memo_node::text, ''.*MAIN_DIAL_DIFF="([^"]*)".*'', ''\1'') AS is_main,
    (xpath(''//ITEM_NAME/text()'', memo_node))[1]::text                     AS dialysis_difficulty_name
FROM memo_nodes
ORDER BY seq;', 2, '[]'::jsonb, '1', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績 最新新規電文のdumpタグ取得(RST_RECEIPT_MEMO_HST)', current_timestamp, current_timestamp, NULL);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-604186, '-- 【SQL_CD=-604186】
WITH latest_journal AS (
    SELECT convert_from(dump, ''SJIS'')::xml AS dump_xml
    FROM sys_coop_journal
    WHERE facility_cd = @facilityCd
        AND ord_no = @ordNo
        AND pat_id = @patId
        AND coop_cd = ''rst_dial''
        AND crud in (''C'', ''U'')
        AND ana_result = ''9''
        AND coop_result = ''9''
        AND ctl_no < @ctlNo
    ORDER BY ctl_no DESC
    LIMIT 1
),
cond_nodes AS (
    SELECT
        row_number() OVER () AS seq,
        cond_node
    FROM (
        SELECT unnest(xpath(''//RST_DIALYSIS_COND_HST'', dump_xml)) AS cond_node
        FROM latest_journal
    ) expanded
)
SELECT
    seq,
    (xpath(''/RST_DIALYSIS_COND_HST/@CTL_NO'', cond_node))[1]::text                                      AS item_cd,
    (xpath(''/RST_DIALYSIS_COND_HST/@NAME'', cond_node))[1]::text                                        AS item_name,
    (xpath(''/RST_DIALYSIS_COND_HST/VALUE/text()'', cond_node))[1]::text                                 AS item_value,
    (xpath(''/RST_DIALYSIS_COND_HST/MST_TREAT_ITEM/IN_HOSPITAL_CD/text()'', cond_node))[1]::text        AS mtt_in_hospital_cd,
    (xpath(''/RST_DIALYSIS_COND_HST/MST_TREAT_ITEM/TREAT_ITEM_NAME/text()'', cond_node))[1]::text       AS mtt_treatment_name,
    (xpath(''/RST_DIALYSIS_COND_HST/MST_MEDICINE/SHOT/text()'', cond_node))[1]::text                    AS med_is_shot,
    (xpath(''/RST_DIALYSIS_COND_HST/MST_MEDICINE/IN_HOSPITAL_CD/text()'', cond_node))[1]::text          AS med_in_hospital_cd,
    (xpath(''/RST_DIALYSIS_COND_HST/MST_DIALYZER/IN_HOSPITAL_CD/text()'', cond_node))[1]::text          AS mdr_in_hospital_cd,
    (xpath(''/RST_DIALYSIS_COND_HST/MST_EQUIPMENT/IN_HOSPITAL_CD/text()'', cond_node))[1]::text         AS meqa_in_hospital_cd
FROM cond_nodes
WHERE (xpath(''/RST_DIALYSIS_COND_HST/@CTL_NO'', cond_node))[1]::text <> ''011''
ORDER BY seq;', 2, '[]'::jsonb, '1', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績 最新新規電文のdumpタグ取得(RST_DIALYSIS_COND_HST 抗凝固剤以外)', current_timestamp, current_timestamp, NULL);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-604187, '-- 【SQL_CD=-604187】
WITH latest_journal AS (
    SELECT convert_from(dump, ''SJIS'')::xml AS dump_xml
    FROM sys_coop_journal
    WHERE facility_cd = @facilityCd
        AND ord_no = @ordNo
        AND pat_id = @patId
        AND coop_cd = ''rst_dial''
        AND crud in (''C'', ''U'')
        AND ana_result = ''9''
        AND coop_result = ''9''
        AND ctl_no < @ctlNo
    ORDER BY ctl_no DESC
    LIMIT 1
),
equip_nodes AS (
    SELECT
        row_number() OVER () AS seq,
        equip_node
    FROM (
        SELECT unnest(xpath(''//RST_DIALYSIS_EQUIP_HST'', dump_xml)) AS equip_node
        FROM latest_journal
    ) expanded
)
SELECT
    seq,
    (xpath(''//AMOUNT/text()'', equip_node))[1]::text                      AS amount,
    (xpath(''//MST_EQUIPMENT/IN_HOSPITAL_CD/text()'', equip_node))[1]::text AS in_hospital_cd_1
FROM equip_nodes
ORDER BY seq;', 2, '[]'::jsonb, '1', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績 最新新規電文のdumpタグ取得(RST_DIALYSIS_EQUIP_HST)', current_timestamp, current_timestamp, NULL);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-604188, '-- 【SQL_CD=-604188】
WITH latest_journal AS (
    SELECT convert_from(dump, ''SJIS'')::xml AS dump_xml
    FROM sys_coop_journal
    WHERE facility_cd = @facilityCd
        AND ord_no = @ordNo
        AND pat_id = @patId
        AND coop_cd = ''rst_dial''
        AND crud in (''C'', ''U'')
        AND ana_result = ''9''
        AND coop_result = ''9''
        AND ctl_no < @ctlNo
    ORDER BY ctl_no DESC
    LIMIT 1
),
medication_nodes AS (
    SELECT
        row_number() OVER () AS seq,
        med_node
    FROM (
        SELECT unnest(xpath(''//RST_DIALYSIS_MEDICATION_HST'', dump_xml)) AS med_node
        FROM latest_journal
    ) expanded
),
medication_with_ctl AS (
    SELECT
        seq,
        med_node,
        (xpath(''/RST_DIALYSIS_MEDICATION_HST/@CTL_NO'', med_node))[1]::text AS ctl_no
    FROM medication_nodes
)
SELECT
    ''09''                                                                                                          AS detail_id,
    seq,
    ctl_no,
    @ctlNo                                                                                                        AS journal_ctl_no,
    @ordNo                                                                                                        AS ord_no,
    @facilityCd                                                                                                   AS facility_cd,
    @patId                                                                                                        AS pat_id,
    (xpath(''/RST_DIALYSIS_MEDICATION_HST/EFFECT_FLG/text()'', med_node))[1]::text                                 AS effect_flg,
    (xpath(''/RST_DIALYSIS_MEDICATION_HST/SET_MEDICINE_CD/text()'', med_node))[1]::text                            AS medicine_cd,
    (xpath(''/RST_DIALYSIS_MEDICATION_HST/PROCEDURE_CD/text()'', med_node))[1]::text                               AS procedure_cd,
    (xpath(''/RST_DIALYSIS_MEDICATION_HST/EFFECT_DATE/text()'', med_node))[1]::text                                AS effect_date,
    (xpath(''/RST_DIALYSIS_MEDICATION_HST/SET_MEDICINE_FLG/text()'', med_node))[1]::text                          AS set_medicine_flg,
    (xpath(''/RST_DIALYSIS_MEDICATION_HST/AMOUNT/text()'', med_node))[1]::text                                     AS amount,
    (xpath(''/RST_DIALYSIS_MEDICATION_HST/MST_MEDICINE/SHOT/text()'', med_node))[1]::text                          AS mmd_is_shot,
    (xpath(''/RST_DIALYSIS_MEDICATION_HST/MST_MEDICINE/IN_HOSPITAL_CD/text()'', med_node))[1]::text                AS mmd_in_hospital_cd_1,
    (xpath(''/RST_DIALYSIS_MEDICATION_HST/MST_MEDICINE/IN_HOSPITAL_CD2/text()'', med_node))[1]::text               AS mmd_in_hospital_cd_2,
    (xpath(''/RST_DIALYSIS_MEDICATION_HST/MST_MEDICINE/MEDICINE_CD/text()'', med_node))[1]::text                   AS mmd_medicine_cd,
    (xpath(''/RST_DIALYSIS_MEDICATION_HST/MST_MEDICINE/MEDICINE_GROUP_CD/text()'', med_node))[1]::text             AS class_cd,
    (xpath(''/RST_DIALYSIS_MEDICATION_HST/MST_PROCEDURE/IN_HOSPITAL_CD1/text()'', med_node))[1]::text              AS mp_in_hospital_cd_1,
    (xpath(''/RST_DIALYSIS_MEDICATION_HST/MST_PROCEDURE/IN_HOSPITAL_CD2/text()'', med_node))[1]::text              AS mp_in_hospital_cd_2,
    (xpath(''/RST_DIALYSIS_MEDICATION_HST/MST_SET_MEDI_NAME/IN_HOSPITAL_CD2/text()'', med_node))[1]::text          AS mix_med_in_hospital_cd2
FROM medication_with_ctl
ORDER BY seq;', 2, '[]'::jsonb, '1', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績 最新新規電文のdumpタグ取得(RST_DIALYSIS_MEDICATION_HST)', current_timestamp, current_timestamp, NULL);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-604189, '-- 【SQL_CD=-604189】
WITH latest_journal AS (
    SELECT convert_from(dump, ''SJIS'')::xml AS dump_xml
    FROM sys_coop_journal
    WHERE facility_cd = @facilityCd
        AND ord_no = @ordNo
        AND pat_id = @patId
        AND coop_cd = ''rst_dial''
        AND crud in (''C'', ''U'')
        AND ana_result = ''9''
        AND coop_result = ''9''
        AND ctl_no < @ctlNo
    ORDER BY ctl_no DESC
    LIMIT 1
),
treatment_nodes AS (
    SELECT
        row_number() OVER () AS seq,
        treat_node
    FROM (
        SELECT unnest(xpath(''//RST_DIALYSIS_TREATMENT_HST'', dump_xml)) AS treat_node
        FROM latest_journal
    ) expanded
)
SELECT
    ''10''                                                                                                AS detail_id,
    seq,
    @ctlNo                                                                                              AS journal_ctl_no,
    @ordNo                                                                                              AS ord_no,
    @facilityCd                                                                                         AS facility_cd,
    @patId                                                                                              AS pat_id,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/@CTL_NO'', treat_node))[1]::text                                AS disp_no,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/@NAME'', treat_node))[1]::text                                  AS disp_name,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/TREAT_MEDICINE_CD/text()'', treat_node))[1]::text               AS medicine_cd,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/PROCEDURE_CD/text()'', treat_node))[1]::text                    AS procedure_cd,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/AMOUNT/text()'', treat_node))[1]::text                          AS amount,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/TREAT_CLASS/text()'', treat_node))[1]::text                     AS treat_class,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/RESULT_NO/text()'', treat_node))[1]::text                       AS result_no,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/OCCUR_DATE/text()'', treat_node))[1]::text                      AS occur_date_start,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/OXYGEN_AMOUNT/text()'', treat_node))[1]::text                   AS oxygen_amount,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/OXYGEN_START/text()'', treat_node))[1]::text                    AS oxygen_start_new,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/OXYGEN_TIME/text()'', treat_node))[1]::text                     AS oxygen_time_new,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/MST_MEDICINE/SHOT/text()'', treat_node))[1]::text               AS mmd_is_shot,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/MST_MEDICINE/IN_HOSPITAL_CD/text()'', treat_node))[1]::text     AS mmd_in_hospital_cd_1,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/MST_MEDICINE/IN_HOSPITAL_CD2/text()'', treat_node))[1]::text    AS mmd_in_hospital_cd_2,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/MST_MEDICINE/MEDICINE_CD/text()'', treat_node))[1]::text        AS mmd_medicine_cd,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/MST_MEDICINE/MEDICINE_GROUP_CD/text()'', treat_node))[1]::text  AS mmd_class_cd,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/MST_PROCEDURE/IN_HOSPITAL_CD1/text()'', treat_node))[1]::text   AS mp_in_hospital_cd_1,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/MST_PROCEDURE/IN_HOSPITAL_CD2/text()'', treat_node))[1]::text   AS mp_in_hospital_cd_2
FROM treatment_nodes
ORDER BY seq;', 2, '[]'::jsonb, '1', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績 最新新規電文のdumpタグ取得(RST_DIALYSIS_TREATMENT_HST)', current_timestamp, current_timestamp, NULL);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-604190, '-- 【SQL_CD=-604190】
WITH latest_journal AS (
    SELECT convert_from(dump, ''SJIS'')::xml AS dump_xml
    FROM sys_coop_journal
    WHERE facility_cd = @facilityCd
        AND ord_no = @ordNo
        AND pat_id = @patId
        AND coop_cd = ''rst_dial''
        AND crud in (''C'', ''U'')
        AND ana_result = ''9''
        AND coop_result = ''9''
        AND ctl_no < @ctlNo
    ORDER BY ctl_no DESC
    LIMIT 1
)
SELECT
    (xpath(''//EXAM_FREE_DATA_DETAIL/text()'', dump_xml))[1]::text        AS exam_free_data,
    (xpath(''//A00001//ACL/text()'', dump_xml))[1]::text                  AS acl,
    (xpath(''//A10002//TABLE_NAME/text()'', dump_xml))[1]::text           AS if_event_log,
    (xpath(''//A20001//SYS_SYSTEM_DEFINE/VALUE/text()'', dump_xml))[1]::text AS sys_system_value
FROM latest_journal;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績 最新新規電文のdumpタグ取得(EXAM_FREE_DATA_DETAIL/SYS_COOP_EXEC_DATA)', current_timestamp, current_timestamp, NULL);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-604191, '-- 【SQL_CD=-604191】
WITH latest_journal AS (
    SELECT convert_from(dump, ''SJIS'')::xml AS dump_xml
    FROM sys_coop_journal
    WHERE facility_cd = @facilityCd
        AND ord_no = @ordNo
        AND pat_id = @patId
        AND coop_cd = ''rst_dial''
        AND crud in (''C'', ''U'')
        AND ana_result = ''9''
        AND coop_result = ''9''
        AND ctl_no < @ctlNo
    ORDER BY ctl_no DESC
    LIMIT 1
),
bed_nodes AS (
    SELECT
        row_number() OVER () AS seq,
        bed_node
    FROM (
        SELECT unnest(xpath(''//A00002//BED_NO'', dump_xml)) AS bed_node
        FROM latest_journal
    ) expanded
)
SELECT
    seq,
    (xpath(''//BED_NO/text()'',
        (''<root>'' || bed_node::text || ''</root>'')::xml
    ))[1]::text AS in_hospital_cd_1
FROM bed_nodes
ORDER BY seq;
', 2, '[]'::jsonb, '1', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績 最新新規電文のdumpタグ取得(MST_BED/BED_NO)', current_timestamp, current_timestamp, NULL);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-604192, '-- 【SQL_CD=-604192】
WITH latest_journal AS (
    SELECT convert_from(dump, ''SJIS'')::xml AS dump_xml
    FROM sys_coop_journal
    WHERE facility_cd = @facilityCd
        AND ord_no = @ordNo
        AND pat_id = @patId
        AND coop_cd = ''rst_dial''
        AND crud in (''C'', ''U'')
        AND ana_result = ''9''
        AND coop_result = ''9''
        AND ctl_no < @ctlNo
    ORDER BY ctl_no DESC
    LIMIT 1
),
row_nodes AS (
    SELECT
        row_number() OVER () AS seq,
        row_node
    FROM (
        SELECT unnest(xpath(''//SYS_COOP_INI_DATA/row'', dump_xml)) AS row_node
        FROM latest_journal
    ) expanded
)
SELECT
    seq,
    (xpath(''//INI_SECTION/text()'', row_node))[1]::text AS ini_section,
    (xpath(''//INI_KEY/text()'', row_node))[1]::text     AS ini_key,
    (xpath(''//INI_VALUE/text()'', row_node))[1]::text   AS ini_value
FROM row_nodes
ORDER BY seq;', 2, '[]'::jsonb, '1', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績 最新新規電文のdumpタグ取得(SYS_COOP_INI_DATA/row)', current_timestamp, current_timestamp, NULL);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-604193, '-- 【SQL_CD=-604193】
SELECT
    @e01 AS e01,
    @e02 AS e02,
    @e03 AS e03,
    @e04 AS e04,
    @e05 AS e05,
    @e06 AS e06,
    @e07 AS e07,
    @e08 AS e08,
    @e09 AS e09,
    @e10 AS e10,
    @e11 AS e11,
    @e12 AS e12,
    @e13 AS e13,
    @e14 AS e14,
    @e15 AS e15,
    @e16 AS e16', 2, '[]'::jsonb, '1', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績 最新新規電文のdumpタグ取得(RST_DIALYSIS_MEDICATION_HST/RST_DIALYSIS_TREATMENT_HST 明細)', current_timestamp, current_timestamp, NULL);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-604194, '-- 【SQL_CD=-604194】
WITH latest_journal AS (
    SELECT convert_from(dump, ''SJIS'')::xml AS dump_xml
    FROM sys_coop_journal
    WHERE facility_cd = @facilityCd
        AND ord_no = @ordNo
        AND pat_id = @patId
        AND coop_cd = ''rst_dial''
        AND crud in (''C'', ''U'')
        AND ana_result = ''9''
        AND coop_result = ''9''
        AND ctl_no < @ctlNo
    ORDER BY ctl_no DESC
    LIMIT 1
),
medication_nodes AS (
    SELECT
        row_number() OVER () AS seq,
        med_node
    FROM (
        SELECT unnest(xpath(''//RST_DIALYSIS_MEDICATION_HST'', dump_xml)) AS med_node
        FROM latest_journal
    ) expanded
),
target_node AS (
    SELECT med_node
    FROM medication_nodes
    WHERE regexp_replace(med_node::text, ''.*CTL_NO="([^"]*)".*'', ''\1'') = @targetCtlNo::text
),
set_medicine_nodes AS (
    SELECT
        row_number() OVER () AS seq,
        set_med_node
    FROM (
        SELECT unnest(xpath(''//MST_SET_MEDI_NAME/MST_SET_MEDICINE'', med_node)) AS set_med_node
        FROM target_node
    ) expanded
)
SELECT
    seq,
    (xpath(''/MST_SET_MEDICINE/MST_MEDICINE/SHOT/text()'', set_med_node))[1]::text           AS mmd_is_shot,
    (xpath(''/MST_SET_MEDICINE/MST_MEDICINE/IN_HOSPITAL_CD/text()'', set_med_node))[1]::text  AS mmd_in_hospital_cd_1,
    (xpath(''/MST_SET_MEDICINE/MST_MEDICINE/MEDICINE_GROUP_CD/text()'', set_med_node))[1]::text AS class_cd,
    (xpath(''/MST_SET_MEDICINE/PROCEDURE_CD/text()'', set_med_node))[1]::text                 AS procedure_cd,
    (xpath(''/MST_SET_MEDICINE/MST_PROCEDURE/IN_HOSPITAL_CD1/text()'', set_med_node))[1]::text AS mp_in_hospital_cd_1,
    (xpath(''/MST_SET_MEDICINE/MST_PROCEDURE/IN_HOSPITAL_CD2/text()'', set_med_node))[1]::text AS mp_in_hospital_cd_2,
    (xpath(''/MST_SET_MEDICINE/MEDI_USE_NUM/text()'', set_med_node))[1]::text                 AS amount,
    ''11''                                                                                      AS detail_id
FROM set_medicine_nodes
ORDER BY seq;', 2, '[]'::jsonb, '1', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績 最新新規電文のdumpタグ取得(RST_DIALYSIS_MEDICATION_HST > MST_SET_MEDICINE)', current_timestamp, current_timestamp, NULL);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-604195, '-- 【SQL_CD=-604195】
WITH latest_journal AS (
    SELECT convert_from(dump, ''SJIS'')::xml AS dump_xml
    FROM sys_coop_journal
    WHERE facility_cd = @facilityCd
        AND ord_no = @ordNo
        AND pat_id = @patId
        AND coop_cd = ''rst_dial''
        AND crud in (''C'', ''U'')
        AND ana_result = ''9''
        AND coop_result = ''9''
        AND ctl_no < @ctlNo
    ORDER BY ctl_no DESC
    LIMIT 1
),
treatment_nodes AS (
    SELECT
        row_number() OVER () AS seq,
        treat_node
    FROM (
        SELECT unnest(xpath(''//RST_DIALYSIS_TREATMENT_HST'', dump_xml)) AS treat_node
        FROM latest_journal
    ) expanded
),
target_node AS (
    SELECT treat_node
    FROM treatment_nodes
    WHERE (xpath(''/RST_DIALYSIS_TREATMENT_HST/@CTL_NO'', treat_node))[1]::text = @targetCtlNo::text
),
set_medicine_nodes AS (
    SELECT
        row_number() OVER () AS seq,
        set_med_node
    FROM (
        SELECT unnest(xpath(''//MST_SET_MEDI_NAME/MST_SET_MEDICINE'', treat_node)) AS set_med_node
        FROM target_node
    ) expanded
)
SELECT
    seq,
    (xpath(''/MST_SET_MEDICINE/MST_MEDICINE/SHOT/text()'', set_med_node))[1]::text            AS mmd_is_shot,
    (xpath(''/MST_SET_MEDICINE/MST_MEDICINE/IN_HOSPITAL_CD/text()'', set_med_node))[1]::text   AS mmd_in_hospital_cd_1,
    (xpath(''/MST_SET_MEDICINE/MST_MEDICINE/MEDICINE_GROUP_CD/text()'', set_med_node))[1]::text AS class_cd,
    (xpath(''/MST_SET_MEDICINE/PROCEDURE_CD/text()'', set_med_node))[1]::text                  AS procedure_cd,
    (xpath(''/MST_SET_MEDICINE/MST_PROCEDURE/IN_HOSPITAL_CD1/text()'', set_med_node))[1]::text AS mp_in_hospital_cd_1,
    (xpath(''/MST_SET_MEDICINE/MST_PROCEDURE/IN_HOSPITAL_CD2/text()'', set_med_node))[1]::text AS mp_in_hospital_cd_2,
    (xpath(''/MST_SET_MEDICINE/MEDI_USE_NUM/text()'', set_med_node))[1]::text                  AS amount,
    ''12''                                                                                       AS detail_id
FROM set_medicine_nodes
ORDER BY seq;', 2, '[]'::jsonb, '1', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績 最新新規電文のdumpタグ取得(RST_DIALYSIS_TREATMENT_HST > MST_SET_MEDICINE)', current_timestamp, current_timestamp, NULL);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-604196, '-- 【SQL_CD=-604196】
WITH latest_journal AS (
    SELECT convert_from(dump, ''SJIS'')::xml AS dump_xml
    FROM sys_coop_journal
    WHERE facility_cd = @facilityCd
        AND ord_no = @ordNo
        AND pat_id = @patId
        AND coop_cd = ''rst_dial''
        AND crud in (''C'', ''U'')
        AND ana_result = ''9''
        AND coop_result = ''9''
        AND ctl_no < @ctlNo
    ORDER BY ctl_no DESC
    LIMIT 1
),
cond_nodes AS (
    SELECT
        row_number() OVER () AS seq,
        cond_node
    FROM (
        SELECT unnest(xpath(''//RST_DIALYSIS_COND_HST'', dump_xml)) AS cond_node
        FROM latest_journal
    ) expanded
)
SELECT
    seq,
    (xpath(''/RST_DIALYSIS_COND_HST/@CTL_NO'', cond_node))[1]::text                                      AS item_cd,
    (xpath(''/RST_DIALYSIS_COND_HST/@NAME'', cond_node))[1]::text                                        AS item_name,
    (xpath(''/RST_DIALYSIS_COND_HST/VALUE/text()'', cond_node))[1]::text                                 AS item_value,
    (xpath(''/RST_DIALYSIS_COND_HST/MST_TREAT_ITEM/IN_HOSPITAL_CD/text()'', cond_node))[1]::text        AS mtt_in_hospital_cd,
    (xpath(''/RST_DIALYSIS_COND_HST/MST_TREAT_ITEM/TREAT_ITEM_NAME/text()'', cond_node))[1]::text       AS mtt_treatment_name,
    (xpath(''/RST_DIALYSIS_COND_HST/MST_MEDICINE/SHOT/text()'', cond_node))[1]::text                    AS med_is_shot,
    (xpath(''/RST_DIALYSIS_COND_HST/MST_MEDICINE/IN_HOSPITAL_CD/text()'', cond_node))[1]::text          AS med_in_hospital_cd,
    (xpath(''/RST_DIALYSIS_COND_HST/MST_DIALYZER/IN_HOSPITAL_CD/text()'', cond_node))[1]::text          AS mdr_in_hospital_cd,
    (xpath(''/RST_DIALYSIS_COND_HST/MST_EQUIPMENT/IN_HOSPITAL_CD/text()'', cond_node))[1]::text         AS meqa_in_hospital_cd
FROM cond_nodes
WHERE (xpath(''/RST_DIALYSIS_COND_HST/@CTL_NO'', cond_node))[1]::text = ''011''
ORDER BY seq;', 2, '[]'::jsonb, '1', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績 最新新規電文のdumpタグ取得(RST_DIALYSIS_COND_HST 抗凝固剤)', current_timestamp, current_timestamp, NULL);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-604197, '-- 【SQL_CD=-604197】
WITH latest_journal AS (
    SELECT convert_from(dump, ''SJIS'')::xml AS dump_xml
    FROM sys_coop_journal
    WHERE facility_cd = @facilityCd
        AND ord_no = @ordNo
        AND pat_id = @patId
        AND coop_cd = ''rst_dial''
        AND crud in (''C'', ''U'')
        AND ana_result = ''9''
        AND coop_result = ''9''
        AND ctl_no < @ctlNo
    ORDER BY ctl_no DESC
    LIMIT 1
),
set_medicine_nodes AS (
    SELECT
        row_number() OVER () AS seq,
        set_med_node
    FROM (
        SELECT unnest(xpath(
            ''//RST_DIALYSIS_COND_HST[@CTL_NO="011"]/MST_SET_MEDI_NAME/MST_SET_MEDICINE'',
            dump_xml
        )) AS set_med_node
        FROM latest_journal
    ) expanded
)
SELECT
    seq,
    (xpath(''/MST_SET_MEDICINE/MST_MEDICINE/IN_HOSPITAL_CD/text()'', set_med_node))[1]::text  AS mix_med_in_hospital_cd,
    (xpath(''/MST_SET_MEDICINE/MEDI_USE_NUM/text()'', set_med_node))[1]::text                 AS mix_amout
FROM set_medicine_nodes
ORDER BY seq;', 2, '[]'::jsonb, '1', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績 最新新規電文のdumpタグ取得(RST_DIALYSIS_COND_HST 抗凝固剤 調製薬剤繰り返し)', current_timestamp, current_timestamp, NULL);