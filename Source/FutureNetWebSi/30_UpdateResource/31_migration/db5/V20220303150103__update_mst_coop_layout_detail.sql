delete from "mst_coop_layout_detail" where "ctl_no" in (-201000001,-201000003,-201000021);
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-201000001, 'F_hosp', 'ini_dial', 'R', 'ini_dial_meisai', 'pre', '富士通想定透析初回申込-申込詳細', 'For test', '1', '<root name="透析申込詳細(pre)">
    <item  name="明細.項目コード" len="8" type="string"/>
    <item  name="明細.項目属性" len="3" key="項目属性" type="string"/>
    <item  name="明細.項目名称" len="50" type="string"/>
    <item  name="明細.数量" len="11" type="string"/>
    <item  name="明細.選択単位フラグ" len="1" type="string"/>
    <item  name="明細.単位コード" len="3" type="string"/>
    <item  name="明細.単位名称" len="4" type="string"/>
    <item  name="明細.第２単位コード" len="3" type="string"/>
    <item  name="明細.第２単位名称" len="4" type="string"/>
    <item  name="明細.単位換算量" len="11" type="string"/>
</root>', '{"key": {"項目属性": {"VA2": "曜日パターン", "VA3": "曜日", "VA4": "開始日", "VA5": "終了日", "VA6": "開始時刻", "VA7": "終了時刻", "VA8": "透析時間", "VA9": "実施場所", "VAA": "加算情報", "VAB": "障害者加算", "VAC": "搬送区分", "VB1": "原疾患", "VC1": "治療方法", "VD1": "依頼事項", "VD2": "連絡先", "VDW": "DW", "XXX": "コメント", "YYY": "観察記録", "ZZZ": "クール", "_DEFAULT": "空データ"}}}', '1', '0', -1, '2019-12-13 06:16:24', CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-201000003, 'F_hosp', 'ini_dial', 'R', 'ini_dial_meisai', '障害者加算', '富士通想定透析初回申込-申込詳細', 'For test', '1', '<root name="透析申込詳細(透析困難)">
    <item  name="明細.項目コード" len="8" col="$journal.detail.pat_personal_main.dial_diff_com_info.dial_diff_cd" type="string"/>
    <item  name="明細.項目属性" len="3" type="string"/>
    <item  name="明細.項目名称" len="50" col="$journal.detail.pat_personal_main.dial_diff_com_info.dial_diff_name" type="string"/>
    <item  name="明細.数量" len="11" type="string"/>
    <item  name="明細.選択単位フラグ" len="1" type="string"/>
    <item  name="明細.単位コード" len="3" type="string"/>
    <item  name="明細.単位名称" len="4" type="string"/>
    <item  name="明細.第２単位コード" len="3" type="string"/>
    <item  name="明細.第２単位名称" len="4" type="string"/>
    <item  name="明細.単位換算量" len="11" type="string"/>
</root>', '{}', '1', '0', -1, '2019-12-13 09:31:33', CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-201000021, 'F_hosp', 'ini_dial', 'R', 'ini_dial_meisai', '加算情報', '富士通想定透析初回申込-申込詳細', 'For test', '1', '<root name="透析申込詳細(加算情報)">
    <item  name="明細.項目コード" len="8" col="$journal.detail.pat_main_2.addition_info.cd" type="string"/>
    <item  name="明細.項目属性" len="3" type="string"/>
    <item  name="明細.項目名称" len="50" col="$journal.detail.pat_main_2.addition_info.name" type="string"/>
    <item  name="明細.数量" len="11" type="string"/>
    <item  name="明細.選択単位フラグ" len="1" type="string"/>
    <item  name="明細.単位コード" len="3" type="string"/>
    <item  name="明細.単位名称" len="4" type="string"/>
    <item  name="明細.第２単位コード" len="3" type="string"/>
    <item  name="明細.第２単位名称" len="4" type="string"/>
    <item  name="明細.単位換算量" len="11" type="string"/>
</root>', '{}', '1', '0', -1, '2019-12-13 09:30:47', CURRENT_TIMESTAMP);
