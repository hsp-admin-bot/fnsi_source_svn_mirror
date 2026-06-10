DELETE FROM "ntss"."sys_data_set" where sql_cd in (115);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (115, 'WITH DATA AS (

WITH tmp1 AS (
  SELECT
    ord_no,
    treat_date,
    jsonb_array_elements(rst_treatment_info) AS rti,
		jsonb_array_elements(rst_treat_staff_info) AS rtsi
  FROM ord_main
  WHERE ord_no = @ordNo
    AND is_del = ''0''
    AND rst_dialysis_state <> ''0''
    AND facility_cd = @facilityCd
),
oxygen_elements AS (
  SELECT
    ord_no,
    treat_date,
    (rti->>''occur_date'')::timestamp AS occur_date,
    rti->>''oxygen_start'' AS oxygen_start,
    rti->>''oxygen_amount'' AS oxygen_amount,
    rti->>''oxygen_speed'' AS oxygen_speed,
		rtsi->>''treat_staff_name'' AS staff_name
  FROM tmp1
  WHERE rti->>''treat_class'' = ''3''
),
start_tbl AS (
  SELECT
    ord_no,
    treat_date,
    occur_date AS start_date,
    oxygen_speed AS speed,
		staff_name AS start_staff,
    ROW_NUMBER() OVER (PARTITION BY ord_no ORDER BY occur_date) AS rn
  FROM oxygen_elements
  WHERE oxygen_start IS NOT NULL AND LENGTH(oxygen_start) > 0
),
end_tbl AS (
  SELECT
    ord_no,
    treat_date,
    occur_date AS end_date,
    oxygen_amount AS amount,
		staff_name AS end_staff,
    ROW_NUMBER() OVER (PARTITION BY ord_no ORDER BY occur_date) AS rn
  FROM oxygen_elements
  WHERE oxygen_amount IS NOT NULL AND LENGTH(oxygen_amount) > 0
)

SELECT
  s.ord_no AS ord_no_t,
  s.ord_no,
  s.treat_date,
  s.start_date,
  e.end_date,
  s.speed,
  e.amount,
  s.start_staff,
  e.end_staff
FROM start_tbl s
LEFT JOIN end_tbl e ON s.ord_no = e.ord_no AND s.rn = e.rn
) ,
time_info AS (
	WITH b AS (
    select ord_main.* from ord_main
     where rst_dialysis_state between ''1'' and ''5''
     and
			ord_no = @ordNo
     and
       is_del = ''0''
	), d AS (
    select b.ord_no
    , data_type
    , MAX(bio_moni_ctl_no) AS bio_moni_ctl_no
    from b inner join mni_monitor on (b.ord_no = mni_monitor.ord_no)
    group by b.ord_no
    , mni_monitor.data_type
	), e AS (
    select mni_monitor.*,
    to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') AS 経過時間
    , to_number(mni_monitor.monitor_data::json->>''3'', ''9999'') AS 残り時間_除水完了
    , to_number(mni_monitor.monitor_data::json->>''4'', ''9999'') AS 残り時間_透析完了
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
    where d.data_type = 1
	), f AS (
    select e.*
    , e.経過時間 + e.残り時間_除水完了 AS 予測時間_除水
    , e.経過時間 + e.残り時間_透析完了 AS 予測時間_透析
    from e
	)
	select
	b.ord_no as ordnob,
	-- 終了予定
	b.rst_start_date + e.経過時間  * interval ''1 minute'' AS  ind_end_date,
	-- 終了予測
	CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 THEN b.rst_start_date + f.予測時間_除水 * interval ''1 minute''
       ELSE b.rst_start_date + f.予測時間_透析 * interval ''1 minute''
	END AS ind_end_date_time
	-- 透析開始
	, b.rst_start_date
	-- 透析終了
	, b.rst_end_date
	from  b left JOIN e on b.ord_no=e.ord_no left JOIN f on b.ord_no=f.ord_no
)
SELECT
DATA.ord_no_t as ord_no,
	*
FROM
	DATA
	LEFT JOIN
	time_info
	on
	DATA.ord_no_t = time_info.ordnob
	;
	', 2, '[{"preview": "09:47", "can_calc": "0", "data_code": "start_date", "data_name": "開始時刻", "data_type": "DateTime", "conv_table": [], "data_class": "酸素吸入", "field_name": "start_date", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:00", "can_calc": "0", "data_code": "end_date", "data_name": "終了時刻", "data_type": "DateTime", "conv_table": [], "data_class": "酸素吸入", "field_name": "end_date", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護婦２", "can_calc": "0", "data_code": "start_staff", "data_name": "開始者", "data_type": "string", "conv_table": [], "data_class": "酸素吸入", "field_name": "start_staff", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護婦３", "can_calc": "0", "data_code": "end_staff", "data_name": "終了者", "data_type": "string", "conv_table": [], "data_class": "酸素吸入", "field_name": "end_staff", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "1", "data_code": "speed", "data_name": "吸入速度", "data_type": "decimal", "conv_table": [], "data_class": "酸素吸入", "field_name": "speed", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15", "can_calc": "1", "data_code": "amount", "data_name": "吸入量", "data_type": "decimal", "conv_table": [], "data_class": "酸素吸入", "field_name": "amount", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：酸素吸入 @ordNo 使用', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);



