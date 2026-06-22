INSERT INTO mst_coop_layout(
facility_cd,
coop_cd,
coop_cd_index,
-- add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
coop_version,
-- add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
direction,
coop_cd_sub,
coop_format,
coop_name,
coop_vender,
description,
is_editable,
coop_setting,
coop_ext_setting,
is_disp,
is_del,
user_id,
reg_date,
up_date)
VALUES(
/* mcl.facilityCd */null,
/* mcl.coopCd*/null,
/* mcl.coopCdIndex*/null,
-- add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
/* mcl.coopVersion*/'',
-- add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
/* mcl.direction */null,
/* mcl.coopCdSub */null,
/* mcl.coopFormat */null,
/* mcl.coopName */null,
/* mcl.coopVender */null,
/* mcl.description */null,
/* mcl.isEditable */null,
/* mcl.coopSetting */null,
/* mcl.coopExtSetting */null,
/* mcl.isDisp */'1',
/* mcl.isDel */'0',
/* mcl.userId */null,
to_timestamp(/*mcl.regDate*/null, 'YYYY-MM-DD HH24:MI:SS'),
to_timestamp(/*mcl.upDate*/null, 'YYYY-MM-DD HH24:MI:SS'))
