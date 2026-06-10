select
  A.ord_no,
  A.treat_date,
  A.ind_treatment_cd,
  case
    when A.ind_treatment_cd = 0 then '未登録'
    else B.treatment_name
  end as ind_treatment_name,
  A.ind_kur_cd,
  C.kur_name as ind_kur_name,
  case
    when A.ind_kur_cd = 0 then '未登録'
    else C.kur_name
  end as ind_kur_name,
  A.ind_bed_cd,
  case
    when A.ind_bed_cd = 0 then '未登録'
    else D.bed_name
  end as ind_bed_name,
  A.rst_kur_cd,
  A.rst_kur_name,
  A.rst_bed_cd,
  A.rst_bed_name,
  A.rst_treatment_cd,
  A.rst_treatment_name,
  A.rst_dialysis_state,
  case
    when A.rst_dialysis_state = '0' then to_char(to_date(A.treat_date, 'yyyyMMdd'), 'yyyy/MM/dd')
    else to_char(A.rst_start_date, 'yyyy/MM/dd')
  end as view_treat_date
from
  ord_main A
  left outer join mst_treatment B on (A.ind_treatment_cd = B.treatment_cd)
  left outer join mst_kur C on (A.ind_kur_cd = C.kur_cd)
  left outer join mst_bed D on (A.ind_bed_cd = D.bed_cd)
where
  A.facility_cd = /*facilityCd*/'000000'
and
  A.is_del = '0'
and
/*%if null != ordNo*/
  A.ord_no =  /*ordNo*/1
/*%else*/
  A.pat_id = /*patId*/1
and
  (
    (A.rst_dialysis_state = '0' and A.treat_date = /*treatDate*/'19700101')
  or
    (A.rst_dialysis_state > '0' and A.rst_start_date between /*dialysisDateFrom*/'1970/01/01 00:00:00' and /*dialysisDateTo*/'1970/01/01 23:59:59')
    /*%if getIndTreatFlg*/
  or
    (A.rst_dialysis_state = '0' and A.treat_date = (
      select
        min(treat_date)
      from
        ord_main
      where
        facility_cd = /*facilityCd*/'000000'
      and
        pat_id = /*patId*/1
      and
        is_del = '0'
      and
        treat_date > /*treatDate*/'19700101'
      )
    )
    /*%end*/
  )
/*%end*/
order by
 A.rst_dialysis_state desc,
 A.rst_start_date,
 A.treat_date,
 A.rst_bed_name,
 C.kur_start_time,
 D.bed_name
