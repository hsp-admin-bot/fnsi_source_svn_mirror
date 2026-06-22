delete from sys_data_set where sql_cd in (-1000103,-1000105);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1000103, '-- 【SQL_CD=-1000103】
SELECT
    pat_id AS PATID,
    hosp_pat_id AS DISP_PATID,
    COALESCE(personal_info_decrypt(pat_last_name), '''') || '' '' || COALESCE(personal_info_decrypt(pat_first_name), '''') AS NAME,
    COALESCE(pat_sex, ''0'') AS SEX_CD,
    COALESCE(pat_birthday, '''') AS BIRTHDAY
FROM
    pat_personal_main
WHERE
    facility_cd = @facilityCd
AND hosp_pat_id NOT LIKE ''nn%''
AND is_del = ''0''',3,'[{}]','0','{"applications": [4]}',NULL,'統計調査（患者情報）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1000105, '-- 【SQL_CD=-1000105】
SELECT
    p.pat_id AS PATID,
    p.hosp_pat_id AS DISP_PATID,
    COALESCE(personal_info_decrypt(pat_last_name), '''') || '' '' || COALESCE(personal_info_decrypt(pat_first_name), '''') AS NAME,
    COALESCE(pat_sex, ''0'') AS SEX_CD,
    p.die_cd AS DIE_CD,
    p.die_date AS DIE_DATE,
    COALESCE(pat_birthday, '''') AS BIRTHDAY,
    COALESCE(personal_info_decrypt(pat_last_name_kana), '''') || '' '' || COALESCE(personal_info_decrypt(pat_first_name_kana),'''') AS NAME_KANA,
    p.primary_disease_cd AS BASE_DISEASE_CD
FROM
    pat_personal_main p
WHERE
    p.pat_id = @patId
AND
    p.facility_cd = @facilityCd
AND
    p.is_del = ''0''',3,'[{}]','0','{"applications": [4]}',NULL,'統計調査（患者基本情報取得）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);