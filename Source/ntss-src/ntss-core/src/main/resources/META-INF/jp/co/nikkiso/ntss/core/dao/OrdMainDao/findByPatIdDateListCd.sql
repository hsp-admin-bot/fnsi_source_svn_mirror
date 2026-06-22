SELECT count(1)
FROM ord_main
WHERE pat_id = /*pat_id*/1
  AND facility_cd = /*facility_cd*/'000000'
  AND is_del = '0'
  AND (
    /*%for moveOutDate : moveOutDateMapList*/
        (
                treat_date >= /*moveOutDate.get("ind_start_date")*/null
                AND
                treat_date <= /*moveOutDate.get("ind_end_date")*/null)
        /*%if moveOutDate_has_next */
        OR
    /*%end*/
    /*%end*/
    )
;