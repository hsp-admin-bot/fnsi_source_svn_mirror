select
  bio_moni_ctl_no
  , data_type
  , occur_date
  , bp_class
  , cast(bp_max as decimal)
  , cast(bp_min as decimal)
  , cast(bp_ave as decimal)
  , cast(pulse as decimal)
  , cast(temperature as decimal)
  , cast(blood_sugar_level as decimal)
  , is_del
from
(
  select
    ord_no
    , bio_moni_ctl_no
    , data_type
    , occur_date
    , null as bp_class
    , monitor_data->>'90' as bp_max
    , monitor_data->>'91' as bp_min
    , monitor_data->>'92' as bp_ave
    , monitor_data->>'93' as pulse
    , monitor_data->>'94' as temperature
    , monitor_data->>'-1' as blood_sugar_level
    , '0' as is_del
  from
    mni_monitor
  where
    data_type in (2, 4, 5, 6)
  and
    is_del = '0'
) vital_and_monitor
where
  ord_no = /*ordNo*/1
order by
  occur_date
;