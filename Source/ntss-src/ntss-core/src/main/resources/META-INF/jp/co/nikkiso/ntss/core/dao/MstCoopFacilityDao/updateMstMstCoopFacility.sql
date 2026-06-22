UPDATE mst_coop_facility AS a
SET facility_cd = /* mcf.facilityCd */null,
    description = /*mcf.description*/null,
    is_disp = /*mcf.isDisp*/null,
    is_del = /*mcf.isDel*/null,
    if_edge_setting = /*mcf.ifEdgeSetting*/null,
    common_setting = /*mcf.commonSetting*/null,
    user_id = /*mcf.userId*/null,
    up_date = to_timestamp(/*mcf.upDate*/null, 'YYYY-MM-DD HH24:MI:SS')
WHERE a.ctl_no = /*mcf.ctlNo*/0