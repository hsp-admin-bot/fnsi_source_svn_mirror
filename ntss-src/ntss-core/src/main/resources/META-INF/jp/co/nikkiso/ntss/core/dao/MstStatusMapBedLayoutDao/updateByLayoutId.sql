UPDATE
	mst_status_map_bed_layout
SET
	bed_layout = /*conditions.get("bedLayoutBedLayout")*/null
WHERE layout_id = /*conditions.get("bedLayoutLayoutId")*/0;
