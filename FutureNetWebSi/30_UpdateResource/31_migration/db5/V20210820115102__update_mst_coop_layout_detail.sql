delete from "mst_coop_layout_detail" where "ctl_no" = -209000004 OR "ctl_no" = -209000005;
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-209000004, 'F_hosp', 'exam_rst', 'R', '結果情報詳細', 'all', '富士通想定患者プロファイル患者プロファイル項目', 'For test', '1', '<root name="結果情報詳細">

    <item  name="結果情報.検査項目コード" len="17" col="$journal.detail.pat_exam_main.exam_result_info.item_cd" type="string"/>

    <item  name="結果情報.至急フラグ" len="1" type="string"/>

    <item  name="結果情報.検査結果" len="14" col="$journal.detail.pat_exam_main.exam_result_info.result" type="string"/>

    <item  name="結果情報.検査結果フリー" len="50" col="$journal.detail.pat_exam_main.exam_result_info.freememo" type="string"/>

    <item  name="結果情報.結果コメント１コード" len="2" col="$journal.detail.pat_exam_main.exam_result_info.com_cd1" type="string"/>

    <item  name="結果情報.結果コメント２コード" len="2" col="$journal.detail.pat_exam_main.exam_result_info.com_cd2" type="string"/>

    <item  name="結果情報.HLマーク" len="2" col="$journal.detail.pat_exam_main.exam_result_info.hl" type="string"/>

    <item  name="結果情報.正常値（上限）" len="14" type="string"/>

    <item  name="結果情報.正常値（下限）" len="14" type="string"/>

    <item  name="結果情報.異常値（上限）" len="14" type="string"/>

    <item  name="結果情報.異常値（下限）" len="14" type="string"/>

</root>

', '{}', '1', '0', 4126, '2019-12-23 07:03:12', '2019-12-23 07:03:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-209000005, 'F_hosp', 'exam_rst', 'R', '結果情報詳細_空', 'pre', '富士通想定患者プロファイル患者プロファイル項目', 'For test', '1', '<root name="結果情報詳細_空(pre)">



    <item  name="結果情報.検査項目コード" len="17" key="結果詳細" type="string" value="const:all"/>



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



</root>



', '{"key": {"結果詳細": {"all": "all"}}}', '1', '0', 4126, '2019-12-23 07:03:12', '2019-12-23 07:03:12');
