DELETE FROM ntss.sys_data_set
WHERE sql_cd in (-1106006, -1106007, -1106008);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1106006, 'WITH dump_text AS (
SELECT
    convert_from(scj.dump, ''shift-jis'') AS dump_text
FROM sys_coop_journal AS scj
WHERE
    pat_id = @patId
    AND facility_cd = @facilityCd
    AND crud = ''C''
    AND ord_no = @ordNo
    AND coop_cd = ''rad_ord''
    AND key0 = @key0
    AND ana_result = ''9''
    AND coop_result = ''9''
    ORDER BY scj.up_date DESC
LIMIT 1
)
SELECT
      split_part(t.part, '','', 1) as hospital_id
    , split_part(t.part, '','', 2) as hosp_pat_id
    , split_part(t.part, '','', 3) as occur_date
    , split_part(t.part, '','', 4) as occur_time
    , split_part(t.part, '','', 5) as user_id
    , split_part(t.part, '','', 8) as title
    , split_part(t.part, '','', 9) as course_cd2
    , split_part(t.part, '','', 11) as in_out_class
    , split_part(t.part, '','', 12) as reg_rad_date
FROM dump_text
CROSS JOIN LATERAL regexp_split_to_table(dump_text.dump_text, ''\n'') WITH ordinality AS t(part, idx)
WHERE t.idx = 2', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携_放射線オーダー連携_削除', '2025-07-15 20:55:07.818', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1106007, 'WITH dump_text AS (
SELECT
    convert_from(scj.dump, ''shift-jis'') AS dump_text
FROM sys_coop_journal AS scj
WHERE
    pat_id = @patId
    AND facility_cd = @facilityCd
    AND crud = ''C''
    AND ord_no = @ordNo
    AND coop_cd = ''rad_ord''
    AND key0 = @key0
    AND ana_result = ''9''
    AND coop_result = ''9''
    ORDER BY scj.up_date DESC
LIMIT 1
)
SELECT
      split_part(t.part, '','', 1) as hospital_id
    , split_part(t.part, '','', 2) as hosp_pat_id
    , split_part(t.part, '','', 3) as occur_date
    , split_part(t.part, '','', 4) as occur_time
    , split_part(t.part, '','', 5) as user_id
FROM dump_text
CROSS JOIN LATERAL regexp_split_to_table(dump_text.dump_text, ''\n'') WITH ordinality AS t(part, idx)
WHERE t.idx = 4', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携_放射線オーダー連携_削除', '2025-07-15 20:55:07.818', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1106008, 'WITH dump_text AS (
SELECT
    convert_from(scj.dump, ''shift-jis'') AS dump_text
FROM sys_coop_journal AS scj
WHERE
    pat_id = @patId
    AND facility_cd = @facilityCd
    AND crud = ''C''
    AND ord_no = @ordNo
    AND coop_cd = ''rad_ord''
    AND key0 = @key0
    AND ana_result = ''9''
    AND coop_result = ''9''
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
    , split_part(t.part, '','', 7) as part_cd
    , split_part(t.part, '','', 8) as mod_cd
    , split_part(t.part, '','', 9) as direction_cd
    , split_part(t.part, '','', 10) as procedure_cd
FROM dump_text
CROSS JOIN LATERAL regexp_split_to_table(dump_text.dump_text, ''\n'') WITH ordinality AS t(part, idx)
WHERE t.idx = 6', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携_放射線オーダー連携_削除', '2025-07-15 20:55:07.818', CURRENT_TIMESTAMP, NULL);