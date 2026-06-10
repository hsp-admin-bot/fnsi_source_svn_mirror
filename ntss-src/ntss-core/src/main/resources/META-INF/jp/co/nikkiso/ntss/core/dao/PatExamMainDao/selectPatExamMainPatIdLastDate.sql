SELECT 
    pat_id,
    pat_id_dst,
    to_char(MAX(result_exam_date),'yyyymmddHH24MISS') AS last_date 
FROM (pat_exam_main  AS b1
        LEFT JOIN pat_name_identification AS b2 
        ON b1.facility_cd = b2.facility_cd_src AND b1.pat_id = b2.pat_id_src)
WHERE exam_status = '1'
AND is_del = '0'
/*%if facilityCd != null*/
AND (facility_cd IN (SELECT a.facility_cd_src
FROM pat_name_identification AS a
WHERE a.approve = '1'
  AND a.receive = '1'
  AND a.is_open = '1'
  AND a.facility_cd_dst = /*facilityCd*/NULL
) OR facility_cd = /*facilityCd*/NULL )
/*%end */
/*%if patIdList != null*/
AND (pat_id in /*patIdList*/(NULL) OR pat_id IN (SELECT DISTINCT pat_id_src 
                                            FROM ntss.pat_exam_main AS a1
                                                LEFT JOIN ntss.pat_name_identification AS a2 
                                                ON a1.facility_cd = a2.facility_cd_src AND a1.pat_id = a2.pat_id_src))
/*%end */
GROUP BY pat_id, pat_id_dst;