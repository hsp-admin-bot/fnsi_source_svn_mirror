--- 手技
    select
    proc.pricedure_name
 from
     mst_procedure proc
 where
     proc.facility_cd = /*facility_cd*/''
     and
     proc.procedure_cd = /*procedure_cd*/0

