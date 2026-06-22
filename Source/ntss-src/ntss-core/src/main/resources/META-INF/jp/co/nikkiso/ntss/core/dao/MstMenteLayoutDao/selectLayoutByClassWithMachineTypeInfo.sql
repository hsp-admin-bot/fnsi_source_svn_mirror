SELECT
		lt.mainte_layout_cd,
		lt.layout_class,
		lt.layout_name,
		(
		SELECT json_agg(json_build_object(
			'machineTypeCd',m.machine_type_cd,
			'machineType',m.machine_type
		)) from
			-- modify by zhaohan 2022-10-31 [7090] システムを停止しないDBバージョンアップができない。 --start
			-- (SELECT * FROM mst_machine_type where machine_type_cd::text
			(SELECT machine_type_cd, machine_type FROM mst_machine_type where machine_type_cd::text
			-- modify by zhaohan 2022-10-31 [7090] システムを停止しないDBバージョンアップができない。 --end
			 in
			 	(SELECT json_array_elements_text(
				(SELECT to_json(lt.type_info)))::text)) as m) as type_info,

		lt.detail_info_1,
		lt.detail_info_2,
		lt.mainte_layout_cd,
		lt.is_disp,
		lt.is_del,
		lt.up_date,
		lt.reg_date
FROM mst_mainte_layout as lt
WHERE lt.layout_class = /* layoutClass*/'0'
  AND facility_cd = /* facilityCd*/'000000'
	AND is_disp = '1'
	AND is_del = '0'
