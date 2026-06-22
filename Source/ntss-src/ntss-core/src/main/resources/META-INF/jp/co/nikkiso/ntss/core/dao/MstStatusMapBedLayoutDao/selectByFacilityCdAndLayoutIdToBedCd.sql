SELECT
    mst_bed_layout -> 'bed_cd' as bed_cd
FROM
    mst_status_map_bed_layout m
        CROSS JOIN LATERAL json_array_elements((m.bed_layout #>> '{obj_list}')::json) mst_bed_layout
WHERE
	m.facility_cd = /*facilityCd*/''
    AND m.layout_id = /*layoutId*/0
	AND m.is_disp = '1'
	AND m.is_del = '0';
