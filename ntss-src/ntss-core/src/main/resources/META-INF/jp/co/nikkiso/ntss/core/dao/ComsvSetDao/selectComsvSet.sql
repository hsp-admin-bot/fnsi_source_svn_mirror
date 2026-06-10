select
  is_timeset,
  timeset_time,
  is_timeset_nx,
  timeset_nx_time,
  lcd_log_time,
  lcd_log_type,
  is_lcd_medi,
  end_wait_time,
  pat_timing,
  is_notice,
  notice_time,
  log_upload_time,
  offline_start_time,
  is_offline_auto_end,
  reload_next_pat_time,
  next_pat_mode,
  next_pat_mode_range,
  device_timeout,
  treat_moni_interval,
  other_moni_interval,
  treat_realtime_monito_interval,
  other_realtime_monito_interval,
  lcd_menu,
  lcd_npat,
  lcd_report,
  lcd_graph1,
  lcd_graph2,
  lcd_radar,
  is_notice_medi,
  lcd_medi_time
from
  mst_comsv_setting
where
  facility_cd = /*facilityCd*/'000001'
and
  device_edge_no = /*deviceEdgeNo*/1
and
  is_disp = '1'
and
  is_del = '0'
order by comsv_cd desc
LIMIT 1 OFFSET 0
;
