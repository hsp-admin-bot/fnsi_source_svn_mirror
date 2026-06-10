SELECT
   /*%expand "A" */*
FROM
   mst_holiday A
where 
   facility_cd = /*facilityCd*/NULL;
