UPDATE sys_data_set
SET "sql"='select
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
;'
WHERE sql_cd=103;
