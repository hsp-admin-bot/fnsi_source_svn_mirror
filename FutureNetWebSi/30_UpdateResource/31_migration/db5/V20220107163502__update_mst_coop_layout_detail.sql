delete from "mst_coop_layout_detail" where "ctl_no" in (-201000001, -201000002, -201000003, -201000004, -201000005, -201000006, -201000007, -201000008, -201000009, -201000010, -201000011, -201000012, -201000013, -201000014, -201000015, -201000016, -201000017, -201000018, -201000019, -201000020);
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
</root>', '{"key": {"項目属性": {"VA2": "曜日パターン", "VA3": "曜日", "VA4": "開始日", "VA5": "終了日", "VA6": "開始時刻", "VA7": "終了時刻", "VA8": "透析時間", "VA9": "実施場所", "VAB": "障害者加算", "VAC": "搬送区分", "VB1": "原疾患", "VC1": "治療方法", "VD1": "依頼事項", "VD2": "連絡先", "VDW": "DW", "XXX": "コメント", "YYY": "観察記録", "ZZZ": "クール", "_DEFAULT": "空データ"}}}', '1', '0', -1, '2019-12-13 06:16:24', '2022-01-07 18:21:46');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-201000002, 'F_hosp', 'ini_dial', 'R', 'ini_dial_meisai', '原疾患', '富士通想定透析初回申込-申込詳細', 'For test', '1', '<root name="透析申込詳細(原疾患)">
    <item  name="明細.項目コード" len="8" col="$journal.detail.pat_unique_2.medical_hst_info.disease_cd" type="string"/>
    <item  name="明細.項目属性" len="3" type="string"/>
    <item  name="明細.項目名称" len="50" type="string"/>
    <item  name="明細.数量" len="11" type="string"/>
    <item  name="明細.選択単位フラグ" len="1" type="string"/>
    <item  name="明細.単位コード" len="3" type="string"/>
    <item  name="明細.単位名称" len="4" type="string"/>
    <item  name="明細.第２単位コード" len="3" type="string"/>
    <item  name="明細.第２単位名称" len="4" type="string"/>
    <item  name="明細.単位換算量" len="11" type="string"/>
</root>', '{}', '1', '0', -1, '2019-12-13 09:30:47', '2022-01-07 18:21:46');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-201000003, 'F_hosp', 'ini_dial', 'R', 'ini_dial_meisai', '障害者加算', '富士通想定透析初回申込-申込詳細', 'For test', '1', '<root name="透析申込詳細(障害者加算)">
    <item  name="明細.項目コード" len="8" col="$journal.detail.pat_main_2.addition_info.cd" type="string"/>
    <item  name="明細.項目属性" len="3" type="string"/>
    <item  name="明細.項目名称" len="50" type="string"/>
    <item  name="明細.数量" len="11" type="string"/>
    <item  name="明細.選択単位フラグ" len="1" type="string"/>
    <item  name="明細.単位コード" len="3" type="string"/>
    <item  name="明細.単位名称" len="4" type="string"/>
    <item  name="明細.第２単位コード" len="3" type="string"/>
    <item  name="明細.第２単位名称" len="4" type="string"/>
    <item  name="明細.単位換算量" len="11" type="string"/>
</root>', '{}', '1', '0', -1, '2019-12-13 09:31:33', '2022-01-07 18:21:46');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-201000004, 'F_hosp', 'ini_dial', 'R', 'ini_dial_meisai', 'コメント', '富士通想定透析初回申込-申込詳細', 'For test', '1', '<root name="透析申込詳細(コメント)">
    <item  name="明細.項目コード" len="8" type="string"/>
    <item  name="明細.項目属性" len="3" col="$journal.detail.pat_main_3.pat_memo_info.title" type="string"/>
    <item  name="明細.項目名称" len="50" col="$journal.detail.pat_main_3.pat_memo_info.content" type="string"/>
    <item  name="明細.数量" len="11" type="string"/>
    <item  name="明細.選択単位フラグ" len="1" type="string"/>
    <item  name="明細.単位コード" len="3" type="string"/>
    <item  name="明細.単位名称" len="4" type="string"/>
    <item  name="明細.第２単位コード" len="3" type="string"/>
    <item  name="明細.第２単位名称" len="4" type="string"/>
    <item  name="明細.単位換算量" len="11" type="string"/>
