   select
	    equip.class_cd as class_cd,
	    eclass.class_name as class_name,
	    eclass.class_type as class_type,
	    equip.equipment_name as name,
	    equip.equipment_short_name as short_name,
	    equip.unit as unit,
        -- add by chamaojia 2024-06-07 [10754] 接頭文字対応  --start
        equip.use_end_date as use_end_date,
        equip.is_disp as is_disp,
        equip.is_del as is_del
        -- add by chamaojia 2024-06-07 [10754] 接頭文字対応  --end
   from
    mst_equipment equip
    left outer join mst_equipment_class eclass
    on equip.facility_cd = eclass.facility_cd
    and equip.class_cd = eclass.class_cd
   where
    equip.facility_cd = /*facility_cd*/''
   and
    equip.equipment_cd = /*cd*/0
   ;
