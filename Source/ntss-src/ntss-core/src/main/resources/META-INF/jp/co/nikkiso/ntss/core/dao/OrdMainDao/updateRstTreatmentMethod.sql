UPDATE
  ord_main
SET
  ind_treatment_name = /*treatmentName*/null,
  rst_treatment_cd = /*treatmentCd*/0,
  rst_treatment_name = /*treatmentName*/null
WHERE
  ord_no in /*ordNoList*/()