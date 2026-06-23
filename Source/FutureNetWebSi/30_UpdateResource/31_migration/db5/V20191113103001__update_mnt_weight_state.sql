--体重計状態テーブルの更新
insert into mnt_weight_state (weight_cd, is_connect, card_read_value, write_result, reg_date, up_date)
select MST.weight_cd, '0','{"id":"","idm":""}', '0', now(), now()
from mst_weight MST
     left outer join mnt_weight_state MNT
   on MST.weight_cd = MNT.weight_cd
where MNT.weight_cd is null
;