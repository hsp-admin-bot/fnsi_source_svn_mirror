select pat_id,
       ctl_no,
       treat_week,
       ind_treat_start_time,
       kur_standard_start_time,
       duration::int,
       ptp_kur_cd,
       mk_kur_cd,
       kur_start_time,
       kur_end_time
from (select pat_id,
             ctl_no,
             treat_week,
             ind_sch_info ->> 'ind_treat_start_time' || '00'  as ind_treat_start_time,
             mk.kur_standard_start_time,
             cast(ind_cond_info ->> '1' as jsonb) ->> 'value' as duration,
             ptp.ind_kur_cd                                   as ptp_kur_cd,
             mk.kur_cd                                        as mk_kur_cd,
             mk.kur_start_time,
             mk.kur_end_time
      from pat_treatment_pattern ptp
             left join mst_kur mk on ptp.ind_kur_cd = mk.kur_cd and ptp.facility_cd = mk.facility_cd and mk.is_del = '0'
      where ptp.facility_cd = /*facilityCd*/null
      order by treat_week) t
where t.ptp_kur_cd <> '0'
  and ((t.ind_treat_start_time < t.kur_start_time or t.ind_treat_start_time > t.kur_end_time) or
       (t.ptp_kur_cd is not null and t.mk_kur_cd is null));
