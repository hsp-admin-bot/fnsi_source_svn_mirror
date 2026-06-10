UPDATE sys_master_define
SET edit_level = '1',
    up_date = CURRENT_TIMESTAMP
WHERE master_physical_name = 'mst_room_bed_group';

UPDATE sys_master_define
SET edit_level = '1',
    up_date = CURRENT_TIMESTAMP
WHERE master_physical_name = 'mst_wheel_chair';

UPDATE sys_master_define
SET edit_level = '5',
    up_date = CURRENT_TIMESTAMP
WHERE master_physical_name = 'mst_medicine_support';

UPDATE sys_master_define
SET edit_level = '1',
    up_date = CURRENT_TIMESTAMP
WHERE master_physical_name = 'mst_graph_setting';

UPDATE sys_master_define
SET edit_level = '5',
    up_date = CURRENT_TIMESTAMP
WHERE master_physical_name = 'mst_url_link_register';
