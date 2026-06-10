UPDATE mst_coop_layout AS a
SET facility_cd = /*mcl.facilityCd*/null,
    coop_cd = /*mcl.coopCd*/null,
-- add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    coop_cd_index = /*mcl.coopCdIndex*/'',
    coop_version = /*mcl.coopVersion*/'',
-- add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    direction =/*mcl.direction*/null,
    coop_cd_sub = /*mcl.coopCdSub*/null,
    coop_format = /*mcl.coopFormat*/null,
    coop_name = /*mcl.coopName*/null,
    coop_vender = /*mcl.coopVender*/null,
    description = /*mcl.description*/null,
    is_editable = /*mcl.isEditable*/null,
    coop_setting = /*mcl.coopSetting*/null,
    coop_ext_setting = /*mcl.coopExtSetting*/null,
    is_del = /*mcl.isDel*/null,
    user_id = /*mcl.userId*/null,
    up_date = to_timestamp(/*mcl.upDate*/null, 'YYYY-MM-DD HH24:MI:SS')
    WHERE a.ctl_no = /*mcl.ctlNo*/0
