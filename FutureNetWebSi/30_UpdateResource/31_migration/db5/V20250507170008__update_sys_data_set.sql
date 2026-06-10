DELETE FROM sys_data_set WHERE sql_cd IN (-1001, -306001, -309001, -309002, -309101, -310002, -310003, -310004, -310005, -310006, -310007, -310008, -310010, -310011, -310012, -310014, -310015, -310016, -317019, -317104, -317110, -317111, -317114, -317116, -317118, -317119, -317120, -317121, -317122, -317123, -317125, -317126, -317127, -427, 6101, 6103, 6202);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317127, 'with mst_coop_ini_info as(
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
	and info ->> ''key0'' = ''MED''
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
  WHERE
        pev.pat_event_cd = @pat_event_cd
),
input_row as (
	select
		pei.pat_event_cd,
		ROW_NUMBER() OVER (PARTITION by pei.pat_event_cd) as input_row_no,
		input_params.value
	from
		pat_event_info as pei
	cross join
		lateral json_array_elements(
			pei.input_params::json
		) input_params
),
result_row as (
	select
		pei.pat_event_cd,
		ROW_NUMBER() OVER (PARTITION by pei.pat_event_cd) as result_row_no,
		result_params.value
	from
		pat_event_info as pei
	cross join
		lateral json_array_elements(
			pei.result_params::json
		) result_params
),
interview_record_info as (
	SELECT
		result_row.pat_event_cd,
		(unescape_html(REGEXP_REPLACE(substring(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g'') from 1 for length(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g''))), ''<[^>]*>'', '''', ''g'')))  AS e01
	FROM
		result_row
	INNER JOIN input_row on
		input_row.pat_event_cd = result_row.pat_event_cd
	AND result_row.result_row_no = input_row.input_row_no
	AND input_row.value ->> ''field_name'' = (select value from mst_coop_ini_info where key2 = ''FIELD'')
)
SELECT
	interview_record_info.e01,
	TO_CHAR(pei.up_date, ''YYYY-MM-DD HH24:MI:SS'') AS up_date,
	pei.reg_staff_name as staff_name
FROM
    pat_event_info pei
INNER JOIN interview_record_info ON
	pei.pat_event_cd = interview_record_info.pat_event_cd', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携問診記録取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317126, 'with mst_coop_ini_info as(
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
	and info ->> ''key0'' = ''MED''
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
  WHERE
        pev.pat_event_cd = @pat_event_cd
  ),
input_row as (
	select
		pei.pat_event_cd,
		ROW_NUMBER() OVER (PARTITION by pei.pat_event_cd) as input_row_no,
		input_params.value
	from
		pat_event_info as pei
	cross join
		lateral json_array_elements(
			pei.input_params::json
		) input_params
),
result_row as (
	select
		pei.pat_event_cd,
		ROW_NUMBER() OVER (PARTITION by pei.pat_event_cd) as result_row_no,
		result_params.value
	from
		pat_event_info as pei
	cross join
		lateral json_array_elements(
			pei.result_params::json
		) result_params
),
nursing_notes_info as (
	SELECT
		result_row.pat_event_cd,
		(unescape_html(REGEXP_REPLACE(substring(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g'') from 1 for length(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g''))), ''<[^>]*>'', '''', ''g'')))  AS e01
	FROM
		result_row
	INNER JOIN input_row on
		input_row.pat_event_cd = result_row.pat_event_cd
	AND result_row.result_row_no = input_row.input_row_no
	AND input_row.value ->> ''field_name'' = (select value from mst_coop_ini_info where key2 = ''FIELD'')
)
SELECT
	nursing_notes_info.e01,
	TO_CHAR(pei.up_date, ''YYYY-MM-DD HH24:MI:SS'') AS up_date,
	pei.reg_staff_name as staff_name
FROM
    pat_event_info pei
INNER JOIN nursing_notes_info ON
	pei.pat_event_cd = nursing_notes_info.pat_event_cd', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携看護メモ録取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317125, 'with mst_coop_ini_info as(
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
	and info ->> ''key0'' = ''MED''
	and info ->> ''key1'' = ''SEND_COMMENT''
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
  WHERE
        pev.pat_event_cd = @pat_event_cd
	),
input_row as (
	select
		pei.pat_event_cd,
		ROW_NUMBER() OVER (PARTITION by pei.pat_event_cd) as input_row_no,
		input_params.value
	from
		pat_event_info as pei
	cross join
		lateral json_array_elements(
			pei.input_params::json
		) input_params
),
result_row as (
	select
		pei.pat_event_cd,
		ROW_NUMBER() OVER (PARTITION by pei.pat_event_cd) as result_row_no,
		result_params.value
	from
		pat_event_info as pei
	cross join
		lateral json_array_elements(
			pei.result_params::json
		) result_params
),
s_info as (
	SELECT
		result_row.pat_event_cd,
		(unescape_html(REGEXP_REPLACE(substring(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g'') from 1 for length(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g''))), ''<[^>]*>'', '''', ''g'')))  AS e01
	FROM
		result_row
	INNER JOIN input_row on
		input_row.pat_event_cd = result_row.pat_event_cd
	AND result_row.result_row_no = input_row.input_row_no
	AND input_row.value ->> ''field_name'' = (select value from mst_coop_ini_info where key2 = ''S_FIELD'')
),
o_info as (
	SELECT
		result_row.pat_event_cd,
		(unescape_html(REGEXP_REPLACE(substring(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g'') from 1 for length(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g''))), ''<[^>]*>'', '''', ''g'')))  AS e01
	FROM
		result_row
	INNER JOIN input_row on
		input_row.pat_event_cd = result_row.pat_event_cd
	AND result_row.result_row_no = input_row.input_row_no
	AND input_row.value ->> ''field_name'' = (select value from mst_coop_ini_info where key2 = ''O_FIELD'')
),
a_info as (
	SELECT
		result_row.pat_event_cd,
		(unescape_html(REGEXP_REPLACE(substring(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g'') from 1 for length(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g''))), ''<[^>]*>'', '''', ''g'')))  AS e01
	FROM
		result_row
	INNER JOIN input_row on
		input_row.pat_event_cd = result_row.pat_event_cd
	AND result_row.result_row_no = input_row.input_row_no
	AND input_row.value ->> ''field_name'' = (select value from mst_coop_ini_info where key2 = ''A_FIELD'')
),
p_info as (
	SELECT
		result_row.pat_event_cd,
		(unescape_html(REGEXP_REPLACE(substring(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g'') from 1 for length(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g''))), ''<[^>]*>'', '''', ''g'')))  AS e01
	FROM
		result_row
	INNER JOIN input_row on
		input_row.pat_event_cd = result_row.pat_event_cd
	AND result_row.result_row_no = input_row.input_row_no
	AND input_row.value ->> ''field_name'' = (select value from mst_coop_ini_info where key2 = ''P_FIELD'')
)
SELECT
	s_info.e01 AS s,
	o_info.e01 AS o,
	a_info.e01 AS a,
	p_info.e01 AS p,
	TO_CHAR(pei.up_date, ''YYYY-MM-DD HH24:MI:SS'') AS up_date,
	pei.reg_staff_name as staff_name
FROM
    pat_event_info pei
INNER JOIN s_info ON
	pei.pat_event_cd = s_info.pat_event_cd
INNER JOIN o_info ON
	pei.pat_event_cd = o_info.pat_event_cd
INNER JOIN a_info ON
	pei.pat_event_cd = a_info.pat_event_cd
INNER JOIN p_info ON
	pei.pat_event_cd = p_info.pat_event_cd
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携SOAP繰り返し取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
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
	and info ->> ''key0'' = ''MED''
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
    @ordNo as ord_no,
	@patId as patId,
	@facilityCd as facility_cd,
    ''01'' AS detail_id
FROM
    pat_event_info pei
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携問診記録繰り返し取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
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
	and info ->> ''key0'' = ''MED''
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
    @ordNo as ord_no,
	@patId as patId,
	@facilityCd as facility_cd,
    ''01'' AS detail_id
FROM
    pat_event_info pei
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携看護メモ取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
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
        AND info ->> ''key0'' = ''MED''
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
    @ordNo as ord_no,
	@patId as patId,
	@facilityCd as facility_cd,
    ''01'' AS detail_id
    
FROM 
    pat_event_info pei;
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携SOAP繰り返し取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317120, 'WITH staff_no AS (
    SELECT
        (@ns1NameClassification = ''0'')::int + (@ns2NameClassification = ''0'')::int AS staff_no2,
        (@ns1NameClassification = ''0'')::int + (@ns2NameClassification = ''0'')::int + (@ns3NameClassification = ''0'')::int AS staff_no3,
        (@ns1NameClassification = ''0'')::int + (@ns2NameClassification = ''0'')::int + (@ns3NameClassification = ''0'')::int
        + (@ns4NameClassification = ''0'')::int AS staff_no4,
        (@ns1NameClassification = ''0'')::int + (@ns2NameClassification = ''0'')::int + (@ns3NameClassification = ''0'')::int
        + (@ns4NameClassification = ''0'')::int + (@ns5NameClassification = ''0'')::int AS staff_no5
)
, user_info AS (
    SELECT
        user_id,
        CONCAT(personal_info_decrypt(user_last_name), personal_info_decrypt(user_first_name)) AS user_name
    FROM
        mst_personal_user
    WHERE
        user_id IN (@staffCd1::int, @staffCd2::int, @staffCd3::int, @staffCd4::int, @staffCd5::int)
)
SELECT 
        CASE @ns1NameClassification
            WHEN ''0'' THEN (SELECT user_name FROM user_info WHERE user_id = @staffCd1::int)
            WHEN ''1'' THEN @ordFullName1
            WHEN ''2'' THEN @fixedNurseName1
            WHEN ''3'' THEN @fixedNurseName2
        END
     AS e01,
        CASE @ns2NameClassification
            WHEN ''0'' THEN (SELECT user_name FROM user_info WHERE user_id = 
                CASE (SELECT staff_no2 FROM staff_no)
                    WHEN ''1'' THEN @staffCd1
                    WHEN ''2'' THEN @staffCd2
                END ::int)
            WHEN ''1'' THEN @ordFullName2
            WHEN ''2'' THEN @fixedNurseName1
            WHEN ''3'' THEN @fixedNurseName2
        END
     AS e02,
        CASE @ns3NameClassification
            WHEN ''0'' THEN (SELECT user_name FROM user_info WHERE user_id = 
                CASE (SELECT staff_no3 FROM staff_no)
                    WHEN ''1'' THEN @staffCd1
                    WHEN ''2'' THEN @staffCd2
                    WHEN ''3'' THEN @staffCd3
                END ::int)
            WHEN ''1'' THEN @fixedNurseName1
            WHEN ''2'' THEN @fixedNurseName2
        END
     AS e03,
        CASE @ns4NameClassification
            WHEN ''0'' THEN (SELECT user_name FROM user_info WHERE user_id = 
                CASE (SELECT staff_no4 FROM staff_no)
                    WHEN ''1'' THEN @staffCd1
                    WHEN ''2'' THEN @staffCd2
                    WHEN ''3'' THEN @staffCd3
                    WHEN ''4'' THEN @staffCd4
                END ::int)
            WHEN ''1'' THEN @fixedNurseName1
            WHEN ''2'' THEN @fixedNurseName2
        END
     AS e04,
        CASE @ns5NameClassification
            WHEN ''0'' THEN (SELECT user_name FROM user_info WHERE user_id = 
                CASE (SELECT staff_no5 FROM staff_no)
                    WHEN ''1'' THEN @staffCd1
                    WHEN ''2'' THEN @staffCd2
                    WHEN ''3'' THEN @staffCd3
                    WHEN ''4'' THEN @staffCd4
                    WHEN ''5'' THEN @staffCd5
                END ::int)
            WHEN ''1'' THEN @fixedNurseName1
            WHEN ''2'' THEN @fixedNurseName2
        END
     AS e05', 3, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携担当Ns取得SQL', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, '[{"sql_cd": -317119, "field_name": "ns1_name_classification", "replace_var": "@ns1NameClassification"}, {"sql_cd": -317119, "field_name": "ns2_name_classification", "replace_var": "@ns2NameClassification"}, {"sql_cd": -317119, "field_name": "ns3_name_classification", "replace_var": "@ns3NameClassification"}, {"sql_cd": -317119, "field_name": "ns4_name_classification", "replace_var": "@ns4NameClassification"}, {"sql_cd": -317119, "field_name": "ns5_name_classification", "replace_var": "@ns5NameClassification"}, {"sql_cd": -317119, "field_name": "staff_cd1", "replace_var": "@staffCd1"}, {"sql_cd": -317119, "field_name": "staff_cd2", "replace_var": "@staffCd2"}, {"sql_cd": -317119, "field_name": "staff_cd3", "replace_var": "@staffCd3"}, {"sql_cd": -317119, "field_name": "staff_cd4", "replace_var": "@staffCd4"}, {"sql_cd": -317119, "field_name": "staff_cd5", "replace_var": "@staffCd5"}, {"sql_cd": -317119, "field_name": "ord_full_name1", "replace_var": "@ordFullName1"}, {"sql_cd": -317119, "field_name": "ord_full_name2", "replace_var": "@ordFullName2"}, {"sql_cd": -317119, "field_name": "fixed_nurse_name1", "replace_var": "@fixedNurseName1"}, {"sql_cd": -317119, "field_name": "fixed_nurse_name2", "replace_var": "@fixedNurseName2"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317119, 'WITH ord_info AS (
    SELECT
        rst_charge_user_info ->> ''user_last_name_1'' AS last_name1,
        rst_charge_user_info ->> ''user_first_name_1'' AS first_name1,
        rst_charge_user_info ->> ''user_last_name_2'' AS last_name2,
        rst_charge_user_info ->> ''user_first_name_2'' AS first_name2
    FROM
        ord_main
    WHERE
        ord_no = @ordNo
),
dr_value AS(
    SELECT
        info ->> ''key2'' AS key2,
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS VALUE
    FROM
        mst_coop_ini AS ini
    CROSS JOIN
            LATERAL jsonb_array_elements(ini.coop_ini_info) info
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND info ->> ''key0'' = @key0
        AND info ->> ''key1'' = ''KARTE_ORD_SEND''
),
dr AS(
    SELECT
        staff_info ->> ''staff_cd'' AS dr_cd,
        row_number() OVER(ORDER BY (staff_info ->> ''disp_order'')::int ASC) AS idx
    FROM
        pat_main AS pat
    CROSS JOIN
            LATERAL jsonb_array_elements(pat.charge_staff_info) staff_info
    WHERE
        pat.pat_id = @patId
        AND staff_info ->> ''is_main'' = ''1''
    ORDER BY
        (staff_info ->> ''disp_order'')::int ASC
),
charge_staff AS(
    SELECT
        staff_info ->> ''staff_cd'' AS staff_cd,
        row_number() OVER(ORDER BY (staff_info ->> ''disp_order'')::int ASC) AS idx
    FROM
        pat_main AS pat
    CROSS JOIN
            LATERAL jsonb_array_elements(pat.charge_staff_info) staff_info
    WHERE
        pat.pat_id = @patId
        AND staff_info ->> ''is_charge'' = ''1''
    ORDER BY
        (staff_info ->> ''disp_order'')::int ASC
)
SELECT
    COALESCE((SELECT value FROM dr_value WHERE key2 = ''DR1_NAME_CLASSIFICATION''), ''0'') AS dr1_name_classification,
    COALESCE((SELECT value FROM dr_value WHERE key2 = ''DR2_NAME_CLASSIFICATION''), ''0'') AS dr2_name_classification,
    COALESCE((SELECT value FROM dr_value WHERE key2 = ''DR3_NAME_CLASSIFICATION''), ''0'') AS dr3_name_classification,
    COALESCE((SELECT value FROM dr_value WHERE key2 = ''DR4_NAME_CLASSIFICATION''), ''0'') AS dr4_name_classification,
    COALESCE((SELECT value FROM dr_value WHERE key2 = ''DR5_NAME_CLASSIFICATION''), ''0'') AS dr5_name_classification,
    (SELECT value FROM dr_value WHERE key2 = ''FIXED_DOCTOR_NAME1'') AS fixed_doctor_name1,
    (SELECT value FROM dr_value WHERE key2 = ''FIXED_DOCTOR_NAME2'') AS fixed_doctor_name2,
    COALESCE((SELECT dr_cd FROM dr WHERE idx = 1), ''-1'') AS dr_cd1,
    COALESCE((SELECT dr_cd FROM dr WHERE idx = 2), ''-1'') AS dr_cd2,
    COALESCE((SELECT dr_cd FROM dr WHERE idx = 3), ''-1'') AS dr_cd3,
    COALESCE((SELECT dr_cd FROM dr WHERE idx = 4), ''-1'') AS dr_cd4,
    COALESCE((SELECT dr_cd FROM dr WHERE idx = 5), ''-1'') AS dr_cd5,
    
    COALESCE((SELECT value FROM dr_value WHERE key2 = ''NS1_NAME_CLASSIFICATION''), ''0'') AS ns1_name_classification,
    COALESCE((SELECT value FROM dr_value WHERE key2 = ''NS2_NAME_CLASSIFICATION''), ''0'') AS ns2_name_classification,
    COALESCE((SELECT value FROM dr_value WHERE key2 = ''NS3_NAME_CLASSIFICATION''), ''0'') AS ns3_name_classification,
    COALESCE((SELECT value FROM dr_value WHERE key2 = ''NS4_NAME_CLASSIFICATION''), ''0'') AS ns4_name_classification,
    COALESCE((SELECT value FROM dr_value WHERE key2 = ''NS5_NAME_CLASSIFICATION''), ''0'') AS ns5_name_classification,
    (SELECT value FROM dr_value WHERE key2 = ''FIXED_NURSE_NAME1'') AS fixed_nurse_name1,
    (SELECT value FROM dr_value WHERE key2 = ''FIXED_NURSE_NAME2'') AS fixed_nurse_name2,
    COALESCE((SELECT staff_cd FROM charge_staff WHERE idx = 1), ''-1'') AS staff_cd1,
    COALESCE((SELECT staff_cd FROM charge_staff WHERE idx = 2), ''-1'') AS staff_cd2,
    COALESCE((SELECT staff_cd FROM charge_staff WHERE idx = 3), ''-1'') AS staff_cd3,
    COALESCE((SELECT staff_cd FROM charge_staff WHERE idx = 4), ''-1'') AS staff_cd4,
    COALESCE((SELECT staff_cd FROM charge_staff WHERE idx = 5), ''-1'') AS staff_cd5,
    
    (SELECT CONCAT(last_name1, first_name1) FROM ord_info) AS ord_full_name1,
    (SELECT CONCAT(last_name2, first_name2) FROM ord_info) AS ord_full_name2', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携担当Ns事前取得SQL', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317118, 'WITH dr_no AS (
    SELECT
        (@dr1NameClassification = ''0'')::int + (@dr2NameClassification = ''0'')::int AS dr_no2,
        (@dr1NameClassification = ''0'')::int + (@dr2NameClassification = ''0'')::int + (@dr3NameClassification = ''0'')::int AS dr_no3,
        (@dr1NameClassification = ''0'')::int + (@dr2NameClassification = ''0'')::int + (@dr3NameClassification = ''0'')::int
        + (@dr4NameClassification = ''0'')::int AS dr_no4,
        (@dr1NameClassification = ''0'')::int + (@dr2NameClassification = ''0'')::int + (@dr3NameClassification = ''0'')::int
        + (@dr4NameClassification = ''0'')::int + (@dr5NameClassification = ''0'')::int AS dr_no5
)
, user_info AS (
    SELECT
        user_id,
        CONCAT(personal_info_decrypt(user_last_name), personal_info_decrypt(user_first_name)) AS user_name
    FROM
        mst_personal_user
    WHERE
        user_id IN (@drCd1::int, @drCd2::int, @drCd3::int, @drCd4::int, @drCd5::int)
)
SELECT 
        CASE @dr1NameClassification
            WHEN ''0'' THEN (SELECT user_name FROM user_info WHERE user_id = @drCd1::int)
            WHEN ''1'' THEN @ordFullName1
            WHEN ''2'' THEN @fixedDoctorName1
            WHEN ''3'' THEN @fixedDoctorName2
        END
     AS e01,
        CASE @dr2NameClassification
            WHEN ''0'' THEN (SELECT user_name FROM user_info WHERE user_id = 
                CASE (SELECT dr_no2 FROM dr_no)
                    WHEN ''1'' THEN @drCd1
                    WHEN ''2'' THEN @drCd2
                END ::int)
            WHEN ''1'' THEN @ordFullName2
            WHEN ''2'' THEN @fixedDoctorName1
            WHEN ''3'' THEN @fixedDoctorName2
        END
     AS e02,
        CASE @dr3NameClassification
            WHEN ''0'' THEN (SELECT user_name FROM user_info WHERE user_id = 
                CASE (SELECT dr_no3 FROM dr_no)
                    WHEN ''1'' THEN @drCd1
                    WHEN ''2'' THEN @drCd2
                    WHEN ''3'' THEN @drCd3
                END ::int)
            WHEN ''1'' THEN @fixedDoctorName1
            WHEN ''2'' THEN @fixedDoctorName2
        END
     AS e03,
        CASE @dr4NameClassification
            WHEN ''0'' THEN (SELECT user_name FROM user_info WHERE user_id = 
                CASE (SELECT dr_no4 FROM dr_no)
                    WHEN ''1'' THEN @drCd1
                    WHEN ''2'' THEN @drCd2
                    WHEN ''3'' THEN @drCd3
                    WHEN ''4'' THEN @drCd4
                END ::int)
            WHEN ''1'' THEN @fixedDoctorName1
            WHEN ''2'' THEN @fixedDoctorName2
        END
     AS e04,
        CASE @dr5NameClassification
            WHEN ''0'' THEN (SELECT user_name FROM user_info WHERE user_id = 
                CASE (SELECT dr_no5 FROM dr_no)
                    WHEN ''1'' THEN @drCd1
                    WHEN ''2'' THEN @drCd2
                    WHEN ''3'' THEN @drCd3
                    WHEN ''4'' THEN @drCd4
                    WHEN ''5'' THEN @drCd5
                END ::int)
            WHEN ''1'' THEN @fixedDoctorName1
            WHEN ''2'' THEN @fixedDoctorName2
        END
     AS e05', 3, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携Dr取得SQL', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, '[{"sql_cd": -317119, "field_name": "dr1_name_classification", "replace_var": "@dr1NameClassification"}, {"sql_cd": -317119, "field_name": "dr2_name_classification", "replace_var": "@dr2NameClassification"}, {"sql_cd": -317119, "field_name": "dr3_name_classification", "replace_var": "@dr3NameClassification"}, {"sql_cd": -317119, "field_name": "dr4_name_classification", "replace_var": "@dr4NameClassification"}, {"sql_cd": -317119, "field_name": "dr5_name_classification", "replace_var": "@dr5NameClassification"}, {"sql_cd": -317119, "field_name": "dr_cd1", "replace_var": "@drCd1"}, {"sql_cd": -317119, "field_name": "dr_cd2", "replace_var": "@drCd2"}, {"sql_cd": -317119, "field_name": "dr_cd3", "replace_var": "@drCd3"}, {"sql_cd": -317119, "field_name": "dr_cd4", "replace_var": "@drCd4"}, {"sql_cd": -317119, "field_name": "dr_cd5", "replace_var": "@drCd5"}, {"sql_cd": -317119, "field_name": "ord_full_name1", "replace_var": "@ordFullName1"}, {"sql_cd": -317119, "field_name": "ord_full_name2", "replace_var": "@ordFullName2"}, {"sql_cd": -317119, "field_name": "fixed_doctor_name1", "replace_var": "@fixedDoctorName1"}, {"sql_cd": -317119, "field_name": "fixed_doctor_name2", "replace_var": "@fixedDoctorName2"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317116, '
with blood_value as(
select
	info ->> ''key2'' as key2,
	unnest(string_to_array(coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) as VALUE
from
	mst_coop_ini as ini
cross join
            lateral json_array_elements(
                ini.coop_ini_info::json
            ) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and info ->> ''key0'' = ''MED''
	and info ->> ''key1'' = ''KARTE_ORD_SEND''
)
select
	''血液'' as detail_id,
	case abo
	when ''1'' then (
		select
			value
		from
			blood_value
		where
			key2 = ''BLOOD_TYPE_A''
	)
	when ''2'' then(
		select
			value
		from
			blood_value
		where
			key2 = ''BLOOD_TYPE_B''
	)
	when ''4'' then(
		select
			value
		from
			blood_value
		where
			key2 = ''BLOOD_TYPE_AB''
	)
	when ''3'' then(
		select
			value
		from
			blood_value
		where
			key2 = ''BLOOD_TYPE_O''
	)
	else (
		select
			value
		from
			blood_value
		where
			key2 = ''BLOOD_TYPE_UNKNOWN''
	)
	end as abo,
	case rh
	when ''1'' then(
		select
			value
		from
			blood_value
		where
			key2 = ''BLOOD_TYPE_RH+''
	)
	when ''2'' then(
		select
			value
		from
			blood_value
		where
			key2 = ''BLOOD_TYPE_RH-''
	)
	else (
		select
			value
		from
			blood_value
		where
			key2 = ''BLOOD_TYPE_UNKNOWN''
	)
	end as rh
from
	(
		select
			@blood_type_abo as abo,
			@blood_type_rh as rh
	) as blood_type', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携血液取得SQL', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, '[{"sql_cd": -317115, "field_name": "abo", "replace_var": "@blood_type_abo"}, {"sql_cd": -317115, "field_name": "rh", "replace_var": "@blood_type_rh"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317114, '
with charge_user_value as(
select
    info ->> ''key2'' as key2,
    unnest(string_to_array(coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) as value
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
    and info ->> ''key1'' = ''KARTE_ORD_SEND''
),
charge_user_info as (
    select
        ord.rst_charge_user_info ->>''user_last_name_1'' as user_last_name_1,
        ord.rst_charge_user_info ->>''user_first_name_1'' as user_first_name_1,
        ord.rst_charge_user_info ->>''user_last_name_2'' as user_last_name_2,
        ord.rst_charge_user_info ->>''user_first_name_2'' as user_first_name_2
    from 
        ord_main as ord
where
    ord.ord_no = @ordNo
)
select
    case (
        select
            value
        from
            charge_user_value
        where
            key2 = ''CHARGE_USER_CLASSIFICATION''
    )
        when ''0'' then coalesce(
      nullif(
        (select
          user_last_name_1 || user_first_name_1
        from
          charge_user_info),'''')
      ,(
        coalesce(nullif(
          (select
            user_last_name_2 || user_first_name_2
          from
            charge_user_info),'''')
            ,(
            select
                value
                  from
                      charge_user_value
                  where
                      key2 = ''FIXED_DOCTOR_NAME1''
          )
        )
      )
    )
        when ''1'' then coalesce(
      nullif(
        (select 
          user_last_name_2 || user_first_name_2
        from 
          charge_user_info),'''')
        ,(
                select
                    value
                from
                    charge_user_value
                where
                    key2 = ''FIXED_DOCTOR_NAME1''
        ))
        when ''2'' then (
            select
                value
            from
                charge_user_value
            where
                key2 = ''FIXED_DOCTOR_NAME1''
        )
        when ''3'' then(
            select
                value
            from
                charge_user_value
            where
                key2 = ''FIXED_DOCTOR_NAME2''
        )
        when ''4'' then(
            select
                value
            from
                charge_user_value
            where
                key2 = ''FIXED_NURSE_NAME1''
        )
        when ''5'' then(
            select
                value
            from
                charge_user_value
            where
                key2 = ''FIXED_NURSE_NAME2''
        )
    end as e01', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携担当者取得SQL', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317111, 'WITH sys_user_info AS(
    SELECT
        CONCAT(personal_info_decrypt(user_last_name), personal_info_decrypt(user_first_name)) AS sys_full_name
    FROM
        mst_personal_user
    WHERE
        user_id = @userId
),
pat_user_info AS(
    SELECT
        CONCAT(personal_info_decrypt(user_last_name), personal_info_decrypt(user_first_name)) AS pat_full_name
    FROM
        mst_personal_user
    WHERE
        user_id = COALESCE(NULLIF(@staffCd, ''''), ''-1'')::numeric
)
SELECT
    (
        CASE
            @doctorNameClassification
        WHEN ''0'' THEN COALESCE(
                    (SELECT sys_full_name FROM sys_user_info),
                    NULLIF(@ordFullName, ''''),
                    (SELECT pat_full_name FROM pat_user_info),
                    @fixedDoctorName1
                  )
        WHEN ''1'' THEN COALESCE(
                    NULLIF(@ordFullName, ''''),
                    (SELECT pat_full_name FROM pat_user_info),
                    @fixedDoctorName1
                  )
        WHEN ''2'' THEN COALESCE(
                    (SELECT pat_full_name FROM pat_user_info),
                    @fixedDoctorName1
                  )
        WHEN ''3'' THEN @fixedDoctorName1
        WHEN ''4'' THEN @fixedDoctorName2
        WHEN ''5'' THEN @fixedNurseName1
        WHEN ''6'' THEN @fixedNurseName2
        END 
    ) AS e01', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携医師名取得SQL', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, '[{"sql_cd": -317110, "field_name": "doctor_name_classification", "replace_var": "@doctorNameClassification"}, {"sql_cd": -317110, "field_name": "user_id", "replace_var": "@userId"}, {"sql_cd": -317110, "field_name": "ord_full_name", "replace_var": "@ordFullName"}, {"sql_cd": -317110, "field_name": "staff_cd", "replace_var": "@staffCd"}, {"sql_cd": -317110, "field_name": "fixed_doctor_name1", "replace_var": "@fixedDoctorName1"}, {"sql_cd": -317110, "field_name": "fixed_doctor_name2", "replace_var": "@fixedDoctorName2"}, {"sql_cd": -317110, "field_name": "fixed_nurse_name1", "replace_var": "@fixedNurseName1"}, {"sql_cd": -317110, "field_name": "fixed_nurse_name2", "replace_var": "@fixedNurseName2"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317110, 'WITH pat_info AS(
SELECT
    staff_info ->> ''staff_cd'' AS staff_cd
FROM
    pat_main AS pat
CROSS JOIN
    LATERAL json_array_elements(pat.charge_staff_info::json) staff_info
WHERE
    pat.pat_id = @patId
    AND staff_info ->> ''is_main'' = ''1''
ORDER BY
    (staff_info ->> ''disp_order'')::numeric ASC
LIMIT 1
),
sys_coop_info AS(
  SELECT
    user_id
  FROM
    sys_coop_journal AS sys
  WHERE
    sys.ctl_no = @ctlNo
),
ord_info AS (
    SELECT
        rst_charge_user_info ->> ''user_last_name_1'' AS last_name1,
        rst_charge_user_info ->> ''user_first_name_1'' AS first_name1
    FROM
        ord_main
    WHERE
        ord_no = @ordNo
),
doctor_name_value AS(
SELECT
    info ->> ''key2'' AS key2,
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS VALUE
FROM
    mst_coop_ini AS ini
CROSS JOIN
    LATERAL json_array_elements(ini.coop_ini_info::json) info
WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = ''MED''
    AND info ->> ''key1'' = ''KARTE_ORD_SEND''
)
SELECT
    (SELECT value FROM doctor_name_value WHERE key2 = ''DOCTOR_NAME_CLASSIFICATION'') AS doctor_name_classification,
    (SELECT user_id FROM sys_coop_info) AS user_id,
    (SELECT CONCAT(last_name1, first_name1) FROM ord_info) AS ord_full_name,
    (SELECT staff_cd FROM pat_info) AS staff_cd,
    (SELECT value FROM doctor_name_value WHERE key2 = ''FIXED_DOCTOR_NAME1'') AS fixed_doctor_name1,
    (SELECT value FROM doctor_name_value WHERE key2 = ''FIXED_DOCTOR_NAME2'') AS fixed_doctor_name2,
    (SELECT value FROM doctor_name_value WHERE key2 = ''FIXED_NURSE_NAME1'') AS fixed_nurse_name1,
    (SELECT value FROM doctor_name_value WHERE key2 = ''FIXED_NURSE_NAME2'') AS fixed_nurse_name2', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携医師名取得事前SQL', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317104, '
with medical_name_info as(
select
	info ->> ''key2'' as key2,
	unnest(string_to_array(coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) as VALUE
from
	mst_coop_ini as ini
cross join lateral jsON_array_elements(ini.coop_ini_info ::jsON) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and info ->> ''key0'' = ''MED''
	and info ->> ''key1'' = ''KARTE_ORD_SEND''
)
select
  ord.rst_treatment_name as e01  --血液浄化法
  ,to_char(ord.rst_start_date,''YYYY/MM/DD'') as e02--透析日
  ,RIGHT(''00''||TRUNC(TO_NUMBER(ord.ind_cond_info->''1''->>''value'',''999999'')/60,0),2)||''時間''||RIGHT(''00''||MOD(TO_NUMBER(ord.ind_cond_info->''1''->>''value'',''999999''),60),2)||''分''as e03--予定時間
  ,to_char(ord.rst_start_date,''YYYY/MM/DD HH24:MI:SS'') as e04--開始時刻
  ,to_char(ord.rst_end_date,''YYYY/MM/DD HH24:MI:SS'') as e05--終了時刻
  ,FLOOR(EXTRACT(EPOCH FROM DATE_TRUNC(''minute'', rst_end_date) - DATE_TRUNC(''minute'', rst_start_date)) / 3600) || ''時間'' ||
   FLOOR(MOD(EXTRACT(EPOCH FROM DATE_TRUNC(''minute'', rst_end_date) - DATE_TRUNC(''minute'', rst_start_date)), 3600) / 60) || ''分'' as e06--透析時間・実績時間
  ,to_number(cast(ord.rst_dialysis_cnt as text), ''FM999999'') as e07--透析回数
  ,to_number(ord.rst_cond_info->''14''->>''value'', ''FM999'') as e08--血流量
  ,to_char(cast(ord.rst_weight_info->>''ctr'' as numeric),''FM9990.00'') as e09--CTR
  ,ord.rst_cond_info->''5''->>''value_name_1'' as e10--ダイアライザ
  ,ord.rst_cond_info->''2''->>''value_name_1'' as e11--ブラッドアクセス・バスキュラーアクセス
  , case (
  	select
  		value
  	from
  		medical_name_info
  	where 
  		key2 = ''MEDICAL_NAME''
	) when ''0'' then coalesce(ord.rst_course_name,(
		select 
			value
		from
			medical_name_info
		where
			key2 = ''FIXED_MEDICAL_NAME''
	))when ''1'' then (
		select 
			value
		from
			medical_name_info
		where
			key2 = ''FIXED_MEDICAL_NAME''		
	)
    end as e12--診療科名
	,ord.rst_cond_info->''25''->>''value_name_1''  as e13--抗凝固剤
	,trim(to_char(to_number(ord.rst_cond_info->''26''->>''value'',''9999.99''),''99990.99''))  as e14--初回注入量
	,trim(to_char(to_number(ord.rst_cond_info->''27''->>''value'',''9999.99''),''99990.99'')) as e15--持続注入量
	,trim(to_char(to_number(ord.rst_cond_info->''28''->>''value'',''9999.99''),''99990.99'')) as e16--持続総量
from 
	ord_main ord
where
	ord.ord_no = @ordNo

', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携治療情報テーブルデータ取得SQL', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317019, '
WITH send_change_flag_info AS (
    SELECT
        UNNEST(string_to_array(COALESCE(
                    NULLIF(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) AS SEND_CHANGE_FLAG
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(
                ini.coop_ini_info::json
            ) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = ''MED''
    AND info ->> ''key1'' = ''ELAPSED_INFO''
    AND info ->> ''key2'' = ''SEND_CHANGE_FLAG''
)
SELECT
    CASE SEND_CHANGE_FLAG
        WHEN ''0'' THEN null
        WHEN ''1'' THEN ''1''
    END
FROM
    send_change_flag_info', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携修正連携スキップ用SQL', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310016, 'WITH exam_data AS(
  SELECT
    TO_CHAR(reg_exam_date, ''YYYYMMDD'') AS exam_date,
    reg_order_class
  FROM
    ntss.pat_exam_main
  WHERE
    exam_main_cd = @ordNo::numeric
    AND facility_cd = @facilityCd
),
ord_data AS(
  SELECT
    1 AS exist
  FROM
    ord_main
  WHERE
    treat_date = (SELECT exam_date FROM exam_data)
    AND facility_cd = @facilityCd
    AND pat_id = @patId::numeric
    AND ind_kur_cd > 0
    AND is_del = ''0''
  LIMIT 1
)
SELECT 1
WHERE (SELECT reg_order_class FROM exam_data) = ''0''
OR (SELECT exist FROM ord_data) IS NOT NULL', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom検査オーダ 連携判定', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310015, 'UPDATE
    pat_exam_main
SET
    is_lock = ''1''
WHERE
    exam_main_cd = @ordNo', 2, '[]'::jsonb, '0', '{"applications": [6]}'::jsonb, '{"classes": []}'::jsonb, 'Medicom検査依頼実績連携 検査依頼変更不可更新', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310014, 'with
min_staff_ctl_no AS (
SELECT min(staff.value ->> ''ctl_no'') AS min_is_main_ctl_no
FROM pat_main 
        CROSS JOIN
            LATERAL json_array_elements(pat_main.charge_staff_info::json) staff
    WHERE
        pat_id = @patId
        AND staff.value ->> ''is_main'' = ''1'' 
)
,staff AS (
SELECT 
    staff.value ->> ''staff_cd'' staff_cd
from pat_main 
        CROSS JOIN
            LATERAL json_array_elements(pat_main.charge_staff_info::json) staff
    WHERE
        pat_id = @patId
        and staff.value ->> ''ctl_no'' = (SELECT min_is_main_ctl_no FROM min_staff_ctl_no)
)
,def_doctor AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''DEFAULT_DOCTOR''
)
, doctor_data as(
SELECT 
    CASE 
    WHEN (SELECT min_is_main_ctl_no FROM min_staff_ctl_no) IS NULL THEN (SELECT value FROM def_doctor)
    ELSE (SELECT staff_cd FROM staff)
    END AS staff_cd
)
,exam_data as (
    select
        TO_CHAR(
            reg_exam_date,
            ''YYYYMMDD''
        ) as exam_date,
        case
            reg_order_class
    when ''0'' then '' ''
            else reg_order_class
        end as exam_timing,
        order_exam_set_info
    from
        ntss.pat_exam_main
    where
        exam_main_cd = @ordNo ::integer
        --    )
),
output_item as(
    select
        coalesce(
            nullif(
                info ->> ''value'',
                ''''
            ),
            info ->> ''default_v''
        ) as value
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
        and info ->> ''key1'' = ''EXAM_ORD''
        and info ->> ''key2'' = ''OUTPUT_ITEM''
)
,
exam_set as(
    select
        exam_set.other_exam_time
    from
        (
            select
                order_exam_set_info
            from
                exam_data
        ) p
    cross join lateral json_array_elements(
            p.order_exam_set_info ::json
        ) info
    inner join mst_exam_set as exam_set 
                on
        info ->> ''set_cd'' = (
            exam_set.exam_set_cd || ''''
        )
),
before_margin as(
    select
        coalesce(
            nullif(
                info ->> ''value'',
                ''''
            ),
            info ->> ''default_v''
        ) as value
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
        and info ->> ''key1'' = ''EXAM_ORD''
        and info ->> ''key2'' = ''BEFORE_MARGIN''
),
after_margin as(
    select
        coalesce(
            nullif(
                info ->> ''value'',
                ''''
            ),
            info ->> ''default_v''
        ) as value
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
        and info ->> ''key1'' = ''EXAM_ORD''
        and info ->> ''key2'' = ''AFTER_MARGIN''
),
ord_data as(
    select
        ord.ord_no,
        ord.ind_treat_start_time,
        ind_cond_info -> ''1'' ->> ''value'' as plan_dialysis_time
    from
        (
            select
                *
            from
                ord_main
            where
                pat_id = @patId ::integer
                and treat_date = (
                    select
                        exam_date
                    from
                        exam_data
                )
                and is_del = ''0''
            order by
                ind_treat_start_time asc
            limit 1
        ) ord
),
exam_time as (
    select
        (
            select
                ord_no
            from
                ord_data
        ) as ord_no,
        exam_date,
        exam_timing,
        case
            exam_timing
  when ''1'' then 
  to_char(
                (
                    (
                        select
                            ind_treat_start_time
                        from
                            ord_data
                    )::time - (
                        (
                            select
                                value
                            from
                                before_margin
                        ) || '' minutes''
                    )::interval
                ),
                ''HH24MI''
            )
            when ''2'' then 
  to_char(
                (
                    (
                        select
                            ind_treat_start_time
                        from
                            ord_data
                    )::time + (
                        (
                            select
                                plan_dialysis_time
                            from
                                ord_data
                        ) || '' minutes''
                    )::interval + (
                        (
                            select
                                value
                            from
                                after_margin
                        ) || '' minutes''
                    )::interval
                ),
                ''HH24MI''
            )
            else (
                select
                    other_exam_time
                from
                    exam_set
            )
        end as exam_time
    from
        exam_data
),
output_in_out as(
    select
        coalesce(
            nullif(
                info ->> ''value'',
                ''''
            ),
            info ->> ''default_v''
        ) as value
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
        and info ->> ''key1'' = ''EXAM_ORD''
        and info ->> ''key2'' = ''OUTPUT_IN_OUT''
),
item_set_no as (
    --SELECT info.value ->> ''no'' AS no
    select
        info ->> ''set_cd'' as no
    from
        (
            select
                m.*
            from
                pat_exam_main as m
            where
                m.is_del = ''0''
                and jsonb_array_length(m.order_exam_set_info) > 0
                    and m.exam_main_cd = @ordNo ::integer
        ) p
    cross join lateral json_array_elements(
            p.order_exam_set_info ::json
        ) info
    inner join mst_exam_set as item 
                on
        info ->> ''set_cd'' = (
            item.exam_set_cd || ''''
        )
),
exam_items AS (
select
    item_cd,
    item_name,
    in_hospital_cd1,
    in_hospital_cd2,
    in_hospital_cd3
from
    (
        select
            info ->> ''set_cd'' as seq_no,
            ''6'' as sub_no,
            -- 子（検査項目）
            info ->> ''item_cd'' as item_cd,
            info ->> ''item_name'' as item_name,
            item.in_hospital_cd1,
            item.in_hospital_cd2,
            item.in_hospital_cd3
        from
            (
                select
                    m.*
                from
                    pat_exam_main as m
                where
                    m.is_del = ''0''
                    and jsonb_array_length(m.order_exam_set_info) > 0
                        and m.exam_main_cd = @ordNo ::integer
            ) p
        cross join lateral json_array_elements(
                p.exam_order_info ::json
            ) info
        join mst_exam_item as item 
            on
            info ->> ''item_cd'' = (
                item.exam_item_cd || ''''
            )
            and 
                case (select value from output_in_out)
                when ''1'' then item.is_in_hospital = ''0''
                when ''2'' then item.is_in_hospital = ''1''
                else true
            end
        where
            info ->> ''set_cd'' in (
                select
                    no
                from
                    item_set_no
            )
            and
          case
                (
                    select
                        value
                    from
                        output_item
                )
                when ''1'' then false
                else true
            end
    union all
        select
            info ->> ''set_cd'' as seq_no,
            ''5'' as sub_no,
            -- 親（検査セット）
            info ->> ''set_cd'' as item_cd,
            info ->> ''set_name'' as item_name,
            item.in_hospital_cd1,
            item.in_hospital_cd2,
            item.in_hospital_cd3
        from
            (
                select
                    m.*
                from
                    pat_exam_main as m
                where
                    m.is_del = ''0''
                    and jsonb_array_length(m.order_exam_set_info) > 0
                        and m.exam_main_cd = @ordNo ::integer
            ) p
        cross join lateral json_array_elements(
                p.order_exam_set_info ::json
            ) info
        left outer join mst_exam_set as item
            on
            info ->> ''set_cd'' = (
                item.exam_set_cd || ''''
            )
        where
            info ->> ''set_cd'' in (
                select
                    no
                from
                    item_set_no
            )
            and 
          case
                (
                    select
                        value
                    from
                        output_item
                )
                when ''2'' then false
                else true
            end
    ) exam_all
order by
    item_cd
)
INSERT INTO ntss.pat_coop_detail(
    facility_cd,
    pat_id,
    save_1,
    save_2,
    is_disp,
    is_del,
    user_id,
    up_date,
    reg_date,
    coop_version
)
SELECT
    @facilityCd,
    @patId::integer,
    ''{"pkg": "MED"}''::jsonb,
    jsonb_build_object(
        ''ord_no'', (SELECT ord_no FROM ord_data),
        ''hosp_pat_id'', LPAD(@hospPatId::text, 12, ''0''),
        ''exam_date'', (SELECT exam_date FROM exam_data), 
        ''exam_timing'', (SELECT exam_timing FROM exam_data),
        ''exam_time'', (SELECT exam_time FROM exam_time),
        ''staff_cd'',(SELECT staff_cd FROM doctor_data),
        ''exam_items'',
        (select jsonb_agg(
            jsonb_build_object(
                    ''exam_cd'',item_cd,
                    ''exam_name'',item_name,
                    ''in_hospital_cd1'',in_hospital_cd1,
                    ''in_hospital_cd2'',in_hospital_cd2,
                    ''in_hospital_cd3'',in_hospital_cd3
                )
            )
            from exam_items
        )::jsonb),
    ''1'',
    ''0'',
    - 1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    ''MED''
FROM
    exam_items
    limit 1', 2, '[]'::jsonb, '0', '{"applications": [6]}'::jsonb, NULL, 'Medicom検査依頼実績連携', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, '[{"sql_cd": -310009, "field_name": "staff_cd", "replace_var": "@doctorCd"}, {"sql_cd": -310009, "field_name": "user_name", "replace_var": "@doctorName"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310012, 'WITH  coop_update AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0 
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''COOP_UPDATE''
), ord_coop AS (
SELECT ctl_no
FROM ord_coop_no
WHERE
ord_no = @ordNo
AND coop_cd = ''exam_ord''
AND facility_cd = @facilityCd
AND status = ''1''
)

SELECT ''O1'' AS kbn
WHERE 
CASE (SELECT value FROM coop_update)
WHEN ''0'' THEN (SELECT ctl_no FROM ord_coop) IS NULL
ELSE true
END', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'Medicom検査オーダ 修正連携判定', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310011, 'WITH
output_item AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''OUTPUT_ITEM''
),
output_in_out AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''OUTPUT_IN_OUT''
),
item_set_no AS (
SELECT info.value ->> ''set_cd'' AS no
FROM ( 
                select
                  m.* 
                from
                  pat_exam_main as m 
                where
                  m.is_del = ''0'' 
                  and jsonb_array_length(m.order_exam_set_info) > 0 
                  and m.exam_main_cd = @ordNo
              ) p 
              cross join lateral json_array_elements(p.order_exam_set_info ::json) info 
              inner join mst_exam_set as item 
                on info ->> ''set_cd'' = (item.exam_set_cd || '''')
)
select
  count(1) as exam_set_cnt
        from
          ( 
            select
              1
            from
              ( 
                select
                  m.* 
                from
                  pat_exam_main as m 
                where
                  m.is_del = ''0'' 
                  and jsonb_array_length(m.order_exam_set_info) > 0 
                  and m.exam_main_cd = @ordNo
              ) p 
              cross join lateral json_array_elements(p.exam_order_info ::json) info 
              join mst_exam_item as item 
                on info ->> ''item_cd'' = (item.exam_item_cd || '''')
                AND 
                CASE (SELECT value FROM output_in_out)
                WHEN ''1'' THEN item.is_in_hospital = ''0''
                WHEN ''2'' THEN item.is_in_hospital = ''1''
                ELSE true
                END 
              WHERE info ->> ''no'' IN (SELECT no FROM item_set_no)
              AND 
              CASE (SELECT value FROM output_item)
              WHEN ''1'' THEN false
              ELSE true
              END
            union all 
            select
              1
            from
              ( 
                select
                  m.* 
                from
                  pat_exam_main as m 
                where
                  m.is_del = ''0'' 
                  and jsonb_array_length(m.order_exam_set_info) > 0 
                  and m.exam_main_cd = @ordNo
              ) p 
              cross join lateral json_array_elements(p.order_exam_set_info ::json) info 
              left outer join mst_exam_set as item 
                on info ->> ''set_cd'' = (item.exam_set_cd || '''')
              WHERE info ->> ''set_cd'' IN (SELECT no FROM item_set_no)
              AND 
              CASE (SELECT value FROM output_item)
              WHEN ''2'' THEN false
              ELSE true
              END
          ) exam_all ', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'Medicom検査オーダ 検査項目カウント', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310010, 'WITH
exam_item AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''MST''
    AND info ->> ''key2'' = ''EXAM_ITEM''
),
exam_set AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''MST''
    AND info ->> ''key2'' = ''EXAM_SET''
),
output_item AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''OUTPUT_ITEM''
),
output_in_out AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''OUTPUT_IN_OUT''
),
item_set_no AS (
select info.value ->> ''set_cd'' AS no
FROM ( 
                select
                  m.* 
                from
                  pat_exam_main as m 
                where
                  m.is_del = ''0'' 
                  and jsonb_array_length(m.order_exam_set_info) > 0 
                  and m.exam_main_cd = @ordNo
              ) p 
              cross join lateral json_array_elements(p.order_exam_set_info ::json) info 
              inner join mst_exam_set as item 
                on info ->> ''set_cd'' = (item.exam_set_cd || '''')
),
institution_cd AS (
 SELECT
        UNNEST(string_to_array(COALESCE(
                    NULLIF(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) AS exam_institution_cd
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(
                ini.coop_ini_info::json
            ) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''EXAM_INSTITUTION_CD''
)
select
  ''検査項目'' as detail_id,
  (select exam_institution_cd from institution_cd) as exam_institution_cd,
  (exam_full.exam_row + 1) as exam_row,
  LEFT(max(case exam_full.exam_col when 0 then exam_full.in_hospital_cd else null end ), 17) as exam1,
  max(case exam_full.exam_col when 0 then exam_full.sub_no else '' '' end ) as exam1p,
  LEFT(max(case exam_full.exam_col when 1 then exam_full.in_hospital_cd else '' '' end ), 17) as exam2,
  max(case exam_full.exam_col when 1 then exam_full.sub_no else '' '' end ) as exam2p,
  LEFT(max(case exam_full.exam_col when 2 then exam_full.in_hospital_cd else '' '' end ), 17) as exam3,
  max(case exam_full.exam_col when 2 then exam_full.sub_no else '' '' end ) as exam3p,
  LEFT(max(case exam_full.exam_col when 3 then exam_full.in_hospital_cd else '' '' end ), 17) as exam4,
  max(case exam_full.exam_col when 3 then exam_full.sub_no else '' '' end ) as exam4p,
  LEFT(max(case exam_full.exam_col when 4 then exam_full.in_hospital_cd else '' '' end ), 17) as exam5,
  max(case exam_full.exam_col when 4 then exam_full.sub_no else '' '' end ) as exam5p
from
  ( 
    select
      (row_number() over () - 1) / 5 as exam_row
      , (row_number() over () - 1) % 5 as exam_col
      , exam.sub_no
      , exam.in_hospital_cd
    from
      ( 
        select
          exam_all.* 
        from
          ( 
            select
              info ->> ''item_cd'' as seq_no
              , ''6'' as sub_no -- 子（検査項目）
              , info ->> ''item_cd'' as item_cd 
              , info ->> ''item_name'' as item_name
              , CASE (SELECT value FROM exam_item)
              WHEN ''1'' THEN item.in_hospital_cd1
              WHEN ''2'' THEN item.in_hospital_cd2
              WHEN ''3'' THEN item.in_hospital_cd3
              ELSE NULL
              END as in_hospital_cd
            from
              ( 
                select
                  m.* 
                from
                  pat_exam_main as m 
                where
                  m.is_del = ''0'' 
                  and jsonb_array_length(m.order_exam_set_info) > 0 
                  and m.exam_main_cd = @ordNo
              ) p 
              cross join lateral json_array_elements(p.exam_order_info ::json) info 
              join mst_exam_item as item 
                on info ->> ''item_cd'' = (item.exam_item_cd || '''') 
                AND 
                CASE (SELECT value FROM output_in_out)
                WHEN ''1'' THEN item.is_in_hospital = ''0''
                WHEN ''2'' THEN item.is_in_hospital = ''1''
                ELSE true
                END
              WHERE info ->> ''set_cd'' IN (SELECT no FROM item_set_no)
              AND 
              CASE (SELECT value FROM output_item)
              WHEN ''1'' THEN false
              ELSE true
              END
            union all 
            select
              info ->> ''set_cd'' as seq_no
              , ''5'' as sub_no -- 親（検査セット）
              , info ->> ''set_cd'' as item_cd 
              , info ->> ''set_name'' as item_name
              , CASE (SELECT value FROM exam_set)
              WHEN ''1'' THEN item.in_hospital_cd1
              WHEN ''2'' THEN item.in_hospital_cd2
              WHEN ''3'' THEN item.in_hospital_cd3
              ELSE NULL
              END as in_hospital_cd
            from
              ( 
                select
                  m.* 
                from
                  pat_exam_main as m 
                where
                  m.is_del = ''0'' 
                  and jsonb_array_length(m.order_exam_set_info) > 0 
                  and m.exam_main_cd = @ordNo
              ) p 
              cross join lateral json_array_elements(p.order_exam_set_info ::json) info 
              left outer join mst_exam_set as item 
                on info ->> ''set_cd'' = (item.exam_set_cd || '''')
              WHERE info ->> ''set_cd'' IN (SELECT no FROM item_set_no)
              AND 
              CASE (SELECT value FROM output_item)
              WHEN ''2'' THEN false
              ELSE true
              END
          ) exam_all
        order by
          seq_no ASC 
          , sub_no ASC
      ) exam
  ) exam_full 
group by
  exam_full.exam_row 
order by
  exam_row', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'Medicom検査オーダ 繰り返し部', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310008, 'WITH
min_staff_ctl_no AS (
SELECT min(staff.value ->> ''ctl_no'') AS min_is_main_ctl_no
FROM pat_main 
        CROSS JOIN
            LATERAL json_array_elements(pat_main.charge_staff_info::json) staff
    WHERE
        pat_id = @patId
        AND staff.value ->> ''is_main'' = ''1'' 
),
staff AS (
SELECT 
    staff.value ->> ''staff_cd'' staff_cd
from pat_main 
        CROSS JOIN
            LATERAL json_array_elements(pat_main.charge_staff_info::json) staff
    WHERE
        pat_id = @patId
        and staff.value ->> ''ctl_no'' = (SELECT min_is_main_ctl_no FROM min_staff_ctl_no)
),
def_doctor AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''DEFAULT_DOCTOR''
)


SELECT 
    CASE 
    WHEN (SELECT min_is_main_ctl_no FROM min_staff_ctl_no) IS NULL THEN (SELECT value FROM def_doctor)
    ELSE (SELECT staff_cd FROM staff)
    END AS staff_cd
    ,CASE 
    WHEN (SELECT min_is_main_ctl_no FROM min_staff_ctl_no) IS NULL THEN 0
    ELSE 1
    END AS is_conv', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom検査オーダ担当医取得事前SQL', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310007, 'WITH  sequence_digit AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''SEQUENCE_DIGIT''
),
journal AS (
  SELECT
    COUNT(1) AS CNT 
  FROM
    sys_coop_journal AS coop1 
    JOIN sys_coop_journal AS coop2 
    ON coop1.facility_cd = coop2.facility_cd
    AND coop1.ctl_no = @ctlNo
    AND coop1.coop_cd = coop2.coop_cd
    AND TO_CHAR(coop2.reg_date, ''YYYYMMDD'') = TO_CHAR(coop1.reg_date, ''YYYYMMDD'') 
    AND coop2.ctl_no < @ctlNo
)

SELECT to_char(CURRENT_TIMESTAMP, ''YYMMDD'') || LPAD(((SELECT CNT FROM journal) % (RPAD(''1'', value::smallint, ''0'')::smallint))::text, value::smallint, ''0'') || ''.txt'' AS filename FROM sequence_digit', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom検査オーダファイル名取得', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310006, 'WITH exam_data AS(
  SELECT
    TO_CHAR(reg_exam_date, ''YYYYMMDD'') AS exam_date,
    CASE reg_order_class
      WHEN ''0'' THEN '' ''
      ELSE reg_order_class
    END AS exam_timing,
    exam_set_info ->> ''set_cd'' AS exam_set_cd,
    pat_id
  FROM
    ntss.pat_exam_main
    CROSS JOIN
      LATERAL json_array_elements(
        pat_exam_main.order_exam_set_info::json
      ) exam_set_info
  WHERE
    exam_main_cd = @ordNo
  limit 1
),
exam_set_data AS(
  SELECT
    other_exam_time
  FROM
    mst_exam_set
  WHERE
    exam_set_cd = (
      SELECT
        exam_set_cd
      FROM
        exam_data
    )::int
),
ord_data AS(
  SELECT
    ord_main.ind_treat_start_time,
    ord_main.ind_cond_info,
    ord_main.ind_bed_cd
  FROM
    ord_main
  WHERE
    pat_id = (
      SELECT
        pat_id
      FROM
        exam_data
    )
  AND treat_date = (
      SELECT
        exam_date
      FROM
        exam_data
    )
  AND ind_kur_cd > 0
  AND ord_main.is_del = ''0''
  ORDER BY
    ind_treat_start_time ASC
  LIMIT 1
),
before_margin AS(
  SELECT
    COALESCE(
      NULLIF(
        info ->> ''value'',
        ''''
      ),
      info ->> ''default_v''
    ) AS value
  FROM
    mst_coop_ini AS ini
    CROSS JOIN
      LATERAL json_array_elements(
        ini.coop_ini_info::json
      ) info
  WHERE
    facility_cd = @facilityCd
  AND is_del = ''0''
  AND info ->> ''key0'' = @key0
  AND info ->> ''key1'' = ''EXAM_ORD''
  AND info ->> ''key2'' = ''BEFORE_MARGIN''
),
after_margin AS(
  SELECT
    COALESCE(
      NULLIF(
        info ->> ''value'',
        ''''
      ),
      info ->> ''default_v''
    ) AS value
  FROM
    mst_coop_ini AS ini
    CROSS JOIN
      LATERAL json_array_elements(
        ini.coop_ini_info::json
      ) info
  WHERE
    facility_cd = @facilityCd
  AND is_del = ''0''
  AND info ->> ''key0'' = @key0
  AND info ->> ''key1'' = ''EXAM_ORD''
  AND info ->> ''key2'' = ''AFTER_MARGIN''
),
output_bed_no AS(
  SELECT
    COALESCE(
      NULLIF(
        info ->> ''value'',
        ''''
      ),
      info ->> ''default_v''
    ) AS value
  FROM
    mst_coop_ini AS ini
    CROSS JOIN
      LATERAL json_array_elements(
        ini.coop_ini_info::json
      ) info
  WHERE
    facility_cd = @facilityCd
  AND is_del = ''0''
  AND info ->> ''key0'' = @key0
  AND info ->> ''key1'' = ''EXAM_ORD''
  AND info ->> ''key2'' = ''OUTPUT_BED_NO''
)
SELECT
  exam_date,
  exam_timing,
  CASE exam_timing
    WHEN ''1'' THEN to_char((
        ind_treat_start_time::time - ((
            SELECT
              value
            FROM
              before_margin
          ) || '' minutes'')::interval
      ), ''HH24MI'')
    WHEN ''2'' THEN to_char((
        ind_treat_start_time::time + (
          ind_cond_info -> ''1'' ->> ''value'' || '' minutes''
        )::interval + ((
            SELECT
              value
            FROM
              after_margin
          ) || '' minutes'')::interval
      ), ''HH24MI'')
    ELSE(
      SELECT
        other_exam_time
      FROM
        exam_set_data
    )
  END AS exam_time,
  CASE(
      SELECT
        value
      FROM
        output_bed_no
    )
    WHEN ''1'' THEN
        ord_data.ind_bed_cd::text
    ELSE ''    ''
  END AS bed_cd
FROM
  exam_data,
  ord_data', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'Medicom', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310005, 'WITH other_sex AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''DEFAULT_SEX''
),
pat_id_digit AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''PAT_ID_DIGIT''
),
pat_id_padding AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''PAT_ID_PADDING''
),
unset_default_name AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''UNSET_DEFAULT_NAME''
),
outside_terms_default_name AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''OUTSIDE_TERMS_DEFAULT_NAME''
)

SELECT
  CASE 
    WHEN @patSex::text IN (''1'',''2'') THEN @patSex::text
    ELSE (SELECT value FROM other_sex)
    END AS pat_sex,
  CASE (SELECT value FROM pat_id_padding)
    WHEN ''0'' THEN LPAD(@hospPatId::text, (SELECT value FROM pat_id_digit)::smallint, ''0'')
    WHEN ''1'' THEN RPAD(@hospPatId::text, (SELECT value FROM pat_id_digit)::smallint, ''0'') 
    ELSE @hospPatId::text
    END AS hosp_pat_id,
  CASE 
    WHEN COALESCE(@patNameKana,'''') = '''' THEN (SELECT value FROM unset_default_name)
    ELSE 
        CASE
        WHEN @patNameKana  ~ ''^[ァ-ヶｦ-ﾟｱ-ﾝ 　]+$'' THEN LEFT(hankana_translate(@patNameKana), 20)
        ELSE (SELECT value FROM outside_terms_default_name)
        END
    END AS pat_name_kana', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom検査オーダ連携用の連携設定で変換する値取得', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, '[{"sql_cd": -310004, "field_name": "hosp_pat_id", "replace_var": "@hospPatId"}, {"sql_cd": -310004, "field_name": "pat_name_kana", "replace_var": "@patNameKana"}, {"sql_cd": -310004, "field_name": "pat_sex", "replace_var": "@patSex"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310004, 'select
 LEFT(hosp_pat_id, 10) as hosp_pat_id,
 personal_info_decrypt(pat_last_name)||'' ''||personal_info_decrypt(pat_first_name) as pat_name,
 personal_info_decrypt(pat_last_name_kana)||'' ''||personal_info_decrypt(pat_first_name_kana) as pat_name_kana,
 personal_info_decrypt(pat_last_name_alpha)||'' ''||personal_info_decrypt(pat_first_name_alpha) as pat_name_alpha,
 pat_birthday as pat_birthday_yyyymmdd,
 to_char(to_date(pat_birthday, ''YYYYMMDD''), ''YYYY/MM/DD'') as pat_birthday,
 case when pat_birthday is null then null
 else to_char(date_part(''year'',age(''now'', to_date(pat_birthday, ''YYYYMMDD''))), ''FM999'')
 end as pat_age,
 pat_sex,
 pat_blood_type_abo,
 pat_blood_type_rh,
 pat_blood_type_abo * 10 +  pat_blood_type_rh as pat_blood_type_abo_rh,
 pat_blood_type_serovar as pat_blood_type_serovar,
 case in_out_class when 0 then ''2'' when 1 then ''1'' else '''' end as in_out_class,
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
 COALESCE(severity_cd,0) as severity_cd,
 COALESCE(transport_cd,0) as transport_cd,
 is_die,
 die_date,
 die_cd,
 die_cd as die_cd1,
 -- 透析困難有無
 case when jsonb_array_length(dial_diff_com_info) > 0 then 1 else 0 end as dial_diff_com_info_flag,
 up_date
 from
 pat_personal_main
 where
 is_del = ''0''
 and
 pat_personal_main.pat_id = @patId', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310003, 'WITH def_course AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''DEFAULT_COURSE''
),
def_ward AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''DEFAULT_WARD''
)

SELECT
  medical_care_info ->> ''ward_cd'' AS ward_cd
  , ward.ward_name AS ward_name
  , LEFT(COALESCE(ward.in_hospital_cd_1, (SELECT value FROM def_ward)), 15) AS ward_in_hospital_cd
  , medical_care_info ->> ''main_course_cd'' AS main_course_cd
  , course.course_name AS course_name
  , LEFT(COALESCE(course.in_hospital_cd_1, (SELECT value FROM def_course)), 15) AS course_in_hospital_cd
FROM
  pat_main AS main 
  LEFT JOIN mst_ward AS ward ON ward.ward_cd ::TEXT = main.medical_care_info ->> ''ward_cd'' 
  LEFT JOIN mst_course AS course ON course.course_cd ::TEXT = main.medical_care_info ->> ''main_course_cd'' 
WHERE
  pat_id = @patId', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'Medicom検査オーダ', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310002, 'SELECT
        UNNEST(string_to_array(COALESCE(
                    NULLIF(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) AS facility_no
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(
                ini.coop_ini_info::json
            ) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''FACILITY_NO''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom検査オーダ連携用の[連携設定→施設NO]値取得', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-309101, 'WITH
exam_item AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        ntss.mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    where
        facility_cd = ''@facilityCd''
    AND is_del = ''0''
    AND info ->> ''key0'' = ''MED''
    AND info ->> ''key1'' = ''MST''
    AND info ->> ''key2'' = ''EXAM_ITEM''
)
INSERT INTO pat_exam_main (
  pat_id,
  facility_cd,
  ord_no,
  fn_pat_id,
  reg_exam_date,
  reg_order_class,
  exam_status,
  order_comment,
  order_exam_set_info,
  exam_order_info,
  order_label_info,
  data_gen_class,
  result_exam_date,
  result_comment,
  exam_result_info,
  cop_order_no1,
  cop_order_no2,
  is_lock,
  ind_user_id,
  is_del,
  reg_date,
  reg_staff,
  up_date,
  up_staff,
  is_order,
  exam_week,
  exam_from,
  exam_to,
  exam_pattern 
)
VALUES
  (
    @patId,
    ''@facilityCd'',
  CASE
      ''@ordNo'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@ordNo'', ''9999999999999999999999999999999999999999999999999999999999999999'' ) 
    END,
    NULLIF ( ''@fnPatId'', '''' ),
  CASE
      ''@regExamDate'' 
      WHEN '''' THEN
      CURRENT_TIMESTAMP ELSE to_timestamp( ''@regExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'' ) 
    END,
	CASE 
	    WHEN ''@regOrderClass'' IN (''1'', ''2'') THEN ''@regOrderClass''
	    ELSE ''0''
	END,
    NULLIF ( ''@examStatus'', '''' ),
    NULLIF ( ''@orderComment'', '''' ),
    ''@orderExamSetInfoValue'',
    ''@examOrderInfoValue'',
    ''@orderLabelInfoValue'',
    NULLIF ( ''@dataGenClass'', '''' ),
  CASE
      ''@resultExamDate'' 
      WHEN '''' THEN
      NULL ELSE to_timestamp( ''@resultExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'' ) 
    END,
    ''@resultComment'',
    ''@examResultInfoValue'',
  CASE
      ''@copOrderNo1'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@copOrderNo1'', ''9999999999999999999999999999999999999999999999999999999999999999'' ) 
    END,
  CASE
      ''@copOrderNo2'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@copOrderNo2'', ''9999999999999999999999999999999999999999999999999999999999999999'' ) 
      END,
    NULLIF ( ''@isLock'', '''' ),
  CASE
      ''@indUserId'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@indUserId'', ''9999999999999999999999999999999999999999999999999999999999999999'' ) 
    END,
    ''0'',
    CURRENT_TIMESTAMP,
  CASE
      ''@regStaff'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@regStaff'', ''9999999999999999999999999999999999999999999999999999999999999999'' ) 
    END,
    CURRENT_TIMESTAMP,
  CASE
      ''@upStaff'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@upStaff'', ''9999999999999999999999999999999999999999999999999999999999999999'' ) 
    END,
    NULLIF ( ''@isOrder'', '''' ),
  CASE
      ''@examWeek'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@examWeek'', ''9999999999999999'' ) 
    END,
  CASE
      ''@examFrom'' 
      WHEN '''' THEN
      NULL ELSE to_timestamp( ''@examFrom'', ''yyyymmddhh24miss'' ) 
      END,
  CASE
      ''@examTo'' 
      WHEN '''' THEN
      NULL ELSE to_timestamp( ''@examTo'', ''yyyymmddhh24miss'' ) 
      END,
  CASE
      ''@examPattern'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@examPattern'', ''9999999999999999'' ) 
    END 
  )', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)Medicomの検査結果', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-309002, 'WITH center_codes AS (
    SELECT
        UNNEST(
            STRING_TO_ARRAY(
                COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v''),
                '',''
            )
        ) AS val
    FROM
        mst_coop_ini AS ini
    CROSS JOIN
    LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND is_disp = ''1''
        AND info ->> ''key0'' = @key0
        AND info ->> ''key1'' = ''SNY_EXAM_ORDER_INFO''
        AND info ->> ''key2'' = ''CENTER_CODE''
)
SELECT
    1
FROM
    center_codes
WHERE
    TRIM(BOTH '' 　'' FROM val) = @centerCode;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)Medicomの検査結果 センターコードチェック', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-309001, 'SELECT
	1
WHERE
	@regExamDate_Date = ''''', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)Medicomの検査結果', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-306001, ' select
 ltrim(hosp_pat_id,''0'') AS hosp_pat_id,
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
 COALESCE(severity_cd,0) as severity_cd,
 COALESCE(transport_cd,0) as transport_cd,
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
 pat_personal_main.pat_id = @patId', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'Medicom', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1001, 'WITH sch_start_time AS (
    SELECT 
        COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS v
    FROM 
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE 
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info->>''key0'', '''') = @key0
        AND info->>''key1'' = ''COOP_CONFIG''
        AND info->>''key2'' = ''SCH_START_TIME''
)
SELECT 
    COALESCE(
        ord_main.treat_date,
        TO_CHAR(ord_main.rst_start_date::TIMESTAMP, ''YYYYMMDD''),
        ''''
    ) AS treat_date,
    CASE 
        WHEN (SELECT v FROM sch_start_time) = ''0'' 
            THEN COALESCE(
                LEFT(mst_kur.kur_standard_start_time, 4),
                TO_CHAR(ord_main.rst_start_date::TIMESTAMP, ''HH24MI''),
                ''''
            )
        WHEN (SELECT v FROM sch_start_time) = ''1'' 
            THEN COALESCE(
                ord_main.ind_treat_start_time,
                TO_CHAR(ord_main.rst_start_date::TIMESTAMP, ''HH24MI''),
                ''''
            )
        ELSE ''''
    END AS ind_treat_start_time
FROM 
    ord_main
JOIN 
    mst_kur ON ord_main.rst_kur_cd = mst_kur.kur_cd
WHERE 
    ord_main.ord_no = @ordNo', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2020-03-17 16:17:08.001', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-427, 'select 
	''除水'' as detail_id,
	trim(to_char(TO_NUMBER(COALESCE(ord.rst_weight_info->>''water_removal_target'',''0''),''9999.99''),''9990.99'')) as e01,
	trim(to_char(ROUND(TO_NUMBER(COALESCE(ord.rst_weight_info->>''water_removal_target'',''0''),''9990.99'') / TRUNC(TO_NUMBER(ord.rst_cond_info->''1''->>''value'',''999999'')/60,0), 2),''9990.99'')) as e02,
	trim(to_char(TO_NUMBER(COALESCE(ord.rst_weight_info->>''add_total'',''0''),''9999.99''),''9990.99'')) as e03
from 
	ord_main ord
where
	ord.ord_no = @ordNo
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom)経過情報（除水）', '2020-05-27 10:00:13.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(6101, 'SELECT
    exam_main_cd,
    pat_id,
    facility_cd,
    ord_no,
    fn_pat_id,
    to_char( reg_exam_date, ''yyyy-MM-dd hh24:mi:ss'' ) AS reg_exam_date,
    reg_order_class,
    exam_status,
    order_comment,
    order_exam_set_info,
    exam_order_info,
    order_label_info,
    data_gen_class,
    to_char( result_exam_date, ''yyyy-MM-dd hh24:mi:ss'' ) AS result_exam_date,
    result_comment,
    exam_result_info,
    cop_order_no1,
    cop_order_no2,
    is_lock,
    ind_user_id,
    is_del,
    reg_date,
    reg_staff,
    up_date,
    up_staff,
    is_order,
    exam_week,
    to_char( exam_from, ''yyyymmddhh24miss'' ) AS exam_from,
    to_char( exam_to, ''yyyymmddhh24miss'' ) AS exam_to,
    exam_pattern,
    (
    SELECT
        (
            COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''disp_order'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
        ) AS next_disp_order 
    FROM
        pat_exam_main exam
        CROSS JOIN LATERAL json_array_elements ( exam.exam_result_info :: json ) RESULT 
    WHERE
        exam.exam_main_cd = pat_exam_main.exam_main_cd 
    ) AS next_disp_order 
FROM
    pat_exam_main 
WHERE
    is_del = ''0'' 
    AND pat_id = @patId 
    AND facility_cd = @facilityCd
    AND reg_exam_date = TO_TIMESTAMP(@regExamDate_Date, ''YYYY-MM-DD HH24:MI:SS'') 
    AND reg_order_class = 
    CASE 
        WHEN NULLIF(@regOrderClass, '''')::int IN (1, 2) THEN @regOrderClass::text
        ELSE ''0'' 
    END', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)Medicomの検査結果', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(6103, 'UPDATE pat_exam_main 
SET result_exam_date = CASE
    ''@resultExamDate'' 
    WHEN '''' THEN
    NULL ELSE to_timestamp( ''@resultExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'' ) 
    END,
    up_date = CURRENT_TIMESTAMP ,
    exam_result_info =''[]''
WHERE
    is_del = ''0'' 
    AND pat_id = @patId 
    AND facility_cd = ''@facilityCd''
    AND reg_exam_date = TO_TIMESTAMP(''@regExamDate_Date'', ''YYYY-MM-DD HH24:MI:SS'') 
    AND reg_order_class = ''@regOrderClass'' 
    AND exam_main_cd = @examMainCd', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)Medicomの検査結果', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(6202, 'WITH exam_item AS(
    SELECT
        COALESCE(
            NULLIF(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) AS value
    FROM
        ntss.mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = ''@facilityCd''
        AND is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = ''@key0''
        AND info ->> ''key1'' = ''MST''
        AND info ->> ''key2'' = ''EXAM_ITEM''
),
item_cd AS (
    SELECT
        exam_item_cd,
        exam_item_name
    FROM
        mst_exam_item
    WHERE
        facility_cd = ''@facilityCd''
        AND CASE WHEN (
            SELECT
                value
            FROM
                exam_item
        ) = ''1'' THEN mst_exam_item.in_hospital_cd1 WHEN (
            SELECT
                value
            FROM
                exam_item
        ) = ''2'' THEN mst_exam_item.in_hospital_cd2 WHEN (
            SELECT
                value
            FROM
                exam_item
        ) = ''3'' THEN mst_exam_item.in_hospital_cd3 END = ''@examResultInfo.itemCd''
        LIMIT 1
),
chg_cnt AS (
    SELECT
        count(exam_result_info) AS chgCnt
    FROM
        pat_exam_main
        CROSS JOIN jsonb_array_elements(exam_result_info) exam_result_infoj
    WHERE
        facility_cd = ''@facilityCd''
        AND pat_id = @patId 
        AND (exam_result_infoj ->> ''item_cd'')::INTEGER = (SELECT exam_item_cd FROM item_cd)
        AND is_del = ''0''
),
keep_cnt AS (
    SELECT
        count(exam_result_infoj) AS keepcnt
    FROM
        pat_exam_main
        CROSS JOIN jsonb_array_elements(exam_result_info) exam_result_infoj
    WHERE
        facility_cd = ''@facilityCd''
        AND pat_id = @patId
        AND (exam_result_infoj ->> ''item_cd'')::INTEGER != (SELECT exam_item_cd FROM item_cd)
        AND is_del = ''0''
),
rst_comment AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS comCd1
    FROM
        ntss.mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = ''@facilityCd''
        AND is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = ''@key0''
        AND info ->> ''key1'' = ''EXAM_RST_COMMENT''
        AND info ->> ''key2'' = ''@examResultInfo.comCd1''
), 
rst_comment2 AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS comCd2
    FROM
        ntss.mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = ''@facilityCd''
        AND is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = ''@key0''
        AND info ->> ''key1'' = ''EXAM_RST_COMMENT''
        AND info ->> ''key2'' = ''@examResultInfo.comCd2''
),
jsonb_tbl AS (
    SELECT jsonb_build_array(
        jsonb_build_object(
            ''com_cd'',
            null,
            ''exam_class'',
            ''@examResultInfo.examClass'',
            ''freememo'',
            CASE 
                WHEN (select comCd1 from rst_comment) <> '''' AND (select comCd2 from rst_comment2) <> ''''
                    THEN concat_ws('', '',NULLIF((SELECT comCd1 FROM rst_comment), ''''), NULLIF((SELECT comCd2 FROM rst_comment2), ''''))
                    ELSE concat_ws('''',(select comCd1 from rst_comment),(select comCd2 from rst_comment2))
            END,
            ''hl'',
            ''@examResultInfo.hl'',
            ''item_cd'',
            (SELECT exam_item_cd FROM item_cd),
            ''item_name'',
            (SELECT exam_item_name FROM item_cd),
            ''lower'',
            null,
            ''result'',
            ''@examResultInfo.result'',
            ''result_date'',
            TO_CHAR(TO_TIMESTAMP(''@regExamDate_Date'', ''YYYY-MM-DD HH24:MI:SS''), ''YYYY/MM/DD HH24:MI:SS''),
            ''unit'',
            null,
            ''upper'',
            null
        ) 
    ) AS newJsonb
)
UPDATE pat_exam_main
SET
    exam_result_info = 
    CASE 
        WHEN exam_result_info IS NULL OR exam_result_info = ''[]'' THEN 
            newJsonb
        ELSE 
            CASE 
                WHEN chgCnt = 0 THEN 
                    exam_result_info || newJsonb
                ELSE 
                    CASE 
                        WHEN keepCnt = 0 THEN 
                            newJsonb 
                        ELSE 
                            (
                                SELECT jsonb_agg(exam_result_info_j)
                                FROM pat_exam_main
                                CROSS JOIN LATERAL jsonb_array_elements(exam_result_info) exam_result_info_j
                                WHERE facility_cd = ''@facilityCd''
                                  AND pat_id = @patId
                                  AND (exam_result_info_j ->> ''item_cd'')::INTEGER != (SELECT exam_item_cd FROM item_cd)
                                  AND exam_main_cd = @examMainCd
                            ) || newJsonb
                    END 
            END 
    END
FROM
	chg_cnt,
	jsonb_tbl,
	keep_cnt
WHERE
    is_del = ''0''
    AND pat_id = @patId
    AND facility_cd = ''@facilityCd''
    AND reg_exam_date = TO_TIMESTAMP(''@regExamDate_Date'', ''YYYY-MM-DD HH24:MI:SS'')
    AND reg_order_class = 
    CASE 
        WHEN ''@regOrderClass'' IN (''1'', ''2'') THEN ''@regOrderClass''
        ELSE ''0'' 
    END
    AND exam_main_cd = @examMainCd
    AND COALESCE(CAST((SELECT exam_item_cd FROM item_cd) AS TEXT), '''') <> ''''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)Medicomの検査結果', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);