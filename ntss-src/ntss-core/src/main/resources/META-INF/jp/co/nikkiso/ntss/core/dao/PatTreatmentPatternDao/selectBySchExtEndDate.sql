SELECT
  A.pat_id,
  A.ctl_no,
  A.facility_cd,
  A.treat_type,
  A.ind_treat_start_date,
  A.ind_treatment_cd,
  A.ind_kur_cd,
  A.treat_week,
  A.ind_sch_info,
  A.ind_cond_info,
  A.ind_medi_info,
  A.ind_equip_info,
  A.ind_ind_comment_info,
  A.ind_tare_info,
  A.ind_off_water_info,
  A.ind_device_set_info,
  A.reg_date,
  A.up_date,
  B.sch_ext_end_date
FROM
  pat_treatment_pattern A
  LEFT JOIN
    pat_main B
  ON
    A.pat_id = B.pat_id
WHERE
  B.is_del = '0'
AND
  B.sch_ext_end_date < /* sch_ext_end_date */null
ORDER BY
  B.facility_cd,
  B.pat_id,
  A.ctl_no
;
