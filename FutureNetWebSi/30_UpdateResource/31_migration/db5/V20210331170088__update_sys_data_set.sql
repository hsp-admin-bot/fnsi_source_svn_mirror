UPDATE ntss.sys_data_set
SET "sql"='with hist_ord_nos as (
  select
    ord_main.ord_no
    ,ord_main.rst_start_date
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
  array_ord_no[1] as ord_no_prev
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
;'
WHERE sql_cd=104;
