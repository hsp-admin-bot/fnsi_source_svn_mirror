with dev_log as (
  select
    event_reg_date
    , cast(1 as smallint) as record_kind
    , cast(null as smallint) as ctl_no
    , machine_record_message
    , cast(0 as bigint) as ord_no
  from
    mnt_motion_record
  where
    data_type = 1
    and facility_cd = /*facilityCd*/'1'
    and machine_type_cd = /*machineTypeCd*/'1'
    and machine_serial = /*machineSerial*/'1'
    and event_reg_date >= /*fromDate*/'1970/01/01 00:00:00'
)
select
  event_reg_date ,
  machine_record_message ,
  count(event_reg_date) over()
from
  (
    select
      *
    from
      dev_log
  ) as union_tbl
order by
  event_reg_date desc
  , record_kind
  , ctl_no desc
limit 10
offset /*offset*/0
;
