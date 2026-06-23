delete from "mst_coop_layout_detail" where "ctl_no"  <= -201000001 and "ctl_no"  >= -201000008;INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-201000001, 'F_hosp', 'ini_dial', 'R', 'ini_dial_meisai', 'pre', '富士通想定透析初回申込-申込詳細', 'For test', '1', '<root name="透析申込詳細(pre)">
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
</root>', '{"key": {"項目属性": {"VA2": "空データ", "VA3": "空データ", "VA4": "空データ", "VA5": "空データ", "VA6": "空データ", "VA7": "空データ", "VA8": "空データ", "VA9": "空データ", "VAB": "障害者加算", "VAC": "空データ", "VB1": "原疾患", "VC1": "治療方法", "VD1": "空データ", "VD2": "空データ", "VDW": "空データ", "VF3": "明細", "XXX": "コメント", "YYY": "観察記録"}}}', '1', '0', -1, '2019-12-13 06:16:24', '2019-12-13 06:16:24');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-201000002, 'F_hosp', 'ini_dial', 'R', 'ini_dial_meisai', '原疾患', '富士通想定透析初回申込-申込詳細', 'For test', '1', '<root name="透析申込詳細(原疾患)">
    <item  name="明細.項目コード" len="8" col="$journal.pat_unique.medical_hst_info.disease_cd" type="string"/>
    <item  name="明細.項目属性" len="3" type="string"/>
    <item  name="明細.項目名称" len="50" type="string"/>
    <item  name="明細.数量" len="11" type="string"/>
    <item  name="明細.選択単位フラグ" len="1" type="string"/>
    <item  name="明細.単位コード" len="3" type="string"/>
    <item  name="明細.単位名称" len="4" type="string"/>
    <item  name="明細.第２単位コード" len="3" type="string"/>
    <item  name="明細.第２単位名称" len="4" type="string"/>
    <item  name="明細.単位換算量" len="11" type="string"/>
</root>', '{}', '1', '0', -1, '2019-12-13 09:30:47', '2019-12-13 09:30:47');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-201000003, 'F_hosp', 'ini_dial', 'R', 'ini_dial_meisai', '障害者加算', '富士通想定透析初回申込-申込詳細', 'For test', '1', '<root name="透析申込詳細(障害者加算)">
    <item  name="明細.項目コード" len="8" col="$journal.pat_personal_main.dial_diff_com_info.dial_diff_cd" type="string"/>
    <item  name="明細.項目属性" len="3" type="string"/>
    <item  name="明細.項目名称" len="50" type="string"/>
    <item  name="明細.数量" len="11" type="string"/>
    <item  name="明細.選択単位フラグ" len="1" type="string"/>
    <item  name="明細.単位コード" len="3" type="string"/>
    <item  name="明細.単位名称" len="4" type="string"/>
    <item  name="明細.第２単位コード" len="3" type="string"/>
    <item  name="明細.第２単位名称" len="4" type="string"/>
    <item  name="明細.単位換算量" len="11" type="string"/>
</root>', '{}', '1', '0', -1, '2019-12-13 09:31:33', '2019-12-13 09:31:33');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-201000004, 'F_hosp', 'ini_dial', 'R', 'ini_dial_meisai', 'コメント', '富士通想定透析初回申込-申込詳細', 'For test', '1', '<root name="透析申込詳細(コメント)">
    <item  name="明細.項目コード" len="8" type="string"/>
    <item  name="明細.項目属性" len="3" type="string"/>
    <item  name="明細.項目名称" len="50" col="$journal.pat_obs_rec.obs_rec_info.detail" type="string"/>
    <item  name="明細.数量" len="11" type="string"/>
    <item  name="明細.選択単位フラグ" len="1" type="string"/>
    <item  name="明細.単位コード" len="3" type="string"/>
    <item  name="明細.単位名称" len="4" type="string"/>
    <item  name="明細.第２単位コード" len="3" type="string"/>
    <item  name="明細.第２単位名称" len="4" type="string"/>
    <item  name="明細.単位換算量" len="11" type="string"/>
