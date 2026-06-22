INSERT INTO mst_coop_layout_detail(
facility_cd,
coop_cd,
-- add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
coop_version,
-- add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
direction,
coop_cd_detail,
coop_cd_detail_sub,
coop_name,
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
/* mcld.facilityCd */null,
/* mcld.coopCd*/null,
-- add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
/* mcld.coopVersion*/'',
-- add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
/* mcld.direction */null,
/* mcld.coopCdDetail */null,
/* mcld.coopCdDetailSub */null,
/* mcld.coopName */null,
/* mcld.description */null,
/* mcld.isEditable */null,
/* mcld.coopSetting */null,
/* mcld.coopExtSetting */null,
/* mcld.isDisp */'1',
/* mcld.isDel */'0',
/* mcld.userId */null,
to_timestamp(/*mcld.regDate*/null, 'YYYY-MM-DD HH24:MI:SS'),
to_timestamp(/*mcld.upDate*/null, 'YYYY-MM-DD HH24:MI:SS'))
