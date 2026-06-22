SELECT
  comp_treatment_cd AS "compTreatmentCd",
  treatment AS "treatment",
  treat_class AS "treatClass",
  treat_medicine_cd AS "treatMedicineCd",
  amount AS "amount",
  procedure_cd AS "procedureCd",
  facility_cd AS "facilityCd",
  is_disp AS "isDisp",
  is_del AS "isDel"
FROM mst_comp_treatment
WHERE facility_cd = /* params.get("facilityCd") */'0'
  AND is_del = '0'
ORDER BY comp_treatment_cd;
