SELECT count(1)
FROM pat_rad_main
WHERE facility_cd = /* facility_cd */null
  AND pat_id = /* pat_id */null
  AND is_del = '0'
  AND rad_status = '0'
  AND (
    /*%for moveOutDate : moveOutDateMapList*/
        (
                reg_rad_date >= /*moveOutDate.get("ind_start_date")*/null
                AND
                reg_rad_date <= /*moveOutDate.get("ind_end_date")*/null)
        /*%if moveOutDate_has_next */
        OR
    /*%end*/
    /*%end*/
    )
;
