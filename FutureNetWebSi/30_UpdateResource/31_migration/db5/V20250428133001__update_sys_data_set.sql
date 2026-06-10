DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (
	-317125,-317126,-317127
	);

INSERT INTO ntss.sys_data_set
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
		(unescape_html(REPLACE(REGEXP_REPLACE(substring(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g'') from 1 for length(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g''))), ''<[^>]*>'', '''', ''g''),E''\uFEFF'' ,'''')))  AS e01
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
	pei.pat_event_cd = interview_record_info.pat_event_cd', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携問診記録取得SQL', '2025-04-07 14:38:45.425', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
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
	and info ->> ''key0'' = @key0
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
		(unescape_html(REPLACE(REGEXP_REPLACE(substring(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g'') from 1 for length(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g''))), ''<[^>]*>'', '''', ''g''),E''\uFEFF'' ,'''')))  AS e01
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
		(unescape_html(REPLACE(REGEXP_REPLACE(substring(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g'') from 1 for length(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g''))), ''<[^>]*>'', '''', ''g''),E''\uFEFF'' ,'''')))  AS e01
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
		(unescape_html(REPLACE(REGEXP_REPLACE(substring(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g'') from 1 for length(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g''))), ''<[^>]*>'', '''', ''g''),E''\uFEFF'' ,'''')))  AS e01
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
		(unescape_html(REPLACE(REGEXP_REPLACE(substring(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g'') from 1 for length(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g''))), ''<[^>]*>'', '''', ''g''),E''\uFEFF'' ,'''')))  AS e01
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
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携SOAP繰り返し取得SQL', '2025-04-07 14:38:45.425', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
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
		(unescape_html(REPLACE(REGEXP_REPLACE(substring(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g'') from 1 for length(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g''))), ''<[^>]*>'', '''', ''g''),E''\uFEFF'' ,''''))) AS e01
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
	pei.pat_event_cd = nursing_notes_info.pat_event_cd', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携看護メモ録取得SQL', '2025-04-07 14:38:45.425', CURRENT_TIMESTAMP, NULL);
