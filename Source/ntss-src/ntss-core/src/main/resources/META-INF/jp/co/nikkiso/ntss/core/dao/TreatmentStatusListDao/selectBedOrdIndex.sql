select
    mss.facility_cd
    , ms.code as ind_bed_cd
    , ms.name as ind_bed_name
    , row_number() over() as ord_index
from
    mst_selector mss
cross join lateral jsonb_to_recordset(mss.order_settings->'items') as ms
(
    code bigint,
    name text
)
where
    master_physical_name = 'mst_bed'
    AND facility_cd = /*facilityCd*/''