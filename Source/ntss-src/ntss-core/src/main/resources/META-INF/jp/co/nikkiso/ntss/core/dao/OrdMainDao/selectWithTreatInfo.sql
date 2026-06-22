select
  OM.ord_no,
  OM.facility_cd,
  MB.machine_no,
  MC.machine_name,
  OM.ind_bed_cd,
  OM.ind_bed_name,
  OM.ind_kur_cd,
  OM.ind_kur_name,
  OM.rst_bed_cd,
  OM.rst_bed_name,
  OM.rst_kur_cd,
  OM.rst_kur_name,
  OM.pat_id,
  OM.ind_tare_info,
  OM.ind_off_water_info
from
  ord_main OM
  left outer join mst_bed MB on MB.bed_cd = OM.ind_bed_cd and MB.facility_cd = OM.facility_cd
  left outer join mst_machine MC on MB.machine_no = MC.machine_no and MC.facility_cd = OM.facility_cd
where
  OM.ord_no = /*ordNo*/null