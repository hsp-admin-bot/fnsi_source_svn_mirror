SELECT
  ptp.ctl_no,
  ptp.pat_id,
  ptp.treat_week,
  ptp.ind_treatment_cd,
  ptp.ind_kur_cd,
  ptp.ind_sch_info ->> 'ind_bed_cd' as ind_bed_cd,
  mk.kur_standard_start_time as treat_start_time,
  ptp.ind_cond_info -> '1' ->> 'value' as treat_time,
  pm.sch_ext_end_date,
  ptp.treat_type,
  mk.kur_name,
  mb.bed_name
FROM
  pat_treatment_pattern ptp
  JOIN pat_main pm ON
    ptp.facility_cd = pm.facility_cd and ptp.pat_id = pm.pat_id
  LEFT JOIN mst_kur mk ON
    ptp.facility_cd = mk.facility_cd and ptp.ind_kur_cd::int = mk.kur_cd and mk.is_del = '0'
  LEFT JOIN mst_bed mb ON
    ptp.facility_cd = mb.facility_cd and (ptp.ind_sch_info ->> 'ind_bed_cd')::int = mb.bed_cd and mb.is_del = '0'
WHERE
  ptp.facility_cd = /*facilityCd*/null
  /*%if null != patternBedList && patternBedList.size() > 0*/
  AND (ptp.ind_sch_info ->> 'ind_bed_cd')::int IN /*patternBedList*/(NULL)
  /*%elseif treatmentCd != null*/
  AND ptp.pat_id = /*patId*/0
  AND ptp.ind_treatment_cd = /*treatmentCd*/null
  /*%end*/
