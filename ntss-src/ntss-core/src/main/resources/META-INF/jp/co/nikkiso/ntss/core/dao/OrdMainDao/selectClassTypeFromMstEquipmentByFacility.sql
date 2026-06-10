select
m.equipment_cd as code,
n.class_type,
n.class_name,
m.equipment_name,
m.is_del,
m.is_disp,
m.use_end_date
from
mst_equipment m
left join mst_equipment_class n
on m.class_cd = n.class_cd
and n.facility_cd = /*facilityCd*/null
where
m.facility_cd = /*facilityCd*/null

