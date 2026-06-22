SELECT
  om.ord_no,

  om.pat_id,

  om.treat_date,

  om.treat_week,

  om.ind_treatment_cd,

  om.ind_kur_cd,

  om.ind_bed_cd,

  mk.kur_standard_start_time as treat_start_time,

  om.ind_cond_info -> '1' ->> 'value' as treat_time,

  mk.kur_name,

  mb.bed_name,

  om.ind_medi_info,

  om.rst_dialysis_state,

  om.treat_type

FROM
  ord_main om LEFT JOIN mst_kur mk ON om.facility_cd = mk.facility_cd and om.ind_kur_cd = mk.kur_cd and mk.is_del = '0'
              LEFT JOIN mst_bed mb ON om.facility_cd = mb.facility_cd and om.ind_bed_cd = mb.bed_cd and mb.is_del = '0'
WHERE

  om.facility_cd = /*facilityCd*/null

  AND om.treat_date >= /*startDate*/null
  /*%if null != endDate */
  AND om.treat_date <= /*endDate*/null
  /*%end*/
  /*%if null != ownOrdNoList && ownOrdNoList.size() > 0 && bedList != null && bedList.size() > 0*/
  AND om.ord_no NOT IN /*ownOrdNoList*/(NULL)
  AND om.ind_bed_cd IN /*bedList*/(NULL)
  AND om.ind_kur_cd != 0
  /*%elseif treatmentCd != null*/
  AND om.pat_id = /*patId*/0
  AND om.rst_dialysis_state = '0'
  AND om.ind_treatment_cd = /*treatmentCd*/null
  /*%end*/
  AND om.is_del = '0'

