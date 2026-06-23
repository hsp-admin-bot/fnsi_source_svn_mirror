delete from "mst_coop_layout_detail" where "ctl_no" in (-409000001);
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-409000001, 'P_hosp', 'exam_rst', 'R', '検査結果', 'all', 'Medicom', '検査結果受信', '1', '<root name="検査結果項目">
    <item  name="項目コード" len="17" col="$journal.detail.pat_exam_main.exam_result_info.item_cd" type="string"/>
    <item  name="検査結果値" len="8" col="$journal.detail.pat_exam_main.exam_result_info.result" type="string"/>
    <item  name="検査値形態" len="1" col="$journal.detail.pat_exam_main.exam_result_info.hl" type="string"/>
    <item  name="結果コメント１" len="3" col="$journal.detail.pat_exam_main.exam_result_info.com_cd1" type="string"/>
    <item  name="結果コメント２" len="3" col="$journal.detail.pat_exam_main.exam_result_info.com_cd2" type="string"/>
</root>', '{}', '1', '0', 4, '2020-05-26 10:52:13.579', '2020-05-26 10:52:16.343');
