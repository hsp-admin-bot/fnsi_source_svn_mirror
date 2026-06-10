select
  om.ord_no,
  om.pat_id,
  om.ind_kur_cd,
  om.treat_date,
  om.ind_treat_start_time,
  om.ind_cond_info
from
  (
    select
      *
    from
      mnt_machine_state
    where
		  facility_cd = /*facilityCd*/null
		and
		  machine_type_cd = /*machineTypeCd*/null
		and
		  machine_serial = trim(/*machineSerial*/null)
  ) mms,
  (
    select
      *
    from
      ord_main
    where
      facility_cd = /*facilityCd*/null
/*%if(isSendCondition)*/
    and
      (
        rst_dialysis_state = '1'
      or
        rst_dialysis_state = '2'
      ) --1,2：条件送信済み・確認済みのデータのみ対象
/*%else */
    and
      rst_dialysis_state = '0' --0：条件送信前のデータのみ対象
/*%end */
    and
      ind_bed_cd <> 0
    and
      ind_kur_cd <> 0
    and
      is_del = '0'
    and
      treat_date >= /*searchStartDate*/null
/*%if(null != searchEndDate)*/
    and
      treat_date <= /*searchEndDate*/null
/*%end */
  ) om,
  (
    select
      *
    from
      mst_kur
    where
      facility_cd = /*facilityCd*/null
    and
      is_del = '0'
  ) mk
where
  mms.bed_cd = om.ind_bed_cd
and
  om.ind_kur_cd = mk.kur_cd
order by
  om.treat_date, mk.kur_standard_start_time, mk.kur_cd, om.up_date desc
;
