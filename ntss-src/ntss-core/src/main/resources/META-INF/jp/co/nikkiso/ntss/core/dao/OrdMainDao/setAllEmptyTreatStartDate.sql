update ord_main
set ind_treat_start_time = substring(mk.kur_standard_start_time, 1, 4)
from mst_kur mk
where ord_main.ind_kur_cd = mk.kur_cd
  and ord_main.facility_cd = mk.facility_cd
  and ord_main.facility_cd = /*facilityCd*/null
  and ind_treat_start_time is null
  and ind_kur_cd <> '0'
  and rst_dialysis_state = '0'
  and treat_date >= to_char(now(), 'yyyymmdd');
