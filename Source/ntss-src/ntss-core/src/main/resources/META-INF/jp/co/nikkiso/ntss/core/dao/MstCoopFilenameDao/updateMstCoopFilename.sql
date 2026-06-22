UPDATE mst_coop_filename AS a
SET facility_cd = /*mcfn.facilityCd*/null,
    coop_cd = /*mcfn.coopCd*/null,
    coop_cd_index = /*mcfn.coopCdIndex*/null,
    coop_version = /*mcfn.coopVersion*/'',
    pdf_name =/*mcfn.pdfName*/null,
    dump_name = /*mcfn.dumpName*/null,
    compression_name = /*mcfn.compressionName*/null,
    is_disp = /*mcfn.isDisp*/null,
    is_del = /*mcfn.isDel*/null,
    user_id = /*mcfn.userId*/null,
    up_date = to_timestamp(/*mcfn.upDate*/null, 'YYYY-MM-DD HH24:MI:SS')
    WHERE a.ctl_no = /*mcfn.ctlNo*/0
