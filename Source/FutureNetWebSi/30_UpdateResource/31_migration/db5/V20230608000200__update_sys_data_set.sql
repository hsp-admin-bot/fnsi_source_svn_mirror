DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (7102,9621);
DELETE FROM "ntss"."sys_data_set" WHERE sql_cd = 7104;
DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (9618,9627,9619,9616,9617,9629);
DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (1014,1015,1011,1010);


INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7102, 'with nameSplit as (select split_part(''@otherContactInfo.lastName'' ,'' '', 1) as lastName,
                          split_part(''@otherContactInfo.lastName'' ,'' '', 2) as firstName),
     dup as (select (case when count(1) >= 1 then 1 else 0 end) as checkDup
                FROM pat_personal_main
                 CROSS JOIN jsonb_array_elements(personal_info_decrypt_jsonb(other_contact_info)) WITH ORDINALITY arr(j, idx), nameSplit
                    WHERE is_del = ''0''
                      AND hosp_pat_id = ''@hospPatId''
                      and (((j ->> ''first_name'')::text = nameSplit.firstName
                                   and (j ->> ''last_name'')::text = nameSplit.lastName)
                        or (j ->> ''last_name'')::text = ''@otherContactInfo.lastName''))
UPDATE pat_personal_main
SET 
	up_date = CURRENT_TIMESTAMP,
other_contact_info = (CASE
            ''@otherContactInfoFlg''
             WHEN '''' THEN
                 ''@otherContactInfoValue''
             ELSE (case when ''@otherContactInfo.relationName'' <> ''本人'' and dup.checkDup = ''0'' then other_contact_info || jsonb_build_object(
                 ''ctl_no'',''@otherContactInfo.ctlNo''
                 ,''disp_order'',''@otherContactInfo.dispOrder''
                 ,''is_key_person'',''@otherContactInfo.isKeyPerson''
                 ,''pat_id'',''@otherContactInfo.patId''
                 ,''last_name'',nameSplit.lastName
                 ,''first_name'',nameSplit.firstName
                 ,''last_name_kana'',''@otherContactInfo.lastNmKana''
                 ,''first_name_kana'',''@otherContactInfo.firstNmKana''
                 ,''relation_cd'',CASE ''@relationCd'' WHEN ''@''||''relationCd'' THEN null ELSE ''@relationCd'' END
                 ,''relation_name'',''@otherContactInfo.relationName''
                 ,''zip_cd'',''@otherContactInfo.zipCd''
                 ,''address'',''@otherContactInfo.address''
                 ,''e_mail'',''@otherContactInfo.eMail''
                 ,''work_name'',''@otherContactInfo.workName''
                 ,''work_tel'',''@otherContactInfo.workTel''
                 ,''tel1'',''@otherContactInfo.tel1''
                 ,''tel2'',''@otherContactInfo.tel2''
                 ,''fax'',''@otherContactInfo.fax''
                 ,''memo1'',''@otherContactInfo.memo1''
                 ,''memo2'',''@otherContactInfo.memo2''
) else ''@otherContactInfoValue'' end)
            END)::jsonb,
    pat_contact_info   = (CASE
                              when
                                  ''@otherContactInfoFlg'' <> '''' and ''@otherContactInfo.relationName'' = ''本人''
                                  THEN
                                  ''
                                  {
                                    "fax": "@otherContactInfo.fax",
                                    "tel1": "@otherContactInfo.tel1",
                                    "tel2": "@otherContactInfo.tel2",
                                    "memo1": "@otherContactInfo.memo1",
                                    "memo2": "@otherContactInfo.memo2",
                                    "e_mail": "@otherContactInfo.eMail",
                                    "zip_cd": "@otherContactInfo.zipCd",
                                    "address": "@otherContactInfo.address",
                                    "work_tel": "@otherContactInfo.workTel",
                                    "work_name": "@otherContactInfo.workName",
                                    "work_address": "@otherContactInfo.workAddress"
                                  }
                                  '' :: jsonb
                              ELSE pat_contact_info
        END)
