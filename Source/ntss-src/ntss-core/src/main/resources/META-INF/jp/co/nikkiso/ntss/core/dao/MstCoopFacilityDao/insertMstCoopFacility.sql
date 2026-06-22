INSERT INTO mst_coop_facility(
facility_cd,
description,
is_disp,
is_del,
if_edge_setting,
common_setting,
user_id,
reg_date,
up_date)
VALUES(
/*mcf.facilityCd*/null,
/*mcf.description*/null,
/*mcf.isDisp*/'1',
/*mcf.isDel*/'0',
/*mcf.ifEdgeSetting*/null,
/*mcf.commonSetting*/null,
/*mcf.userId*/0,
to_timestamp(/*mcf.regDate*/null, 'YYYY-MM-DD HH24:MI:SS'),
to_timestamp(/*mcf.upDate*/null, 'YYYY-MM-DD HH24:MI:SS'))