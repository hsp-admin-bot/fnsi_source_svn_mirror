select distinct
    case
        when from_pat_id = /*patId*/0 then to_facility_cd
        when to_pat_id   = /*patId*/0 then from_facility_cd
    end as facility_cd
from
    shr_pat_info
where
    (
        from_pat_id = /*patId*/0
        or to_pat_id = /*patId*/0
    )
    and is_del  = '0'
    and is_disp = '1'
