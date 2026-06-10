DELETE FROM "ntss"."sys_data_set" where sql_cd in (82,99,104);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (82, 'WITH ord_key_tbl as (
  select
    ord_no,
    treat_date
  from
    ord_main
  where
    ord_no = @ordNo
    and is_del = ''0''
), ord_hist_tbl as (
  select
    ord_no,
    to_date(treat_date, ''yyyymmdd'') as treat_date,
    latest_dw.cond_dw AS rst_dw,
		case when ind_cond_info->''3''->>''value'' = ''-1'' then latest_dw.cond_dw
		else ind_cond_info->''3''->>''value'' end as target_weight
  from
    ord_main as om
		INNER JOIN pat_unique 
        ON om.pat_id = pat_unique.pat_id
        AND pat_unique.is_del = ''0''
				LEFT JOIN LATERAL (
        SELECT elem ->> ''dw'' AS cond_dw
        FROM json_array_elements(pat_unique.physical_info::json) WITH ORDINALITY AS t(elem, idx)
        WHERE (elem ->> ''dw'') IS NOT NULL AND (elem ->> ''dw'') != ''''
				 AND TO_DATE(elem ->> ''exam_date'', ''YYYY-MM-DD'') <= TO_DATE(om.treat_date, ''YYYYMMDD'')
        ORDER BY idx
        LIMIT 1
    ) AS latest_dw ON TRUE
  where
  om.pat_id = @patId
  and  om.ord_no <> (select ord_no from ord_key_tbl)
  and
    om.treat_date <= (select treat_date from ord_key_tbl)
  and
     om.rst_dialysis_state = ''0''
  and om.is_del = ''0''
  order by
    om.treat_date desc
  limit 2
), ord_array_tbl as (
  select
    array_agg(ord_no) as array_ord_no,
    array_agg(treat_date) as array_treat_date,
    array_agg(rst_dw) as array_dw,
    array_agg(target_weight) as array_target_weight
  from
    ord_hist_tbl
)
select
	ord_no as ord_no_t,
	treat_date,
  array_ord_no[1] as ord_no1,
  array_ord_no[2] as ord_no2,
  array_treat_date[1] as treat_date1,
  array_treat_date[2] as treat_date2,
  array_dw[1] as dw1,
  array_dw[2] as dw2,
  array_target_weight[1] as target_weight1,
  array_target_weight[2] as target_weight2
from
  ord_array_tbl,ord_key_tbl', 2, '[{"preview": "55.00", "can_calc": "0", "data_code": "dw1", "data_name": "DW（前回）", "data_type": "decimal", "conv_table": [], "data_class": "体重情報(過去指示)", "field_name": "dw1", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "0", "data_code": "target_weight1", "data_name": "目標体重（前回）", "data_type": "decimal", "conv_table": [], "data_class": "体重情報(過去指示)", "field_name": "target_weight1", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/04", "can_calc": "0", "data_code": "treat_date1", "data_name": "透析予定日(前回)", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報(過去指示)", "field_name": "treat_date1", "disp_format": "yyyy/mm/dd", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "0", "data_code": "dw2", "data_name": "DW（前々回）", "data_type": "decimal", "conv_table": [], "data_class": "体重情報(過去指示)", "field_name": "dw2", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "0", "data_code": "target_weight2", "data_name": "目標体重（前々回）", "data_type": "decimal", "conv_table": [], "data_class": "体重情報(過去指示)", "field_name": "target_weight2", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/04", "can_calc": "0", "data_code": "treat_date2", "data_name": "透析予定日(前々回)", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報(過去指示)", "field_name": "treat_date2", "disp_format": "yyyy/mm/dd", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示：体重情報(過去指示)　@ordNo使用', '2020-03-27 15:00:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (99, 'with current_ord AS (
    select pat_id, treat_date, rst_start_date, ord_no
    from ord_main
    where ord_no = @ordNo
    and is_del = ''0''
    and rst_dialysis_state <>''0''
),
hist_ord_nos as (
  select
    ord_main.ord_no
    ,ord_main.rst_start_date
  from
    ord_main INNER JOIN current_ord ON ord_main.pat_id = current_ord.pat_id
  where    rst_dialysis_state > ''4''
    and ord_main.ord_no <> @ordNo
    and (((current_ord.rst_start_date is not null) and (ord_main.rst_start_date <= current_ord.rst_start_date))
        or
         ((current_ord.rst_start_date is null) and (ord_main.rst_start_date is not null) and (ord_main.treat_date <= current_ord.treat_date)))
    and is_del = ''0''
  order by rst_start_date desc limit 2
)
, ord_hist_tbl as (
  select rst_start_date
    ,to_number(rst_weight_info->>''weight_before'', ''999.99'') as weight_before
    ,(rst_weight_info->>''weight_before_date'')::timestamp as weight_before_date
    ,to_number(rst_weight_info->>''weight_after'', ''999.99'') as weight_after
    ,(rst_weight_info->>''weight_after_date'')::timestamp as weight_after_date
    ,to_number(rst_weight_info->>''water_removal_rst'', ''999.99'') as water_removal_rst
  from
    ord_main
  where
    ord_no in (select ord_no from hist_ord_nos)
  and is_del = ''0''
  and rst_dialysis_state <>''0''
), ord_array_tbl as (
  select
    array_agg(weight_before order by rst_start_date desc) as array_weight_before
    ,array_agg(weight_before_date order by rst_start_date desc) as array_weight_before_date
    ,array_agg(weight_after order by rst_start_date desc) as array_weight_after
    ,array_agg(weight_after_date order by rst_start_date desc) as array_weight_after_date
    ,array_agg(water_removal_rst order by rst_start_date desc) as array_water_removal_rst
    ,@ordNo as ord_no_t
  from
    ord_hist_tbl
)
select ord_no,array_water_removal_rst[1] as water_removal_rst_prev
  ,array_weight_before[2] as weight_before_prev_prev
  ,array_weight_before_date[2] as weight_before_date_prev_prev
  ,array_weight_after[2] as weight_after_prev_prev
  ,array_weight_after_date[2] as weight_after_date_prev_prev
  ,array_water_removal_rst[2] as water_removal_rst_prev_prev
  ,treat_date
from
  ord_array_tbl
left join current_ord on ord_array_tbl.ord_no_t = current_ord.ord_no
;', 2, '[{"preview": "2.00", "can_calc": "1", "data_code": "water_removal_rst_prev", "data_name": "実績除水量(前回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "water_removal_rst_prev", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "58.20", "can_calc": "1", "data_code": "weight_before_prev_prev", "data_name": "前体重(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "weight_before_prev_prev", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/08", "can_calc": "0", "data_code": "weight_before_date_prev_prev", "data_name": "前体重測定日時(前々回)", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "weight_before_date_prev_prev", "disp_format": "yyyy/mm/dd", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.30", "can_calc": "1", "data_code": "weight_after_prev_prev", "data_name": "後体重(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "weight_after_prev_prev", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/08", "can_calc": "0", "data_code": "weight_after_date_prev_prev", "data_name": "後体重測定日時(前々回)", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "weight_after_date_prev_prev", "disp_format": "yyyy/mm/dd", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.10", "can_calc": "1", "data_code": "water_removal_rst_prev_prev", "data_name": "実績除水量(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "water_removal_rst_prev_prev", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：体重情報(過去実績) @ordNo 使用', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (104, 'WITH DATA AS (


	with hist_ord_nos as (
  select
    ord_main.ord_no
    ,ord_main.rst_start_date
    ,(select treat_date from ord_main where ord_no = @ordNo AND is_del = ''0'' and rst_dialysis_state > ''4'')
  from
    ord_main
  where
    ord_main.pat_id = (select pat_id from ord_main where ord_no = @ordNo and is_del = ''0'' and rst_dialysis_state<>''0'')
    and rst_dialysis_state > ''4''
    and ord_main.ord_no <> @ordNo
    and rst_start_date <= (select rst_start_date from ord_main where ord_no = @ordNo and is_del = ''0'' and rst_dialysis_state<>''0'')
    and is_del = ''0''
  order by rst_start_date desc limit 2
)
, ord_hist_mae as (
  select
    ord_main.ord_no
    ,rst_start_date
    ,occur_date as before_vital_measure_date
    ,to_number(monitor_data->>''90'', ''999'') as before_bp_high
    ,to_number(monitor_data->>''91'', ''999'') as before_bp_low
    ,to_number(monitor_data->>''92'', ''999'') as before_bp_ave
    ,to_number(monitor_data->>''93'', ''999'') as before_pulse
  from
    ord_main
    left outer join (select * from mni_monitor where is_del = ''0'') as mni_monitor
      on ord_main.ord_no = mni_monitor.ord_no and mni_monitor.data_type = 5
  where
    ord_main.ord_no in (select ord_no from hist_ord_nos) and ord_main.is_del = ''0''
), ord_hist_ato as (
  select
    ord_main.ord_no
    ,rst_start_date
    ,occur_date  as after_vital_measure_date
    ,to_number(monitor_data->>''90'', ''999'') as after_bp_high
    ,to_number(monitor_data->>''91'', ''999'') as after_bp_low
    ,to_number(monitor_data->>''92'', ''999'') as after_bp_ave
    ,to_number(monitor_data->>''93'', ''999'') as after_pulse
  from
    ord_main
    left outer join (select * from mni_monitor where is_del = ''0'') as mni_monitor
      on ord_main.ord_no = mni_monitor.ord_no and mni_monitor.data_type = 6
  where
    ord_main.ord_no in (select ord_no from hist_ord_nos) and ord_main.is_del = ''0''
), ord_array_tbl as (
  select
    array_agg(ord_hist_mae.ord_no order by ord_hist_mae.rst_start_date desc) as array_ord_no
    ,array_agg(ord_hist_mae.rst_start_date order by ord_hist_mae.rst_start_date desc) as array_rst_start_date

    ,array_agg(before_vital_measure_date order by ord_hist_mae.rst_start_date desc) as array_before_vital_measure_date
    ,array_agg(before_bp_high order by ord_hist_mae.rst_start_date desc) as array_before_bp_high
    ,array_agg(before_bp_low order by ord_hist_mae.rst_start_date desc) as array_before_bp_low
    ,array_agg(before_bp_ave order by ord_hist_mae.rst_start_date desc) as array_before_bp_ave
    ,array_agg(before_pulse order by ord_hist_mae.rst_start_date desc) as array_before_pulse

    ,array_agg(after_vital_measure_date order by ord_hist_mae.rst_start_date desc) as array_after_vital_measure_date
    ,array_agg(after_bp_high order by ord_hist_mae.rst_start_date desc) as array_after_bp_high
    ,array_agg(after_bp_low order by ord_hist_mae.rst_start_date desc) as array_after_bp_low
    ,array_agg(after_bp_ave order by ord_hist_mae.rst_start_date desc) as array_after_bp_ave
    ,array_agg(after_pulse order by ord_hist_mae.rst_start_date desc) as array_after_pulse
  from
    ord_hist_mae
    inner join ord_hist_ato
      on ord_hist_mae.ord_no = ord_hist_ato.ord_no
)

select
  @ordNo as ord_no_t
  ,treat_date
	,array_ord_no[1] as ord_no_prev
  ,array_ord_no[2] as ord_no_prev_prev
  ,array_rst_start_date[1] as rst_start_date_prev
  ,array_rst_start_date[2] as rst_start_date_prev_prev

  ,array_before_vital_measure_date[1] as before_vital_measure_date_prev
  ,array_before_vital_measure_date[2] as before_vital_measure_date_prev_prev
  ,array_before_bp_high[1] as before_bp_high_prev
  ,array_before_bp_high[2] as before_bp_high_prev_prev
  ,array_before_bp_low[1] as before_bp_low_prev
  ,array_before_bp_low[2] as before_bp_low_prev_prev
  ,array_before_bp_ave[1] as before_bp_ave_prev
  ,array_before_bp_ave[2] as before_bp_ave_prev_prev
  ,array_before_pulse[1] as before_pulse_prev
  ,array_before_pulse[2] as before_pulse_prev_prev

  ,array_after_vital_measure_date[1] as after_vital_measure_date_prev
  ,array_after_vital_measure_date[2] as after_vital_measure_date_prev_prev
  ,array_after_bp_high[1] as after_bp_high_prev
  ,array_after_bp_high[2] as after_bp_high_prev_prev
  ,array_after_bp_low[1] as after_bp_low_prev
  ,array_after_bp_low[2] as after_bp_low_prev_prev
  ,array_after_bp_ave[1] as after_bp_ave_prev
  ,array_after_bp_ave[2] as after_bp_ave_prev_prev
  ,array_after_pulse[1] as after_pulse_prev
  ,array_after_pulse[2] as after_pulse_prev_prev

  ,array_before_bp_high[1]::text || ''/'' || array_before_bp_low[1]::text || ''/'' || array_before_bp_ave[1] || ''('' || array_before_pulse[1]::text || '')'' as before_bp_summary_prev
  ,array_before_bp_high[2]::text || ''/'' || array_before_bp_low[2]::text || ''/'' || array_before_bp_ave[2] || ''('' || array_before_pulse[2]::text || '')'' as before_bp_summary_prev_prev

  ,array_after_bp_high[1]::text || ''/'' || array_after_bp_low[1]::text || ''/'' || array_after_bp_ave[1] || ''('' || array_after_pulse[1]::text || '')'' as after_bp_summary_prev
  ,array_after_bp_high[2]::text || ''/'' || array_after_bp_low[2]::text || ''/'' || array_after_bp_ave[2] || ''('' || array_after_pulse[2]::text || '')'' as after_bp_summary_prev_prev
from
  ord_array_tbl,hist_ord_nos
LIMIT 1


	),
time_info AS (
	WITH b as (
		select 
			ord_no,
			rst_start_date,
			rst_end_date,
			rst_dialysis_state  
		from ord_main as ord	where  ord.facility_cd = @facilityCd  and ord.ord_no = @ordNo and ord.rst_dialysis_state <> ''0''
	)
	, e AS (
  SELECT DISTINCT ON (ord_no)
       mni_monitor.*,
       TO_NUMBER(mni_monitor.monitor_data::json->>''1'', ''9999'') AS 経過時間,
       TO_NUMBER(mni_monitor.monitor_data::json->>''3'', ''9999'') AS 残り時間_除水完了,
       TO_NUMBER(mni_monitor.monitor_data::json->>''4'', ''9999'') AS 残り時間_透析完了
FROM mni_monitor mni_monitor
WHERE mni_monitor.ord_no = @ordNo and  mni_monitor.facility_cd= @facilityCd and mni_monitor.data_type = 1
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
	from  b 
	left JOIN e on b.ord_no=e.ord_no 
	left JOIN f on b.ord_no=f.ord_no
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
	', 2, '[{"preview": "140", "can_calc": "1", "data_code": "before_bp_high_prev", "data_name": "前血圧（最高）(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_high_prev", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "before_bp_low_prev", "data_name": "前血圧（最低）(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_low_prev", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "before_bp_ave_prev", "data_name": "前血圧（平均）(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_ave_prev", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "before_pulse_prev", "data_name": "前脈拍(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_pulse_prev", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120/80/100(72)", "can_calc": "0", "data_code": "before_bp_summary_prev", "data_name": "前血圧（最高/最低/平均(脈拍)）(前回)", "data_type": "string", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_summary_prev", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:10", "can_calc": "0", "data_code": "before_vital_measure_date_prev", "data_name": "前血圧測定日時(前回)", "data_type": "DateTime", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_vital_measure_date_prev", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "after_bp_high_prev", "data_name": "後血圧（最高）(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_high_prev", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "82", "can_calc": "1", "data_code": "after_bp_low_prev", "data_name": "後血圧（最低）(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_low_prev", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "101", "can_calc": "1", "data_code": "after_bp_ave_prev", "data_name": "後血圧（平均）(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_ave_prev", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "76", "can_calc": "1", "data_code": "after_pulse_prev", "data_name": "後脈拍(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_pulse_prev", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120/80/100(72)", "can_calc": "0", "data_code": "after_bp_summary_prev", "data_name": "後血圧（最高/最低/平均(脈拍)）(前回)", "data_type": "string", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_summary_prev", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:53", "can_calc": "0", "data_code": "after_vital_measure_date_prev", "data_name": "後血圧測定日時(前回)", "data_type": "DateTime", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_vital_measure_date_prev", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "140", "can_calc": "1", "data_code": "before_bp_high_prev_prev", "data_name": "前血圧（最高）(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_high_prev_prev", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "before_bp_low_prev_prev", "data_name": "前血圧（最低）(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_low_prev_prev", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "before_bp_ave_prev_prev", "data_name": "前血圧（平均）(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_ave_prev_prev", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "before_pulse_prev_prev", "data_name": "前脈拍(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_pulse_prev_prev", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120/80/100(72)", "can_calc": "0", "data_code": "before_bp_summary_prev_prev", "data_name": "前血圧（最高/最低/平均(脈拍)）(前々回)", "data_type": "string", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_summary_prev_prev", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:10", "can_calc": "0", "data_code": "before_vital_measure_date_prev_prev", "data_name": "前血圧測定日時(前々回)", "data_type": "DateTime", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_vital_measure_date_prev_prev", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "after_bp_high_prev_prev", "data_name": "後血圧（最高）(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_high_prev_prev", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "82", "can_calc": "1", "data_code": "after_bp_low_prev_prev", "data_name": "後血圧（最低）(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_low_prev_prev", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "101", "can_calc": "1", "data_code": "after_bp_ave_prev_prev", "data_name": "後血圧（平均）(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_ave_prev_prev", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "76", "can_calc": "1", "data_code": "after_pulse_prev_prev", "data_name": "後脈拍(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_pulse_prev_prev", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120/80/100(72)", "can_calc": "0", "data_code": "after_bp_summary_prev_prev", "data_name": "後血圧（最高/最低/平均(脈拍)）(前々回)", "data_type": "string", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_summary_prev_prev", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:53", "can_calc": "0", "data_code": "after_vital_measure_date_prev_prev", "data_name": "後血圧測定日時(前々回)", "data_type": "DateTime", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_vital_measure_date_prev_prev", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：血圧情報(過去実績) @ordNo 使用', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);
