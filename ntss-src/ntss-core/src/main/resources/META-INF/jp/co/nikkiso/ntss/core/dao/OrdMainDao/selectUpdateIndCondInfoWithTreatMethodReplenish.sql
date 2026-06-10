SELECT
  ord_no
FROM
  ord_main A
    LEFT JOIN
  mst_treatment B
  ON
      A.ind_treatment_cd = B.treatment_cd
WHERE
    A.ord_no IN /*ordNoList*/() AND
    B.device_mode IN
    /*%if isOnline*/
    (2,3,5,6,9,-1)
  /*%else*/
  (4,7,8,10)
/*%end*/
