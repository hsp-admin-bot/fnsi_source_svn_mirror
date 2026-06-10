update "sys_data_set" set "pre_sql_info" = null where "sql_cd" in (-456, -457);
delete from "sys_data_set" where "sql_cd" in (-99997,-99994,-300001,-458,-459,-460,-461,-462,-463,-464,-465,-466,-467,-468,-469);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-300001, ' select
 hosp_pat_id,
 personal_info_decrypt(pat_last_name)||'' ''||personal_info_decrypt(pat_first_name) as pat_name,
 personal_info_decrypt(pat_last_name_kana)||'' ''||personal_info_decrypt(pat_first_name_kana) as pat_name_kana,
 personal_info_decrypt(pat_last_name_alpha)||'' ''||personal_info_decrypt(pat_first_name_alpha) as pat_name_alpha,
 pat_birthday as pat_birthday_yyyymmdd,
 to_char(to_date(pat_birthday, ''YYYYMMDD''), ''YYYY/MM/DD'') as pat_birthday,
 case when pat_birthday is null then null
 else to_char(date_part(''year'',age(''now'', to_date(pat_birthday, ''YYYYMMDD''))), ''FM999'')
 end as pat_age,
 case when pat_sex = 1 then 0   when pat_sex = 2 then 1 else 2 end as pat_sex,
 pat_blood_type_abo,
 pat_blood_type_rh,
 pat_blood_type_abo * 10 +  pat_blood_type_rh as pat_blood_type_abo_rh,
 pat_blood_type_serovar as pat_blood_type_serovar,
 in_out_class,
 case in_out_class when 0 then ''外来'' when 1 then ''入院'' else ''不明'' end as in_out_class_name,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''zip_cd'')) as pat_zip,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''address'')) as pat_address,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''tel1'')) as pat_tel1,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''tel2'')) as pat_tel2,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''fax'')) as pat_fax,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''e_mail'')) as pat_e_mail,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''work_name'')) as pat_work_name,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''work_tel'')) as pat_work_tel,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''memo1'')) as pat_memo1,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''memo2'')) as pat_memo2,
 nationality as nationality,
 severity_cd,
 transport_cd,
 is_die,
 die_date,
 die_cd,
 die_cd as die_cd1,
 -- 透析困難有無
 case when jsonb_array_length(dial_diff_com_info) > 0 then 1 else 0 end as dial_diff_com_info_flag,
 up_date,
 insu_class, 
 insu_name
 from
 pat_personal_main
 left outer join (select pat_id, insu_class, insu_name from pat_insurance where pat_id = @patId and is_del = ''0'' order by is_selected desc limit 1) as insurance on insurance.pat_id = pat_personal_main.pat_id
 where
 is_del = ''0''
 and
 pat_personal_main.pat_id = @patId', 3, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'Medicom', '2020-07-31 18:29:49', '2020-07-31 18:29:49', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-99997, 'select
  ''FUTURENET_'' ||
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
  pat_id = @patId', 3, '[]', '0', '{"applications": [4]}', NULL, 'パナ処方ファイル名取得', '2020-03-24 10:52:31', '2020-03-24 10:52:34', '[{"sql_cd": -300006, "field_name": "start_date14", "replace_var": "@rstStartDate"}]');
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-99994, 'SELECT
  TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDDHH24MISS_'') ||
  ''_'' || 
  CASE WHEN ppm.in_out_class IS NULL THEN ''3'' ELSE CAST(ppm.in_out_class AS TEXT) END || 
  ''_'' ||
  ''FUTURENET''
  || ''.xml'' AS filename 
FROM
  ntss.pat_personal_main AS ppm 
