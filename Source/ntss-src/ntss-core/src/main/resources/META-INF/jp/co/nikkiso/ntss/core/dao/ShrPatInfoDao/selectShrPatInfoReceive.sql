SELECT  * from shr_pat_info
where is_del = '0'
    AND is_disp = '1'
    AND to_pat_id =/* patId */0
    AND to_facility_cd = /* facilityCd */''

  UNION ALL

     SELECT *
     FROM shr_pat_info
     WHERE is_del = '0'
       AND is_disp = '1'
       AND from_pat_id = /* patId */0
       AND to_facility_cd = /* facilityCd */''
       AND to_pat_id is null
