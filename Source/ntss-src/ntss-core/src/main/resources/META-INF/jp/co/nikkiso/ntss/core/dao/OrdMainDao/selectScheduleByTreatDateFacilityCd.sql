WITH mss_bed AS (
  select
    mss.facility_cd, ms.*, row_number() over() as ord_index
  from
    mst_selector mss
    cross join lateral jsonb_to_recordset(mss.order_settings->'items') as ms
    (
      code bigint,
      name text
    )
  where
    master_physical_name = 'mst_bed'
    AND facility_cd = /*facilityCd*/'nkknkk'
)
select
  U.ord_no,
  U.facility_cd,
  U.pat_id,
  U.treat_date,
  U.treat_week,
  coalesce(U.kur_cd,0) as ind_kur_cd,
  coalesce(U.bed_cd,0) as ind_bed_cd,
  U.rst_dialysis_state,
  U.kur_name as ind_kur_name,
  U.bed_name as ind_bed_name,
  U.rst_start_date,
  U.rst_end_date,
  K.kur_start_time as ind_kur_start_time,
  MSB.ord_index as ind_bed_order_index
from
  -- 指定日の治療記録(スケジュール+実績)を取得
  (
  select
      A.ord_no,
      A.facility_cd,
      A.pat_id,
      A.treat_date,
      A.treat_week,
      A.ind_kur_cd as kur_cd,
      A.ind_bed_cd as bed_cd,
      A.rst_dialysis_state,
      B.kur_name,
      C.bed_name,
      A.rst_start_date,
      A.rst_end_date
  from ord_main A
  left outer join mst_kur B on (A.ind_kur_cd = B.kur_cd)
  left outer join mst_bed C on (A.ind_bed_cd = C.bed_cd)
  where
    A.facility_cd = /*facilityCd*/'000000'
  and
    A.treat_date between /*startDate*/'20190101' and /*endDate*/'20190101'
  and
    (A.ind_bed_cd  = /*bedCd*/0 or A.ind_bed_cd = 0)
  and
    A.pat_id IS NOT NULL
  and
    A.rst_dialysis_state = '0'
  and
    A.is_del = '0'
union all
  select
      A.ord_no,
      A.facility_cd,
      A.pat_id,
      A.treat_date,
      A.treat_week,
      A.rst_kur_cd as kur_cd,
      A.rst_bed_cd as bed_cd,
      A.rst_dialysis_state,
      A.rst_kur_name as kur_name,
      A.rst_bed_name as bed_name,
      A.rst_start_date,
      A.rst_end_date
  from ord_main A
  where
    A.facility_cd = /*facilityCd*/'000000'
  and
    A.treat_date between /*startDate*/'20190101' and /*endDate*/'20190101'
  and
    (A.ind_bed_cd  = /*bedCd*/0 or A.ind_bed_cd = 0)
  and
    A.pat_id IS NOT NULL
  and
    A.rst_dialysis_state = '1'
  and
    A.is_del = '0'
  ) U
  left join mst_kur K on U.kur_cd = K.kur_cd
  left join mss_bed MSB on U.bed_cd = MSB.code
order by
    treat_date desc,
    K.kur_start_time asc NULLS LAST,
    MSB.ord_index asc NULLS LAST
