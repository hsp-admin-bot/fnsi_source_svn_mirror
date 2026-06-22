SELECT pat_id, facility_cd, ord_no, treat_date, rst_weight_info
FROM (
         SELECT O.pat_id, O.facility_cd, tmp.ord_no, tmp.treat_date, O.rst_weight_info,
                ROW_NUMBER() OVER (PARTITION BY tmp.pat_id,tmp.facility_cd,tmp.ord_no,tmp.treat_date ORDER BY O.rst_return_home_date DESC) AS row_num
         FROM ord_main O
                  LEFT OUTER JOIN mst_treatment T ON O.rst_treatment_cd = T.treatment_cd
                  JOIN (
             VALUES
                 /*%for data : dataList */
                 (/*data.patId*/null, /*data.facilityCd*/'', /*data.ordNo*/null, /*data.treatDate*/'')
                     /*%if data_has_next */
                     /*# "," */
                     /*%end */
                 /*%end*/
         ) AS tmp (pat_id, facility_cd, ord_no, treat_date)
                       ON O.pat_id = tmp.pat_id
                           AND O.facility_cd = tmp.facility_cd
                           AND O.ord_no <> tmp.ord_no
                           AND O.rst_return_home_date < CAST(tmp.treat_date AS Timestamp)
                           AND O.is_del = '0'
                           AND T.device_mode <> 9
     ) AS subquery
WHERE row_num = 1
;