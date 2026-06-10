DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 237);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (161, 'SELECT
	rst_treatment_name,
	rst_kur_name,
	rst_bed_name,
	rst_dw,
COALESCE (
NULLIF(
CASE
WHEN treat_week = ''1'' THEN(SELECT mst_user_authentication FROM mst_kur WHERE kur_cd = rst_kur_cd) ->''data''->0->''Mon''->>''user_id''
WHEN treat_week = ''2'' THEN(SELECT mst_user_authentication FROM mst_kur WHERE kur_cd = rst_kur_cd) ->''data''->0->''Tues''->>''user_id''
WHEN treat_week = ''3'' THEN(SELECT mst_user_authentication FROM mst_kur WHERE kur_cd = rst_kur_cd) ->''data''->0->''Wednes''->>''user_id''
WHEN treat_week = ''4'' THEN(SELECT mst_user_authentication FROM mst_kur WHERE kur_cd = rst_kur_cd) ->''data''->0->''Thurs''->>''user_id''
WHEN treat_week = ''5'' THEN(SELECT mst_user_authentication FROM mst_kur WHERE kur_cd = rst_kur_cd) ->''data''->0->''Fri''->>''user_id''
WHEN treat_week = ''6'' THEN(SELECT mst_user_authentication FROM mst_kur WHERE kur_cd = rst_kur_cd) ->''data''->0->''Satur''->>''user_id''
WHEN treat_week = ''7'' THEN(SELECT mst_user_authentication FROM mst_kur WHERE kur_cd = rst_kur_cd) ->''data''->0->''Sun''->>''user_id''
END,''''), 
NULLIF(((SELECT mst_user_authentication FROM mst_kur WHERE kur_cd = rst_kur_cd) ->''data''->0->''All''->>''user_id''),''''),
NULLIF((SELECT "value" FROM mst_facility_setting  WHERE facility_cd = @facilityCd AND facility_setting_no = ''1025''),''0''),'''')
AS full_time_doctor,
	case 	
		when date_trunc(''day'', mst.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mst.in_hosp_b_startdate) then mst.in_hospital_cd_a1 	
		when date_trunc(''day'', mst.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mst.in_hosp_a_startdate) then mst.in_hospital_cd_b1 	
		when date_trunc(''day'', mst.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mst.in_hosp_b_startdate) is null then mst.in_hospital_cd_a1	
		when date_trunc(''day'', mst.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mst.in_hosp_a_startdate) is null then mst.in_hospital_cd_b1
		when date_trunc(''day'', mst.in_hosp_b_startdate) < date_trunc(''day'', mst.in_hosp_a_startdate) and date_trunc(''day'', mst.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then mst.in_hospital_cd_a1
		when date_trunc(''day'', mst.in_hosp_a_startdate) < date_trunc(''day'', mst.in_hosp_b_startdate) and date_trunc(''day'', mst.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then mst.in_hospital_cd_b1	
		when ord.treat_date :: TIMESTAMP = date_trunc(''day'', mst.in_hosp_a_startdate) and ord.treat_date :: TIMESTAMP = date_trunc(''day'', mst.in_hosp_b_startdate) then mst.in_hospital_cd_a1
		else ''''
	end as rst_trea_in_hospital_cd_1,	
	case 	
		when date_trunc(''day'', mst.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mst.in_hosp_b_startdate) then mst.in_hospital_cd_a2	
		when date_trunc(''day'', mst.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mst.in_hosp_a_startdate) then mst.in_hospital_cd_b2 	
		when date_trunc(''day'', mst.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mst.in_hosp_b_startdate) is null then mst.in_hospital_cd_a2	
		when date_trunc(''day'', mst.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mst.in_hosp_a_startdate) is null then mst.in_hospital_cd_b2
		when date_trunc(''day'', mst.in_hosp_b_startdate) < date_trunc(''day'', mst.in_hosp_a_startdate) and date_trunc(''day'', mst.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then mst.in_hospital_cd_a2
		when date_trunc(''day'', mst.in_hosp_a_startdate) < date_trunc(''day'', mst.in_hosp_b_startdate) and date_trunc(''day'', mst.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then mst.in_hospital_cd_b2	
		when ord.treat_date :: TIMESTAMP = date_trunc(''day'', mst.in_hosp_a_startdate) and ord.treat_date :: TIMESTAMP = date_trunc(''day'', mst.in_hosp_b_startdate) then mst.in_hospital_cd_a2
		else ''''
	end as rst_trea_in_hospital_cd_2,	
	case 	
		when date_trunc(''day'', mst.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mst.in_hosp_b_startdate) then mst.in_hospital_cd_a3 	
		when date_trunc(''day'', mst.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mst.in_hosp_a_startdate) then mst.in_hospital_cd_b3 	
		when date_trunc(''day'', mst.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mst.in_hosp_b_startdate) is null then mst.in_hospital_cd_a3	
		when date_trunc(''day'', mst.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mst.in_hosp_a_startdate) is null then mst.in_hospital_cd_b3
		when date_trunc(''day'', mst.in_hosp_b_startdate) < date_trunc(''day'', mst.in_hosp_a_startdate) and date_trunc(''day'', mst.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then mst.in_hospital_cd_a3
		when date_trunc(''day'', mst.in_hosp_a_startdate) < date_trunc(''day'', mst.in_hosp_b_startdate) and date_trunc(''day'', mst.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then mst.in_hospital_cd_b3
		when ord.treat_date :: TIMESTAMP = date_trunc(''day'', mst.in_hosp_a_startdate) and ord.treat_date :: TIMESTAMP = date_trunc(''day'', mst.in_hosp_b_startdate) then mst.in_hospital_cd_a3
		else ''''
	end as rst_trea_in_hospital_cd_3,	
	case 	
		when date_trunc(''day'', mst.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mst.in_hosp_b_startdate) then mst.in_hospital_cd_a4 	
		when date_trunc(''day'', mst.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mst.in_hosp_a_startdate) then mst.in_hospital_cd_b4 	
		when date_trunc(''day'', mst.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mst.in_hosp_b_startdate) is null then mst.in_hospital_cd_a4	
		when date_trunc(''day'', mst.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mst.in_hosp_a_startdate) is null then mst.in_hospital_cd_b4
		when date_trunc(''day'', mst.in_hosp_b_startdate) < date_trunc(''day'', mst.in_hosp_a_startdate) and date_trunc(''day'', mst.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then mst.in_hospital_cd_a4
		when date_trunc(''day'', mst.in_hosp_a_startdate) < date_trunc(''day'', mst.in_hosp_b_startdate) and date_trunc(''day'', mst.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then mst.in_hospital_cd_b4	
		when ord.treat_date :: TIMESTAMP = date_trunc(''day'', mst.in_hosp_a_startdate) and ord.treat_date :: TIMESTAMP = date_trunc(''day'', mst.in_hosp_b_startdate) then mst.in_hospital_cd_a4
		else ''''
	end as rst_trea_in_hospital_cd_4,	
	msk.in_hospital_cd_1 AS rst_kur_in_hospital_cd_1,
	msb.in_hospital_cd_1 AS rst_bed_in_hospital_cd_1,
	msb.in_hospital_cd_2 AS rst_bed_in_hospital_cd_2,
	ord.ord_no,
	ord.treat_date 
FROM
	ord_main ord
	LEFT JOIN mst_treatment mst ON ( ord.rst_treatment_cd = mst.treatment_cd AND mst.is_del = ''0'' AND mst.is_disp = ''1'' )
	LEFT JOIN mst_kur msk ON ( ord.rst_kur_cd = msk.kur_cd AND msk.is_del = ''0'' )
	LEFT JOIN mst_bed msb ON ( ord.rst_bed_cd = msb.bed_cd AND msb.is_disp = ''1'' AND msb.is_del = ''0'' ) 
WHERE
	ord.pat_id = @patId 
	AND ord.ord_no = @ordNo 
	AND ord.is_del = ''0'' 
  AND ord.rst_dialysis_state > ''0'' 
	AND ord.rst_dialysis_state < ''6'';', 2, '[{"preview": "テスト治療方法", "can_calc": "0", "data_code": "rst_treatment_name", "data_name": "治療方法名", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_treatment_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "rst_trea_in_hospital_cd_1", "data_name": "治療方法連携コード１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_trea_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "rst_trea_in_hospital_cd_2", "data_name": "治療方法連携コード２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_trea_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "rst_trea_in_hospital_cd_3", "data_name": "治療方法連携コード３", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_trea_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "rst_trea_in_hospital_cd_4", "data_name": "治療方法連携コード４", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_trea_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テストクール", "can_calc": "0", "data_code": "rst_kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_kur_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "rst_kur_in_hospital_cd_1", "data_name": "クール連携コード", "data_type": "decimal", "conv_table": [], "data_class": "実績情報", "field_name": "rst_kur_in_hospital_cd_1", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "常勤医", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "full_time_doctor", "data_name": "常勤医", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "full_time_doctor", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テストベッド", "can_calc": "0", "data_code": "rst_bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_bed_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "rst_bed_in_hospital_cd_1", "data_name": "ベッド連携コード１", "data_type": "decimal", "conv_table": [], "data_class": "実績情報", "field_name": "rst_bed_in_hospital_cd_1", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "rst_bed_in_hospital_cd_2", "data_name": "ベッド連携コード２", "data_type": "decimal", "conv_table": [], "data_class": "実績情報", "field_name": "rst_bed_in_hospital_cd_2", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "1", "data_code": "rst_dw", "data_name": "DW", "data_type": "decimal", "conv_table": [], "data_class": "実績情報", "field_name": "rst_dw", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": []}', '', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (162, 'WITH DATA AS (




with tmp as
(
select
  CAST(rst_weight_info->>''weight_before'' AS DECIMAL) as weight_before
  ,(rst_weight_info->>''weight_before_date'')::timestamp as weight_before_date

  ,CAST(rst_weight_info->>''weight_after'' AS DECIMAL) as weight_after
  ,(rst_weight_info->>''weight_after_date'')::timestamp as weight_after_date

  ,CAST(rst_weight_info->>''ctr'' AS DECIMAL) as ctr
  ,(rst_weight_info->>''ctr_measure_date'')::timestamp as ctr_measure_date
  ,CAST(rst_weight_info->>''ctr_weight'' AS DECIMAL) as ctr_weight

  ,CAST(rst_weight_info->>''kt_v_measure'' AS DECIMAL) as kt_v_measure
  ,CAST(rst_weight_info->>''urr'' AS DECIMAL) as urr
  ,CAST((select monitor_data from mni_monitor where ord_no = @ordNo and bio_moni_ctl_no::text = rst_weight_info->>''re_loop_rate_main'' and is_del = ''0'')->>''38'' AS DECIMAL) as re_loop_rate

  ,to_number((select monitor_data from mni_monitor where ord_no = @ordNo and data_type = 5 and is_del = ''0'')->>''90'', ''999'') as before_bp_high
  ,to_number((select monitor_data from mni_monitor where ord_no = @ordNo and data_type = 5 and is_del = ''0'')->>''91'', ''999'') as before_bp_low
  ,to_number((select monitor_data from mni_monitor where ord_no = @ordNo and data_type = 5 and is_del = ''0'')->>''92'', ''999'') as before_bp_ave
  ,to_number((select monitor_data from mni_monitor where ord_no = @ordNo and data_type = 5 and is_del = ''0'')->>''93'', ''999'') as before_pulse
  ,(select occur_date from mni_monitor where ord_no = @ordNo and data_type = 5 and is_del = ''0'') as before_vital_measure_date

  ,to_number((select monitor_data from mni_monitor where ord_no = @ordNo and data_type = 6 and is_del = ''0'')->>''90'', ''999'') as after_bp_high
  ,to_number((select monitor_data from mni_monitor where ord_no = @ordNo and data_type = 6 and is_del = ''0'')->>''91'', ''999'') as after_bp_low
  ,to_number((select monitor_data from mni_monitor where ord_no = @ordNo and data_type = 6 and is_del = ''0'')->>''92'', ''999'') as after_bp_ave
  ,to_number((select monitor_data from mni_monitor where ord_no = @ordNo and data_type = 6 and is_del = ''0'')->>''93'', ''999'') as after_pulse
  ,(select occur_date from mni_monitor where ord_no = @ordNo and data_type = 6 and is_del = ''0'') as after_vital_measure_date
from
  ord_main
where
  ord_no = @ordNo and is_del = ''0''
 and rst_dialysis_state >''0'' and rst_dialysis_state <''6''
)

select
  @ordNo as ord_no_t,*
  ,before_bp_high::text || ''/'' || before_bp_low::text || ''/'' || before_bp_ave || ''('' || before_pulse::text || '')'' as before_bp_summary
  ,after_bp_high::text || ''/'' || after_bp_low::text || ''/'' || after_bp_ave || ''('' || after_pulse::text || '')'' as after_bp_summary
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
	b.ord_no as ordnob,
	b.treat_date as treat_date,
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
	', 2, '[{"preview": "57.90", "can_calc": "1", "data_code": "weight_before", "data_name": "前体重", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "weight_before", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:01", "can_calc": "0", "data_code": "weight_before_date", "data_name": "前体重測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報", "field_name": "weight_before_date", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.05", "can_calc": "1", "data_code": "weight_after", "data_name": "後体重", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "weight_after", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13:02", "can_calc": "0", "data_code": "weight_after_date", "data_name": "後体重測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報", "field_name": "weight_after_date", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "34.12", "can_calc": "1", "data_code": "ctr", "data_name": "CTR", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "ctr", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "ctr_measure_date", "data_name": "CTR測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報", "field_name": "ctr_measure_date", "disp_format": "yyyy/mm/dd", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.05", "can_calc": "1", "data_code": "ctr_weight", "data_name": "CTR測定時体重", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "ctr_weight", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.51", "can_calc": "1", "data_code": "kt_v_measure", "data_name": "Kt/V測定値(DDM)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "kt_v_measure", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "35.5", "can_calc": "1", "data_code": "urr", "data_name": "URR", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "urr", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "25", "can_calc": "1", "data_code": "re_loop_rate", "data_name": "再循環率", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "re_loop_rate", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "140", "can_calc": "1", "data_code": "before_bp_high", "data_name": "前血圧（最高）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "before_bp_high", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "before_bp_low", "data_name": "前血圧（最低）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "before_bp_low", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "before_bp_ave", "data_name": "前血圧（平均）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "before_bp_ave", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "before_pulse", "data_name": "前脈拍", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "before_pulse", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120/80/100(72)", "can_calc": "0", "data_code": "before_bp_summary", "data_name": "前血圧（最高/最低/平均(脈拍)）", "data_type": "string", "conv_table": [], "data_class": "血圧情報", "field_name": "before_bp_summary", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:10", "can_calc": "0", "data_code": "before_vital_measure_date", "data_name": "前血圧測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "血圧情報", "field_name": "before_vital_measure_date", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "after_bp_high", "data_name": "後血圧（最高）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "after_bp_high", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "82", "can_calc": "1", "data_code": "after_bp_low", "data_name": "後血圧（最低）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "after_bp_low", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "101", "can_calc": "1", "data_code": "after_bp_ave", "data_name": "後血圧（平均）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "after_bp_ave", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "76", "can_calc": "1", "data_code": "after_pulse", "data_name": "後脈拍", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "after_pulse", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120/80/100(72)", "can_calc": "0", "data_code": "after_bp_summary", "data_name": "後血圧（最高/最低/平均(脈拍)）", "data_type": "string", "conv_table": [], "data_class": "血圧情報", "field_name": "after_bp_summary", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:53", "can_calc": "0", "data_code": "after_vital_measure_date", "data_name": "後血圧測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "血圧情報", "field_name": "after_vital_measure_date", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": []}', '実績（治療中）：体重情報/血圧情報 @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (163, 'WITH DATA AS (

with mstcp_tbl as (
select
    comp_treatment_cd
    ,case treat_class when ''0'' then mstMedicMix.in_hospital_cd_1 else mstMedic.in_hospital_cd_1 end as treatMdeci_in_hospital_cd_1
    ,case treat_class when ''0'' then mstMedicMix.in_hospital_cd_2 else mstMedic.in_hospital_cd_2 end as treatMdeci_in_hospital_cd_2
    ,case treat_class when ''0'' then mstMedicMix.in_hospital_cd_3 else mstMedic.in_hospital_cd_3 end as treatMdeci_in_hospital_cd_3
    ,case treat_class when ''0'' then '''' else mstMedic.in_hospital_cd_4 end as treatMdeci_in_hospital_cd_4
		,case 
			 when mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < mstCpt.in_hosp_b_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_a1
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < mstCpt.in_hosp_a_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_b1
		   when mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and mstCpt.in_hosp_b_startdate :: TIMESTAMP is null then mstCpt.in_hospital_cd_a1
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and mstCpt.in_hosp_a_startdate :: TIMESTAMP is null then mstCpt.in_hospital_cd_b1
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP < mstCpt.in_hosp_a_startdate :: TIMESTAMP and mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP then mstCpt.in_hospital_cd_a1
		   when mstCpt.in_hosp_a_startdate :: TIMESTAMP < mstCpt.in_hosp_b_startdate :: TIMESTAMP and mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP then mstCpt.in_hospital_cd_b1
		   when ord.treat_date :: TIMESTAMP = mstCpt.in_hosp_a_startdate :: TIMESTAMP and ord.treat_date :: TIMESTAMP = mstCpt.in_hosp_b_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_a1
			 else ''''
		 end as comptreat_in_hospital_cd_1
 		,case 
			 when mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < mstCpt.in_hosp_b_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_a2
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < mstCpt.in_hosp_a_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_b2
		   when mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and mstCpt.in_hosp_b_startdate :: TIMESTAMP is null then mstCpt.in_hospital_cd_a2
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and mstCpt.in_hosp_a_startdate :: TIMESTAMP is null then mstCpt.in_hospital_cd_b2
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP < mstCpt.in_hosp_a_startdate :: TIMESTAMP and mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP then mstCpt.in_hospital_cd_a2
		   when mstCpt.in_hosp_a_startdate :: TIMESTAMP < mstCpt.in_hosp_b_startdate :: TIMESTAMP and mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP then mstCpt.in_hospital_cd_b2
		   when ord.treat_date :: TIMESTAMP = mstCpt.in_hosp_a_startdate :: TIMESTAMP and ord.treat_date :: TIMESTAMP = mstCpt.in_hosp_b_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_a2
			 else ''''
		 end as comptreat_in_hospital_cd_2
  	,case 
			 when mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < mstCpt.in_hosp_b_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_a3
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < mstCpt.in_hosp_a_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_b3
		   when mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and mstCpt.in_hosp_b_startdate :: TIMESTAMP is null then mstCpt.in_hospital_cd_a3
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and mstCpt.in_hosp_a_startdate :: TIMESTAMP is null then mstCpt.in_hospital_cd_b3
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP < mstCpt.in_hosp_a_startdate :: TIMESTAMP and mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP then mstCpt.in_hospital_cd_a3
		   when mstCpt.in_hosp_a_startdate :: TIMESTAMP < mstCpt.in_hosp_b_startdate :: TIMESTAMP and mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP then mstCpt.in_hospital_cd_b3
		   when ord.treat_date :: TIMESTAMP = mstCpt.in_hosp_a_startdate :: TIMESTAMP and ord.treat_date :: TIMESTAMP = mstCpt.in_hosp_b_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_a3
			 else ''''
		 end as comptreat_in_hospital_cd_3
   	,case 
			 when mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < mstCpt.in_hosp_b_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_a4
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < mstCpt.in_hosp_a_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_b4
		   when mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and mstCpt.in_hosp_b_startdate :: TIMESTAMP is null then mstCpt.in_hospital_cd_a4
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and mstCpt.in_hosp_a_startdate :: TIMESTAMP is null then mstCpt.in_hospital_cd_b4
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP < mstCpt.in_hosp_a_startdate :: TIMESTAMP and mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP then mstCpt.in_hospital_cd_a4
		   when mstCpt.in_hosp_a_startdate :: TIMESTAMP < mstCpt.in_hosp_b_startdate :: TIMESTAMP and mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP then mstCpt.in_hospital_cd_b4
		   when ord.treat_date :: TIMESTAMP = mstCpt.in_hosp_a_startdate :: TIMESTAMP and ord.treat_date :: TIMESTAMP = mstCpt.in_hosp_b_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_a4
			 else ''''
		 end as comptreat_in_hospital_cd_4
    from ord_main as ord		
		cross join lateral
      json_array_elements (ord.rst_treatment_info::json) info		
    inner join mst_comp_treatment as mstCpt on (info ->> ''treat_cd'' = mstCpt.comp_treatment_cd :: TEXT and ord.is_del = ''0'')
    left join mst_medicine_mix  as mstMedicMix  on (mstCpt.treat_medicine_cd = mstMedicMix.medicine_mix_cd      and mstMedicMix.is_del = ''0'' and mstMedicMix.is_disp = ''1'')
    left join mst_medicine as  mstMedic  on (mstCpt.treat_medicine_cd = mstMedic.medicine_cd      and mstMedic.is_del = ''0'' and mstMedic.is_disp = ''1'')
    where
     mstCpt.is_del = ''0''
     and mstCpt.is_disp = ''1''
		 and mstCpt.facility_cd = @facilityCd
		 and ord.ord_no = @ordNo
		 
		 
--     from mst_comp_treatment mstCpt
--     left join mst_medicine_mix  as mstMedicMix  on (mstCpt.treat_medicine_cd = mstMedicMix.medicine_mix_cd      and mstMedicMix.is_del = ''0'' and mstMedicMix.is_disp = ''1'')
--     left join mst_medicine as  mstMedic  on (mstCpt.treat_medicine_cd = mstMedic.medicine_cd      and mstMedic.is_del = ''0'' and mstMedic.is_disp = ''1'')
--     where mstCpt.treat_class != ''2''
--     and mstCpt.is_del = ''0''
--     and mstCpt.is_disp = ''1''
    )
select
	a.ord_no as ord_no_t,
  to_char(to_timestamp(coalesce(a.occur_date, b.occur_date, c.occur_date), ''YYYY-MM-DD"T"HH24:MI:SS"Z"'')::timestamp, ''HH24:MI'') as occur_time,
  a.complaint,
  b.treat_name,
  b.treat_medicine,
  b.treatMdeci_in_hospital_cd_1,
  b.treatMdeci_in_hospital_cd_2,
  b.treatMdeci_in_hospital_cd_3,
  treatMdeci_in_hospital_cd_4,
	b.comptreat_in_hospital_cd_1,
	b.comptreat_in_hospital_cd_2,
	b.comptreat_in_hospital_cd_3,
	b.comptreat_in_hospital_cd_4,
  b.amount,
  b.unit,
  b.procedure_name,
  c.treat_staff_name,
  c.treat_staff_cd
from
  (
select
    ord.ord_no,
    complaint->>''occur_date'' as occur_date,
    complaint->>''complaint'' as complaint,
    complaint->>''row_no'' as row_no
from
    ord_main as ord
    cross join lateral
    json_array_elements (ord.rst_complaint_info::json) complaint
    where ord.is_del = ''0'' and ord.rst_dialysis_state > ''0'' and ord.rst_dialysis_state < ''6''
    and ord.ord_no = @ordNo
    and complaint->>''checkFlag'' = ''1''
order by
    ord_no,
    occur_date) a
full outer join
  (
select
    ord_no as ord_no_t
		,ord.ord_no,
    treatment->>''occur_date'' as occur_date,
    treatment->>''row_no'' as row_no,
case
    when treatment->>''treat_class'' = ''3'' and treatment->>''oxygen_start'' is not null then concat(''酸素吸入開始 '', to_char(cast(treatment->>''oxygen_speed'' as numeric), ''FM999999.00''), ''L/min'')
    when treatment->>''treat_class'' = ''3'' and treatment->>''oxygen_start'' is null then concat(''酸素吸入終了 '' , to_char(cast(treatment->>''oxygen_amount'' as numeric), ''FM999999.00''), ''L'')
    when treatment->>''treat_class'' = ''4'' and treatment->>''electrocardiogram_start'' is not null then ''心電図測定開始''
    when treatment->>''treat_class'' = ''4'' and treatment->>''electrocardiogram_start'' is null then ''心電図測定終了''
    else treatment->>''treat_name'' end
    as treat_name,
    treatment->>''treat_medicine_name'' as treat_medicine,
    treatment->>''amount'' as amount,
    treatment->>''unit'' as unit,
    treatment->>''procedure_name'' as procedure_name,
    mstcp_tbl.treatMdeci_in_hospital_cd_1,
    mstcp_tbl.treatMdeci_in_hospital_cd_2,
    mstcp_tbl.treatMdeci_in_hospital_cd_3,
    mstcp_tbl.treatMdeci_in_hospital_cd_4,
    mstcp_tbl.comptreat_in_hospital_cd_1,
    mstcp_tbl.comptreat_in_hospital_cd_2,
    mstcp_tbl.comptreat_in_hospital_cd_3,
    mstcp_tbl.comptreat_in_hospital_cd_4
from
    ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_treatment_info::json) treatment
      left join mstcp_tbl on (mstcp_tbl.comp_treatment_cd ::text = treatment ->> ''treat_cd'')
    where ord.is_del = ''0'' and ord.rst_dialysis_state > ''0'' and ord.rst_dialysis_state < ''6''
    and ord_no = @ordNo
    and treatment->>''checkFlag'' = ''1''

union all
select
		ord_no as ord_no_t,
    ord_no
    , to_char(event_reg_date, ''YYYY-MM-DD"T"HH24:MI:SS"Z"'') as occur_date
    , ''0'' as row_no
    , machine_record_message as treat_name
    ,'''' as treat_medicine
    ,'''' as amount
    ,'''' as unit
    ,'''' as procedure_name
    ,'''' as treatMdeci_in_hospital_cd_1
    ,'''' as treatMdeci_in_hospital_cd_2
    ,'''' as treatMdeci_in_hospital_cd_3
    ,'''' as treatMdeci_in_hospital_cd_4
		,'''' as comptreat_in_hospital_cd_1
    ,'''' as comptreat_in_hospital_cd_2
    ,'''' as comptreat_in_hospital_cd_3
    ,'''' as comptreat_in_hospital_cd_4
from
    mnt_motion_record as mnt
where
    mnt.ord_no = @ordNo
    and mnt.report_disp_flg = ''1''

order by
    ord_no,
    occur_date,
    row_no) b
  on a.ord_no = b.ord_no and a.occur_date = b.occur_date and a.row_no = b.row_no
full outer join
  (
select
    ord.ord_no,
    treat_staff->>''occur_date'' as occur_date,
    treat_staff->>''row_no'' as row_no,
    treat_staff->>''treat_staff_name'' as treat_staff_name,
    treat_staff->>''treat_staff_cd'' as treat_staff_cd
from
    ord_main as ord
    cross join lateral
    json_array_elements (ord.rst_treat_staff_info::json) treat_staff
    where ord.is_del = ''0''  and ord.rst_dialysis_state > ''0'' and ord.rst_dialysis_state <''6''
    and ord_no = @ordNo
    and treat_staff->>''checkFlag'' = ''1''
order by
    ord_no,
    occur_date,
    row_no) c
  on COALESCE(a.ord_no,b.ord_no) = c.ord_no and COALESCE(a.occur_date,b.occur_date) = c.occur_date and COALESCE(a.row_no, b.row_no) = c.row_no
where
  coalesce(a.ord_no, b.ord_no, c.ord_no) = @ordNo
order by
  coalesce(a.occur_date, b.occur_date, c.occur_date), to_number(coalesce(a.row_no, b.row_no, c.row_no), ''9999999999'')

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
	b.ord_no as ordnob,
	b.treat_date as treat_date,
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
	', 2, '[{"preview": "09:46", "can_calc": "0", "data_code": "occur_time", "data_name": "愁訴処置時刻", "data_type": "DateTime", "conv_table": [], "data_class": "愁訴処置", "field_name": "occur_time", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト愁訴", "can_calc": "0", "data_code": "complaint", "data_name": "愁訴", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "complaint", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト処置", "can_calc": "0", "data_code": "treat_name", "data_name": "処置", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treat_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "comptreat_in_hospital_cd_1", "data_name": "処置連携コード１", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "comptreat_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "comptreat_in_hospital_cd_2", "data_name": "処置連携コード２", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "comptreat_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "comptreat_in_hospital_cd_3", "data_name": "処置連携コード３", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "comptreat_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "comptreat_in_hospital_cd_4", "data_name": "処置連携コード４", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "comptreat_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト処置薬剤", "can_calc": "0", "data_code": "treat_medicine", "data_name": "処置薬剤", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treat_medicine", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treatmdeci_in_hospital_cd_1", "data_name": "処置薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treatmdeci_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treatmdeci_in_hospital_cd_2", "data_name": "処置薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treatmdeci_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treatmdeci_in_hospital_cd_3", "data_name": "処置薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treatmdeci_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treatmdeci_in_hospital_cd_4", "data_name": "処置薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treatmdeci_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "愁訴処置", "field_name": "amount", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "A", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "unit", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treat_staff_cd", "data_name": "処置ID", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treat_staff_cd", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "treat_staff_name", "data_name": "処置者", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treat_staff_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": []}', '実績（治療中）：愁訴処置 @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (164, 'select * from ord_main where ord_no = @ordNo and is_del = ''0'' and rst_dialysis_state >''0'' and rst_dialysis_state <''6''', 2, '[{"preview": "2011/3/12  08:21", "can_calc": "0", "data_code": "rst_start_date", "data_name": "透析開始日時", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_start_date", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/3/12  12:45", "can_calc": "0", "data_code": "rst_end_date", "data_name": "透析終了日時", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_end_date", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": []}', '', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (165, 'WITH DATA AS (

WITH ord AS (
    SELECT
        ord_no,
				treat_date,
        json_idx,
        medi,
        is_del
    FROM
        ord_main
    CROSS JOIN LATERAL jsonb_array_elements (rst_medi_info) WITH ORDINALITY AS tmp (medi, json_idx)
    WHERE
        is_del = ''0''
    AND ord_no = @ordNo
    AND facility_cd = @facilityCd
    AND rst_dialysis_state > ''0'' AND rst_dialysis_state < ''6''
)
select @ordNo as ord_no_t,a.*
 from (
select
  medi ->> ''cd'' as medi_cd,
  medi ->> ''name'' as medi_name,
  medi ->> ''unit'' as medi_unit,
  medi ->> ''amount'' as medi_amount,
  case when  ord.medi->>''medicine_type'' = ''1'' then mstMedic.class_cd else mstMedicMix.class_cd end as medi_class_cd,
  medi ->> ''class_name'' as medi_class_name,
  medi ->> ''class_type'' as medi_class_type,
  medi ->> ''effect_flg'' as effect_flg,
  medi ->> ''short_name'' as short_name,
  CASE WHEN medi ->> ''effect_date'' <> ''null'' THEN
    to_timestamp( substring(medi ->> ''effect_date''::text from 0 for 11) || '' '' || substring(medi ->> ''effect_date''::text from 12 for 12),''YYYY-MM-DD HH24:MI:SS.MS'')
  END as effect_date,
  medi ->> ''effect_user_id'' as effect_user_id,
  medi ->> ''timing_name'' as medi_timing_name,
  medi ->> ''procedure_name'' as procedure_name,
	COALESCE(medi ->> ''effect_user_last_name''::text, '''') || '' '' || COALESCE(medi ->> ''effect_user_first_name''::text, '''') as effect_user_name,
  medi->>''comment'' as comment
  , medi->>''medicine_type'' as medicine_type
  ,case when  ord.medi->>''medicine_type'' = ''1'' then mstMedic.in_hospital_cd_1 else mstMedicMix.in_hospital_cd_1 end as rst_medi_in_hospital_cd_1
  ,case when  ord.medi->>''medicine_type'' = ''1'' then mstMedic.in_hospital_cd_2 else mstMedicMix.in_hospital_cd_2 end as rst_medi_in_hospital_cd_2
  ,case when  ord.medi->>''medicine_type'' = ''1'' then mstMedic.in_hospital_cd_3 else mstMedicMix.in_hospital_cd_3 end as rst_medi_in_hospital_cd_3
  ,case when  ord.medi->>''medicine_type'' = ''1'' then mstMedic.in_hospital_cd_4 else '''' end as rst_medi_in_hospital_cd_4
	,case 
	   when date_trunc(''day'', mstP.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mstP.in_hosp_b_startdate) then mstP.in_hospital_cd_a1
	   when date_trunc(''day'', mstP.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mstP.in_hosp_a_startdate) then mstP.in_hospital_cd_b1
		 when date_trunc(''day'', mstP.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mstP.in_hosp_b_startdate) is null then mstP.in_hospital_cd_a1
		 when date_trunc(''day'', mstP.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mstP.in_hosp_a_startdate) is null then mstP.in_hospital_cd_b1
		 when date_trunc(''day'', mstP.in_hosp_b_startdate) < date_trunc(''day'', mstP.in_hosp_a_startdate) and date_trunc(''day'', mstP.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then mstP.in_hospital_cd_a1
		 when date_trunc(''day'', mstP.in_hosp_a_startdate) < date_trunc(''day'', mstP.in_hosp_b_startdate) and date_trunc(''day'', mstP.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then mstP.in_hospital_cd_b1
		 when (ord.treat_date :: TIMESTAMP) = date_trunc(''day'', mstP.in_hosp_a_startdate) and (ord.treat_date :: TIMESTAMP) = date_trunc(''day'', mstP.in_hosp_b_startdate) then mstP.in_hospital_cd_a1
		 else ''''
	 end as rst_procedure_in_hospital_cd_1
	,case 
	   when date_trunc(''day'', mstP.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mstP.in_hosp_b_startdate) then mstP.in_hospital_cd_a2
	   when date_trunc(''day'', mstP.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mstP.in_hosp_a_startdate) then mstP.in_hospital_cd_b2
		 when date_trunc(''day'', mstP.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mstP.in_hosp_b_startdate) is null then mstP.in_hospital_cd_a2
		 when date_trunc(''day'', mstP.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mstP.in_hosp_a_startdate) is null then mstP.in_hospital_cd_b2
		 when date_trunc(''day'', mstP.in_hosp_b_startdate) < date_trunc(''day'', mstP.in_hosp_a_startdate) and date_trunc(''day'', mstP.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then mstP.in_hospital_cd_a2
		 when date_trunc(''day'', mstP.in_hosp_a_startdate) < date_trunc(''day'', mstP.in_hosp_b_startdate) and date_trunc(''day'', mstP.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then mstP.in_hospital_cd_b2
		 when (ord.treat_date :: TIMESTAMP) = date_trunc(''day'', mstP.in_hosp_a_startdate) and (ord.treat_date :: TIMESTAMP) = date_trunc(''day'', mstP.in_hosp_b_startdate) then mstP.in_hospital_cd_a2
		 else ''''
	 end as rst_procedure_in_hospital_cd_2
  from
    ord
    left join mst_medicine_mix  as mstMedicMix  on (ord.medi ->> ''cd'' = mstMedicMix.medicine_mix_cd :: text and mstMedicMix.is_del = ''0'' and mstMedicMix.is_disp = ''1'' and mstMedicMix.facility_cd = @facilityCd )
    left join mst_medicine as  mstMedic  on (ord.medi ->> ''cd'' = mstMedic.medicine_cd :: text and mstMedic.is_del = ''0'' and mstMedic.is_disp = ''1'' and mstMedic.facility_cd = @facilityCd )
    left join mst_procedure as mstP on (ord.medi ->> ''procedure_cd'' = mstP.procedure_cd :: text and mstP.is_del = ''0'' and mstP.is_disp = ''1''  and mstP.facility_cd = @facilityCd)

  where
    ord.ord_no = @ordNo
  and ord.is_del = ''0'' )  a where a.medi_class_cd in ( @medIds )

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
	b.ord_no as ordnob,
	b.treat_date as treat_date,
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
	', 2, '[{"preview": "テスト薬剤１", "can_calc": "0", "data_code": "medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析液", "can_calc": "0", "data_code": "medi_class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_medi_in_hospital_cd_1", "data_name": "薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_medi_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_medi_in_hospital_cd_2", "data_name": "薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_medi_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_medi_in_hospital_cd_3", "data_name": "薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_medi_in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_medi_in_hospital_cd_4", "data_name": "薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_medi_in_hospital_cd_4", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "medi_amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "medi_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側回路内注射", "can_calc": "0", "data_code": "procedure_name", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "procedure_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_procedure_in_hospital_cd_1", "data_name": "手技連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_procedure_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_procedure_in_hospital_cd_2", "data_name": "手技連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_procedure_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "medi_timing_name", "data_name": "投与時間帯", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_timing_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "予定薬剤です。", "can_calc": "0", "data_code": "comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "comment", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "effect_date", "data_name": "実施時刻", "data_type": "DateTime", "conv_table": [], "data_class": "投薬", "field_name": "effect_date", "disp_format": "yyyy/mm/dd hh:mm", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "effect_user_id", "data_name": "実施者ID", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "effect_user_id", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "data_code": "effect_user_name", "data_name": "実施者名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "effect_user_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "effect_flg", "data_name": "実施マーク", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未使用"}, {"code": "1", "disp": "■", "item": "実施済"}], "data_class": "投薬", "field_name": "effect_flg", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_cd", "data_name": "薬剤コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "medi_cd", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": []}', '実績（治療中）：投薬 @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (166, 'WITH DATA AS (

with ord_tbl as (
  select
    facility_cd,
    pat_id,
    rst_bed_cd,
    to_timestamp(treat_date, ''yyyymmdd'') + ''1 days - 1 milliseconds'' as treat_date_end
  from ord_main
  where ord_no = @ordNo
  and is_del = ''0''
), bed_group_tbl AS (
  select
    facility_cd,
    room_bed_group_name as bed_group_name
  from
    mst_room_bed_group
  where
    mst_room_bed_group.bed_list @> (''['' || (select rst_bed_cd from ord_tbl) || '']'')::jsonb
  and
    mst_room_bed_group.group_class = 1
  and mst_room_bed_group.is_del = ''0''
  and mst_room_bed_group.is_disp = ''1''
  group by
    facility_cd, room_bed_group_cd
    limit 1
), room_tbl AS (
  select
    facility_cd,
    room_bed_group_name as room_name
  from
    mst_room_bed_group
  where
    mst_room_bed_group.bed_list @> (''['' || (select rst_bed_cd from ord_tbl) || '']'')::jsonb
  and
    mst_room_bed_group.group_class = 2
  and mst_room_bed_group.is_del = ''0''
  and mst_room_bed_group.is_disp = ''1''
  group by
    facility_cd, room_bed_group_cd
    limit 1
), pat_physical_tbl AS (
-- 指定患者、基準日以前のDWがある身体情報を取得
  select
    work_tbl.*
  from
    (
    select
      pat_id,
      info->>''exam_date'' as exam_date,
      info->>''dw'' as dw,
      info->>''pre_scale_upper'' as pre_scale_upper,
      info->>''pre_scale_lower'' as pre_scale_lower
    from
      (select * from pat_unique where is_del = ''0'') as pat_unique
      cross join lateral
        json_array_elements (pat_unique.physical_info :: json) info
    where
      pat_unique.pat_id = (select pat_id from ord_tbl)
    ) work_tbl
  where
    exam_date::timestamp <= (select treat_date_end from ord_tbl)
  and
    dw is not null
  order by
    exam_date desc
  limit 1
), pat_wheel_chair_tbl AS (
-- 指定患者の車いす情報を取得
  select
    pat_id,
    wheel_chair_name,
    wheel_chair_weight
  from
    mst_wheel_chair,
    (
      select
        mss.facility_cd, ms.*, row_number() over() as index
      from
        mst_selector mss
      cross join lateral jsonb_to_recordset(mss.order_settings->''items'') as ms
      (
        code bigint,
        name text
      )
      where
        facility_cd = (select facility_cd from ord_tbl)
      and
        master_physical_name = ''mst_wheel_chair''
    ) ms
  where
    mst_wheel_chair.wheel_chair_cd = ms.code
  and
    pat_id = (select pat_id from ord_tbl)
  and
    is_disp = ''1''
  and
    is_del = ''0''
  and
    is_personal = ''1''
  limit 1
)
select
  to_date(ord.treat_date, ''yyyymmdd'') as treat_date,
  ord.rst_kur_cd as kur_cd,
  ord.ord_no as ord_no_t,
  ord.rst_treatment_cd as treatment_cd,
  to_char(ord.rst_start_date, ''HH24:MI'') as treat_start_time,

  to_char(ord.rst_end_date, ''HH24:MI'') as treat_end_time,

  ord.rst_bed_cd as bed_cd,

  ord.rst_cond_info->''1''->>''value'' as treatment_time,
  --ord.rst_cond_info->''2''->>''value_name_1'' as va,
  ord.rst_cond_info->''4''->>''value'' as water_removal_amount_limit,
  ord.rst_cond_info->''12''->>''value'' as single_needle,
  ord.rst_cond_info->''14''->>''value'' as blood_flow,
  ord.rst_cond_info->''16''->>''value'' as dialysate_flow_rate,
  ord.rst_cond_info->''17''->>''value'' as dialysate_amount,
  ord.rst_cond_info->''18''->>''value'' as dialysate_temperature,
  ord.rst_cond_info->''20''->>''value'' as fluid_replacement_amount,
  ord.rst_cond_info->''21''->>''value'' as fluid_replacement_timing,
  ord.rst_cond_info->''22''->>''value'' as fluid_replacement_use_count,
  ord.rst_cond_info->''23''->>''value'' as fluid_replacement_temperature,
  ord.rst_cond_info->''24''->>''value'' as fluid_replacement_speed,
  ord.rst_cond_info->''26''->>''value'' as anti_coagulant_one_shot_amount,
  ord.rst_cond_info->''27''->>''value'' as anti_coagulant_sustained_speed,
  ord.rst_cond_info->''27''->>''unit'' as anti_coagulant_sustained_speed_unit,
  ord.rst_cond_info->''28''->>''value'' as anti_coagulant_sustained_amount,
  ord.rst_cond_info->''29''->>''value'' as ip,
  ord.rst_cond_info->''30''->>''value'' as ip_start,
  ord.rst_cond_info->''31''->>''value'' as ip_one_shot_amount,
  ord.rst_cond_info->''32''->>''value'' as ip_speed,
  ord.rst_cond_info->''33''->>''value'' as ip_speed_max,
  ord.rst_cond_info->''34''->>''value'' as auto_one_shot,
  ord.rst_cond_info->''35''->>''value'' as ip_auto_off,
  ord.rst_cond_info->''36''->>''value'' as ip_auto_off_time,
  ord.rst_cond_info->''37''->>''value'' as ip_monitor_auto_off,
  ord.rst_cond_info->''38''->>''value'' as ip_monitor_auto_off_time,
	
	case 
		when ord.rst_device_mode is null then mst_treatment.device_mode
		else ord.rst_device_mode 
	end as device_mode,
	case 	
		when date_trunc(''day'',mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'',mst_treatment.in_hosp_b_startdate) then mst_treatment.in_hospital_cd_a1 
		when date_trunc(''day'',mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'',mst_treatment.in_hosp_a_startdate) then mst_treatment.in_hospital_cd_b1 
		when date_trunc(''day'',mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'',mst_treatment.in_hosp_b_startdate) is null then mst_treatment.in_hospital_cd_a1
		when date_trunc(''day'',mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'',mst_treatment.in_hosp_a_startdate) is null then mst_treatment.in_hospital_cd_b1
		when date_trunc(''day'',mst_treatment.in_hosp_b_startdate) < date_trunc(''day'',mst_treatment.in_hosp_a_startdate) and date_trunc(''day'',mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then mst_treatment.in_hospital_cd_a1
		when date_trunc(''day'',mst_treatment.in_hosp_a_startdate) < date_trunc(''day'',mst_treatment.in_hosp_b_startdate) and date_trunc(''day'',mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then mst_treatment.in_hospital_cd_b1
		when ord.treat_date :: TIMESTAMP = date_trunc(''day'',mst_treatment.in_hosp_a_startdate) and ord.treat_date :: TIMESTAMP = date_trunc(''day'',mst_treatment.in_hosp_b_startdate) then mst_treatment.in_hospital_cd_a1
		else ''''
	end as treatment_in_hospital_cd_1,	
	case 	
		when date_trunc(''day'',mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'',mst_treatment.in_hosp_b_startdate) then mst_treatment.in_hospital_cd_a2 
		when date_trunc(''day'',mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'',mst_treatment.in_hosp_a_startdate) then mst_treatment.in_hospital_cd_b2 
		when date_trunc(''day'',mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'',mst_treatment.in_hosp_b_startdate) is null then mst_treatment.in_hospital_cd_a2
		when date_trunc(''day'',mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'',mst_treatment.in_hosp_a_startdate) is null then mst_treatment.in_hospital_cd_b2
		when date_trunc(''day'',mst_treatment.in_hosp_b_startdate) < date_trunc(''day'',mst_treatment.in_hosp_a_startdate) and date_trunc(''day'',mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then mst_treatment.in_hospital_cd_a2
		when date_trunc(''day'',mst_treatment.in_hosp_a_startdate) < date_trunc(''day'',mst_treatment.in_hosp_b_startdate) and date_trunc(''day'',mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then mst_treatment.in_hospital_cd_b2
		when ord.treat_date :: TIMESTAMP = date_trunc(''day'',mst_treatment.in_hosp_a_startdate) and ord.treat_date :: TIMESTAMP = date_trunc(''day'',mst_treatment.in_hosp_b_startdate) then mst_treatment.in_hospital_cd_a2
		else ''''
	end as treatment_in_hospital_cd_2,	
	case 	
		when date_trunc(''day'',mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'',mst_treatment.in_hosp_b_startdate) then mst_treatment.in_hospital_cd_a3 
		when date_trunc(''day'',mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'',mst_treatment.in_hosp_a_startdate) then mst_treatment.in_hospital_cd_b3 
		when date_trunc(''day'',mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'',mst_treatment.in_hosp_b_startdate) is null then mst_treatment.in_hospital_cd_a3
		when date_trunc(''day'',mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'',mst_treatment.in_hosp_a_startdate) is null then mst_treatment.in_hospital_cd_b3
		when date_trunc(''day'',mst_treatment.in_hosp_b_startdate) < date_trunc(''day'',mst_treatment.in_hosp_a_startdate) and date_trunc(''day'',mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then mst_treatment.in_hospital_cd_a3
		when date_trunc(''day'',mst_treatment.in_hosp_a_startdate) < date_trunc(''day'',mst_treatment.in_hosp_b_startdate) and date_trunc(''day'',mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then mst_treatment.in_hospital_cd_b3
		when ord.treat_date :: TIMESTAMP = date_trunc(''day'',mst_treatment.in_hosp_a_startdate) and ord.treat_date :: TIMESTAMP = date_trunc(''day'',mst_treatment.in_hosp_b_startdate) then mst_treatment.in_hospital_cd_a3
		else ''''
	end as treatment_in_hospital_cd_3,	
	case 	
		when date_trunc(''day'',mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'',mst_treatment.in_hosp_b_startdate) then mst_treatment.in_hospital_cd_a4 
		when date_trunc(''day'',mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'',mst_treatment.in_hosp_a_startdate) then mst_treatment.in_hospital_cd_b4 
		when date_trunc(''day'',mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'',mst_treatment.in_hosp_b_startdate) is null then mst_treatment.in_hospital_cd_a4
		when date_trunc(''day'',mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'',mst_treatment.in_hosp_a_startdate) is null then mst_treatment.in_hospital_cd_b4
		when date_trunc(''day'',mst_treatment.in_hosp_b_startdate) < date_trunc(''day'',mst_treatment.in_hosp_a_startdate) and date_trunc(''day'',mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then mst_treatment.in_hospital_cd_a4
		when date_trunc(''day'',mst_treatment.in_hosp_a_startdate) < date_trunc(''day'',mst_treatment.in_hosp_b_startdate) and date_trunc(''day'',mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then mst_treatment.in_hospital_cd_b4
		when ord.treat_date :: TIMESTAMP = date_trunc(''day'',mst_treatment.in_hosp_a_startdate) and ord.treat_date :: TIMESTAMP = date_trunc(''day'',mst_treatment.in_hosp_b_startdate) then mst_treatment.in_hospital_cd_a4
		else ''''
	end as treatment_in_hospital_cd_4,		
	

  CAST(ord.rst_cond_info->''26''->>''value'' AS DECIMAL)
    + CAST(ord.rst_cond_info->''28''->>''value'' AS DECIMAL)
    as anti_coagulant_total_amount,

  case
    when ord.rst_cond_info->''31''->>''value'' is not null then ''ml/h''
    else null
  end as ip_one_shot_amount_unit,
  case
    when ord.rst_cond_info->''32''->>''value'' is not null then ''ml/h''
    else null
  end as ip_speed_unit,
  case
    when ord.rst_cond_info->''33''->>''value'' is not null then ''ml''
    else null
  end as ip_speed_max_unit,

  ord.rst_tare_info->>''name_1'' as tare_name1,
  ord.rst_tare_info->>''name_2'' as tare_name2,
  ord.rst_tare_info->>''name_3'' as tare_name3,
  ord.rst_tare_info->>''name_4'' as tare_name4,
  ord.rst_tare_info->>''name_5'' as tare_name5,
  ord.rst_tare_info->>''weight_1'' as tare_weight1,
  ord.rst_tare_info->>''weight_2'' as tare_weight2,
  ord.rst_tare_info->>''weight_3'' as tare_weight3,
  ord.rst_tare_info->>''weight_4'' as tare_weight4,
  ord.rst_tare_info->>''weight_5'' as tare_weight5,
  CAST(ord.rst_tare_info->>''weight_1'' AS DECIMAL)
    + CAST(ord.rst_tare_info->>''weight_2'' AS DECIMAL)
    + CAST(ord.rst_tare_info->>''weight_3'' AS DECIMAL)
    + CAST(ord.rst_tare_info->>''weight_4'' AS DECIMAL)
    + CAST(ord.rst_tare_info->>''weight_5'' AS DECIMAL)
    as tare_weight_total,

  ord.rst_off_water_info->>''name_1'' as off_water_name1,
  ord.rst_off_water_info->>''name_2'' as off_water_name2,
  ord.rst_off_water_info->>''name_3'' as off_water_name3,
  ord.rst_off_water_info->>''name_4'' as off_water_name4,
  ord.rst_off_water_info->>''name_5'' as off_water_name5,
  ord.rst_off_water_info->>''weight_1'' as off_water_weight1,
  ord.rst_off_water_info->>''weight_2'' as off_water_weight2,
  ord.rst_off_water_info->>''weight_3'' as off_water_weight3,
  ord.rst_off_water_info->>''weight_4'' as off_water_weight4,
  ord.rst_off_water_info->>''weight_5'' as off_water_weight5,
  CAST(ord.rst_off_water_info->>''weight_1'' AS DECIMAL)
    + CAST(ord.rst_off_water_info->>''weight_2'' AS DECIMAL)
    + CAST(ord.rst_off_water_info->>''weight_3'' AS DECIMAL)
    + CAST(ord.rst_off_water_info->>''weight_4'' AS DECIMAL)
    + CAST(ord.rst_off_water_info->>''weight_5'' AS DECIMAL)
    as off_water_weight_total,

  case
    when ord.rst_cond_info->''3''->>''value'' = ''-1'' then ''1''
    else ''0''
  end as target_weight_mode,
  case
    when ord.rst_cond_info->''3''->>''value'' = ''-1'' then pat_physical_tbl.dw
    else ord.rst_cond_info->''3''->>''value''
  end as target_weight,


  pat_physical_tbl.pre_scale_upper,
  pat_physical_tbl.pre_scale_lower,

  pat_wheel_chair_tbl.wheel_chair_name,
  pat_wheel_chair_tbl.wheel_chair_weight,

  mst_va.va_name as va_name,
  mst_va.in_hospital_cd_1 as va_in_hospital_cd_1,
  mst_va.in_hospital_cd_2  as va_in_hospital_cd_2,
  mst_va.va_direct as va_direct,

  mst_bed.shunt_position,
  mst_bed.is_infection,
  mst_bed.emergency_class,
  mst_machine.machine_name,

  bed_group_tbl.bed_group_name, -- 実績
  room_tbl.room_name, -- 実績

  mst_dialyzer.model_number as dialyzer_name,
  mst_dialyzer.maker,
  mst_dialyzer.function_class,
  mst_dialyzer.area,
  mst_dialyzer.ufr,
  mst_dialyzer.koa,
  mst_dialyzer.material,
  mst_dialyzer.wetdry,
  mst_dialyzer.sterilization,
  mst_dialyzer.bloodamt,
  mst_dialyzer.alqd_flood_vol,
  mst_dialyzer.urea_clearance,
  mst_dialyzer.gas_purge_time,
  mst_dialyzer.substituent_wash_amt,
  mst_dialyzer.membrane_wash,
  mst_dialyzer.in_hospital_cd_1 as rst_dialyzer_in_hospital_cd_1,
  mst_dialyzer.in_hospital_cd_2 as rst_dialyzer_in_hospital_cd_2,
  mst_dialyzer.in_hospital_cd_3 as rst_dialyzer_in_hospital_cd_3,
  mst_dialyzer.in_hospital_cd_4 as rst_dialyzer_in_hospital_cd_4,

  adsorption_column_tbl.equipment_name as adsorption_column_name,
  adsorption_column_tbl.in_hospital_cd_1 as rst_adsorption_in_hospital_cd_1,
  adsorption_column_tbl.in_hospital_cd_2 as rst_adsorption_in_hospital_cd_2,
  adsorption_column_tbl.in_hospital_cd_3 as rst_adsorption_in_hospital_cd_3,
  adsorption_column_tbl.in_hospital_cd_4 as rst_adsorption_in_hospital_cd_4,

  primary_film_tbl.equipment_name as primary_film_name,
  primary_film_tbl.in_hospital_cd_1 as rst_primary_film_in_hospital_cd_1,
  primary_film_tbl.in_hospital_cd_2 as rst_primary_film_in_hospital_cd_2,
  primary_film_tbl.in_hospital_cd_3 as rst_primary_film_in_hospital_cd_3,
  primary_film_tbl.in_hospital_cd_4 as rst_primary_film_in_hospital_cd_4,

  secondary_film_tbl.equipment_name as secondary_film_name,
  secondary_film_tbl.in_hospital_cd_1 as rst_secondary_film_in_hospital_cd_1,
  secondary_film_tbl.in_hospital_cd_2 as rst_secondary_film_in_hospital_cd_2,
  secondary_film_tbl.in_hospital_cd_3 as rst_secondary_film_in_hospital_cd_3,
  secondary_film_tbl.in_hospital_cd_4 as rst_secondary_film_in_hospital_cd_4,

  puncture_needle_a_tbl.equipment_name as puncture_needle_a_name,
  puncture_needle_a_tbl.in_hospital_cd_1 as rst_pn_a_in_hospital_cd_1,
  puncture_needle_a_tbl.in_hospital_cd_2 as rst_pn_a_in_hospital_cd_2,
  puncture_needle_a_tbl.in_hospital_cd_3 as rst_pn_a_in_hospital_cd_3,
  puncture_needle_a_tbl.in_hospital_cd_4 as rst_pn_a_in_hospital_cd_4,

  puncture_needle_v_tbl.equipment_name as puncture_needle_v_name,
  puncture_needle_v_tbl.in_hospital_cd_1 as rst_pn_v_in_hospital_cd_1,
  puncture_needle_v_tbl.in_hospital_cd_2 as rst_pn_v_in_hospital_cd_2,
  puncture_needle_v_tbl.in_hospital_cd_3 as rst_pn_v_in_hospital_cd_3,
  puncture_needle_v_tbl.in_hospital_cd_4 as rst_pn_v_in_hospital_cd_4,

  puncture_needle_sn_tbl.equipment_name as puncture_needle_s_name,
  puncture_needle_sn_tbl.in_hospital_cd_1 as rst_pn_s_in_hospital_cd_1,
  puncture_needle_sn_tbl.in_hospital_cd_2 as rst_pn_s_in_hospital_cd_2,
  puncture_needle_sn_tbl.in_hospital_cd_3 as rst_pn_s_in_hospital_cd_3,
  puncture_needle_sn_tbl.in_hospital_cd_4 as rst_pn_s_in_hospital_cd_4,

  blood_circuit_tbl.equipment_name as blood_circuit_name,
  blood_circuit_tbl.in_hospital_cd_1 as rst_bc_in_hospital_cd_1,
  blood_circuit_tbl.in_hospital_cd_2 as rst_bc_in_hospital_cd_2,
  blood_circuit_tbl.in_hospital_cd_3 as rst_bc_in_hospital_cd_3,
  blood_circuit_tbl.in_hospital_cd_4 as rst_bc_in_hospital_cd_4,

  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.medicine_mix_name
    else med_dialysate_tbl.medicine_name
  end as dialysate_name,

  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.in_hospital_cd_1
    else med_dialysate_tbl.in_hospital_cd_1
  end as rst_dialysate_in_hospital_cd_1,

  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.in_hospital_cd_2
    else med_dialysate_tbl.in_hospital_cd_2
  end as rst_dialysate_in_hospital_cd_2,

  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.in_hospital_cd_3
    else med_dialysate_tbl.in_hospital_cd_3
  end as rst_dialysate_in_hospital_cd_3,

  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then ''''
    else med_dialysate_tbl.in_hospital_cd_4
  end as rst_dialysate_in_hospital_cd_4,


  case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.medicine_mix_name
    else med_fluid_replacement_tbl.medicine_name
  end as fluid_replacement_name,

   case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.in_hospital_cd_1
    else med_fluid_replacement_tbl.in_hospital_cd_1
  end as rst_fluid_in_hospital_cd_1,

  case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.in_hospital_cd_2
    else med_fluid_replacement_tbl.in_hospital_cd_2
  end as rst_fluid_in_hospital_cd_2,

  case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.in_hospital_cd_3
    else med_fluid_replacement_tbl.in_hospital_cd_3
  end as rst_fluid_in_hospital_cd_3,

  case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then ''''
    else med_fluid_replacement_tbl.in_hospital_cd_4
  end as rst_fluid_in_hospital_cd_4,

  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.medicine_mix_name
    else med_anti_coagulant_tbl.medicine_name
  end as anti_coagulant_name,

  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.in_hospital_cd_1
    else med_anti_coagulant_tbl.in_hospital_cd_1
  end as rst_anti_in_hospital_cd_1,

  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.in_hospital_cd_2
    else med_anti_coagulant_tbl.in_hospital_cd_2
  end as rst_anti_in_hospital_cd_2,

  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.in_hospital_cd_3
    else med_anti_coagulant_tbl.in_hospital_cd_3
  end as rst_anti_in_hospital_cd_3,

  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then ''''
    else med_anti_coagulant_tbl.in_hospital_cd_4
  end as rst_anti_in_hospital_cd_4,

  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.unit
    else med_dialysate_tbl.unit
  end as dialysate_amount_unit,
  case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.unit
    else med_fluid_replacement_tbl.unit
  end as fluid_replacement_unit,
  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.unit
    else med_anti_coagulant_tbl.unit
  end as anti_coagulant_unit,
  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.unit
    else med_anti_coagulant_tbl.unit
  end as anti_coagulant_speed_unit

  -- 実績
  ,rst_dialysis_cnt
  ,rst_in_out_class
  ,rst_ward_name
  ,mst_ward_tbl.in_hospital_cd_1 as  rst_ward_in_hospital_cd_1
  ,rst_course_name
  ,mst_course_tbl.in_hospital_cd_1 as  rst_course_in_hospital_cd_1
  ,rst_accept_date
  ,rst_return_home_date
  ,rst_purification_cnt
  ,trim(coalesce(rst_charge_user_info->>''user_id_1'', '''') , '' '') as rst_charge_user_id_1
  ,trim(coalesce(rst_charge_user_info->>''user_id_2'', '''') , '' '') as rst_charge_user_id_2
  ,trim(coalesce(rst_charge_user_info->>''user_last_name_1'', '''') || '' '' || coalesce(rst_charge_user_info->>''user_first_name_1'', ''''), '' '') as rst_charge_user_name1
  ,trim(coalesce(rst_charge_user_info->>''user_last_name_2'', '''') || '' '' || coalesce(rst_charge_user_info->>''user_first_name_2'', ''''), '' '') as rst_charge_user_name2
  ,(rst_charge_user_info->>''date_1'')::timestamp as rst_charge_date1
  ,(rst_charge_user_info->>''date_2'')::timestamp as rst_charge_date2
  ,trim(coalesce(rst_puncture_user_info->>''user_id_1'', '''') , '' '') as rst_puncture_user_id_1
  ,trim(coalesce(rst_puncture_user_info->>''user_id_2'', '''') , '' '') as rst_puncture_user_id_2
  ,trim(coalesce(rst_puncture_user_info->>''user_last_name_1'', '''') || '' '' || coalesce(rst_puncture_user_info->>''user_first_name_1'', ''''), '' '') as rst_puncture_user_name1
  ,trim(coalesce(rst_puncture_user_info->>''user_last_name_2'', '''') || '' '' || coalesce(rst_puncture_user_info->>''user_first_name_2'', ''''), '' '') as rst_puncture_user_name2
  ,(rst_puncture_user_info->>''date_1'')::timestamp as rst_puncture_date1
  ,(rst_puncture_user_info->>''date_2'')::timestamp as rst_puncture_date2
  ,trim(coalesce(rst_return_user_info->>''user_id_1'', '''') , '' '') as rst_return_user_id_1
  ,trim(coalesce(rst_return_user_info->>''user_id_2'', '''') , '' '') as rst_return_user_id_2
  ,trim(coalesce(rst_return_user_info->>''user_last_name_1'', '''') || '' '' || coalesce(rst_return_user_info->>''user_first_name_1'', ''''), '' '') as rst_return_user_name1
  ,trim(coalesce(rst_return_user_info->>''user_last_name_2'', '''') || '' '' || coalesce(rst_return_user_info->>''user_first_name_2'', ''''), '' '') as rst_return_user_name2
  ,(rst_return_user_info->>''date_1'')::timestamp as rst_return_date1
  ,(rst_return_user_info->>''date_2'')::timestamp as rst_return_date2
  ,pull_leave_amount
  ,ord.rst_dw
  ,ord.rst_treatment_name

from
  ord_main as ord

  left join pat_physical_tbl on ord.pat_id = pat_physical_tbl.pat_id
  left join pat_wheel_chair_tbl on ord.pat_id = pat_wheel_chair_tbl.pat_id

  left join mst_va on cast(rst_cond_info->''2''->>''value'' as integer) = mst_va.va_cd  and mst_va.is_del = ''0'' and mst_va.is_disp = ''1''  -- 実績

  left join mst_treatment on ord.rst_treatment_cd = mst_treatment.treatment_cd and mst_treatment.is_del = ''0'' and mst_treatment.is_disp = ''1''
  left join mst_bed on ord.rst_bed_cd = mst_bed.bed_cd and mst_bed.is_del = ''0'' and mst_bed.is_disp = ''1''
  left join mst_machine on mst_bed.machine_no = mst_machine.machine_no and mst_machine.is_del = ''0'' and mst_machine.is_disp = ''1''

  left join bed_group_tbl on mst_bed.facility_cd = bed_group_tbl.facility_cd -- 実績
  left join room_tbl on mst_bed.facility_cd = room_tbl.facility_cd -- 実績

  left join mst_dialyzer on ord.rst_cond_info->''5''->>''value'' = mst_dialyzer.dialyzer_cd::text and mst_dialyzer.is_del = ''0'' and mst_dialyzer.is_disp = ''1'' and mst_dialyzer.dialyzer_cd in (@diaIds)

  left join mst_equipment as adsorption_column_tbl on ord.rst_cond_info->''6''->>''value'' = adsorption_column_tbl.equipment_cd::text and adsorption_column_tbl.is_del = ''0'' and adsorption_column_tbl.is_disp = ''1''and adsorption_column_tbl.class_cd IN (@eqIds)
  left join mst_equipment as primary_film_tbl on ord.rst_cond_info->''7''->>''value'' = primary_film_tbl.equipment_cd::text and primary_film_tbl.is_del = ''0'' and primary_film_tbl.is_disp = ''1'' and primary_film_tbl.class_cd IN (@eqIds)
  left join mst_equipment as secondary_film_tbl on ord.rst_cond_info->''8''->>''value'' = secondary_film_tbl.equipment_cd::text and secondary_film_tbl.is_del = ''0'' and secondary_film_tbl.is_disp = ''1'' and secondary_film_tbl.class_cd IN (@eqIds)

  left join mst_equipment as puncture_needle_a_tbl on ord.rst_cond_info->''9''->>''value'' = puncture_needle_a_tbl.equipment_cd::text and puncture_needle_a_tbl.is_del = ''0'' and puncture_needle_a_tbl.is_disp = ''1'' and puncture_needle_a_tbl.class_cd IN (@eqIds)
  left join mst_equipment as puncture_needle_v_tbl on ord.rst_cond_info->''10''->>''value'' = puncture_needle_v_tbl.equipment_cd::text and puncture_needle_v_tbl.is_del = ''0'' and puncture_needle_v_tbl.is_disp = ''1'' and puncture_needle_v_tbl.class_cd IN (@eqIds)
  left join mst_equipment as puncture_needle_sn_tbl on ord.rst_cond_info->''11''->>''value'' = puncture_needle_sn_tbl.equipment_cd::text and puncture_needle_sn_tbl.is_del = ''0'' and puncture_needle_sn_tbl.is_disp = ''1'' and puncture_needle_sn_tbl.class_cd IN (@eqIds)
  left join mst_equipment as blood_circuit_tbl on ord.rst_cond_info->''13''->>''value'' = blood_circuit_tbl.equipment_cd::text and blood_circuit_tbl.is_del = ''0'' and blood_circuit_tbl.is_disp = ''1'' and blood_circuit_tbl.class_cd IN (@eqIds)

  left join mst_medicine as med_dialysate_tbl on ord.rst_cond_info->''15''->>''value'' = med_dialysate_tbl.medicine_cd::text and med_dialysate_tbl.is_del = ''0'' and med_dialysate_tbl.is_disp = ''1'' and  med_dialysate_tbl.class_cd IN ( @medIds )
  left join mst_medicine as med_fluid_replacement_tbl on ord.rst_cond_info->''19''->>''value'' = med_fluid_replacement_tbl.medicine_cd::text and med_fluid_replacement_tbl.is_del = ''0'' and med_fluid_replacement_tbl.is_disp = ''1'' and  med_fluid_replacement_tbl.class_cd IN ( @medIds )
  left join mst_medicine as med_anti_coagulant_tbl on ord.rst_cond_info->''25''->>''value'' = med_anti_coagulant_tbl.medicine_cd::text and med_anti_coagulant_tbl.is_del = ''0'' and med_anti_coagulant_tbl.is_disp = ''1''   and  med_anti_coagulant_tbl.class_cd IN ( @medIds )

  left join mst_medicine_mix as mix_dialysate_tbl on ord.rst_cond_info->''15''->>''value'' = mix_dialysate_tbl.medicine_mix_cd::text and mix_dialysate_tbl.is_del = ''0'' and mix_dialysate_tbl.is_disp = ''1'' and  mix_dialysate_tbl.class_cd IN ( @medIds )
  left join mst_medicine_mix as mix_fluid_replacement_tbl on ord.rst_cond_info->''19''->>''value'' = mix_fluid_replacement_tbl.medicine_mix_cd::text and mix_fluid_replacement_tbl.is_del = ''0'' and mix_fluid_replacement_tbl.is_disp = ''1'' and  mix_fluid_replacement_tbl.class_cd IN ( @medIds )
  left join mst_medicine_mix as mix_anti_coagulant_tbl on ord.rst_cond_info->''25''->>''value'' = mix_anti_coagulant_tbl.medicine_mix_cd::text and mix_anti_coagulant_tbl.is_del = ''0'' and mix_anti_coagulant_tbl.is_disp = ''1''  and  mix_anti_coagulant_tbl.class_cd IN ( @medIds )
  left join mst_ward as mst_ward_tbl on (ord.rst_ward_cd = mst_ward_tbl.ward_cd and mst_ward_tbl.is_disp =''1'' and mst_ward_tbl.is_del =''0''    )
  left join mst_course as mst_course_tbl on (ord.rst_course_cd = mst_course_tbl.course_cd and mst_course_tbl.is_disp =''1'' and mst_course_tbl.is_del =''0''   )
where
  ord.ord_no = @ordNo
 and ord.rst_dialysis_state >''0'' and ord.rst_dialysis_state <''6''
 and ord.is_del = ''0''

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
	b.ord_no as ordnob,
	b.treat_date as treat_date,
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
	', 2, '[{"preview": "2011/3/12", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/3/12 08:21", "can_calc": "0", "data_code": "treat_start_time", "data_name": "透析開始時刻", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "treat_start_time", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/3/12  12:45", "can_calc": "0", "data_code": "treat_end_time", "data_name": "透析終了時刻", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "treat_end_time", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "0", "data_code": "treatment_time", "data_name": "透析時間", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "treatment_time", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "420", "can_calc": "0", "data_code": "treatment_time", "data_name": "透析時間(分)", "data_type": "decimal", "conv_table": [], "data_class": "実績情報", "field_name": "treatment_time", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "89", "can_calc": "1", "data_code": "rst_dialysis_cnt", "data_name": "透析回数", "data_type": "decimal", "conv_table": [], "data_class": "実績情報", "field_name": "rst_dialysis_cnt", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "89", "can_calc": "1", "data_code": "rst_purification_cnt", "data_name": "特殊浄化回数", "data_type": "decimal", "conv_table": [], "data_class": "実績情報", "field_name": "rst_purification_cnt", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "外来", "can_calc": "0", "data_code": "rst_in_out_class", "data_name": "入外区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "外来", "item": "外来"}, {"code": "1", "disp": "入院", "item": "入院"}], "data_class": "実績情報", "field_name": "rst_in_out_class", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "A棟", "can_calc": "0", "data_code": "rst_ward_name", "data_name": "病棟名", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_ward_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_ward_in_hospital_cd_1", "data_name": "病棟連携コード", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_ward_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "泌尿器科", "can_calc": "0", "data_code": "rst_course_name", "data_name": "診療科名", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_course_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "泌尿器科", "can_calc": "0", "data_code": "rst_course_in_hospital_cd_1", "data_name": "診療科連携コード", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_course_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:01", "can_calc": "0", "data_code": "rst_accept_date", "data_name": "受付時刻", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_accept_date", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13:02", "can_calc": "0", "data_code": "rst_return_home_date", "data_name": "帰宅時刻", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_home_date", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_charge_user_id_1", "data_name": "担当者ID１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_user_id_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "rst_charge_user_name1", "data_name": "担当者名１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_user_name1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:03", "can_calc": "0", "data_code": "rst_charge_date1", "data_name": "担当日時１", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_date1", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_charge_user_id_2", "data_name": "担当者ID２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_user_id_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "rst_charge_user_name2", "data_name": "担当者名２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_user_name2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:04", "can_calc": "0", "data_code": "rst_charge_date2", "data_name": "担当日時２", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_date2", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_puncture_user_id_1", "data_name": "穿刺者ID１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_user_id_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "data_code": "rst_puncture_user_name1", "data_name": "穿刺者名１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_user_name1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:16", "can_calc": "0", "data_code": "rst_puncture_date1", "data_name": "穿刺日時１", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_date1", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_puncture_user_id_2", "data_name": "穿刺者ID２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_user_id_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "data_code": "rst_puncture_user_name2", "data_name": "穿刺者名２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_user_name2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:16", "can_calc": "0", "data_code": "rst_puncture_date2", "data_name": "穿刺日時２", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_date2", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_return_user_id_1", "data_name": "返血者ID１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_user_id_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "rst_return_user_name1", "data_name": "返血者名１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_user_name1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:51", "can_calc": "0", "data_code": "rst_return_date1", "data_name": "返血日時１", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_date1", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_return_user_id_2", "data_name": "返血者ID２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_user_id_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "data_code": "rst_return_user_name2", "data_name": "返血者名２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_user_name2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:51", "can_calc": "0", "data_code": "rst_return_date2", "data_name": "返血日時２", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_date2", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.10", "can_calc": "0", "data_code": "pull_leave_amount", "data_name": "I-HDF引き残し量", "data_type": "decimal", "conv_table": [], "data_class": "実績情報", "field_name": "pull_leave_amount", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "04:00", "can_calc": "0", "data_code": "treatment_time", "data_name": "透析時間", "data_type": "DateTime", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_time", "disp_format": "[h]:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "420", "can_calc": "0", "data_code": "treatment_time", "data_name": "透析時間(分)", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_time", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左手前腕部シャント化静脈", "can_calc": "0", "data_code": "va_name", "data_name": "VA", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "va_in_hospital_cd_1", "data_name": "VA連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "va_in_hospital_cd_2", "data_name": "VA連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左", "can_calc": "0", "data_code": "va_direct", "data_name": "VA方向", "data_type": "string", "conv_table": [{"code": "0", "disp": "右", "item": "右"}, {"code": "1", "disp": "左", "item": "左"}, {"code": "2", "disp": "両方", "item": "両方"}, {"code": "3", "disp": "なし", "item": "なし"}, {"code": "-", "disp": "不明", "item": "不明"}], "data_class": "透析条件", "field_name": "va_direct", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "1", "data_code": "dw", "data_name": "DW", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dw", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DWと同じ", "can_calc": "0", "data_code": "target_weight_mode", "data_name": "目標体重指定設定", "data_type": "string", "conv_table": [{"code": "0", "disp": "DWと違う", "item": "DWと違う"}, {"code": "1", "disp": "DWと同じ", "item": "DWと同じ"}], "data_class": "透析条件", "field_name": "target_weight_mode", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "1", "data_code": "target_weight", "data_name": "目標体重", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "target_weight", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "HDF", "can_calc": "0", "data_code": "treatment_name", "data_name": "治療方法", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_treatment_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "HDF", "can_calc": "0", "data_code": "device_mode", "data_name": "装置モード", "data_type": "string", "conv_table": [{"code": "-1", "disp": "不明", "item": "不明"}, {"code": "0", "disp": "HD", "item": "HD"}, {"code": "1", "disp": "ECUM", "item": "ECUM"}, {"code": "2", "disp": "HDF", "item": "HDF"}, {"code": "3", "disp": "HF", "item": "HF"}, {"code": "4", "disp": "HD+補液", "item": "HD+補液"}, {"code": "5", "disp": "ECUM+補液", "item": "ECUM+補液"}, {"code": "6", "disp": "AFBF", "item": "AFBF"}, {"code": "7", "disp": "OHDF", "item": "OHDF"}, {"code": "8", "disp": "OHF", "item": "OHF"}, {"code": "9", "disp": "特殊浄化", "item": "特殊浄化"}, {"code": "10", "disp": "I-HDF", "item": "I-HDF"}], "data_class": "透析条件", "field_name": "device_mode", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "water_removal_amount_limit", "data_name": "除水量制限", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "water_removal_amount_limit", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "FDX-120GW", "can_calc": "0", "data_code": "dialyzer_name", "data_name": "ダイアライザ", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialyzer_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト１次膜", "can_calc": "0", "data_code": "primary_film_name", "data_name": "1次膜", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "primary_film_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_primary_film_in_hospital_cd_1", "data_name": "1次膜連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_primary_film_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_primary_film_in_hospital_cd_2", "data_name": "1次膜連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_primary_film_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_primary_film_in_hospital_cd_3", "data_name": "1次膜連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_primary_film_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_primary_film_in_hospital_cd_4", "data_name": "1次膜連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_primary_film_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト２次膜", "can_calc": "0", "data_code": "secondary_film_name", "data_name": "2次膜", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "secondary_film_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_secondary_film_in_hospital_cd_1", "data_name": "2次膜連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_secondary_film_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_secondary_film_in_hospital_cd_2", "data_name": "2次膜連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_secondary_film_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_secondary_film_in_hospital_cd_3", "data_name": "2次膜連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_secondary_film_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_secondary_film_in_hospital_cd_4", "data_name": "2次膜連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_secondary_film_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リクセルS-15", "can_calc": "0", "data_code": "adsorption_column_name", "data_name": "吸着カラム", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "adsorption_column_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_adsorption_in_hospital_cd_1", "data_name": "吸着カラム連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_adsorption_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_adsorption_in_hospital_cd_2", "data_name": "吸着カラム連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_adsorption_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_adsorption_in_hospital_cd_3", "data_name": "吸着カラム連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_adsorption_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_adsorption_in_hospital_cd_4", "data_name": "吸着カラム連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_adsorption_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "180", "can_calc": "1", "data_code": "blood_flow", "data_name": "血流量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "blood_flow", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "Dドライ3.0S", "can_calc": "0", "data_code": "dialysate_name", "data_name": "透析液", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialysate_in_hospital_cd_1", "data_name": "透析液連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialysate_in_hospital_cd_2", "data_name": "透析液連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialysate_in_hospital_cd_3", "data_name": "透析液連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialysate_in_hospital_cd_4", "data_name": "透析液連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/min", "can_calc": "0", "data_code": "dialysate_amount_unit", "data_name": "透析液単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_amount_unit", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "dialysate_flow_rate", "data_name": "透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_flow_rate", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120.00", "can_calc": "1", "data_code": "dialysate_amount", "data_name": "透析液量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_amount", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.0", "can_calc": "1", "data_code": "dialysate_temperature", "data_name": "透析液温度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_temperature", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト補液", "can_calc": "0", "data_code": "fluid_replacement_name", "data_name": "補液", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_fluid_in_hospital_cd_1", "data_name": "補液連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_fluid_in_hospital_cd_2", "data_name": "補液連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_fluid_in_hospital_cd_3", "data_name": "補液連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_fluid_in_hospital_cd_4", "data_name": "補液連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "L", "can_calc": "0", "data_code": "fluid_replacement_unit", "data_name": "補液単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_unit", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "8.0", "can_calc": "1", "data_code": "fluid_replacement_amount", "data_name": "補液量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_amount", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.0", "can_calc": "1", "data_code": "fluid_replacement_speed", "data_name": "補液速度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_speed", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "後補液", "can_calc": "0", "data_code": "fluid_replacement_timing", "data_name": "補液選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "後補液", "item": "後補液"}, {"code": "1", "disp": "前補液", "item": "前補液"}], "data_class": "透析条件", "field_name": "fluid_replacement_timing", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "1", "data_code": "fluid_replacement_use_count", "data_name": "補液使用数", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_use_count", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.0", "can_calc": "1", "data_code": "fluid_replacement_temperature", "data_name": "補液温度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_temperature", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト抗凝固剤", "can_calc": "0", "data_code": "anti_coagulant_name", "data_name": "抗凝固剤", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_anti_in_hospital_cd_1", "data_name": "抗凝固剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_anti_in_hospital_cd_2", "data_name": "抗凝固剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_anti_in_hospital_cd_3", "data_name": "抗凝固剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_anti_in_hospital_cd_4", "data_name": "抗凝固剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "U", "can_calc": "0", "data_code": "anti_coagulant_unit", "data_name": "抗凝固剤単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_unit", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1000", "can_calc": "1", "data_code": "anti_coagulant_one_shot_amount", "data_name": "抗凝固剤ワンショット量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_one_shot_amount", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "anti_coagulant_sustained_speed", "data_name": "抗凝固剤持続速度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_speed", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "U/h", "can_calc": "0", "data_code": "anti_coagulant_sustained_speed_unit", "data_name": "抗凝固剤持続速度単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_speed_unit", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2000", "can_calc": "1", "data_code": "anti_coagulant_sustained_amount", "data_name": "抗凝固剤持続総量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_amount", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3000", "can_calc": "1", "data_code": "anti_coagulant_total_amount", "data_name": "抗凝固剤総量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_total_amount", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "する", "can_calc": "0", "data_code": "ip", "data_name": "IP使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "透析条件", "field_name": "ip", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "自動", "can_calc": "0", "data_code": "ip_start", "data_name": "IPスタート", "data_type": "string", "conv_table": [{"code": "0", "disp": "手動", "item": "手動"}, {"code": "1", "disp": "自動", "item": "自動"}], "data_class": "透析条件", "field_name": "ip_start", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.2", "can_calc": "1", "data_code": "ip_speed", "data_name": "IP速度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/h", "can_calc": "0", "data_code": "ip_speed_unit", "data_name": "IP速度単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_unit", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "1", "data_code": "ip_speed_max", "data_name": "IP速度最大値", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_max", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/h", "can_calc": "0", "data_code": "ip_speed_max_unit", "data_name": "IP速度最大値単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_max_unit", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "auto_one_shot", "data_name": "自動ワンショット", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "透析条件", "field_name": "auto_one_shot", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ip_one_shot_amount", "data_name": "IPワンショット量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_one_shot_amount", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL", "can_calc": "0", "data_code": "ip_one_shot_amount_unit", "data_name": "IPワンショット量単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_one_shot_amount_unit", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切", "can_calc": "0", "data_code": "ip_auto_off", "data_name": "IP電源自動切り", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "透析条件", "field_name": "ip_auto_off", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ip_auto_off_time", "data_name": "IP電源自動切り時間", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_auto_off_time", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切", "can_calc": "0", "data_code": "ip_monitor_auto_off", "data_name": "IP電源OKモニタ切り", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "透析条件", "field_name": "ip_monitor_auto_off", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ip_monitor_auto_off_time", "data_name": "IP電源OKモニタ切り時間", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_monitor_auto_off_time", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "しない", "can_calc": "0", "data_code": "single_needle", "data_name": "シングルニードル使用", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "透析条件", "field_name": "single_needle", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針A", "can_calc": "0", "data_code": "puncture_needle_a_name", "data_name": "穿刺針A針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_a_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_a_in_hospital_cd_1", "data_name": "穿刺針A針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_a_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_a_in_hospital_cd_2", "data_name": "穿刺針A針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_a_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_a_in_hospital_cd_3", "data_name": "穿刺針A針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_a_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_a_in_hospital_cd_4", "data_name": "穿刺針A針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_a_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針V針", "can_calc": "0", "data_code": "puncture_needle_v_name", "data_name": "穿刺針V針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_v_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_v_in_hospital_cd_1", "data_name": "穿刺針V針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_v_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_v_in_hospital_cd_2", "data_name": "穿刺針V針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_v_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_v_in_hospital_cd_3", "data_name": "穿刺針V針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_v_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_v_in_hospital_cd_4", "data_name": "穿刺針V針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_v_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針S針", "can_calc": "0", "data_code": "puncture_needle_s_name", "data_name": "穿刺針S針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_s_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_s_in_hospital_cd_1", "data_name": "穿刺針S針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_s_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_s_in_hospital_cd_2", "data_name": "穿刺針S針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_s_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_s_in_hospital_cd_3", "data_name": "穿刺針S針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_s_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_s_in_hospital_cd_4", "data_name": "穿刺針S針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_s_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "血液回路", "can_calc": "0", "data_code": "blood_circuit_name", "data_name": "血液回路名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "blood_circuit_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_bc_in_hospital_cd_1", "data_name": "血液回路連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_bc_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_bc_in_hospital_cd_2", "data_name": "血液回路連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_bc_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_bc_in_hospital_cd_3", "data_name": "血液回路連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_bc_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_bc_in_hospital_cd_4", "data_name": "血液回路連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_bc_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左", "can_calc": "0", "data_code": "shunt_position", "data_name": "シャント位置", "data_type": "string", "conv_table": [{"code": "0", "disp": "右", "item": "右"}, {"code": "1", "disp": "左", "item": "左"}, {"code": "2", "disp": "両方", "item": "両方"}, {"code": "3", "disp": "なし", "item": "なし"}, {"code": "-", "disp": "不明", "item": "不明"}], "data_class": "ベッド情報", "field_name": "shunt_position", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "感染症あり", "can_calc": "0", "data_code": "is_infection", "data_name": "感染症対応", "data_type": "string", "conv_table": [{"code": "0", "disp": "感染症なし", "item": "感染症なし"}, {"code": "1", "disp": "感染症あり", "item": "感染症あり"}], "data_class": "ベッド情報", "field_name": "is_infection", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常ベッド", "can_calc": "0", "data_code": "emergency_class", "data_name": "緊急区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "通常ベッド", "item": "通常ベッド"}, {"code": "1", "disp": "緊急ベッド", "item": "緊急ベッド"}], "data_class": "ベッド情報", "field_name": "emergency_class", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "Aグループ", "can_calc": "0", "data_code": "bed_group_name", "data_name": "ベッドグループ名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "bed_group_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "第二透析室", "can_calc": "0", "data_code": "room_name", "data_name": "透析室名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "room_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "装置001", "can_calc": "0", "data_code": "machine_name", "data_name": "装置名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "machine_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装", "can_calc": "0", "data_code": "maker", "data_name": "メーカー", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "maker", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "function_class", "data_name": "機能分類", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "function_class", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.2", "can_calc": "1", "data_code": "area", "data_name": "面積", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "area", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "45.00", "can_calc": "1", "data_code": "ufr", "data_name": "UFR", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "ufr", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "koa", "data_name": "KOA", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "koa", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "親水化PEPA", "can_calc": "0", "data_code": "material", "data_name": "材質", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "material", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "WET", "can_calc": "0", "data_code": "wetdry", "data_name": "WET/DRY", "data_type": "string", "conv_table": [{"code": "0", "disp": "不明", "item": "不明"}, {"code": "1", "disp": "WET", "item": "WET"}, {"code": "2", "disp": "DRY", "item": "DRY"}], "data_class": "ダイアライザ情報", "field_name": "wetdry", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "γ線滅菌", "can_calc": "0", "data_code": "sterilization", "data_name": "滅菌", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "sterilization", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "0", "data_code": "bloodamt", "data_name": "血流量", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "bloodamt", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "alqd_flood_vol", "data_name": "透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "alqd_flood_vol", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "190", "can_calc": "0", "data_code": "urea_clearance", "data_name": "尿素クリアランス", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "urea_clearance", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "1", "data_code": "gas_purge_time", "data_name": "ガスパージ時間", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "gas_purge_time", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1000", "can_calc": "1", "data_code": "substituent_wash_amt", "data_name": "置換洗浄量（透析液）", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "substituent_wash_amt", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "membrane_wash", "data_name": "膜洗浄（中空糸）", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "ダイアライザ情報", "field_name": "membrane_wash", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialyzer_in_hospital_cd_1", "data_name": "ダイアライザ連携コード１", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "rst_dialyzer_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialyzer_in_hospital_cd_2", "data_name": "ダイアライザ連携コード２", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "rst_dialyzer_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialyzer_in_hospital_cd_3", "data_name": "ダイアライザ連携コード３", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "rst_dialyzer_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialyzer_in_hospital_cd_4", "data_name": "ダイアライザ連携コード４", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "rst_dialyzer_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_1", "data_name": "治療方法連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_2", "data_name": "治療方法連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_3", "data_name": "治療方法連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_4", "data_name": "治療方法連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": []}', '実績（治療中）：透析条件/ベッド情報/ダイアライザ情報/実績情報 @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (167, 'WITH DATA AS (


	with ord_key_tbl as (
  select
    facility_cd
  from
    ord_main
  where
    ord_no = @ordNo and is_del = ''0'' and rst_dialysis_state > ''0'' and rst_dialysis_state < ''6''
), dialyzer_tbl as (
  select
    *
  from
    mst_dialyzer
  where
    mst_dialyzer.facility_cd = (select facility_cd from ord_key_tbl)
  and
    mst_dialyzer.is_disp = ''1''
  and
    mst_dialyzer.is_del = ''0''
), equipment_tbl as (
  select
    *
  from
    mst_equipment
  where
    mst_equipment.facility_cd = (select facility_cd from ord_key_tbl)
  and
    mst_equipment.is_disp = ''1''
  and
    mst_equipment.is_del = ''0''
), equipment_class_tbl as (
  select
    *
  from
    mst_equipment_class
  where
    mst_equipment_class.facility_cd = (select facility_cd from ord_key_tbl)
  and
    mst_equipment_class.is_disp = ''1''
  and
    mst_equipment_class.is_del = ''0''
), ord_tbl as (
  select
		ord_no,
    facility_cd,
    to_date(treat_date, ''yyyymmdd'') as treat_date,
    case
			when info->>''class_cd'' is null then ''-1''
			else info->>''class_cd''
			end as equip_class_cd,
    info->>''class_type'' as class_type,
    info->>''equip_type'' as equip_type,
    info->>''cd'' as cd,
    info->>''amount'' as amount,
    info->>''ind_user_id'' as ind_user_id,
    info->>''ind_user_last_name'' as ind_user_last_name,
    info->>''ind_user_first_name'' as ind_user_first_name,
    info->>''upd_user_id'' as upd_user_id,
    info->>''upd_user_last_name'' as upd_user_last_name,
    info->>''upd_user_first_name'' as upd_user_first_name,
    info->>''input_class'' as input_class,
    info->>''is_editable'' as is_editable,
    info->>''cop_order_no'' as cop_order_no
    -- 実績
    ,info->>''needle_type'' as needle_type
  from
    ord_main
      cross join lateral
        json_array_elements (ord_main.rst_equip_info :: json) info
  where
    ord_no = @ordNo and is_del = ''0'' and rst_dialysis_state > ''0'' and rst_dialysis_state < ''6''
)
(select
ord_no as ord_no_t,
  ord.*,
    dia.model_number as equip_name,
  dia.in_hospital_cd_1 as rst_equip_in_hospital_cd_1,
  dia.in_hospital_cd_2 as rst_equip_in_hospital_cd_2,
  dia.in_hospital_cd_3 as rst_equip_in_hospital_cd_3,
  dia.in_hospital_cd_4 as rst_equip_in_hospital_cd_4,
  null as equip_unit,
  null as equip_class_name,
  null as equip_class_type
from
  ord_tbl as ord
  inner join dialyzer_tbl as dia on ord.cd = dia.dialyzer_cd::text
  where equip_type = ''1''   and dia.dialyzer_cd IN (@diaIds)
order by equip_class_cd, cd)
union all
(select
ord_no as ord_no_t,
  ord.*,
    eqp.equipment_name as equip_name,
  eqp.in_hospital_cd_1 as rst_equip_in_hospital_cd_1,
  eqp.in_hospital_cd_2 as rst_equip_in_hospital_cd_2,
  eqp.in_hospital_cd_3 as rst_equip_in_hospital_cd_3,
  eqp.in_hospital_cd_4 as rst_equip_in_hospital_cd_4,
  eqp.unit as equip_unit,
  eqp_cls.class_name as equip_class_name,
  eqp_cls.class_type as equip_class_type
from
  ord_tbl as ord
  inner join equipment_tbl as eqp on ord.cd = eqp.equipment_cd::text
  left join equipment_class_tbl eqp_cls on eqp.class_cd = eqp_cls.class_cd
  where equip_type <> ''1'' and eqp.class_cd IN (@eqIds)
order by equip_class_cd, cd)

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
	b.ord_no as ordnob,
	b.treat_date as treat_date,
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
	', 2, '[{"preview": "テスト穿刺針", "can_calc": "0", "data_code": "equip_name", "data_name": "医療材料名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_name", "disp_format": "", "filter_type": "Equip", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針", "can_calc": "0", "data_code": "equip_class_name", "data_name": "医療材料分類名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_class_name", "disp_format": "", "filter_type": "Equip", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "amount", "disp_format": "0", "filter_type": "Equip", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "equip_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_unit", "disp_format": "", "filter_type": "Equip", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "A針", "can_calc": "0", "data_code": "needle_type", "data_name": "穿刺針区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "未使用", "item": "未使用"}, {"code": "1", "disp": "A針", "item": "A針"}, {"code": "2", "disp": "V針", "item": "V針"}, {"code": "3", "disp": "SN", "item": "SN"}], "data_class": "医材", "field_name": "needle_type", "disp_format": "", "filter_type": "Equip", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_1", "data_name": "医療材料連携コード１", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_1", "disp_format": "", "filter_type": "Equip", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_2", "data_name": "医療材料連携コード２", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_2", "disp_format": "", "filter_type": "Equip", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_3", "data_name": "医療材料連携コード３", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_3", "disp_format": "", "filter_type": "Equip", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_4", "data_name": "医療材料連携コード４", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_4", "disp_format": "", "filter_type": "Equip", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": []}', '実績（治療中）：医材 @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (168, 'WITH DATA AS (


	select
	ord_no as ord_no_t,
  facility_cd,
  to_date(treat_date, ''yyyymmdd'') as treat_date,

  info->>''no'' as no,
  info->>''content'' as content,

  info->>''ind_user_id'' as ind_user_id,
  info->>''ind_user_last_name'' as ind_user_last_name,
  info->>''ind_user_first_name'' as ind_user_first_name,
  info->>''upd_user_id'' as upd_user_id,
  info->>''upd_user_last_name'' as upd_user_last_name,
  info->>''upd_user_first_name'' as upd_user_first_name,
  info->>''input_class'' as input_class,
  info->>''is_editable'' as is_editable,
  info->>''cop_order_no'' as cop_order_no
from
  ord_main
    cross join lateral
      json_array_elements (ord_main.rst_ind_comment_info :: json) info
where
  ord_no = @ordNo and is_del = ''0''
  and rst_dialysis_state > ''0'' and rst_dialysis_state < ''6''
order by no

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
	b.ord_no as ordnob,
	b.treat_date as treat_date,
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
	', 2, '[{"preview": "指示簿テストです。", "can_calc": "0", "data_code": "content", "data_name": "指示内容", "data_type": "string", "conv_table": [], "data_class": "指示コメント", "field_name": "content", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": []}', '実績（治療中）：指示簿(指示コメント) @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (169, 'WITH DATA AS (


	with current_ord AS (
    select pat_id, treat_date, rst_start_date
    from ord_main
    where ord_no = @ordNo
    and is_del = ''0''
    and rst_dialysis_state >''0'' and rst_dialysis_state <''6''
),
hist_ord_nos as (
  select
    ord_main.ord_no
    ,ord_main.rst_start_date
  from
    ord_main INNER JOIN current_ord ON ord_main.pat_id = current_ord.pat_id
  where    rst_dialysis_state >''0'' and rst_dialysis_state <''6''
    and ord_main.ord_no <> @ordNo
    and (((current_ord.rst_start_date is not null) and (ord_main.rst_start_date <= current_ord.rst_start_date))
        or
         ((current_ord.rst_start_date is null) and (ord_main.rst_start_date is not null) and (ord_main.treat_date <= current_ord.treat_date)))
    and is_del = ''0''
  order by rst_start_date desc limit 2
)
, ord_hist_tbl as (
  select rst_start_date
    ,CAST(rst_weight_info->>''weight_before'' AS DECIMAL) as weight_before
    ,(rst_weight_info->>''weight_before_date'')::timestamp as weight_before_date
    ,CAST(rst_weight_info->>''weight_after'' AS DECIMAL) as weight_after
    ,(rst_weight_info->>''weight_after_date'')::timestamp as weight_after_date
    ,CAST(rst_weight_info->>''water_removal_rst'' AS DECIMAL) as water_removal_rst
  from
    ord_main
  where
    ord_no in (select ord_no from hist_ord_nos)
  and is_del = ''0''
  and rst_dialysis_state >''0'' and rst_dialysis_state <''6''
), ord_array_tbl as (
  select
    array_agg(weight_before order by rst_start_date desc) as array_weight_before
    ,array_agg(weight_before_date order by rst_start_date desc) as array_weight_before_date
    ,array_agg(weight_after order by rst_start_date desc) as array_weight_after
    ,array_agg(weight_after_date order by rst_start_date desc) as array_weight_after_date
    ,array_agg(water_removal_rst order by rst_start_date desc) as array_water_removal_rst
  from
    ord_hist_tbl
)
select
	@ordNo as ord_no_t
	,array_water_removal_rst[1] as water_removal_rst_prev
  ,array_weight_before[2] as weight_before_prev_prev
  ,array_weight_before_date[2] as weight_before_date_prev_prev
  ,array_weight_after[2] as weight_after_prev_prev
  ,array_weight_after_date[2] as weight_after_date_prev_prev
  ,array_water_removal_rst[2] as water_removal_rst_prev_prev
from
  ord_array_tbl

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
	b.ord_no as ordnob,
	b.treat_date as treat_date,
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
	', 2, '[{"preview": "2.00", "can_calc": "1", "data_code": "water_removal_rst_prev", "data_name": "実績除水量(前回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "water_removal_rst_prev", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "58.20", "can_calc": "1", "data_code": "weight_before_prev_prev", "data_name": "前体重(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "weight_before_prev_prev", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/08", "can_calc": "0", "data_code": "weight_before_date_prev_prev", "data_name": "前体重測定日時(前々回)", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "weight_before_date_prev_prev", "disp_format": "yyyy/mm/dd", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.30", "can_calc": "1", "data_code": "weight_after_prev_prev", "data_name": "後体重(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "weight_after_prev_prev", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/08", "can_calc": "0", "data_code": "weight_after_date_prev_prev", "data_name": "後体重測定日時(前々回)", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "weight_after_date_prev_prev", "disp_format": "yyyy/mm/dd", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.10", "can_calc": "1", "data_code": "water_removal_rst_prev_prev", "data_name": "実績除水量(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "water_removal_rst_prev_prev", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": []}', '実績（治療中）：体重情報(過去実績) @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (170, 'WITH DATA AS (

with latest_otc as(
  select * from ord_treat_condition where (ord_no, up_date) in (select ord_no, max(up_date) from ord_treat_condition where ord_no = @ordNo and is_del = ''0'' and is_disp = ''1'' group by ord_no)
)
, dialyzer_record as(
  select gas_purge_time, substituent_wash_amt, membrane_wash
  from
    ord_main
    inner join (select * from mst_dialyzer where is_del = ''0'' and is_disp = ''1'' and dialyzer_cd IN (@diaIds)) as mst_dialyzer
      on (ord_main.rst_cond_info#>>''{5, value}'')::text = mst_dialyzer.dialyzer_cd::text
  where
    ord_no = @ordNo and ord_main.is_del = ''0''
    and ord_main.rst_dialysis_state >''0'' and ord_main.rst_dialysis_state <''6''
)

select
  ord_main.ord_no as ord_no_t
	,null as ope_dev_a_0179 -- 血流量設定最大値
  ,null as ope_dev_a_0181 -- 除水速度制限
  ,null as ope_dev_a_0038 -- 動脈側気泡検出器
  ,null as ope_dev_a_0021 -- 除水計算時間
  ,null as ope_dev_a_0022 -- 除水計算優先項目
  ,null as ope_dev_a_0039 -- 除水開始遅延時間
  ,null as ope_dev_a_0182 -- 透析液温度操作範囲上限
  ,null as ope_dev_a_0183 -- 透析液温度操作範囲下限
  ,null as ope_dev_a_0024 -- シングルニードル切替圧上限
  ,null as ope_dev_a_0025 -- シングルニードル切替圧下限
  ,null as ope_dev_a_0241 -- TMPゼロ補正
  ,null as ope_dev_a_0168 -- HD補正警報上限値
  ,null as ope_dev_a_0169 -- HD補正警報下限値
  ,null as ope_dev_a_0171 -- ECUM補正警報上限値
  ,null as ope_dev_a_0172 -- ECUM補正警報下限値
  ,null as ope_dev_a_0174 -- HDF補正警報上限値
  ,null as ope_dev_a_0175 -- HDF補正警報下限値
  ,null as ope_dev_a_0177 -- HF補正警報上限値
  ,null as ope_dev_a_0178 -- HF補正警報下限値
  ,null as ope_dev_b_0037 -- HD+補液補正警報上限値
  ,null as ope_dev_b_0038 -- HD+補液補正警報下限値
  ,null as ope_dev_a_0391 -- OHDF補正警報上限値
  ,null as ope_dev_a_0392 -- OHDF補正警報下限値
  ,null as ope_dev_a_0394 -- OHF補正警報上限値
  ,null as ope_dev_a_0395 -- OHF補正警報下限値
  ,null as ope_dev_a_0383 -- 補液量制限
  ,null as ope_dev_a_0389 -- 補液計算優先項目
  ,null as ope_dev_a_0379 -- 補液比率（前補液）
  ,null as ope_dev_b_0039 -- 補液比率（後補液）
  ,null as ope_dev_a_0398 -- 補液開始遅延時間
  ,null as ope_dev_a_0369 -- DP=Qd+Qs(補液速度加算)
  ,null as ope_dev_a_0090 -- 濾過率（前補液）
  ,null as ope_dev_b_0040 -- 濾過率（後補液）
  ,null as ope_dev_a_0091 -- ヘマトクリット（Ht）
  ,null as ope_dev_a_0092 -- 総タンパク（TP）
  ,null as ope_dev_a_0336 -- 緊急補液速度
  ,null as ope_dev_a_0337 -- 緊急補液量
  ,null as ope_dev_a_0185 -- HDF速度操作範囲上限前補液
  ,null as ope_dev_b_0031 -- HDF速度操作範囲上限後補液
  ,null as ope_dev_a_0186 -- HF速度操作範囲上限前補液
  ,null as ope_dev_b_0032 -- HF速度操作範囲上限後補液
  ,null as ope_dev_b_0030 -- HD+補液速度操作範囲上限前補液
  ,null as ope_dev_b_0033 -- HD+補液速度操作範囲上限後補液
  ,null as ope_dev_a_0396 -- OHDF速度操作範囲上限前補液
  ,null as ope_dev_b_0034 -- OHDF速度操作範囲上限後補液
  ,null as ope_dev_a_0397 -- OHF速度操作範囲上限前補液
  ,null as ope_dev_b_0035 -- OHF速度操作範囲上限後補液
  ,null as ope_dev_a_0384 -- AFBF補液比率使用選択
  ,null as ope_dev_a_0385 -- AFBF補液比率
  ,null as ope_dev_a_0386 -- AFBF速度操作範囲上限
  ,null as ope_dev_a_0387 -- AFBF速度操作範囲下限
  ,null as ihdf_dev_a_0200 -- I-HDF_補液量設定
  ,null as ihdf_dev_a_0201 -- I-HDF_補液速度
  ,null as ihdf_dev_a_0202 -- I-HDF_補液周期
  ,null as ihdf_dev_a_0203 -- I-HDF_補液開始時間
  ,null as ihdf_dev_a_0204 -- I-HDF_除水再開時間
  ,null as ihdf_dev_a_0205 -- I-HDF_総補液量上限
  ,null as blood_flow_judge --ホスト監視血流量監視フラグ
  ,null as blood_flow_upper --ホスト監視血流量上限
  ,null as blood_flow_lower --ホスト監視血流量下限
  ,null as ip_speed_judge --ホスト監視IP速度監視フラグ
  ,null as ip_speed_upper --ホスト監視IP速度上限
  ,null as ip_speed_lower --ホスト監視IP速度下限
  ,null as ufr_judge --ホスト監視除水速度監視フラグ
  ,null as ufr_upper --ホスト監視除水速度上限
  ,null as ufr_lower --ホスト監視除水速度下限
  ,null as bp_max_judge --ホスト監視最高血圧監視フラグ
  ,null as bp_max_upper --ホスト監視最高血圧上限
  ,null as bp_max_lower --ホスト監視最高血圧下限
  ,null as bp_min_judge --ホスト監視最低血圧監視フラグ
  ,null as bp_min_upper --ホスト監視最低血圧上限
  ,null as bp_min_lower --ホスト監視最低血圧下限
  ,null as bp_ave_judge --ホスト監視平均血圧監視フラグ
  ,null as bp_ave_upper --ホスト監視平均血圧上限
  ,null as bp_ave_lower --ホスト監視平均血圧下限
  ,null as pulse_judge --ホスト監視脈拍監視フラグ
  ,null as pulse_upper --ホスト監視脈拍上限
  ,null as pulse_lower --ホスト監視脈拍下限
  ,null as vp_judge --ホスト監視静脈圧監視フラグ
  ,null as vp_upper --ホスト監視静脈圧上限
  ,null as vp_lower --ホスト監視静脈圧下限
  ,null as rst_ap_judge --ホスト監視動脈圧監視フラグ
  ,null as rst_ap_upper --ホスト監視動脈圧上限
  ,null as rst_ap_lower --ホスト監視動脈圧下限
  ,null as na_conc_judge --ホスト監視Na濃度監視フラグ
  ,null as na_conc_upper --ホスト監視Na濃度上限
  ,null as na_conc_lower --ホスト監視Na濃度下限
  ,null as dialys_temp_judge --ホスト監視透析液温度監視フラグ
  ,null as dialys_temp_upper --ホスト監視透析液温度上限
  ,null as dialys_temp_lower --ホスト監視透析液温度下限
  ,null as care_i_judge --ホスト監視血圧未測定時報知監視フラグ
  ,null as care_i_interval --ホスト監視ケア報知
  ,null as war_dev_a_0240 -- TMP監視モード
  ,null as war_dev_a_0100 -- HD/ECUM静脈圧自動設定警報幅上限
  ,null as war_dev_a_0101 -- HD/ECUM静脈圧自動設定警報幅下限
  ,null as war_dev_a_0102 -- HD/ECUM静脈圧自動設定警報限界上限
  ,null as war_dev_a_0103 -- HD/ECUM静脈圧自動設定警報限界下限
  ,null as war_dev_a_0104 -- HD/ECUM静脈圧固定警報上限
  ,null as war_dev_a_0105 -- HD/ECUM静脈圧固定警報下限
  ,null as war_dev_a_0152 -- HD/ECUMダイアライザ入口圧自動設定警報幅上限
  ,null as war_dev_a_0153 -- HD/ECUMダイアライザ入口圧自動設定警報幅下限
  ,null as war_dev_a_0154 -- HD/ECUMダイアライザ入口圧自動設定警報限界上限
  ,null as war_dev_a_0155 -- HD/ECUMダイアライザ入口圧自動設定警報限界下限
  ,null as war_dev_a_0156 -- HD/ECUMダイアライザ入口圧固定警報上限
  ,null as war_dev_a_0157 -- HD/ECUMダイアライザ入口圧固定警報下限
  ,null as war_dev_a_0112 -- HD/ECUM液圧自動設定警報幅上限
  ,null as war_dev_a_0113 -- HD/ECUM液圧自動設定警報幅下限
  ,null as war_dev_a_0114 -- HD/ECUM液圧自動設定警報限界上限
  ,null as war_dev_a_0115 -- HD/ECUM液圧自動設定警報限界下限
  ,null as war_dev_a_0116 -- HD/ECUM液圧固定警報上限
  ,null as war_dev_a_0117 -- HD/ECUM液圧固定警報下限
  ,null as war_dev_a_0128 -- HD/ECUMTMP自動設定警報幅上限
  ,null as war_dev_a_0129 -- HD/ECUMTMP自動設定警報幅下限
  ,null as war_dev_a_0130 -- HD/ECUMTMP自動設定警報限界上限
  ,null as war_dev_a_0131 -- HD/ECUMTMP自動設定警報限界下限
  ,null as war_dev_a_0132 -- HD/ECUMTMP固定警報上限
  ,null as war_dev_a_0133 -- HD/ECUMTMP固定警報下限
  ,null as war_dev_a_0126 -- HD/ECUMTMP自動追従警報幅上限
  ,null as war_dev_a_0127 -- HD/ECUMTMP自動追従警報幅下限
  ,null as war_dev_a_0146 -- HD/ECUMダイアライザ差圧自動設定警報幅上限
  ,null as war_dev_a_0147 -- HD/ECUMダイアライザ差圧自動設定警報幅下限
  ,null as war_dev_a_0148 -- HD/ECUMダイアライザ差圧固定警報上限
  ,null as war_dev_a_0149 -- HD/ECUMダイアライザ差圧固定警報下限
  ,null as war_dev_a_0106 -- HDF/HF静脈圧自動設定警報幅上限
  ,null as war_dev_a_0107 -- HDF/HF静脈圧自動設定警報幅下限
  ,null as war_dev_a_0158 -- HDF/HFダイアライザ入口圧自動設定警報幅上限
  ,null as war_dev_a_0159 -- HDF/HFダイアライザ入口圧自動設定警報幅下限
  ,null as war_dev_a_0118 -- HDF/HF液圧自動設定警報幅上限
  ,null as war_dev_a_0119 -- HDF/HF液圧自動設定警報幅下限
  ,null as war_dev_a_0136 -- HDF/HFTMP自動設定警報幅上限
  ,null as war_dev_a_0137 -- HDF/HFTMP自動設定警報幅下限
  ,null as war_dev_a_0134 -- HDF/HFTMP自動追従警報幅上限
  ,null as war_dev_a_0135 -- HDF/HFTMP自動追従警報幅下限
  ,null as war_dev_a_0150 -- HDF/HFダイアライザ差圧自動設定警報幅上限
  ,null as war_dev_a_0151 -- HDF/HFダイアライザ差圧自動設定警報幅下限
  ,null as war_dev_a_0110 -- SN静脈圧固定警報上限
  ,null as war_dev_a_0111 -- SN静脈圧固定警報下限
  ,null as war_dev_a_0162 -- SNダイアライザ入口圧固定警報上限
  ,null as war_dev_a_0163 -- SNダイアライザ入口圧固定警報下限
  ,null as war_dev_a_0120 -- SN液圧自動設定警報幅上限
  ,null as war_dev_a_0121 -- SN液圧自動設定警報幅下限
  ,null as war_dev_a_0122 -- SN液圧自動設定警報限界上限
  ,null as war_dev_a_0123 -- SN液圧自動設定警報限界下限
  ,null as war_dev_a_0124 -- SN液圧固定警報上限
  ,null as war_dev_a_0125 -- SN液圧固定警報下限
  ,null as war_dev_a_0140 -- SNTMP自動設定警報幅上限
  ,null as war_dev_a_0141 -- SNTMP自動設定警報幅下限
  ,null as war_dev_a_0142 -- SNTMP自動設定警報限界上限
  ,null as war_dev_a_0143 -- SNTMP自動設定警報限界下限
  ,null as war_dev_a_0144 -- SNTMP固定警報上限
  ,null as war_dev_a_0145 -- SNTMP固定警報下限
  ,null as war_dev_a_0138 -- SNTMP自動追従警報幅上限
  ,null as war_dev_a_0139 -- SNTMP自動追従警報幅下限
  ,null as war_dev_a_0108 -- 準備回収静脈圧固定警報上限
  ,null as war_dev_a_0109 -- 準備回収静脈圧固定警報下限
  ,null as war_dev_a_0160 -- 準備回収ダイアライザ入口圧固定警報上限
  ,null as war_dev_a_0161 -- 準備回収ダイアライザ入口圧固定警報下限
  ,null as war_dev_a_0254 -- Na濃度自動警報幅上限値
  ,null as war_dev_a_0255 -- Na濃度自動警報幅下限値
  ,null as war_dev_a_0256 -- Na濃度固定警報幅上限値
  ,null as war_dev_a_0257 -- Na濃度固定警報幅下限値
  ,null as bp_dev_a_0211 -- 血圧警報点最高血圧上限
  ,null as bp_dev_a_0212 -- 血圧警報点最高血圧下限
  ,null as bp_dev_a_0213 -- 血圧警報点最低血圧上限
  ,null as bp_dev_a_0214 -- 血圧警報点最低血圧下限
  ,null as bp_dev_a_0215 -- 血圧警報点平均血圧上限
  ,null as bp_dev_a_0216 -- 血圧警報点平均血圧下限
  ,null as bp_dev_a_0217 -- 血圧警報点脈拍数上限
  ,null as bp_dev_a_0218 -- 血圧警報点脈拍数下限
  ,null as bp_dev_a_0219 -- 最高血圧上限警報_血液ポンプ_動作選択
  ,null as bp_dev_a_0227 -- 最高血圧上限警報_血液ポンプ_速度
  ,null as bp_dev_a_0220 -- 最高血圧下限警報_血液ポンプ_動作選択
  ,null as bp_dev_a_0228 -- 最高血圧下限警報_血液ポンプ_速度
  ,null as bp_dev_a_0221 -- 最高血圧上限警報_除水ポンプ_動作選択
  ,null as bp_dev_a_0229 -- 最高血圧上限警報_除水ポンプ_速度
  ,null as bp_dev_a_0222 -- 最高血圧下限警報_除水ポンプ_動作選択
  ,null as bp_dev_a_0230 -- 最高血圧下限警報_除水ポンプ_速度
  ,null as bp_dev_a_0223 -- 最高血圧上限警報_Na注入ポンプ_動作選択
  ,null as bp_dev_a_0231 -- 最高血圧上限警報_Na注入ポンプ_速度
  ,null as bp_dev_a_0224 -- 最高血圧下限警報_Na注入ポンプ_動作選択
  ,null as bp_dev_a_0225 -- 最高血圧上限警報_補液ポンプ_動作選択
  ,null as bp_dev_a_0233 -- 最高血圧上限警報_補液ポンプ_速度
  ,null as bp_dev_a_0226 -- 最高血圧下限警報_補液ポンプ_動作選択
  ,null as bp_dev_a_0234 -- 最高血圧下限警報_補液ポンプ_速度
  ,null as bp_dev_a_0191 -- 血圧カフ選択
  ,null as bp_dev_a_0190 -- 血圧自動測定間隔
  ,null as bp_dev_a_0192 -- 昇圧値
  ,null as bp_dev_a_0193 -- 昇圧方法選択
  ,null as bp_dev_a_0195 -- 血圧測定方法選択
  ,null as bp_dev_a_0239 -- 高速測定選択
  ,null as bp_dev_a_0194 -- 血圧連続測定動作選択
  ,null as bp_dev_a_0235 -- 警報連動測定開始時間
  ,null as bp_dev_a_0236 -- 治療条件連動測定時間
  ,null as bp_dev_a_0237 -- 静脈圧警報発生時の血圧測定
  ,null as bp_dev_a_0238 -- 血流量または除水速度変更時の血圧測定
  ,null as bv_dev_a_0267 -- BV計使用選択
  ,null as bv_dev_a_0260 -- ⊿BV低下警報点1
  ,null as bv_dev_a_0261 -- ⊿BV低下警報点2
  ,null as bv_dev_a_0262 -- ⊿BV変化率警報点
  ,null as bv_dev_a_0277 -- ⊿BV除水低下速度
  ,null as bv_dev_a_0278 -- ⊿BV除水低下遅延時間
  ,null as bv_dev_a_0258 -- アクセス再循環測定使用選択
  ,null as bv_dev_a_0259 -- アクセス再循環自動測定1
  ,null as bv_dev_a_0263 -- アクセス再循環自動測定2
  ,null as bv_dev_a_0264 -- アクセス再循環自動測定3
  ,null as bv_dev_a_0265 -- アクセス再循環自動測定4
  ,null as bv_dev_a_0266 -- アクセス再循環自動測定5
  ,null as dfas_dev_a_0270 -- 動脈側返血使用選択
  ,null as bv_dev_a_0281 -- アクセス再循環再循環率報知
  ,null as pri_pat_a_0219 -- プライミング補助動脈充填液量
  ,null as pri_pat_a_0220 -- プライミング補助動脈充填流速
  ,null as pri_pat_a_0225 -- プライミング補助動脈充填後継続の有無
  ,null as pri_pat_a_0221 -- プライミング補助静脈充填液量
  ,null as pri_pat_a_0222 -- プライミング補助静脈充填流速
  ,null as pri_pat_a_0226 -- プライミング補助静脈充填後継続の有無
  ,null as pri_pat_a_0223 -- プライミング補助気泡抜き液量
  ,null as pri_pat_a_0224 -- プライミング補助気泡抜き流速
  ,null as pri_pat_a_0227 -- プライミング補助気泡抜き間欠動作選択
  ,null as pri_pat_a_0228 -- プライミング補助液交換量
  ,null as pri_pat_a_0229 -- プライミング補助間欠動作動作時間
  ,null as pri_pat_a_0230 -- プライミング補助間欠動作停止時間
  ,null as pri_pat_a_0232 -- 自動プライミング落差時間
  ,null as pri_pat_a_0238 -- 自動プライミング総量
  ,null as pri_pat_a_0231 -- 自動プライミング開始時間
  ,null as pri_pat_a_0233 -- 自動プライミング送液液量
  ,null as pri_pat_a_0234 -- 自動プライミング送液流速1回目
  ,null as pri_pat_a_0235 -- 自動プライミング送液流速2回目以降
  ,null as pri_pat_a_0236 -- 自動プライミング循環流速
  ,null as pri_pat_a_0237 -- 自動プライミング循環時間
  ,null as pri_dev_a_0370 -- 自動回収_使用液量
  ,null as pri_dev_a_0371 -- 自動回収_流速
  ,null as pri_dev_a_0372 -- 自動回収_血液判別器による終了選択
  ,null as pri_pat_b_0051 -- オンラインプライミング_ダイアライザ気泡抜き時間_後補液
  ,null as pri_pat_b_0032 -- オンラインプライミング_動脈チャンバ液面作成時間_前補液
  ,null as pri_pat_b_0052 -- オンラインプライミング_動脈チャンバ液面作成時間_後補液
  ,null as pri_pat_b_0033 -- オンラインプライミング_循環洗浄時間_前補液
  ,null as pri_pat_b_0053 -- オンラインプライミング_循環洗浄時間_後補液
  ,null as ufr_dev_a_0290 -- UFRプログラム使用選択
  ,null as na_dev_a_0315 -- Na注入プログラム使用選択
  ,null as na_dev_a_0184 -- Na注入濃度最大値
  ,null as dc_dev_a_0340 -- 透析液濃度プログラム使用選択
  ,null as ecum_dev_a_0016 -- ECUM選択
  ,null as ecum_dev_a_0017 -- ECUM量
  ,null as ecum_dev_a_0018 -- ECUM時間
  ,null as ecum_dev_a_0019 -- ECUM時間カウント選択
  ,null as cpro_dev_a_0252 -- Ｂ液濃度プログラム自動設定警報幅上限
  ,null as cpro_dev_a_0253 -- Ｂ液濃度プログラム自動設定警報幅下限
  ,null as cpro_dev_a_0250 -- 透析液濃度プログラム自動設定警報幅上限
  ,null as cpro_dev_a_0251 -- 透析液濃度プログラム自動設定警報幅下限
  ,null as dfas_pat_b_0001 -- IPラインプライミング使用選択
  ,dialyzer_record.gas_purge_time -- ガスパージ時間
  ,dialyzer_record.substituent_wash_amt-- 置換洗浄量（透析液）
  ,dialyzer_record.membrane_wash -- 膜洗浄（中空糸）
  ,null as dfas_pat_b_0005 -- 中空糸_プライミング時のBP速度
  ,null as dfas_pat_b_0007 -- 中空糸_送液最大時間
  ,null as dfas_pat_b_0008 -- 中空糸_回路内洗浄送液量
  ,null as dfas_pat_b_0009 -- 中空糸_気泡抜き動作実行回数
  ,null as dfas_pat_b_0010 -- 中空糸_気泡抜き圧力上限
  ,null as dfas_pat_b_0059 -- 積層_プライミング時のBP速度
  ,null as dfas_pat_b_0054 -- 積層_送液最大時間
  ,null as dfas_pat_b_0055 -- 積層_回路内洗浄送液量
  ,null as dfas_pat_b_0056 -- 積層_気泡抜き動作実行回数
  ,null as dfas_pat_b_0057 -- 積層_気泡抜き圧力上限
  ,null as dfas_pat_b_0058 -- 積層_除水ポンプ速度
  ,null as dfas_dev_a_0339 -- 脱血方法選択
  ,null as dfas_dev_a_0333 -- 脱血速度
  ,null as dfas_dev_a_0331 -- 同時脱血_脱血量
  ,null as dfas_dev_a_0334 -- 片側脱血(除水なし)_脱血量
  ,null as dfas_dev_a_0338 -- 片側脱血（除水あり）_脱血量
  ,null as dfas_dev_a_0332 -- 片側脱血への切替え透析液圧
  ,treat_condition->>''335'' as ord_treat_condition_335 -- 治療開始時_血液ポンプ速度
  ,null as dfas_dev_a_0373 -- 静脈側返血速度
  ,null as dfas_dev_a_0374 -- 静脈側最大返血量
  ,null as dfas_dev_a_0377 -- 静脈側返血_血液判別器使用選択
  ,null as dfas_dev_a_0376 -- 動脈側最大返血量
  ,null as dfas_dev_a_0378 -- 動脈側返血_血液判別器使用選択
  ,null as dia_dev_a_0282 -- 透析量プログラム使用選択
  ,treat_condition->>''283'' as ord_treat_condition_283 -- 体液量計算時後体重
  ,treat_condition->>''284'' as ord_treat_condition_284 -- 体液量+補正値
  ,treat_condition->>''285'' as ord_treat_condition_285 -- 目標後体重
  ,treat_condition->>''286'' as ord_treat_condition_286 -- 標準血流量
  ,treat_condition->>''287'' as ord_treat_condition_287 -- KoA
  ,null as dia_dev_a_0288 -- 目標Kt/V
  ,treat_condition->>''187'' as ord_treat_condition_187 -- ダイアライザ 尿素クリアランス
  ,treat_condition->>''188'' as ord_treat_condition_188 -- ダイアライザ 血流量
  ,treat_condition->>''189'' as ord_treat_condition_189 -- ダイアライザ 透析液流量
  ,null as bvufc_dev_a_0196 -- BV-UFC使用選択
  ,null as bvufc_dev_a_0197 -- UFC期間除水速度上限
  ,null as bvufc_dev_a_0198 -- UFC期間除水速度下限
  ,null as bvufc_dev_a_0199 -- 開始期間 時間
  ,null as bvufc_dev_a_0206 -- 開始期間 除水速度倍率
  ,null as bvufc_dev_a_0207 -- 固定倍率除水期間 時間
  ,null as bvufc_dev_a_0208 -- 固定倍率除水期間 除水速度倍率
  ,null as bvufc_dev_a_0209 -- 固定倍率除水終了条件　最高血圧
  ,null as bvufc_dev_a_0210 -- 固定倍率除水終了条件　脈拍
  ,null as bvufc_dev_a_0248 -- 固定倍率除水終了条件　ΔBV
  ,null as bvufc_dev_a_0249 -- 終了前期間 時間
  ,null as ope_dev_a_0268 -- 透析液流量　設定方法
  ,null as ope_dev_a_0269 -- 透析液流量　比率設定
  ,null as bvufc_dev_a_0271 -- 開始時ΔBV基準値
  ,null as bvufc_dev_a_0272 -- ΔBV基準線　指数1
  ,null as bvufc_dev_a_0273 -- ΔBV基準線　指数2
  ,null as bvufc_dev_a_0274 -- ΔBV基準線　指数3
  ,null as bvufc_dev_a_0275 -- 終了時ΔBV基準値
  ,null as qbqd_dev_a_0400 -- QBプログラム血流量1
  ,null as qbqd_dev_a_0401 -- QBプログラム血流量2
  ,null as qbqd_dev_a_0402 -- QBプログラム血流量3
  ,null as qbqd_dev_a_0403 -- QBプログラム血流量4
  ,null as qbqd_dev_a_0404 -- QBプログラム血流量5
  ,null as qbqd_dev_a_0405 -- QBプログラム血流量6
  ,null as qbqd_dev_a_0406 -- QBプログラム血流量7
  ,null as qbqd_dev_a_0407 -- QBプログラム血流量8
  ,null as qbqd_dev_a_0408 -- QBプログラム血流量9
  ,null as qbqd_dev_a_0409 -- QBプログラム血流量10
  ,null as qbqd_dev_a_0410 -- QDプログラム透析液流量1
  ,null as qbqd_dev_a_0411 -- QDプログラム透析液流量2
  ,null as qbqd_dev_a_0412 -- QDプログラム透析液流量3
  ,null as qbqd_dev_a_0413 -- QDプログラム透析液流量4
  ,null as qbqd_dev_a_0414 -- QDプログラム透析液流量5
  ,null as qbqd_dev_a_0415 -- QDプログラム透析液流量6
  ,null as qbqd_dev_a_0416 -- QDプログラム透析液流量7
  ,null as qbqd_dev_a_0417 -- QDプログラム透析液流量8
  ,null as qbqd_dev_a_0418 -- QDプログラム透析液流量9
  ,null as qbqd_dev_a_0419 -- QDプログラム透析液流量10
  ,null as qbqd_dev_a_0420 -- QB、QDプログラム切替時間1
  ,null as qbqd_dev_a_0421 -- QB、QDプログラム切替時間2
  ,null as qbqd_dev_a_0422 -- QB、QDプログラム切替時間3
  ,null as qbqd_dev_a_0423 -- QB、QDプログラム切替時間4
  ,null as qbqd_dev_a_0424 -- QB、QDプログラム切替時間5
  ,null as qbqd_dev_a_0425 -- QB、QDプログラム切替時間6
  ,null as qbqd_dev_a_0426 -- QB、QDプログラム切替時間7
  ,null as qbqd_dev_a_0427 -- QB、QDプログラム切替時間8
  ,null as qbqd_dev_a_0428 -- QB、QDプログラム切替時間9
  ,null as qbqd_dev_a_0429 -- QB、QDプログラム最大ステップ数
  ,null as qbqd_dev_a_0430 -- QBプログラム電源
  ,null as qbqd_dev_a_0431 -- QDプログラム電源
  ,null as ihdf_dev_a_0432 -- I-HDFプログラム使用選択
  ,null as ihdf_dev_a_0433 -- 予定補液回数
  ,null as ihdf_dev_a_0434 -- 補液バランス制限
  ,null as ihdf_dev_a_0435 -- 補液量01
  ,null as ihdf_dev_a_0436 -- 補液量02
  ,null as ihdf_dev_a_0437 -- 補液量03
  ,null as ihdf_dev_a_0438 -- 補液量04
  ,null as ihdf_dev_a_0439 -- 補液量05
  ,null as ihdf_dev_a_0440 -- 補液量06
  ,null as ihdf_dev_a_0441 -- 補液量07
  ,null as ihdf_dev_a_0442 -- 補液量08
  ,null as ihdf_dev_a_0443 -- 補液量09
  ,null as ihdf_dev_a_0444 -- 補液量10
  ,null as ihdf_dev_a_0445 -- 補液量11
  ,null as ihdf_dev_a_0446 -- 補液量12
  ,null as ihdf_dev_a_0447 -- 補液量13
  ,null as ihdf_dev_a_0448 -- 補液量14
  ,null as ihdf_dev_a_0449 -- 補液量15
  ,null as ihdf_dev_a_0450 -- 補液量16
  ,null as ihdf_dev_a_0451 -- 回収量01
  ,null as ihdf_dev_a_0452 -- 回収量02
  ,null as ihdf_dev_a_0453 -- 回収量03
  ,null as ihdf_dev_a_0454 -- 回収量04
  ,null as ihdf_dev_a_0455 -- 回収量05
  ,null as ihdf_dev_a_0456 -- 回収量06
  ,null as ihdf_dev_a_0457 -- 回収量07
  ,null as ihdf_dev_a_0458 -- 回収量08
  ,null as ihdf_dev_a_0459 -- 回収量09
  ,null as ihdf_dev_a_0460 -- 回収量10
  ,null as ihdf_dev_a_0461 -- 回収量11
  ,null as ihdf_dev_a_0462 -- 回収量12
  ,null as ihdf_dev_a_0463 -- 回収量13
  ,null as ihdf_dev_a_0464 -- 回収量14
  ,null as ihdf_dev_a_0465 -- 回収量15
  ,null as ihdf_dev_a_0466 -- 回収量16
from
  ord_main
  inner join latest_otc on ord_main.ord_no = latest_otc.ord_no
  cross join dialyzer_record
where ord_main.ord_no = @ordNo and ord_main.is_del = ''0''
 and ord_main.rst_dialysis_state >''0'' and ord_main.rst_dialysis_state <''6''

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
	', 2, '[{"preview": "220", "can_calc": "1", "data_code": "ope_dev_a_0179", "data_name": "血流量設定最大値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0179", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4.00", "can_calc": "1", "data_code": "ope_dev_a_0181", "data_name": "除水速度制限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0181", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "ope_dev_a_0038", "data_name": "動脈側気泡検出器", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用する", "item": "使用する"}, {"code": "1", "disp": "使用しない", "item": "使用しない"}], "data_class": "装置設定", "field_name": "ope_dev_a_0038", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析時間", "can_calc": "0", "data_code": "ope_dev_a_0021", "data_name": "除水計算時間", "data_type": "string", "conv_table": [{"code": "0", "disp": "透析時間", "item": "透析時間"}, {"code": "1", "disp": "設定時間", "item": "設定時間"}], "data_class": "装置設定", "field_name": "ope_dev_a_0021", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "除水速度算出", "can_calc": "0", "data_code": "ope_dev_a_0022", "data_name": "除水計算優先項目", "data_type": "string", "conv_table": [{"code": "0", "disp": "除水速度算出", "item": "除水速度算出"}, {"code": "1", "disp": "除水量設定算出", "item": "除水量設定算出"}], "data_class": "装置設定", "field_name": "ope_dev_a_0022", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "ope_dev_a_0039", "data_name": "除水開始遅延時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0039", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "40.0", "can_calc": "1", "data_code": "ope_dev_a_0182", "data_name": "透析液温度操作範囲上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0182", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "33.0", "can_calc": "1", "data_code": "ope_dev_a_0183", "data_name": "透析液温度操作範囲下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0183", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "ope_dev_a_0024", "data_name": "シングルニードル切替圧上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0024", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "ope_dev_a_0025", "data_name": "シングルニードル切替圧下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0025", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "あり", "can_calc": "0", "data_code": "ope_dev_a_0241", "data_name": "TMPゼロ補正", "data_type": "string", "conv_table": [{"code": "0", "disp": "あり", "item": "あり"}, {"code": "1", "disp": "なし", "item": "なし"}], "data_class": "装置設定", "field_name": "ope_dev_a_0241", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0168", "data_name": "HD補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0168", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0169", "data_name": "HD補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0169", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0171", "data_name": "ECUM補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0171", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0172", "data_name": "ECUM補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0172", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0174", "data_name": "HDF補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0174", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0175", "data_name": "HDF補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0175", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0177", "data_name": "HF補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0177", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0178", "data_name": "HF補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0178", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_b_0037", "data_name": "HD+補液補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0037", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_b_0038", "data_name": "HD+補液補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0038", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0391", "data_name": "OHDF補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0391", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0392", "data_name": "OHDF補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0392", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0394", "data_name": "OHF補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0394", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0395", "data_name": "OHF補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0395", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4.0", "can_calc": "1", "data_code": "ope_dev_a_0383", "data_name": "補液量制限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0383", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "補液速度算出", "can_calc": "0", "data_code": "ope_dev_a_0389", "data_name": "補液計算優先項目", "data_type": "string", "conv_table": [{"code": "0", "disp": "補液速度算出", "item": "補液速度算出"}, {"code": "1", "disp": "補液量設定算出", "item": "補液量設定算出"}, {"code": "2", "disp": "補液比率", "item": "補液比率"}, {"code": "3", "disp": "濾過率から算出", "item": "濾過率から算出"}], "data_class": "装置設定", "field_name": "ope_dev_a_0389", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "1", "data_code": "ope_dev_a_0379", "data_name": "補液比率（前補液）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0379", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "1", "data_code": "ope_dev_b_0039", "data_name": "補液比率（後補液）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0039", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ope_dev_a_0398", "data_name": "補液開始遅延時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0398", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "ope_dev_a_0369", "data_name": "DP=Qd+Qs(補液速度加算)", "data_type": "string", "conv_table": [{"code": "1", "disp": "使用しない", "item": "使用しない"}, {"code": "2", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "ope_dev_a_0369", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "52", "can_calc": "1", "data_code": "ope_dev_a_0090", "data_name": "濾過率（前補液）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0090", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "42", "can_calc": "1", "data_code": "ope_dev_b_0040", "data_name": "濾過率（後補液）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0040", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "35", "can_calc": "1", "data_code": "ope_dev_a_0091", "data_name": "ヘマトクリット（Ht）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0091", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.7", "can_calc": "1", "data_code": "ope_dev_a_0092", "data_name": "総タンパク（TP）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0092", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "ope_dev_a_0336", "data_name": "緊急補液速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0336", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "ope_dev_a_0337", "data_name": "緊急補液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0337", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_a_0185", "data_name": "HDF速度操作範囲上限前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0185", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_b_0031", "data_name": "HDF速度操作範囲上限後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0031", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_a_0186", "data_name": "HF速度操作範囲上限前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0186", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_b_0032", "data_name": "HF速度操作範囲上限後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0032", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12.00", "can_calc": "1", "data_code": "ope_dev_b_0030", "data_name": "HD+補液速度操作範囲上限前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0030", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_b_0033", "data_name": "HD+補液速度操作範囲上限後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0033", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12.00", "can_calc": "1", "data_code": "ope_dev_a_0396", "data_name": "OHDF速度操作範囲上限前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0396", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_b_0034", "data_name": "OHDF速度操作範囲上限後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0034", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12.00", "can_calc": "1", "data_code": "ope_dev_a_0397", "data_name": "OHF速度操作範囲上限前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0397", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_b_0035", "data_name": "OHF速度操作範囲上限後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0035", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "ope_dev_a_0384", "data_name": "AFBF補液比率使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "ope_dev_a_0384", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13.00", "can_calc": "1", "data_code": "ope_dev_a_0385", "data_name": "AFBF補液比率", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0385", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.50", "can_calc": "1", "data_code": "ope_dev_a_0386", "data_name": "AFBF速度操作範囲上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0386", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.00", "can_calc": "1", "data_code": "ope_dev_a_0387", "data_name": "AFBF速度操作範囲下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0387", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "ihdf_dev_a_0200", "data_name": "I-HDF_補液量設定", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0200", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "ihdf_dev_a_0201", "data_name": "I-HDF_補液速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0201", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "1", "data_code": "ihdf_dev_a_0202", "data_name": "I-HDF_補液周期", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0202", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "1", "data_code": "ihdf_dev_a_0203", "data_name": "I-HDF_補液開始時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0203", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0204", "data_name": "I-HDF_除水再開時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0204", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.50", "can_calc": "1", "data_code": "ihdf_dev_a_0205", "data_name": "I-HDF_総補液量上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0205", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析液圧", "can_calc": "0", "data_code": "war_dev_a_0240", "data_name": "TMP監視モード", "data_type": "string", "conv_table": [{"code": "0", "disp": "TMP自動追従", "item": "TMP自動追従"}, {"code": "1", "disp": "TMP自動設定", "item": "TMP自動設定"}, {"code": "2", "disp": "透析液圧", "item": "透析液圧"}], "data_class": "装置設定", "field_name": "war_dev_a_0240", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0100", "data_name": "HD/ECUM静脈圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0100", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-30", "can_calc": "1", "data_code": "war_dev_a_0101", "data_name": "HD/ECUM静脈圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0101", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0102", "data_name": "HD/ECUM静脈圧自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0102", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "war_dev_a_0103", "data_name": "HD/ECUM静脈圧自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0103", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0104", "data_name": "HD/ECUM静脈圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0104", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0105", "data_name": "HD/ECUM静脈圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0105", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0152", "data_name": "HD/ECUMダイアライザ入口圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0152", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0153", "data_name": "HD/ECUMダイアライザ入口圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0153", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0154", "data_name": "HD/ECUMダイアライザ入口圧自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0154", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "war_dev_a_0155", "data_name": "HD/ECUMダイアライザ入口圧自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0155", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0156", "data_name": "HD/ECUMダイアライザ入口圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0156", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0157", "data_name": "HD/ECUMダイアライザ入口圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0157", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0112", "data_name": "HD/ECUM液圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0112", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0113", "data_name": "HD/ECUM液圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0113", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0114", "data_name": "HD/ECUM液圧自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0114", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-300", "can_calc": "1", "data_code": "war_dev_a_0115", "data_name": "HD/ECUM液圧自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0115", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0116", "data_name": "HD/ECUM液圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0116", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-300", "can_calc": "1", "data_code": "war_dev_a_0117", "data_name": "HD/ECUM液圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0117", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0128", "data_name": "HD/ECUMTMP自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0128", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0129", "data_name": "HD/ECUMTMP自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0129", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "war_dev_a_0130", "data_name": "HD/ECUMTMP自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0130", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-30", "can_calc": "1", "data_code": "war_dev_a_0131", "data_name": "HD/ECUMTMP自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0131", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "war_dev_a_0132", "data_name": "HD/ECUMTMP固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0132", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-30", "can_calc": "1", "data_code": "war_dev_a_0133", "data_name": "HD/ECUMTMP固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0133", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "1", "data_code": "war_dev_a_0126", "data_name": "HD/ECUMTMP自動追従警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0126", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-20", "can_calc": "1", "data_code": "war_dev_a_0127", "data_name": "HD/ECUMTMP自動追従警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0127", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "1", "data_code": "war_dev_a_0146", "data_name": "HD/ECUMダイアライザ差圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0146", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-20", "can_calc": "1", "data_code": "war_dev_a_0147", "data_name": "HD/ECUMダイアライザ差圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0147", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "80", "can_calc": "1", "data_code": "war_dev_a_0148", "data_name": "HD/ECUMダイアライザ差圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0148", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "war_dev_a_0149", "data_name": "HD/ECUMダイアライザ差圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0149", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0106", "data_name": "HDF/HF静脈圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0106", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0107", "data_name": "HDF/HF静脈圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0107", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0158", "data_name": "HDF/HFダイアライザ入口圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0158", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0159", "data_name": "HDF/HFダイアライザ入口圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0159", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0118", "data_name": "HDF/HF液圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0118", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0119", "data_name": "HDF/HF液圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0119", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0136", "data_name": "HDF/HFTMP自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0136", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0137", "data_name": "HDF/HFTMP自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0137", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0134", "data_name": "HDF/HFTMP自動追従警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0134", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0135", "data_name": "HDF/HFTMP自動追従警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0135", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0150", "data_name": "HDF/HFダイアライザ差圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0150", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0151", "data_name": "HDF/HFダイアライザ差圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0151", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "400", "can_calc": "1", "data_code": "war_dev_a_0110", "data_name": "SN静脈圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0110", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0111", "data_name": "SN静脈圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0111", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5000", "can_calc": "1", "data_code": "war_dev_a_0162", "data_name": "SNダイアライザ入口圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0162", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0163", "data_name": "SNダイアライザ入口圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0163", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0120", "data_name": "SN液圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0120", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0121", "data_name": "SN液圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0121", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0122", "data_name": "SN液圧自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0122", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-300", "can_calc": "1", "data_code": "war_dev_a_0123", "data_name": "SN液圧自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0123", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0124", "data_name": "SN液圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0124", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-300", "can_calc": "1", "data_code": "war_dev_a_0125", "data_name": "SN液圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0125", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "war_dev_a_0140", "data_name": "SNTMP自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0140", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-30", "can_calc": "1", "data_code": "war_dev_a_0141", "data_name": "SNTMP自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0141", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "war_dev_a_0142", "data_name": "SNTMP自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0142", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-30", "can_calc": "1", "data_code": "war_dev_a_0143", "data_name": "SNTMP自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0143", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0144", "data_name": "SNTMP固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0144", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0145", "data_name": "SNTMP固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0145", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0138", "data_name": "SNTMP自動追従警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0138", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0139", "data_name": "SNTMP自動追従警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0139", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "400", "can_calc": "1", "data_code": "war_dev_a_0108", "data_name": "準備回収静脈圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0108", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-200", "can_calc": "1", "data_code": "war_dev_a_0109", "data_name": "準備回収静脈圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0109", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "war_dev_a_0160", "data_name": "準備回収ダイアライザ入口圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0160", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-200", "can_calc": "1", "data_code": "war_dev_a_0161", "data_name": "準備回収ダイアライザ入口圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0161", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "1", "data_code": "war_dev_a_0254", "data_name": "Na濃度自動警報幅上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0254", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-5", "can_calc": "1", "data_code": "war_dev_a_0255", "data_name": "Na濃度自動警報幅下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0255", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "190", "can_calc": "1", "data_code": "war_dev_a_0256", "data_name": "Na濃度固定警報幅上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0256", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "war_dev_a_0257", "data_name": "Na濃度固定警報幅下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0257", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "bp_dev_a_0211", "data_name": "血圧警報点最高血圧上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0211", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "80", "can_calc": "1", "data_code": "bp_dev_a_0212", "data_name": "血圧警報点最高血圧下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0212", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "160", "can_calc": "1", "data_code": "bp_dev_a_0213", "data_name": "血圧警報点最低血圧上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0213", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "bp_dev_a_0214", "data_name": "血圧警報点最低血圧下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0214", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "180", "can_calc": "1", "data_code": "bp_dev_a_0215", "data_name": "血圧警報点平均血圧上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0215", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "bp_dev_a_0216", "data_name": "血圧警報点平均血圧下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0216", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "170", "can_calc": "1", "data_code": "bp_dev_a_0217", "data_name": "血圧警報点脈拍数上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0217", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "bp_dev_a_0218", "data_name": "血圧警報点脈拍数下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0218", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0219", "data_name": "最高血圧上限警報_血液ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0219", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "bp_dev_a_0227", "data_name": "最高血圧上限警報_血液ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0227", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0220", "data_name": "最高血圧下限警報_血液ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0220", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "bp_dev_a_0228", "data_name": "最高血圧下限警報_血液ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0228", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0221", "data_name": "最高血圧上限警報_除水ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0221", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.10", "can_calc": "1", "data_code": "bp_dev_a_0229", "data_name": "最高血圧上限警報_除水ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0229", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0222", "data_name": "最高血圧下限警報_除水ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0222", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.10", "can_calc": "1", "data_code": "bp_dev_a_0230", "data_name": "最高血圧下限警報_除水ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0230", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0223", "data_name": "最高血圧上限警報_Na注入ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0223", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.30", "can_calc": "1", "data_code": "bp_dev_a_0231", "data_name": "最高血圧上限警報_Na注入ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0231", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0224", "data_name": "最高血圧下限警報_Na注入ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0224", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.30", "can_calc": "1", "data_code": "bp_dev_a_0232", "data_name": "最高血圧下限警報_Na注入ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0232", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0225", "data_name": "最高血圧上限警報_補液ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0225", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "1", "data_code": "bp_dev_a_0233", "data_name": "最高血圧上限警報_補液ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0233", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0226", "data_name": "最高血圧下限警報_補液ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0226", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "1", "data_code": "bp_dev_a_0234", "data_name": "最高血圧下限警報_補液ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0234", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "成人", "can_calc": "0", "data_code": "bp_dev_a_0191", "data_name": "血圧カフ選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "成人", "item": "成人"}, {"code": "1", "disp": "幼児", "item": "幼児"}], "data_class": "装置設定", "field_name": "bp_dev_a_0191", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "1", "data_code": "bp_dev_a_0190", "data_name": "血圧自動測定間隔", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0190", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "180", "can_calc": "1", "data_code": "bp_dev_a_0192", "data_name": "昇圧値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0192", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "手動", "can_calc": "0", "data_code": "bp_dev_a_0193", "data_name": "昇圧方法選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "手動", "item": "手動"}, {"code": "1", "disp": "自動", "item": "自動"}, {"code": "2", "disp": "スマート昇圧", "item": "スマート昇圧"}], "data_class": "装置設定", "field_name": "bp_dev_a_0193", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "降圧設定", "can_calc": "0", "data_code": "bp_dev_a_0195", "data_name": "血圧測定方法選択", "data_type": "string", "conv_table": [{"code": "1", "disp": "降圧測定", "item": "降圧測定"}, {"code": "2", "disp": "昇圧測定", "item": "昇圧測定"}], "data_class": "装置設定", "field_name": "bp_dev_a_0195", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "なし", "can_calc": "0", "data_code": "bp_dev_a_0239", "data_name": "高速測定選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "なし", "item": "なし"}, {"code": "1", "disp": "あり", "item": "あり"}], "data_class": "装置設定", "field_name": "bp_dev_a_0239", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12分", "can_calc": "0", "data_code": "bp_dev_a_0194", "data_name": "血圧連続測定動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "12分", "item": "12分"}, {"code": "1", "disp": "5分", "item": "5分"}], "data_class": "装置設定", "field_name": "bp_dev_a_0194", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2:34", "can_calc": "0", "data_code": "bp_dev_a_0235", "data_name": "警報連動測定開始時間", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0235", "disp_format": "[h]:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3:45", "can_calc": "0", "data_code": "bp_dev_a_0236", "data_name": "治療条件連動測定時間", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0236", "disp_format": "[h]:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "継続", "can_calc": "0", "data_code": "bp_dev_a_0237", "data_name": "静脈圧警報発生時の血圧測定", "data_type": "string", "conv_table": [{"code": "0", "disp": "継続", "item": "継続"}, {"code": "1", "disp": "中断・終了", "item": "中断・終了"}], "data_class": "装置設定", "field_name": "bp_dev_a_0237", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "継続", "can_calc": "0", "data_code": "bp_dev_a_0238", "data_name": "血流量または除水速度変更時の血圧測定", "data_type": "string", "conv_table": [{"code": "0", "disp": "継続", "item": "継続"}, {"code": "1", "disp": "中断・終了", "item": "中断・終了"}], "data_class": "装置設定", "field_name": "bp_dev_a_0238", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "する", "can_calc": "0", "data_code": "bv_dev_a_0267", "data_name": "BV計使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "装置設定", "field_name": "bv_dev_a_0267", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-20.0", "can_calc": "1", "data_code": "bv_dev_a_0260", "data_name": "⊿BV低下警報点1", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0260", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-40.0", "can_calc": "1", "data_code": "bv_dev_a_0261", "data_name": "⊿BV低下警報点2", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0261", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-10.0", "can_calc": "1", "data_code": "bv_dev_a_0262", "data_name": "⊿BV変化率警報点", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0262", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "1", "data_code": "bv_dev_a_0277", "data_name": "⊿BV除水低下速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0277", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "1", "data_code": "bv_dev_a_0278", "data_name": "⊿BV除水低下遅延時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0278", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "する", "can_calc": "0", "data_code": "bv_dev_a_0258", "data_name": "アクセス再循環測定使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "装置設定", "field_name": "bv_dev_a_0258", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:01", "can_calc": "1", "data_code": "bv_dev_a_0259", "data_name": "アクセス再循環自動測定1", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0259", "disp_format": "HH:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:02", "can_calc": "1", "data_code": "bv_dev_a_0263", "data_name": "アクセス再循環自動測定2", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0263", "disp_format": "HH:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:03", "can_calc": "1", "data_code": "bv_dev_a_0264", "data_name": "アクセス再循環自動測定3", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0264", "disp_format": "HH:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:04", "can_calc": "1", "data_code": "bv_dev_a_0265", "data_name": "アクセス再循環自動測定4", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0265", "disp_format": "HH:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:05", "can_calc": "1", "data_code": "bv_dev_a_0266", "data_name": "アクセス再循環自動測定5", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0266", "disp_format": "HH:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "dfas_dev_a_0270", "data_name": "動脈側返血使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "dfas_dev_a_0270", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "1", "data_code": "bv_dev_a_0281", "data_name": "アクセス再循環再循環率報知", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0281", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "pri_pat_a_0219", "data_name": "プライミング補助動脈充填液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0219", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "pri_pat_a_0220", "data_name": "プライミング補助動脈充填流速", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0220", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "しない", "can_calc": "0", "data_code": "pri_pat_a_0225", "data_name": "プライミング補助動脈充填後継続の有無", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "装置設定", "field_name": "pri_pat_a_0225", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "pri_pat_a_0221", "data_name": "プライミング補助静脈充填液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0221", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "pri_pat_a_0222", "data_name": "プライミング補助静脈充填流速", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0222", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "しない", "can_calc": "0", "data_code": "pri_pat_a_0226", "data_name": "プライミング補助静脈充填後継続の有無", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "装置設定", "field_name": "pri_pat_a_0226", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "400", "can_calc": "1", "data_code": "pri_pat_a_0223", "data_name": "プライミング補助気泡抜き液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0223", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "pri_pat_a_0224", "data_name": "プライミング補助気泡抜き流速", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0224", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "連続", "can_calc": "0", "data_code": "pri_pat_a_0227", "data_name": "プライミング補助気泡抜き間欠動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "連続", "item": "連続"}, {"code": "1", "disp": "間欠", "item": "間欠"}], "data_class": "装置設定", "field_name": "pri_pat_a_0227", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "800", "can_calc": "1", "data_code": "pri_pat_a_0228", "data_name": "プライミング補助液交換量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0228", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.0", "can_calc": "1", "data_code": "pri_pat_a_0229", "data_name": "プライミング補助間欠動作動作時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0229", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.0", "can_calc": "1", "data_code": "pri_pat_a_0230", "data_name": "プライミング補助間欠動作停止時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0230", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "40", "can_calc": "1", "data_code": "pri_pat_a_0232", "data_name": "自動プライミング落差時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0232", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "pri_pat_a_0238", "data_name": "自動プライミング総量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0238", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "420", "can_calc": "1", "data_code": "pri_pat_a_0231", "data_name": "自動プライミング開始時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0231", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "250", "can_calc": "1", "data_code": "pri_pat_a_0233", "data_name": "自動プライミング送液液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0233", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "250", "can_calc": "1", "data_code": "pri_pat_a_0234", "data_name": "自動プライミング送液流速1回目", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0234", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "250", "can_calc": "1", "data_code": "pri_pat_a_0235", "data_name": "自動プライミング送液流速2回目以降", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0235", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "400", "can_calc": "1", "data_code": "pri_pat_a_0236", "data_name": "自動プライミング循環流速", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0236", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "pri_pat_a_0237", "data_name": "自動プライミング循環時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0237", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "pri_dev_a_0370", "data_name": "自動回収_使用液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_dev_a_0370", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "pri_dev_a_0371", "data_name": "自動回収_流速", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_dev_a_0371", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "OFF", "can_calc": "0", "data_code": "pri_dev_a_0372", "data_name": "自動回収_血液判別器による終了選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "OFF", "item": "OFF"}, {"code": "1", "disp": "ON", "item": "ON"}], "data_class": "装置設定", "field_name": "pri_dev_a_0372", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2", "can_calc": "1", "data_code": "pri_pat_b_0051", "data_name": "オンラインプライミング_ダイアライザ気泡抜き時間_後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_b_0051", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "90", "can_calc": "1", "data_code": "pri_pat_b_0032", "data_name": "オンラインプライミング_動脈チャンバ液面作成時間_前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_b_0032", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "pri_pat_b_0052", "data_name": "オンラインプライミング_動脈チャンバ液面作成時間_後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_b_0052", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3", "can_calc": "1", "data_code": "pri_pat_b_0033", "data_name": "オンラインプライミング_循環洗浄時間_前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_b_0033", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3", "can_calc": "1", "data_code": "pri_pat_b_0053", "data_name": "オンラインプライミング_循環洗浄時間_後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_b_0053", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切り", "can_calc": "0", "data_code": "ufr_dev_a_0290", "data_name": "UFRプログラム使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "切り", "item": "切り"}, {"code": "1", "disp": "入り[ステップ]", "item": "入り[ステップ]"}, {"code": "2", "disp": "入り[コース]", "item": "入り[コース]"}], "data_class": "装置設定", "field_name": "ufr_dev_a_0290", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切り", "can_calc": "0", "data_code": "na_dev_a_0315", "data_name": "Na注入プログラム使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "切り", "item": "切り"}, {"code": "1", "disp": "入り[ステップ]", "item": "入り[ステップ]"}, {"code": "2", "disp": "入り[コース]", "item": "入り[コース]"}], "data_class": "装置設定", "field_name": "na_dev_a_0315", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "na_dev_a_0184", "data_name": "Na注入濃度最大値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "na_dev_a_0184", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切り", "can_calc": "0", "data_code": "dc_dev_a_0340", "data_name": "透析液濃度プログラム使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "切り", "item": "切り"}, {"code": "1", "disp": "入り[B,A共通ステップ]", "item": "入り[B,A共通ステップ]"}, {"code": "2", "disp": "入り[B,A別ステップ]", "item": "入り[B,A別ステップ]"}, {"code": "3", "disp": "入り[B,A別コース]", "item": "入り[B,A別コース]"}], "data_class": "装置設定", "field_name": "dc_dev_a_0340", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "HD", "can_calc": "0", "data_code": "ecum_dev_a_0016", "data_name": "ECUM選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "HD", "item": "HD"}, {"code": "1", "disp": "ECUM", "item": "ECUM"}], "data_class": "装置設定", "field_name": "ecum_dev_a_0016", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "1", "data_code": "ecum_dev_a_0017", "data_name": "ECUM量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ecum_dev_a_0017", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "07:59", "can_calc": "1", "data_code": "ecum_dev_a_0018", "data_name": "ECUM時間", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "ecum_dev_a_0018", "disp_format": "HH:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "HD", "can_calc": "0", "data_code": "ecum_dev_a_0019", "data_name": "ECUM時間カウント選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "透析時間に含まない", "item": "透析時間に含まない"}, {"code": "1", "disp": "透析時間に含む", "item": "透析時間に含む"}], "data_class": "装置設定", "field_name": "ecum_dev_a_0019", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.0", "can_calc": "1", "data_code": "cpro_dev_a_0252", "data_name": "Ｂ液濃度プログラム自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "cpro_dev_a_0252", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-5.0", "can_calc": "1", "data_code": "cpro_dev_a_0253", "data_name": "Ｂ液濃度プログラム自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "cpro_dev_a_0253", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.0", "can_calc": "1", "data_code": "cpro_dev_a_0250", "data_name": "透析液濃度プログラム自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "cpro_dev_a_0250", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-5.0", "can_calc": "1", "data_code": "cpro_dev_a_0251", "data_name": "透析液濃度プログラム自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "cpro_dev_a_0251", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "dfas_pat_b_0001", "data_name": "IPラインプライミング使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "dfas_pat_b_0001", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "1", "data_code": "gas_purge_time", "data_name": "ガスパージ時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "gas_purge_time", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1000", "can_calc": "1", "data_code": "substituent_wash_amt", "data_name": "置換洗浄量（透析液）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "substituent_wash_amt", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "membrane_wash", "data_name": "膜洗浄（中空糸）", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "membrane_wash", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "dfas_pat_b_0005", "data_name": "中空糸_プライミング時のBP速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0005", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "dfas_pat_b_0007", "data_name": "中空糸_送液最大時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0007", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "dfas_pat_b_0008", "data_name": "中空糸_回路内洗浄送液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0008", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "dfas_pat_b_0009", "data_name": "中空糸_気泡抜き動作実行回数", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0009", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "150", "can_calc": "1", "data_code": "dfas_pat_b_0010", "data_name": "中空糸_気泡抜き圧力上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0010", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "150", "can_calc": "1", "data_code": "dfas_pat_b_0059", "data_name": "積層_プライミング時のBP速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0059", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "dfas_pat_b_0054", "data_name": "積層_送液最大時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0054", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "dfas_pat_b_0055", "data_name": "積層_回路内洗浄送液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0055", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "dfas_pat_b_0056", "data_name": "積層_気泡抜き動作実行回数", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0056", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "150", "can_calc": "1", "data_code": "dfas_pat_b_0057", "data_name": "積層_気泡抜き圧力上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0057", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.20", "can_calc": "1", "data_code": "dfas_pat_b_0058", "data_name": "積層_除水ポンプ速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0058", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "片側脱血（除水なし）", "can_calc": "0", "data_code": "dfas_dev_a_0339", "data_name": "脱血方法選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "同時脱血", "item": "同時脱血"}, {"code": "1", "disp": "片側脱血（除水あり）", "item": "片側脱血（除水あり）"}, {"code": "2", "disp": "片側脱血（除水なし）", "item": "片側脱血（除水なし）"}], "data_class": "装置設定", "field_name": "dfas_dev_a_0339", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "dfas_dev_a_0333", "data_name": "脱血速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0333", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "150", "can_calc": "1", "data_code": "dfas_dev_a_0331", "data_name": "同時脱血_脱血量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0331", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "150", "can_calc": "1", "data_code": "dfas_dev_a_0334", "data_name": "片側脱血(除水なし)_脱血量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0334", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "dfas_dev_a_0338", "data_name": "片側脱血（除水あり）_脱血量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0338", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-200", "can_calc": "1", "data_code": "dfas_dev_a_0332", "data_name": "片側脱血への切替え透析液圧", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0332", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "ord_treat_condition_335", "data_name": "治療開始時_血液ポンプ速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_335", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "dfas_dev_a_0373", "data_name": "静脈側返血速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0373", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "250", "can_calc": "1", "data_code": "dfas_dev_a_0374", "data_name": "静脈側最大返血量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0374", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "dfas_dev_a_0377", "data_name": "静脈側返血_血液判別器使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "dfas_dev_a_0377", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "1", "data_code": "dfas_dev_a_0376", "data_name": "動脈側最大返血量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0376", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "dfas_dev_a_0378", "data_name": "動脈側返血_血液判別器使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "dfas_dev_a_0378", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "dia_dev_a_0282", "data_name": "透析量プログラム使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "dia_dev_a_0282", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "57.90", "can_calc": "1", "data_code": "ord_treat_condition_283", "data_name": "体液量計算時後体重", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_283", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.00", "can_calc": "1", "data_code": "ord_treat_condition_284", "data_name": "体液量+補正値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_284", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "1", "data_code": "ord_treat_condition_285", "data_name": "目標後体重", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_285", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "ord_treat_condition_286", "data_name": "標準血流量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_286", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "ord_treat_condition_287", "data_name": "KoA", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_287", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.1", "can_calc": "1", "data_code": "dia_dev_a_0288", "data_name": "目標Kt/V", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dia_dev_a_0288", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "190", "can_calc": "1", "data_code": "ord_treat_condition_187", "data_name": "ダイアライザ 尿素クリアランス", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_187", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "ord_treat_condition_188", "data_name": "ダイアライザ 血流量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_188", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "ord_treat_condition_189", "data_name": "ダイアライザ 透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_189", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "bvufc_dev_a_0196", "data_name": "BV-UFC使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "bvufc_dev_a_0196", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.00", "can_calc": "1", "data_code": "bvufc_dev_a_0197", "data_name": "UFC期間除水速度上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0197", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "1", "data_code": "bvufc_dev_a_0198", "data_name": "UFC期間除水速度下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0198", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "bvufc_dev_a_0199", "data_name": "開始期間 時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0199", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.00", "can_calc": "1", "data_code": "bvufc_dev_a_0206", "data_name": "開始期間 除水速度倍率", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0206", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "bvufc_dev_a_0207", "data_name": "固定倍率除水期間 時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0207", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.30", "can_calc": "1", "data_code": "bvufc_dev_a_0208", "data_name": "固定倍率除水期間 除水速度倍率", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0208", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "bvufc_dev_a_0209", "data_name": "固定倍率除水終了条件　最高血圧", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0209", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "bvufc_dev_a_0210", "data_name": "固定倍率除水終了条件　脈拍", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0210", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "1", "data_code": "bvufc_dev_a_0248", "data_name": "固定倍率除水終了条件　ΔBV", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0248", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "1", "data_code": "bvufc_dev_a_0249", "data_name": "終了前期間 時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0249", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "流量設定", "can_calc": "0", "data_code": "ope_dev_a_0268", "data_name": "透析液流量　設定方法", "data_type": "string", "conv_table": [{"code": "1", "disp": "流量設定", "item": "流量設定"}, {"code": "2", "disp": "比率設定", "item": "比率設定"}], "data_class": "装置設定", "field_name": "ope_dev_a_0268", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.0", "can_calc": "1", "data_code": "ope_dev_a_0269", "data_name": "透析液流量　比率設定", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0269", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "1", "data_code": "bvufc_dev_a_0271", "data_name": "開始時ΔBV基準値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0271", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "bvufc_dev_a_0272", "data_name": "ΔBV基準線　指数1", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0272", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "80", "can_calc": "1", "data_code": "bvufc_dev_a_0273", "data_name": "ΔBV基準線　指数2", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0273", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "95", "can_calc": "1", "data_code": "bvufc_dev_a_0274", "data_name": "ΔBV基準線　指数3", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0274", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-4.0", "can_calc": "1", "data_code": "bvufc_dev_a_0275", "data_name": "終了時ΔBV基準値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0275", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "qbqd_dev_a_0400", "data_name": "QBプログラム血流量1", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0400", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "160", "can_calc": "1", "data_code": "qbqd_dev_a_0401", "data_name": "QBプログラム血流量2", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0401", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0402", "data_name": "QBプログラム血流量3", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0402", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0403", "data_name": "QBプログラム血流量4", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0403", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0404", "data_name": "QBプログラム血流量5", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0404", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0405", "data_name": "QBプログラム血流量6", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0405", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0406", "data_name": "QBプログラム血流量7", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0406", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0407", "data_name": "QBプログラム血流量8", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0407", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0408", "data_name": "QBプログラム血流量9", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0408", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0409", "data_name": "QBプログラム血流量10", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0409", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "qbqd_dev_a_0410", "data_name": "QDプログラム透析液流量1", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0410", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "400", "can_calc": "1", "data_code": "qbqd_dev_a_0411", "data_name": "QDプログラム透析液流量2", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0411", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0412", "data_name": "QDプログラム透析液流量3", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0412", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0413", "data_name": "QDプログラム透析液流量4", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0413", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0414", "data_name": "QDプログラム透析液流量5", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0414", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0415", "data_name": "QDプログラム透析液流量6", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0415", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0416", "data_name": "QDプログラム透析液流量7", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0416", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0417", "data_name": "QDプログラム透析液流量8", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0417", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0418", "data_name": "QDプログラム透析液流量9", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0418", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0419", "data_name": "QDプログラム透析液流量10", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0419", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0420", "data_name": "QB、QDプログラム切替時間1", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0420", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0421", "data_name": "QB、QDプログラム切替時間2", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0421", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0422", "data_name": "QB、QDプログラム切替時間3", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0422", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0423", "data_name": "QB、QDプログラム切替時間4", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0423", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0424", "data_name": "QB、QDプログラム切替時間5", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0424", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0425", "data_name": "QB、QDプログラム切替時間6", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0425", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0426", "data_name": "QB、QDプログラム切替時間7", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0426", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0427", "data_name": "QB、QDプログラム切替時間8", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0427", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0428", "data_name": "QB、QDプログラム切替時間9", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0428", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3", "can_calc": "1", "data_code": "qbqd_dev_a_0429", "data_name": "QB、QDプログラム最大ステップ数", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0429", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切", "can_calc": "0", "data_code": "qbqd_dev_a_0430", "data_name": "QBプログラム電源", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "装置設定", "field_name": "qbqd_dev_a_0430", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切", "can_calc": "0", "data_code": "qbqd_dev_a_0431", "data_name": "QDプログラム電源", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "装置設定", "field_name": "qbqd_dev_a_0431", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "ihdf_dev_a_0432", "data_name": "I-HDFプログラム使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "ihdf_dev_a_0432", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7", "can_calc": "1", "data_code": "ihdf_dev_a_0433", "data_name": "予定補液回数", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0433", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0434", "data_name": "補液バランス制限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0434", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0435", "data_name": "補液量01", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0435", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0436", "data_name": "補液量02", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0436", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0437", "data_name": "補液量03", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0437", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0438", "data_name": "補液量04", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0438", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0439", "data_name": "補液量05", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0439", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0440", "data_name": "補液量06", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0440", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0441", "data_name": "補液量07", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0441", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0442", "data_name": "補液量08", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0442", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0443", "data_name": "補液量09", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0443", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0444", "data_name": "補液量10", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0444", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0445", "data_name": "補液量11", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0445", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0446", "data_name": "補液量12", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0446", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0447", "data_name": "補液量13", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0447", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0448", "data_name": "補液量14", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0448", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0449", "data_name": "補液量15", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0449", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0450", "data_name": "補液量16", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0450", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0451", "data_name": "回収量01", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0451", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0452", "data_name": "回収量02", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0452", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0453", "data_name": "回収量03", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0453", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0454", "data_name": "回収量04", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0454", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0455", "data_name": "回収量05", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0455", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0456", "data_name": "回収量06", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0456", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0457", "data_name": "回収量07", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0457", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0458", "data_name": "回収量08", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0458", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0459", "data_name": "回収量09", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0459", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0460", "data_name": "回収量10", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0460", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0461", "data_name": "回収量11", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0461", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0462", "data_name": "回収量12", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0462", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0463", "data_name": "回収量13", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0463", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0464", "data_name": "回収量14", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0464", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0465", "data_name": "回収量15", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0465", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0466", "data_name": "回収量16", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0466", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": []}', '実績（治療中）：装置設定 @ordNo 使用', '2005-08-01 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (171, 'select
  @ordNo AS ord_no,
  occur_date
  ,to_number(monitor_data->>''90'', ''999'') as bp_high
  ,to_number(monitor_data->>''91'', ''999'') as bp_low
  ,to_number(monitor_data->>''92'', ''999'') as bp_ave
  ,to_number(monitor_data->>''93'', ''999'') as pulse
  ,to_number(monitor_data->>''94'', ''999'') as body_temperature
  ,to_number(monitor_data->>''-1'', ''999'') as blood_glucose_level
from
  mni_monitor
where
  ord_no = @ordNo and data_type in (0, 2, 4) and is_del = ''0''
	ORDER BY occur_date DESC
;', 2, '[{"preview": "130", "can_calc": "0", "data_code": "bp_high", "data_name": "最高血圧", "data_type": "decimal", "conv_table": [], "data_class": "バイタル情報", "field_name": "bp_high", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "88", "can_calc": "0", "data_code": "bp_low", "data_name": "最低血圧", "data_type": "decimal", "conv_table": [], "data_class": "バイタル情報", "field_name": "bp_low", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "bp_ave", "data_name": "平均血圧", "data_type": "decimal", "conv_table": [], "data_class": "バイタル情報", "field_name": "bp_ave", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:02", "can_calc": "0", "data_code": "occur_date", "data_name": "測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "バイタル情報", "field_name": "occur_date", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "66", "can_calc": "0", "data_code": "pulse", "data_name": "脈拍", "data_type": "decimal", "conv_table": [], "data_class": "バイタル情報", "field_name": "pulse", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.4", "can_calc": "0", "data_code": "body_temperature", "data_name": "体温", "data_type": "decimal", "conv_table": [], "data_class": "バイタル情報", "field_name": "body_temperature", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "110.0", "can_calc": "0", "data_code": "blood_glucose_level", "data_name": "血糖値", "data_type": "decimal", "conv_table": [], "data_class": "バイタル情報", "field_name": "blood_glucose_level", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": []}', '実績（治療中）：バイタル情報 @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (172, 'WITH DATA AS (

with hist_ord_nos as (
  select
    ord_main.ord_no
    ,ord_main.rst_start_date
  from
    ord_main
  where
    ord_main.pat_id = (select pat_id from ord_main where ord_no = @ordNo and is_del = ''0'' and rst_dialysis_state > ''0'' and rst_dialysis_state < ''6'')
    and rst_dialysis_state > ''4''
    and ord_main.ord_no <> @ordNo
    and rst_start_date <= (select rst_start_date from ord_main where ord_no = @ordNo and is_del = ''0'' and rst_dialysis_state >''0'' and rst_dialysis_state < ''6'' and rst_dialysis_state < ''6'')
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
  ord_array_tbl

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
  b.ord_no as ordnob,
	b.treat_date as treat_date,
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
  ', 2, '[{"preview": "140", "can_calc": "1", "data_code": "before_bp_high_prev", "data_name": "前血圧（最高）(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_high_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "before_bp_low_prev", "data_name": "前血圧（最低）(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_low_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "before_bp_ave_prev", "data_name": "前血圧（平均）(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_ave_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "before_pulse_prev", "data_name": "前脈拍(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_pulse_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120/80/100(72)", "can_calc": "0", "data_code": "before_bp_summary_prev", "data_name": "前血圧（最高/最低/平均(脈拍)）(前回)", "data_type": "string", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_summary_prev", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:10", "can_calc": "0", "data_code": "before_vital_measure_date_prev", "data_name": "前血圧測定日時(前回)", "data_type": "DateTime", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_vital_measure_date_prev", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "after_bp_high_prev", "data_name": "後血圧（最高）(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_high_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "82", "can_calc": "1", "data_code": "after_bp_low_prev", "data_name": "後血圧（最低）(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_low_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "101", "can_calc": "1", "data_code": "after_bp_ave_prev", "data_name": "後血圧（平均）(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_ave_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "76", "can_calc": "1", "data_code": "after_pulse_prev", "data_name": "後脈拍(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_pulse_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120/80/100(72)", "can_calc": "0", "data_code": "after_bp_summary_prev", "data_name": "後血圧（最高/最低/平均(脈拍)）(前回)", "data_type": "string", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_summary_prev", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:53", "can_calc": "0", "data_code": "after_vital_measure_date_prev", "data_name": "後血圧測定日時(前回)", "data_type": "DateTime", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_vital_measure_date_prev", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "140", "can_calc": "1", "data_code": "before_bp_high_prev_prev", "data_name": "前血圧（最高）(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_high_prev_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "before_bp_low_prev_prev", "data_name": "前血圧（最低）(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_low_prev_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "before_bp_ave_prev_prev", "data_name": "前血圧（平均）(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_ave_prev_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "before_pulse_prev_prev", "data_name": "前脈拍(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_pulse_prev_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120/80/100(72)", "can_calc": "0", "data_code": "before_bp_summary_prev_prev", "data_name": "前血圧（最高/最低/平均(脈拍)）(前々回)", "data_type": "string", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_summary_prev_prev", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:10", "can_calc": "0", "data_code": "before_vital_measure_date_prev_prev", "data_name": "前血圧測定日時(前々回)", "data_type": "DateTime", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_vital_measure_date_prev_prev", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "after_bp_high_prev_prev", "data_name": "後血圧（最高）(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_high_prev_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "82", "can_calc": "1", "data_code": "after_bp_low_prev_prev", "data_name": "後血圧（最低）(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_low_prev_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "101", "can_calc": "1", "data_code": "after_bp_ave_prev_prev", "data_name": "後血圧（平均）(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_ave_prev_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "76", "can_calc": "1", "data_code": "after_pulse_prev_prev", "data_name": "後脈拍(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_pulse_prev_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120/80/100(72)", "can_calc": "0", "data_code": "after_bp_summary_prev_prev", "data_name": "後血圧（最高/最低/平均(脈拍)）(前々回)", "data_type": "string", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_summary_prev_prev", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:53", "can_calc": "0", "data_code": "after_vital_measure_date_prev_prev", "data_name": "後血圧測定日時(前々回)", "data_type": "DateTime", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_vital_measure_date_prev_prev", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": []}', '実績（治療中）：血圧情報(過去実績) @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (173, 'WITH DATA AS (

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
from
  ord_main
where
  ord_no = @ordNo and is_del = ''0''
  and rst_dialysis_state > ''0'' and rst_dialysis_state < ''6''
)

select
  *
	, @ordNo as ord_no_t
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
	b.ord_no as ordnob,
	b.treat_date as treat_date,
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
	', 2, '[{"preview": "55.00", "can_calc": "1", "data_code": "water_removal_target", "data_name": "目標除水量", "data_type": "decimal", "conv_table": [], "data_class": "除水情報", "field_name": "water_removal_target", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.85", "can_calc": "1", "data_code": "water_removal_rst", "data_name": "実績除水量", "data_type": "decimal", "conv_table": [], "data_class": "除水情報", "field_name": "water_removal_rst", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7.70", "can_calc": "1", "data_code": "add_water_total", "data_name": "補液積算値", "data_type": "decimal", "conv_table": [], "data_class": "除水情報", "field_name": "add_water_total", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "食事量", "can_calc": "0", "data_code": "before_tare_name_1", "data_name": "風袋名称１（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "before_tare_weight_1", "data_name": "風袋重量１（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_weight_1", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "服", "can_calc": "0", "data_code": "before_tare_name_2", "data_name": "風袋名称２（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "before_tare_weight_2", "data_name": "風袋重量２（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_weight_2", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "義足", "can_calc": "0", "data_code": "before_tare_name_3", "data_name": "風袋名称３（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1200", "can_calc": "1", "data_code": "before_tare_weight_3", "data_name": "風袋重量３（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_weight_3", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋１", "can_calc": "0", "data_code": "before_tare_name_4", "data_name": "風袋名称４（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "before_tare_weight_4", "data_name": "風袋重量４（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_weight_4", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋２", "can_calc": "0", "data_code": "before_tare_name_5", "data_name": "風袋名称５（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "before_tare_weight_5", "data_name": "風袋重量５（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_weight_5", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "車椅子１", "can_calc": "0", "data_code": "before_wheel_chair_name", "data_name": "車椅子名称（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_wheel_chair_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15000", "can_calc": "1", "data_code": "before_wheel_chair_weight", "data_name": "車椅子重量（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_wheel_chair_weight", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "16800", "can_calc": "1", "data_code": "before_tare_total", "data_name": "風袋重量合計（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_total", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "食事量", "can_calc": "0", "data_code": "after_tare_name_1", "data_name": "風袋名称１（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "after_tare_weight_1", "data_name": "風袋重量１（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_weight_1", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "服", "can_calc": "0", "data_code": "after_tare_name_2", "data_name": "風袋名称２（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "after_tare_weight_2", "data_name": "風袋重量２（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_weight_2", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "義足", "can_calc": "0", "data_code": "after_tare_name_3", "data_name": "風袋名称３（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1200", "can_calc": "1", "data_code": "after_tare_weight_3", "data_name": "風袋重量３（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_weight_3", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋１", "can_calc": "0", "data_code": "after_tare_name_4", "data_name": "風袋名称４（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "after_tare_weight_4", "data_name": "風袋重量４（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_weight_4", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋２", "can_calc": "0", "data_code": "after_tare_name_5", "data_name": "風袋名称５（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "after_tare_weight_5", "data_name": "風袋重量５（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_weight_5", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "車椅子１", "can_calc": "0", "data_code": "after_wheel_chair_name", "data_name": "車椅子名称（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_wheel_chair_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15000", "can_calc": "1", "data_code": "after_wheel_chair_weight", "data_name": "車椅子重量（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_wheel_chair_weight", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "16800", "can_calc": "1", "data_code": "after_tare_total", "data_name": "風袋重量合計（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_total", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "食事量", "can_calc": "0", "data_code": "off_water_name_1", "data_name": "除水補正名称１", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "off_water_weight_1", "data_name": "除水補正重量１", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_1", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "プライミング", "can_calc": "0", "data_code": "off_water_name_2", "data_name": "除水補正名称２", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "off_water_weight_2", "data_name": "除水補正重量２", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_2", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "輸液量", "can_calc": "0", "data_code": "off_water_name_3", "data_name": "除水補正名称３", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "off_water_weight_3", "data_name": "除水補正重量３", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_3", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他（不感蒸泄）", "can_calc": "0", "data_code": "off_water_name_4", "data_name": "除水補正名称４", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "off_water_weight_4", "data_name": "除水補正重量４", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_4", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他", "can_calc": "0", "data_code": "off_water_name_5", "data_name": "除水補正名称５", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "off_water_weight_5", "data_name": "除水補正重量５", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_5", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "900", "can_calc": "1", "data_code": "off_water_total", "data_name": "除水補正重量合計", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_total", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": []}', '実績（治療中）：除水情報/風袋・除水補正 @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (174, 'select
CASE WHEN (monitor_data->>''1'') IS NULL THEN 0 ELSE  (monitor_data->>''1'')::INTEGER END  as mon1 -- 経過時間
,monitor_data->>''2'' as mon2 -- 経過時間（ＥＣＵＭ）
,case when monitor_data->>''3'' is null then ''0'' else monitor_data->>''3'' end as mon3 -- 残り時間（除水完了）
,case when monitor_data->>''4'' is null then ''0'' else monitor_data->>''4'' end as mon4 -- 残り時間（透析完了）
,monitor_data->>''5'' as mon5 -- 除水積算値
,monitor_data->>''6'' as mon6 -- 除水速度
,monitor_data->>''7'' as mon7 -- 血液循環量
,monitor_data->>''8'' as mon8 -- 血流量
,monitor_data->>''9'' as mon9 -- ＩＰ総量
,monitor_data->>''10'' as mon10 -- ＩＰ速度
,monitor_data->>''11'' as mon11 -- 静脈圧
,monitor_data->>''12'' as mon12 -- 透析液圧
,monitor_data->>''13'' as mon13 -- TMP
,monitor_data->>''14'' as mon14 -- ダイアライザ入口圧
,monitor_data->>''15'' as mon15 -- ダイアライザ差圧
,monitor_data->>''16'' as mon16 -- 血液入口～静脈平均圧
,monitor_data->>''17'' as mon17 -- ⊿BV
,monitor_data->>''18'' as mon18 -- バイカーボ濃度
,monitor_data->>''19'' as mon19 -- 透析液濃度
,monitor_data->>''20'' as mon20 -- Ｎａ濃度
,monitor_data->>''21'' as mon21 -- 透析液温度
,monitor_data->>''22'' as mon22 -- 透析液流量
,monitor_data->>''23'' as mon23 -- 漏血量
,monitor_data->>''24'' as mon24 -- 給液圧（上限）
,monitor_data->>''25'' as mon25 -- 給液圧（下限）
,monitor_data->>''26'' as mon26 -- ＵＦＲ
,monitor_data->>''27'' as mon27 -- ＵＦＲ低下率
,monitor_data->>''28'' as mon28 -- 初期ＵＦＲ測定値
,monitor_data->>''29'' as mon29 -- TMP補正値
,monitor_data->>''30'' as mon30 -- 透析運転時間
,monitor_data->>''31'' as mon31 -- 治療モード
,monitor_data->>''32'' as mon32 -- 除水目標値
,monitor_data->>''33'' as mon33 -- 除水速度設定値
,monitor_data->>''34'' as mon34 -- 透析液温度設定値
,monitor_data->>''35'' as mon35 -- 透析液流量設定値
,monitor_data->>''36'' as mon36 -- 血流量設定値
,monitor_data->>''37'' as mon37 -- ＩＰ速度設定
,monitor_data->>''39'' as mon39 -- 静脈圧警報点（上限）
,monitor_data->>''40'' as mon40 -- 静脈圧警報点（下限）
,monitor_data->>''41'' as mon41 -- 透析液圧警報点（上限）
,monitor_data->>''42'' as mon42 -- 透析液圧警報点（下限）
,monitor_data->>''43'' as mon43 -- TMP警報点（上限）
,monitor_data->>''44'' as mon44 -- TMP警報点（下限）
,monitor_data->>''45'' as mon45 -- ダイアライザ入口圧警報点（上限）
,monitor_data->>''46'' as mon46 -- ダイアライザ入口圧警報点（下限）
,monitor_data->>''47'' as mon47 -- ダイアライザ差圧警報点（上限）
,monitor_data->>''48'' as mon48 -- ダイアライザ差圧警報点（下限）
,monitor_data->>''49'' as mon49 -- ⊿ＢＶ低下警報点1
,monitor_data->>''50'' as mon50 -- ⊿ＢＶ低下警報点2
,monitor_data->>''51'' as mon51 -- ⊿BV変化率警報点
,monitor_data->>''54'' as mon54 -- バイカーボ濃度警報点（上限）
,monitor_data->>''55'' as mon55 -- バイカーボ濃度警報点（下限）
,monitor_data->>''56'' as mon56 -- 透析液濃度警報点（上限）
,monitor_data->>''57'' as mon57 -- 透析液濃度警報点（下限）
,monitor_data->>''58'' as mon58 -- Ｎａ濃度警報点（上限）
,monitor_data->>''59'' as mon59 -- Ｎａ濃度警報点（下限）
,monitor_data->>''60'' as mon60 -- 透析液温度警報点（上限）
,monitor_data->>''61'' as mon61 -- 透析液温度警報点（下限）
,monitor_data->>''62'' as mon62 -- 漏血量警報
,monitor_data->>''63'' as mon63 -- 給水圧警報点（上限）
,monitor_data->>''64'' as mon64 -- 給水圧警報点（下限）
,monitor_data->>''65'' as mon65 -- 初期ＵＦＲ警報点（上限）
,monitor_data->>''66'' as mon66 -- 初期ＵＦＲ警報点（下限）
,monitor_data->>''67'' as mon67 -- ＵＦＲ低下率警報
,monitor_data->>''68'' as mon68 -- Kt/V
,monitor_data->>''69'' as mon69 -- 運転中の血流量積算値
,monitor_data->>''70'' as mon70 -- 補液量設定値
,monitor_data->>''71'' as mon71 -- 補液速度
,monitor_data->>''72'' as mon72 -- 補液量現在値
,monitor_data->>''73'' as mon73 -- 補液速度設定値
,monitor_data->>''74'' as mon74 -- 補液温度
,monitor_data->>''75'' as mon75 -- 補液温度設定値
,monitor_data->>''76'' as mon76 -- 濾液速度
,monitor_data->>''77'' as mon77 -- 荷重計
,case when monitor_data->>''78'' is null then ''0'' else monitor_data->>''78'' end as mon78 -- 残り時間（補液完了）
,monitor_data->>''80'' as mon80 -- ⊿ＢＶ変化率
,monitor_data->>''85'' as mon85 -- ⊿BVリファレンスエリア上限
,monitor_data->>''86'' as mon86 -- ⊿BVリファレンスエリア下限
,monitor_data->>''88'' as mon88 -- PRR
,monitor_data->>''89'' as mon89 -- 再循環率測定結果（BVMS連携用）
,monitor_data->>''90'' as mon90 -- 最高血圧
,monitor_data->>''91'' as mon91 -- 最低血圧
,monitor_data->>''92'' as mon92 -- 平均血圧
,monitor_data->>''93'' as mon93 -- 脈拍
,monitor_data->>''94'' as mon94 -- 体温
,monitor_data->>''95'' as mon95 -- ⊿ＢＶ_5分平均値
,monitor_data->>''96'' as mon96 -- ⊿ＢＶ_最大最小を除いた5分平均値
,monitor_data->>''97'' as mon97 -- 推定血流量
,monitor_data->>''98'' as mon98 -- 血流量不足率

,monitor_data->>''38'' as mon38 -- Kt/V測定値
,monitor_data->>''79'' as mon79 -- URR
,monitor_data->>''100'' as mon100 -- ⊿BV(BVplus)
,monitor_data->>''101'' as mon101 -- Ht
,monitor_data->>''102'' as mon102 -- LDQb

,monitor_data->>''Z11'' as monZ1sigma -- 治療モード(Σ)
,monitor_data->>''Z21'' as monZ2sigma -- 工程状態(Σ)
,monitor_data->>''Z31'' as monZ3sigma -- 除水速度(Σ)
,monitor_data->>''Z41'' as monZ4sigma -- 血液流量(Σ)
,monitor_data->>''Z51'' as monZ5sigma -- シリンジ流量(Σ)
,monitor_data->>''Z61'' as monZ6sigma -- ろ過流量(Σ)
,monitor_data->>''Z71'' as monZ7sigma -- 透析液/ドレン流量(Σ)
,monitor_data->>''Z81'' as monZ8sigma -- 補液流量(Σ)
,monitor_data->>''Z91'' as monZ9sigma -- 透析液加温器温度(Σ)
,monitor_data->>''Z101'' as monZ10sigma -- 補液加温器温度(Σ)
,monitor_data->>''Z111'' as monZ11sigma -- 現在 除水量(Σ)
,monitor_data->>''Z121'' as monZ12sigma -- 現在 血液循環量(Σ)
,monitor_data->>''Z131'' as monZ13sigma -- 現在 ろ過量(Σ)
,monitor_data->>''Z141'' as monZ14sigma -- 現在 透析液/ドレン量(Σ)
,monitor_data->>''Z151'' as monZ15sigma -- 現在 補液量(Σ)
,monitor_data->>''Z161'' as monZ16sigma -- 治療時間(Σ)
,monitor_data->>''Z171'' as monZ17sigma -- シリンジ積算量(Σ)
,monitor_data->>''Z181'' as monZ18sigma -- 目標 除水量(Σ)
,monitor_data->>''Z191'' as monZ19sigma -- 目標 血液循環量(Σ)
,monitor_data->>''Z201'' as monZ20sigma -- 目標 ろ過量(Σ)
,monitor_data->>''Z211'' as monZ21sigma -- 目標 透析液/ドレン量(Σ)
,monitor_data->>''Z221'' as monZ22sigma -- 目標 補液量(Σ)
,monitor_data->>''Z231'' as monZ23sigma -- 目標 治療時間(Σ)
,monitor_data->>''Z241'' as monZ24sigma -- 脱血圧(Σ)
,monitor_data->>''Z251'' as monZ25sigma -- 入口圧(Σ)
,monitor_data->>''Z261'' as monZ26sigma -- 静脈圧(Σ)
,monitor_data->>''Z271'' as monZ27sigma -- ろ過圧(Σ)
,monitor_data->>''Z281'' as monZ28sigma -- 排気圧/2次膜圧(Σ)
,monitor_data->>''Z291'' as monZ29sigma -- TMP/TMP1(Σ)
,monitor_data->>''Z301'' as monZ30sigma -- TMP2(Σ)
,monitor_data->>''Z311'' as monZ31sigma -- 差圧(Σ)
,monitor_data->>''Z321'' as monZ32sigma -- 気泡検知警報(Σ)
,monitor_data->>''Z331'' as monZ33sigma -- 漏血警報(Σ)
,monitor_data->>''Z341'' as monZ34sigma -- 加温器警報(Σ)
,monitor_data->>''Z351'' as monZ35sigma -- 脱血圧警報(Σ)
,monitor_data->>''Z361'' as monZ36sigma -- 入口圧警報(Σ)
,monitor_data->>''Z371'' as monZ37sigma -- 静脈圧警報(Σ)
,monitor_data->>''Z381'' as monZ38sigma -- ろ過圧警報(Σ)
,monitor_data->>''Z391'' as monZ39sigma -- 排気圧/2次膜圧警報(Σ)
,monitor_data->>''Z401'' as monZ40sigma -- TMP警報(Σ)
,monitor_data->>''Z411'' as monZ41sigma -- TMP2警報(Σ)
,monitor_data->>''Z421'' as monZ42sigma -- 差圧警報(Σ)
,monitor_data->>''Z431'' as monZ43sigma -- その他警報(Σ)

,monitor_data->>''Z12'' as monZ1km -- 測定値 TMP(KM)
,monitor_data->>''Z22'' as monZ2km -- 測定値 入口圧(KM)
,monitor_data->>''Z32'' as monZ3km -- 測定値 返血圧(KM)
,monitor_data->>''Z42'' as monZ4km -- 測定値 2次膜圧（吸着圧）(KM)
,monitor_data->>''Z52'' as monZ5km -- 圧力上限警報設定値 TMP(KM)
,monitor_data->>''Z62'' as monZ6km -- 圧力上限警報設定値 入口圧(KM)
,monitor_data->>''Z72'' as monZ7km -- 圧力上限警報設定値 返血圧(KM)
,monitor_data->>''Z82'' as monZ8km -- 圧力上限警報設定値 2次膜圧（吸着圧）(KM)
,monitor_data->>''Z92'' as monZ9km -- 流量情報 BP瞬時流量(KM)
,monitor_data->>''Z102'' as monZ10km -- 流量情報 PP瞬時流量(KM)
,monitor_data->>''Z112'' as monZ11km -- 流量情報 DP瞬時流量(KM)
,monitor_data->>''Z122'' as monZ12km -- 流量情報 BP積算流量(KM)
,monitor_data->>''Z132'' as monZ13km -- 流量情報 PP積算流量(KM)
,monitor_data->>''Z142'' as monZ14km -- 流量情報 DP積算流量(KM)
,monitor_data->>''Z152'' as monZ15km -- 流量情報 除水積算流量(KM)
,monitor_data->>''Z162'' as monZ16km -- 流量情報 血漿処理目標値(KM)
,monitor_data->>''Z172'' as monZ17km -- その他情報 加温器温度(KM)
,monitor_data->>''Z182'' as monZ18km -- その他情報 バランス(KM)
,monitor_data->>''Z192'' as monZ19km -- その他情報 経過時間(KM)
,monitor_data->>''Z202'' as monZ20km -- その他情報 アラーム番号(KM)
,monitor_data->>''Z212'' as monZ21km -- その他情報 自己診断番号(KM)
,monitor_data->>''Z222'' as monZ22km -- その他情報 モード(KM)
,monitor_data->>''Z232'' as monZ23km -- その他情報 工程情報(KM)

,monitor_data->>''Z13'' as monZ1iq -- 治療経過時間(iQ)
,monitor_data->>''Z23'' as monZ2iq -- 除水速度(iQ)
,monitor_data->>''Z33'' as monZ3iq -- ろ過ポンプ流量(iQ)
,monitor_data->>''Z43'' as monZ4iq -- 補液ポンプ流量(iQ)
,monitor_data->>''Z53'' as monZ5iq -- 透析ポンプ流量(iQ)
,monitor_data->>''Z63'' as monZ6iq -- 血液ポンプ流量(iQ)
,monitor_data->>''Z73'' as monZ7iq -- シリンジポンプ流量(iQ)
,monitor_data->>''Z83'' as monZ8iq -- 除水量積算値(iQ)
,monitor_data->>''Z93'' as monZ9iq -- ろ過量積算値(iQ)
,monitor_data->>''Z103'' as monZ10iq -- 補液量積算値(iQ)
,monitor_data->>''Z113'' as monZ11iq -- 透析液量積算値(iQ)
,monitor_data->>''Z123'' as monZ12iq -- 血液循環量(iQ)
,monitor_data->>''Z133'' as monZ13iq -- シリンジポンプ積算値(iQ)
,monitor_data->>''Z143'' as monZ14iq -- 採血圧(iQ)
,monitor_data->>''Z153'' as monZ15iq -- 動脈圧(iQ)
,monitor_data->>''Z163'' as monZ16iq -- 静脈圧(iQ)
,monitor_data->>''Z173'' as monZ17iq -- ろ過圧(iQ)
,monitor_data->>''Z183'' as monZ18iq -- TMP(iQ)
,monitor_data->>''Z193'' as monZ19iq -- 分離ポンプ流量(iQ)
,monitor_data->>''Z203'' as monZ20iq -- 返漿ポンプ流量(iQ)
,monitor_data->>''Z213'' as monZ21iq -- ドレンポンプ流量(iQ)
,monitor_data->>''Z223'' as monZ22iq -- 分離量積算値(iQ)
,monitor_data->>''Z233'' as monZ23iq -- 返漿量積算値(iQ)
,monitor_data->>''Z243'' as monZ24iq -- ドレン量積算値(iQ)
,monitor_data->>''Z253'' as monZ25iq -- 血漿圧(iQ)
,monitor_data->>''Z263'' as monZ26iq -- 血漿入口圧(iQ)

,monitor_data->>''Z14'' as monZ1km90 -- 測定値 TMP圧(KM90)
,monitor_data->>''Z24'' as monZ2km90 -- 測定値 入口圧(KM90)
,monitor_data->>''Z34'' as monZ3km90 -- 測定値 返血圧(KM90)
,monitor_data->>''Z44'' as monZ4km90 -- 測定値 ろ過圧(KM90)
,monitor_data->>''Z54'' as monZ5km90 -- 測定値 浄化器圧(KM90)
,monitor_data->>''Z64'' as monZ6km90 -- 設定値 TMP圧(KM90)
,monitor_data->>''Z74'' as monZ7km90 -- 設定値 入口圧(KM90)
,monitor_data->>''Z84'' as monZ8km90 -- 設定値 返血圧・上限(KM90)
,monitor_data->>''Z94'' as monZ9km90 -- 設定値 返血圧・下限(KM90)
,monitor_data->>''Z104'' as monZ10km90 -- 設定値 浄化器圧(KM90)
,monitor_data->>''Z114'' as monZ11km90 -- 設定値 除水設定値(KM90)
,monitor_data->>''Z124'' as monZ12km90 -- 流量情報 血液ﾎﾟﾝﾌﾟ指令流量(KM90)
,monitor_data->>''Z134'' as monZ13km90 -- 流量情報 透析液ﾎﾟﾝﾌﾟ指令流量(KM90)
,monitor_data->>''Z144'' as monZ14km90 -- 流量情報 補充液ﾎﾟﾝﾌﾟ指令流量(KM90)
,monitor_data->>''Z154'' as monZ15km90 -- 流量情報 ろ液ﾎﾟﾝﾌﾟ指令流量(KM90)
,monitor_data->>''Z164'' as monZ16km90 -- 流量情報 血液ﾎﾟﾝﾌﾟ積算流量(KM90)
,monitor_data->>''Z174'' as monZ17km90 -- 流量情報 透析液ﾎﾟﾝﾌﾟ積算流量(KM90)
,monitor_data->>''Z184'' as monZ18km90 -- 流量情報 補充液ﾎﾟﾝﾌﾟ積算流量(KM90)
,monitor_data->>''Z194'' as monZ19km90 -- 流量情報 除水積算流量(KM90)
,monitor_data->>''Z204'' as monZ20km90 -- その他情報 加温器温度(KM90)
,monitor_data->>''Z214'' as monZ21km90 -- その他情報 除水差分/重量値(KM90)
,monitor_data->>''Z224'' as monZ22km90 -- その他情報 初期診断情報(KM90)
,monitor_data->>''Z234'' as monZ23km90 -- その他情報 ｱﾗｰﾑ情報1(KM90)
,monitor_data->>''Z244'' as monZ24km90 -- その他情報 ｱﾗｰﾑ情報2(KM90)
,monitor_data->>''Z254'' as monZ25km90 -- その他情報 ｱﾗｰﾑ情報3(KM90)
,monitor_data->>''Z264'' as monZ26km90 -- その他情報 ｱﾗｰﾑ情報4(KM90)
,monitor_data->>''Z274'' as monZ27km90 -- その他情報 ｱﾗｰﾑ情報5(KM90)
,monitor_data->>''Z284'' as monZ28km90 -- その他情報 ｱﾗｰﾑ情報6(KM90)
,monitor_data->>''Z294'' as monZ29km90 -- その他情報 ｱﾗｰﾑ情報7(KM90)
,monitor_data->>''Z304'' as monZ30km90 -- その他情報 ｱﾗｰﾑ情報8(KM90)
,monitor_data->>''Z314'' as monZ31km90 -- その他情報 ｱﾗｰﾑ情報9(KM90)
,monitor_data->>''Z324'' as monZ32km90 -- その他情報 ｱﾗｰﾑ情報10(KM90)
,monitor_data->>''Z334'' as monZ33km90 -- その他情報 注意情報(KM90)
,monitor_data->>''Z344'' as monZ34km90 -- 経過時間(KM90)
,monitor_data->>''Z354'' as monZ35km90 -- その他情報 用途(KM90)
,monitor_data->>''Z364'' as monZ36km90 -- その他情報 工程(KM90)
,monitor_data->>''Z374'' as monZ37km90 -- その他情報 動作日、時間(KM90)
,occur_date as occur_date -- 発生日時
,ord_no
from
  mni_monitor
where
  ord_no = @ordNo and data_type = 1 and is_del = ''0''
	order by occur_date desc;', 2, '[{"preview": "00：11", "can_calc": "0", "data_code": "mon1", "data_name": "経過時間", "data_type": "DateTime", "conv_table": [], "data_class": "モニタ", "field_name": "mon1", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "00：12", "can_calc": "0", "data_code": "mon2", "data_name": "経過時間（ＥＣＵＭ）", "data_type": "DateTime", "conv_table": [], "data_class": "モニタ", "field_name": "mon2", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "00：13", "can_calc": "0", "data_code": "mon3", "data_name": "残り時間（除水完了）", "data_type": "DateTime", "conv_table": [], "data_class": "モニタ", "field_name": "mon3", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "00：14", "can_calc": "0", "data_code": "mon4", "data_name": "残り時間（透析完了）", "data_type": "DateTime", "conv_table": [], "data_class": "モニタ", "field_name": "mon4", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.21", "can_calc": "0", "data_code": "mon5", "data_name": "除水積算値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon5", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.18", "can_calc": "0", "data_code": "mon6", "data_name": "除水速度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon6", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "8.58", "can_calc": "0", "data_code": "mon7", "data_name": "血液循環量", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon7", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "0", "data_code": "mon8", "data_name": "血流量", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon8", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4.4", "can_calc": "0", "data_code": "mon9", "data_name": "ＩＰ総量", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon9", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.2", "can_calc": "0", "data_code": "mon10", "data_name": "ＩＰ速度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon10", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "138", "can_calc": "0", "data_code": "mon11", "data_name": "静脈圧", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon11", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "144", "can_calc": "0", "data_code": "mon12", "data_name": "透析液圧", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon12", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-7", "can_calc": "0", "data_code": "mon13", "data_name": "TMP", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon13", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-830", "can_calc": "0", "data_code": "mon14", "data_name": "ダイアライザ入口圧", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon14", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-925", "can_calc": "0", "data_code": "mon15", "data_name": "ダイアライザ差圧", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon15", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-367", "can_calc": "0", "data_code": "mon16", "data_name": "血液入口～静脈平均圧", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon16", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon17", "data_name": "⊿BV", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon17", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "0", "data_code": "mon18", "data_name": "バイカーボ濃度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon18", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13.8", "can_calc": "0", "data_code": "mon19", "data_name": "透析液濃度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon19", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon20", "data_name": "Ｎａ濃度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon20", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.2", "can_calc": "0", "data_code": "mon21", "data_name": "透析液温度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon21", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "mon22", "data_name": "透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon22", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "0", "data_code": "mon23", "data_name": "漏血量", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon23", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "38", "can_calc": "0", "data_code": "mon24", "data_name": "給液圧（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon24", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "22", "can_calc": "0", "data_code": "mon25", "data_name": "給液圧（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon25", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-72.13", "can_calc": "0", "data_code": "mon26", "data_name": "ＵＦＲ", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon26", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon27", "data_name": "ＵＦＲ低下率", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon27", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "0", "data_code": "mon28", "data_name": "初期ＵＦＲ測定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon28", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "0", "data_code": "mon29", "data_name": "TMP補正値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon29", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon30", "data_name": "透析運転時間", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon30", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "HD", "can_calc": "0", "data_code": "mon31", "data_name": "治療モード", "data_type": "string", "conv_table": [{"code": "-1", "disp": "不明", "item": "不明"}, {"code": "0", "disp": "HD", "item": "HD"}, {"code": "1", "disp": "ECUM", "item": "ECUM"}, {"code": "2", "disp": "HDF", "item": "HDF"}, {"code": "3", "disp": "HF", "item": "HF"}, {"code": "4", "disp": "HD+補液", "item": "HD+補液"}, {"code": "5", "disp": "ECUM+補液", "item": "ECUM+補液"}, {"code": "6", "disp": "AFBF", "item": "AFBF"}, {"code": "7", "disp": "OHDF", "item": "OHDF"}, {"code": "8", "disp": "OHF", "item": "OHF"}, {"code": "9", "disp": "特殊浄化", "item": "特殊浄化"}, {"code": "10", "disp": "I-HDF", "item": "I-HDF"}], "data_class": "モニタ", "field_name": "mon31", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.85", "can_calc": "0", "data_code": "mon32", "data_name": "除水目標値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon32", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.2", "can_calc": "0", "data_code": "mon33", "data_name": "除水速度設定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon33", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.5", "can_calc": "0", "data_code": "mon34", "data_name": "透析液温度設定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon34", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "mon35", "data_name": "透析液流量設定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon35", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "0", "data_code": "mon36", "data_name": "血流量設定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon36", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.2", "can_calc": "0", "data_code": "mon37", "data_name": "ＩＰ速度設定", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon37", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "0", "data_code": "mon39", "data_name": "静脈圧警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon39", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "0", "data_code": "mon40", "data_name": "静脈圧警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon40", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "0", "data_code": "mon41", "data_name": "透析液圧警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon41", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "0", "data_code": "mon42", "data_name": "透析液圧警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon42", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "0", "data_code": "mon43", "data_name": "TMP警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon43", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "0", "data_code": "mon44", "data_name": "TMP警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon44", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "0", "data_code": "mon45", "data_name": "ダイアライザ入口圧警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon45", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "0", "data_code": "mon46", "data_name": "ダイアライザ入口圧警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon46", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "0", "data_code": "mon47", "data_name": "ダイアライザ差圧警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon47", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-20", "can_calc": "0", "data_code": "mon48", "data_name": "ダイアライザ差圧警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon48", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-20.0", "can_calc": "0", "data_code": "mon49", "data_name": "⊿ＢＶ低下警報点1", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon49", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-40.0", "can_calc": "0", "data_code": "mon50", "data_name": "⊿ＢＶ低下警報点2", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon50", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-10.0", "can_calc": "0", "data_code": "mon51", "data_name": "⊿BV変化率警報点", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon51", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "0", "data_code": "mon54", "data_name": "バイカーボ濃度警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon54", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "0", "data_code": "mon55", "data_name": "バイカーボ濃度警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon55", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon56", "data_name": "透析液濃度警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon56", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon57", "data_name": "透析液濃度警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon57", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon58", "data_name": "Ｎａ濃度警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon58", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon59", "data_name": "Ｎａ濃度警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon59", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "40.0", "can_calc": "0", "data_code": "mon60", "data_name": "透析液温度警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon60", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "33.0", "can_calc": "0", "data_code": "mon61", "data_name": "透析液温度警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon61", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "0", "data_code": "mon62", "data_name": "漏血量警報", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon62", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "45", "can_calc": "0", "data_code": "mon63", "data_name": "給水圧警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon63", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "8", "can_calc": "0", "data_code": "mon64", "data_name": "給水圧警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon64", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-40.00", "can_calc": "0", "data_code": "mon65", "data_name": "初期ＵＦＲ警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon65", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-100.00", "can_calc": "0", "data_code": "mon66", "data_name": "初期ＵＦＲ警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon66", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "29", "can_calc": "0", "data_code": "mon67", "data_name": "ＵＦＲ低下率警報", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon67", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.1", "can_calc": "0", "data_code": "mon68", "data_name": "Kt/V", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon68", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "8.58", "can_calc": "0", "data_code": "mon69", "data_name": "運転中の血流量積算値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon69", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "8", "can_calc": "0", "data_code": "mon70", "data_name": "補液量設定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon70", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.0", "can_calc": "0", "data_code": "mon71", "data_name": "補液速度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon71", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.4", "can_calc": "0", "data_code": "mon72", "data_name": "補液量現在値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon72", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.0", "can_calc": "0", "data_code": "mon73", "data_name": "補液速度設定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon73", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.4", "can_calc": "0", "data_code": "mon74", "data_name": "補液温度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon74", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.4", "can_calc": "0", "data_code": "mon75", "data_name": "補液温度設定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon75", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "0", "data_code": "mon76", "data_name": "濾液速度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon76", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.62", "can_calc": "0", "data_code": "mon77", "data_name": "荷重計", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon77", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "00：15", "can_calc": "0", "data_code": "mon78", "data_name": "残り時間（補液完了）", "data_type": "DateTime", "conv_table": [], "data_class": "モニタ", "field_name": "mon78", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-5.0", "can_calc": "0", "data_code": "mon80", "data_name": "⊿ＢＶ変化率", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon80", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon85", "data_name": "⊿BVリファレンスエリア上限", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon85", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon86", "data_name": "⊿BVリファレンスエリア下限", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon86", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "0", "data_code": "mon88", "data_name": "PRR", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon88", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon89", "data_name": "再循環率測定結果（BVMS連携用）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon89", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "132", "can_calc": "0", "data_code": "mon90", "data_name": "最高血圧", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon90", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "88", "can_calc": "0", "data_code": "mon91", "data_name": "最低血圧", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon91", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "102", "can_calc": "0", "data_code": "mon92", "data_name": "平均血圧", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon92", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "66", "can_calc": "0", "data_code": "mon93", "data_name": "脈拍", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon93", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.6", "can_calc": "0", "data_code": "mon94", "data_name": "体温", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon94", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "0", "data_code": "mon95", "data_name": "⊿ＢＶ_5分平均値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon95", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "0", "data_code": "mon96", "data_name": "⊿ＢＶ_最大最小を除いた5分平均値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon96", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.51", "can_calc": "0", "data_code": "mon38", "data_name": "Kt/V測定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon38", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "35.5", "can_calc": "0", "data_code": "mon79", "data_name": "URR", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon79", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "0", "data_code": "mon97", "data_name": "推定血流量", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon97", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50.1", "can_calc": "0", "data_code": "mon98", "data_name": "血流量不足率", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon98", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "SCUF", "can_calc": "0", "data_code": "monz1sigma", "data_name": "治療モード(Σ)", "data_type": "string", "conv_table": [{"code": "00", "disp": "SCUF", "item": "SCUF"}, {"code": "01", "disp": "CHF 前希釈", "item": "CHF 前希釈"}, {"code": "02", "disp": "CHF 後希釈", "item": "CHF 後希釈"}, {"code": "03", "disp": "CHD", "item": "CHD"}, {"code": "04", "disp": "CHDF 前希釈", "item": "CHDF 前希釈"}, {"code": "05", "disp": "CHDF 後希釈", "item": "CHDF 後希釈"}, {"code": "06", "disp": "PE", "item": "PE"}, {"code": "07", "disp": "PA プラソーバ", "item": "PA プラソーバ"}, {"code": "08", "disp": "PA イムソーバ", "item": "PA イムソーバ"}, {"code": "09", "disp": "DFPP 補液無し", "item": "DFPP 補液無し"}, {"code": "10", "disp": "DFPP 補液有り", "item": "DFPP 補液有り"}, {"code": "11", "disp": "HA", "item": "HA"}, {"code": "12", "disp": "LCAP", "item": "LCAP"}, {"code": "13", "disp": "(腹水)", "item": "(腹水)"}], "data_class": "モニタ", "field_name": "monz1sigma", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "治療", "can_calc": "0", "data_code": "monz2sigma", "data_name": "工程状態(Σ)", "data_type": "string", "conv_table": [{"code": "1", "disp": "治療", "item": "治療"}, {"code": "2", "disp": "治療停止", "item": "治療停止"}, {"code": "3", "disp": "回収", "item": "回収"}, {"code": "4", "disp": "回収 廃棄", "item": "回収 廃棄"}, {"code": "5", "disp": "準備", "item": "準備"}, {"code": "6", "disp": "点検", "item": "点検"}, {"code": "7", "disp": "その他", "item": "その他"}], "data_class": "モニタ", "field_name": "monz2sigma", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz3sigma", "data_name": "除水速度(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz3sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz4sigma", "data_name": "血液流量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz4sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz5sigma", "data_name": "シリンジ流量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz5sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz6sigma", "data_name": "ろ過流量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz6sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz7sigma", "data_name": "透析液/ドレン流量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz7sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz8sigma", "data_name": "補液流量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz8sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz9sigma", "data_name": "透析液加温器温度(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz9sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz10sigma", "data_name": "補液加温器温度(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz10sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz11sigma", "data_name": "現在 除水量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz11sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz12sigma", "data_name": "現在 血液循環量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz12sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz13sigma", "data_name": "現在 ろ過量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz13sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz14sigma", "data_name": "現在 透析液/ドレン量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz14sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz15sigma", "data_name": "現在 補液量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz15sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz16sigma", "data_name": "治療時間(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz16sigma", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz17sigma", "data_name": "シリンジ積算量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz17sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz18sigma", "data_name": "目標 除水量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz18sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz19sigma", "data_name": "目標 血液循環量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz19sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz20sigma", "data_name": "目標 ろ過量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz20sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz21sigma", "data_name": "目標 透析液/ドレン量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz21sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz22sigma", "data_name": "目標 補液量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz22sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz23sigma", "data_name": "目標 治療時間(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz23sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz24sigma", "data_name": "脱血圧(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz24sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz25sigma", "data_name": "入口圧(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz25sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz26sigma", "data_name": "静脈圧(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz26sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz27sigma", "data_name": "ろ過圧(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz27sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz28sigma", "data_name": "排気圧/2次膜圧(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz28sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz29sigma", "data_name": "TMP/TMP1(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz29sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz30sigma", "data_name": "TMP2(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz30sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz31sigma", "data_name": "差圧(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz31sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz32sigma", "data_name": "気泡検知警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz32sigma", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz33sigma", "data_name": "漏血警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz33sigma", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz34sigma", "data_name": "加温器警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz34sigma", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz35sigma", "data_name": "脱血圧警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz35sigma", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz36sigma", "data_name": "入口圧警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz36sigma", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz37sigma", "data_name": "静脈圧警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz37sigma", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz38sigma", "data_name": "ろ過圧警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz38sigma", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz39sigma", "data_name": "排気圧/2次膜圧警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz39sigma", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz40sigma", "data_name": "TMP警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz40sigma", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz41sigma", "data_name": "TMP2警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz41sigma", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz42sigma", "data_name": "差圧警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz42sigma", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz43sigma", "data_name": "その他警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz43sigma", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz1km", "data_name": "測定値 TMP(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz1km", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz2km", "data_name": "測定値 入口圧(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz2km", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz3km", "data_name": "測定値 返血圧(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz3km", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz4km", "data_name": "測定値 2次膜圧（吸着圧）(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz4km", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz5km", "data_name": "圧力上限警報設定値 TMP(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz5km", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz6km", "data_name": "圧力上限警報設定値 入口圧(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz6km", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz7km", "data_name": "圧力上限警報設定値 返血圧(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz7km", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz8km", "data_name": "圧力上限警報設定値 2次膜圧（吸着圧）(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz8km", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz9km", "data_name": "流量情報 BP瞬時流量(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz9km", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz10km", "data_name": "流量情報 PP瞬時流量(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz10km", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz11km", "data_name": "流量情報 DP瞬時流量(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz11km", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz12km", "data_name": "流量情報 BP積算流量(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz12km", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz13km", "data_name": "流量情報 PP積算流量(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz13km", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz14km", "data_name": "流量情報 DP積算流量(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz14km", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz15km", "data_name": "流量情報 除水積算流量(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz15km", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz16km", "data_name": "流量情報 血漿処理目標値(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz16km", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz17km", "data_name": "その他情報 加温器温度(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz17km", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz18km", "data_name": "その他情報 バランス(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz18km", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz19km", "data_name": "その他情報 経過時間(KM)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz19km", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz20km", "data_name": "その他情報 アラーム番号(KM)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz20km", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz21km", "data_name": "その他情報 自己診断番号(KM)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz21km", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "情報なし", "can_calc": "0", "data_code": "monz22km", "data_name": "その他情報 モード(KM)", "data_type": "string", "conv_table": [{"code": "0", "disp": "情報なし", "item": "情報なし"}, {"code": "1", "disp": "CHDF", "item": "CHDF"}, {"code": "2", "disp": "CHD", "item": "CHD"}, {"code": "3", "disp": "CHF", "item": "CHF"}, {"code": "4", "disp": "PE", "item": "PE"}, {"code": "5", "disp": "PP", "item": "PP"}, {"code": "6", "disp": "DF", "item": "DF"}, {"code": "7", "disp": "手動", "item": "手動"}], "data_class": "モニタ", "field_name": "monz22km", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "情報なし", "can_calc": "0", "data_code": "monz23km", "data_name": "その他情報 工程情報(KM)", "data_type": "string", "conv_table": [{"code": "0", "disp": "情報なし", "item": "情報なし"}, {"code": "1", "disp": "洗浄工程", "item": "洗浄工程"}, {"code": "2", "disp": "臨床工程", "item": "臨床工程"}, {"code": "3", "disp": "回収工程", "item": "回収工程"}, {"code": "4", "disp": "手動工程", "item": "手動工程"}], "data_class": "モニタ", "field_name": "monz23km", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz1iq", "data_name": "治療経過時間(iQ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz1iq", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz2iq", "data_name": "除水速度(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz2iq", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz3iq", "data_name": "ろ過ポンプ流量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz3iq", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz4iq", "data_name": "補液ポンプ流量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz4iq", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz5iq", "data_name": "透析ポンプ流量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz5iq", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz6iq", "data_name": "血液ポンプ流量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz6iq", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz7iq", "data_name": "シリンジポンプ流量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz7iq", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz8iq", "data_name": "除水量積算値(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz8iq", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz9iq", "data_name": "ろ過量積算値(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz9iq", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz10iq", "data_name": "補液量積算値(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz10iq", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz11iq", "data_name": "透析液量積算値(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz11iq", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz12iq", "data_name": "血液循環量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz12iq", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz13iq", "data_name": "シリンジポンプ積算値(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz13iq", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz14iq", "data_name": "採血圧(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz14iq", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz15iq", "data_name": "動脈圧(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz15iq", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz16iq", "data_name": "静脈圧(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz16iq", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz17iq", "data_name": "ろ過圧(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz17iq", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz18iq", "data_name": "TMP(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz18iq", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz19iq", "data_name": "分離ポンプ流量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz19iq", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz20iq", "data_name": "返漿ポンプ流量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz20iq", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz21iq", "data_name": "ドレンポンプ流量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz21iq", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz22iq", "data_name": "分離量積算値(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz22iq", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz23iq", "data_name": "返漿量積算値(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz23iq", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz24iq", "data_name": "ドレン量積算値(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz24iq", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz25iq", "data_name": "血漿圧(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz25iq", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz26iq", "data_name": "血漿入口圧(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz26iq", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz1km90", "data_name": "測定値 TMP圧(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz1km90", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz2km90", "data_name": "測定値 入口圧(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz2km90", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz3km90", "data_name": "測定値 返血圧(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz3km90", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz4km90", "data_name": "測定値 ろ過圧(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz4km90", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz5km90", "data_name": "測定値 浄化器圧(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz5km90", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz6km90", "data_name": "設定値 TMP圧(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz6km90", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz7km90", "data_name": "設定値 入口圧(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz7km90", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz8km90", "data_name": "設定値 返血圧・上限(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz8km90", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz9km90", "data_name": "設定値 返血圧・下限(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz9km90", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz10km90", "data_name": "設定値 浄化器圧(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz10km90", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz11km90", "data_name": "設定値 除水設定値(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz11km90", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz12km90", "data_name": "流量情報 血液ﾎﾟﾝﾌﾟ指令流量(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz12km90", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz13km90", "data_name": "流量情報 透析液ﾎﾟﾝﾌﾟ指令流量(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz13km90", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz14km90", "data_name": "流量情報 補充液ﾎﾟﾝﾌﾟ指令流量(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz14km90", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz15km90", "data_name": "流量情報 ろ液ﾎﾟﾝﾌﾟ指令流量(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz15km90", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz16km90", "data_name": "流量情報 血液ﾎﾟﾝﾌﾟ積算流量(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz16km90", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz17km90", "data_name": "流量情報 透析液ﾎﾟﾝﾌﾟ積算流量(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz17km90", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz18km90", "data_name": "流量情報 補充液ﾎﾟﾝﾌﾟ積算流量(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz18km90", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz19km90", "data_name": "流量情報 除水積算流量(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz19km90", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz20km90", "data_name": "その他情報 加温器温度(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz20km90", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz21km90", "data_name": "その他情報 除水差分/重量値(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz21km90", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz22km90", "data_name": "その他情報 初期診断情報(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz22km90", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz23km90", "data_name": "その他情報 ｱﾗｰﾑ情報1(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz23km90", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz24km90", "data_name": "その他情報 ｱﾗｰﾑ情報2(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz24km90", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz25km90", "data_name": "その他情報 ｱﾗｰﾑ情報3(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz25km90", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz26km90", "data_name": "その他情報 ｱﾗｰﾑ情報4(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz26km90", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz27km90", "data_name": "その他情報 ｱﾗｰﾑ情報5(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz27km90", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz28km90", "data_name": "その他情報 ｱﾗｰﾑ情報6(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz28km90", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz29km90", "data_name": "その他情報 ｱﾗｰﾑ情報7(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz29km90", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz30km90", "data_name": "その他情報 ｱﾗｰﾑ情報8(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz30km90", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz31km90", "data_name": "その他情報 ｱﾗｰﾑ情報9(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz31km90", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz32km90", "data_name": "その他情報 ｱﾗｰﾑ情報10(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz32km90", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz33km90", "data_name": "その他情報 注意情報(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz33km90", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz34km90", "data_name": "経過時間(KM9000)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz34km90", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz35km90", "data_name": "その他情報 用途(KM90)", "data_type": "string", "conv_table": [{"code": "1", "disp": "CRRT", "item": "CRRT"}, {"code": "2", "disp": "ECUM", "item": "ECUM"}, {"code": "3", "disp": "DF", "item": "DF"}, {"code": "4", "disp": "DFT", "item": "DFT"}, {"code": "5", "disp": "PP", "item": "PP"}, {"code": "6", "disp": "PE", "item": "PE"}, {"code": "7", "disp": "DHP", "item": "DHP"}, {"code": "8", "disp": "ASCT", "item": "ASCT"}, {"code": "9", "disp": "TEST", "item": "TEST"}], "data_class": "モニタ", "field_name": "monz35km90", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz36km90", "data_name": "その他情報 工程(KM90)", "data_type": "string", "conv_table": [{"code": "1", "disp": "装着", "item": "装着"}, {"code": "2", "disp": "確認", "item": "確認"}, {"code": "3", "disp": "洗浄", "item": "洗浄"}, {"code": "4", "disp": "臨床", "item": "臨床"}, {"code": "5", "disp": "回収", "item": "回収"}], "data_class": "モニタ", "field_name": "monz36km90", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz37km90", "data_name": "その他情報 動作日、時間(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz37km90", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "mon100", "data_name": "⊿BV(BVplus)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon100", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "mon101", "data_name": "Ht", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon101", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "mon102", "data_name": "LDQb", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon102", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/25", "can_calc": "0", "data_code": "occur_date", "data_name": "発生日時", "data_type": "DateTime", "conv_table": [], "data_class": "モニタ", "field_name": "occur_date", "disp_format": "yyyy/mm/dd", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": []}', '実績（治療中）：モニタ @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (175, 'WITH DATA AS (

with tmp1 as
(
  select
    ord_no
    ,jsonb_array_elements(rst_treatment_info) as rti
  from
    ord_main
where
  ord_no = @ordNo and is_del = ''0''
  and rst_dialysis_state >''0'' and rst_dialysis_state <''6''
)
, oxygen_tbl as
(
  select
    *
    ,(rti->>''occur_date'')::timestamp as occur_date
    ,date_trunc(''minute'', (rti->>''occur_date'')::timestamp) as date_trunc_occur_date
  from
    tmp1
  where
    rti->>''treat_class'' = ''3''
)
, tmp2 as
(
  select
    ord_no
    ,jsonb_array_elements(rst_treat_staff_info) as rtsi
  from
    ord_main
where
  ord_no = @ordNo and is_del = ''0''
  and rst_dialysis_state >''0'' and rst_dialysis_state <''6''
)
, staff_tbl as
(
  select
    *
    ,date_trunc(''minute'', (rtsi->>''occur_date'')::timestamp) as date_trunc_occur_date
  from
    tmp2
)

select
oxygen_tbl.ord_no as ord_no_t,
  oxygen_tbl.ord_no
  ,case
    when bit_length(rti->>''oxygen_start'') <> 0 then occur_date else null -- 開始
  end as start_date
  ,case
    when bit_length(rti->>''oxygen_amount'') <> 0 then occur_date else null -- 終了
  end as end_date
  ,case
    when bit_length(rti->>''oxygen_start'') <> 0 then rtsi->>''treat_staff_name'' else null -- 開始
  end as start_staff
  ,case
    when bit_length(rti->>''oxygen_amount'') <> 0 then rtsi->>''treat_staff_name'' else null -- 終了
  end as end_staff
  ,case
    when bit_length(rti->>''oxygen_speed'') <> 0 then rti->>''oxygen_speed'' else null
  end as speed
  ,case
    when bit_length(rti->>''oxygen_amount'') <> 0 then rti->>''oxygen_amount'' else null
  end as amount
from
  oxygen_tbl
  left outer join staff_tbl
    on oxygen_tbl.ord_no = staff_tbl.ord_no and oxygen_tbl.date_trunc_occur_date = staff_tbl.date_trunc_occur_date
order by
  ord_no, occur_date

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
	b.ord_no as ordnob,
	b.treat_date as treat_date,
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
	', 2, '[{"preview": "09:47", "can_calc": "0", "data_code": "start_date", "data_name": "開始時刻", "data_type": "DateTime", "conv_table": [], "data_class": "酸素吸入", "field_name": "start_date", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:00", "can_calc": "0", "data_code": "end_date", "data_name": "終了時刻", "data_type": "DateTime", "conv_table": [], "data_class": "酸素吸入", "field_name": "end_date", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護婦２", "can_calc": "0", "data_code": "start_staff", "data_name": "開始者", "data_type": "string", "conv_table": [], "data_class": "酸素吸入", "field_name": "start_staff", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護婦３", "can_calc": "0", "data_code": "end_staff", "data_name": "終了者", "data_type": "string", "conv_table": [], "data_class": "酸素吸入", "field_name": "end_staff", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "1", "data_code": "speed", "data_name": "吸入速度", "data_type": "decimal", "conv_table": [], "data_class": "酸素吸入", "field_name": "speed", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15", "can_calc": "1", "data_code": "amount", "data_name": "吸入量", "data_type": "decimal", "conv_table": [], "data_class": "酸素吸入", "field_name": "amount", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": []}', '実績（治療中）：酸素吸入 @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (176, 'WITH DATA AS (

with tmp1 as
(
  select
    ord_no
    ,jsonb_array_elements(rst_treatment_info) as rti
  from
    ord_main
where
  ord_no = @ordNo and is_del = ''0'' and rst_dialysis_state >''0'' and rst_dialysis_state <''6''
)
, oxygen_tbl as
(
  select
    *
    ,(rti->>''occur_date'')::timestamp as occur_date
    ,date_trunc(''minute'', (rti->>''occur_date'')::timestamp) as date_trunc_occur_date
  from
    tmp1
  where
    rti->>''treat_class'' = ''3''
)

select
	@ordNo as ord_no_t,
  sum(CAST(rti->>''oxygen_amount'' AS DECIMAL)) as total_amount
from
  oxygen_tbl
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
	b.ord_no as ordnob,
	b.treat_date as treat_date,
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
	', 2, '[{"preview": "16", "can_calc": "1", "data_code": "total_amount", "data_name": "吸入総量", "data_type": "decimal", "conv_table": [], "data_class": "酸素吸入総量", "field_name": "total_amount", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": []}', '実績（治療中）：酸素吸入総量 @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (177, 'WITH DATA AS (

with addition_info_expand as
(
  select
    ord_no
    ,json_idx
    ,addinfo
  from
    ord_main
    cross join lateral jsonb_array_elements(addition_info) with ordinality as tmp(addinfo, json_idx)
  where
    is_del = ''0''
    and ord_no = @ordNo
    and rst_dialysis_state >''0'' and rst_dialysis_state < ''6''
)
, tmp as
(
  select
    ord_no
    ,addinfo->>''cd'' as cd
    ,addinfo->>''name'' as name
    ,json_idx
    ,addinfo
  from
    addition_info_expand
)

select
ord_no as ord_no_t,
  ord_no
  ,name
  ,in_hospital_cd_1 as rst_addition_in_hospital_cd_1
  ,in_hospital_cd_2 as rst_addition_in_hospital_cd_2
  ,in_hospital_cd_3 as rst_addition_in_hospital_cd_3
  ,case
	  when addition_class =''1'' then ''施設''
		when addition_class =''2'' then ''患者（困）''
		when addition_class =''3'' then ''患者（病）''
		when addition_class =''4'' then ''ろ過''
		when addition_class =''5'' then ''長時間''
		when addition_class =''6'' then ''薬剤''
		when addition_class =''7'' then ''処置（イベント）''
		when addition_class =''8'' then ''処置（検査）''
		when addition_class =''9'' then ''導入期''
		when addition_class =''10'' then ''休日''
		when addition_class =''11'' then ''時間外''
		when addition_class =''12'' then ''汎用''
	 else  ''''
	end as addition_class_name
from
  tmp left outer join mst_addition on tmp.cd = mst_addition.addition_cd::text and is_disp = ''1'' and is_del = ''0''
order by json_idx

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
	b.ord_no as ordnob,
	b.treat_date as treat_date,
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
	', 2, '[{"preview": "休日", "can_calc": "0", "data_code": "addition_class", "data_name": "種別区分", "data_type": "string", "conv_table": [{"code": "1", "disp": "施設", "item": "施設"}, {"code": "2", "disp": "患者（困）", "item": "患者（困）"}, {"code": "3", "disp": "患者（病）", "item": "患者（病）"}, {"code": "4", "disp": "ろ過", "item": "ろ過"}, {"code": "5", "disp": "長時間", "item": "長時間"}, {"code": "6", "disp": "薬剤", "item": "薬剤"}, {"code": "7", "disp": "処置（イベント）", "item": "処置（イベント）"}, {"code": "8", "disp": "処置（検査）", "item": "処置（検査）"}, {"code": "9", "disp": "導入期", "item": "導入期"}, {"code": "10", "disp": "休日", "item": "休日"}, {"code": "11", "disp": "時間外", "item": "時間外"}, {"code": "12", "disp": "汎用", "item": "汎用"}], "data_class": "加算・管理料", "field_name": "addition_class", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "休日加算", "can_calc": "0", "data_code": "name", "data_name": "加算・管理料名称", "data_type": "string", "conv_table": [], "data_class": "加算・管理料", "field_name": "name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_addition_in_hospital_cd_1", "data_name": "加算・管理料連携コード１", "data_type": "string", "conv_table": [], "data_class": "加算・管理料", "field_name": "rst_addition_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_addition_in_hospital_cd_2", "data_name": "加算・管理料連携コード２", "data_type": "string", "conv_table": [], "data_class": "加算・管理料", "field_name": "rst_addition_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_addition_in_hospital_cd_3", "data_name": "加算・管理料連携コード３", "data_type": "string", "conv_table": [], "data_class": "加算・管理料", "field_name": "rst_addition_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": []}', '実績（治療中）：加算 @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (178, 'with checklist_cd_record as (
  select
    rst_checklist_info->>''checklist_cd'' as cd
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
  order by occur_date limit 1
)
, setting_tbl as (
  select
    checklist_settings
  from
    mst_checklist
  where
    checklist_cd::text in (select cd from checklist_cd_record)
    and is_del = ''0''
    and is_disp = ''1''
)
, setting_tbl_expand as
(
  select
    checklist_setting
    ,json_idx
  from
    setting_tbl
    cross join lateral jsonb_array_elements(checklist_settings) with ordinality as tmp(checklist_setting, json_idx)
)
, row_to_col_tbl as
(
  select
    array_agg(is_check order by cast(rst_checklist_info->>''item_number'' as integer)) as is_checks
    ,array_agg(rst_class order by cast(rst_checklist_info->>''item_number'' as integer)) as rst_classes
    ,array_agg(list_cd order by cast(rst_checklist_info->>''item_number'' as integer)) as list_cds
    ,array_agg(func_class order by cast(rst_checklist_info->>''item_number'' as integer)) as func_classes
    ,array_agg(rst_checklist_info order by cast(rst_checklist_info->>''item_number'' as integer)) as check_infos
    ,array_agg(reg_staff_info order by cast(rst_checklist_info->>''item_number'' as integer)) as staff_infos
    ,array_agg(occur_date order by cast(rst_checklist_info->>''item_number'' as integer)) as occur_dates
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
    and list_cd = 1
)

select
@ordNo AS ord_no,
  checklist_setting->>''list_cd'' as list_cd
  ,checklist_setting->>''list_name'' as list_name
  ,checklist_setting->>''dialysis_prog_name'' as dialysis_prog_name

  ,check_infos[1]->>''name'' as item_name_1
  ,case
    when checklist_setting->''funclist''->0->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->0->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_1
  ,checklist_setting->''funclist''->0->>''list_name'' as class_code_name_1
  ,is_checks[1] as is_check_1
  ,staff_infos[1]->>''reg_staff_cd'' as reg_staff_cd_1
  ,occur_dates[1] as occur_date_1
  
  ,check_infos[2]->>''name'' as item_name_2
  ,case
    when checklist_setting->''funclist''->1->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->1->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_2
  ,checklist_setting->''funclist''->1->>''list_name'' as class_code_name_2
  ,is_checks[2] as is_check_2
  ,staff_infos[2]->>''reg_staff_cd'' as reg_staff_cd_2
  ,occur_dates[2] as occur_date_2

  ,check_infos[3]->>''name'' as item_name_3
  ,case
    when checklist_setting->''funclist''->2->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->2->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_3
  ,checklist_setting->''funclist''->2->>''list_name'' as class_code_name_3
  ,is_checks[3] as is_check_3
  ,staff_infos[3]->>''reg_staff_cd'' as reg_staff_cd_3
  ,occur_dates[3] as occur_date_3

  ,check_infos[4]->>''name'' as item_name_4
  ,case
    when checklist_setting->''funclist''->3->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->3->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_4
  ,checklist_setting->''funclist''->3->>''list_name'' as class_code_name_4
  ,is_checks[4] as is_check_4
  ,staff_infos[4]->>''reg_staff_cd'' as reg_staff_cd_4
  ,occur_dates[4] as occur_date_4

  ,check_infos[5]->>''name'' as item_name_5
  ,case
    when checklist_setting->''funclist''->4->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->4->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_5
  ,checklist_setting->''funclist''->4->>''list_name'' as class_code_name_5
  ,is_checks[5] as is_check_5
  ,staff_infos[5]->>''reg_staff_cd'' as reg_staff_cd_5
  ,occur_dates[5] as occur_date_5

  ,check_infos[6]->>''name'' as item_name_6
  ,case
    when checklist_setting->''funclist''->5->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->5->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_6
  ,checklist_setting->''funclist''->5->>''list_name'' as class_code_name_6
  ,is_checks[6] as is_check_6
  ,staff_infos[6]->>''reg_staff_cd'' as reg_staff_cd_6
  ,occur_dates[6] as occur_date_6

  ,check_infos[7]->>''name'' as item_name_7
  ,case
    when checklist_setting->''funclist''->6->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->6->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_7
  ,checklist_setting->''funclist''->6->>''list_name'' as class_code_name_7
  ,is_checks[7] as is_check_7
  ,staff_infos[7]->>''reg_staff_cd'' as reg_staff_cd_7
  ,occur_dates[7] as occur_date_7

  ,check_infos[8]->>''name'' as item_name_8
  ,case
    when checklist_setting->''funclist''->7->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->7->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_8
  ,checklist_setting->''funclist''->7->>''list_name'' as class_code_name_8
  ,is_checks[8] as is_check_8
  ,staff_infos[8]->>''reg_staff_cd'' as reg_staff_cd_8
  ,occur_dates[8] as occur_date_8

  ,check_infos[9]->>''name'' as item_name_9
  ,case
    when checklist_setting->''funclist''->8->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->8->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_9
  ,checklist_setting->''funclist''->8->>''list_name'' as class_code_name_9
  ,is_checks[9] as is_check_9
  ,staff_infos[9]->>''reg_staff_cd'' as reg_staff_cd_9
  ,occur_dates[9] as occur_date_9

  ,check_infos[10]->>''name'' as item_name_10
  ,case
    when checklist_setting->''funclist''->9->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->9->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_10
  ,checklist_setting->''funclist''->9->>''list_name'' as class_code_name_10
  ,is_checks[10] as is_check_10
  ,staff_infos[10]->>''reg_staff_cd'' as reg_staff_cd_10
  ,occur_dates[10] as occur_date_10
from
  row_to_col_tbl cross join (select * from setting_tbl_expand where checklist_setting->>''list_cd'' = ''1'') as tmp
;', 2, '[{"preview": "始業時点検", "can_calc": "0", "data_code": "list_name", "data_name": "リスト名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "list_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析開始前", "can_calc": "0", "data_code": "dialysis_prog_name", "data_name": "透析工程", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "dialysis_prog_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "血液浄化器", "can_calc": "0", "data_code": "item_name_1", "data_name": "項目1名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "item_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析条件", "can_calc": "0", "data_code": "func_code_name_1", "data_name": "項目1機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "func_code_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ダイアライザ", "can_calc": "0", "data_code": "class_code_name_1", "data_name": "項目1分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "class_code_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_1", "data_name": "項目1チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト1", "field_name": "is_check_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_1", "data_name": "項目1チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "reg_staff_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:14", "can_calc": "0", "data_code": "occur_date_1", "data_name": "項目1チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト1", "field_name": "occur_date_1", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "回路", "can_calc": "0", "data_code": "item_name_2", "data_name": "項目2名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "item_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "医療材料リスト", "can_calc": "0", "data_code": "func_code_name_2", "data_name": "項目2機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "func_code_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "血液回路", "can_calc": "0", "data_code": "class_code_name_2", "data_name": "項目2分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "class_code_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_2", "data_name": "項目2チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト1", "field_name": "is_check_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_2", "data_name": "項目2チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "reg_staff_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:14", "can_calc": "0", "data_code": "occur_date_2", "data_name": "項目2チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト1", "field_name": "occur_date_2", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "接続", "can_calc": "0", "data_code": "item_name_3", "data_name": "項目3名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "item_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_3", "data_name": "項目3機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "func_code_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_3", "data_name": "項目3分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "class_code_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_3", "data_name": "項目3チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト1", "field_name": "is_check_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士３", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_3", "data_name": "項目3チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "reg_staff_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:14", "can_calc": "0", "data_code": "occur_date_3", "data_name": "項目3チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト1", "field_name": "occur_date_3", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "洗浄", "can_calc": "0", "data_code": "item_name_4", "data_name": "項目4名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "item_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_4", "data_name": "項目4機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "func_code_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_4", "data_name": "項目4分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "class_code_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_4", "data_name": "項目4チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト1", "field_name": "is_check_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士４", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_4", "data_name": "項目4チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "reg_staff_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:14", "can_calc": "0", "data_code": "occur_date_4", "data_name": "項目4チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト1", "field_name": "occur_date_4", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "クレンメ状態", "can_calc": "0", "data_code": "item_name_5", "data_name": "項目5名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "item_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_5", "data_name": "項目5機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "func_code_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_5", "data_name": "項目5分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "class_code_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_5", "data_name": "項目5チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト1", "field_name": "is_check_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士５", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_5", "data_name": "項目5チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "reg_staff_cd_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:14", "can_calc": "0", "data_code": "occur_date_5", "data_name": "項目5チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト1", "field_name": "occur_date_5", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "気泡除去", "can_calc": "0", "data_code": "item_name_6", "data_name": "項目6名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "item_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_6", "data_name": "項目6機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "func_code_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_6", "data_name": "項目6分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "class_code_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_6", "data_name": "項目6チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト1", "field_name": "is_check_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士６", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_6", "data_name": "項目6チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "reg_staff_cd_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:14", "can_calc": "0", "data_code": "occur_date_6", "data_name": "項目6チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト1", "field_name": "occur_date_6", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "カプラ向き", "can_calc": "0", "data_code": "item_name_7", "data_name": "項目7名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "item_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_7", "data_name": "項目7機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "func_code_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_7", "data_name": "項目7分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "class_code_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_7", "data_name": "項目7チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト1", "field_name": "is_check_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士７", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_7", "data_name": "項目7チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "reg_staff_cd_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:14", "can_calc": "0", "data_code": "occur_date_7", "data_name": "項目7チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト1", "field_name": "occur_date_7", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "液面レベル", "can_calc": "0", "data_code": "item_name_8", "data_name": "項目8名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "item_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_8", "data_name": "項目8機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "func_code_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_8", "data_name": "項目8分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "class_code_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_8", "data_name": "項目8チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト1", "field_name": "is_check_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士８", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_8", "data_name": "項目8チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "reg_staff_cd_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:14", "can_calc": "0", "data_code": "occur_date_8", "data_name": "項目8チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト1", "field_name": "occur_date_8", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "監視装置状態", "can_calc": "0", "data_code": "item_name_9", "data_name": "項目9名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "item_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_9", "data_name": "項目9機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "func_code_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_9", "data_name": "項目9分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "class_code_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_9", "data_name": "項目9チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト1", "field_name": "is_check_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士９", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_9", "data_name": "項目9チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "reg_staff_cd_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:14", "can_calc": "0", "data_code": "occur_date_9", "data_name": "項目9チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト1", "field_name": "occur_date_9", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針、固定テープ", "can_calc": "0", "data_code": "item_name_10", "data_name": "項目10名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "item_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_10", "data_name": "項目10機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "func_code_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_10", "data_name": "項目10分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "class_code_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_10", "data_name": "項目10チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト1", "field_name": "is_check_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１０", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_10", "data_name": "項目10チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "reg_staff_cd_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:14", "can_calc": "0", "data_code": "occur_date_10", "data_name": "項目10チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト1", "field_name": "occur_date_10", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": []}', '実績（治療中）：チェックリスト1 @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (179, 'WITH DATA AS (

select
    @ordNo as ord_no_t
		,s.rst_weight_info ->> ''ctr'' as last_ctr
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
    AND ord.rst_start_date > s.rst_start_date
    AND s.is_del = ''0''
  )
WHERE
  ord.ord_no = @ordNo
AND
  ord.is_del = ''0''
AND ord.rst_dialysis_state >''0'' and ord.rst_dialysis_state <''6''

ORDER BY
  s.rst_start_date DESC

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
	b.ord_no as ordnob,
	b.treat_date as treat_date,
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
	', 2, '[{"preview": "56.78", "can_calc": "1", "data_code": "last_weight_before", "data_name": "前体重(前回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "last_weight_before", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/3/12  8:21", "can_calc": "1", "data_code": "last_weight_before_date", "data_name": "前体重測定日時(前回)", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "last_weight_before_date", "disp_format": "yyyy/mm/dd", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "56.78", "can_calc": "1", "data_code": "last_weight_after", "data_name": "後体重(前回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "last_weight_after", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/3/12  8:21", "can_calc": "1", "data_code": "last_weight_after_date", "data_name": "後体重測定日時(前回)", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "last_weight_after_date", "disp_format": "yyyy/mm/dd", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "last_ctr", "data_name": "CTR(前回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "last_ctr", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/3/12  8:21", "can_calc": "1", "data_code": "last_ctr_measure_date", "data_name": "CTR測定日時(前回)", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "last_ctr_measure_date", "disp_format": "yyyy/mm/dd", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "56.78", "can_calc": "1", "data_code": "last_ctr_weight", "data_name": "CTR測定時体重(前回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "last_ctr_weight", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": []}', '実績（治療中）(前回体重)', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (180, 'with checklist_cd_record as (
  select
    rst_checklist_info->>''checklist_cd'' as cd
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
  order by occur_date limit 1
)
, setting_tbl as (
  select
    checklist_settings
  from
    mst_checklist
  where
    checklist_cd::text in (select cd from checklist_cd_record)
    and is_del = ''0''
    and is_disp = ''1''
)
, setting_tbl_expand as
(
  select
    checklist_setting
    ,json_idx
  from
    setting_tbl
    cross join lateral jsonb_array_elements(checklist_settings) with ordinality as tmp(checklist_setting, json_idx)
)
, row_to_col_tbl as
(
  select
    array_agg(is_check order by cast(rst_checklist_info->>''item_number'' as integer)) as is_checks
    ,array_agg(rst_class order by cast(rst_checklist_info->>''item_number'' as integer)) as rst_classes
    ,array_agg(list_cd order by cast(rst_checklist_info->>''item_number'' as integer)) as list_cds
    ,array_agg(func_class order by cast(rst_checklist_info->>''item_number'' as integer)) as func_classes
    ,array_agg(rst_checklist_info order by cast(rst_checklist_info->>''item_number'' as integer)) as check_infos
    ,array_agg(reg_staff_info order by cast(rst_checklist_info->>''item_number'' as integer)) as staff_infos
    ,array_agg(occur_date order by cast(rst_checklist_info->>''item_number'' as integer)) as occur_dates
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
    and list_cd = 2
)

select
@ordNo AS ord_no,
  checklist_setting->>''list_cd'' as list_cd
  ,checklist_setting->>''list_name'' as list_name
  ,checklist_setting->>''dialysis_prog_name'' as dialysis_prog_name

  ,check_infos[1]->>''name'' as item_name_1
  ,case
    when checklist_setting->''funclist''->0->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->0->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_1
  ,checklist_setting->''funclist''->0->>''list_name'' as class_code_name_1
  ,is_checks[1] as is_check_1
  ,staff_infos[1]->>''reg_staff_cd'' as reg_staff_cd_1
  ,occur_dates[1] as occur_date_1
  
  ,check_infos[2]->>''name'' as item_name_2
  ,case
    when checklist_setting->''funclist''->1->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->1->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_2
  ,checklist_setting->''funclist''->1->>''list_name'' as class_code_name_2
  ,is_checks[2] as is_check_2
  ,staff_infos[2]->>''reg_staff_cd'' as reg_staff_cd_2
  ,occur_dates[2] as occur_date_2

  ,check_infos[3]->>''name'' as item_name_3
  ,case
    when checklist_setting->''funclist''->2->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->2->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_3
  ,checklist_setting->''funclist''->2->>''list_name'' as class_code_name_3
  ,is_checks[3] as is_check_3
  ,staff_infos[3]->>''reg_staff_cd'' as reg_staff_cd_3
  ,occur_dates[3] as occur_date_3

  ,check_infos[4]->>''name'' as item_name_4
  ,case
    when checklist_setting->''funclist''->3->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->3->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_4
  ,checklist_setting->''funclist''->3->>''list_name'' as class_code_name_4
  ,is_checks[4] as is_check_4
  ,staff_infos[4]->>''reg_staff_cd'' as reg_staff_cd_4
  ,occur_dates[4] as occur_date_4

  ,check_infos[5]->>''name'' as item_name_5
  ,case
    when checklist_setting->''funclist''->4->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->4->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_5
  ,checklist_setting->''funclist''->4->>''list_name'' as class_code_name_5
  ,is_checks[5] as is_check_5
  ,staff_infos[5]->>''reg_staff_cd'' as reg_staff_cd_5
  ,occur_dates[5] as occur_date_5

  ,check_infos[6]->>''name'' as item_name_6
  ,case
    when checklist_setting->''funclist''->5->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->5->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_6
  ,checklist_setting->''funclist''->5->>''list_name'' as class_code_name_6
  ,is_checks[6] as is_check_6
  ,staff_infos[6]->>''reg_staff_cd'' as reg_staff_cd_6
  ,occur_dates[6] as occur_date_6

  ,check_infos[7]->>''name'' as item_name_7
  ,case
    when checklist_setting->''funclist''->6->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->6->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_7
  ,checklist_setting->''funclist''->6->>''list_name'' as class_code_name_7
  ,is_checks[7] as is_check_7
  ,staff_infos[7]->>''reg_staff_cd'' as reg_staff_cd_7
  ,occur_dates[7] as occur_date_7

  ,check_infos[8]->>''name'' as item_name_8
  ,case
    when checklist_setting->''funclist''->7->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->7->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_8
  ,checklist_setting->''funclist''->7->>''list_name'' as class_code_name_8
  ,is_checks[8] as is_check_8
  ,staff_infos[8]->>''reg_staff_cd'' as reg_staff_cd_8
  ,occur_dates[8] as occur_date_8

  ,check_infos[9]->>''name'' as item_name_9
  ,case
    when checklist_setting->''funclist''->8->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->8->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_9
  ,checklist_setting->''funclist''->8->>''list_name'' as class_code_name_9
  ,is_checks[9] as is_check_9
  ,staff_infos[9]->>''reg_staff_cd'' as reg_staff_cd_9
  ,occur_dates[9] as occur_date_9

  ,check_infos[10]->>''name'' as item_name_10
  ,case
    when checklist_setting->''funclist''->9->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->9->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_10
  ,checklist_setting->''funclist''->9->>''list_name'' as class_code_name_10
  ,is_checks[10] as is_check_10
  ,staff_infos[10]->>''reg_staff_cd'' as reg_staff_cd_10
  ,occur_dates[10] as occur_date_10
from
  row_to_col_tbl cross join (select * from setting_tbl_expand where checklist_setting->>''list_cd'' = ''2'') as tmp
;
', 2, '[{"preview": "シャント音", "can_calc": "0", "data_code": "list_name", "data_name": "リスト名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "list_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析開始前", "can_calc": "0", "data_code": "dialysis_prog_name", "data_name": "透析工程", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "dialysis_prog_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "良好", "can_calc": "0", "data_code": "item_name_1", "data_name": "項目1名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "item_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_1", "data_name": "項目1機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "func_code_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_1", "data_name": "項目1分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "class_code_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_1", "data_name": "項目1チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト2", "field_name": "is_check_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_1", "data_name": "項目1チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "reg_staff_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:15", "can_calc": "0", "data_code": "occur_date_1", "data_name": "項目1チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト2", "field_name": "occur_date_1", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "狭窄", "can_calc": "0", "data_code": "item_name_2", "data_name": "項目2名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "item_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_2", "data_name": "項目2機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "func_code_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_2", "data_name": "項目2分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "class_code_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_2", "data_name": "項目2チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト2", "field_name": "is_check_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_2", "data_name": "項目2チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "reg_staff_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:15", "can_calc": "0", "data_code": "occur_date_2", "data_name": "項目2チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト2", "field_name": "occur_date_2", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "拍動", "can_calc": "0", "data_code": "item_name_3", "data_name": "項目3名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "item_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_3", "data_name": "項目3機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "func_code_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_3", "data_name": "項目3分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "class_code_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_3", "data_name": "項目3チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト2", "field_name": "is_check_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士３", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_3", "data_name": "項目3チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "reg_staff_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:15", "can_calc": "0", "data_code": "occur_date_3", "data_name": "項目3チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト2", "field_name": "occur_date_3", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "閉塞", "can_calc": "0", "data_code": "item_name_4", "data_name": "項目4名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "item_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_4", "data_name": "項目4機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "func_code_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_4", "data_name": "項目4分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "class_code_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_4", "data_name": "項目4チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト2", "field_name": "is_check_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士４", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_4", "data_name": "項目4チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "reg_staff_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:15", "can_calc": "0", "data_code": "occur_date_4", "data_name": "項目4チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト2", "field_name": "occur_date_4", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_5", "data_name": "項目5名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "item_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_5", "data_name": "項目5機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "func_code_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_5", "data_name": "項目5分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "class_code_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_5", "data_name": "項目5チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト2", "field_name": "is_check_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士５", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_5", "data_name": "項目5チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "reg_staff_cd_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_5", "data_name": "項目5チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト2", "field_name": "occur_date_5", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_6", "data_name": "項目6名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "item_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_6", "data_name": "項目6機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "func_code_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_6", "data_name": "項目6分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "class_code_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_6", "data_name": "項目6チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト2", "field_name": "is_check_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士６", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_6", "data_name": "項目6チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "reg_staff_cd_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_6", "data_name": "項目6チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト2", "field_name": "occur_date_6", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_7", "data_name": "項目7名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "item_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_7", "data_name": "項目7機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "func_code_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_7", "data_name": "項目7分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "class_code_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_7", "data_name": "項目7チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト2", "field_name": "is_check_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士７", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_7", "data_name": "項目7チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "reg_staff_cd_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_7", "data_name": "項目7チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト2", "field_name": "occur_date_7", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_8", "data_name": "項目8名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "item_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_8", "data_name": "項目8機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "func_code_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_8", "data_name": "項目8分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "class_code_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_8", "data_name": "項目8チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト2", "field_name": "is_check_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士８", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_8", "data_name": "項目8チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "reg_staff_cd_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_8", "data_name": "項目8チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト2", "field_name": "occur_date_8", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_9", "data_name": "項目9名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "item_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_9", "data_name": "項目9機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "func_code_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_9", "data_name": "項目9分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "class_code_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_9", "data_name": "項目9チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト2", "field_name": "is_check_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士９", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_9", "data_name": "項目9チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "reg_staff_cd_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_9", "data_name": "項目9チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト2", "field_name": "occur_date_9", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_10", "data_name": "項目10名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "item_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_10", "data_name": "項目10機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "func_code_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_10", "data_name": "項目10分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "class_code_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_10", "data_name": "項目10チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト2", "field_name": "is_check_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１０", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_10", "data_name": "項目10チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "reg_staff_cd_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_10", "data_name": "項目10チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト2", "field_name": "occur_date_10", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": []}', '実績（治療中）：チェックリスト2 @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (181, 'with checklist_cd_record as (
  select
    rst_checklist_info->>''checklist_cd'' as cd
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
  order by occur_date limit 1
)
, setting_tbl as (
  select
    checklist_settings
  from
    mst_checklist
  where
    checklist_cd::text in (select cd from checklist_cd_record)
    and is_del = ''0''
    and is_disp = ''1''
)
, setting_tbl_expand as
(
  select
    checklist_setting
    ,json_idx
  from
    setting_tbl
    cross join lateral jsonb_array_elements(checklist_settings) with ordinality as tmp(checklist_setting, json_idx)
)
, row_to_col_tbl as
(
  select
    array_agg(is_check order by cast(rst_checklist_info->>''item_number'' as integer)) as is_checks
    ,array_agg(rst_class order by cast(rst_checklist_info->>''item_number'' as integer)) as rst_classes
    ,array_agg(list_cd order by cast(rst_checklist_info->>''item_number'' as integer)) as list_cds
    ,array_agg(func_class order by cast(rst_checklist_info->>''item_number'' as integer)) as func_classes
    ,array_agg(rst_checklist_info order by cast(rst_checklist_info->>''item_number'' as integer)) as check_infos
    ,array_agg(reg_staff_info order by cast(rst_checklist_info->>''item_number'' as integer)) as staff_infos
    ,array_agg(occur_date order by cast(rst_checklist_info->>''item_number'' as integer)) as occur_dates
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
    and list_cd = 3
)

select
@ordNo AS ord_no,
  checklist_setting->>''list_cd'' as list_cd
  ,checklist_setting->>''list_name'' as list_name
  ,checklist_setting->>''dialysis_prog_name'' as dialysis_prog_name

  ,check_infos[1]->>''name'' as item_name_1
  ,case
    when checklist_setting->''funclist''->0->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->0->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_1
  ,checklist_setting->''funclist''->0->>''list_name'' as class_code_name_1
  ,is_checks[1] as is_check_1
  ,staff_infos[1]->>''reg_staff_cd'' as reg_staff_cd_1
  ,occur_dates[1] as occur_date_1
  
  ,check_infos[2]->>''name'' as item_name_2
  ,case
    when checklist_setting->''funclist''->1->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->1->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_2
  ,checklist_setting->''funclist''->1->>''list_name'' as class_code_name_2
  ,is_checks[2] as is_check_2
  ,staff_infos[2]->>''reg_staff_cd'' as reg_staff_cd_2
  ,occur_dates[2] as occur_date_2

  ,check_infos[3]->>''name'' as item_name_3
  ,case
    when checklist_setting->''funclist''->2->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->2->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_3
  ,checklist_setting->''funclist''->2->>''list_name'' as class_code_name_3
  ,is_checks[3] as is_check_3
  ,staff_infos[3]->>''reg_staff_cd'' as reg_staff_cd_3
  ,occur_dates[3] as occur_date_3

  ,check_infos[4]->>''name'' as item_name_4
  ,case
    when checklist_setting->''funclist''->3->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->3->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_4
  ,checklist_setting->''funclist''->3->>''list_name'' as class_code_name_4
  ,is_checks[4] as is_check_4
  ,staff_infos[4]->>''reg_staff_cd'' as reg_staff_cd_4
  ,occur_dates[4] as occur_date_4

  ,check_infos[5]->>''name'' as item_name_5
  ,case
    when checklist_setting->''funclist''->4->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->4->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_5
  ,checklist_setting->''funclist''->4->>''list_name'' as class_code_name_5
  ,is_checks[5] as is_check_5
  ,staff_infos[5]->>''reg_staff_cd'' as reg_staff_cd_5
  ,occur_dates[5] as occur_date_5

  ,check_infos[6]->>''name'' as item_name_6
  ,case
    when checklist_setting->''funclist''->5->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->5->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_6
  ,checklist_setting->''funclist''->5->>''list_name'' as class_code_name_6
  ,is_checks[6] as is_check_6
  ,staff_infos[6]->>''reg_staff_cd'' as reg_staff_cd_6
  ,occur_dates[6] as occur_date_6

  ,check_infos[7]->>''name'' as item_name_7
  ,case
    when checklist_setting->''funclist''->6->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->6->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_7
  ,checklist_setting->''funclist''->6->>''list_name'' as class_code_name_7
  ,is_checks[7] as is_check_7
  ,staff_infos[7]->>''reg_staff_cd'' as reg_staff_cd_7
  ,occur_dates[7] as occur_date_7

  ,check_infos[8]->>''name'' as item_name_8
  ,case
    when checklist_setting->''funclist''->7->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->7->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_8
  ,checklist_setting->''funclist''->7->>''list_name'' as class_code_name_8
  ,is_checks[8] as is_check_8
  ,staff_infos[8]->>''reg_staff_cd'' as reg_staff_cd_8
  ,occur_dates[8] as occur_date_8

  ,check_infos[9]->>''name'' as item_name_9
  ,case
    when checklist_setting->''funclist''->8->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->8->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_9
  ,checklist_setting->''funclist''->8->>''list_name'' as class_code_name_9
  ,is_checks[9] as is_check_9
  ,staff_infos[9]->>''reg_staff_cd'' as reg_staff_cd_9
  ,occur_dates[9] as occur_date_9

  ,check_infos[10]->>''name'' as item_name_10
  ,case
    when checklist_setting->''funclist''->9->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->9->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_10
  ,checklist_setting->''funclist''->9->>''list_name'' as class_code_name_10
  ,is_checks[10] as is_check_10
  ,staff_infos[10]->>''reg_staff_cd'' as reg_staff_cd_10
  ,occur_dates[10] as occur_date_10
from
  row_to_col_tbl cross join (select * from setting_tbl_expand where checklist_setting->>''list_cd'' = ''3'') as tmp
;
', 2, '[{"preview": "透析開始直後", "can_calc": "0", "data_code": "list_name", "data_name": "リスト名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "list_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "dialysis_prog_name", "data_name": "透析工程", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "dialysis_prog_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "動脈側脱血", "can_calc": "0", "data_code": "item_name_1", "data_name": "項目1名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "item_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_1", "data_name": "項目1機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "func_code_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_1", "data_name": "項目1分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "class_code_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_1", "data_name": "項目1チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト3", "field_name": "is_check_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_1", "data_name": "項目1チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "reg_staff_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:45", "can_calc": "0", "data_code": "occur_date_1", "data_name": "項目1チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト3", "field_name": "occur_date_1", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈圧", "can_calc": "0", "data_code": "item_name_2", "data_name": "項目2名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "item_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_2", "data_name": "項目2機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "func_code_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_2", "data_name": "項目2分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "class_code_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_2", "data_name": "項目2チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト3", "field_name": "is_check_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_2", "data_name": "項目2チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "reg_staff_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:45", "can_calc": "0", "data_code": "occur_date_2", "data_name": "項目2チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト3", "field_name": "occur_date_2", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側返血", "can_calc": "0", "data_code": "item_name_3", "data_name": "項目3名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "item_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_3", "data_name": "項目3機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "func_code_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_3", "data_name": "項目3分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "class_code_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_3", "data_name": "項目3チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト3", "field_name": "is_check_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士３", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_3", "data_name": "項目3チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "reg_staff_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:45", "can_calc": "0", "data_code": "occur_date_3", "data_name": "項目3チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト3", "field_name": "occur_date_3", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "警報機能確認", "can_calc": "0", "data_code": "item_name_4", "data_name": "項目4名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "item_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_4", "data_name": "項目4機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "func_code_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_4", "data_name": "項目4分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "class_code_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_4", "data_name": "項目4チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト3", "field_name": "is_check_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士４", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_4", "data_name": "項目4チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "reg_staff_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:45", "can_calc": "0", "data_code": "occur_date_4", "data_name": "項目4チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト3", "field_name": "occur_date_4", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "血液回路の状態", "can_calc": "0", "data_code": "item_name_5", "data_name": "項目5名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "item_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_5", "data_name": "項目5機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "func_code_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_5", "data_name": "項目5分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "class_code_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_5", "data_name": "項目5チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト3", "field_name": "is_check_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士５", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_5", "data_name": "項目5チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "reg_staff_cd_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:45", "can_calc": "0", "data_code": "occur_date_5", "data_name": "項目5チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト3", "field_name": "occur_date_5", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺部の状態", "can_calc": "0", "data_code": "item_name_6", "data_name": "項目6名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "item_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_6", "data_name": "項目6機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "func_code_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_6", "data_name": "項目6分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "class_code_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_6", "data_name": "項目6チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト3", "field_name": "is_check_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士６", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_6", "data_name": "項目6チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "reg_staff_cd_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:45", "can_calc": "0", "data_code": "occur_date_6", "data_name": "項目6チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト3", "field_name": "occur_date_6", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "投与量・速度確認", "can_calc": "0", "data_code": "item_name_7", "data_name": "項目7名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "item_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_7", "data_name": "項目7機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "func_code_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_7", "data_name": "項目7分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "class_code_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_7", "data_name": "項目7チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト3", "field_name": "is_check_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士７", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_7", "data_name": "項目7チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "reg_staff_cd_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:45", "can_calc": "0", "data_code": "occur_date_7", "data_name": "項目7チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト3", "field_name": "occur_date_7", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_8", "data_name": "項目8名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "item_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_8", "data_name": "項目8機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "func_code_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_8", "data_name": "項目8分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "class_code_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_8", "data_name": "項目8チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト3", "field_name": "is_check_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士８", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_8", "data_name": "項目8チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "reg_staff_cd_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_8", "data_name": "項目8チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト3", "field_name": "occur_date_8", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_9", "data_name": "項目9名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "item_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_9", "data_name": "項目9機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "func_code_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_9", "data_name": "項目9分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "class_code_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_9", "data_name": "項目9チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト3", "field_name": "is_check_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士９", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_9", "data_name": "項目9チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "reg_staff_cd_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_9", "data_name": "項目9チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト3", "field_name": "occur_date_9", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_10", "data_name": "項目10名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "item_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_10", "data_name": "項目10機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "func_code_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_10", "data_name": "項目10分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "class_code_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_10", "data_name": "項目10チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト3", "field_name": "is_check_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１０", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_10", "data_name": "項目10チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "reg_staff_cd_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_10", "data_name": "項目10チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト3", "field_name": "occur_date_10", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": []}', '実績（治療中）：チェックリスト3 @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (182, 'with checklist_cd_record as (
  select
    rst_checklist_info->>''checklist_cd'' as cd
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
  order by occur_date limit 1
)
, setting_tbl as (
  select
    checklist_settings
  from
    mst_checklist
  where
    checklist_cd::text in (select cd from checklist_cd_record)
    and is_del = ''0''
    and is_disp = ''1''
)
, setting_tbl_expand as
(
  select
    checklist_setting
    ,json_idx
  from
    setting_tbl
    cross join lateral jsonb_array_elements(checklist_settings) with ordinality as tmp(checklist_setting, json_idx)
)
, row_to_col_tbl as
(
  select
    array_agg(is_check order by cast(rst_checklist_info->>''item_number'' as integer)) as is_checks
    ,array_agg(rst_class order by cast(rst_checklist_info->>''item_number'' as integer)) as rst_classes
    ,array_agg(list_cd order by cast(rst_checklist_info->>''item_number'' as integer)) as list_cds
    ,array_agg(func_class order by cast(rst_checklist_info->>''item_number'' as integer)) as func_classes
    ,array_agg(rst_checklist_info order by cast(rst_checklist_info->>''item_number'' as integer)) as check_infos
    ,array_agg(reg_staff_info order by cast(rst_checklist_info->>''item_number'' as integer)) as staff_infos
    ,array_agg(occur_date order by cast(rst_checklist_info->>''item_number'' as integer)) as occur_dates
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
    and list_cd = 4
)

select
@ordNo AS ord_no,
  checklist_setting->>''list_cd'' as list_cd
  ,checklist_setting->>''list_name'' as list_name
  ,checklist_setting->>''dialysis_prog_name'' as dialysis_prog_name

  ,check_infos[1]->>''name'' as item_name_1
  ,case
    when checklist_setting->''funclist''->0->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->0->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_1
  ,checklist_setting->''funclist''->0->>''list_name'' as class_code_name_1
  ,is_checks[1] as is_check_1
  ,staff_infos[1]->>''reg_staff_cd'' as reg_staff_cd_1
  ,occur_dates[1] as occur_date_1
  
  ,check_infos[2]->>''name'' as item_name_2
  ,case
    when checklist_setting->''funclist''->1->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->1->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_2
  ,checklist_setting->''funclist''->1->>''list_name'' as class_code_name_2
  ,is_checks[2] as is_check_2
  ,staff_infos[2]->>''reg_staff_cd'' as reg_staff_cd_2
  ,occur_dates[2] as occur_date_2

  ,check_infos[3]->>''name'' as item_name_3
  ,case
    when checklist_setting->''funclist''->2->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->2->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_3
  ,checklist_setting->''funclist''->2->>''list_name'' as class_code_name_3
  ,is_checks[3] as is_check_3
  ,staff_infos[3]->>''reg_staff_cd'' as reg_staff_cd_3
  ,occur_dates[3] as occur_date_3

  ,check_infos[4]->>''name'' as item_name_4
  ,case
    when checklist_setting->''funclist''->3->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->3->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_4
  ,checklist_setting->''funclist''->3->>''list_name'' as class_code_name_4
  ,is_checks[4] as is_check_4
  ,staff_infos[4]->>''reg_staff_cd'' as reg_staff_cd_4
  ,occur_dates[4] as occur_date_4

  ,check_infos[5]->>''name'' as item_name_5
  ,case
    when checklist_setting->''funclist''->4->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->4->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_5
  ,checklist_setting->''funclist''->4->>''list_name'' as class_code_name_5
  ,is_checks[5] as is_check_5
  ,staff_infos[5]->>''reg_staff_cd'' as reg_staff_cd_5
  ,occur_dates[5] as occur_date_5

  ,check_infos[6]->>''name'' as item_name_6
  ,case
    when checklist_setting->''funclist''->5->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->5->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_6
  ,checklist_setting->''funclist''->5->>''list_name'' as class_code_name_6
  ,is_checks[6] as is_check_6
  ,staff_infos[6]->>''reg_staff_cd'' as reg_staff_cd_6
  ,occur_dates[6] as occur_date_6

  ,check_infos[7]->>''name'' as item_name_7
  ,case
    when checklist_setting->''funclist''->6->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->6->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_7
  ,checklist_setting->''funclist''->6->>''list_name'' as class_code_name_7
  ,is_checks[7] as is_check_7
  ,staff_infos[7]->>''reg_staff_cd'' as reg_staff_cd_7
  ,occur_dates[7] as occur_date_7

  ,check_infos[8]->>''name'' as item_name_8
  ,case
    when checklist_setting->''funclist''->7->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->7->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_8
  ,checklist_setting->''funclist''->7->>''list_name'' as class_code_name_8
  ,is_checks[8] as is_check_8
  ,staff_infos[8]->>''reg_staff_cd'' as reg_staff_cd_8
  ,occur_dates[8] as occur_date_8

  ,check_infos[9]->>''name'' as item_name_9
  ,case
    when checklist_setting->''funclist''->8->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->8->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_9
  ,checklist_setting->''funclist''->8->>''list_name'' as class_code_name_9
  ,is_checks[9] as is_check_9
  ,staff_infos[9]->>''reg_staff_cd'' as reg_staff_cd_9
  ,occur_dates[9] as occur_date_9

  ,check_infos[10]->>''name'' as item_name_10
  ,case
    when checklist_setting->''funclist''->9->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->9->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_10
  ,checklist_setting->''funclist''->9->>''list_name'' as class_code_name_10
  ,is_checks[10] as is_check_10
  ,staff_infos[10]->>''reg_staff_cd'' as reg_staff_cd_10
  ,occur_dates[10] as occur_date_10
from
  row_to_col_tbl cross join (select * from setting_tbl_expand where checklist_setting->>''list_cd'' = ''4'') as tmp
;
', 2, '[{"preview": "透析中", "can_calc": "0", "data_code": "list_name", "data_name": "リスト名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "list_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "dialysis_prog_name", "data_name": "透析工程", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "dialysis_prog_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "一般状態の確認", "can_calc": "0", "data_code": "item_name_1", "data_name": "項目1名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "item_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_1", "data_name": "項目1機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "func_code_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_1", "data_name": "項目1分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "class_code_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_1", "data_name": "項目1チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト4", "field_name": "is_check_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_1", "data_name": "項目1チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "reg_staff_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:21", "can_calc": "0", "data_code": "occur_date_1", "data_name": "項目1チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト4", "field_name": "occur_date_1", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺部の確認", "can_calc": "0", "data_code": "item_name_2", "data_name": "項目2名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "item_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_2", "data_name": "項目2機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "func_code_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_2", "data_name": "項目2分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "class_code_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_2", "data_name": "項目2チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト4", "field_name": "is_check_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_2", "data_name": "項目2チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "reg_staff_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:21", "can_calc": "0", "data_code": "occur_date_2", "data_name": "項目2チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト4", "field_name": "occur_date_2", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "血液回路の状態", "can_calc": "0", "data_code": "item_name_3", "data_name": "項目3名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "item_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_3", "data_name": "項目3機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "func_code_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_3", "data_name": "項目3分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "class_code_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_3", "data_name": "項目3チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト4", "field_name": "is_check_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士３", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_3", "data_name": "項目3チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "reg_staff_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:21", "can_calc": "0", "data_code": "occur_date_3", "data_name": "項目3チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト4", "field_name": "occur_date_3", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "エアートラップ液面", "can_calc": "0", "data_code": "item_name_4", "data_name": "項目4名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "item_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_4", "data_name": "項目4機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "func_code_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_4", "data_name": "項目4分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "class_code_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_4", "data_name": "項目4チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト4", "field_name": "is_check_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士４", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_4", "data_name": "項目4チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "reg_staff_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:21", "can_calc": "0", "data_code": "occur_date_4", "data_name": "項目4チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト4", "field_name": "occur_date_4", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "凝血", "can_calc": "0", "data_code": "item_name_5", "data_name": "項目5名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "item_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_5", "data_name": "項目5機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "func_code_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_5", "data_name": "項目5分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "class_code_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_5", "data_name": "項目5チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト4", "field_name": "is_check_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士５", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_5", "data_name": "項目5チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "reg_staff_cd_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:21", "can_calc": "0", "data_code": "occur_date_5", "data_name": "項目5チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト4", "field_name": "occur_date_5", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "抗凝固薬注入量", "can_calc": "0", "data_code": "item_name_6", "data_name": "項目6名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "item_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_6", "data_name": "項目6機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "func_code_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_6", "data_name": "項目6分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "class_code_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_6", "data_name": "項目6チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト4", "field_name": "is_check_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士６", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_6", "data_name": "項目6チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "reg_staff_cd_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:21", "can_calc": "0", "data_code": "occur_date_6", "data_name": "項目6チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト4", "field_name": "occur_date_6", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析液流量の確認", "can_calc": "0", "data_code": "item_name_7", "data_name": "項目7名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "item_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_7", "data_name": "項目7機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "func_code_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_7", "data_name": "項目7分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "class_code_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_7", "data_name": "項目7チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト4", "field_name": "is_check_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士７", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_7", "data_name": "項目7チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "reg_staff_cd_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:21", "can_calc": "0", "data_code": "occur_date_7", "data_name": "項目7チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト4", "field_name": "occur_date_7", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_8", "data_name": "項目8名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "item_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_8", "data_name": "項目8機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "func_code_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_8", "data_name": "項目8分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "class_code_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_8", "data_name": "項目8チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト4", "field_name": "is_check_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士８", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_8", "data_name": "項目8チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "reg_staff_cd_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_8", "data_name": "項目8チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト4", "field_name": "occur_date_8", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_9", "data_name": "項目9名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "item_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_9", "data_name": "項目9機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "func_code_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_9", "data_name": "項目9分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "class_code_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_9", "data_name": "項目9チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト4", "field_name": "is_check_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士９", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_9", "data_name": "項目9チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "reg_staff_cd_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_9", "data_name": "項目9チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト4", "field_name": "occur_date_9", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_10", "data_name": "項目10名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "item_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_10", "data_name": "項目10機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "func_code_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_10", "data_name": "項目10分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "class_code_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_10", "data_name": "項目10チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト4", "field_name": "is_check_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１０", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_10", "data_name": "項目10チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "reg_staff_cd_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_10", "data_name": "項目10チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト4", "field_name": "occur_date_10", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": []}', '実績（治療中）：チェックリスト4 @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (183, 'with checklist_cd_record as (
  select
    rst_checklist_info->>''checklist_cd'' as cd
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
  order by occur_date limit 1
)
, setting_tbl as (
  select
    checklist_settings
  from
    mst_checklist
  where
    checklist_cd::text in (select cd from checklist_cd_record)
    and is_del = ''0''
    and is_disp = ''1''
)
, setting_tbl_expand as
(
  select
    checklist_setting
    ,json_idx
  from
    setting_tbl
    cross join lateral jsonb_array_elements(checklist_settings) with ordinality as tmp(checklist_setting, json_idx)
)
, row_to_col_tbl as
(
  select
    array_agg(is_check order by cast(rst_checklist_info->>''item_number'' as integer)) as is_checks
    ,array_agg(rst_class order by cast(rst_checklist_info->>''item_number'' as integer)) as rst_classes
    ,array_agg(list_cd order by cast(rst_checklist_info->>''item_number'' as integer)) as list_cds
    ,array_agg(func_class order by cast(rst_checklist_info->>''item_number'' as integer)) as func_classes
    ,array_agg(rst_checklist_info order by cast(rst_checklist_info->>''item_number'' as integer)) as check_infos
    ,array_agg(reg_staff_info order by cast(rst_checklist_info->>''item_number'' as integer)) as staff_infos
    ,array_agg(occur_date order by cast(rst_checklist_info->>''item_number'' as integer)) as occur_dates
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
    and list_cd = 5
)

select
@ordNo AS ord_no,
  checklist_setting->>''list_cd'' as list_cd
  ,checklist_setting->>''list_name'' as list_name
  ,checklist_setting->>''dialysis_prog_name'' as dialysis_prog_name

  ,check_infos[1]->>''name'' as item_name_1
  ,case
    when checklist_setting->''funclist''->0->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->0->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_1
  ,checklist_setting->''funclist''->0->>''list_name'' as class_code_name_1
  ,is_checks[1] as is_check_1
  ,staff_infos[1]->>''reg_staff_cd'' as reg_staff_cd_1
  ,occur_dates[1] as occur_date_1
  
  ,check_infos[2]->>''name'' as item_name_2
  ,case
    when checklist_setting->''funclist''->1->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->1->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_2
  ,checklist_setting->''funclist''->1->>''list_name'' as class_code_name_2
  ,is_checks[2] as is_check_2
  ,staff_infos[2]->>''reg_staff_cd'' as reg_staff_cd_2
  ,occur_dates[2] as occur_date_2

  ,check_infos[3]->>''name'' as item_name_3
  ,case
    when checklist_setting->''funclist''->2->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->2->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_3
  ,checklist_setting->''funclist''->2->>''list_name'' as class_code_name_3
  ,is_checks[3] as is_check_3
  ,staff_infos[3]->>''reg_staff_cd'' as reg_staff_cd_3
  ,occur_dates[3] as occur_date_3

  ,check_infos[4]->>''name'' as item_name_4
  ,case
    when checklist_setting->''funclist''->3->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->3->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_4
  ,checklist_setting->''funclist''->3->>''list_name'' as class_code_name_4
  ,is_checks[4] as is_check_4
  ,staff_infos[4]->>''reg_staff_cd'' as reg_staff_cd_4
  ,occur_dates[4] as occur_date_4

  ,check_infos[5]->>''name'' as item_name_5
  ,case
    when checklist_setting->''funclist''->4->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->4->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_5
  ,checklist_setting->''funclist''->4->>''list_name'' as class_code_name_5
  ,is_checks[5] as is_check_5
  ,staff_infos[5]->>''reg_staff_cd'' as reg_staff_cd_5
  ,occur_dates[5] as occur_date_5

  ,check_infos[6]->>''name'' as item_name_6
  ,case
    when checklist_setting->''funclist''->5->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->5->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_6
  ,checklist_setting->''funclist''->5->>''list_name'' as class_code_name_6
  ,is_checks[6] as is_check_6
  ,staff_infos[6]->>''reg_staff_cd'' as reg_staff_cd_6
  ,occur_dates[6] as occur_date_6

  ,check_infos[7]->>''name'' as item_name_7
  ,case
    when checklist_setting->''funclist''->6->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->6->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_7
  ,checklist_setting->''funclist''->6->>''list_name'' as class_code_name_7
  ,is_checks[7] as is_check_7
  ,staff_infos[7]->>''reg_staff_cd'' as reg_staff_cd_7
  ,occur_dates[7] as occur_date_7

  ,check_infos[8]->>''name'' as item_name_8
  ,case
    when checklist_setting->''funclist''->7->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->7->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_8
  ,checklist_setting->''funclist''->7->>''list_name'' as class_code_name_8
  ,is_checks[8] as is_check_8
  ,staff_infos[8]->>''reg_staff_cd'' as reg_staff_cd_8
  ,occur_dates[8] as occur_date_8

  ,check_infos[9]->>''name'' as item_name_9
  ,case
    when checklist_setting->''funclist''->8->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->8->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_9
  ,checklist_setting->''funclist''->8->>''list_name'' as class_code_name_9
  ,is_checks[9] as is_check_9
  ,staff_infos[9]->>''reg_staff_cd'' as reg_staff_cd_9
  ,occur_dates[9] as occur_date_9

  ,check_infos[10]->>''name'' as item_name_10
  ,case
    when checklist_setting->''funclist''->9->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->9->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_10
  ,checklist_setting->''funclist''->9->>''list_name'' as class_code_name_10
  ,is_checks[10] as is_check_10
  ,staff_infos[10]->>''reg_staff_cd'' as reg_staff_cd_10
  ,occur_dates[10] as occur_date_10
from
  row_to_col_tbl cross join (select * from setting_tbl_expand where checklist_setting->>''list_cd'' = ''5'') as tmp
;
', 2, '[{"preview": "透析終了直前", "can_calc": "0", "data_code": "list_name", "data_name": "リスト名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "list_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "dialysis_prog_name", "data_name": "透析工程", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "dialysis_prog_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "除水完了", "can_calc": "0", "data_code": "item_name_1", "data_name": "項目1名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "item_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_1", "data_name": "項目1機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "func_code_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_1", "data_name": "項目1分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "class_code_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_1", "data_name": "項目1チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト5", "field_name": "is_check_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_1", "data_name": "項目1チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "reg_staff_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11:47", "can_calc": "0", "data_code": "occur_date_1", "data_name": "項目1チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト5", "field_name": "occur_date_1", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "治療時間", "can_calc": "0", "data_code": "item_name_2", "data_name": "項目2名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "item_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_2", "data_name": "項目2機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "func_code_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_2", "data_name": "項目2分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "class_code_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_2", "data_name": "項目2チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト5", "field_name": "is_check_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_2", "data_name": "項目2チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "reg_staff_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11:47", "can_calc": "0", "data_code": "occur_date_2", "data_name": "項目2チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト5", "field_name": "occur_date_2", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "生殖残量", "can_calc": "0", "data_code": "item_name_3", "data_name": "項目3名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "item_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_3", "data_name": "項目3機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "func_code_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_3", "data_name": "項目3分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "class_code_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_3", "data_name": "項目3チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト5", "field_name": "is_check_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士３", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_3", "data_name": "項目3チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "reg_staff_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11:47", "can_calc": "0", "data_code": "occur_date_3", "data_name": "項目3チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト5", "field_name": "occur_date_3", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_4", "data_name": "項目4名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "item_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_4", "data_name": "項目4機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "func_code_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_4", "data_name": "項目4分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "class_code_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_4", "data_name": "項目4チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト5", "field_name": "is_check_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士４", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_4", "data_name": "項目4チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "reg_staff_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_4", "data_name": "項目4チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト5", "field_name": "occur_date_4", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_5", "data_name": "項目5名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "item_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_5", "data_name": "項目5機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "func_code_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_5", "data_name": "項目5分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "class_code_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_5", "data_name": "項目5チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト5", "field_name": "is_check_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士５", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_5", "data_name": "項目5チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "reg_staff_cd_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_5", "data_name": "項目5チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト5", "field_name": "occur_date_5", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_6", "data_name": "項目6名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "item_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_6", "data_name": "項目6機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "func_code_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_6", "data_name": "項目6分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "class_code_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_6", "data_name": "項目6チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト5", "field_name": "is_check_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士６", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_6", "data_name": "項目6チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "reg_staff_cd_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_6", "data_name": "項目6チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト5", "field_name": "occur_date_6", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_7", "data_name": "項目7名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "item_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_7", "data_name": "項目7機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "func_code_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_7", "data_name": "項目7分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "class_code_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_7", "data_name": "項目7チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト5", "field_name": "is_check_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士７", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_7", "data_name": "項目7チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "reg_staff_cd_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_7", "data_name": "項目7チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト5", "field_name": "occur_date_7", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_8", "data_name": "項目8名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "item_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_8", "data_name": "項目8機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "func_code_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_8", "data_name": "項目8分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "class_code_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_8", "data_name": "項目8チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト5", "field_name": "is_check_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士８", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_8", "data_name": "項目8チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "reg_staff_cd_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_8", "data_name": "項目8チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト5", "field_name": "occur_date_8", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_9", "data_name": "項目9名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "item_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_9", "data_name": "項目9機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "func_code_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_9", "data_name": "項目9分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "class_code_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_9", "data_name": "項目9チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト5", "field_name": "is_check_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士９", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_9", "data_name": "項目9チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "reg_staff_cd_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_9", "data_name": "項目9チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト5", "field_name": "occur_date_9", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_10", "data_name": "項目10名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "item_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_10", "data_name": "項目10機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "func_code_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_10", "data_name": "項目10分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "class_code_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_10", "data_name": "項目10チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト5", "field_name": "is_check_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１０", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_10", "data_name": "項目10チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "reg_staff_cd_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_10", "data_name": "項目10チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト5", "field_name": "occur_date_10", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": []}', '実績（治療中）：チェックリスト5 @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (184, 'with checklist_cd_record as (
  select
    rst_checklist_info->>''checklist_cd'' as cd
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
  order by occur_date limit 1
)
, setting_tbl as (
  select
    checklist_settings
  from
    mst_checklist
  where
    checklist_cd::text in (select cd from checklist_cd_record)
    and is_del = ''0''
    and is_disp = ''1''
)
, setting_tbl_expand as
(
  select
    checklist_setting
    ,json_idx
  from
    setting_tbl
    cross join lateral jsonb_array_elements(checklist_settings) with ordinality as tmp(checklist_setting, json_idx)
)
, row_to_col_tbl as
(
  select
    array_agg(is_check order by cast(rst_checklist_info->>''item_number'' as integer)) as is_checks
    ,array_agg(rst_class order by cast(rst_checklist_info->>''item_number'' as integer)) as rst_classes
    ,array_agg(list_cd order by cast(rst_checklist_info->>''item_number'' as integer)) as list_cds
    ,array_agg(func_class order by cast(rst_checklist_info->>''item_number'' as integer)) as func_classes
    ,array_agg(rst_checklist_info order by cast(rst_checklist_info->>''item_number'' as integer)) as check_infos
    ,array_agg(reg_staff_info order by cast(rst_checklist_info->>''item_number'' as integer)) as staff_infos
    ,array_agg(occur_date order by cast(rst_checklist_info->>''item_number'' as integer)) as occur_dates
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
    and list_cd = 6
)

select
@ordNo AS ord_no,
  checklist_setting->>''list_cd'' as list_cd
  ,checklist_setting->>''list_name'' as list_name
  ,checklist_setting->>''dialysis_prog_name'' as dialysis_prog_name

  ,check_infos[1]->>''name'' as item_name_1
  ,case
    when checklist_setting->''funclist''->0->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->0->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_1
  ,checklist_setting->''funclist''->0->>''list_name'' as class_code_name_1
  ,is_checks[1] as is_check_1
  ,staff_infos[1]->>''reg_staff_cd'' as reg_staff_cd_1
  ,occur_dates[1] as occur_date_1
  
  ,check_infos[2]->>''name'' as item_name_2
  ,case
    when checklist_setting->''funclist''->1->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->1->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_2
  ,checklist_setting->''funclist''->1->>''list_name'' as class_code_name_2
  ,is_checks[2] as is_check_2
  ,staff_infos[2]->>''reg_staff_cd'' as reg_staff_cd_2
  ,occur_dates[2] as occur_date_2

  ,check_infos[3]->>''name'' as item_name_3
  ,case
    when checklist_setting->''funclist''->2->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->2->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_3
  ,checklist_setting->''funclist''->2->>''list_name'' as class_code_name_3
  ,is_checks[3] as is_check_3
  ,staff_infos[3]->>''reg_staff_cd'' as reg_staff_cd_3
  ,occur_dates[3] as occur_date_3

  ,check_infos[4]->>''name'' as item_name_4
  ,case
    when checklist_setting->''funclist''->3->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->3->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_4
  ,checklist_setting->''funclist''->3->>''list_name'' as class_code_name_4
  ,is_checks[4] as is_check_4
  ,staff_infos[4]->>''reg_staff_cd'' as reg_staff_cd_4
  ,occur_dates[4] as occur_date_4

  ,check_infos[5]->>''name'' as item_name_5
  ,case
    when checklist_setting->''funclist''->4->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->4->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_5
  ,checklist_setting->''funclist''->4->>''list_name'' as class_code_name_5
  ,is_checks[5] as is_check_5
  ,staff_infos[5]->>''reg_staff_cd'' as reg_staff_cd_5
  ,occur_dates[5] as occur_date_5

  ,check_infos[6]->>''name'' as item_name_6
  ,case
    when checklist_setting->''funclist''->5->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->5->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_6
  ,checklist_setting->''funclist''->5->>''list_name'' as class_code_name_6
  ,is_checks[6] as is_check_6
  ,staff_infos[6]->>''reg_staff_cd'' as reg_staff_cd_6
  ,occur_dates[6] as occur_date_6

  ,check_infos[7]->>''name'' as item_name_7
  ,case
    when checklist_setting->''funclist''->6->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->6->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_7
  ,checklist_setting->''funclist''->6->>''list_name'' as class_code_name_7
  ,is_checks[7] as is_check_7
  ,staff_infos[7]->>''reg_staff_cd'' as reg_staff_cd_7
  ,occur_dates[7] as occur_date_7

  ,check_infos[8]->>''name'' as item_name_8
  ,case
    when checklist_setting->''funclist''->7->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->7->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_8
  ,checklist_setting->''funclist''->7->>''list_name'' as class_code_name_8
  ,is_checks[8] as is_check_8
  ,staff_infos[8]->>''reg_staff_cd'' as reg_staff_cd_8
  ,occur_dates[8] as occur_date_8

  ,check_infos[9]->>''name'' as item_name_9
  ,case
    when checklist_setting->''funclist''->8->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->8->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_9
  ,checklist_setting->''funclist''->8->>''list_name'' as class_code_name_9
  ,is_checks[9] as is_check_9
  ,staff_infos[9]->>''reg_staff_cd'' as reg_staff_cd_9
  ,occur_dates[9] as occur_date_9

  ,check_infos[10]->>''name'' as item_name_10
  ,case
    when checklist_setting->''funclist''->9->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->9->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_10
  ,checklist_setting->''funclist''->9->>''list_name'' as class_code_name_10
  ,is_checks[10] as is_check_10
  ,staff_infos[10]->>''reg_staff_cd'' as reg_staff_cd_10
  ,occur_dates[10] as occur_date_10
from
  row_to_col_tbl cross join (select * from setting_tbl_expand where checklist_setting->>''list_cd'' = ''6'') as tmp
;
', 2, '[{"preview": "終業時点検", "can_calc": "0", "data_code": "list_name", "data_name": "リスト名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "list_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析終了後", "can_calc": "0", "data_code": "dialysis_prog_name", "data_name": "透析工程", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "dialysis_prog_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "除水誤差", "can_calc": "0", "data_code": "item_name_1", "data_name": "項目1名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "item_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_1", "data_name": "項目1機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "func_code_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_1", "data_name": "項目1分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "class_code_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_1", "data_name": "項目1チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト6", "field_name": "is_check_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_1", "data_name": "項目1チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "reg_staff_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:52", "can_calc": "0", "data_code": "occur_date_1", "data_name": "項目1チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト6", "field_name": "occur_date_1", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "液漏れ", "can_calc": "0", "data_code": "item_name_2", "data_name": "項目2名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "item_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_2", "data_name": "項目2機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "func_code_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_2", "data_name": "項目2分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "class_code_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_2", "data_name": "項目2チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト6", "field_name": "is_check_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_2", "data_name": "項目2チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "reg_staff_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:52", "can_calc": "0", "data_code": "occur_date_2", "data_name": "項目2チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト6", "field_name": "occur_date_2", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "異音", "can_calc": "0", "data_code": "item_name_3", "data_name": "項目3名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "item_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_3", "data_name": "項目3機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "func_code_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_3", "data_name": "項目3分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "class_code_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_3", "data_name": "項目3チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト6", "field_name": "is_check_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士３", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_3", "data_name": "項目3チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "reg_staff_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:52", "can_calc": "0", "data_code": "occur_date_3", "data_name": "項目3チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト6", "field_name": "occur_date_3", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "異臭", "can_calc": "0", "data_code": "item_name_4", "data_name": "項目4名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "item_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_4", "data_name": "項目4機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "func_code_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_4", "data_name": "項目4分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "class_code_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_4", "data_name": "項目4チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト6", "field_name": "is_check_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士４", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_4", "data_name": "項目4チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "reg_staff_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:52", "can_calc": "0", "data_code": "occur_date_4", "data_name": "項目4チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト6", "field_name": "occur_date_4", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "外観点検", "can_calc": "0", "data_code": "item_name_5", "data_name": "項目5名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "item_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_5", "data_name": "項目5機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "func_code_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_5", "data_name": "項目5分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "class_code_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_5", "data_name": "項目5チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト6", "field_name": "is_check_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士５", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_5", "data_name": "項目5チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "reg_staff_cd_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:52", "can_calc": "0", "data_code": "occur_date_5", "data_name": "項目5チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト6", "field_name": "occur_date_5", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "機器動作", "can_calc": "0", "data_code": "item_name_6", "data_name": "項目6名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "item_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_6", "data_name": "項目6機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "func_code_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_6", "data_name": "項目6分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "class_code_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_6", "data_name": "項目6チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト6", "field_name": "is_check_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士６", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_6", "data_name": "項目6チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "reg_staff_cd_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:52", "can_calc": "0", "data_code": "occur_date_6", "data_name": "項目6チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト6", "field_name": "occur_date_6", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "警報の有無", "can_calc": "0", "data_code": "item_name_7", "data_name": "項目7名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "item_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_7", "data_name": "項目7機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "func_code_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_7", "data_name": "項目7分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "class_code_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_7", "data_name": "項目7チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト6", "field_name": "is_check_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士７", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_7", "data_name": "項目7チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "reg_staff_cd_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:52", "can_calc": "0", "data_code": "occur_date_7", "data_name": "項目7チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト6", "field_name": "occur_date_7", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_8", "data_name": "項目8名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "item_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_8", "data_name": "項目8機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "func_code_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_8", "data_name": "項目8分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "class_code_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_8", "data_name": "項目8チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト6", "field_name": "is_check_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士８", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_8", "data_name": "項目8チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "reg_staff_cd_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_8", "data_name": "項目8チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト6", "field_name": "occur_date_8", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_9", "data_name": "項目9名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "item_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_9", "data_name": "項目9機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "func_code_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_9", "data_name": "項目9分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "class_code_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_9", "data_name": "項目9チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト6", "field_name": "is_check_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士９", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_9", "data_name": "項目9チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "reg_staff_cd_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_9", "data_name": "項目9チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト6", "field_name": "occur_date_9", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_10", "data_name": "項目10名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "item_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_10", "data_name": "項目10機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "func_code_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_10", "data_name": "項目10分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "class_code_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_10", "data_name": "項目10チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト6", "field_name": "is_check_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１０", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_10", "data_name": "項目10チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "reg_staff_cd_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_10", "data_name": "項目10チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト6", "field_name": "occur_date_10", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": []}', '実績（治療中）：チェックリスト6 @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (185, 'with checklist_cd_record as (
  select
    rst_checklist_info->>''checklist_cd'' as cd
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
  order by occur_date limit 1
)
, setting_tbl as (
  select
    checklist_settings
  from
    mst_checklist
  where
    checklist_cd::text in (select cd from checklist_cd_record)
    and is_del = ''0''
    and is_disp = ''1''
)
, setting_tbl_expand as
(
  select
    checklist_setting
    ,json_idx
  from
    setting_tbl
    cross join lateral jsonb_array_elements(checklist_settings) with ordinality as tmp(checklist_setting, json_idx)
)
, row_to_col_tbl as
(
  select
    array_agg(is_check order by cast(rst_checklist_info->>''item_number'' as integer)) as is_checks
    ,array_agg(rst_class order by cast(rst_checklist_info->>''item_number'' as integer)) as rst_classes
    ,array_agg(list_cd order by cast(rst_checklist_info->>''item_number'' as integer)) as list_cds
    ,array_agg(func_class order by cast(rst_checklist_info->>''item_number'' as integer)) as func_classes
    ,array_agg(rst_checklist_info order by cast(rst_checklist_info->>''item_number'' as integer)) as check_infos
    ,array_agg(reg_staff_info order by cast(rst_checklist_info->>''item_number'' as integer)) as staff_infos
    ,array_agg(occur_date order by cast(rst_checklist_info->>''item_number'' as integer)) as occur_dates
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
    and list_cd = 7
)

select
@ordNo AS ord_no,
  checklist_setting->>''list_cd'' as list_cd
  ,checklist_setting->>''list_name'' as list_name
  ,checklist_setting->>''dialysis_prog_name'' as dialysis_prog_name

  ,check_infos[1]->>''name'' as item_name_1
  ,case
    when checklist_setting->''funclist''->0->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->0->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_1
  ,checklist_setting->''funclist''->0->>''list_name'' as class_code_name_1
  ,is_checks[1] as is_check_1
  ,staff_infos[1]->>''reg_staff_cd'' as reg_staff_cd_1
  ,occur_dates[1] as occur_date_1
  
  ,check_infos[2]->>''name'' as item_name_2
  ,case
    when checklist_setting->''funclist''->1->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->1->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_2
  ,checklist_setting->''funclist''->1->>''list_name'' as class_code_name_2
  ,is_checks[2] as is_check_2
  ,staff_infos[2]->>''reg_staff_cd'' as reg_staff_cd_2
  ,occur_dates[2] as occur_date_2

  ,check_infos[3]->>''name'' as item_name_3
  ,case
    when checklist_setting->''funclist''->2->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->2->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_3
  ,checklist_setting->''funclist''->2->>''list_name'' as class_code_name_3
  ,is_checks[3] as is_check_3
  ,staff_infos[3]->>''reg_staff_cd'' as reg_staff_cd_3
  ,occur_dates[3] as occur_date_3

  ,check_infos[4]->>''name'' as item_name_4
  ,case
    when checklist_setting->''funclist''->3->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->3->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_4
  ,checklist_setting->''funclist''->3->>''list_name'' as class_code_name_4
  ,is_checks[4] as is_check_4
  ,staff_infos[4]->>''reg_staff_cd'' as reg_staff_cd_4
  ,occur_dates[4] as occur_date_4

  ,check_infos[5]->>''name'' as item_name_5
  ,case
    when checklist_setting->''funclist''->4->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->4->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_5
  ,checklist_setting->''funclist''->4->>''list_name'' as class_code_name_5
  ,is_checks[5] as is_check_5
  ,staff_infos[5]->>''reg_staff_cd'' as reg_staff_cd_5
  ,occur_dates[5] as occur_date_5

  ,check_infos[6]->>''name'' as item_name_6
  ,case
    when checklist_setting->''funclist''->5->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->5->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_6
  ,checklist_setting->''funclist''->5->>''list_name'' as class_code_name_6
  ,is_checks[6] as is_check_6
  ,staff_infos[6]->>''reg_staff_cd'' as reg_staff_cd_6
  ,occur_dates[6] as occur_date_6

  ,check_infos[7]->>''name'' as item_name_7
  ,case
    when checklist_setting->''funclist''->6->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->6->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_7
  ,checklist_setting->''funclist''->6->>''list_name'' as class_code_name_7
  ,is_checks[7] as is_check_7
  ,staff_infos[7]->>''reg_staff_cd'' as reg_staff_cd_7
  ,occur_dates[7] as occur_date_7

  ,check_infos[8]->>''name'' as item_name_8
  ,case
    when checklist_setting->''funclist''->7->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->7->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_8
  ,checklist_setting->''funclist''->7->>''list_name'' as class_code_name_8
  ,is_checks[8] as is_check_8
  ,staff_infos[8]->>''reg_staff_cd'' as reg_staff_cd_8
  ,occur_dates[8] as occur_date_8

  ,check_infos[9]->>''name'' as item_name_9
  ,case
    when checklist_setting->''funclist''->8->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->8->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_9
  ,checklist_setting->''funclist''->8->>''list_name'' as class_code_name_9
  ,is_checks[9] as is_check_9
  ,staff_infos[9]->>''reg_staff_cd'' as reg_staff_cd_9
  ,occur_dates[9] as occur_date_9

  ,check_infos[10]->>''name'' as item_name_10
  ,case
    when checklist_setting->''funclist''->9->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->9->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_10
  ,checklist_setting->''funclist''->9->>''list_name'' as class_code_name_10
  ,is_checks[10] as is_check_10
  ,staff_infos[10]->>''reg_staff_cd'' as reg_staff_cd_10
  ,occur_dates[10] as occur_date_10
from
  row_to_col_tbl cross join (select * from setting_tbl_expand where checklist_setting->>''list_cd'' = ''7'') as tmp
;
', 2, '[{"preview": "", "can_calc": "0", "data_code": "list_name", "data_name": "リスト名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "list_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dialysis_prog_name", "data_name": "透析工程", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "dialysis_prog_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_1", "data_name": "項目1名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "item_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "func_code_name_1", "data_name": "項目1機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "func_code_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_1", "data_name": "項目1分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "class_code_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_1", "data_name": "項目1チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト7", "field_name": "is_check_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_1", "data_name": "項目1チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "reg_staff_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_1", "data_name": "項目1チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト7", "field_name": "occur_date_1", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_2", "data_name": "項目2名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "item_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_2", "data_name": "項目2機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "func_code_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_2", "data_name": "項目2分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "class_code_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_2", "data_name": "項目2チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト7", "field_name": "is_check_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_2", "data_name": "項目2チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "reg_staff_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_2", "data_name": "項目2チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト7", "field_name": "occur_date_2", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_3", "data_name": "項目3名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "item_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_3", "data_name": "項目3機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "func_code_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_3", "data_name": "項目3分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "class_code_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_3", "data_name": "項目3チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト7", "field_name": "is_check_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士３", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_3", "data_name": "項目3チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "reg_staff_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_3", "data_name": "項目3チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト7", "field_name": "occur_date_3", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_4", "data_name": "項目4名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "item_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_4", "data_name": "項目4機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "func_code_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_4", "data_name": "項目4分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "class_code_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_4", "data_name": "項目4チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト7", "field_name": "is_check_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士４", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_4", "data_name": "項目4チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "reg_staff_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_4", "data_name": "項目4チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト7", "field_name": "occur_date_4", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_5", "data_name": "項目5名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "item_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_5", "data_name": "項目5機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "func_code_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_5", "data_name": "項目5分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "class_code_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_5", "data_name": "項目5チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト7", "field_name": "is_check_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士５", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_5", "data_name": "項目5チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "reg_staff_cd_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_5", "data_name": "項目5チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト7", "field_name": "occur_date_5", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_6", "data_name": "項目6名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "item_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_6", "data_name": "項目6機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "func_code_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_6", "data_name": "項目6分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "class_code_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_6", "data_name": "項目6チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト7", "field_name": "is_check_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士６", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_6", "data_name": "項目6チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "reg_staff_cd_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_6", "data_name": "項目6チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト7", "field_name": "occur_date_6", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_7", "data_name": "項目7名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "item_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_7", "data_name": "項目7機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "func_code_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_7", "data_name": "項目7分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "class_code_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_7", "data_name": "項目7チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト7", "field_name": "is_check_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士７", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_7", "data_name": "項目7チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "reg_staff_cd_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_7", "data_name": "項目7チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト7", "field_name": "occur_date_7", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_8", "data_name": "項目8名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "item_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_8", "data_name": "項目8機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "func_code_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_8", "data_name": "項目8分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "class_code_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_8", "data_name": "項目8チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト7", "field_name": "is_check_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士８", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_8", "data_name": "項目8チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "reg_staff_cd_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_8", "data_name": "項目8チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト7", "field_name": "occur_date_8", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_9", "data_name": "項目9名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "item_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_9", "data_name": "項目9機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "func_code_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_9", "data_name": "項目9分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "class_code_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_9", "data_name": "項目9チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト7", "field_name": "is_check_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士９", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_9", "data_name": "項目9チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "reg_staff_cd_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_9", "data_name": "項目9チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト7", "field_name": "occur_date_9", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_10", "data_name": "項目10名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "item_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_10", "data_name": "項目10機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "func_code_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_10", "data_name": "項目10分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "class_code_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_10", "data_name": "項目10チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト7", "field_name": "is_check_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１０", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_10", "data_name": "項目10チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "reg_staff_cd_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_10", "data_name": "項目10チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト7", "field_name": "occur_date_10", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": []}', '実績（治療中）：チェックリスト7 @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (186, 'with checklist_cd_record as (
  select
    rst_checklist_info->>''checklist_cd'' as cd
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
  order by occur_date limit 1
)
, setting_tbl as (
  select
    checklist_settings
  from
    mst_checklist
  where
    checklist_cd::text in (select cd from checklist_cd_record)
    and is_del = ''0''
    and is_disp = ''1''
)
, setting_tbl_expand as
(
  select
    checklist_setting
    ,json_idx
  from
    setting_tbl
    cross join lateral jsonb_array_elements(checklist_settings) with ordinality as tmp(checklist_setting, json_idx)
)
, row_to_col_tbl as
(
  select
    array_agg(is_check order by cast(rst_checklist_info->>''item_number'' as integer)) as is_checks
    ,array_agg(rst_class order by cast(rst_checklist_info->>''item_number'' as integer)) as rst_classes
    ,array_agg(list_cd order by cast(rst_checklist_info->>''item_number'' as integer)) as list_cds
    ,array_agg(func_class order by cast(rst_checklist_info->>''item_number'' as integer)) as func_classes
    ,array_agg(rst_checklist_info order by cast(rst_checklist_info->>''item_number'' as integer)) as check_infos
    ,array_agg(reg_staff_info order by cast(rst_checklist_info->>''item_number'' as integer)) as staff_infos
    ,array_agg(occur_date order by cast(rst_checklist_info->>''item_number'' as integer)) as occur_dates
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
    and list_cd = 8
)

select
@ordNo AS ord_no,
  checklist_setting->>''list_cd'' as list_cd
  ,checklist_setting->>''list_name'' as list_name
  ,checklist_setting->>''dialysis_prog_name'' as dialysis_prog_name

  ,check_infos[1]->>''name'' as item_name_1
  ,case
    when checklist_setting->''funclist''->0->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->0->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_1
  ,checklist_setting->''funclist''->0->>''list_name'' as class_code_name_1
  ,is_checks[1] as is_check_1
  ,staff_infos[1]->>''reg_staff_cd'' as reg_staff_cd_1
  ,occur_dates[1] as occur_date_1
  
  ,check_infos[2]->>''name'' as item_name_2
  ,case
    when checklist_setting->''funclist''->1->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->1->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_2
  ,checklist_setting->''funclist''->1->>''list_name'' as class_code_name_2
  ,is_checks[2] as is_check_2
  ,staff_infos[2]->>''reg_staff_cd'' as reg_staff_cd_2
  ,occur_dates[2] as occur_date_2

  ,check_infos[3]->>''name'' as item_name_3
  ,case
    when checklist_setting->''funclist''->2->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->2->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_3
  ,checklist_setting->''funclist''->2->>''list_name'' as class_code_name_3
  ,is_checks[3] as is_check_3
  ,staff_infos[3]->>''reg_staff_cd'' as reg_staff_cd_3
  ,occur_dates[3] as occur_date_3

  ,check_infos[4]->>''name'' as item_name_4
  ,case
    when checklist_setting->''funclist''->3->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->3->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_4
  ,checklist_setting->''funclist''->3->>''list_name'' as class_code_name_4
  ,is_checks[4] as is_check_4
  ,staff_infos[4]->>''reg_staff_cd'' as reg_staff_cd_4
  ,occur_dates[4] as occur_date_4

  ,check_infos[5]->>''name'' as item_name_5
  ,case
    when checklist_setting->''funclist''->4->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->4->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_5
  ,checklist_setting->''funclist''->4->>''list_name'' as class_code_name_5
  ,is_checks[5] as is_check_5
  ,staff_infos[5]->>''reg_staff_cd'' as reg_staff_cd_5
  ,occur_dates[5] as occur_date_5

  ,check_infos[6]->>''name'' as item_name_6
  ,case
    when checklist_setting->''funclist''->5->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->5->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_6
  ,checklist_setting->''funclist''->5->>''list_name'' as class_code_name_6
  ,is_checks[6] as is_check_6
  ,staff_infos[6]->>''reg_staff_cd'' as reg_staff_cd_6
  ,occur_dates[6] as occur_date_6

  ,check_infos[7]->>''name'' as item_name_7
  ,case
    when checklist_setting->''funclist''->6->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->6->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_7
  ,checklist_setting->''funclist''->6->>''list_name'' as class_code_name_7
  ,is_checks[7] as is_check_7
  ,staff_infos[7]->>''reg_staff_cd'' as reg_staff_cd_7
  ,occur_dates[7] as occur_date_7

  ,check_infos[8]->>''name'' as item_name_8
  ,case
    when checklist_setting->''funclist''->7->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->7->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_8
  ,checklist_setting->''funclist''->7->>''list_name'' as class_code_name_8
  ,is_checks[8] as is_check_8
  ,staff_infos[8]->>''reg_staff_cd'' as reg_staff_cd_8
  ,occur_dates[8] as occur_date_8

  ,check_infos[9]->>''name'' as item_name_9
  ,case
    when checklist_setting->''funclist''->8->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->8->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_9
  ,checklist_setting->''funclist''->8->>''list_name'' as class_code_name_9
  ,is_checks[9] as is_check_9
  ,staff_infos[9]->>''reg_staff_cd'' as reg_staff_cd_9
  ,occur_dates[9] as occur_date_9

  ,check_infos[10]->>''name'' as item_name_10
  ,case
    when checklist_setting->''funclist''->9->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->9->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_10
  ,checklist_setting->''funclist''->9->>''list_name'' as class_code_name_10
  ,is_checks[10] as is_check_10
  ,staff_infos[10]->>''reg_staff_cd'' as reg_staff_cd_10
  ,occur_dates[10] as occur_date_10
from
  row_to_col_tbl cross join (select * from setting_tbl_expand where checklist_setting->>''list_cd'' = ''8'') as tmp
;
', 2, '[{"preview": "", "can_calc": "0", "data_code": "list_name", "data_name": "リスト名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "list_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "dialysis_prog_name", "data_name": "透析工程", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "dialysis_prog_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_1", "data_name": "項目1名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "item_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "func_code_name_1", "data_name": "項目1機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "func_code_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_1", "data_name": "項目1分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "class_code_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_1", "data_name": "項目1チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト8", "field_name": "is_check_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_1", "data_name": "項目1チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "reg_staff_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_1", "data_name": "項目1チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト8", "field_name": "occur_date_1", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_2", "data_name": "項目2名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "item_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_2", "data_name": "項目2機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "func_code_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_2", "data_name": "項目2分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "class_code_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_2", "data_name": "項目2チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト8", "field_name": "is_check_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_2", "data_name": "項目2チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "reg_staff_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_2", "data_name": "項目2チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト8", "field_name": "occur_date_2", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_3", "data_name": "項目3名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "item_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_3", "data_name": "項目3機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "func_code_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_3", "data_name": "項目3分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "class_code_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_3", "data_name": "項目3チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト8", "field_name": "is_check_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士３", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_3", "data_name": "項目3チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "reg_staff_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_3", "data_name": "項目3チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト8", "field_name": "occur_date_3", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_4", "data_name": "項目4名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "item_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_4", "data_name": "項目4機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "func_code_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_4", "data_name": "項目4分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "class_code_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_4", "data_name": "項目4チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト8", "field_name": "is_check_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士４", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_4", "data_name": "項目4チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "reg_staff_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_4", "data_name": "項目4チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト8", "field_name": "occur_date_4", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_5", "data_name": "項目5名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "item_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_5", "data_name": "項目5機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "func_code_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_5", "data_name": "項目5分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "class_code_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_5", "data_name": "項目5チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト8", "field_name": "is_check_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士５", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_5", "data_name": "項目5チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "reg_staff_cd_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_5", "data_name": "項目5チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト8", "field_name": "occur_date_5", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_6", "data_name": "項目6名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "item_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_6", "data_name": "項目6機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "func_code_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_6", "data_name": "項目6分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "class_code_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_6", "data_name": "項目6チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト8", "field_name": "is_check_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士６", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_6", "data_name": "項目6チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "reg_staff_cd_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_6", "data_name": "項目6チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト8", "field_name": "occur_date_6", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_7", "data_name": "項目7名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "item_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_7", "data_name": "項目7機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "func_code_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_7", "data_name": "項目7分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "class_code_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_7", "data_name": "項目7チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト8", "field_name": "is_check_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士７", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_7", "data_name": "項目7チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "reg_staff_cd_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_7", "data_name": "項目7チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト8", "field_name": "occur_date_7", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_8", "data_name": "項目8名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "item_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_8", "data_name": "項目8機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "func_code_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_8", "data_name": "項目8分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "class_code_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_8", "data_name": "項目8チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト8", "field_name": "is_check_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士８", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_8", "data_name": "項目8チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "reg_staff_cd_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_8", "data_name": "項目8チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト8", "field_name": "occur_date_8", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_9", "data_name": "項目9名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "item_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_9", "data_name": "項目9機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "func_code_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_9", "data_name": "項目9分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "class_code_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_9", "data_name": "項目9チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト8", "field_name": "is_check_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士９", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_9", "data_name": "項目9チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "reg_staff_cd_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_9", "data_name": "項目9チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト8", "field_name": "occur_date_9", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_10", "data_name": "項目10名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "item_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_10", "data_name": "項目10機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "func_code_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_10", "data_name": "項目10分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "class_code_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_10", "data_name": "項目10チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト8", "field_name": "is_check_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１０", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_10", "data_name": "項目10チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "reg_staff_cd_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_10", "data_name": "項目10チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト8", "field_name": "occur_date_10", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": []}', '実績（治療中）：チェックリスト8 @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (187, 'WITH DATA AS (

with dat as
(
SELECT
	rst_rounds_info ->> ''content'' AS CONTENT,
	rst_rounds_info ->> ''round_type_name'' AS round_type,
	rst_rounds_info ->> ''round_type_cd'' AS round_type_cd,
	CAST(rst_rounds_info ->> ''reg_date_time'' as TIMESTAMP) AS reg_date_time1,
	rst_rounds_info ->> ''ind_user_id'' AS ind_user_id,
	( rst_rounds_info ->> ''ind_user_last_name'' ) || ''　'' || ( rst_rounds_info ->> ''ind_user_first_name'' ) AS ind_user_name,
	rst_rounds_info ->> ''reg_user_id'' AS reg_user_id,
	( rst_rounds_info ->> ''reg_user_last_name'' ) || ''　'' || ( rst_rounds_info ->> ''reg_user_first_name'' ) AS reg_user_name,
CASE
		rst_rounds_info ->> ''is_ind_comment_post''
		WHEN ''0'' THEN
		''転記しない'' ELSE''転記する''
	END AS is_ind_comment_post,
	rst_rounds_info ->> ''ind_comment_no'' AS ind_comment_no,
CASE
		rst_rounds_info ->> ''posting_class''
		WHEN ''0'' THEN
		''継続'' ELSE''当日のみ''
	END AS posting_class,
	rst_rounds_info ->> ''created_user_id'' AS created_user_id,
	( rst_rounds_info ->> ''created_user_last_name'' ) || ''　'' || ( rst_rounds_info ->> ''created_user_first_name'' ) AS created_user_name,
	rst_rounds_info ->> ''updated_user_id'' AS updated_user_id,
	( rst_rounds_info ->> ''updated_user_last_name'' ) || ''　'' || ( rst_rounds_info ->> ''updated_user_first_name'' ) AS updated_user_name
FROM
	ord_main
WHERE
	ord_no = @ordNo
	AND is_del = ''0''
	AND rst_dialysis_state > ''0''
	AND rst_dialysis_state < ''6''
)

SELECT
@ordNo as ord_no_t,
CONTENT,
round_type,
round_type_cd,
substr(to_char(reg_date_time1,''YYYY-MM-DD hh24:mi:ss''), 0,17) as reg_date_time,
ind_user_id,
ind_user_name,
reg_user_id,
reg_user_name,
is_ind_comment_post,
ind_comment_no,
posting_class,
created_user_id,
created_user_name,
updated_user_id,
updated_user_name
FROM
	dat

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
	b.ord_no as ordnob,
	b.treat_date as treat_date,
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
	', 2, '[{"preview": "001", "can_calc": "1", "data_code": "round_type", "data_name": "種別名", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "round_type", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "002", "can_calc": "1", "data_code": "content", "data_name": "種別内容", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "content", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "003", "can_calc": "1", "data_code": "round_type_cd", "data_name": "種別コード", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "round_type_cd", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/20 12:30", "can_calc": "1", "data_code": "reg_date_time", "data_name": "起票日時", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "reg_date_time", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "005", "can_calc": "1", "conv_sql": {"sql_cd": 196, "field_name": "disp_user_id", "target_var": "@indUserId"}, "data_code": "ind_user_id", "data_name": "指示者ID", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "ind_user_id", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "006", "can_calc": "1", "data_code": "ind_user_name", "data_name": "指示者名", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "ind_user_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "007", "can_calc": "1", "conv_sql": {"sql_cd": 193, "field_name": "disp_user_id", "target_var": "@regUserId"}, "data_code": "reg_user_id", "data_name": "起票者ID", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "reg_user_id", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "008", "can_calc": "1", "data_code": "reg_user_name", "data_name": "起票者名", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "reg_user_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "009", "can_calc": "1", "data_code": "is_ind_comment_post", "data_name": "指示コメントに転記", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "is_ind_comment_post", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "010", "can_calc": "1", "data_code": "ind_comment_no", "data_name": "指示コメント番号", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "ind_comment_no", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "011", "can_calc": "1", "data_code": "posting_class", "data_name": "転記区分", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "posting_class", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "012", "can_calc": "1", "conv_sql": {"sql_cd": 194, "field_name": "disp_user_id", "target_var": "@createdUserId"}, "data_code": "created_user_id", "data_name": "登録者ID", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "created_user_id", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "013", "can_calc": "1", "data_code": "created_user_name", "data_name": "登録者名", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "created_user_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "014", "can_calc": "1", "conv_sql": {"sql_cd": 195, "field_name": "disp_user_id", "target_var": "@updatedUserId"}, "data_code": "updated_user_id", "data_name": "更新者ID", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "updated_user_id", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "015", "can_calc": "1", "data_code": "updated_user_name", "data_name": "更新者名", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "updated_user_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": []}', '実績（治療中）：回診記録 @ordNo 使用', '2020-07-31 18:29:49', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (237, 'WITH mst_treat AS (
  SELECT
    treatment_cd
  FROM
    mst_treatment mt
  WHERE
    mt.facility_cd = @facilityCd
    AND mt.is_del = ''0''
    AND mt.device_mode <> ''9''
),
rst_dial_cnt AS (
  SELECT 
    ord_no AS p_no,
    treatment_cd,
    treat_date,
    TO_CHAR(treat_date::DATE, ''YYYY-MM'') AS treat_month,
    COALESCE(
        SUM(CASE WHEN rst_dialysis_state > ''0'' AND treatment_cd is not null THEN COUNT(treat_date) ELSE 0 END) 
        OVER (PARTITION BY TO_CHAR(treat_date::DATE, ''YYYY-MM'') ORDER BY treat_date), 
        0
    ) AS rst_dialysis_cnt
  FROM
    ord_main m
  LEFT JOIN
    mst_treat mt ON mt.treatment_cd = m.rst_treatment_cd
  WHERE
    facility_cd = @facilityCd
    AND pat_id = @patId
    AND treat_date BETWEEN to_char(date_trunc(''month'', CAST(@fromDate AS TIMESTAMP)), ''YYYYMMDD'') 
    AND TO_CHAR((date_trunc(''month'', CAST(@toDate AS TIMESTAMP)) + INTERVAL ''1 month'' - INTERVAL ''1 day''), ''YYYYMMDD'')
    AND m.is_del = ''0''
  GROUP BY
    treat_month,
    p_no,
    treatment_cd
)

SELECT
  om.ord_no,
  om.treat_date,
  rdc.treat_month, 
  rdc.rst_dialysis_cnt
FROM
  ord_main om
  LEFT JOIN rst_dial_cnt rdc ON om.ord_no = rdc.p_no
WHERE
  om.ord_no = @ordNo
  AND om.pat_id = @patId
  AND om.facility_cd = @facilityCd
  AND om.is_del = ''0''
  AND om.rst_dialysis_state > ''0''
  AND om.rst_dialysis_state < ''6''
ORDER BY
  treat_date
', 2, '[{"preview": "3", "can_calc": "0", "data_code": "rst_dialysis_cnt", "data_name": "月透析回数", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_dialysis_cnt", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": []}', '実績（治療中）：実績情報 @ordNo 使用', '2025-02-24 02:15:50.043', CURRENT_TIMESTAMP, NULL);
