SELECT
    bed.bed_cd
FROM
    mst_bed bed
        INNER JOIN mst_machine mac ON bed.machine_no = mac.machine_no
        AND bed.facility_cd = mac.facility_cd
WHERE
    bed.facility_cd = /*facilityCd*/null
  AND
    mac.device_edge_no IN /*deviceEdgeNoList*/( NULL )
;
