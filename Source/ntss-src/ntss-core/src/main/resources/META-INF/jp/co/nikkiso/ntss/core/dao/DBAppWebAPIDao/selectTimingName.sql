--- 投与タイミング
    select
    medt.medicate_timing_name as timing_name
 from
     mst_medicate_timing medt
 where
     medt.facility_cd = /*facility_cd*/''
     and
     medt.medicate_timing_cd = /*timing_cd*/0

    