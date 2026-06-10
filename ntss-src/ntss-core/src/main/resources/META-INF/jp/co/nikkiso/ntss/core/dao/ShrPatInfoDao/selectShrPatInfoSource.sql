SELECT  * from shr_pat_info
where is_del = '0'
    AND is_disp = '1'
    AND from_facility_cd = /* facilityCd */''
    AND (from_pat_id = /* patId */0 OR (from_pat_id IS NULL AND to_pat_id = /* patId */0));
