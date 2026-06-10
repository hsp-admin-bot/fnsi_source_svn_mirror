SELECT  /*%expand "A" */*
FROM pat_ind_approve A
WHERE A.facility_cd = /*facilityCd*/null AND
      A.ord_no IN /*ordNoList*/(null)
