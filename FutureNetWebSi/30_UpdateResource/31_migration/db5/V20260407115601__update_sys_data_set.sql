DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (12, 99, 105);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (12, 'WITH rst_start_data_check AS (
    SELECT CASE WHEN rst_start_date IS NULL THEN up_date ELSE rst_start_date END AS rst_start_date
    FROM ord_main
    WHERE ord_no = @ordNo
    AND is_del = ''0''
    AND rst_dialysis_state > ''0''
),
	b AS (
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
),g as (
select
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
, b.ord_no
from  b left join e on b.ord_no = e.ord_no left join f on b.ord_no = f.ord_no)
select g.rst_start_date,g.rst_end_date,g.ind_end_date_time,g.ind_end_date,
ord.ord_no,
ord.treat_date,
    s.rst_weight_info ->> ''ctr'' as last_ctr
  , s.rst_weight_info ->> ''ctr_weight'' as last_ctr_weight
  , s.rst_weight_info ->> ''weight_before'' as last_weight_before
  , s.rst_weight_info ->> ''weight_after'' as last_weight_after
  , s.rst_weight_info ->> ''weight_decreased'' as last_weight_decreased
  , substr(to_char(cast( s.rst_weight_info ->> ''ctr_measure_date''  as TIMESTAMP),''YYYY/MM/DD hh24:mi:ss''),0,17)  as last_ctr_measure_date
  , substr(to_char(cast( s.rst_weight_info ->> ''weight_after_date''  as TIMESTAMP),''YYYY/MM/DD hh24:mi:ss''),0,17)  as last_weight_after_date
  , substr(to_char(cast( s.rst_weight_info ->> ''weight_before_date''  as TIMESTAMP),''YYYY/MM/DD hh24:mi:ss''),0,17)  as last_weight_before_date
  , (s.rst_puncture_user_info ->> ''user_last_name_1'') || (s.rst_puncture_user_info ->> ''user_first_name_1'') as last_puncture_user_name
from
  ord_main as ord   LEFT OUTER JOIN ord_main s ON (
    ord.ord_no <> s.ord_no
    AND ord.pat_id = s.pat_id
    AND ord.facility_cd = s.facility_cd
    AND (SELECT rst_start_date FROM rst_start_data_check) > s.rst_start_date
    AND s.is_del = ''0''
  )
	left join g
	on ord.ord_no=g.ord_no
WHERE
  ord.ord_no = @ordNo
AND
  ord.is_del = ''0''
AND ord.rst_dialysis_state > ''0''
ORDER BY
  s.rst_start_date DESC
