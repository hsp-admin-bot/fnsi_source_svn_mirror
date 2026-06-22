select
  ma.machine_no,
  ma.com_format_cd,
  ma.machine_option,
  ma.tmp_center_hd,
  ma.tmp_center_ecum,
  ma.tmp_center_hdf,
  ma.tmp_center_hf,
  ma.tmp_center_hd_ho,
  ma.tmp_center_ohdf,
  ma.tmp_center_ohf,
  ma.com_type,
  mt.over_nxseries,
  ma.is_support_hd,
  ma.is_support_ecum,
  ma.is_support_hdf,
  ma.is_support_hf,
  ma.is_support_hd_ho,
  ma.is_support_ecum_ho,
  ma.is_support_afbf,
  ma.is_support_ohdf,
  ma.is_support_ohf,
  ma.is_support_i_hdf,
  ma.is_support_blood_purify
from
	mst_machine ma,
	mst_bed be,
	mst_machine_type mt
where
  	ma.facility_cd = be.facility_cd
	and
  	ma.machine_no = be.machine_no
	and
  	be.facility_cd = /*facilityCd*/'000000'
	and
  	be.bed_cd =  /*indBedCd*/'0'
    and
    mt.machine_type_cd = ma.machine_type_cd
