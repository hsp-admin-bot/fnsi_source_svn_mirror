with ind_schedule_info as (
  select facility_cd, ord_no, pat_id, ind_bed_cd, first_kur_treat_date, first_kur_treat_date_time, last_kur_treat_date, last_kur_treat_date_time
  from (
     values
        (null, 0, 0, 0, null, null, null, null)
        /*%for isl : indScheduleInfoList */
        ,(
        /*isl.facilityCd*/null,
        /*isl.ordNo*/0,
        /*isl.patId*/0,
        /*isl.indBedCd*/0,
        /*isl.firstKurTreatDate*/null,
        /*isl.firstKurTreatDateTime*/null,
        /*isl.lastKurTreatDate*/null,
        /*isl.lastKurTreatDateTime*/null
        )
        /*%end*/
   ) as t(facility_cd, ord_no, pat_id, ind_bed_cd, first_kur_treat_date, first_kur_treat_date_time, last_kur_treat_date, last_kur_treat_date_time)
),inserts as (
  select t.facility_cd, t.ord_no, t.pat_id, t2.treat_date, t2.kur_cd, t.ind_bed_cd
  from ind_schedule_info t,
  (
   select null as treat_date, null AS date_time , 0 as kur_cd
   union all
   select
     CASE
       WHEN dates IS NULL THEN NULL
       ELSE to_char(dates, 'YYYYMMDD')
       END AS treat_date,
     CASE
       WHEN dates IS NULL THEN NULL
       ELSE to_char(dates, 'YYYYMMDD') || mk.kur_standard_start_time
       END AS date_time,
     mk.kur_cd
   from
     ( select distinct * from (
                                  select
                                      /*%for isl2 : indScheduleInfoList2 */
                                      generate_series(/*isl2.firstKurTreatDate*/null, /*isl2.lastKurTreatDate*/null,
                                                                                interval '1 day') as dates
                                  /*%if isl2_has_next */
                                  /*# "union all" */
                                  /*# " select " */
                                  /*%end*/
                                  /*%end*/
                              ) tbl_tmp
    ) AS dates cross join mst_kur mk
   where  mk.facility_cd = /*facilityCd*/null and mk.is_del <> '1'
  ) t2
  where t2.date_time > t.first_kur_treat_date_time and t2.date_time <= t.last_kur_treat_date_time
)
insert into ord_schedule
(
  facility_cd,
  ord_no,
  pat_id,
  treat_date,
  kur_cd,
  bed_cd,
  is_dummy,
  up_date,
  reg_date,
  treat_week
)
select
  facility_cd,
  ord_no,
  pat_id,
  treat_date,
  kur_cd,
  ind_bed_cd,
  '1' AS is_dummy,
  transaction_timestamp() as up_date,
  transaction_timestamp() as reg_date,
  EXTRACT(ISODOW FROM to_date(treat_date, 'yyyyMMdd')) as treat_week
from inserts
