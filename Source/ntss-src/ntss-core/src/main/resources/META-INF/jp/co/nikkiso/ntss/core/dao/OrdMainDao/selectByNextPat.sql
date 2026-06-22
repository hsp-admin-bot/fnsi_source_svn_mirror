select
  om.ord_no,
  om.pat_id,
  om.ind_kur_cd,
  om.treat_date,
  om.ind_treat_start_time,
  om.ind_cond_info
from
  ord_main om
  inner join mnt_machine_state mms on om.facility_cd = mms.facility_cd and om.ind_bed_cd = mms.bed_cd
  inner join mst_kur mk on om.facility_cd = mk.facility_cd and om.ind_kur_cd = mk.kur_cd
where
  mms.facility_cd = /*facilityCd*/null
  and
  mms.machine_type_cd = /*machineTypeCd*/null
  and
  mms.machine_serial = trim(/*machineSerial*/null)
  and
  mms.bed_cd is not null
  and
  mms.bed_cd <> 0
  and
  om.rst_dialysis_state = '0' --0：条件送信前のデータのみ対象
  and
  om.is_del = '0'
  and
  mk.is_del = '0'
  and
  om.treat_date >= /*searchStartDate*/null
order by
  om.treat_date, mk.kur_standard_start_time, mk.kur_cd, om.up_date desc
limit 1
