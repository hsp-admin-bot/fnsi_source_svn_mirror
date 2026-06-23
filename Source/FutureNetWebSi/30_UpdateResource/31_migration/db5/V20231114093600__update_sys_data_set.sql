DELETE
FROM 
  sys_data_set sds 
WHERE
  sql_cd = -609201;

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
    AND info ->> ''key0'' = ''CSI''
    AND info ->> ''key1'' = ''MST''
    AND info ->> ''key2'' = ''EXAM_ITEM''
),
json_info as(
SELECT 
       jsonb_agg(result || json_build_object(''item_cd'',item.exam_item_cd)::jsonb) AS result_json
     from
       jsonb_array_elements(''[{"com_cd":"@examResultInfo.comCd", "disp_order":"@nextDispOrder", "exam_class":"@examResultInfo.examClass", "freememo":"@examResultInfo.freememo", "hl":"@examResultInfo.hl", "item_cd":"@examResultInfo.itemCd", "item_name":"@examResultInfo.itemName", "jlac10_cd":"@examResultInfo.jlac10Cd", "lower":"@examResultInfo.lower", "result":"@examResultInfo.result", "result_date":"@examResultInfo.resultDate", "type":"@examResultInfo.type", "unit":"@examResultInfo.unit", "upper":"@examResultInfo.upper"}]'' :: jsonb) result
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
)
UPDATE ntss.pat_exam_main
SET exam_result_info =
CASE
    ''@examResultInfoFlg'' 
    WHEN '''' THEN ''@examResultInfoValue''
    ELSE exam_result_info || (select COALESCE(result_json, ''[]'') from json_info)
    END
  WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND reg_exam_date = to_timestamp( ''@regExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'' ) 
  AND reg_order_class = ''@regOrderClass'' 
  AND exam_main_cd = @examMainCd', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)CSIの検査結果', '2023-09-28 13:12:38.000', current_timestamp, NULL);
