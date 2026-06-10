--del mst_spitz, mst_exam_set is_in_hospital
UPDATE sys_master_define AS t
SET column_info = (
    SELECT jsonb_build_object('fields', jsonb_agg(fields))
    FROM (
        SELECT fields
        FROM sys_master_define AS s, jsonb_array_elements(s.column_info -> 'fields') AS fields
        WHERE s.master_physical_name = t.master_physical_name
        AND (fields ->> 'physical_name' IS DISTINCT FROM 'is_in_hospital')
    ) AS filtered_data
)
WHERE master_physical_name IN ('mst_spitz', 'mst_exam_set');

--add mst_exam_item is_in_hospital
UPDATE sys_master_define 
SET column_info = jsonb_set ( column_info, '{fields}', column_info -> 'fields' || '[{
	"type": "combo1",
	"title": "院内院外フラグ",
	"hidden": "true",
	"physical_name": "is_in_hospital"
   }]' :: JSONB ) 
WHERE master_physical_name = 'mst_exam_item';