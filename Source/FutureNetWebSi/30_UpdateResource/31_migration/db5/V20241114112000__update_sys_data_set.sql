DELETE FROM "ntss"."sys_data_set" where sql_cd in (-610004,-609201);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-610004, '-- 【SQL_CD=-610004】
SELECT 
  info ->> ''key1'' AS ini_section
  , info ->> ''key2'' AS ini_key
  , COALESCE(info ->> ''value'', info ->> ''default_v'', '''') AS ini_value
FROM 
  ntss.mst_coop_ini mci 
CROSS JOIN LATERAL json_array_elements ( mci.coop_ini_info  :: json ) info 
WHERE
  facility_cd = @facilityCd
  AND is_disp = ''1''
  AND is_del = ''0''
  AND info ->> ''is_effect'' = ''1''
  AND info ->> ''key0'' = @key0', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '連携設定マスタ取得', '2023-12-21 19:53:52.841', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-609201, 'WITH
exam_item AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        ntss.mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    where
        facility_cd = ''@facilityCd''
    AND is_del = ''0''
    AND info ->> ''key0'' = ''@key0''
    AND info ->> ''key1'' = ''MST''
    AND info ->> ''key2'' = ''EXAM_ITEM''
    AND info ->> ''is_effect'' = ''1''
),
json_info as(
    SELECT 
      jsonb_agg(result || json_build_object(''item_cd'',item.exam_item_cd,''item_name'',item.exam_item_name,''exam_class'',item.exam_class)::jsonb) AS result_json
    from
      jsonb_array_elements(''[{"com_cd":"@examResultInfo.comCd", "disp_order":"@nextDispOrder", "freememo":"@examResultInfo.freememo", "hl":"@examResultInfo.hl", "item_cd":"@examResultInfo.itemCd", "item_name":"@examResultInfo.itemName", "jlac10_cd":"@examResultInfo.jlac10Cd", "lower":"@examResultInfo.lower", "result":"@examResultInfo.result", "result_date":"@examResultInfo.resultDate", "type":"@examResultInfo.type", "unit":"@examResultInfo.unit", "upper":"@examResultInfo.upper"}]'' :: jsonb) result
        inner join ntss.mst_exam_item as item 
          on result ->> ''item_cd'' = CASE (SELECT value FROM exam_item)
            WHEN ''1'' THEN item.in_hospital_cd1::text
            WHEN ''2'' THEN item.in_hospital_cd2::text
            WHEN ''3'' THEN item.in_hospital_cd3::text
            ELSE ''''
          END
      AND item.facility_cd = ''@facilityCd''
      AND item.is_disp = ''1''
      AND item.is_del = ''0''
),
json_info_marge as(
  SELECT 
  	CASE WHEN exam_result_info IS NOT NULL AND exam_result_info <> ''[]'' THEN
      coalesce ((
        SELECT jsonb_agg((exam_result_info->>(idx-1)::INT)::json) 
        FROM pat_exam_main 
        CROSS JOIN jsonb_array_elements(exam_result_info) WITH ORDINALITY arr(j, idx) 
        WHERE exam_main_cd = @examMainCd AND j->>''item_cd'' <> (SELECT exam_item_cd FROM mst_exam_item WHERE facility_cd = ''@facilityCd'' AND ''@examResultInfo.itemCd'' 
         = CASE (SELECT value FROM exam_item)
            WHEN ''1'' THEN in_hospital_cd1::text
            WHEN ''2'' THEN in_hospital_cd2::text
            WHEN ''3'' THEN in_hospital_cd3::text
            ELSE ''''
          END
        )::TEXT
      ),''[]'')::jsonb || (SELECT result_json FROM json_info)::jsonb
   	ELSE
     	(SELECT result_json FROM json_info)::jsonb
   	end  AS result_json
  from 
    pat_exam_main
  WHERE
    exam_main_cd = @examMainCd
    AND is_del = ''0''
)

UPDATE ntss.pat_exam_main
SET exam_result_info =
CASE
    ''@examResultInfoFlg'' 
    WHEN '''' THEN ''@examResultInfoValue''
    ELSE (select COALESCE(result_json, ''[]'') from json_info_marge)
    END
  WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND reg_exam_date = to_timestamp( ''@regExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'' ) 
  AND reg_order_class = ''@regOrderClass'' 
  AND exam_main_cd = @examMainCd', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)CSIの検査結果', '2023-09-28 13:12:38.000', CURRENT_TIMESTAMP, NULL);
