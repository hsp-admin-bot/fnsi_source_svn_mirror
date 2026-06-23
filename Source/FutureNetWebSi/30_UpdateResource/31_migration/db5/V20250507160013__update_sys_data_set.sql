DELETE FROM "ntss"."sys_data_set" where sql_cd in (150,151);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (150, 'WITH 
patIds_tbl AS (
	SELECT
		ord.pat_id
		,ord.treat_date
		,ord.ord_no
	FROM
		ord_schedule AS ord
	INNER JOIN ord_main ON ord.ord_no = ord_main.ord_no 
	and ord.facility_cd = ord_main.facility_cd
	LEFT JOIN mst_bed ON (mst_bed.bed_cd = ord.bed_cd )
	WHERE
		ord.treat_date between to_char(date_trunc(''day'', (@fromDate)::timestamp), ''yyyymmdd'') and to_char(date_trunc(''day'', (@toDate)::timestamp) + ''1 days - 1 milliseconds'', ''yyyymmdd'')
		AND ord.facility_cd = @facilityCd
		AND ord.is_dummy = ''0''
		AND ((mst_bed.machine_no is not null ) or (mst_bed.machine_no is  null and mst_bed.bed_cd is  null))
	ORDER BY ord.treat_date,ord.pat_id
)
, Selunique AS (
	SELECT 
    pat_id,
	  ELEMENT->> ''period_start'' AS in_out_date,
		ELEMENT ->> ''disp_order'' AS disp_order,
		ELEMENT ->> ''in_out'' AS in_out,
		ELEMENT ->> ''move_in_out'' AS move_in_out,
		ELEMENT ->> ''ctl_no'' AS ctl_no,
	CASE
			WHEN ELEMENT ->> ''move_in_out'' = ''4'' THEN
			''入院'' 
			WHEN ELEMENT ->> ''move_in_out'' = ''5'' THEN
			''外来''
			WHEN ELEMENT ->> ''move_in_out'' = ''6'' THEN
			''外来''
		END AS move_in_out_name 
	FROM
		pat_unique,
		jsonb_array_elements ( in_out_visit_history_info ) AS ELEMENT 
	WHERE
		pat_id in (SELECT DISTINCT pat_id FROM patIds_tbl)
		AND facility_cd = @facilityCd
	ORDER BY
		in_out_date ASC,ctl_no desc 
),
SeluniqueDis AS (
	SELECT
		pat_id,
		in_out_date,
		ROW_NUMBER() OVER (PARTITION BY pat_id, in_out_date ORDER BY in_out_date ASC,ctl_no desc) AS rm,  
		move_in_out_name
	FROM
		Selunique
),
LastData AS (
	SELECT
		ROW_NUMBER() OVER (PARTITION BY pat_id ORDER BY pat_id ASC, in_out_date DESC) AS idx,
		pat_id,
		in_out_date,
		move_in_out_name
	FROM
		SeluniqueDis
	WHERE rm = 1
 		AND move_in_out_name is not null
		AND in_out_date < to_char(date_trunc(''day'', (@fromDate)::timestamp), ''yyyymmdd'')
	ORDER BY pat_id ASC, in_out_date DESC
),
RangeData AS (
	SELECT
		pat_id,
		in_out_date,
		move_in_out_name
	FROM
		SeluniqueDis
	WHERE rm = 1
 		AND move_in_out_name is not null
		AND in_out_date between to_char(date_trunc(''day'', (@fromDate)::timestamp), ''yyyymmdd'') and to_char(date_trunc(''day'', (@toDate)::timestamp) + ''1 days - 1 milliseconds'', ''yyyymmdd'')
),
RangeOrdData AS (
	SELECT
		p.pat_id,
		string_agg(treat_date, '','') AS date_str
	FROM
		patIds_tbl p
	WHERE
		p.pat_id in (SELECT r.pat_id FROM RangeData r)
	GROUP BY p.pat_id
)

SELECT 
	p.treat_date,
	p.pat_id,
	1 AS has_ord,
	l.in_out_date AS last_in_out_date,
	l.move_in_out_name AS last_move_in_out_name,
	r.in_out_date,
	r.move_in_out_name
FROM
	patIds_tbl p
LEFT JOIN LastData l ON p.pat_id = l.pat_id AND l.idx = 1
LEFT JOIN RangeData r ON p.pat_id = r.pat_id AND p.treat_date = r.in_out_date
UNION ALL
SELECT
	null AS treat_date,
	r.pat_id,
	0 AS has_ord,
	null AS last_in_out_date,
	null AS last_move_in_out_name,
	r.in_out_date,
	r.move_in_out_name
FROM
	RangeData r
LEFT JOIN RangeOrdData ro ON r.pat_id = ro.pat_id
WHERE POSITION(r.in_out_date IN ro.date_str) = 0
', 2, '[{"preview": "0", "can_calc": "0", "data_code": "out_pat_cnt", "data_name": "外来合計", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "out_pat_cnt", "disp_format": "0", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '薬剤週間薬剤集計表 外来合計@facilityCd @fromdate @todate', '2021-05-07 10:00:02', CURRENT_TIMESTAMP, '[]');
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (151, 'WITH 
patIds_tbl AS (
	SELECT
		ord.pat_id
		,ord.treat_date
		,ord.ord_no
	FROM
		ord_schedule AS ord
	INNER JOIN ord_main ON ord.ord_no = ord_main.ord_no 
	and ord.facility_cd = ord_main.facility_cd
	LEFT JOIN mst_bed ON (mst_bed.bed_cd = ord.bed_cd )
	WHERE
		ord.treat_date between to_char(date_trunc(''day'', (@fromDate)::timestamp), ''yyyymmdd'') and to_char(date_trunc(''day'', (@toDate)::timestamp) + ''1 days - 1 milliseconds'', ''yyyymmdd'')
		AND ord.facility_cd = @facilityCd
		AND ord.is_dummy = ''0''
		AND ((mst_bed.machine_no is not null ) or (mst_bed.machine_no is  null and mst_bed.bed_cd is  null))
	ORDER BY ord.treat_date,ord.pat_id
)
, Selunique AS (
	SELECT 
    pat_id,
	  ELEMENT->> ''period_start'' AS in_out_date,
		ELEMENT ->> ''disp_order'' AS disp_order,
		ELEMENT ->> ''in_out'' AS in_out,
		ELEMENT ->> ''move_in_out'' AS move_in_out,
		ELEMENT ->> ''ctl_no'' AS ctl_no,
	CASE
			WHEN ELEMENT ->> ''move_in_out'' = ''4'' THEN
			''入院'' 
			WHEN ELEMENT ->> ''move_in_out'' = ''5'' THEN
			''外来''
			WHEN ELEMENT ->> ''move_in_out'' = ''6'' THEN
			''外来''
		END AS move_in_out_name 
	FROM
		pat_unique,
		jsonb_array_elements ( in_out_visit_history_info ) AS ELEMENT 
	WHERE
		pat_id in (SELECT DISTINCT pat_id FROM patIds_tbl)
		AND facility_cd = @facilityCd
	ORDER BY
		in_out_date ASC,ctl_no desc 
),
SeluniqueDis AS (
	SELECT
		pat_id,
		in_out_date,
		ROW_NUMBER() OVER (PARTITION BY pat_id, in_out_date ORDER BY in_out_date ASC,ctl_no desc) AS rm,  
		move_in_out_name
	FROM
		Selunique
),
LastData AS (
	SELECT
		ROW_NUMBER() OVER (PARTITION BY pat_id ORDER BY pat_id ASC, in_out_date DESC) AS idx,
		pat_id,
		in_out_date,
		move_in_out_name
	FROM
		SeluniqueDis
	WHERE rm = 1
 		AND move_in_out_name is not null
		AND in_out_date < to_char(date_trunc(''day'', (@fromDate)::timestamp), ''yyyymmdd'')
	ORDER BY pat_id ASC, in_out_date DESC
),
RangeData AS (
	SELECT
		pat_id,
		in_out_date,
		move_in_out_name
	FROM
		SeluniqueDis
	WHERE rm = 1
 		AND move_in_out_name is not null
		AND in_out_date between to_char(date_trunc(''day'', (@fromDate)::timestamp), ''yyyymmdd'') and to_char(date_trunc(''day'', (@toDate)::timestamp) + ''1 days - 1 milliseconds'', ''yyyymmdd'')
),
RangeOrdData AS (
	SELECT
		p.pat_id,
		string_agg(treat_date, '','') AS date_str
	FROM
		patIds_tbl p
	WHERE
		p.pat_id in (SELECT r.pat_id FROM RangeData r)
	GROUP BY p.pat_id
)

SELECT 
	p.treat_date,
	p.pat_id,
	1 AS has_ord,
	l.in_out_date AS last_in_out_date,
	l.move_in_out_name AS last_move_in_out_name,
	r.in_out_date,
	r.move_in_out_name
FROM
	patIds_tbl p
LEFT JOIN LastData l ON p.pat_id = l.pat_id AND l.idx = 1
LEFT JOIN RangeData r ON p.pat_id = r.pat_id AND p.treat_date = r.in_out_date
UNION ALL
SELECT
	null AS treat_date,
	r.pat_id,
	0 AS has_ord,
	null AS last_in_out_date,
	null AS last_move_in_out_name,
	r.in_out_date,
	r.move_in_out_name
FROM
	RangeData r
LEFT JOIN RangeOrdData ro ON r.pat_id = ro.pat_id
WHERE POSITION(r.in_out_date IN ro.date_str) = 0
', 2, '[{"preview": "0", "can_calc": "0", "data_code": "hosp_pat_cnt", "data_name": "入院合計", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "hosp_pat_cnt", "disp_format": "0", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '薬剤週間薬剤集計表 入院合計@facilityCd @fromdate @todate', '2021-05-07 10:00:02', CURRENT_TIMESTAMP, '[]');