</root>  ', '{}', '1', '0', -1, '2019-12-13 09:32:15', '2019-12-13 09:32:15');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-201000005, 'F_hosp', 'ini_dial', 'R', 'ini_dial_meisai', '観察記録', '富士通想定透析初回申込-申込詳細', 'For test', '1', '<root name="透析申込詳細(観察記録)">
    <item  name="明細.項目コード" len="8" type="string"/>
    <item  name="明細.項目属性" len="3" type="string"/>
    <item  name="明細.項目名称" len="50" col="$journal.pat_main.pat_memo_info.content" type="string"/>
    <item  name="明細.数量" len="11" type="string"/>
    <item  name="明細.選択単位フラグ" len="1" type="string"/>
    <item  name="明細.単位コード" len="3" type="string"/>
    <item  name="明細.単位名称" len="4" type="string"/>
    <item  name="明細.第２単位コード" len="3" type="string"/>
    <item  name="明細.第２単位名称" len="4" type="string"/>
    <item  name="明細.単位換算量" len="11" type="string"/>
</root>', '{}', '1', '0', -1, '2019-12-13 09:32:15', '2019-12-13 09:32:15');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-201000006, 'F_hosp', 'ini_dial', 'R', 'ini_dial_meisai', '治療方法', '富士通想定透析初回申込-申込詳細', 'For test', '1', '<root name="透析申込詳細(治療方法)">
    <item  name="明細.項目コード" len="8" col="$journal.pat_order_data.vender_1_info.treat_cd" type="string"/>
    <item  name="明細.項目属性" len="3" type="string"/>
    <item  name="明細.項目名称" len="50" col="$journal.pat_order_data.vender_1_info.treat_name" type="string"/>
    <item  name="明細.数量" len="11" type="string"/>
    <item  name="明細.選択単位フラグ" len="1" type="string"/>
    <item  name="明細.単位コード" len="3" type="string"/>
    <item  name="明細.単位名称" len="4" type="string"/>
    <item  name="明細.第２単位コード" len="3" type="string"/>
    <item  name="明細.第２単位名称" len="4" type="string"/>
    <item  name="明細.単位換算量" len="11" type="string"/>
</root>', '{}', '1', '0', -1, '2019-12-13 09:32:52', '2019-12-13 09:32:52');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-201000007, 'F_hosp', 'ini_dial', 'R', 'ini_dial_meisai', '明細', '富士通想定透析初回申込-申込詳細', 'For test', '1', '<root name="透析申込詳細(明細)">
    <item  name="明細.項目コード" len="8" type="string"/>
    <item  name="明細.項目属性" len="3" type="string"/>
    <item  name="明細.項目名称" len="50" type="string"/>
    <item  name="明細.数量" len="11" col="$journal.pat_unique.physical_info.dw" type="string"/>
    <item  name="明細.選択単位フラグ" len="1" type="string"/>
    <item  name="明細.単位コード" len="3" type="string"/>
    <item  name="明細.単位名称" len="4" type="string"/>
    <item  name="明細.第２単位コード" len="3" type="string"/>
    <item  name="明細.第２単位名称" len="4" type="string"/>
    <item  name="明細.単位換算量" len="11" type="string"/>
</root>', '{}', '1', '0', -1, '2019-12-13 09:34:15', '2019-12-13 09:34:15');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-201000008, 'F_hosp', 'ini_dial', 'R', 'ini_dial_meisai', '空データ', '富士通想定透析初回申込-申込詳細', 'For test', '1', '<root name="透析申込詳細(空データ)">
    <item  name="明細.項目コード" len="8" type="string"/>
    <item  name="明細.項目属性" len="3" type="string"/>
    <item  name="明細.項目名称" len="50" type="string"/>
    <item  name="明細.数量" len="11" type="string"/>
    <item  name="明細.選択単位フラグ" len="1" type="string"/>
    <item  name="明細.単位コード" len="3" type="string"/>
    <item  name="明細.単位名称" len="4" type="string"/>
    <item  name="明細.第２単位コード" len="3" type="string"/>
    <item  name="明細.第２単位名称" len="4" type="string"/>
    <item  name="明細.単位換算量" len="11" type="string"/>
</root>', '{}', '1', '0', -1, '2019-12-13 09:34:15', '2019-12-13 09:34:15');
