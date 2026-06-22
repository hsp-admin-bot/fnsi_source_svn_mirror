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
  A.facility_cd = /*facility_cd*/null
	AND
  to_date(B.sch_ext_end_date, 'yyyyMMdd') <
    date_trunc('month', CURRENT_DATE + interval '1 year 1 month') - interval '1 day' --1年後の月末日
ORDER BY
  pat_id, ctl_no
;
