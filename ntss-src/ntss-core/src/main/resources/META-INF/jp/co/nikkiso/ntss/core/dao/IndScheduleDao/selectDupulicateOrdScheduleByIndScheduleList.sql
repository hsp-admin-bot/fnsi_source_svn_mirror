select
  A.facility_cd,
  A.ord_no,
  A.pat_id,
  A.treat_date,
  A.ind_kur_cd,
  A.ind_bed_cd,
  A.ind_treatment_cd
from
  ord_schedule os
inner join mst_kur mk
    on os.facility_cd = mk.facility_cd
   and os.kur_cd = mk.kur_cd
inner join ord_main A
    on A.ord_no = os.ord_no
where
    os.facility_cd = /*facilityCd*/null
    and os.bed_cd > 0

    /*%if excludeOrdNoList != null && excludeOrdNoList.size() > 0 */
    and os.ord_no not in /*excludeOrdNoList*/(null)
    /*%end*/

    and (
        1 = 0
        /*%for isl : indScheduleInfoList */
        or (
            os.bed_cd = /*isl.indBedCd*/0
            and os.ord_no <> /*isl.ordNo*/0
            and (os.treat_date || mk.kur_standard_start_time)
                between /*isl.firstKurTreatDateTime*/null
                    and /*isl.lastKurTreatDateTime*/null
        )
        /*%end*/
    )
;
