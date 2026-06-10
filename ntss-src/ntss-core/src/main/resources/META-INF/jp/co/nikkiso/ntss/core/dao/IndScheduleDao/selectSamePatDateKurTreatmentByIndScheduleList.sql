select
  A.facility_cd
  ,A.ord_no
  ,A.pat_id
  ,A.treat_date
  ,A.ind_kur_cd
  ,A.ind_bed_cd
  ,A.ind_treatment_cd
from
  ord_main A
where
  A.facility_cd = /*facilityCd*/null
  /*%if indScheduleInfoList != null && indScheduleInfoList.size() > 0 */
  and (A.pat_id, A.treat_date, A.ind_kur_cd, A.ind_treatment_cd) in (
/*%for isl : indScheduleInfoList */
    (
      /*isl.patId*/0,
      /*isl.treatDate*/null,
      /*isl.indKurCd*/0,
      /*isl.indTreatmentCd*/0
    )
  /*%if isl_has_next */
  /*# "," */
  /*%end*/
/*%end*/
  )
  /*%end*/
/*%if excludeOrdNoList != null && excludeOrdNoList.size() > 0 */
  and A.ord_no NOT IN /*excludeOrdNoList*/(null)
/*%end*/
