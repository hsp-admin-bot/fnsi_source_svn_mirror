UPDATE mst_coop_distribute AS a
SET facility_cd = /* mcd.facilityCd */null,
    coop_cd = /*mcd.coopCd*/null,
    coop_cd_index = /*mcd.coopCdIndex*/null,
-- add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    coop_version = /*mcd.coopVersion*/'',
-- add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    direction = /*mcd.direction*/null,
    coop_vender = /*mcd.coopVender*/null,
    description = /*mcd.description*/null,
    is_editable = /*mcd.isEditable*/null,
    distribute_setting = /*mcd.distributeSetting*/null,
    is_disp = /*mcd.isDisp*/null,
    is_del = /*mcd.isDel*/null,
    user_id = /*mcd.userId*/null,
    up_date = to_timestamp(/*mcd.upDate*/null, 'YYYY-MM-DD HH24:MI:SS')
WHERE a.ctl_no = /*mcd.ctlNo*/0
