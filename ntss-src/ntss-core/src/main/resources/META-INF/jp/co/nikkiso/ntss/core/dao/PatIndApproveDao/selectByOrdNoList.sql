SELECT  /*%expand "A" */*
FROM pat_ind_approve A
WHERE A.ord_no IN /*ord_no*/(null)
ORDER BY A.reg_date
