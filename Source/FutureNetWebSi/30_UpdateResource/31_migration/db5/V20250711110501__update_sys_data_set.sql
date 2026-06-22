DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-1105004,-1105005);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1105004, 'WITH dump_text AS (
SELECT
    convert_from(scj.dump, ''shift-jis'') AS dump_text
FROM sys_coop_journal AS scj
WHERE
    pat_id = @patId
    AND facility_cd = @facilityCd
    AND crud IN (''C'',''U'')
    AND ord_no = @ordNo
    AND coop_cd = ''exam_ord''
    AND key0 = @key0
    AND ana_result = ''9''
    AND coop_result IN (''9'',''8'',''1'',''0'')
    ORDER BY scj.up_date DESC
LIMIT 1
)
SELECT
    t.part AS data
    , split_part(t.part, '','', 1) as hospital_id
    , split_part(t.part, '','', 2) as hosp_pat_id
    , split_part(t.part, '','', 3) as occur_date
    , split_part(t.part, '','', 4) as occur_time
    , split_part(t.part, '','', 5) as user_id
    , split_part(t.part, '','', 8) as title
    , split_part(t.part, '','', 9) as course_cd2
    , split_part(t.part, '','', 11) as in_out_class
    , split_part(t.part, '','', 12) as reg_exam_date
    , split_part(t.part, '','', 13) as reg_exam_date
FROM dump_text
CROSS JOIN LATERAL regexp_split_to_table(dump_text.dump_text, ''\n'') WITH ordinality AS t(part, idx)
WHERE t.idx = 2', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携_検体検査オーダー連携_削除', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1105005, 'WITH dump_text AS (
SELECT
    convert_from(scj.dump, ''shift-jis'') AS dump_text
FROM sys_coop_journal AS scj
WHERE
    pat_id = @patId
    AND facility_cd = @facilityCd
    AND crud IN (''C'',''U'')
    AND ord_no = @ordNo
    AND coop_cd = ''exam_ord''
    AND key0 = @key0
    AND ana_result = ''9''
    AND coop_result IN (''9'',''8'',''1'',''0'')
    ORDER BY scj.up_date DESC
LIMIT 1
)
SELECT
    t.part AS data
    , split_part(t.part, '','', 1) as hospital_id
    , split_part(t.part, '','', 2) as hosp_pat_id
    , split_part(t.part, '','', 3) as occur_date
    , split_part(t.part, '','', 4) as occur_time
    , split_part(t.part, '','', 5) as user_id
    , split_part(t.part, '','', 22) as exam_set_cnt
    , split_part(t.part, '','', 23) as item_in_hospital_cd
    , split_part(t.part, '','', 24) as exam_timing_flag
FROM dump_text
CROSS JOIN LATERAL regexp_split_to_table(dump_text.dump_text, ''\n'') WITH ordinality AS t(part, idx)
WHERE t.idx = 4', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携_検体検査オーダー連携_削除', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
