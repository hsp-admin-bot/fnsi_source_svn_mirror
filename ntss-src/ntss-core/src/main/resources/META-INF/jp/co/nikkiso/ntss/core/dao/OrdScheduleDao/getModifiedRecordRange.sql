select count(1) as cnt
from ord_main om
       left join mst_kur mk on om.ind_kur_cd = mk.kur_cd and om.facility_cd = mk.facility_cd and mk.is_del = '0'
where om.facility_cd = /* facilityCd */'NKKSBR'
  and om.ind_treat_start_time is not null
  and om.rst_dialysis_state = '0'
  and om.treat_date >= to_char(now(), 'YYYYMMDD')
  and ((om.ind_treat_start_time || '00' < mk.kur_start_time or om.ind_treat_start_time || '00' > mk.kur_end_time) or
       (om.ind_kur_cd is not null and mk.kur_cd is null))

union all

select count(1) as cnt
from ord_main om
       inner join mst_kur mk on om.ind_kur_cd = mk.kur_cd and om.facility_cd = mk.facility_cd
where om.facility_cd = /* facilityCd */'NKKSBR'
  and om.ind_treat_start_time is not null
  and om.rst_dialysis_state = '0'
  and om.treat_date >= to_char(now(), 'YYYYMMDD')
  and om.ind_treat_start_time || '00' >= mk.kur_start_time and om.ind_treat_start_time || '00' <= mk.kur_end_time

union all

select count(1) as cnt
from ord_schedule os
       inner join mst_kur mk
                  on os.facility_cd = mk.facility_cd and os.kur_cd = mk.kur_cd and mk.is_del = '1' and
                     os.is_dummy = '1'
where os.facility_cd = /* facilityCd */'NKKSBR'
  and os.treat_date >= to_char(now(), 'YYYYMMDD');

