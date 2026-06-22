UPDATE mst_coop_layout_detail AS a
SET facility_cd = /*mcld.facilityCd*/null,
    coop_cd = /*mcld.coopCd*/null,
-- add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    coop_version = /*mcld.coopVersion*/'',
-- add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    direction =/*mcld.direction*/null,
    coop_cd_detail = /*mcld.coopCdDetail*/null,
    coop_cd_detail_sub = /*mcld.coopCdDetailSub*/null,
    coop_name = /*mcld.coopName*/null,
    description = /*mcld.description*/null,
    is_editable = /*mcld.isEditable*/null,
    coop_setting = /*mcld.coopSetting*/null,
    coop_ext_setting = /*mcld.coopExtSetting*/null,
    is_disp = /*mcld.isDisp*/null,
    is_del = /*mcld.isDel*/null,
    user_id = /*mcld.userId*/null,
    up_date = to_timestamp(/*mcld.upDate*/null, 'YYYY-MM-DD HH24:MI:SS')
    WHERE a.ctl_no = /*mcld.ctlNo*/0
