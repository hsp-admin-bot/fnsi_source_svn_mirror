SELECT
  A.rst_cond_send_date,
  A.rst_dialysis_state,
  A.rst_in_out_class,
  A.rst_medi_info,
  A.rst_puncture_user_info->>'date_1' AS puncture1_date ,
  A.rst_puncture_user_info->>'date_2' AS puncture2_date ,
  A.rst_return_user_info->>'date_1' AS return1_date,
  A.rst_return_user_info->>'date_2' AS return2_date,
  A.rst_start_date,
  A.rst_end_date,
  A.pat_id,
  A.ord_no,
  B.bed_name
FROM
  ord_main A
JOIN
  mst_bed B
ON
  A.rst_bed_cd = B.bed_cd
AND
  A.facility_cd = B.facility_cd
WHERE
  A.facility_cd = /* facilityCd */'000001'
AND
  A.rst_dialysis_state in ('1', '2', '3', '4', '5')
AND
  B.is_del = '0'
;
