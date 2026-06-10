DELETE FROM sys_data_set WHERE sql_cd = 105;
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (105, 'WITH DATA AS (

	with tmp as
(
  select
  CAST(rst_weight_info->>''water_removal_target'' AS DECIMAL) as water_removal_target
  ,CAST(rst_weight_info->>''water_removal_rst'' AS DECIMAL) as water_removal_rst
  ,CAST(rst_weight_info->>''add_water_total'' AS DECIMAL) as add_water_total

  ,rst_tare_info->''before''->>''name_1'' as before_tare_name_1
  ,rst_tare_info->''before''->>''name_2'' as before_tare_name_2
  ,rst_tare_info->''before''->>''name_3'' as before_tare_name_3
  ,rst_tare_info->''before''->>''name_4'' as before_tare_name_4
  ,rst_tare_info->''before''->>''name_5'' as before_tare_name_5
  ,CAST(rst_tare_info->''before''->>''weight_1'' AS DECIMAL) as before_tare_weight_1
  ,CAST(rst_tare_info->''before''->>''weight_2'' AS DECIMAL) as before_tare_weight_2
  ,CAST(rst_tare_info->''before''->>''weight_3'' AS DECIMAL) as before_tare_weight_3
  ,CAST(rst_tare_info->''before''->>''weight_4'' AS DECIMAL) as before_tare_weight_4
  ,CAST(rst_tare_info->''before''->>''weight_5'' AS DECIMAL) as before_tare_weight_5
  ,rst_tare_info->''before''->>''wheel_chair_name'' as before_wheel_chair_name
  ,CAST(rst_tare_info->''before''->>''wheel_chair_weight'' AS DECIMAL) as before_wheel_chair_weight

  ,rst_tare_info->''after''->>''name_1'' as after_tare_name_1
  ,rst_tare_info->''after''->>''name_2'' as after_tare_name_2
  ,rst_tare_info->''after''->>''name_3'' as after_tare_name_3
  ,rst_tare_info->''after''->>''name_4'' as after_tare_name_4
  ,rst_tare_info->''after''->>''name_5'' as after_tare_name_5
  ,CAST(rst_tare_info->''after''->>''weight_1'' AS DECIMAL) as after_tare_weight_1
  ,CAST(rst_tare_info->''after''->>''weight_2'' AS DECIMAL) as after_tare_weight_2
  ,CAST(rst_tare_info->''after''->>''weight_3'' AS DECIMAL) as after_tare_weight_3
  ,CAST(rst_tare_info->''after''->>''weight_4'' AS DECIMAL) as after_tare_weight_4
  ,CAST(rst_tare_info->''after''->>''weight_5'' AS DECIMAL) as after_tare_weight_5
  ,rst_tare_info->''after''->>''wheel_chair_name'' as after_wheel_chair_name
  ,CAST(rst_tare_info->''after''->>''wheel_chair_weight'' AS DECIMAL) as after_wheel_chair_weight

  ,rst_off_water_info->>''name_1'' as off_water_name_1
  ,rst_off_water_info->>''name_2'' as off_water_name_2
  ,rst_off_water_info->>''name_3'' as off_water_name_3
  ,rst_off_water_info->>''name_4'' as off_water_name_4
  ,rst_off_water_info->>''name_5'' as off_water_name_5
  ,CAST(rst_off_water_info->>''weight_1'' AS DECIMAL) as off_water_weight_1
  ,CAST(rst_off_water_info->>''weight_2'' AS DECIMAL) as off_water_weight_2
  ,CAST(rst_off_water_info->>''weight_3'' AS DECIMAL) as off_water_weight_3
  ,CAST(rst_off_water_info->>''weight_4'' AS DECIMAL) as off_water_weight_4
  ,CAST(rst_off_water_info->>''weight_5'' AS DECIMAL) as off_water_weight_5
	,ord_no
from
  ord_main
where
  ord_no = @ordNo and is_del = ''0''
  and rst_dialysis_state <> ''0''
)

select
  *,
	ord_no as ord_no_t
  ,coalesce(before_tare_weight_1, 0) + coalesce(before_tare_weight_2, 0)
    + coalesce(before_tare_weight_3, 0) + coalesce(before_tare_weight_4, 0)
    + coalesce(before_tare_weight_5, 0) + coalesce(before_wheel_chair_weight, 0) as before_tare_total
  ,coalesce(after_tare_weight_1, 0) + coalesce(after_tare_weight_2, 0)
    + coalesce(after_tare_weight_3, 0) + coalesce(after_tare_weight_4, 0)
    + coalesce(after_tare_weight_5, 0) + coalesce(after_wheel_chair_weight, 0) as after_tare_total
  ,coalesce(off_water_weight_1, 0) + coalesce(off_water_weight_2, 0)
    + coalesce(off_water_weight_3, 0) + coalesce(off_water_weight_4, 0) + coalesce(off_water_weight_5, 0) as off_water_total
from
  tmp



	),
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
	b.ord_no,
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
	DATA.ord_no_t = time_info.ord_no
	;
	', 2, '[{"preview": "55.00", "can_calc": "1", "data_code": "water_removal_target", "data_name": "目標除水量", "data_type": "decimal", "conv_table": [], "data_class": "除水情報", "field_name": "water_removal_target", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.85", "can_calc": "1", "data_code": "water_removal_rst", "data_name": "実績除水量", "data_type": "decimal", "conv_table": [], "data_class": "除水情報", "field_name": "water_removal_rst", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7.70", "can_calc": "1", "data_code": "add_water_total", "data_name": "補液積算値", "data_type": "decimal", "conv_table": [], "data_class": "除水情報", "field_name": "add_water_total", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "食事量", "can_calc": "0", "data_code": "before_tare_name_1", "data_name": "風袋名称１（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_name_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "before_tare_weight_1", "data_name": "風袋重量１（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_weight_1", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "服", "can_calc": "0", "data_code": "before_tare_name_2", "data_name": "風袋名称２（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_name_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "before_tare_weight_2", "data_name": "風袋重量２（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_weight_2", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "義足", "can_calc": "0", "data_code": "before_tare_name_3", "data_name": "風袋名称３（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_name_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1200", "can_calc": "1", "data_code": "before_tare_weight_3", "data_name": "風袋重量３（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_weight_3", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋１", "can_calc": "0", "data_code": "before_tare_name_4", "data_name": "風袋名称４（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_name_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "before_tare_weight_4", "data_name": "風袋重量４（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_weight_4", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋２", "can_calc": "0", "data_code": "before_tare_name_5", "data_name": "風袋名称５（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_name_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "before_tare_weight_5", "data_name": "風袋重量５（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_weight_5", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "車椅子１", "can_calc": "0", "data_code": "before_wheel_chair_name", "data_name": "車椅子名称（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_wheel_chair_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15000", "can_calc": "1", "data_code": "before_wheel_chair_weight", "data_name": "車椅子重量（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_wheel_chair_weight", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "16800", "can_calc": "1", "data_code": "before_tare_total", "data_name": "風袋重量合計（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_total", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "食事量", "can_calc": "0", "data_code": "after_tare_name_1", "data_name": "風袋名称１（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_name_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "after_tare_weight_1", "data_name": "風袋重量１（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_weight_1", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "服", "can_calc": "0", "data_code": "after_tare_name_2", "data_name": "風袋名称２（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_name_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "after_tare_weight_2", "data_name": "風袋重量２（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_weight_2", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "義足", "can_calc": "0", "data_code": "after_tare_name_3", "data_name": "風袋名称３（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_name_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1200", "can_calc": "1", "data_code": "after_tare_weight_3", "data_name": "風袋重量３（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_weight_3", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋１", "can_calc": "0", "data_code": "after_tare_name_4", "data_name": "風袋名称４（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_name_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "after_tare_weight_4", "data_name": "風袋重量４（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_weight_4", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋２", "can_calc": "0", "data_code": "after_tare_name_5", "data_name": "風袋名称５（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_name_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "after_tare_weight_5", "data_name": "風袋重量５（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_weight_5", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "車椅子１", "can_calc": "0", "data_code": "after_wheel_chair_name", "data_name": "車椅子名称（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_wheel_chair_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15000", "can_calc": "1", "data_code": "after_wheel_chair_weight", "data_name": "車椅子重量（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_wheel_chair_weight", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "16800", "can_calc": "1", "data_code": "after_tare_total", "data_name": "風袋重量合計（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_total", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "食事量", "can_calc": "0", "data_code": "off_water_name_1", "data_name": "除水補正名称１", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "off_water_weight_1", "data_name": "除水補正重量１", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_1", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "プライミング", "can_calc": "0", "data_code": "off_water_name_2", "data_name": "除水補正名称２", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "off_water_weight_2", "data_name": "除水補正重量２", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_2", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "輸液量", "can_calc": "0", "data_code": "off_water_name_3", "data_name": "除水補正名称３", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "off_water_weight_3", "data_name": "除水補正重量３", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_3", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他（不感蒸泄）", "can_calc": "0", "data_code": "off_water_name_4", "data_name": "除水補正名称４", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "off_water_weight_4", "data_name": "除水補正重量４", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_4", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他", "can_calc": "0", "data_code": "off_water_name_5", "data_name": "除水補正名称５", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "off_water_weight_5", "data_name": "除水補正重量５", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_5", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "900", "can_calc": "1", "data_code": "off_water_total", "data_name": "除水補正重量合計", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_total", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：除水情報/風袋・除水補正 @ordNo 使用', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);