</root>', '{}', '1', '0', -1, '2019-12-13 09:32:15', '2022-01-07 18:21:46');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-201000005, 'F_hosp', 'ini_dial', 'R', 'ini_dial_meisai', '観察記録', '富士通想定透析初回申込-申込詳細', 'For test', '1', '<root name="透析申込詳細(観察記録)">
    <item  name="明細.項目コード" len="8" type="string"/>
    <item  name="明細.項目属性" len="3" col="$journal.detail.pat_main_3.pat_memo_info.title" type="string"/>
    <item  name="明細.項目名称" len="50" col="$journal.detail.pat_main_3.pat_memo_info.content" type="string"/>
    <item  name="明細.数量" len="11" type="string"/>
    <item  name="明細.選択単位フラグ" len="1" type="string"/>
    <item  name="明細.単位コード" len="3" type="string"/>
    <item  name="明細.単位名称" len="4" type="string"/>
    <item  name="明細.第２単位コード" len="3" type="string"/>
    <item  name="明細.第２単位名称" len="4" type="string"/>
    <item  name="明細.単位換算量" len="11" type="string"/>
</root>', '{}', '1', '0', -1, '2019-12-13 09:32:15', '2022-01-07 18:21:46');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-201000006, 'F_hosp', 'ini_dial', 'R', 'ini_dial_meisai', '治療方法', '富士通想定透析初回申込-申込詳細', 'For test', '1', '<root name="透析申込詳細(治療方法)">
    <item  name="明細.項目コード" len="8" col="$journal.ord_main.ind_treatment_cd" type="string"/>
    <item  name="明細.項目属性" len="3" type="string"/>
    <item  name="明細.項目名称" len="50" col="$journal.ord_main.ind_treatment_name" type="string"/>
    <item  name="明細.数量" len="11" type="string"/>
    <item  name="明細.選択単位フラグ" len="1" type="string"/>
    <item  name="明細.単位コード" len="3" type="string"/>
    <item  name="明細.単位名称" len="4" type="string"/>
    <item  name="明細.第２単位コード" len="3" type="string"/>
    <item  name="明細.第２単位名称" len="4" type="string"/>
    <item  name="明細.単位換算量" len="11" type="string"/>
</root>', '{}', '1', '0', -1, '2019-12-13 09:32:52', '2022-01-07 18:21:46');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-201000007, 'F_hosp', 'ini_dial', 'R', 'ini_dial_meisai', 'DW', '富士通想定透析初回申込-申込詳細', 'For test', '1', '<root name="透析申込詳細(DW)">
    <item  name="明細.項目コード" len="8" type="string"/>
    <item  name="明細.項目属性" len="3" type="string"/>
    <item  name="明細.項目名称" len="50" type="string"/>
    <item  name="明細.数量" len="11" col="$journal.detail.pat_unique_1.physical_info.dw" type="string"/>
    <item  name="明細.選択単位フラグ" len="1" type="string"/>
    <item  name="明細.単位コード" len="3" type="string"/>
    <item  name="明細.単位名称" len="4" type="string"/>
    <item  name="明細.第２単位コード" len="3" type="string"/>
    <item  name="明細.第２単位名称" len="4" type="string"/>
    <item  name="明細.単位換算量" len="11" type="string"/>
</root>', '{}', '1', '0', -1, '2019-12-13 09:34:15', '2022-01-07 18:21:46');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-201000008, 'F_hosp', 'ini_dial', 'R', 'ini_dial_meisai', '曜日パターン', '富士通想定透析初回申込-申込詳細', 'For test', '1', '<root name="透析申込詳細(曜日パターン)">
    <item  name="明細.項目コード" len="8" type="string"/>
    <item  name="明細.項目属性" len="3" type="string"/>
    <item  name="明細.項目名称" len="50" col="$journal.ord_main.week_patren" type="string"/>
    <item  name="明細.数量" len="11" type="string"/>
    <item  name="明細.選択単位フラグ" len="1" type="string"/>
    <item  name="明細.単位コード" len="3" type="string"/>
    <item  name="明細.単位名称" len="4" type="string"/>
    <item  name="明細.第２単位コード" len="3" type="string"/>
    <item  name="明細.第２単位名称" len="4" type="string"/>
    <item  name="明細.単位換算量" len="11" type="string"/>
