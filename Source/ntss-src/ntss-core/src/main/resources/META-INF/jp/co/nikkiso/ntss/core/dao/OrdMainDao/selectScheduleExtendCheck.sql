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
AND A.ind_kur_cd > 0
AND A.ind_bed_cd > 0
AND (treat_date,ind_kur_cd,ind_bed_cd) in(
/*%for ordMain : ordMainList*/
(
/* ordMain.treatDate*/null,
/* ordMain.indKurCd*/0,
/* ordMain.indBedCd*/0
)
/*%if ordMain_has_next */
    /*# "," */
/*%end*/
/*%end*/
)
AND
  A.is_del = '0'
ORDER BY
  A.treat_date;
