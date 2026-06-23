DELETE from "sys_data_set" WHERE sql_cd = 1403;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1403, 'WITH do_equals_result AS (
  SELECT 
    info ->> ''ctl_no'' AS old_ctl_no
  FROM
    pat_personal_main pm
    CROSS JOIN LATERAL json_array_elements (personal_info_decrypt_jsonb(pm.other_contact_info) :: json ) AS info
    WHERE
    pm.pat_id = @patId 
    AND pm.facility_cd = ''@facilityCd'' 
    AND pm.is_del = ''0''
    AND (REPLACE(info ->> ''last_name'','' '','''') || REPLACE(info ->> ''first_name'','' '','''')) = REPLACE(''@otherContactInfo.lastName'' ::TEXT,'' '','''')
)
, do_old_ordno AS (
  SELECT 
    CASE WHEN COUNT(do_equals_result) > 0 THEN 1 ELSE 0 END AS ord_order_no
  FROM
    do_equals_result
)
, name_info AS ( 
  SELECT
    ''@otherContactInfo.lastName'' ::TEXT AS lastName
   , '''' ::TEXT AS lastNmKana
   -- , ''@otherContactInfo.lastNmKana'' ::TEXT AS lastNmKana
) 
, tmp_index_info AS ( 
  SELECT
    COALESCE(NULLIF(POSITION(''　'' IN lastName), 0), LENGTH(lastName) + 1) AS indexLast1
    , COALESCE(NULLIF(POSITION('' '' IN lastName), 0), LENGTH(lastName) + 1) AS indexLast2
    , COALESCE(NULLIF(POSITION(''　'' IN lastNmKana), 0), LENGTH(lastNmKana) + 1) AS indexLastK1
    , COALESCE(NULLIF(POSITION('' '' IN lastNmKana), 0), LENGTH(lastNmKana) + 1) AS indexLastK2
  FROM
    name_info
) 
, index_info AS ( 
  SELECT
    CASE 
      WHEN indexLast1 > indexLast2 
        THEN indexLast2 
      ELSE indexLast1 
      END AS indexLast
    , CASE 
      WHEN indexLastK1 > indexLastK2 
        THEN indexLastK2 
      ELSE indexLastK1 
      END AS indexLastK
  FROM
    tmp_index_info
)
, new_name_info AS (
  SELECT
    TRIM(TRIM(TRIM(SUBSTRING(lastName, 1, indexLast-1)), ''　'')) AS lastName
    , TRIM(TRIM(TRIM(SUBSTRING(lastName, indexLast + 1)), ''　'')) AS firstName
    , TRIM(TRIM(TRIM(SUBSTRING(lastNmKana, 1, indexLastK-1)), ''　'')) AS lastNmKana
    , TRIM(TRIM(TRIM(SUBSTRING(lastNmKana, indexLastK + 1)), ''　'')) AS firstNmKana
  FROM 
    name_info,
    index_info
)  
, data_new_info AS (
  SELECT 
    (SELECT old_ctl_no FROM do_equals_result) AS ctl_no,
    ''0'' AS disp_order,
    null AS pat_id,
    COALESCE(NULLIF(lastName, ''''), '' '') AS last_name,
    COALESCE(NULLIF(firstName, ''''), '' '') AS first_name,
    NULLIF(lastNmKana, '''') AS last_name_kana,
    NULLIF(firstNmKana, '''') AS first_name_kana,
    CASE WHEN COALESCE(NULLIF(''@relationFlg'', ''''), ''0'') = ''1'' THEN NULLIF(''@otherContactInfo.relationCd'', '''') ELSE null END AS relation_cd,
    null AS relation_name,
    null AS zip_cd,
    null AS address,
    NULLIF(''@otherContactInfo.tel1'', '''') AS tel1,
    NULLIF(''@otherContactInfo.tel2'', '''') AS tel2,
    null AS fax,
    null AS e_mail,
    null AS work_name,
    null AS work_tel,
    null AS work_address,
    NULLIF(''@otherContactInfo.memo1'', '''') AS memo1,
    null AS memo2,
    ''0'' AS is_key_person
  FROM new_name_info
) 
, data_exists_info AS (
  SELECT
    1 AS order_no
    , (info->>''ctl_no'') :: TEXT AS ctl_no 
  FROM
    pat_personal_main pm
    CROSS JOIN LATERAL json_array_elements (personal_info_decrypt_jsonb(pm.other_contact_info) :: json ) AS info 
    INNER JOIN data_new_info AS NEW ON (info->> ''last_name'')::TEXT = (NEW.last_name ::TEXT) AND (info->> ''first_name'')::TEXT = (NEW.first_name ::TEXT)
  WHERE
    pm.pat_id = @patId 
    AND pm.facility_cd = ''@facilityCd'' 
    AND pm.is_del = ''0'' 
  UNION 
  SELECT
    2 AS order_no
    , ''-1'' AS ctl_no 
  ORDER BY
    order_no ASC, ctl_no ASC LIMIT 1
)
, data_info AS ( 
  SELECT
    (SELECT ord_order_no FROM do_old_ordno) AS order_no,
    ctl_no::TEXT AS ctl_no,
    disp_order::TEXT AS disp_order,
    pat_id::TEXT AS pat_id,
    last_name::TEXT AS last_name,
    first_name::TEXT AS first_name,
    last_name_kana::TEXT AS last_name_kana,
    first_name_kana::TEXT AS first_name_kana,
    relation_cd::TEXT AS relation_cd,
    relation_name::TEXT AS relation_name,
    zip_cd::TEXT AS zip_cd,
    address::TEXT AS address,
    tel1::TEXT AS tel1,
    tel2::TEXT AS tel2,
    fax::TEXT AS fax,
    e_mail::TEXT AS e_mail,
    work_name::TEXT AS work_name,
    work_tel::TEXT AS work_tel,
    work_address::TEXT AS work_address,
    memo1::TEXT AS memo1,
    memo2::TEXT AS memo2,
    is_key_person::TEXT AS is_key_person
  FROM
    data_new_info AS new
  WHERE
    (SELECT ctl_no FROM data_exists_info) = ''-1'' 
  UNION 
  SELECT
    1 AS order_no,
    info ->> ''ctl_no'' AS ctl_no,
    info ->> ''disp_order'' AS disp_order,
    info ->> ''pat_id'' AS pat_id,
    info ->> ''last_name'' AS last_name,
    info ->> ''first_name'' AS first_name,
    info ->> ''last_name_kana'' AS last_name_kana,
    info ->> ''first_name_kana'' AS first_name_kana,
    (CASE WHEN NEW.ctl_no_old IS NULL THEN info ->> ''relation_cd'' ELSE new.relation_cd::TEXT END) AS relation_cd,
    (CASE WHEN NEW.ctl_no_old IS NULL THEN info ->> ''relation_name'' ELSE '''' END) AS relation_name,
    info ->> ''zip_cd'' AS zip_cd,
    info ->> ''address'' AS address,
    (CASE WHEN NEW.ctl_no_old IS NULL THEN info ->> ''tel1'' ELSE new.tel1::TEXT END) AS tel1,
    (CASE WHEN NEW.ctl_no_old IS NULL THEN info ->> ''tel2'' ELSE new.tel2::TEXT END) AS tel2,
    info ->> ''fax'' AS fax,
    info ->> ''e_mail'' AS e_mail,
    info ->> ''work_name'' AS work_name,
    info ->> ''work_tel'' AS work_tel,
    info ->> ''work_address'' AS work_address,
    (CASE WHEN NEW.ctl_no_old IS NULL THEN info ->> ''memo1'' ELSE new.memo1::TEXT END) AS memo1,
    info ->> ''memo2'' AS memo2,
    info ->> ''is_key_person'' AS is_key_person
  FROM
    pat_personal_main pm
    CROSS JOIN LATERAL json_array_elements (personal_info_decrypt_jsonb(pm.other_contact_info) :: json ) AS info 
    LEFT OUTER JOIN (SELECT data1.ctl_no AS ctl_no_old, new1.* FROM data_new_info AS new1, data_exists_info AS data1) AS NEW ON (info->> ''ctl_no'')::TEXT = (NEW.ctl_no_old::TEXT)
  WHERE
    pm.pat_id = @patId 
    AND pm.facility_cd = ''@facilityCd'' 
    AND pm.is_del = ''0''
    AND (REPLACE(info ->> ''last_name'','' '','''') || REPLACE(info ->> ''first_name'','' '','''')) <> REPLACE(''@otherContactInfo.lastName'' ::TEXT,'' '','''')
  ORDER BY
    order_no DESC, ctl_no ASC
)
, json_data AS (
  SELECT json_build_object(
    ''ctl_no'', row_number() over(order by order_no DESC, ctl_no ASC),
    ''disp_order'', (COALESCE(NULLIF(disp_order, ''''), ''0'') :: INTEGER),
    ''pat_id'', pat_id,
    ''last_name'', last_name,
    ''first_name'', first_name,
    ''last_name_kana'', last_name_kana,
    ''first_name_kana'', first_name_kana,
    ''relation_cd'', (relation_cd :: INTEGER),
    ''relation_name'', relation_name,
    ''zip_cd'', zip_cd,
    ''address'', address,
    ''tel1'', tel1,
    ''tel2'', tel2,
    ''fax'', fax,
    ''e_mail'', e_mail,
    ''work_name'', work_name,
    ''work_tel'', work_tel,
    ''work_address'', work_address,
    ''memo1'', memo1,
    ''memo2'', memo2,
    ''is_key_person'', is_key_person) AS new_data
  FROM data_info
)
UPDATE pat_personal_main 
SET 
  other_contact_info = (SELECT array_to_json(ARRAY_AGG(new_data)) FROM json_data)
  , up_date = CURRENT_TIMESTAMP
WHERE
    is_del = ''0'' 
    AND pat_id = @patId 
    AND facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_緊急連絡先', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', '[{"sql_cd": 1006, "field_name": "relation_flg", "replace_var": "@relationFlg"}]');
