SELECT
  A.insurance_cd,
  case
    when A.insu_class = 3 then (A.insu_self_info::json->>'insu_self_name')::text
    else A.insu_name
  end insu_name,
  A.is_selected,
  A.is_del
FROM
  pat_insurance A
  LEFT JOIN ord_personal_prescription B on A.insurance_cd = B.insurance_cd
WHERE
    B.ord_prescription_no = /* ordPrescriptionNo*/0
