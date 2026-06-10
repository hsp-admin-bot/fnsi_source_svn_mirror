select count(*)
FROM
	ord_schedule sche
	JOIN ord_main ord ON sche.facility_cd = ord.facility_cd
	AND sche.ord_no = ord.ord_no
WHERE
sche.facility_cd = /*facilityCd*/NULL
AND (ord.ord_no, sche.kur_cd, sche.bed_cd, sche.treat_date, ord.rst_dialysis_state) in (
    VALUES
    (0, 0, 0, null, null)
 /*%for item : indScheduleInfoList */
    ,(
        /*item.ordNo*/0,
        /*item.indKurCd*/0,
        /*item.indBedCd*/0,
        /*item.treatDate*/null,
        /*item.rstDialysisState*/null
    )
 /*%end*/
)
  AND sche.is_dummy = '0'
