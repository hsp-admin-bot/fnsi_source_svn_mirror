DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-1105001);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1105001, '-- SQL:-1105001 begin
WITH in_hosp_code AS (
	--検体検査マスタの院内コード参照先
	SELECT
		coalesce(
			nullif(info ->> ''value'', ''''),
			info ->> ''default_v''
		) AS value
	FROM
		mst_coop_ini AS ini
		CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
	WHERE
		facility_cd = @facilityCd
		AND is_del = ''0''
		AND coalesce(info ->> ''key0'', '''') = @key0
		AND info ->> ''key1'' = ''SCM_EXAM_ORDER_SEND''
		AND info ->> ''key2'' = ''IN_HOSP_CODE''
)
, in_hosp_code_set AS (
	--検体検査マスタの院内コード参照先
	SELECT
		coalesce(
			nullif(info ->> ''value'', ''''),
			info ->> ''default_v''
		) AS value
	FROM
		mst_coop_ini AS ini
		CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
	WHERE
		facility_cd = @facilityCd
		AND is_del = ''0''
		AND coalesce(info ->> ''key0'', '''') = @key0
		AND info ->> ''key1'' = ''SCM_EXAM_ORDER_SEND''
		AND info ->> ''key2'' = ''IN_HOSP_CODE_SET''
)
, exam_data AS (
	(
	    SELECT
        	t.set_info ->> ''set_cd'' AS set_cd,
        	t.idx AS set_idx,
        	pem.up_date AS up_date 
    	FROM
        	pat_exam_main pem
        	CROSS JOIN jsonb_array_elements(pem.order_exam_set_info) WITH ordinality AS t(set_info, idx)
    	WHERE
    		pem.is_del = ''0''
        	AND pem.facility_cd = @facilityCd
        	AND pem.pat_id = @patId
        	AND pem.exam_main_cd = @ordNo
        ORDER BY 
        	up_date DESC
        LIMIT 1
	)
	UNION ALL 
	(
		SELECT
        	t.set_info ->> ''set_cd'' AS set_cd,
        	t.idx AS set_idx,
        	pem.up_date AS up_date 
    	FROM
        	pat_exam_main_hst pem
        	CROSS JOIN jsonb_array_elements(pem.order_exam_set_info) WITH ordinality AS t(set_info, idx)
    	WHERE
    	    pem.is_del = ''0''
        	AND pem.facility_cd = @facilityCd
        	AND pem.pat_id = @patId
        	AND pem.exam_main_cd = @ordNo
        ORDER BY 
        	up_date DESC
        LIMIT 1
	)
	ORDER BY 
    	up_date DESC NULLS LAST
    LIMIT 1
)
, item_count AS (
    --検査セットの院内コードがS始まりの場合取得
    SELECT
        1 AS item_sort_no,
        set_idx,
        CASE (SELECT value::numeric FROM in_hosp_code_set)
            WHEN 1 THEN mes.in_hospital_cd1
            WHEN 2 THEN mes.in_hospital_cd2
            WHEN 3 THEN mes.in_hospital_cd3
        END item_in_hospital_cd
    FROM
        exam_data
        LEFT JOIN mst_exam_set mes ON set_cd = mes.exam_set_cd::text
    WHERE
        LEFT(CASE (SELECT value::numeric FROM in_hosp_code_set)
            WHEN 1 THEN mes.in_hospital_cd1
            WHEN 2 THEN mes.in_hospital_cd2
            WHEN 3 THEN mes.in_hospital_cd3
        END, 1) = ''S''
        AND is_del = ''0''
        AND is_disp = ''1''
        
        UNION ALL
    --検査項目数を取得
    SELECT
        2 AS item_sort_no,
        set_idx,
        CASE (SELECT value::numeric FROM in_hosp_code)
            WHEN 1 THEN mei.in_hospital_cd1
            WHEN 2 THEN mei.in_hospital_cd2
            WHEN 3 THEN mei.in_hospital_cd3
        END item_in_hospital_cd
    FROM
        exam_data
        LEFT JOIN mst_exam_set mes ON set_cd = mes.exam_set_cd::text
        CROSS JOIN jsonb_array_elements(mes.exam_item_info) AS item_info
        LEFT JOIN mst_exam_item mei ON item_info ->> ''exam_item_cd'' = mei.exam_item_cd::text
    WHERE
        NULLIF((CASE (SELECT value FROM in_hosp_code_set)
            WHEN ''1'' THEN mes.in_hospital_cd1
            WHEN ''2'' THEN mes.in_hospital_cd2
            WHEN ''3'' THEN mes.in_hospital_cd3
            ELSE mes.in_hospital_cd1
            END), '''') IS NOT NULL
        AND NULLIF((CASE (SELECT value FROM in_hosp_code)
            WHEN ''1'' THEN mei.in_hospital_cd1
            WHEN ''2'' THEN mei.in_hospital_cd2
            WHEN ''3'' THEN mei.in_hospital_cd3
            ELSE mei.in_hospital_cd1
            END), '''') IS NOT NULL
        AND mei.is_del = ''0''
        AND mei.is_disp = ''1''
)
, limit_item AS (
    SELECT
        item_in_hospital_cd AS item_in_hospital_cd
    FROM
        item_count
    ORDER BY
        set_idx,
        item_sort_no,
        item_in_hospital_cd
    LIMIT 250
)
SELECT string_agg(RPAD(RIGHT(item_in_hospital_cd, 8), 8, '' ''), '''') AS item_in_hospital_cd
FROM limit_item
-- SQL:-1105001 end', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携_検体検査オーダー連携', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
