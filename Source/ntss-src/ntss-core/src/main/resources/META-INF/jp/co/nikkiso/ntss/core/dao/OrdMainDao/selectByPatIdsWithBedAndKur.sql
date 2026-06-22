SELECT DISTINCT ON (ord.pat_id) ord.ord_no, ord.pat_id, kur.kur_start_time, bed.bed_name
-- add FNSI-No.341 患者リストのソート項目不足 吉 start
,ind_treatment_cd
-- add FNSI-No.341 患者リストのソート項目不足  吉 end
FROM ntss.ord_main ord
LEFT JOIN ntss.mst_kur kur ON ord.ind_kur_cd = kur.kur_cd
LEFT JOIN ntss.mst_bed bed ON ord.ind_bed_cd = bed.bed_cd
WHERE
	ord.facility_cd = /*facilityCd*/NULL
	AND ord.pat_id IN /*patIds*/(0)
	AND ord.treat_date = /*treatDate*/NULL
ORDER BY ord.pat_id, kur.kur_start_time ASC;
