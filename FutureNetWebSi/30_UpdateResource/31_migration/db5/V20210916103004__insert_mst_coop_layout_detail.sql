delete from "mst_coop_layout_detail" where "ctl_no" = -606000001;
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-606000001, 'C_hosp', 'exam_rst', 'R', '検体検査結果', 'all', 'CSI', '検査結果（XML)', '1', '<RST_EXAMIN_HST_DETAIL ID="">

    <DISP_PATID></DISP_PATID>

    <REG_EXAM_DATE>col:$journal.detail.pat_exam_main.exam_result_info.result_date</REG_EXAM_DATE>

    <REG_ORDER_CLASS>col:$journal.detail.pat_exam_main.exam_result_info.reg_order_class</REG_ORDER_CLASS>

    <IN_HOSPITAL_CD>col:$journal.detail.pat_exam_main.exam_result_info.item_cd</IN_HOSPITAL_CD>

    <EXAM_RST>col:$journal.detail.pat_exam_main.exam_result_info.result</EXAM_RST>

    <COMMENTS>col:$journal.detail.pat_exam_main.exam_result_info.freememo</COMMENTS>

</RST_EXAMIN_HST_DETAIL>', '{}', '1', '0', 4126, '2019-12-23 07:03:12', '2019-12-23 07:03:12');
