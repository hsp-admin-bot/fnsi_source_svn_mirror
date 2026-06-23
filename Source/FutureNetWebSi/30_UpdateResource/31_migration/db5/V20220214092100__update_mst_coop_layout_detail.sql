delete from "mst_coop_layout_detail" where "ctl_no" in (-207000031);
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-207000031, 'F_hosp', 'rst_dial', 'S', '実績詳細', '実績詳細', '富士通実績', '実績送信', '1', '<root name="透析実績詳細(実績詳細)">



    <item  name="明細.項目コード" len="8" type="string" value="dataset:-101.e01"/>



    <item  name="明細.項目属性" len="3" key="分類属性" type="string" value="dataset:-101.e02"/>



    <item  name="明細.項目名称" len="50" type="string" value="dataset:-101.e03"/>



    <item  name="明細.数量" len="11" type="string" value="dataset:-101.e04"/>



    <item  name="明細.選択単位フラグ" len="1" type="string" value="dataset:-101.e05"/>



    <item  name="明細.単位コード" len="3" type="string" value="dataset:-101.e06"/>



    <item  name="明細.単位名称" len="4" type="string" value="dataset:-101.e07"/>



    <item  name="明細.第２単位コード" len="3" type="string" value="$BLANK"/>



    <item  name="明細.第２単位名称" len="4" type="string" value="$BLANK"/>



    <item  name="明細.単位換算量" len="11" type="string" value="$BLANK"/>



    <item  name="明細.タグ名称" len="20" type="string" value="$BLANK"/>



</root>', '{"key": {"分類属性": {"COM": "実施コメント", "OX1": "酸素吸入", "OX2": "酸素量", "VA6": "希望開始時刻", "VA7": "希望終了時刻", "VA8": "予定所要時間", "VAB": "加算", "VC1": "浄化方法", "VE1": "ベッドＮＯ", "VF1": "目標体重", "VF2": "透析前体重", "VF3": "ドライウェイト", "VF9": "透析後体重", "VGX": "抗凝固剤・初回", "VGY": "抗凝固剤・持続", "VGZ": "抗凝固剤・ＴＯＴＡＬ", "VH1": "透析器", "VH2": "吸着器", "VH3": "血漿分離器", "VI1": "透析液", "VI2": "置換液", "VK3": "血液流量", "VK4": "透析液流量", "VN1": "ＶＡ", "VO1": "手技", "VO2": "薬剤", "VR1": "医療材料", "VS2": "補液量", "VS3": "透析導入日"}}}', '1', '0', 4, '2019-12-13 06:16:24', CURRENT_TIMESTAMP);