LIMIT
 1', 2, '[{"preview": "56.78", "can_calc": "1", "data_code": "last_weight_before", "data_name": "前体重(前回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報(過去実績)", "field_name": "last_weight_before", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/3/12 8:21", "can_calc": "0", "data_code": "last_weight_before_date", "data_name": "前体重測定日時(前回)", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報(過去実績)", "field_name": "last_weight_before_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "56.78", "can_calc": "1", "data_code": "last_weight_after", "data_name": "後体重(前回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報(過去実績)", "field_name": "last_weight_after", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/3/12 8:21", "can_calc": "0", "data_code": "last_weight_after_date", "data_name": "後体重測定日時(前回)", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報(過去実績)", "field_name": "last_weight_after_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "last_ctr", "data_name": "CTR(前回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報(過去実績)", "field_name": "last_ctr", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/3/12", "can_calc": "0", "data_code": "last_ctr_measure_date", "data_name": "CTR測定日時(前回)", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報(過去実績)", "field_name": "last_ctr_measure_date", "disp_format": "yyyy/mm/dd", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "56.78", "can_calc": "1", "data_code": "last_ctr_weight", "data_name": "CTR測定時体重(前回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報(過去実績)", "field_name": "last_ctr_weight", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：体重情報(過去実績)(前回) @ordNo 使用', '2021-10-06 09:47:33', CURRENT_TIMESTAMP, NULL);
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
;', 2, '[{"preview": "2.00", "can_calc": "1", "data_code": "water_removal_rst_prev", "data_name": "実績除水量(前回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報(過去実績)", "field_name": "water_removal_rst_prev", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "58.20", "can_calc": "1", "data_code": "weight_before_prev_prev", "data_name": "前体重(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報(過去実績)", "field_name": "weight_before_prev_prev", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/08 10:10", "can_calc": "0", "data_code": "weight_before_date_prev_prev", "data_name": "前体重測定日時(前々回)", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報(過去実績)", "field_name": "weight_before_date_prev_prev", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.30", "can_calc": "1", "data_code": "weight_after_prev_prev", "data_name": "後体重(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報(過去実績)", "field_name": "weight_after_prev_prev", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/08 10:10", "can_calc": "0", "data_code": "weight_after_date_prev_prev", "data_name": "後体重測定日時(前々回)", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報(過去実績)", "field_name": "weight_after_date_prev_prev", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.10", "can_calc": "1", "data_code": "water_removal_rst_prev_prev", "data_name": "実績除水量(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報(過去実績)", "field_name": "water_removal_rst_prev_prev", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：体重情報(過去実績)(前々回) @ordNo 使用', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (105, 'with tmp as
(
  select
  rst_tare_info->''before''->>''name_1'' as before_tare_name_1
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
  ,round(CAST(rst_tare_info->''before''->>''wheel_chair_weight'' AS DECIMAL) / 1000.0, 2) as before_wheel_chair_weight

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
  ,round(CAST(rst_tare_info->''after''->>''wheel_chair_weight'' AS DECIMAL) / 1000.0, 2) as after_wheel_chair_weight

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
  ,treat_date
from
  ord_main
where
  ord_no = @ordNo and is_del = ''0''
  and rst_dialysis_state <> ''0''
)

select
  *
  ,coalesce(before_tare_weight_1, 0) + coalesce(before_tare_weight_2, 0)
    + coalesce(before_tare_weight_3, 0) + coalesce(before_tare_weight_4, 0)
    + coalesce(before_tare_weight_5, 0) as before_tare_total
  ,coalesce(after_tare_weight_1, 0) + coalesce(after_tare_weight_2, 0)
    + coalesce(after_tare_weight_3, 0) + coalesce(after_tare_weight_4, 0)
    + coalesce(after_tare_weight_5, 0) as after_tare_total
  ,coalesce(off_water_weight_1, 0) + coalesce(off_water_weight_2, 0)
    + coalesce(off_water_weight_3, 0) + coalesce(off_water_weight_4, 0)
    + coalesce(off_water_weight_5, 0) as off_water_total
from
  tmp
	', 2, '[{"preview": "食事量", "can_calc": "0", "data_code": "before_tare_name_1", "data_name": "風袋名称１(透析前)", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_name_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "before_tare_weight_1", "data_name": "風袋重量１(透析前)", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_weight_1", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "服", "can_calc": "0", "data_code": "before_tare_name_2", "data_name": "風袋名称２(透析前)", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_name_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "before_tare_weight_2", "data_name": "風袋重量２(透析前)", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_weight_2", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "義足", "can_calc": "0", "data_code": "before_tare_name_3", "data_name": "風袋名称３(透析前)", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_name_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1200", "can_calc": "1", "data_code": "before_tare_weight_3", "data_name": "風袋重量３(透析前)", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_weight_3", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋１", "can_calc": "0", "data_code": "before_tare_name_4", "data_name": "風袋名称４(透析前)", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_name_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "before_tare_weight_4", "data_name": "風袋重量４(透析前)", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_weight_4", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋２", "can_calc": "0", "data_code": "before_tare_name_5", "data_name": "風袋名称５(透析前)", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_name_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "before_tare_weight_5", "data_name": "風袋重量５(透析前)", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_weight_5", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "車椅子１", "can_calc": "0", "data_code": "before_wheel_chair_name", "data_name": "車椅子名称(透析前)", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_wheel_chair_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15.00", "can_calc": "1", "data_code": "before_wheel_chair_weight", "data_name": "車椅子重量(透析前)", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_wheel_chair_weight", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "16800", "can_calc": "1", "data_code": "before_tare_total", "data_name": "風袋重量合計(透析前)", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_total", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "食事量", "can_calc": "0", "data_code": "after_tare_name_1", "data_name": "風袋名称１(透析後)", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_name_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "after_tare_weight_1", "data_name": "風袋重量１(透析後)", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_weight_1", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "服", "can_calc": "0", "data_code": "after_tare_name_2", "data_name": "風袋名称２(透析後)", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_name_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "after_tare_weight_2", "data_name": "風袋重量２(透析後)", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_weight_2", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "義足", "can_calc": "0", "data_code": "after_tare_name_3", "data_name": "風袋名称３(透析後)", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_name_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1200", "can_calc": "1", "data_code": "after_tare_weight_3", "data_name": "風袋重量３(透析後)", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_weight_3", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋１", "can_calc": "0", "data_code": "after_tare_name_4", "data_name": "風袋名称４(透析後)", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_name_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "after_tare_weight_4", "data_name": "風袋重量４(透析後)", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_weight_4", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋２", "can_calc": "0", "data_code": "after_tare_name_5", "data_name": "風袋名称５(透析後)", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_name_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "after_tare_weight_5", "data_name": "風袋重量５(透析後)", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_weight_5", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "車椅子１", "can_calc": "0", "data_code": "after_wheel_chair_name", "data_name": "車椅子名称(透析後)", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_wheel_chair_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15.00", "can_calc": "1", "data_code": "after_wheel_chair_weight", "data_name": "車椅子重量(透析後)", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_wheel_chair_weight", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "16800", "can_calc": "1", "data_code": "after_tare_total", "data_name": "風袋重量合計(透析後)", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_total", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "食事量", "can_calc": "0", "data_code": "off_water_name_1", "data_name": "除水補正名称１", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "off_water_weight_1", "data_name": "除水補正重量１", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_1", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "プライミング", "can_calc": "0", "data_code": "off_water_name_2", "data_name": "除水補正名称２", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "off_water_weight_2", "data_name": "除水補正重量２", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_2", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "輸液量", "can_calc": "0", "data_code": "off_water_name_3", "data_name": "除水補正名称３", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "off_water_weight_3", "data_name": "除水補正重量３", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_3", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他(不感蒸泄)", "can_calc": "0", "data_code": "off_water_name_4", "data_name": "除水補正名称４", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "off_water_weight_4", "data_name": "除水補正重量４", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_4", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他", "can_calc": "0", "data_code": "off_water_name_5", "data_name": "除水補正名称５", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "off_water_weight_5", "data_name": "除水補正重量５", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_5", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "900", "can_calc": "1", "data_code": "off_water_total", "data_name": "除水補正重量合計", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_total", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：除水情報/風袋・除水補正 @ordNo 使用', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);
