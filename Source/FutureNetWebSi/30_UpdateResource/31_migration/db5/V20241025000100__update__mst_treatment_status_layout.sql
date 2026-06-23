with updated_dcs as (
    select
        layout_no,
        jsonb_agg(
                case when (item->>'data_class')::int <= -10000 
	        then jsonb_set(item, '{table_name}', '"mni_monitor"'::jsonb)
			else item end
            ) as new_dcs
    from
        mst_treatment_status_layout,
        jsonb_array_elements(dcs_view_items) with ordinality as items(item,idx)
    group by layout_no
)
update
    mst_treatment_status_layout
set
    dcs_view_items = u.new_dcs
    from
	updated_dcs u
where
    mst_treatment_status_layout.layout_no = u.layout_no;