from dup,nameSplit
WHERE is_del = ''0''
  AND hosp_pat_id = ''@hospPatId''
  AND facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(連絡先情報)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, '[{"sql_cd": 9620, "field_name": "relation_cd", "replace_var": "@relationCd"}]');
  
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9621, 'with nameSplit as (select split_part(''@otherContactInfo.lastName'' ,'' '', 1) as lastName,
                          split_part(''@otherContactInfo.lastName'' ,'' '', 2) as firstName),
     oldInfo as (select (other_contact_info ->> (idx - 1)::int)::json AS oldInfo
                 FROM pat_personal_main CROSS JOIN jsonb_array_elements(personal_info_decrypt_jsonb(other_contact_info)) WITH ORDINALITY arr(j, idx), nameSplit
                 WHERE (((j ->> ''first_name'')::text = nameSplit.firstName
               and (j ->> ''last_name'')::text = nameSplit.lastName)
    or (j ->> ''last_name'')::text = ''@otherContactInfo.lastName'')
                   and is_del = ''0''
                   AND hosp_pat_id = ''@hospPatId''
                   AND facility_cd = ''@facilityCd'')
UPDATE pat_personal_main
SET 
	up_date = CURRENT_TIMESTAMP,
other_contact_info = REPLACE(other_contact_info::text, oldInfo.oldInfo::text, jsonb_build_object(
                 ''ctl_no'',''@otherContactInfo.ctlNo''
                 ,''disp_order'',''@otherContactInfo.dispOrder''
                 ,''is_key_person'',''@otherContactInfo.isKeyPerson''
                 ,''pat_id'',''@otherContactInfo.patId''
                 ,''last_name'',nameSplit.lastName
                 ,''first_name'',nameSplit.firstName
                 ,''last_name_kana'',''@otherContactInfo.lastNmKana''
                 ,''first_name_kana'',''@otherContactInfo.firstNmKana''
                 ,''relation_cd'',CASE ''@relationCd'' WHEN ''@''||''relationCd'' THEN null ELSE ''@relationCd'' END
                 ,''relation_name'',''@otherContactInfo.relationName''
                 ,''zip_cd'',''@otherContactInfo.zipCd''
                 ,''address'',''@otherContactInfo.address''
                 ,''e_mail'',''@otherContactInfo.eMail''
                 ,''work_name'',''@otherContactInfo.workName''
                 ,''work_tel'',''@otherContactInfo.workTel''
                 ,''tel1'',''@otherContactInfo.tel1''
                 ,''tel2'',''@otherContactInfo.tel2''
                 ,''fax'',''@otherContactInfo.fax''
                 ,''memo1'',''@otherContactInfo.memo1''
                 ,''memo2'',''@otherContactInfo.memo2''
)::text)::jsonb
from nameSplit,oldInfo
WHERE is_del = ''0''
  AND hosp_pat_id = ''@hospPatId''
  AND facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(連絡先情報)', '2022-06-27 12:39:15.173', CURRENT_TIMESTAMP, '[{"sql_cd": 9620, "field_name": "relation_cd", "replace_var": "@relationCd"}]');

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7104, 'SELECT dialysis_difficulty_cd as dialysis_difficulty_cd_no FROM mst_dialysis_difficulty WHERE  in_hospital_cd_1 = @dialDiffComInfo.dialDiffCd AND facility_cd = @facilityCd
union
select 0 as dialysis_difficulty_cd_no
order by dialysis_difficulty_cd_no desc nulls last
limit 1', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の取得', '2022-06-27 12:39:22.557', CURRENT_TIMESTAMP, NULL);

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9627, 'WITH check_taboo_allergy_cd as (select (case position('','' in ''@tabooAllergyInfo.tabooAllergyCd'')
                                            when 0 then false
                                            else true end) as ctac)
   , tabooAllergyCdInfo AS (SELECT (case
                                        when ctac then split_part(''@tabooAllergyInfo.tabooAllergyCd'', '','', 1)
                                        else '''' end)                                 AS cd
                                 , (case
                                        when ctac then split_part(''@tabooAllergyInfo.tabooAllergyCd'', '','', 2)
                                        else ''5'' end)                                AS type
                            from check_taboo_allergy_cd)
   , newTabooAllergyInfo AS (SELECT ''【分類】薬剤アレルギー'' || E''\n'' || (CASE WHEN ''@tabooAllergyInfo.memo'' != ''''
                                                     THEN ''【内容】''||''@tabooAllergyInfo.memo''
																										 ELSE '''' END) ::TEXT                    AS memo
                                  , COALESCE(NULLIF(''@nextCtlNo3'', ''''), ''1'')            AS ctl_no
                                  , ''@tabooAllergyInfo.content''::TEXT                   AS content
                                  , COALESCE(NULLIF(''@nextCtlNo3'', ''''), ''0'')            AS disp_order
                                  , type ::TEXT                                         AS category_class
                                  , cd                                                  AS taboo_allergy_cd
                                  , ''@tabooAllergyInfo.tabooAllergyClass''::TEXT         AS taboo_allergy_class
                             FROM tabooAllergyCdInfo)
UPDATE pat_main
SET 
	up_date = CURRENT_TIMESTAMP,
taboo_allergy_info = taboo_allergy_info || jsonb_build_object(''memo'', memo,
                      ''ctl_no'', ctl_no::integer,
                      ''content'', content,
                      ''disp_order'', disp_order::integer,
                      ''category_class'', category_class,
                      ''taboo_allergy_cd'', nullif(taboo_allergy_cd, ''''),
                      ''taboo_allergy_class'', taboo_allergy_class,
											''new_flag'',1) FROM newTabooAllergyInfo WHERE is_del = ''0''
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(薬剤アレルギー情報)', '2022-06-09 12:45:07.732', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9618, 'UPDATE pat_main
SET 
	up_date = CURRENT_TIMESTAMP,
taboo_allergy_info = taboo_allergy_info || jsonb_build_object(''memo'', ''【分類】食物アレルギー'' || E''\n'' || (CASE WHEN ''@tabooAllergyInfo.memo'' != ''''
                                                     THEN ''【内容】''||''@tabooAllergyInfo.memo''
																										 ELSE '''' END) ::TEXT ,
                      ''ctl_no'', COALESCE(NULLIF(''@nextCtlNo3'', ''''), ''1'')::integer,
                      ''content'', ''@tabooAllergyInfo.content''::TEXT,
                      ''disp_order'', COALESCE(NULLIF(''@nextCtlNo3'', ''''), ''0'')::integer,
                      ''category_class'', ''@tabooAllergyInfo.categoryClass''::TEXT,
                      ''taboo_allergy_cd'', ''@tabooAllergyInfo.tabooAllergyCd'',
                      ''taboo_allergy_class'', ''@tabooAllergyInfo.tabooAllergyClass''::TEXT,
											''new_flag'',1) WHERE is_del = ''0''
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(食物アレルギー情報)', '2022-07-12 02:55:43.381', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9619, 'UPDATE pat_main
SET 
	up_date = CURRENT_TIMESTAMP,
taboo_allergy_info = taboo_allergy_info || jsonb_build_object(''memo'', ''【分類】造影剤アレルギー'' || E''\n'' || (CASE WHEN ''@tabooAllergyInfo.memo'' != ''''
                                                     THEN ''【内容】''||''@tabooAllergyInfo.memo''
																										 ELSE '''' END) ::TEXT ,
                      ''ctl_no'', COALESCE(NULLIF(''@nextCtlNo3'', ''''), ''1'')::integer,
                      ''content'', ''@tabooAllergyInfo.content''::TEXT,
                      ''disp_order'', COALESCE(NULLIF(''@nextCtlNo3'', ''''), ''0'')::integer,
                      ''category_class'', ''@tabooAllergyInfo.categoryClass''::TEXT,
                      ''taboo_allergy_cd'', ''@tabooAllergyInfo.tabooAllergyCd'',
                      ''taboo_allergy_class'', ''@tabooAllergyInfo.tabooAllergyClass''::TEXT,
											''new_flag'',1) WHERE is_del = ''0''
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(禁忌・アレルギー情報)', '2022-06-09 12:45:07.732', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9617, 'UPDATE pat_main
SET 
	up_date = CURRENT_TIMESTAMP,
taboo_allergy_info = taboo_allergy_info || jsonb_build_object(''memo'', ''【分類】その他アレルギー'' || E''\n'' || (CASE WHEN ''@tabooAllergyInfo.memo'' != ''''
                                                     THEN ''【内容】''||''@tabooAllergyInfo.memo''
																										 ELSE '''' END) ::TEXT ,
                      ''ctl_no'', COALESCE(NULLIF(''@nextCtlNo3'', ''''), ''1'')::integer,
                      ''content'', ''@tabooAllergyInfo.content''::TEXT,
                      ''disp_order'', COALESCE(NULLIF(''@nextCtlNo3'', ''''), ''0'')::integer,
                      ''category_class'', ''@tabooAllergyInfo.categoryClass''::TEXT,
                      ''taboo_allergy_cd'', ''@tabooAllergyInfo.tabooAllergyCd'',
                      ''taboo_allergy_class'', ''@tabooAllergyInfo.tabooAllergyClass''::TEXT,
											''new_flag'',1) WHERE is_del = ''0''
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(その他アレルギー情報)', '2022-07-12 02:55:43.381', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9616, 'UPDATE pat_main
SET 
	up_date = CURRENT_TIMESTAMP,
taboo_allergy_info = taboo_allergy_info || jsonb_build_object(''memo'', ''【分類】金属アレルギー'' || E''\n'' || (CASE WHEN ''@tabooAllergyInfo.memo'' != ''''
                                                     THEN ''【内容】''||''@tabooAllergyInfo.memo''
																										 ELSE '''' END) ::TEXT ,
                      ''ctl_no'', COALESCE(NULLIF(''@nextCtlNo3'', ''''), ''1'')::integer,
                      ''content'', ''@tabooAllergyInfo.content''::TEXT,
                      ''disp_order'', COALESCE(NULLIF(''@nextCtlNo3'', ''''), ''0'')::integer,
                      ''category_class'', ''@tabooAllergyInfo.categoryClass''::TEXT,
                      ''taboo_allergy_cd'', ''@tabooAllergyInfo.tabooAllergyCd'',
                      ''taboo_allergy_class'', ''@tabooAllergyInfo.tabooAllergyClass''::TEXT,
											''new_flag'',1) WHERE is_del = ''0''
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(金属アレルギー情報)', '2022-07-12 02:55:43.381', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9629, 'WITH tabooAllergy as ( 
    SELECT
        (idx - 1) AS idx
        , ms ->> ''memo'' AS memo
        , ms ->> ''ctl_no'' AS ctl_no
        , ms ->> ''content'' AS content
        , ms ->> ''disp_order'' AS disp_order
        , ms ->> ''category_class'' AS category_class
        , ms ->> ''taboo_allergy_cd'' AS taboo_allergy_cd
        , ms ->> ''taboo_allergy_class'' AS taboo_allergy_class
        , ms ->> ''new_flag'' AS new_flag
        , regexp_matches(ms ->> ''memo'', ''【分類】[^【]*'') AS memo_class 
    FROM
        pat_main AS A 
        CROSS JOIN LATERAL jsonb_array_elements(A.taboo_allergy_info ::jsonb) WITH ORDINALITY AS info(ms, idx)
    WHERE
        A.is_del = ''0'' 
        AND A.facility_cd = ''@facilityCd'' 
        AND A.pat_id = @patId
) 
, tabooAllergyUpdate AS ( 
    SELECT
        old.idx AS oldIdx
        , new.idx AS newIdx
        , old.ctl_no AS ctl_no
        , new.memo AS memo
        , new.content AS content
        , old.disp_order AS disp_order
        , new.category_class AS category_class
        , new.taboo_allergy_cd AS taboo_allergy_cd
        , new.taboo_allergy_class AS taboo_allergy_class
        , new.memo_class AS memo_class 
    FROM
        ( 
            SELECT
                idx
                , memo
                , ctl_no
                , content
                , disp_order
                , category_class
                , taboo_allergy_cd
                , taboo_allergy_class
                , memo_class 
            FROM
                tabooAllergy 
            WHERE
                new_flag IS NULL
        ) AS old
        , ( 
            SELECT
                idx
                , memo
                , ctl_no
                , content
                , disp_order
                , category_class
                , taboo_allergy_cd
                , taboo_allergy_class
                , memo_class 
            FROM
                tabooAllergy 
            WHERE
                new_flag IS NOT NULL
        ) AS new 
    WHERE
        ( 
            old.taboo_allergy_cd IS NOT NULL 
            AND old.taboo_allergy_cd != '''' 
            AND old.taboo_allergy_cd = new.taboo_allergy_cd
        ) 
        OR ( 
            ( 
                old.taboo_allergy_cd IS NULL 
                OR old.taboo_allergy_cd = ''''
            ) 
            AND old.content = new.content
        ) 
        AND new.memo_class = old.memo_class
) 
, tabooAllergyCreate AS ( 
    SELECT
        idx AS idx
        , memo AS memo
        , ctl_no AS ctl_no
        , content AS content
        , disp_order AS disp_order
        , category_class AS category_class
        , taboo_allergy_cd AS taboo_allergy_cd
        , taboo_allergy_class AS taboo_allergy_class
        , memo_class AS memo_class 
    FROM
        tabooAllergy 
    WHERE
        new_flag IS NOT NULL 
        AND idx NOT IN (SELECT oldIdx FROM tabooAllergyUpdate) 
        AND idx NOT IN (SELECT newIdx FROM tabooAllergyUpdate)
) 
, tabooAllergyClass AS ( 
    SELECT
        memo_class 
    FROM
        tabooAllergyUpdate 
    UNION 
    SELECT
        memo_class 
    FROM
        tabooAllergyCreate
) 
, tabooAllergyRetain AS ( 
    SELECT
        idx AS idx
        , memo AS memo
        , ctl_no AS ctl_no
        , content AS content
        , disp_order AS disp_order
        , category_class AS category_class
        , taboo_allergy_cd AS taboo_allergy_cd
        , taboo_allergy_class AS taboo_allergy_class 
    FROM
        tabooAllergy 
    WHERE
        new_flag IS NULL 
        AND memo_class NOT IN (SELECT * FROM tabooAllergyClass)
) 
, tabooAllergyTojsonb AS ( 
    SELECT
        (SELECT COALESCE(json_agg( 
            jsonb_build_object( 
                ''memo''
                , memo
                , ''ctl_no''
                , ctl_no ::integer
                , ''content''
                , content
                , ''disp_order''
                , disp_order ::integer
                , ''category_class''
                , category_class
                , ''taboo_allergy_cd''
                , taboo_allergy_cd
                , ''taboo_allergy_class''
                , taboo_allergy_class
            )
        ), ''[]'')
    FROM
        tabooAllergyUpdate )::jsonb
    || 
    (SELECT
        COALESCE(json_agg( 
            jsonb_build_object( 
                ''memo''
                , memo
                , ''ctl_no''
                , ctl_no ::integer
                , ''content''
                , content
                , ''disp_order''
                , disp_order ::integer
                , ''category_class''
                , category_class
                , ''taboo_allergy_cd''
                , taboo_allergy_cd
                , ''taboo_allergy_class''
                , taboo_allergy_class
            )
        ), ''[]'')
    FROM
        tabooAllergyCreate)::jsonb
    ||
    (SELECT
        COALESCE(json_agg( 
            jsonb_build_object( 
                ''memo''
                , memo
                , ''ctl_no''
                , ctl_no ::integer
                , ''content''
                , content
                , ''disp_order''
                , disp_order ::integer
                , ''category_class''
                , category_class
                , ''taboo_allergy_cd''
                , taboo_allergy_cd
                , ''taboo_allergy_class''
                , taboo_allergy_class
            )
        ), ''[]'')
    FROM
        tabooAllergyRetain)::jsonb AS jsonb
) 
                        
UPDATE pat_main
SET
	up_date = CURRENT_TIMESTAMP,
taboo_allergy_info = jsonb
from tabooAllergyTojsonb
WHERE is_del = ''0''
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd''
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(アレルギー情報)', '2023-05-31 17:24:39', CURRENT_TIMESTAMP, NULL);

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1015, 'SELECT
    CASE WHEN COALESCE(NULLIF(@inOutClass,''''),''0'') = TRIM(ini_info ->> ''value'') THEN TO_NUMBER(@inOutClass, ''FM9999999999999999'') 
		     WHEN COALESCE(NULLIF(@inOutClass,''''),''0'') = TRIM(ini_info ->> ''default_v'') THEN TO_NUMBER(@inOutClass, ''FM9999999999999999'') 
       ELSE ''0''
    END AS check_value
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = @facilityCd 
		AND COALESCE(ini_info ->> ''key0'','''') = @key0
    AND TRIM(ini_info ->> ''key1'') = ''CONV_INOUT_TO_FNW''
  ORDER BY check_value DESC
  LIMIT 1', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装)連携設定[患者個人情報]の取得', '2022-06-11 12:57:35.682', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1014, 'SELECT
    CASE WHEN COALESCE(NULLIF(@patSex,''''),''0'') = TRIM(ini_info ->> ''value'') THEN TO_NUMBER(@patSex, ''FM9999999999999999'') 
		     WHEN COALESCE(NULLIF(@patSex,''''),''0'') = TRIM(ini_info ->> ''default_v'') THEN TO_NUMBER(@patSex, ''FM9999999999999999'') 
       ELSE ''0''
    END AS check_value
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = @facilityCd 
		AND COALESCE(ini_info ->> ''key0'','''') = @key0
    AND TRIM(ini_info ->> ''key1'') = ''CONV_SEX_TO_FNW''
  ORDER BY check_value DESC
  LIMIT 1', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装)連携設定[性別変換項目]の取得', '2022-06-03 15:41:21.709', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1011, 'SELECT
    CASE WHEN COALESCE(NULLIF(@patBloodTypeAbo,''''),''0'') = TRIM(ini_info ->> ''value'') THEN TO_NUMBER(@patBloodTypeAbo, ''FM9999999999999999'') 
		     WHEN COALESCE(NULLIF(@patBloodTypeAbo,''''),''0'') = TRIM(ini_info ->> ''default_v'') THEN TO_NUMBER(@patBloodTypeAbo, ''FM9999999999999999'') 
       ELSE ''0''
    END AS check_value
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = @facilityCd 
		AND COALESCE(ini_info ->> ''key0'','''') = @key0
    AND TRIM(ini_info ->> ''key1'') = ''CONV_BLOOD_ABO_TO_FNW''
  ORDER BY check_value DESC
  LIMIT 1', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装)患者プロファイル:連携設定詳細(血液型ABO)の取得', '2022-01-17 15:02:47', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1010, 'SELECT
    CASE WHEN COALESCE(NULLIF(@patBloodTypeRh,''''),''0'') = TRIM(ini_info ->> ''value'') THEN TO_NUMBER(@patBloodTypeRh, ''FM9999999999999999'') 
		     WHEN COALESCE(NULLIF(@patBloodTypeRh,''''),''0'') = TRIM(ini_info ->> ''default_v'') THEN TO_NUMBER(@patBloodTypeRh, ''FM9999999999999999'') 
       ELSE ''0''
    END AS check_value
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = @facilityCd 
		AND COALESCE(ini_info ->> ''key0'','''') = @key0
    AND TRIM(ini_info ->> ''key1'') = ''CONV_BLOOD_RH_TO_FNW''
  ORDER BY check_value DESC
  LIMIT 1', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)連携設定詳細(血液型RH)の取得', '2022-01-17 15:02:47', CURRENT_TIMESTAMP, NULL);





