SELECT
  A.ord_no,
  A.pat_id,
  A.treat_date,
  A.facility_cd,
  A.ind_kur_cd,
  A.ind_bed_cd
FROM
  ord_main A
WHERE A.facility_cd = /*facilityCd*/''
AND A.is_del = '0'
AND (treat_date,ind_kur_cd,ind_bed_cd,pat_id,ind_treatment_cd) in(
/*%for ordMain : ordMainList*/
(
/* ordMain.treatDate*/null,
/* ordMain.indKurCd*/0,
/* ordMain.indBedCd*/0,
/* ordMain.patId*/0,
/* ordMain.indTreatmentCd*/0
)
/*%if ordMain_has_next */
    /*# "," */
/*%end*/
/*%end*/
)
ORDER BY
    A.treat_date;
