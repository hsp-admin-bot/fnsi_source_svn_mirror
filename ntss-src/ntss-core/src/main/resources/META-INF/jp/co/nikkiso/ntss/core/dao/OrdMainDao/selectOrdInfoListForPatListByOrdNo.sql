with mss_bed as ( 
    select
        ms.*
        , row_number() over () as ord_index 
    from
        mst_selector mss 
        cross join lateral jsonb_to_recordset(mss.order_settings -> 'items') as ms(code bigint, name text) 
    where
        master_physical_name = 'mst_bed' 
        and facility_cd = /*facilityCd*/''
)
, kur as ( 
    select
        kur_cd
        , kur_start_time
    from
        mst_kur
    where
        facility_cd = /*facilityCd*/''
)
select
  A.ord_no
  , A.treat_date
  , A.rst_dialysis_state
  , A.rst_start_date
  , A.rst_end_date
  , A.rst_cond_info :: json #>> '{1}' as treat_time
  , A.rst_rounds_info
  , B.highlighting AS round_highlighting
  , C.kur_start_time as ind_kur_start_time
  , D.kur_start_time as rst_kur_start_time
  , E.ord_index as ind_bed_order_index
  , F.ord_index as rst_bed_order_index
from
  ord_main A
left outer join mst_round_type B
  on B.round_type_cd = ( A.rst_rounds_info :: json #>> '{round_type_cd}' ) :: INT
left outer join kur C on (A.ind_kur_cd = C.kur_cd)
left outer join kur D on (A.rst_kur_cd = D.kur_cd)
left outer join mss_bed E on (A.ind_bed_cd = E.code)
left outer join mss_bed F on (A.rst_bed_cd = F.code)
where
  A.ord_no in /* ordNoList */(1)
;