</root>', '{}', '1', '0', -1, '2022-01-07 18:21:46', '2022-01-07 18:21:46');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-201000009, 'F_hosp', 'ini_dial', 'R', 'ini_dial_meisai', '曜日', '富士通想定透析初回申込-申込詳細', 'For test', '1', '<root name="透析申込詳細(曜日)">
    <item  name="明細.項目コード" len="8" type="string"/>
    <item  name="明細.項目属性" len="3" type="string"/>
    <item  name="明細.項目名称" len="50" col="$journal.ord_main.treat_week" type="string"/>
    <item  name="明細.数量" len="11" type="string"/>
    <item  name="明細.選択単位フラグ" len="1" type="string"/>
    <item  name="明細.単位コード" len="3" type="string"/>
    <item  name="明細.単位名称" len="4" type="string"/>
    <item  name="明細.第２単位コード" len="3" type="string"/>
    <item  name="明細.第２単位名称" len="4" type="string"/>
    <item  name="明細.単位換算量" len="11" type="string"/>
</root>', '{}', '1', '0', -1, '2022-01-07 18:21:46', '2022-01-07 18:21:46');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-201000010, 'F_hosp', 'ini_dial', 'R', 'ini_dial_meisai', '開始日', '富士通想定透析初回申込-申込詳細', 'For test', '1', '<root name="透析申込詳細(開始日)">
    <item  name="明細.項目コード" len="8" type="string"/>
    <item  name="明細.項目属性" len="3" type="string"/>
    <item  name="明細.項目名称" len="50" col="$journal.ord_main.treat_date_from" type="string"/>
    <item  name="明細.数量" len="11" type="string"/>
    <item  name="明細.選択単位フラグ" len="1" type="string"/>
    <item  name="明細.単位コード" len="3" type="string"/>
    <item  name="明細.単位名称" len="4" type="string"/>
    <item  name="明細.第２単位コード" len="3" type="string"/>
    <item  name="明細.第２単位名称" len="4" type="string"/>
    <item  name="明細.単位換算量" len="11" type="string"/>
</root>', '{}', '1', '0', -1, '2022-01-07 18:21:46', '2022-01-07 18:21:46');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-201000011, 'F_hosp', 'ini_dial', 'R', 'ini_dial_meisai', '終了日', '富士通想定透析初回申込-申込詳細', 'For test', '1', '<root name="透析申込詳細(終了日)">
    <item  name="明細.項目コード" len="8" type="string"/>
    <item  name="明細.項目属性" len="3" type="string"/>
    <item  name="明細.項目名称" len="50" col="$journal.ord_main.treat_date_to" type="string"/>
    <item  name="明細.数量" len="11" type="string"/>
    <item  name="明細.選択単位フラグ" len="1" type="string"/>
    <item  name="明細.単位コード" len="3" type="string"/>
    <item  name="明細.単位名称" len="4" type="string"/>
    <item  name="明細.第２単位コード" len="3" type="string"/>
    <item  name="明細.第２単位名称" len="4" type="string"/>
    <item  name="明細.単位換算量" len="11" type="string"/>
</root>', '{}', '1', '0', -1, '2022-01-07 18:21:46', '2022-01-07 18:21:46');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-201000012, 'F_hosp', 'ini_dial', 'R', 'ini_dial_meisai', '開始時刻', '富士通想定透析初回申込-申込詳細', 'For test', '1', '<root name="透析申込詳細(開始時刻)">
    <item  name="明細.項目コード" len="8" type="string"/>
    <item  name="明細.項目属性" len="3" type="string"/>
    <item  name="明細.項目名称" len="50" col="$journal.ord_main.ind_treat_start_time" type="string"/>
    <item  name="明細.数量" len="11" type="string"/>
    <item  name="明細.選択単位フラグ" len="1" type="string"/>
    <item  name="明細.単位コード" len="3" type="string"/>
    <item  name="明細.単位名称" len="4" type="string"/>
    <item  name="明細.第２単位コード" len="3" type="string"/>
    <item  name="明細.第２単位名称" len="4" type="string"/>
    <item  name="明細.単位換算量" len="11" type="string"/>
