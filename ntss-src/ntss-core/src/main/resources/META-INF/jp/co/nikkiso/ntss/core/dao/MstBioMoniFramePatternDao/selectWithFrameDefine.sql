select 
  fp.facility_cd,
  fp.ctl_no,
  fp.template_name,
  fp.frame_type,
  fp.frame_no,
  fp.define_info,
  fd.frame_define,
  fp.reg_date,
  fp.up_date
from
  mst_bio_moni_frame_pattern fp
  left outer join mst_frame_define fd 
  on fp.frame_type = fd.frame_type and fp.frame_no = fd.frame_no
where
  facility_cd = /*facility_cd*/'999000' 
/*%if ctl_no >= 0 */
  and 
  ctl_no = /*ctl_no*/1
/*%end*/
order by
  ctl_no
 ;
