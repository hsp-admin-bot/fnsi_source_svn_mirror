insert into mnt_weight_state (weight_cd, is_connect, card_read_value, write_result, reg_date, up_date, facility_cd)
select MST.weight_cd, '0','{"id":"","idm":""}', '0', now(), now(), /*facilityCd*/null
from mst_weight MST
     left outer join mnt_weight_state MNT
   on MST.weight_cd = MNT.weight_cd
where
     MST.facility_cd = /*facilityCd*/'999900'
     and MNT.weight_cd is null
;