</root>', '{}', '1', '0', -1, '2022-01-07 18:21:46', '2022-01-07 18:21:46');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-201000013, 'F_hosp', 'ini_dial', 'R', 'ini_dial_meisai', '終了時刻', '富士通想定透析初回申込-申込詳細', 'For test', '1', '<root name="透析申込詳細(終了時刻)">
    <item  name="明細.項目コード" len="8" type="string"/>
    <item  name="明細.項目属性" len="3" type="string"/>
    <item  name="明細.項目名称" len="50" col="$journal.ord_main.ind_treat_end_time" type="string"/>
    <item  name="明細.数量" len="11" type="string"/>
    <item  name="明細.選択単位フラグ" len="1" type="string"/>
    <item  name="明細.単位コード" len="3" type="string"/>
    <item  name="明細.単位名称" len="4" type="string"/>
    <item  name="明細.第２単位コード" len="3" type="string"/>
    <item  name="明細.第２単位名称" len="4" type="string"/>
    <item  name="明細.単位換算量" len="11" type="string"/>
</root>', '{}', '1', '0', -1, '2022-01-07 18:21:46', '2022-01-07 18:21:46');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-201000014, 'F_hosp', 'ini_dial', 'R', 'ini_dial_meisai', '透析時間', '富士通想定透析初回申込-申込詳細', 'For test', '1', '<root name="透析申込詳細(透析時間)">
    <item  name="明細.項目コード" len="8" type="string"/>
    <item  name="明細.項目属性" len="3" type="string"/>
    <item  name="明細.項目名称" len="50" col="$journal.ord_main.ind_cond_info.1.value" type="string"/>
    <item  name="明細.数量" len="11" type="string"/>
    <item  name="明細.選択単位フラグ" len="1" type="string"/>
    <item  name="明細.単位コード" len="3" type="string"/>
    <item  name="明細.単位名称" len="4" type="string"/>
    <item  name="明細.第２単位コード" len="3" type="string"/>
    <item  name="明細.第２単位名称" len="4" type="string"/>
    <item  name="明細.単位換算量" len="11" type="string"/>
</root>', '{}', '1', '0', -1, '2022-01-07 18:21:46', '2022-01-07 18:21:46');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-201000015, 'F_hosp', 'ini_dial', 'R', 'ini_dial_meisai', '実施場所', '富士通想定透析初回申込-申込詳細', 'For test', '1', '<root name="透析申込詳細(実施場所)">
    <item  name="明細.項目コード" len="8" type="string"/>
    <item  name="明細.項目属性" len="3" type="string"/>
    <item  name="明細.項目名称" len="50" col="$journal.ord_main.ind_bed_cd" type="string"/>
    <item  name="明細.数量" len="11" type="string"/>
    <item  name="明細.選択単位フラグ" len="1" type="string"/>
    <item  name="明細.単位コード" len="3" type="string"/>
    <item  name="明細.単位名称" len="4" type="string"/>
    <item  name="明細.第２単位コード" len="3" type="string"/>
    <item  name="明細.第２単位名称" len="4" type="string"/>
    <item  name="明細.単位換算量" len="11" type="string"/>
</root>', '{}', '1', '0', -1, '2022-01-07 18:21:46', '2022-01-07 18:21:46');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-201000016, 'F_hosp', 'ini_dial', 'R', 'ini_dial_meisai', '搬送区分', '富士通想定透析初回申込-申込詳細', 'For test', '1', '<root name="透析申込詳細(搬送区分)">
    <item  name="明細.項目コード" len="8" col="$journal.pat_personal_main.transport_cd" type="string"/>
    <item  name="明細.項目属性" len="3" type="string"/>
    <item  name="明細.項目名称" len="50" col="$journal.pat_personal_main.transport_name" type="string"/>
    <item  name="明細.数量" len="11" type="string"/>
    <item  name="明細.選択単位フラグ" len="1" type="string"/>
    <item  name="明細.単位コード" len="3" type="string"/>
    <item  name="明細.単位名称" len="4" type="string"/>
    <item  name="明細.第２単位コード" len="3" type="string"/>
    <item  name="明細.第２単位名称" len="4" type="string"/>
    <item  name="明細.単位換算量" len="11" type="string"/>
