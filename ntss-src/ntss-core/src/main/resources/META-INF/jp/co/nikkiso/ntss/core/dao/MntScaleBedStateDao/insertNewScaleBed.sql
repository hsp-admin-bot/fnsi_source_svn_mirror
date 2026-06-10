insert into mnt_scale_bed_state (bed_cd, weight_cd ,  facility_cd ,is_connect, before_send_status, after_send_status, before_weight_scale_no, after_weight_scale_no,md_cd,reg_date, up_date)
select MST.bed_cd, weight_cd, /*facilityCd*/null ,'0',0,0,0, 0, now(), now()
from mst_bed MST
     left outer join mnt_scale_bed_state MNT
   on MST.bed_cd = MNT.bed_cd
where
     MST.facility_cd = /*facilityCd*/'999900'
     and MNT.bed_cd is null
;
