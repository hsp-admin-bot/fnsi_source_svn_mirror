SELECT DISTINCT 
  pat_id
FROM ord_main
WHERE
  treat_date = /*treatDate*/null  

/*%if 0 < kurCode.size() */
  AND ind_kur_cd IN /*kurCode*/(0)
/*%end*/

/*%if null != bedGroup */
  AND ind_bed_cd IN (
    SELECT e::text::int
    FROM mst_room_bed_group, json_array_elements(bed_list::json) e
    WHERE room_bed_group_cd = /*bedGroup*/0
  )
/*%end*/
;