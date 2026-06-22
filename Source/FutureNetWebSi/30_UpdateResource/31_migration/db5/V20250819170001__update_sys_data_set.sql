DELETE FROM ntss.sys_data_set
WHERE sql_cd in (-317121,-317122,-317123);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317121, 'WITH mst_coop_ini_info AS (
    SELECT
        info ->> ''key2'' AS key2,
        unnest(
            string_to_array(
                COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v''),
                '',''
            )
        ) AS VALUE
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND info ->> ''key0'' = @key0
        AND info ->> ''key1'' = ''SEND_COMMENT''
),
pat_event_info AS ( 
    SELECT
        pev.pat_event_cd
    FROM
        pat_event AS pev
    INNER JOIN ord_main AS ord 
        ON pev.event_start_date = ord.treat_date 
        AND ord.pat_id = pev.pat_id 
    WHERE
        pev.use_type = 2 
        AND pev.is_del = ''0'' 
        AND ord.ord_no = @ordNo
        AND pev.category_name = (
            SELECT value FROM mst_coop_ini_info WHERE key2 = ''CATEGORY''
        )
        AND pev.sub_category_name = (
            SELECT value FROM mst_coop_ini_info WHERE key2 = ''SUB_CATEGORY''
        )
)
SELECT 
	pei.pat_event_cd AS pat_event_cd,
    @key0 as key0,
	@patId as patId,
	@facilityCd as facility_cd,
    ''01'' AS detail_id
    
FROM 
    pat_event_info pei;
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携SOAP繰り返し取得SQL', '2025-08-13 22:36:49.450', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317122, 'with mst_coop_ini_info as(
select
	info ->> ''key2'' as key2,
	unnest(string_to_array(coalesce(
				nullif(
				info ->> ''value'',
				''''
			),
			info ->> ''default_v''
	        ), '','')
    ) as VALUE
from
	mst_coop_ini as ini
cross join
	lateral json_array_elements(
		ini.coop_ini_info::json
	) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and info ->> ''key0'' = @key0
	and info ->> ''key1'' = ''SEND_COMMENT2''
),
pat_event_info AS ( 
	SELECT
		pev.pat_event_cd,
		pev.up_date AS up_date,
		pev.reg_staff_info ->> ''reg_staff_name'' AS reg_staff_name,
		pev.input_params,
		pev.result_params
	FROM
		pat_event AS pev
	,	ord_main AS ord 
  WHERE
	pev.event_start_date = ord.treat_date 
	AND ord.pat_id = pev.pat_id 
	AND pev.use_type = 2 
	AND pev.is_del = ''0'' 
	AND ord.ord_no = @ordNo
	AND pev.category_name = (select value from mst_coop_ini_info where key2 = ''CATEGORY'')
	AND pev.sub_category_name = (select value from mst_coop_ini_info where key2 = ''SUB_CATEGORY'')
)
SELECT
	pei.pat_event_cd AS pat_event_cd,
    @key0 as key0,
	@patId as patId,
	@facilityCd as facility_cd,
    ''01'' AS detail_id
FROM
    pat_event_info pei
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携看護メモ取得SQL', '2025-08-13 22:36:49.450', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317123, 'with mst_coop_ini_info as(
select
	info ->> ''key2'' as key2,
	unnest(string_to_array(coalesce(
				nullif(
				info ->> ''value'',
				''''
			),
			info ->> ''default_v''
	        ), '','')
    ) as VALUE
from
	mst_coop_ini as ini
cross join
	lateral json_array_elements(
		ini.coop_ini_info::json
	) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and info ->> ''key0'' = @key0
	and info ->> ''key1'' = ''SEND_COMMENT3''
),
pat_event_info AS ( 
	SELECT
		pev.pat_event_cd,
		pev.up_date AS up_date,
		pev.reg_staff_info ->> ''reg_staff_name'' AS reg_staff_name,
		pev.input_params,
		pev.result_params
	FROM
		pat_event AS pev
	,	ord_main AS ord 
  WHERE
	pev.event_start_date = ord.treat_date 
	AND ord.pat_id = pev.pat_id 
	AND pev.use_type = 2 
	AND pev.is_del = ''0'' 
	AND ord.ord_no = @ordNo
	AND pev.category_name = (select value from mst_coop_ini_info where key2 = ''CATEGORY'')
	AND pev.sub_category_name = (select value from mst_coop_ini_info where key2 = ''SUB_CATEGORY'')
)
SELECT
	pei.pat_event_cd AS pat_event_cd,
    @key0 as key0,
	@patId as patId,
	@facilityCd as facility_cd,
    ''01'' AS detail_id
FROM
    pat_event_info pei
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携問診記録繰り返し取得SQL', '2025-08-13 22:36:49.450', CURRENT_TIMESTAMP, NULL);