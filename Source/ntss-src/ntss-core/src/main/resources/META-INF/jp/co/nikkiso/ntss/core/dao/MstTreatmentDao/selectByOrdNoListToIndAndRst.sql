SELECT
  /*%expand "A" */*
FROM mst_treatment A
WHERE EXISTS (
    SELECT 1
    FROM ord_main o
    WHERE o.ord_no in /*ordNoList*/(null)
      AND (
            o.ind_treatment_cd = A.treatment_cd
         OR (o.rst_dialysis_state <> '0'
             AND o.rst_treatment_cd = A.treatment_cd)
      )
)