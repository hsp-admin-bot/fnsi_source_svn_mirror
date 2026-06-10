with addminutes AS (
select
    ord_main.ind_cond_info::json#>>'{1,value}' as treatment_time
from
    ord_main
where
    facility_cd = /*facilityCd*/'000000'
and
    pat_id = /*patId*/1
/*%if treatDateFrom != null */
and
    treat_date >= /*treatDateFrom*/'00010101'
/*%end */
/*%if treatDateTo != null */
and
    treat_date <= /*treatDateTo*/'99991231'
/*%end */
and
    is_del = '0'
    limit 1)
select
    indication_result.ord_no as ord_no
  , '1' as category
  , indication_result.ind_rst_type as ind_rst_type
  , indication_result.treatment_date as treatment_date
  , indication_result.treatment_cd as treatment_cd
  , CASE WHEN indication_result.treatment_cd is null or indication_result.treatment_cd = 0 THEN '治療方法未登録'
         ELSE CASE WHEN mt.treatment_cd is null or mt.is_del != '0' or mt.is_disp != '1' THEN '治療方法削除済み'
                   ELSE CASE WHEN indication_result.treatment_name is null THEN mt.treatment_name ELSE indication_result.treatment_name END
             END
    END AS treatment_name
  , indication_result.kur_cd as kur_cd
  , CASE WHEN indication_result.kur_cd is null or indication_result.kur_cd = 0 THEN 'クール未登録'
         ELSE CASE WHEN kur.kur_cd is null or kur.is_del != '0' THEN 'クール削除済み'
                   ELSE CASE WHEN indication_result.kur_name is null THEN kur.kur_name ELSE indication_result.kur_name END
              END
    END AS kur_name
  , CASE WHEN indication_result.kur_cd is null or indication_result.kur_cd = 0 THEN '000000'
         ELSE CASE WHEN kur.kur_cd is null or kur.is_del != '0' THEN '000000'
                   ELSE kur.kur_start_time
              END
    END AS kur_start_time
  , indication_result.start_date as start_date
  , indication_result.end_date as end_date
  , indication_result.bed_cd as bed_cd
  , CASE WHEN indication_result.bed_cd is null or indication_result.bed_cd = 0 THEN 'ベッド未登録'
         ELSE CASE WHEN bed.bed_cd is null or bed.is_del != '0' or bed.is_disp != '1' THEN 'ベッド削除済み'
                   ELSE CASE WHEN indication_result.bed_name is null THEN bed.bed_name ELSE indication_result.bed_name END
             END
    END AS bed_name
  , CASE WHEN indication_result.rst_dialysis_state = '0' THEN '【削除済み】' || mt.treatment_name ELSE mt.treatment_name END as treatment_name_mst
  , CASE WHEN indication_result.rst_dialysis_state = '0' THEN '【削除済み】' || bed.bed_name ELSE bed.bed_name END as bed_name_mst
  , CASE WHEN indication_result.rst_dialysis_state = '0' THEN '【削除済み】' || kur.kur_name ELSE kur.kur_name END as kur_name_mst
from (
  select
    ord_no
    , pat_id
    , is_del
    , 1 as ind_rst_type
    , treat_date as treatment_date
    , ind_treatment_cd as treatment_cd
    , ind_treatment_name as treatment_name
    , ind_kur_cd as kur_cd
    , ind_kur_name as kur_name
    , null as kur_start_time
    , to_timestamp(treat_date || ind_treat_start_time, 'YYYYMMDDHH24MI') as start_date
    , to_timestamp(treat_date || ind_treat_start_time, 'YYYYMMDDHH24MI') +
      to_number((select treatment_time from addminutes), '9999999') * interval '1 min' as end_date
    , ind_bed_cd as bed_cd
    , ind_bed_name as bed_name
    , facility_cd
    , rst_dialysis_state
  from
    ord_main
  where
    facility_cd = /*facilityCd*/'000000'
  and
    pat_id = /*patId*/1
  /*%if treatDateFrom != null */
  and
      treat_date >= /*treatDateFrom*/'00010101'
  /*%end */
  /*%if treatDateTo != null */
  and
      treat_date <= /*treatDateTo*/'99991231'
  /*%end */
  and
    is_del = '0'
  union all
  select
    ord_no
    , pat_id
    , is_del
    , 2 as ind_rst_type
    , treat_date as treatment_date
    , rst_treatment_cd as treatment_cd
    , rst_treatment_name as treatment_name
    , rst_kur_cd as kur_cd
    , rst_kur_name as kur_name
    , null as kur_start_time
    , rst_start_date as start_date
    , rst_end_date as end_date
    , rst_bed_cd as bed_cd
    , rst_bed_name as bed_name
    , facility_cd
    , rst_dialysis_state
  from
    ord_main
  where
    facility_cd = /*facilityCd*/'000000'
  and
    rst_dialysis_state != '0'
  and
    pat_id = /*patId*/1
  /*%if treatDateFrom != null */
  and
      treat_date >= /*treatDateFrom*/'00010101'
  /*%end */
  /*%if treatDateTo != null */
  and
      treat_date <= /*treatDateTo*/'99991231'
  /*%end */
  and
    is_del = '0'
  ) indication_result
LEFT JOIN mst_kur AS kur
    ON indication_result.kur_cd = kur.kur_cd
        AND indication_result.facility_cd = kur.facility_cd
LEFT JOIN mst_bed bed
    ON bed.bed_cd = indication_result.bed_cd
        AND indication_result.facility_cd = bed.facility_cd
        AND bed.is_del = '0'
        AND bed.is_disp = '1'
LEFT JOIN mst_treatment mt
    ON indication_result.treatment_cd = mt.treatment_cd
        AND indication_result.facility_cd = mt.facility_cd
        AND mt.is_del = '0'
        AND mt.is_disp = '1'
order by
  ind_rst_type
  , treatment_date
  , start_date
;
