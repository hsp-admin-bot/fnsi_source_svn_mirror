with mon_data as (
  select
    mm.facility_cd as facility_cd,
    mm.machine_type_cd  as machine_type_cd,
    mm.machine_serial as machine_serial ,
    mm.ord_no  as ord_no,
    mm.pat_id as pat_id ,
    mm.occur_date as occur_date,
    mm.data_type as data_type ,
    mm.monitor_data as monitor_data
  from
    mni_monitor mm
  where
    mm.facility_cd = /*facilityCd*/''
    and mm.ord_no in /*ordNoList*/(0)
    and mm.is_del = '0'
  union
  select
    mms.facility_cd as facility_cd,
    mms.machine_type_cd  as machine_type_cd,
    mms.machine_serial  as machine_serial,
    mms.ord_no  as ord_no,
    mms.pat_id as pat_id,
    mms.up_date as occur_date ,
    1 as data_type ,
    mms.monitor_data as monitor_data
  from
    mnt_machine_state mms
  where
    mms.facility_cd = /*facilityCd*/''
    and mms.ord_no in /*ordNoList*/(0)
),
     sorted_data as (
       select
         md.*
       from mon_data md
       order by
         md.machine_type_cd,
         md.machine_serial,
         md.ord_no,
         md.pat_id,
         md.occur_date desc
     )
select
  sd.facility_cd,
  sd.machine_type_cd,
  sd.machine_serial,
  sd.ord_no,
  sd.pat_id,
  jsonb_agg(
    jsonb_build_object('occur_date', sd.occur_date, 'monitor_data', sd.monitor_data, 'data_type' ,sd.data_type)
  ) as monitor_data
from sorted_data sd
group by
  sd.facility_cd,
  sd.machine_type_cd,
  sd.machine_serial,
  sd.ord_no,
  sd.pat_id
