select
n.class_type,
n.class_name,
m.medicine_name,
m.is_disp,
m.is_del,
m.use_end_date
from
mst_medicine m
left join mst_medicine_class n
on m.class_cd = n.class_cd
and n.facility_cd = /*facilityCd*/null
where
m.medicine_cd = /*cd*/0
and m.facility_cd = /*facilityCd*/null

