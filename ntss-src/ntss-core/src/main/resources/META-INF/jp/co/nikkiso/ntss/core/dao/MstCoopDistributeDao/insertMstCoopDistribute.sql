INSERT INTO mst_coop_distribute(
facility_cd,
coop_cd,
coop_cd_index,
-- add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
coop_version,
-- add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
direction,
coop_vender,
description,
is_editable,
distribute_setting,
is_disp,
is_del,
user_id,
reg_date,
up_date)
VALUES(
/*mcd.facilityCd*/null,
/*mcd.coopCd*/null,
/*mcd.coopCdIndex*/null,
-- add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
/*mcd.coopVersion*/'',
-- add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
/*mcd.direction*/null,
/*mcd.coopVender*/null,
/*mcd.description*/null,
/*mcd.isEditable*/null,
/*mcd.distributeSetting*/null,
/*mcd.isDisp*/'1',
/*mcd.isDel*/'0',
/*mcd.userId*/null,
to_timestamp(/*mcd.regDate*/null, 'YYYY-MM-DD HH24:MI:SS'),
to_timestamp(/*mcd.upDate*/null, 'YYYY-MM-DD HH24:MI:SS'))
