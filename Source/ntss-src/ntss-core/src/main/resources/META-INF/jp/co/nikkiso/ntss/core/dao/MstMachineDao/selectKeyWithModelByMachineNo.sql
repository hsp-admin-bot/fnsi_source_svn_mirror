select
  MM.facility_cd,
  MM.machine_type_cd,
  MM.machine_serial,
  MMT.model
from
  mst_machine MM
  left outer join mst_machine_type MMT
    on MM.machine_type_cd = MMT.machine_type_cd
where
  MM.facility_cd = /*facilityCd*/'000000'
  and
  MM.machine_no = /*machineNo*/0
	/*%if null != isDisp */
	and
	  MM.is_disp=/*isDisp*/null
	/*%end*/
	/*%if null != isDel */
	and
	  MM.is_del=/*isDel*/null
	/*%end*/
;