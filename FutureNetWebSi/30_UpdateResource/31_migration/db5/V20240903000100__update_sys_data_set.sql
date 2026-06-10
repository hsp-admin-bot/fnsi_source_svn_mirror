DELETE FROM "ntss"."sys_data_set" where sql_cd in (172, 96);
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
  ', 2, '[{"preview": "140", "can_calc": "1", "data_code": "before_bp_high_prev", "data_name": "前血圧（最高）(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_high_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "before_bp_low_prev", "data_name": "前血圧（最低）(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_low_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "before_bp_ave_prev", "data_name": "前血圧（平均）(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_ave_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "before_pulse_prev", "data_name": "前脈拍(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_pulse_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120/80/100(72)", "can_calc": "0", "data_code": "before_bp_summary_prev", "data_name": "前血圧（最高/最低/平均(脈拍)）(前回)", "data_type": "string", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_summary_prev", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:10", "can_calc": "0", "data_code": "before_vital_measure_date_prev", "data_name": "前血圧測定日時(前回)", "data_type": "DateTime", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_vital_measure_date_prev", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "after_bp_high_prev", "data_name": "後血圧（最高）(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_high_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "82", "can_calc": "1", "data_code": "after_bp_low_prev", "data_name": "後血圧（最低）(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_low_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "101", "can_calc": "1", "data_code": "after_bp_ave_prev", "data_name": "後血圧（平均）(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_ave_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "76", "can_calc": "1", "data_code": "after_pulse_prev", "data_name": "後脈拍(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_pulse_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120/80/100(72)", "can_calc": "0", "data_code": "after_bp_summary_prev", "data_name": "後血圧（最高/最低/平均(脈拍)）(前回)", "data_type": "string", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_summary_prev", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:53", "can_calc": "0", "data_code": "after_vital_measure_date_prev", "data_name": "後血圧測定日時(前回)", "data_type": "DateTime", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_vital_measure_date_prev", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "140", "can_calc": "1", "data_code": "before_bp_high_prev_prev", "data_name": "前血圧（最高）(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_high_prev_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "before_bp_low_prev_prev", "data_name": "前血圧（最低）(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_low_prev_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "before_bp_ave_prev_prev", "data_name": "前血圧（平均）(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_ave_prev_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "before_pulse_prev_prev", "data_name": "前脈拍(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_pulse_prev_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120/80/100(72)", "can_calc": "0", "data_code": "before_bp_summary_prev_prev", "data_name": "前血圧（最高/最低/平均(脈拍)）(前々回)", "data_type": "string", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_summary_prev_prev", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:10", "can_calc": "0", "data_code": "before_vital_measure_date_prev_prev", "data_name": "前血圧測定日時(前々回)", "data_type": "DateTime", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_vital_measure_date_prev_prev", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "after_bp_high_prev_prev", "data_name": "後血圧（最高）(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_high_prev_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "82", "can_calc": "1", "data_code": "after_bp_low_prev_prev", "data_name": "後血圧（最低）(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_low_prev_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "101", "can_calc": "1", "data_code": "after_bp_ave_prev_prev", "data_name": "後血圧（平均）(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_ave_prev_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "76", "can_calc": "1", "data_code": "after_pulse_prev_prev", "data_name": "後脈拍(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_pulse_prev_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120/80/100(72)", "can_calc": "0", "data_code": "after_bp_summary_prev_prev", "data_name": "後血圧（最高/最低/平均(脈拍)）(前々回)", "data_type": "string", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_summary_prev_prev", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:53", "can_calc": "0", "data_code": "after_vital_measure_date_prev_prev", "data_name": "後血圧測定日時(前々回)", "data_type": "DateTime", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_vital_measure_date_prev_prev", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [3]}', '実績（治療中）：血圧情報(過去実績) @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (96, 'with ord_tbl as (
  select
    ord_no,
    facility_cd,
    pat_id,
    case
      when coalesce(rst_dialysis_state, ''0'') = ''0'' then to_timestamp( treat_date || coalesce(ind_treat_start_time, ''2359'' ) || ''59'', ''yyyymmddhh24miss'')
      else coalesce(rst_cond_send_date, rst_start_date)
    end as key_date,
    case
      when coalesce(rst_dialysis_state, ''0'') = ''0'' then ind_bed_cd
      else rst_bed_cd
    end as bed_cd
  from
    ord_main
  where
    ord_no = @ordNo and is_del = ''0''

), bed_tbl as (
  select
    *
  from
    mst_bed
  where
    bed_cd = (select bed_cd from ord_tbl)
  and
    is_disp = ''1''
  and
    is_del = ''0''

), machine_tbl as (
  select
    mm.*,
    mmt.machine_type
  from
    mst_machine as mm
      left join mst_machine_type as mmt on mm.machine_type_cd = mmt.machine_type_cd
  where
    machine_no = (select machine_no from bed_tbl)
  and
    is_disp =''1''
  and
    is_del = ''0''

), mente_tbl as (
  select
    mmr.*
  from
    mnt_motion_record mmr
      inner join machine_tbl as mt
        on mmr.facility_cd = mt.facility_cd
          and mmr.machine_type_cd = mt.machine_type_cd
          and mmr.machine_serial = mt.machine_serial
  where
    mmr.event_reg_date <= (select key_date from ord_tbl)
  and
    mmr.data_type = 4

), mente_tbl1 as (
  select
    *
  from
    mente_tbl
  where
    test_type = 1
  order by
    event_reg_date desc
  limit 1

), mente_tbl2 as (
  select
    *
  from
    mente_tbl
  where
    test_type = 2
  order by
    event_reg_date desc
  limit 1

), mente_tbl3 as (
  select
    *
  from
    mente_tbl
  where
    test_type = 3
  order by
    event_reg_date desc
  limit 1

), mente_tbl4 as (
  select
    *
  from
    mente_tbl
  where
    test_type = 4
  order by
    event_reg_date desc
  limit 1

), mente_tbl5 as (
  select
    *
  from
    mente_tbl
  where
    test_type = 5
  order by
    event_reg_date desc
  limit 1

), mente_tbl6 as (
  select
    *
  from
    mente_tbl
  where
    test_type = 6
  order by
    event_reg_date desc
  limit 1

), mente_tbl7 as (
  select
    *
  from
    mente_tbl
  where
    test_type = 7
  order by
    event_reg_date desc
  limit 1

)


select
  mt.machine_no,
  mt.machine_type,
  mt.com_format_cd,
  mt.setting_date,

  tbl1.event_reg_date as dt1_date,
  tbl1.contents->>''43'' as dt1_data43,
  tbl1.contents->>''44'' as dt1_data44,
  tbl1.contents->>''45'' as dt1_data45,
  tbl1.contents->>''46'' as dt1_data46,
  case
    when tbl1.contents->>''47'' in (''000'', ''0101'', ''0201'', ''0301'') then ''1''
    else ''0''
  end as dt1_data47,
  tbl1.contents->>''48'' as dt1_data48,
  tbl1.contents->>''49'' as dt1_data49,

  tbl2.event_reg_date as dt2_date,
  tbl2.contents->>''53'' as dt2_data53,
  tbl2.contents->>''54'' as dt2_data54,

  tbl3.event_reg_date as dt3_date,
  tbl3.contents->>''58'' as dt3_data58,

  tbl4.event_reg_date as dt4_date,
  tbl4.contents->>''63'' as dt4_data63,
  tbl4.contents->>''64'' as dt4_data64,
  case
    when tbl4.contents->>''65'' in (''3001'', ''3101'') then ''1''
    else ''0''
  end as dt4_data65,

  tbl5.event_reg_date as dt5_date,
  tbl5.contents->>''5'' as dt5_data5,
  case
    when tbl5.contents->>''6'' = ''0001'' then ''1''
    else ''0''
  end as dt5_data6,
  tbl5.contents->>''7'' as dt5_data7,
  tbl5.contents->>''8'' as dt5_data8,
  tbl5.contents->>''9'' as dt5_data9,
  tbl5.contents->>''10'' as dt5_data10,
  tbl5.contents->>''11'' as dt5_data11,

  tbl6.event_reg_date as dt6_date,
  tbl6.contents->>''4'' as dt6_data4,
  tbl6.contents->>''5'' as dt6_data5,
  case
    when tbl6.contents->>''6'' = ''3001'' then ''1''
    else ''0''
  end as dt6_data6,

  tbl7.event_reg_date as dt7_date,
  tbl7.machine_record_message as dt7_message

from
  machine_tbl as mt
   left join mente_tbl1 as tbl1
     on mt.facility_cd = tbl1.facility_cd
       and mt.machine_type_cd = tbl1.machine_type_cd
       and mt.machine_serial = tbl1.machine_serial
   left join mente_tbl2 as tbl2
     on mt.facility_cd = tbl2.facility_cd
       and mt.machine_type_cd = tbl2.machine_type_cd
       and mt.machine_serial = tbl2.machine_serial
   left join mente_tbl3 as tbl3
     on mt.facility_cd = tbl3.facility_cd
       and mt.machine_type_cd = tbl3.machine_type_cd
       and mt.machine_serial = tbl3.machine_serial
   left join mente_tbl4 as tbl4
     on mt.facility_cd = tbl4.facility_cd
       and mt.machine_type_cd = tbl4.machine_type_cd
       and mt.machine_serial = tbl4.machine_serial
   left join mente_tbl5 as tbl5
     on mt.facility_cd = tbl5.facility_cd
       and mt.machine_type_cd = tbl5.machine_type_cd
       and mt.machine_serial = tbl5.machine_serial
   left join mente_tbl6 as tbl6
     on mt.facility_cd = tbl6.facility_cd
       and mt.machine_type_cd = tbl6.machine_type_cd
       and mt.machine_serial = tbl6.machine_serial
   left join mente_tbl7 as tbl7
     on mt.facility_cd = tbl7.facility_cd
       and mt.machine_type_cd = tbl7.machine_type_cd
       and mt.machine_serial = tbl7.machine_serial

', 2, '[{"preview": "1", "can_calc": "0", "data_code": "machine_no", "data_name": "装置番号", "data_type": "string", "conv_table": [], "data_class": "自己診断", "field_name": "machine_no", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DCS3", "can_calc": "0", "data_code": "machine_type", "data_name": "機種", "data_type": "string", "conv_table": [], "data_class": "自己診断", "field_name": "machine_type", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt1_date", "data_name": "配管自己診断測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt2_date", "data_name": "漏血テスト測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt2_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt4_date", "data_name": "濃度自己診断測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt4_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt3_date", "data_name": "透析液流量自己診断測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt3_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt5_date", "data_name": "配管テスト測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt6_date", "data_name": "希釈テスト測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt6_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt7_date", "data_name": "通信共通自己診断測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt7_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/01/01", "can_calc": "0", "data_code": "setting_date", "data_name": "設置日", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "relation_name", "disp_format": "yyyy/mm/dd", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "dt1_data47", "data_name": "配管自己診断測定結果", "data_type": "string", "conv_table": [{"code": "0", "disp": "不合格", "item": "不合格"}, {"code": "1", "disp": "合格", "item": "合格"}], "data_class": "自己診断", "field_name": "dt1_data47", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13", "can_calc": "0", "data_code": "dt1_data43", "data_name": "配管系漏れ(陰圧)", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data43", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "dt1_data44", "data_name": "配管系漏れ(陽圧)", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data44", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-3", "can_calc": "0", "data_code": "dt1_data48", "data_name": "除水テスト", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data48", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-40", "can_calc": "0", "data_code": "dt1_data46", "data_name": "バランステスト", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data46", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "0", "data_code": "dt1_data45", "data_name": "CFフィルタ漏れ", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data45", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "dt1_data49", "data_name": "CFsフィルタ漏れ", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data49", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.203", "can_calc": "0", "data_code": "dt2_data53", "data_name": "赤電圧", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt2_data53", "disp_format": "0.000", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.426", "can_calc": "0", "data_code": "dt2_data54", "data_name": "緑電圧", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt2_data54", "disp_format": "0.000", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "dt4_data65", "data_name": "濃度自己診断結果", "data_type": "string", "conv_table": [{"code": "0", "disp": "不合格", "item": "不合格"}, {"code": "1", "disp": "合格", "item": "合格"}], "data_class": "自己診断", "field_name": "dt4_data65", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dt4_data63", "data_name": "B原液濃度", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt4_data63", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dt4_data64", "data_name": "A原液濃度", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt4_data64", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dt3_data58", "data_name": "透析液流量測定値", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt3_data58", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dt5_data5", "data_name": "排液判定時間", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data5", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "dt5_data6", "data_name": "配管テスト結果", "data_type": "string", "conv_table": [{"code": "0", "disp": "不合格", "item": "不合格"}, {"code": "1", "disp": "合格", "item": "合格"}], "data_class": "自己診断", "field_name": "dt5_data6", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-10", "can_calc": "0", "data_code": "dt5_data7", "data_name": "給水圧", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data7", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "dt5_data8", "data_name": "送液圧（低）", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data8", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "0", "data_code": "dt5_data9", "data_name": "送液圧（高）", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data9", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "dt5_data10", "data_name": "濃度セル3", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data10", "disp_format": "0.0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15.0", "can_calc": "0", "data_code": "dt5_data11", "data_name": "濃度セル4", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data11", "disp_format": "0.0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.00", "can_calc": "0", "data_code": "dt6_data4", "data_name": "B液濃度", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt6_data4", "disp_format": "0.00", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "dt6_data5", "data_name": "透析液濃度", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt6_data5", "disp_format": "0.0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "dt6_data6", "data_name": "希釈テスト結果", "data_type": "string", "conv_table": [{"code": "0", "disp": "不合格", "item": "不合格"}, {"code": "1", "disp": "合格", "item": "合格"}], "data_class": "自己診断", "field_name": "dt6_data6", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "自己診断メッセージです。", "can_calc": "0", "data_code": "dt7_message", "data_name": "通信共通自己診断測定結果", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt7_message", "disp_format": "0.0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 9]}', '装置保守：自己診断　@ordNo使用', '2020-03-30 16:59:00', CURRENT_TIMESTAMP, NULL);
