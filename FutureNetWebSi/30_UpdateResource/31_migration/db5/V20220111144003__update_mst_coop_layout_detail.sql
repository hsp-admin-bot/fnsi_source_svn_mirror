delete from "mst_coop_layout_detail" where "ctl_no" in (-209000001,-209000002,-209000003,-209000004,-209000005,-209000006);
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-209000001, 'F_hosp', 'exam_rst', 'R', '検体情報詳細', 'all', '富士通想定患者プロファイル患者プロファイル項目', 'For test', '1', '<root name="検体情報詳細">
    <item  name="検体情報.採取コード" len="3" type="string"/>
    <item  name="検体情報.材料コード" len="3" type="string"/>
    <item  name="検体情報.尿量" len="3" type="string"/>
    <item  name="検体情報.経過時間" len="4" type="string"/>
    <item  name="検体情報.検体コメントコード１" len="3" type="string"/>
    <item  name="検体情報.検体コメントコード２" len="3" type="string"/>
    <item  name="検体情報.受付状態フラグ" len="1" type="string"/>
</root>', '{}', '1', '0', 4126, '2019-12-23 07:03:12', '2019-12-23 07:03:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-209000002, 'F_hosp', 'exam_rst', 'R', '結果情報詳細', 'all', '富士通想定患者プロファイル患者プロファイル項目', 'For test', '1', '<root name="結果情報詳細">
    <item  name="結果情報.検査項目コード" len="17" col="$journal.detail.pat_exam_main.exam_result_info.item_cd" type="string"/>
    <item  name="結果情報.至急フラグ" len="1" type="string"/>
    <item  name="結果情報.検査結果" len="14" col="$journal.detail.pat_exam_main.exam_result_info.result" type="string"/>
    <item  name="結果情報.検査結果フリー" len="50" col="$journal.detail.pat_exam_main.exam_result_info.freememo" type="string"/>
    <item  name="結果情報.結果コメント１コード" len="2" col="$journal.detail.pat_exam_main.exam_result_info.result_comment1_code" type="string"/>
    <item  name="結果情報.結果コメント２コード" len="2" col="$journal.detail.pat_exam_main.exam_result_info.result_comment2_code" type="string"/>
    <item  name="結果情報.HLマーク" len="2" col="$journal.detail.pat_exam_main.exam_result_info.hl" type="string"/>
    <item  name="結果情報.正常値（上限）" len="14" type="string"/>
    <item  name="結果情報.正常値（下限）" len="14" type="string"/>
    <item  name="結果情報.異常値（上限）" len="14" type="string"/>
    <item  name="結果情報.異常値（下限）" len="14" type="string"/>
</root>', '{}', '1', '0', 4126, '2019-12-23 07:03:12', '2019-12-23 07:03:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-209000003, 'F_hosp', 'exam_rst', 'R', '結果情報詳細_空', 'all', '富士通想定患者プロファイル患者プロファイル項目', 'For test', '1', '<root name="結果情報詳細_空">
    <item  name="結果情報.検査項目コード" len="17" type="string"/>
    <item  name="結果情報.至急フラグ" len="1" type="string"/>
    <item  name="結果情報.検査結果" len="14" type="string"/>
    <item  name="結果情報.検査結果フリー" len="50" type="string"/>
    <item  name="結果情報.結果コメント１コード" len="2" type="string"/>
    <item  name="結果情報.結果コメント２コード" len="2" type="string"/>
    <item  name="結果情報.HLマーク" len="2" type="string"/>
    <item  name="結果情報.正常値（上限）" len="14" type="string"/>
    <item  name="結果情報.正常値（下限）" len="14" type="string"/>
    <item  name="結果情報.異常値（上限）" len="14" type="string"/>
    <item  name="結果情報.異常値（下限）" len="14" type="string"/>
</root>', '{}', '1', '0', 4126, '2019-12-23 07:03:12', '2019-12-23 07:03:12');