WHERE
  pat_id = @patId', 3, '[]', '0', '{"applications": [4]}', NULL, 'Medicomカルテ記載連携(透析経過データ連携)ファイル名取得', '2021-04-20 09:19:08.001', '2021-04-20 09:19:12', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-469, 'WITH medicine_info AS (
  SELECT
    ''投与薬剤情報'' AS detail 
    , medi_info->>''cd'' AS medicine_cd
    , medi_info->>''name'' AS medicine_name
    , medi_info->>''amount'' AS amount
    , medi_info->>''unit'' AS unit
    , '''' AS cutoff
    -- 手技
    , medi_info->>''procedure_cd'' AS procedure_cd
    , medi_info->>''procedure_name'' AS procedure_name
    -- 薬剤区分:1: 通常薬剤、2: 調製薬剤
    , medi_info->>''medicine_type'' AS medicine_type
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi_info 
  WHERE
    ord_no = @ordNo
  UNION ALL
  SELECT
    ''愁訴情報'' AS detail
    , CASE WHEN treatment_info->>''medicine_cd'' IS NULL
         THEN treatment_info->>''treat_medicine_cd'' 
        ELSE treatment_info->>''medicine_cd'' 
      END AS medicine_cd
    , CASE WHEN treatment_info->>''medicine_cd'' IS NULL
        THEN treatment_info->>''treat_medicine_name'' 
        ELSE treatment_info->>''medicine_name'' 
        END AS medicine_name
    , treatment_info->>''amount'' AS amount
    , treatment_info->>''unit'' AS unit
    , '''' AS cutoff
    -- 手技
    , treatment_info->>''procedure_cd'' AS procedure_cd
    , treatment_info->>''procedure_name'' AS procedure_name
    -- 薬剤区分:1: 通常薬剤、2: 調製薬剤
    , treatment_info->>''medicine_type'' AS medicine_type
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) treatment_info 
  WHERE
    ord_no = @ordNo
),
T01 AS (SELECT
  info.*
  -- 注射:0：注射薬剤以外、1：注射薬剤
  , CASE WHEN info.medicine_type = ''1'' THEN COALESCE(medicine.is_shot, ''0'') ELSE COALESCE(medicine_mix.is_shot, ''0'') END AS is_shot
  -- 薬剤分類
  , CASE WHEN info.medicine_type = ''1'' THEN medicine.class_cd ELSE medicine_mix.class_cd END AS class_cd
  -- 薬剤分類(名称)
  , COALESCE(CASE WHEN info.medicine_type = ''1'' THEN class_medicine.class_name ELSE class_mix.class_name END, '''') AS class_name
  -- 薬剤分類(区分)
  , COALESCE(CASE WHEN info.medicine_type = ''1'' THEN class_medicine.class_type ELSE class_mix.class_type END, ''0'') AS class_type
FROM 
  medicine_info AS info
  LEFT JOIN mst_medicine AS medicine ON medicine.medicine_cd = info.medicine_cd :: INT
      AND info.medicine_type = ''1'' -- 1: 通常薬剤
  LEFT JOIN mst_medicine_class AS class_medicine ON class_medicine.class_cd = medicine.class_cd
  LEFT JOIN mst_medicine_mix AS medicine_mix ON medicine_mix.medicine_mix_cd = info.medicine_cd  :: INT
      AND info.medicine_type = ''2'' -- 2: 調製薬剤
  LEFT JOIN mst_medicine_class AS class_mix ON class_mix.class_cd = medicine_mix.class_cd
WHERE
  info.medicine_cd IS NOT NULL
ORDER BY info.medicine_cd :: INT ASC
)
SELECT
  T01.medicine_cd
	, T01.medicine_name
	, T01.amount
	, T01.unit
	, T01.cutoff
	, T01.procedure_name
	, T01.class_name
FROM 
  T01
WHERE
--  T01.is_shot = ''0'' -- 投薬情報(0：注射薬剤以外)
--AND T01.class_name like ''%内服%''
--AND T01.class_name not like ''%頓服%'' AND T01.class_name not like ''%外用%'' AND T01.class_name not like ''%自己注射%''
--AND T01.class_name like ''%頓服%''
--AND T01.class_name like ''%外用%''
--AND T01.class_name like ''%自己注射%''

  T01.is_shot = ''1'' -- 注射情報(1：注射薬剤)
--AND T01.procedure_name like ''%静注%''
--AND T01.procedure_name not like ''%筋注%''
--AND T01.procedure_name not like ''%皮内注%''
--AND T01.procedure_name not like ''%皮下注%''
--AND T01.procedure_name not like ''%点滴%''
--AND T01.procedure_name not like ''%特注%''

--AND T01.procedure_name like ''%筋注%''
--AND T01.procedure_name like ''%皮内注%''
--AND T01.procedure_name like ''%皮下注%''
--AND T01.procedure_name like ''%点滴%''
AND T01.procedure_name like ''%特注%''
ORDER BY T01.medicine_cd :: INT ASC', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(注射情報)(特注)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-468, 'WITH medicine_info AS (
  SELECT
    ''投与薬剤情報'' AS detail 
    , medi_info->>''cd'' AS medicine_cd
    , medi_info->>''name'' AS medicine_name
    , medi_info->>''amount'' AS amount
    , medi_info->>''unit'' AS unit
    , '''' AS cutoff
    -- 手技
    , medi_info->>''procedure_cd'' AS procedure_cd
    , medi_info->>''procedure_name'' AS procedure_name
    -- 薬剤区分:1: 通常薬剤、2: 調製薬剤
    , medi_info->>''medicine_type'' AS medicine_type
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi_info 
  WHERE
    ord_no = @ordNo
  UNION ALL
  SELECT
    ''愁訴情報'' AS detail
    , CASE WHEN treatment_info->>''medicine_cd'' IS NULL
         THEN treatment_info->>''treat_medicine_cd'' 
        ELSE treatment_info->>''medicine_cd'' 
      END AS medicine_cd
    , CASE WHEN treatment_info->>''medicine_cd'' IS NULL
        THEN treatment_info->>''treat_medicine_name'' 
        ELSE treatment_info->>''medicine_name'' 
        END AS medicine_name
    , treatment_info->>''amount'' AS amount
    , treatment_info->>''unit'' AS unit
    , '''' AS cutoff
    -- 手技
    , treatment_info->>''procedure_cd'' AS procedure_cd
    , treatment_info->>''procedure_name'' AS procedure_name
    -- 薬剤区分:1: 通常薬剤、2: 調製薬剤
    , treatment_info->>''medicine_type'' AS medicine_type
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) treatment_info 
  WHERE
    ord_no = @ordNo
),
T01 AS (SELECT
  info.*
  -- 注射:0：注射薬剤以外、1：注射薬剤
  , CASE WHEN info.medicine_type = ''1'' THEN COALESCE(medicine.is_shot, ''0'') ELSE COALESCE(medicine_mix.is_shot, ''0'') END AS is_shot
  -- 薬剤分類
  , CASE WHEN info.medicine_type = ''1'' THEN medicine.class_cd ELSE medicine_mix.class_cd END AS class_cd
  -- 薬剤分類(名称)
  , COALESCE(CASE WHEN info.medicine_type = ''1'' THEN class_medicine.class_name ELSE class_mix.class_name END, '''') AS class_name
  -- 薬剤分類(区分)
  , COALESCE(CASE WHEN info.medicine_type = ''1'' THEN class_medicine.class_type ELSE class_mix.class_type END, ''0'') AS class_type
FROM 
  medicine_info AS info
  LEFT JOIN mst_medicine AS medicine ON medicine.medicine_cd = info.medicine_cd :: INT
      AND info.medicine_type = ''1'' -- 1: 通常薬剤
  LEFT JOIN mst_medicine_class AS class_medicine ON class_medicine.class_cd = medicine.class_cd
  LEFT JOIN mst_medicine_mix AS medicine_mix ON medicine_mix.medicine_mix_cd = info.medicine_cd  :: INT
      AND info.medicine_type = ''2'' -- 2: 調製薬剤
  LEFT JOIN mst_medicine_class AS class_mix ON class_mix.class_cd = medicine_mix.class_cd
WHERE
  info.medicine_cd IS NOT NULL
ORDER BY info.medicine_cd :: INT ASC
)
SELECT
  T01.medicine_cd
	, T01.medicine_name
	, T01.amount
	, T01.unit
	, T01.cutoff
	, T01.procedure_name
	, T01.class_name
FROM 
  T01
WHERE
--  T01.is_shot = ''0'' -- 投薬情報(0：注射薬剤以外)
--AND T01.class_name like ''%内服%''
--AND T01.class_name not like ''%頓服%'' AND T01.class_name not like ''%外用%'' AND T01.class_name not like ''%自己注射%''
--AND T01.class_name like ''%頓服%''
--AND T01.class_name like ''%外用%''
--AND T01.class_name like ''%自己注射%''

  T01.is_shot = ''1'' -- 注射情報(1：注射薬剤)
--AND T01.procedure_name like ''%静注%''
--AND T01.procedure_name not like ''%筋注%''
--AND T01.procedure_name not like ''%皮内注%''
--AND T01.procedure_name not like ''%皮下注%''
--AND T01.procedure_name not like ''%点滴%''
--AND T01.procedure_name not like ''%特注%''

--AND T01.procedure_name like ''%筋注%''
--AND T01.procedure_name like ''%皮内注%''
--AND T01.procedure_name like ''%皮下注%''
AND T01.procedure_name like ''%点滴%''
--AND T01.procedure_name like ''%特注%''
ORDER BY T01.medicine_cd :: INT ASC', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(注射情報)点滴)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-467, 'WITH medicine_info AS (
  SELECT
    ''投与薬剤情報'' AS detail 
    , medi_info->>''cd'' AS medicine_cd
    , medi_info->>''name'' AS medicine_name
    , medi_info->>''amount'' AS amount
    , medi_info->>''unit'' AS unit
    , '''' AS cutoff
    -- 手技
    , medi_info->>''procedure_cd'' AS procedure_cd
    , medi_info->>''procedure_name'' AS procedure_name
    -- 薬剤区分:1: 通常薬剤、2: 調製薬剤
    , medi_info->>''medicine_type'' AS medicine_type
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi_info 
  WHERE
    ord_no = @ordNo
  UNION ALL
  SELECT
    ''愁訴情報'' AS detail
    , CASE WHEN treatment_info->>''medicine_cd'' IS NULL
         THEN treatment_info->>''treat_medicine_cd'' 
        ELSE treatment_info->>''medicine_cd'' 
      END AS medicine_cd
    , CASE WHEN treatment_info->>''medicine_cd'' IS NULL
        THEN treatment_info->>''treat_medicine_name'' 
        ELSE treatment_info->>''medicine_name'' 
        END AS medicine_name
    , treatment_info->>''amount'' AS amount
    , treatment_info->>''unit'' AS unit
    , '''' AS cutoff
    -- 手技
    , treatment_info->>''procedure_cd'' AS procedure_cd
    , treatment_info->>''procedure_name'' AS procedure_name
    -- 薬剤区分:1: 通常薬剤、2: 調製薬剤
    , treatment_info->>''medicine_type'' AS medicine_type
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) treatment_info 
  WHERE
    ord_no = @ordNo
),
T01 AS (SELECT
  info.*
  -- 注射:0：注射薬剤以外、1：注射薬剤
  , CASE WHEN info.medicine_type = ''1'' THEN COALESCE(medicine.is_shot, ''0'') ELSE COALESCE(medicine_mix.is_shot, ''0'') END AS is_shot
  -- 薬剤分類
  , CASE WHEN info.medicine_type = ''1'' THEN medicine.class_cd ELSE medicine_mix.class_cd END AS class_cd
  -- 薬剤分類(名称)
  , COALESCE(CASE WHEN info.medicine_type = ''1'' THEN class_medicine.class_name ELSE class_mix.class_name END, '''') AS class_name
  -- 薬剤分類(区分)
  , COALESCE(CASE WHEN info.medicine_type = ''1'' THEN class_medicine.class_type ELSE class_mix.class_type END, ''0'') AS class_type
FROM 
  medicine_info AS info
  LEFT JOIN mst_medicine AS medicine ON medicine.medicine_cd = info.medicine_cd :: INT
      AND info.medicine_type = ''1'' -- 1: 通常薬剤
  LEFT JOIN mst_medicine_class AS class_medicine ON class_medicine.class_cd = medicine.class_cd
  LEFT JOIN mst_medicine_mix AS medicine_mix ON medicine_mix.medicine_mix_cd = info.medicine_cd  :: INT
      AND info.medicine_type = ''2'' -- 2: 調製薬剤
  LEFT JOIN mst_medicine_class AS class_mix ON class_mix.class_cd = medicine_mix.class_cd
WHERE
  info.medicine_cd IS NOT NULL
ORDER BY info.medicine_cd :: INT ASC
)
SELECT
  T01.medicine_cd
	, T01.medicine_name
	, T01.amount
	, T01.unit
	, T01.cutoff
	, T01.procedure_name
	, T01.class_name
FROM 
  T01
WHERE
--  T01.is_shot = ''0'' -- 投薬情報(0：注射薬剤以外)
--AND T01.class_name like ''%内服%''
--AND T01.class_name not like ''%頓服%'' AND T01.class_name not like ''%外用%'' AND T01.class_name not like ''%自己注射%''
--AND T01.class_name like ''%頓服%''
--AND T01.class_name like ''%外用%''
--AND T01.class_name like ''%自己注射%''

  T01.is_shot = ''1'' -- 注射情報(1：注射薬剤)
--AND T01.procedure_name like ''%静注%''
--AND T01.procedure_name not like ''%筋注%''
--AND T01.procedure_name not like ''%皮内注%''
--AND T01.procedure_name not like ''%皮下注%''
--AND T01.procedure_name not like ''%点滴%''
--AND T01.procedure_name not like ''%特注%''

--AND T01.procedure_name like ''%筋注%''
AND T01.procedure_name like ''%皮内注%''
--AND T01.procedure_name like ''%皮下注%''
--AND T01.procedure_name like ''%点滴%''
--AND T01.procedure_name like ''%特注%''
ORDER BY T01.medicine_cd :: INT ASC', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(注射情報)(皮内注)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-466, 'WITH medicine_info AS (
  SELECT
    ''投与薬剤情報'' AS detail 
    , medi_info->>''cd'' AS medicine_cd
    , medi_info->>''name'' AS medicine_name
    , medi_info->>''amount'' AS amount
    , medi_info->>''unit'' AS unit
    , '''' AS cutoff
    -- 手技
    , medi_info->>''procedure_cd'' AS procedure_cd
    , medi_info->>''procedure_name'' AS procedure_name
    -- 薬剤区分:1: 通常薬剤、2: 調製薬剤
    , medi_info->>''medicine_type'' AS medicine_type
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi_info 
  WHERE
    ord_no = @ordNo
  UNION ALL
  SELECT
    ''愁訴情報'' AS detail
    , CASE WHEN treatment_info->>''medicine_cd'' IS NULL
         THEN treatment_info->>''treat_medicine_cd'' 
        ELSE treatment_info->>''medicine_cd'' 
      END AS medicine_cd
    , CASE WHEN treatment_info->>''medicine_cd'' IS NULL
        THEN treatment_info->>''treat_medicine_name'' 
        ELSE treatment_info->>''medicine_name'' 
        END AS medicine_name
    , treatment_info->>''amount'' AS amount
    , treatment_info->>''unit'' AS unit
    , '''' AS cutoff
    -- 手技
    , treatment_info->>''procedure_cd'' AS procedure_cd
    , treatment_info->>''procedure_name'' AS procedure_name
    -- 薬剤区分:1: 通常薬剤、2: 調製薬剤
    , treatment_info->>''medicine_type'' AS medicine_type
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) treatment_info 
  WHERE
    ord_no = @ordNo
),
T01 AS (SELECT
  info.*
  -- 注射:0：注射薬剤以外、1：注射薬剤
  , CASE WHEN info.medicine_type = ''1'' THEN COALESCE(medicine.is_shot, ''0'') ELSE COALESCE(medicine_mix.is_shot, ''0'') END AS is_shot
  -- 薬剤分類
  , CASE WHEN info.medicine_type = ''1'' THEN medicine.class_cd ELSE medicine_mix.class_cd END AS class_cd
  -- 薬剤分類(名称)
  , COALESCE(CASE WHEN info.medicine_type = ''1'' THEN class_medicine.class_name ELSE class_mix.class_name END, '''') AS class_name
  -- 薬剤分類(区分)
  , COALESCE(CASE WHEN info.medicine_type = ''1'' THEN class_medicine.class_type ELSE class_mix.class_type END, ''0'') AS class_type
FROM 
  medicine_info AS info
  LEFT JOIN mst_medicine AS medicine ON medicine.medicine_cd = info.medicine_cd :: INT
      AND info.medicine_type = ''1'' -- 1: 通常薬剤
  LEFT JOIN mst_medicine_class AS class_medicine ON class_medicine.class_cd = medicine.class_cd
  LEFT JOIN mst_medicine_mix AS medicine_mix ON medicine_mix.medicine_mix_cd = info.medicine_cd  :: INT
      AND info.medicine_type = ''2'' -- 2: 調製薬剤
  LEFT JOIN mst_medicine_class AS class_mix ON class_mix.class_cd = medicine_mix.class_cd
WHERE
  info.medicine_cd IS NOT NULL
ORDER BY info.medicine_cd :: INT ASC
)
SELECT
  T01.medicine_cd
	, T01.medicine_name
	, T01.amount
	, T01.unit
	, T01.cutoff
	, T01.procedure_name
	, T01.class_name
FROM 
  T01
WHERE
--  T01.is_shot = ''0'' -- 投薬情報(0：注射薬剤以外)
--AND T01.class_name like ''%内服%''
--AND T01.class_name not like ''%頓服%'' AND T01.class_name not like ''%外用%'' AND T01.class_name not like ''%自己注射%''
--AND T01.class_name like ''%頓服%''
--AND T01.class_name like ''%外用%''
--AND T01.class_name like ''%自己注射%''

  T01.is_shot = ''1'' -- 注射情報(1：注射薬剤)
--AND T01.procedure_name like ''%静注%''
--AND T01.procedure_name not like ''%筋注%''
--AND T01.procedure_name not like ''%皮内注%''
--AND T01.procedure_name not like ''%皮下注%''
--AND T01.procedure_name not like ''%点滴%''
--AND T01.procedure_name not like ''%特注%''

--AND T01.procedure_name like ''%筋注%''
--AND T01.procedure_name like ''%皮内注%''
AND T01.procedure_name like ''%皮下注%''
--AND T01.procedure_name like ''%点滴%''
--AND T01.procedure_name like ''%特注%''
ORDER BY T01.medicine_cd :: INT ASC', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(注射情報)(皮下注)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-465, 'WITH medicine_info AS (
  SELECT
    ''投与薬剤情報'' AS detail 
    , medi_info->>''cd'' AS medicine_cd
    , medi_info->>''name'' AS medicine_name
    , medi_info->>''amount'' AS amount
    , medi_info->>''unit'' AS unit
    , '''' AS cutoff
    -- 手技
    , medi_info->>''procedure_cd'' AS procedure_cd
    , medi_info->>''procedure_name'' AS procedure_name
    -- 薬剤区分:1: 通常薬剤、2: 調製薬剤
    , medi_info->>''medicine_type'' AS medicine_type
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi_info 
  WHERE
    ord_no = @ordNo
  UNION ALL
  SELECT
    ''愁訴情報'' AS detail
    , CASE WHEN treatment_info->>''medicine_cd'' IS NULL
         THEN treatment_info->>''treat_medicine_cd'' 
        ELSE treatment_info->>''medicine_cd'' 
      END AS medicine_cd
    , CASE WHEN treatment_info->>''medicine_cd'' IS NULL
        THEN treatment_info->>''treat_medicine_name'' 
        ELSE treatment_info->>''medicine_name'' 
        END AS medicine_name
    , treatment_info->>''amount'' AS amount
    , treatment_info->>''unit'' AS unit
    , '''' AS cutoff
    -- 手技
    , treatment_info->>''procedure_cd'' AS procedure_cd
    , treatment_info->>''procedure_name'' AS procedure_name
    -- 薬剤区分:1: 通常薬剤、2: 調製薬剤
    , treatment_info->>''medicine_type'' AS medicine_type
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) treatment_info 
  WHERE
    ord_no = @ordNo
),
T01 AS (SELECT
  info.*
  -- 注射:0：注射薬剤以外、1：注射薬剤
  , CASE WHEN info.medicine_type = ''1'' THEN COALESCE(medicine.is_shot, ''0'') ELSE COALESCE(medicine_mix.is_shot, ''0'') END AS is_shot
  -- 薬剤分類
  , CASE WHEN info.medicine_type = ''1'' THEN medicine.class_cd ELSE medicine_mix.class_cd END AS class_cd
  -- 薬剤分類(名称)
  , COALESCE(CASE WHEN info.medicine_type = ''1'' THEN class_medicine.class_name ELSE class_mix.class_name END, '''') AS class_name
  -- 薬剤分類(区分)
  , COALESCE(CASE WHEN info.medicine_type = ''1'' THEN class_medicine.class_type ELSE class_mix.class_type END, ''0'') AS class_type
FROM 
  medicine_info AS info
  LEFT JOIN mst_medicine AS medicine ON medicine.medicine_cd = info.medicine_cd :: INT
      AND info.medicine_type = ''1'' -- 1: 通常薬剤
  LEFT JOIN mst_medicine_class AS class_medicine ON class_medicine.class_cd = medicine.class_cd
  LEFT JOIN mst_medicine_mix AS medicine_mix ON medicine_mix.medicine_mix_cd = info.medicine_cd  :: INT
      AND info.medicine_type = ''2'' -- 2: 調製薬剤
  LEFT JOIN mst_medicine_class AS class_mix ON class_mix.class_cd = medicine_mix.class_cd
WHERE
  info.medicine_cd IS NOT NULL
ORDER BY info.medicine_cd :: INT ASC
)
SELECT
  T01.medicine_cd
	, T01.medicine_name
	, T01.amount
	, T01.unit
	, T01.cutoff
	, T01.procedure_name
	, T01.class_name
FROM 
  T01
WHERE
--  T01.is_shot = ''0'' -- 投薬情報(0：注射薬剤以外)
--AND T01.class_name like ''%内服%''
--AND T01.class_name not like ''%頓服%'' AND T01.class_name not like ''%外用%'' AND T01.class_name not like ''%自己注射%''
--AND T01.class_name like ''%頓服%''
--AND T01.class_name like ''%外用%''
--AND T01.class_name like ''%自己注射%''

  T01.is_shot = ''1'' -- 注射情報(1：注射薬剤)
--AND T01.procedure_name like ''%静注%''
--AND T01.procedure_name not like ''%筋注%''
--AND T01.procedure_name not like ''%皮内注%''
--AND T01.procedure_name not like ''%皮下注%''
--AND T01.procedure_name not like ''%点滴%''
--AND T01.procedure_name not like ''%特注%''

AND T01.procedure_name like ''%筋注%''
--AND T01.procedure_name like ''%皮内注%''
--AND T01.procedure_name like ''%皮下注%''
--AND T01.procedure_name like ''%点滴%''
--AND T01.procedure_name like ''%特注%''
ORDER BY T01.medicine_cd :: INT ASC', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(注射情報)(筋注)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-464, 'WITH medicine_info AS (
  SELECT
    ''投与薬剤情報'' AS detail 
    , medi_info->>''cd'' AS medicine_cd
    , medi_info->>''name'' AS medicine_name
    , medi_info->>''amount'' AS amount
    , medi_info->>''unit'' AS unit
    , '''' AS cutoff
    -- 手技
    , medi_info->>''procedure_cd'' AS procedure_cd
    , medi_info->>''procedure_name'' AS procedure_name
    -- 薬剤区分:1: 通常薬剤、2: 調製薬剤
    , medi_info->>''medicine_type'' AS medicine_type
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi_info 
  WHERE
    ord_no = @ordNo
  UNION ALL
  SELECT
    ''愁訴情報'' AS detail
    , CASE WHEN treatment_info->>''medicine_cd'' IS NULL
         THEN treatment_info->>''treat_medicine_cd'' 
        ELSE treatment_info->>''medicine_cd'' 
      END AS medicine_cd
    , CASE WHEN treatment_info->>''medicine_cd'' IS NULL
        THEN treatment_info->>''treat_medicine_name'' 
        ELSE treatment_info->>''medicine_name'' 
        END AS medicine_name
    , treatment_info->>''amount'' AS amount
    , treatment_info->>''unit'' AS unit
    , '''' AS cutoff
    -- 手技
    , treatment_info->>''procedure_cd'' AS procedure_cd
    , treatment_info->>''procedure_name'' AS procedure_name
    -- 薬剤区分:1: 通常薬剤、2: 調製薬剤
    , treatment_info->>''medicine_type'' AS medicine_type
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) treatment_info 
  WHERE
    ord_no = @ordNo
),
T01 AS (SELECT
  info.*
  -- 注射:0：注射薬剤以外、1：注射薬剤
  , CASE WHEN info.medicine_type = ''1'' THEN COALESCE(medicine.is_shot, ''0'') ELSE COALESCE(medicine_mix.is_shot, ''0'') END AS is_shot
  -- 薬剤分類
  , CASE WHEN info.medicine_type = ''1'' THEN medicine.class_cd ELSE medicine_mix.class_cd END AS class_cd
  -- 薬剤分類(名称)
  , COALESCE(CASE WHEN info.medicine_type = ''1'' THEN class_medicine.class_name ELSE class_mix.class_name END, '''') AS class_name
  -- 薬剤分類(区分)
  , COALESCE(CASE WHEN info.medicine_type = ''1'' THEN class_medicine.class_type ELSE class_mix.class_type END, ''0'') AS class_type
FROM 
  medicine_info AS info
  LEFT JOIN mst_medicine AS medicine ON medicine.medicine_cd = info.medicine_cd :: INT
      AND info.medicine_type = ''1'' -- 1: 通常薬剤
  LEFT JOIN mst_medicine_class AS class_medicine ON class_medicine.class_cd = medicine.class_cd
  LEFT JOIN mst_medicine_mix AS medicine_mix ON medicine_mix.medicine_mix_cd = info.medicine_cd  :: INT
      AND info.medicine_type = ''2'' -- 2: 調製薬剤
  LEFT JOIN mst_medicine_class AS class_mix ON class_mix.class_cd = medicine_mix.class_cd
WHERE
  info.medicine_cd IS NOT NULL
ORDER BY info.medicine_cd :: INT ASC
)
SELECT
  T01.medicine_cd
	, T01.medicine_name
	, T01.amount
	, T01.unit
	, T01.cutoff
	, T01.procedure_name
	, T01.class_name
FROM 
  T01
WHERE
--  T01.is_shot = ''0'' -- 投薬情報(0：注射薬剤以外)
--AND T01.class_name like ''%内服%''
--AND T01.class_name not like ''%頓服%'' AND T01.class_name not like ''%外用%'' AND T01.class_name not like ''%自己注射%''
--AND T01.class_name like ''%頓服%''
--AND T01.class_name like ''%外用%''
--AND T01.class_name like ''%自己注射%''

  T01.is_shot = ''1'' -- 注射情報(1：注射薬剤)
--AND T01.procedure_name like ''%静注%''
AND T01.procedure_name not like ''%筋注%''
AND T01.procedure_name not like ''%皮内注%''
AND T01.procedure_name not like ''%皮下注%''
AND T01.procedure_name not like ''%点滴%''
AND T01.procedure_name not like ''%特注%''

--AND T01.procedure_name like ''%筋注%''
--AND T01.procedure_name like ''%皮内注%''
--AND T01.procedure_name like ''%皮下注%''
--AND T01.procedure_name like ''%点滴%''
--AND T01.procedure_name like ''%特注%''
ORDER BY T01.medicine_cd :: INT ASC', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(注射情報)(静注)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-463, 'WITH medicine_info AS (
  SELECT
    ''投与薬剤情報'' AS detail 
    , medi_info->>''cd'' AS medicine_cd
    , medi_info->>''name'' AS medicine_name
    , medi_info->>''amount'' AS amount
    , medi_info->>''unit'' AS unit
    , '''' AS cutoff
    -- 手技
    , medi_info->>''procedure_cd'' AS procedure_cd
    , medi_info->>''procedure_name'' AS procedure_name
    -- 薬剤区分:1: 通常薬剤、2: 調製薬剤
    , medi_info->>''medicine_type'' AS medicine_type
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi_info 
  WHERE
    ord_no = @ordNo
  UNION ALL
  SELECT
    ''愁訴情報'' AS detail
    , CASE WHEN treatment_info->>''medicine_cd'' IS NULL
         THEN treatment_info->>''treat_medicine_cd'' 
        ELSE treatment_info->>''medicine_cd'' 
      END AS medicine_cd
    , CASE WHEN treatment_info->>''medicine_cd'' IS NULL
        THEN treatment_info->>''treat_medicine_name'' 
        ELSE treatment_info->>''medicine_name'' 
        END AS medicine_name
    , treatment_info->>''amount'' AS amount
    , treatment_info->>''unit'' AS unit
    , '''' AS cutoff
    -- 手技
    , treatment_info->>''procedure_cd'' AS procedure_cd
    , treatment_info->>''procedure_name'' AS procedure_name
    -- 薬剤区分:1: 通常薬剤、2: 調製薬剤
    , treatment_info->>''medicine_type'' AS medicine_type
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) treatment_info 
  WHERE
    ord_no = @ordNo
),
T01 AS (SELECT
  info.*
  -- 注射:0：注射薬剤以外、1：注射薬剤
  , CASE WHEN info.medicine_type = ''1'' THEN COALESCE(medicine.is_shot, ''0'') ELSE COALESCE(medicine_mix.is_shot, ''0'') END AS is_shot
  -- 薬剤分類
  , CASE WHEN info.medicine_type = ''1'' THEN medicine.class_cd ELSE medicine_mix.class_cd END AS class_cd
  -- 薬剤分類(名称)
  , COALESCE(CASE WHEN info.medicine_type = ''1'' THEN class_medicine.class_name ELSE class_mix.class_name END, '''') AS class_name
  -- 薬剤分類(区分)
  , COALESCE(CASE WHEN info.medicine_type = ''1'' THEN class_medicine.class_type ELSE class_mix.class_type END, ''0'') AS class_type
FROM 
  medicine_info AS info
  LEFT JOIN mst_medicine AS medicine ON medicine.medicine_cd = info.medicine_cd :: INT
      AND info.medicine_type = ''1'' -- 1: 通常薬剤
  LEFT JOIN mst_medicine_class AS class_medicine ON class_medicine.class_cd = medicine.class_cd
  LEFT JOIN mst_medicine_mix AS medicine_mix ON medicine_mix.medicine_mix_cd = info.medicine_cd  :: INT
      AND info.medicine_type = ''2'' -- 2: 調製薬剤
  LEFT JOIN mst_medicine_class AS class_mix ON class_mix.class_cd = medicine_mix.class_cd
WHERE
  info.medicine_cd IS NOT NULL
ORDER BY info.medicine_cd :: INT ASC
)
SELECT
  T01.medicine_cd
	, T01.medicine_name
	, T01.amount
	, T01.unit
	, T01.cutoff
	, T01.procedure_name
	, T01.class_name
FROM 
  T01
WHERE
  T01.is_shot = ''0'' -- 投薬情報(0：注射薬剤以外)
--AND T01.class_name like ''%内服%''
--AND T01.class_name not like ''%頓服%'' AND T01.class_name not like ''%外用%'' AND T01.class_name not like ''%自己注射%''
--AND T01.class_name like ''%頓服%''
--AND T01.class_name like ''%外用%''
AND T01.class_name like ''%自己注射%''

--  T01.is_shot = ''1'' -- 注射情報(1：注射薬剤)
--AND T01.procedure_name like ''%静注%''
--AND T01.procedure_name not like ''%筋注%''
--AND T01.procedure_name not like ''%皮内注%''
--AND T01.procedure_name not like ''%皮下注%''
--AND T01.procedure_name not like ''%点滴%''
--AND T01.procedure_name not like ''%特注%''

--AND T01.procedure_name like ''%筋注%''
--AND T01.procedure_name like ''%皮内注%''
--AND T01.procedure_name like ''%皮下注%''
--AND T01.procedure_name like ''%点滴%''
--AND T01.procedure_name like ''%特注%''
ORDER BY T01.medicine_cd :: INT ASC', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(投薬情報)(自己注射)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-462, 'WITH medicine_info AS (
  SELECT
    ''投与薬剤情報'' AS detail 
    , medi_info->>''cd'' AS medicine_cd
    , medi_info->>''name'' AS medicine_name
    , medi_info->>''amount'' AS amount
    , medi_info->>''unit'' AS unit
    , '''' AS cutoff
    -- 手技
    , medi_info->>''procedure_cd'' AS procedure_cd
    , medi_info->>''procedure_name'' AS procedure_name
    -- 薬剤区分:1: 通常薬剤、2: 調製薬剤
    , medi_info->>''medicine_type'' AS medicine_type
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi_info 
  WHERE
    ord_no = @ordNo
  UNION ALL
  SELECT
    ''愁訴情報'' AS detail
    , CASE WHEN treatment_info->>''medicine_cd'' IS NULL
         THEN treatment_info->>''treat_medicine_cd'' 
        ELSE treatment_info->>''medicine_cd'' 
      END AS medicine_cd
    , CASE WHEN treatment_info->>''medicine_cd'' IS NULL
        THEN treatment_info->>''treat_medicine_name'' 
        ELSE treatment_info->>''medicine_name'' 
        END AS medicine_name
    , treatment_info->>''amount'' AS amount
    , treatment_info->>''unit'' AS unit
    , '''' AS cutoff
    -- 手技
    , treatment_info->>''procedure_cd'' AS procedure_cd
    , treatment_info->>''procedure_name'' AS procedure_name
    -- 薬剤区分:1: 通常薬剤、2: 調製薬剤
    , treatment_info->>''medicine_type'' AS medicine_type
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) treatment_info 
  WHERE
    ord_no = @ordNo
),
T01 AS (SELECT
  info.*
  -- 注射:0：注射薬剤以外、1：注射薬剤
  , CASE WHEN info.medicine_type = ''1'' THEN COALESCE(medicine.is_shot, ''0'') ELSE COALESCE(medicine_mix.is_shot, ''0'') END AS is_shot
  -- 薬剤分類
  , CASE WHEN info.medicine_type = ''1'' THEN medicine.class_cd ELSE medicine_mix.class_cd END AS class_cd
  -- 薬剤分類(名称)
  , COALESCE(CASE WHEN info.medicine_type = ''1'' THEN class_medicine.class_name ELSE class_mix.class_name END, '''') AS class_name
  -- 薬剤分類(区分)
  , COALESCE(CASE WHEN info.medicine_type = ''1'' THEN class_medicine.class_type ELSE class_mix.class_type END, ''0'') AS class_type
FROM 
  medicine_info AS info
  LEFT JOIN mst_medicine AS medicine ON medicine.medicine_cd = info.medicine_cd :: INT
      AND info.medicine_type = ''1'' -- 1: 通常薬剤
  LEFT JOIN mst_medicine_class AS class_medicine ON class_medicine.class_cd = medicine.class_cd
  LEFT JOIN mst_medicine_mix AS medicine_mix ON medicine_mix.medicine_mix_cd = info.medicine_cd  :: INT
      AND info.medicine_type = ''2'' -- 2: 調製薬剤
  LEFT JOIN mst_medicine_class AS class_mix ON class_mix.class_cd = medicine_mix.class_cd
WHERE
  info.medicine_cd IS NOT NULL
ORDER BY info.medicine_cd :: INT ASC
)
SELECT
  T01.medicine_cd
	, T01.medicine_name
	, T01.amount
	, T01.unit
	, T01.cutoff
	, T01.procedure_name
	, T01.class_name
FROM 
  T01
WHERE
  T01.is_shot = ''0'' -- 投薬情報(0：注射薬剤以外)
--AND T01.class_name like ''%内服%''
--AND T01.class_name not like ''%頓服%'' AND T01.class_name not like ''%外用%'' AND T01.class_name not like ''%自己注射%''
--AND T01.class_name like ''%頓服%''
AND T01.class_name like ''%外用%''
--AND T01.class_name like ''%自己注射%''

--  T01.is_shot = ''1'' -- 注射情報(1：注射薬剤)
--AND T01.procedure_name like ''%静注%''
--AND T01.procedure_name not like ''%筋注%''
--AND T01.procedure_name not like ''%皮内注%''
--AND T01.procedure_name not like ''%皮下注%''
--AND T01.procedure_name not like ''%点滴%''
--AND T01.procedure_name not like ''%特注%''

--AND T01.procedure_name like ''%筋注%''
--AND T01.procedure_name like ''%皮内注%''
--AND T01.procedure_name like ''%皮下注%''
--AND T01.procedure_name like ''%点滴%''
--AND T01.procedure_name like ''%特注%''
ORDER BY T01.medicine_cd :: INT ASC', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(投薬情報)(外用)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-461, 'WITH medicine_info AS (
  SELECT
    ''投与薬剤情報'' AS detail 
    , medi_info->>''cd'' AS medicine_cd
    , medi_info->>''name'' AS medicine_name
    , medi_info->>''amount'' AS amount
    , medi_info->>''unit'' AS unit
    , '''' AS cutoff
    -- 手技
    , medi_info->>''procedure_cd'' AS procedure_cd
    , medi_info->>''procedure_name'' AS procedure_name
    -- 薬剤区分:1: 通常薬剤、2: 調製薬剤
    , medi_info->>''medicine_type'' AS medicine_type
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi_info 
  WHERE
    ord_no = @ordNo
  UNION ALL
  SELECT
    ''愁訴情報'' AS detail
    , CASE WHEN treatment_info->>''medicine_cd'' IS NULL
         THEN treatment_info->>''treat_medicine_cd'' 
        ELSE treatment_info->>''medicine_cd'' 
      END AS medicine_cd
    , CASE WHEN treatment_info->>''medicine_cd'' IS NULL
        THEN treatment_info->>''treat_medicine_name'' 
        ELSE treatment_info->>''medicine_name'' 
        END AS medicine_name
    , treatment_info->>''amount'' AS amount
    , treatment_info->>''unit'' AS unit
    , '''' AS cutoff
    -- 手技
    , treatment_info->>''procedure_cd'' AS procedure_cd
    , treatment_info->>''procedure_name'' AS procedure_name
    -- 薬剤区分:1: 通常薬剤、2: 調製薬剤
    , treatment_info->>''medicine_type'' AS medicine_type
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) treatment_info 
  WHERE
    ord_no = @ordNo
),
T01 AS (SELECT
  info.*
  -- 注射:0：注射薬剤以外、1：注射薬剤
  , CASE WHEN info.medicine_type = ''1'' THEN COALESCE(medicine.is_shot, ''0'') ELSE COALESCE(medicine_mix.is_shot, ''0'') END AS is_shot
  -- 薬剤分類
  , CASE WHEN info.medicine_type = ''1'' THEN medicine.class_cd ELSE medicine_mix.class_cd END AS class_cd
  -- 薬剤分類(名称)
  , COALESCE(CASE WHEN info.medicine_type = ''1'' THEN class_medicine.class_name ELSE class_mix.class_name END, '''') AS class_name
  -- 薬剤分類(区分)
  , COALESCE(CASE WHEN info.medicine_type = ''1'' THEN class_medicine.class_type ELSE class_mix.class_type END, ''0'') AS class_type
FROM 
  medicine_info AS info
  LEFT JOIN mst_medicine AS medicine ON medicine.medicine_cd = info.medicine_cd :: INT
      AND info.medicine_type = ''1'' -- 1: 通常薬剤
  LEFT JOIN mst_medicine_class AS class_medicine ON class_medicine.class_cd = medicine.class_cd
  LEFT JOIN mst_medicine_mix AS medicine_mix ON medicine_mix.medicine_mix_cd = info.medicine_cd  :: INT
      AND info.medicine_type = ''2'' -- 2: 調製薬剤
  LEFT JOIN mst_medicine_class AS class_mix ON class_mix.class_cd = medicine_mix.class_cd
WHERE
  info.medicine_cd IS NOT NULL
ORDER BY info.medicine_cd :: INT ASC
)
SELECT
  T01.medicine_cd
	, T01.medicine_name
	, T01.amount
	, T01.unit
	, T01.cutoff
	, T01.procedure_name
	, T01.class_name
FROM 
  T01
WHERE
  T01.is_shot = ''0'' -- 投薬情報(0：注射薬剤以外)
--AND T01.class_name like ''%内服%''
--AND T01.class_name not like ''%頓服%'' AND T01.class_name not like ''%外用%'' AND T01.class_name not like ''%自己注射%''
AND T01.class_name like ''%頓服%''
--AND T01.class_name like ''%外用%''
--AND T01.class_name like ''%自己注射%''

--  T01.is_shot = ''1'' -- 注射情報(1：注射薬剤)
--AND T01.procedure_name like ''%静注%''
--AND T01.procedure_name not like ''%筋注%''
--AND T01.procedure_name not like ''%皮内注%''
--AND T01.procedure_name not like ''%皮下注%''
--AND T01.procedure_name not like ''%点滴%''
--AND T01.procedure_name not like ''%特注%''

--AND T01.procedure_name like ''%筋注%''
--AND T01.procedure_name like ''%皮内注%''
--AND T01.procedure_name like ''%皮下注%''
--AND T01.procedure_name like ''%点滴%''
--AND T01.procedure_name like ''%特注%''
ORDER BY T01.medicine_cd :: INT ASC', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(投薬情報)(頓服)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-460, 'WITH medicine_info AS (
  SELECT
    ''投与薬剤情報'' AS detail 
    , medi_info->>''cd'' AS medicine_cd
    , medi_info->>''name'' AS medicine_name
    , medi_info->>''amount'' AS amount
    , medi_info->>''unit'' AS unit
    , '''' AS cutoff
    -- 手技
    , medi_info->>''procedure_cd'' AS procedure_cd
    , medi_info->>''procedure_name'' AS procedure_name
    -- 薬剤区分:1: 通常薬剤、2: 調製薬剤
    , medi_info->>''medicine_type'' AS medicine_type
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi_info 
  WHERE
    ord_no = @ordNo
  UNION ALL
  SELECT
    ''愁訴情報'' AS detail
    , CASE WHEN treatment_info->>''medicine_cd'' IS NULL
         THEN treatment_info->>''treat_medicine_cd'' 
        ELSE treatment_info->>''medicine_cd'' 
      END AS medicine_cd
    , CASE WHEN treatment_info->>''medicine_cd'' IS NULL
        THEN treatment_info->>''treat_medicine_name'' 
        ELSE treatment_info->>''medicine_name'' 
        END AS medicine_name
    , treatment_info->>''amount'' AS amount
    , treatment_info->>''unit'' AS unit
    , '''' AS cutoff
    -- 手技
    , treatment_info->>''procedure_cd'' AS procedure_cd
    , treatment_info->>''procedure_name'' AS procedure_name
    -- 薬剤区分:1: 通常薬剤、2: 調製薬剤
    , treatment_info->>''medicine_type'' AS medicine_type
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) treatment_info 
  WHERE
    ord_no = @ordNo
),
T01 AS (SELECT
  info.*
  -- 注射:0：注射薬剤以外、1：注射薬剤
  , CASE WHEN info.medicine_type = ''1'' THEN COALESCE(medicine.is_shot, ''0'') ELSE COALESCE(medicine_mix.is_shot, ''0'') END AS is_shot
  -- 薬剤分類
  , CASE WHEN info.medicine_type = ''1'' THEN medicine.class_cd ELSE medicine_mix.class_cd END AS class_cd
  -- 薬剤分類(名称)
  , COALESCE(CASE WHEN info.medicine_type = ''1'' THEN class_medicine.class_name ELSE class_mix.class_name END, '''') AS class_name
  -- 薬剤分類(区分)
  , COALESCE(CASE WHEN info.medicine_type = ''1'' THEN class_medicine.class_type ELSE class_mix.class_type END, ''0'') AS class_type
FROM 
  medicine_info AS info
  LEFT JOIN mst_medicine AS medicine ON medicine.medicine_cd = info.medicine_cd :: INT
      AND info.medicine_type = ''1'' -- 1: 通常薬剤
  LEFT JOIN mst_medicine_class AS class_medicine ON class_medicine.class_cd = medicine.class_cd
  LEFT JOIN mst_medicine_mix AS medicine_mix ON medicine_mix.medicine_mix_cd = info.medicine_cd  :: INT
      AND info.medicine_type = ''2'' -- 2: 調製薬剤
  LEFT JOIN mst_medicine_class AS class_mix ON class_mix.class_cd = medicine_mix.class_cd
WHERE
  info.medicine_cd IS NOT NULL
ORDER BY info.medicine_cd :: INT ASC
)
SELECT
  T01.medicine_cd
	, T01.medicine_name
	, T01.amount
	, T01.unit
	, T01.cutoff
	, T01.procedure_name
	, T01.class_name
FROM 
  T01
WHERE
  T01.is_shot = ''0'' -- 投薬情報(0：注射薬剤以外)
--AND T01.class_name like ''%内服%''
AND T01.class_name not like ''%頓服%'' AND T01.class_name not like ''%外用%'' AND T01.class_name not like ''%自己注射%''
--AND T01.class_name like ''%頓服%''
--AND T01.class_name like ''%外用%''
--AND T01.class_name like ''%自己注射%''

--  T01.is_shot = ''1'' -- 注射情報(1：注射薬剤)
--AND T01.procedure_name like ''%静注%''
--AND T01.procedure_name not like ''%筋注%''
--AND T01.procedure_name not like ''%皮内注%''
--AND T01.procedure_name not like ''%皮下注%''
--AND T01.procedure_name not like ''%点滴%''
--AND T01.procedure_name not like ''%特注%''

--AND T01.procedure_name like ''%筋注%''
--AND T01.procedure_name like ''%皮内注%''
--AND T01.procedure_name like ''%皮下注%''
--AND T01.procedure_name like ''%点滴%''
--AND T01.procedure_name like ''%特注%''
ORDER BY T01.medicine_cd :: INT ASC', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(投薬情報)(内服)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-459, 'SELECT
  T01.ind_user_id -- 入力者コード
  , T01.ind_user_name -- 入力者氏名
  , T01.rst_start_date -- 治療開始日時
  , T01.up_date -- 更新日時
  , T01.rst_end_date -- 治療終了日時
  , journal.coop_ord_no || ''00'' AS order_id00 --投薬情報:内服
  , journal.coop_ord_no || ''01'' AS order_id01 --投薬情報:頓服
  , journal.coop_ord_no || ''02'' AS order_id02 --投薬情報:外用
  , journal.coop_ord_no || ''03'' AS order_id03 --投薬情報:自己注射
  , journal.coop_ord_no || ''20'' AS order_id20 --注射情報:静注
  , journal.coop_ord_no || ''21'' AS order_id21 --注射情報:静静注
  , journal.coop_ord_no || ''22'' AS order_id22 --注射情報:静皮下注
  , journal.coop_ord_no || ''23'' AS order_id23 --注射情報:静皮内注
  , journal.coop_ord_no || ''24'' AS order_id24 --注射情報:静点滴
  , journal.coop_ord_no || ''25'' AS order_id25 --注射情報:静特注
  , journal.coop_ord_no || ''30'' AS order_id30 --処置・治療項目情報:処置
  , journal.coop_ord_no || ''40'' AS order_id40 --処置・酸素情報:処置
  , journal.coop_ord_no || ''31'' AS order_id31 --処置・人工腎臓以外（夜間・休日加算）情報:処置
  , journal.coop_ord_no || ''32'' AS order_id32 --処置・人工腎臓以外（導入期加算）情報:処置
  , journal.coop_ord_no || ''41'' AS order_id41 --医学管理料情報:診察
  , journal.coop_ord_no || ''42'' AS order_id42 --医学管理料情報:診察
  , journal.coop_ord_no || ''43'' AS order_id43 --医学管理料情報:診察
  , journal.coop_ord_no || ''44'' AS order_id44 --医学管理料情報:診察
  , journal.coop_ord_no || ''45'' AS order_id45 --医学管理料情報:診察
  , journal.coop_ord_no || ''46'' AS order_id46 --医学管理料情報:診察
  , journal.coop_ord_no || ''47'' AS order_id47 --医学管理料情報:診察
  , journal.coop_ord_no || ''48'' AS order_id48 --医学管理料情報:診察
  , journal.coop_ord_no || ''49'' AS order_id49 --医学管理料情報:診察
  , journal.coop_ord_no || ''50'' AS order_id50 --手術・麻酔情報:手術・麻酔
  , journal.coop_ord_no || ''60'' AS order_id60 --検査情報:検査
  , journal.coop_ord_no || ''61'' AS order_id61 --検査情報:検査
  , journal.coop_ord_no || ''62'' AS order_id62 --検査情報:検査
  , journal.coop_ord_no || ''63'' AS order_id63 --検査情報:検査
  , journal.coop_ord_no || ''64'' AS order_id64 --検査情報:検査
  , journal.coop_ord_no || ''65'' AS order_id65 --検査情報:検査
  , journal.coop_ord_no || ''66'' AS order_id66 --検査情報:検査
  , journal.coop_ord_no || ''67'' AS order_id67 --検査情報:検査
  , journal.coop_ord_no || ''68'' AS order_id68 --検査情報:検査
  , journal.coop_ord_no || ''69'' AS order_id69 --検査情報:検査
FROM
  (
    (SELECT
     ''1'' AS staff_flag
     , medi_info->>''ind_user_id'' AS ind_user_id
     , (medi_info->>''ind_user_last_name'' :: TEXT) || ''　'' || (medi_info->>''ind_user_first_name'' :: TEXT) AS ind_user_name
     , TO_CHAR(ord.rst_start_date, ''YYYYMMDDHH24MISS'') AS rst_start_date
     , TO_CHAR(ord.up_date, ''YYYYMMDDHH24MISS'') AS up_date
     , TO_CHAR(ord.rst_end_date, ''YYYYMMDDHH24MISS'') AS rst_end_date
    FROM
      ord_main AS ord
      CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi_info -- 投与薬剤情報
    WHERE
      ord_no = @ordNo
    ORDER BY (medi_info->>''no'') :: INT ASC
    LIMIT 1)
    UNION
    (SELECT
     ''2'' AS staff_flag
     , treat_staff_info->>''treat_staff_cd'' AS ind_user_id
     , REPLACE(treat_staff_info->>''treat_staff_name'', '' '', ''　'') AS ind_user_name
     , TO_CHAR(ord.rst_start_date, ''YYYYMMDDHH24MISS'') AS rst_start_date
     , TO_CHAR(ord.up_date, ''YYYYMMDDHH24MISS'') AS up_date
     , TO_CHAR(ord.rst_end_date, ''YYYYMMDDHH24MISS'') AS rst_end_date
    FROM
      ord_main AS ord
      CROSS JOIN LATERAL json_array_elements(ord.rst_treat_staff_info ::json) treat_staff_info -- 愁訴処置者情報
    WHERE
      ord_no = @ordNo
    ORDER BY (treat_staff_info->>''ctl_no'') :: INT ASC, (treat_staff_info->>''row_no'') :: INT ASC
    LIMIT 1)
    ORDER BY staff_flag ASC
    LIMIT 1
  ) AS T01,
  sys_coop_journal AS journal
WHERE
  journal.ctl_no = @ctlNo', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(処方入力情報)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-458, 'WITH staff_info AS ( 
  SELECT
    staff_info ->> ''staff_cd'' AS staff_cd 
  FROM
    pat_main AS pat 
    CROSS JOIN LATERAL json_array_elements(pat.charge_staff_info ::json) staff_info 
  WHERE
    pat.pat_id = @patId
    AND staff_info ->> ''is_main'' = ''1'' 
  ORDER BY
    staff_info ->> ''ctl_no'' ASC 
  LIMIT 1
), 
memo_info AS ( 
  SELECT
    string_agg(replace(replace(memo_info->>''content'', CHR(10), ''''), CHR(13), ''''), ''　'') AS memo
  FROM
    pat_main AS pat 
    CROSS JOIN LATERAL json_array_elements(pat.pat_memo_info ::json) memo_info 
  WHERE
    pat.pat_id = @patId
    AND memo_info->>''content'' IS NOT NULL
) 
SELECT
  ord.rst_start_date AS start_date   --透析開始日時
  , TO_CHAR(ord.rst_start_date, ''YYYYMMDDHH24MISS'') AS start_date14
  , CASE 
    WHEN ord.up_user_id IS NOT NULL AND LENGTH(ord.up_user_id ::TEXT) <> 0 THEN 
      ord.up_user_id 
    WHEN ord.rst_charge_user_info ->> ''user_id_1'' IS NOT NULL AND LENGTH(ord.rst_charge_user_info ->> ''user_id_1'' ::TEXT) <> 0 THEN 
      (ord.rst_charge_user_info ->> ''user_id_1'') :: BIGINT
    ELSE (SELECT staff_cd :: BIGINT FROM staff_info) 
    END AS staff_cd   -- 担当医
  , mcs.in_hospital_cd_1 AS course_cd   --診療科コード１
  , mcs.course_name AS course_name   --診療科名
	, (SELECT memo FROM memo_info) AS memo -- メモ
FROM
  ord_main as ord
  LEFT OUTER JOIN mst_course AS mcs ON mcs.course_cd = ord.rst_course_cd
WHERE
  ord.ord_no = @ordNo  
', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(患者情報)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
