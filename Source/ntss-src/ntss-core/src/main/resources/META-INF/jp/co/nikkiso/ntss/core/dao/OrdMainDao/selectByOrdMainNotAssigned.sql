select
  A.ord_no,
  A.facility_cd,
  A.pat_id,
  A.treat_date,
  A.treat_week,
  A.ind_kur_cd,
  B.kur_name as ind_kur_name,
  A.ind_treatment_cd,
  C.treatment_name as ind_treatment_name
from
  ord_main as A

  left outer join
    mst_kur B
  on (A.ind_kur_cd = B.kur_cd)

  left outer join
    mst_treatment C
  on (
      A.ind_treatment_cd = C.treatment_cd
    and
      A.facility_cd = C.facility_cd
  )
where
    A.facility_cd = /*facilityCd*/'000000'
  and
    A.treat_date = /*treatDate*/'00000101'
  and
    (
        A.ind_bed_cd is null
      or
        A.ind_bed_cd = 0
      or
        (
            A.ind_bed_cd = /*bedCd*/0
          and
            (
                A.ind_kur_cd is null
              or
                A.ind_kur_cd = 0
            )
        )
    )
  and
    (
        A.rst_dialysis_state is null
      or
        A.rst_dialysis_state = '0'
      or
        A.rst_dialysis_state = ''
    )
  and
    A.pat_id IS NOT NULL
order by
  A.treat_date,
  A.ind_kur_cd