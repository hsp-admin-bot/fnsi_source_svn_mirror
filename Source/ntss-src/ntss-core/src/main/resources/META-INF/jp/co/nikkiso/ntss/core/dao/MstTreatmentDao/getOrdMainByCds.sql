SELECT
  count(1)
FROM
  ord_main
WHERE
    ind_treatment_cd IN /*indTreatmentCdList*/(null)
GROUP BY
  ind_treatment_cd
