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
  case
	when A.rst_kur_name IS NULL THEN ''
    else A.rst_kur_name
  end as rst_kur_name,
  A.rst_bed_cd,
  A.rst_bed_name,
  case
	when A.rst_bed_name IS NULL THEN ''
    else A.rst_bed_name
  end as rst_bed_name,
  A.rst_treatment_cd,
  case
	when A.rst_treatment_name IS NULL THEN ''
    else A.rst_treatment_name
  end as rst_treatment_name,
  A.rst_dialysis_state,
  case
    when A.rst_dialysis_state = '0' then to_char(to_date(A.treat_date, 'yyyyMMdd'), 'yyyy/MM/dd')
	when A.rst_start_date IS NULL THEN ''
    else to_char(A.rst_start_date, 'yyyy/MM/dd')
  end as view_treat_date
from
  ord_main A
  left outer join mst_treatment B on (A.ind_treatment_cd = B.treatment_cd)
  left outer join mst_kur C on (A.ind_kur_cd = C.kur_cd)
  left outer join mst_bed D on (A.ind_bed_cd = D.bed_cd)
where
  A.ord_no = /*ordNo*/0
and
  A.is_del = '0'
and
  A.pat_id = /*patId*/1
;
