SELECT
    mst_smbl.layout_id
  , mst_smbl.facility_cd
  , mst_smbl.layout_name
  , mst_smbl.bed_layout
FROM
	mst_status_map_bed_layout mst_smbl
	CROSS JOIN LATERAL json_array_elements((mst_smbl.bed_layout #>> '{obj_list}')::json) mst_bed_layout
WHERE
	CAST(mst_bed_layout ->> 'bed_cd' AS char(8)) = /*bedCd*/'00000000'
	AND is_disp = '1'
	AND is_del = '0';
