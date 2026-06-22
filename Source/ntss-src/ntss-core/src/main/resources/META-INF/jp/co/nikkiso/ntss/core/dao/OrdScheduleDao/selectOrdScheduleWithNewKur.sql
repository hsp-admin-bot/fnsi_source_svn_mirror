SELECT DISTINCT
	ord_no,
	facility_cd,
	bed_cd,
	treat_date,
	kur_cd
FROM
	ord_schedule
WHERE
	facility_cd = /*facilityCd*/null
  /*%if 0 < findOrdNoList.size() */
  AND ord_no NOT IN/*findOrdNoList*/(null)
  /*%end*/
	AND (
		1 = 0
		/*%for isl : scheduleList */
		OR ( bed_cd = /*isl.bedCd*/0
		AND treat_date = /*isl.treatDate*/null
		AND kur_cd = /*isl.kurCd*/0
		) /*%end*/

	)
