DELETE FROM "ntss"."sys_data_set" WHERE sql_cd = 249;
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (249, 'WITH ord_tbl AS (
	SELECT
		pat_id
		, ord_no
		, treat_date
		, rst_weight_info
		, rst_dw
	FROM
		ord_main
	WHERE
		ord_no in (@ordNos)
		AND is_del = ''0''
		AND rst_dialysis_state <>''0''
)
, mni_monitor_tbl as (
	SELECT * FROM mni_monitor WHERE is_del = ''0'' AND facility_cd = @facilityCd AND ord_no in (select ord_no from ord_tbl) AND data_type in (5, 6)
)
, ord_hist_mae as (
	SELECT
		ord.ord_no
		, m.bio_moni_ctl_no
		, m.data_type
		, m.occur_date as before_vital_measure_date
		,to_number(m.monitor_data->>''90'', ''999'') as before_bp_high
		,to_number(m.monitor_data->>''91'', ''999'') as before_bp_low
		,to_number(m.monitor_data->>''92'', ''999'') as before_bp_ave
		,to_number(m.monitor_data->>''93'', ''999'') as before_pulse
	FROM
		ord_tbl AS ord
	LEFT OUTER JOIN mni_monitor_tbl AS m ON m.ord_no = ord.ord_no
	WHERE
		m.facility_cd = @facilityCd
		AND m.ord_no = ord.ord_no
		AND m.data_type = 5
)
, ord_hist_ato as (
	SELECT
		ord.ord_no
		, m.bio_moni_ctl_no
		, m.data_type
		, m.occur_date as after_vital_measure_date
		,to_number(m.monitor_data->>''90'', ''999'') as after_bp_high
		,to_number(m.monitor_data->>''91'', ''999'') as after_bp_low
		,to_number(m.monitor_data->>''92'', ''999'') as after_bp_ave
		,to_number(m.monitor_data->>''93'', ''999'') as after_pulse
	FROM
		ord_tbl AS ord
	LEFT OUTER JOIN mni_monitor_tbl AS m ON m.ord_no = ord.ord_no
	WHERE
		m.facility_cd = @facilityCd
		AND m.ord_no = ord.ord_no
		AND m.data_type = 6
)
, tmp AS (
    SELECT
		ord.pat_id,
		ord.ord_no,
		ord.treat_date,
        CAST( ord.rst_weight_info ->> ''weight_before''  AS DECIMAL ) AS weight_before,
        ( ord.rst_weight_info ->> ''weight_before_date'' ) :: TIMESTAMP AS weight_before_date,
        CAST( ord.rst_weight_info ->> ''weight_after'' AS DECIMAL ) AS weight_after,
        ( ord.rst_weight_info ->> ''weight_after_date'' ) :: TIMESTAMP AS weight_after_date,
        CAST( ord.rst_weight_info ->> ''ctr'' AS DECIMAL  ) AS ctr,
        ( ord.rst_weight_info ->> ''ctr_measure_date'' ) :: TIMESTAMP AS ctr_measure_date,
        CAST( ord.rst_weight_info ->> ''ctr_weight'' AS DECIMAL ) AS ctr_weight,
        CAST( ord.rst_weight_info ->> ''kt_v_measure'' AS DECIMAL ) AS kt_v_measure,
        CAST( ord.rst_weight_info ->> ''urr'' AS DECIMAL  ) AS urr,
        CAST( ord.rst_weight_info ->> ''sttc_vns_prssr'' AS DECIMAL ) AS sttc_vns_prssr,
        CAST( ord.rst_weight_info ->> ''iap_rt'' AS DECIMAL  ) AS iap_rt,
        CASE 
          WHEN regexp_replace(split_part(ord.rst_weight_info -> ''recrcl_rt'' -> ( ord.rst_weight_info -> ''recrcl_rt'' ->> ''valid_no'' ) ->> ''rate'', ''.'', 2), ''0'', '''', ''g'') = '''' 
            THEN to_number(split_part(ord.rst_weight_info -> ''recrcl_rt'' -> ( ord.rst_weight_info -> ''recrcl_rt'' ->> ''valid_no'' ) ->> ''rate'', ''.'', 1), ''999'')
          ELSE to_number(regexp_replace(ord.rst_weight_info -> ''recrcl_rt'' -> ( ord.rst_weight_info -> ''recrcl_rt'' ->> ''valid_no'' ) ->> ''rate'', ''0+$'', ''''),''999.999'')
        END AS re_loop_rate,
		CAST( ord.rst_weight_info ->> ''ihdf_pll''  AS DECIMAL ) AS ihdf_pll,
        CAST( ord.rst_weight_info ->> ''water_removal_target''  AS DECIMAL ) AS water_removal_target,
        CAST( ord.rst_weight_info ->> ''water_removal_rst''  AS DECIMAL ) AS water_removal_rst,
        CAST( ord.rst_weight_info ->> ''add_water_total''  AS DECIMAL ) AS add_water_total,
        CAST( ord.rst_weight_info ->> ''weight_decreased''  AS DECIMAL ) as weight_decreased,
		ord.rst_dw,
		
		maeInfo.before_vital_measure_date,
		maeInfo.before_bp_high,
		maeInfo.before_bp_low,
		maeInfo.before_bp_ave,
		maeInfo.before_pulse,
		
		atoInfo.after_vital_measure_date,
		atoInfo.after_bp_high,
		atoInfo.after_bp_low,
		atoInfo.after_bp_ave,
		atoInfo.after_pulse
    FROM
        ord_tbl AS ord
	LEFT JOIN ord_hist_mae AS maeInfo ON ord.ord_no = maeInfo.ord_no
	LEFT JOIN ord_hist_ato AS atoInfo ON ord.ord_no = atoInfo.ord_no
),
	b AS (
    select ord_main.* from ord_main
     where 	rst_dialysis_state between ''1'' and ''5''
     and
	   ord_no in (@ordNos)
     and
       is_del = ''0''
), d AS (
    select b.ord_no
    , data_type
    , MAX(bio_moni_ctl_no) AS bio_moni_ctl_no
    from b inner join mni_monitor on (b.ord_no = mni_monitor.ord_no) and b.facility_cd = mni_monitor.facility_cd
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
, b.ord_no as ordnob
from  b left join e on b.ord_no = e.ord_no left join f on b.ord_no = f.ord_no)
		   SELECT
    g.*,tmp.*,
    before_bp_high :: TEXT || ''/'' || before_bp_low :: TEXT || ''/'' || before_bp_ave || ''('' || before_pulse :: TEXT || '')'' AS before_bp_summary,
    after_bp_high :: TEXT || ''/'' || after_bp_low :: TEXT || ''/'' || after_bp_ave || ''('' || after_pulse :: TEXT || '')'' AS after_bp_summary
FROM
    tmp
left join
	g
on tmp.ord_no=g.ordnob', 2, '[]', '0', '{"applications": [1]}', '{"classes": [3]}', '実績：体重情報/血圧情報 @ordNos 使用', '2025-04-23 16:14:27.115', CURRENT_TIMESTAMP, NULL);
