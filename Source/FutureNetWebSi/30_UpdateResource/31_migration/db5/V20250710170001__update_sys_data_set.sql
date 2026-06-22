DELETE FROM sys_data_set WHERE sql_cd IN 
(-1105002);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1105002, 'WITH in_hosp_code as (
	--検体検査マスタの院内コード参照先
	select
		coalesce(
			nullif(info ->> ''value'', ''''),
			info ->> ''default_v''
		) as value
	from
		mst_coop_ini as ini
		cross join LATERAL json_array_elements(ini.coop_ini_info :: json) info
	where
		facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info ->> ''key0'', '''') = @key0
		and info ->> ''key1'' = ''SCM_EXAM_ORDER_SEND''
		and info ->> ''key2'' = ''IN_HOSP_CODE''
 )
 , exam_data AS (
    SELECT
        set_info ->> ''set_cd'' AS set_cd
    FROM
        pat_exam_main pem
        CROSS JOIN jsonb_array_elements(pem.order_exam_set_info) AS set_info
    WHERE
        pem.facility_cd = @facilityCd
        AND pem.exam_main_cd = @ordNo
        AND pem.is_del = ''0''
)
, set_count AS(
    --検査セット数を取得
    SELECT
        ROW_NUMBER() OVER(order by set_cd::numeric) AS set_cnt,
        set_cd
    FROM
        exam_data
)
, item_count AS (
    --検査セットの院内コードがS始まりの場合取得
    SELECT
        1 AS item_sort_no,
        set_cnt,
        CASE (SELECT value::numeric FROM in_hosp_code)
            WHEN 1 THEN mes.in_hospital_cd1
            WHEN 2 THEN mes.in_hospital_cd2
            WHEN 3 THEN mes.in_hospital_cd3
        END item_in_hospital_cd,
        1 AS exam_item_cd
    FROM
        set_count
        LEFT JOIN mst_exam_set mes ON set_cd = mes.exam_set_cd::text
    WHERE
        LEFT(CASE (SELECT value::numeric FROM in_hosp_code)
            WHEN 1 THEN mes.in_hospital_cd1
            WHEN 2 THEN mes.in_hospital_cd2
            WHEN 3 THEN mes.in_hospital_cd3
        END,1) = ''S''
    UNION ALL
    --検査項目数を取得
    SELECT
        2 AS item_sort_no,
        set_cnt,
        CASE (SELECT value::numeric FROM in_hosp_code)
            WHEN 1 THEN mei.in_hospital_cd1
            WHEN 2 THEN mei.in_hospital_cd2
            WHEN 3 THEN mei.in_hospital_cd3
        END item_in_hospital_cd,
        mei.exam_item_cd
    FROM
        set_count
        LEFT JOIN mst_exam_set mes ON set_cd = mes.exam_set_cd::text
        CROSS JOIN jsonb_array_elements(mes.exam_item_info) AS item_info
        LEFT JOIN mst_exam_item mei ON item_info ->> ''exam_item_cd'' = mei.exam_item_cd::text
)
,limit_item AS (
    SELECT
    set_cnt,
    item_sort_no,
    exam_item_cd,
    item_in_hospital_cd,
	ROW_NUMBER() OVER(order by set_cnt,item_sort_no,exam_item_cd) AS limit_cnt
FROM
    item_count
)
SELECT
    set_cnt,
    item_in_hospital_cd,
    @key0 AS key0,
    @ordNo AS ord_no,
	@facilityCd AS facility_cd,
	ROW_NUMBER() OVER(order by item_sort_no,exam_item_cd) AS item_cnt,
	''01'' AS detail_id
FROM
    limit_item
WHERE
    limit_cnt <= 250
    AND set_cnt = @setCnt
ORDER BY
    item_in_hospital_cd', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携_検体検査オーダー連携', '2025-05-27 13:22:20.394', CURRENT_TIMESTAMP, NULL);
