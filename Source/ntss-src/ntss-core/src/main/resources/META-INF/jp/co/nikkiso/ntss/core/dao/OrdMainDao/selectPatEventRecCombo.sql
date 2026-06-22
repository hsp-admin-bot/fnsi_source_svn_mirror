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
  A.pat_id = /*patId*/1
and
/*%if 1 == mode*/
    ((A.treat_date <= to_char(to_date(/*dialysisDateTo*/'1970/01/01 23:59:59', 'yyyy/mm/dd hh24:mi:ss'), 'yyyyMMdd')
    and
      A.treat_date >= to_char(to_date(/*dialysisDateFrom*/'1970/01/01 00:00:00', 'yyyy/mm/dd hh24:mi:ss'), 'yyyyMMdd')
      and
     A.rst_dialysis_state = '0')
     or (A.treat_date <= to_char(to_date(/*dialysisDateTo*/'1970/01/01 23:59:59', 'yyyy/mm/dd hh24:mi:ss'), 'yyyyMMdd')
    and
      to_char(now(),'yyyyMMdd') >= to_char(to_date(/*dialysisDateFrom*/'1970/01/01 00:00:00', 'yyyy/mm/dd hh24:mi:ss'), 'yyyyMMdd')
      and
     A.rst_dialysis_state in ('1','2')))
/*%end*/
/*%if 2 == mode*/
    ((A.treat_date <= to_char(to_date(/*dialysisDateTo*/'1970/01/01 23:59:59', 'yyyy/mm/dd hh24:mi:ss'), 'yyyyMMdd')
    or
     COALESCE(to_char(A.rst_start_date,'yyyyMMdd'),A.treat_date) <= to_char(to_date(/*dialysisDateTo*/'1970/01/01 23:59:59', 'yyyy/mm/dd hh24:mi:ss'), 'yyyyMMdd'))
     and
     (A.treat_date >= to_char(to_date(/*dialysisDateFrom*/'1970/01/01 00:00:00', 'yyyy/mm/dd hh24:mi:ss'), 'yyyyMMdd')
    or
     COALESCE(to_char(A.rst_end_date,'yyyyMMdd'),A.treat_date) >= to_char(to_date(/*dialysisDateFrom*/'1970/01/01 23:59:59', 'yyyy/mm/dd hh24:mi:ss'), 'yyyyMMdd'))
    and
    (A.rst_dialysis_state = '4' or A.rst_dialysis_state = '5' or A.rst_dialysis_state = '6'))
/*%end*/
/*%if 3 == mode*/
    A.rst_dialysis_state = '3'
	and
-- 	mod 9208 患者イベントの実績リンクでの選択肢が不正 関 start
-- 	((A.treat_date <= to_char(now(),'yyyyMMdd') and
-- 	A.treat_date <= to_char(to_date(/*dialysisDateFrom*/'1970/01/01 00:00:00', 'yyyy/mm/dd hh24:mi:ss'), 'yyyyMMdd'))
--     or
-- 	(to_char(A.rst_start_date,'yyyyMMdd') <= to_char(now(),'yyyyMMdd') and
-- 	to_char(A.rst_start_date,'yyyyMMdd') <= to_char(to_date(/*dialysisDateFrom*/'1970/01/01 00:00:00', 'yyyy/mm/dd hh24:mi:ss'), 'yyyyMMdd')))
    (A.treat_date <= to_char(to_date(/*dialysisDateTo*/'1970/01/01 23:59:59', 'yyyy/mm/dd hh24:mi:ss'), 'yyyyMMdd')
    or COALESCE(to_char(A.rst_start_date,'yyyyMMdd'),A.treat_date) <= to_char(to_date(/*dialysisDateTo*/'1970/01/01 23:59:59', 'yyyy/mm/dd hh24:mi:ss'), 'yyyyMMdd'))
--     mod 9208 患者イベントの実績リンクでの選択肢が不正 関 end
    and
	to_char(to_date(/*dialysisDateFrom*/'1970/01/01 00:00:00', 'yyyy/mm/dd hh24:mi:ss'), 'yyyyMMdd') <= to_char(now(),'yyyyMMdd')
/*%end*/
order by
 A.rst_dialysis_state desc,
 A.rst_start_date,
 A.treat_date,
 A.rst_bed_name,
 C.kur_start_time,
 D.bed_name
