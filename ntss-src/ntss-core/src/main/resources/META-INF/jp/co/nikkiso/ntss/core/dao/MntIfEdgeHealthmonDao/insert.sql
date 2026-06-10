-- modify by chamaojia 2024-10-11 [11140] 【mnt_if_edge_healthmon】 coop_version delete --start
INSERT 
INTO mnt_if_edge_healthmon( 
    facility_cd
    , if_edge_no
    , healthmon_facility_conn
    , healthmon_server_conn
--     , coop_version
    , reg_date
    , up_date
) 
VALUES ( 
    /*mntIfEdgeHealthmon.facilityCd*/null
    , /*mntIfEdgeHealthmon.ifEdgeNo*/null
    , /*mntIfEdgeHealthmon.healthmonFacilityConn*/'{}' ::JSONB
    , /*mntIfEdgeHealthmon.healthmonServerConn*/'{}' ::JSONB
--     , /*mntIfEdgeHealthmon.coopVersion*/''
    , to_timestamp(/* mntIfEdgeHealthmon.regDate */null, 'YYYY-MM-DD HH24:MI:SS')
    , to_timestamp(/* mntIfEdgeHealthmon.upDate */null, 'YYYY-MM-DD HH24:MI:SS')
)
-- modify by chamaojia 2024-10-11 [11140] 【mnt_if_edge_healthmon】 coop_version delete --end
-- add by chamaojia 2024-10-11 [11140] adding 【 facility_cd 】 cannot be processed repeatedly --start
ON CONFLICT (facility_cd) DO UPDATE
SET up_date = EXCLUDED.up_date
-- add by chamaojia 2024-10-11 [11140] adding 【 facility_cd 】 cannot be processed repeatedly --end
;
