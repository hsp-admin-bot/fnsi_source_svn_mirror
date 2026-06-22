SELECT ord.pat_id, ord.ord_no, ord.pat_id, kur.kur_start_time, ord.ind_bed_cd as bed_cd
,ind_treatment_cd
FROM ntss.ord_main ord
LEFT JOIN ntss.mst_kur kur ON ord.ind_kur_cd = kur.kur_cd
WHERE
	ord.facility_cd = /*facilityCd*/NULL
	AND ord.ord_no IN /*ordNoList*/(0)
ORDER BY kur.kur_start_time ASC;
