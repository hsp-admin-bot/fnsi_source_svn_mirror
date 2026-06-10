select om.ord_no
     , om.pat_id
     , om.treat_date
from ord_main om
       left join mst_kur mk on om.ind_kur_cd = mk.kur_cd and om.facility_cd = mk.facility_cd and mk.is_del = '0'
where om.facility_cd = /*facilityCd*/null
  and om.ind_treat_start_time is not null
  and om.rst_dialysis_state = '0'
  and om.treat_date >= to_char(now(), 'YYYYMMDD')
  and ((om.ind_treat_start_time || '00' < mk.kur_start_time or om.ind_treat_start_time || '00' > mk.kur_end_time) or
       (om.ind_kur_cd is not null and mk.kur_cd is null));
