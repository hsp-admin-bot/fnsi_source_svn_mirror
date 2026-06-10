delete from
    pat_group_detail
where
    facility_cd = /*facilityCd*/null
and
    pat_id in /*patList*/(null)
and
    pat_group_cd in /*groupIdList*/(null)
;
