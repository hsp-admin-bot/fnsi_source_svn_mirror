select
m.medicine_mix_cd as code,
n.class_type,
n.class_name,
m.medicine_mix_name as medicine_name,
m.is_del as is_del_mix,
m.is_disp as is_disp_mix
from
mst_medicine_mix m
left join mst_medicine_class n
on m.class_cd = n.class_cd
and n.facility_cd = /*facilityCd*/null
where
m.facility_cd = /*facilityCd*/null