</root>', '{}', '1', '0', -1, '2022-01-07 18:21:46', '2022-01-07 18:21:46');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-201000017, 'F_hosp', 'ini_dial', 'R', 'ini_dial_meisai', '依頼事項', '富士通想定透析初回申込-申込詳細', 'For test', '1', '<root name="透析申込詳細(依頼事項)">
    <item  name="明細.項目コード" len="8" type="string"/>
    <item  name="明細.項目属性" len="3" col="$journal.detail.pat_main_3.pat_memo_info.title" type="string"/>
    <item  name="明細.項目名称" len="50" col="$journal.detail.pat_main_3.pat_memo_info.content" type="string"/>
    <item  name="明細.数量" len="11" type="string"/>
    <item  name="明細.選択単位フラグ" len="1" type="string"/>
    <item  name="明細.単位コード" len="3" type="string"/>
    <item  name="明細.単位名称" len="4" type="string"/>
    <item  name="明細.第２単位コード" len="3" type="string"/>
    <item  name="明細.第２単位名称" len="4" type="string"/>
    <item  name="明細.単位換算量" len="11" type="string"/>
</root>', '{}', '1', '0', -1, '2022-01-07 18:21:46', '2022-01-07 18:21:46');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-201000018, 'F_hosp', 'ini_dial', 'R', 'ini_dial_meisai', '連絡先', '富士通想定透析初回申込-申込詳細', 'For test', '1', '<root name="透析申込詳細(連絡先)">
    <item  name="明細.項目コード" len="8" type="string"/>
    <item  name="明細.項目属性" len="3" type="string"/>
    <item  name="明細.項目名称" len="50" col="$journal.pat_personal_main.pat_contact_info.tel1" type="string"/>
    <item  name="明細.数量" len="11" type="string"/>
    <item  name="明細.選択単位フラグ" len="1" type="string"/>
    <item  name="明細.単位コード" len="3" type="string"/>
    <item  name="明細.単位名称" len="4" type="string"/>
    <item  name="明細.第２単位コード" len="3" type="string"/>
    <item  name="明細.第２単位名称" len="4" type="string"/>
    <item  name="明細.単位換算量" len="11" type="string"/>
</root>', '{}', '1', '0', -1, '2022-01-07 18:21:46', '2022-01-07 18:21:46');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-201000019, 'F_hosp', 'ini_dial', 'R', 'ini_dial_meisai', 'クール', '富士通想定透析初回申込-申込詳細', 'For test', '1', '<root name="透析申込詳細(クール)">
    <item  name="明細.項目コード" len="8" type="string"/>
    <item  name="明細.項目属性" len="3" type="string"/>
    <item  name="明細.項目名称" len="50" col="$journal.ord_main.ind_kur_cd" type="string"/>
    <item  name="明細.数量" len="11" type="string"/>
    <item  name="明細.選択単位フラグ" len="1" type="string"/>
    <item  name="明細.単位コード" len="3" type="string"/>
    <item  name="明細.単位名称" len="4" type="string"/>
    <item  name="明細.第２単位コード" len="3" type="string"/>
    <item  name="明細.第２単位名称" len="4" type="string"/>
    <item  name="明細.単位換算量" len="11" type="string"/>
</root>', '{}', '1', '0', -1, '2022-01-07 18:21:46', '2022-01-07 18:21:46');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-201000020, 'F_hosp', 'ini_dial', 'R', 'ini_dial_meisai', '空データ', '富士通想定透析初回申込-申込詳細', 'For test', '1', '<root name="透析申込詳細(空データ)">
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
</root>', '{}', '1', '0', -1, '2022-01-07 18:21:46', '2022-01-07 18:21:46');
