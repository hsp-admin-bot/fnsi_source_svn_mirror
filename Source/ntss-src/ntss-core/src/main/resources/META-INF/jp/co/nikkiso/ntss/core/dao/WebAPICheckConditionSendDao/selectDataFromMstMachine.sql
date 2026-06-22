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
  --add FNSI-分類不一致判断の追加 徐 start
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
  --add FNSI-分類不一致判断の追加 徐 end
from
	mst_machine ma,
	mst_bed be,
	ord_main ord,
	--add FNSI-分類不一致判断の追加 徐 start
	mst_machine_type mt
	--add FNSI-分類不一致判断の追加 徐 end
where
  	ma.facility_cd = be.facility_cd
	and
  	ma.machine_no = be.machine_no
	and
  	be.facility_cd = ord.facility_cd
	and
  	be.bed_cd = ord.ind_bed_cd
	and
    ord.ord_no = /*ordNo*/1
    and
    --add FNSI-分類不一致判断の追加 徐 start
    mt.machine_type_cd = ma.machine_type_cd
    --add FNSI-分類不一致判断の追加 徐 end
