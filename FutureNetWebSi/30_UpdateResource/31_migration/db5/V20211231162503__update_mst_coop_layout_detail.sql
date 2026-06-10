delete from "mst_coop_layout_detail" where "ctl_no" in (-202000001,-202000002,-203000001,-203000002,-203000003,-203000004,-203000005,-203000006,-203000007,-203000008,-203000009);
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-202000001, 'F_hosp', 'profile', 'R', '保険情報詳細', 'pre', '富士通想定患者プロファイル患者プロファイル項目', '保険情報', '1', '<root name="保険情報詳細(pre)">
    <item  name="保険情報.保険パターン" len="2" type="string"/>
    <item  name="保険情報.保険パターンＳＥＱ" len="2" type="string"/>
    <item  name="保険情報.保険開始日" len="8" type="string"/>
    <item  name="保険情報.保険終了日" len="8" type="string"/>
    <item  name="保険情報.主保険保険者番号" len="8" type="string"/>
    <item  name="保険情報.公費負担者番号１" len="8" type="string"/>
    <item  name="保険情報.公費負担者番号２" len="8" type="string"/>
    <item  name="保険情報.公費負担者番号３" len="8" type="string"/>
    <item  name="保険情報.公費負担者番号４" len="8" type="string"/>
    <item  name="保険情報.本人家族区分" len="1" type="string"/>
    <item  name="保険情報.外来負担率" len="3" type="string"/>
    <item  name="保険情報.入院負担率" len="3" type="string"/>
    <item  name="保険情報.保険名称" len="42" type="string"/>
    <item  name="振分用" len="0" key="all" type="string" value="const:all"/>
</root>
', '{"key": {"all": {"all": "保険情報詳細"}}}', '1', '0', 4126, '2019-12-23 07:03:12', '2019-12-23 07:03:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-202000002, 'F_hosp', 'profile', 'R', '保険情報詳細', '保険情報詳細', '富士通想定患者プロファイル患者プロファイル項目', '保険情報', '1', '<root name="保険情報詳細">
    <item  name="保険情報.保険パターン" len="2" col="$journal.detail.pat_insurance.ctl_no" type="string"/>
    <item  name="保険情報.保険パターンＳＥＱ" len="2" type="string"/>
    <item  name="保険情報.保険開始日" len="8" col="$journal.detail.pat_insurance.start_date" type="string"/>
    <item  name="保険情報.保険終了日" len="8" col="$journal.detail.pat_insurance.end_date" type="string"/>
    <item  name="保険情報.主保険保険者番号" len="8" col="$journal.detail.pat_insurance.insu_info.insu_no" type="string"/>
    <item  name="保険情報.公費負担者番号" len="32" col="$journal.detail.pat_insurance.insu_pub_info.insu_pub_no" type="string"/>
    <item  name="保険情報.本人家族区分" len="1" col="$journal.detail.pat_insurance.insu_info.insu_kbn" type="string"/>
    <item  name="保険情報.外来負担率" len="3" col="$journal.detail.pat_insurance.insu_info.futan-g" type="string"/>
    <item  name="保険情報.入院負担率" len="3" col="$journal.detail.pat_insurance.insu_info.futan-n" type="string"/>
    <item  name="保険情報.保険名称" len="42" col="$journal.detail.pat_insurance.insu_name" type="string"/>
</root>', '{}', '1', '0', 4126, '2019-12-23 07:03:12', '2019-12-23 07:03:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-203000001, 'F_hosp', 'profile', 'R', '患者プロファイル詳細', 'pre', '富士通想定患者プロファイル患者プロファイル項目', '患者プロファイル項目', '1', '<root name="患者プロファイル詳細(pre)">
    <item  name="患者プロファイル項目属性" len="5" key="項目属性" type="string"/>
    <item  name="患者プロファイル項目ＩＤ" len="30" type="string"/>
    <item  name="患者プロファイル項目名称" len="50" type="string"/>
    <item  name="患者プロファイルタイプ・アイテム" len="1060" type="string"/>
    <item  name="患者プロファイル更新利用者ＩＤ" len="8" type="string"/>
    <item  name="患者プロファイル更新日" len="8" type="string"/>
    <item  name="患者プロファイル更新時間" len="6" type="string"/>
</root>', '{"key": {"項目属性": {"00001": "禁忌", "00002": "禁忌", "ARG01": "アレルギー情報", "ARG10": "アレルギー情報", "ARG90": "アレルギー情報", "ARGN1": "アレルギー情報", "BDY01": "身長", "BDY02": "身長", "BDY10": "血液型情報", "BDY20": "感染症", "BDY21": "感染症", "BDY22": "感染症", "BDY23": "感染症", "BDY24": "感染症", "BDY25": "感染症", "BDY26": "感染症", "BDY27": "感染症", "BDY28": "感染症", "BDY29": "感染症", "BDY30": "感染症", "BDY31": "感染症", "BDY32": "感染症", "BDY33": "感染症", "BDY34": "感染症", "BDY35": "感染症", "BDY36": "感染症", "BDY37": "感染症", "BDY38": "感染症", "BDY39": "感染症", "BDY77": "感染症", "EBD40": "アレルギー情報", "INPLT": "アレルギー情報", "NBS14": "緊急連絡先", "NBS15": "緊急連絡先", "NBS16": "緊急連絡先", "OTS21": "生存有無"}}}', '1', '0', 4126, '2019-12-23 07:03:12', '2019-12-23 07:03:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-203000002, 'F_hosp', 'profile', 'R', '患者プロファイル詳細', '血液型情報', '富士通想定患者プロファイル患者プロファイル項目', '患者プロファイル項目', '1', '<root name="患者プロファイル詳細(血液型情報)">
    <item  name="患者プロファイル項目属性" len="5" type="string"/>
    <item  name="患者プロファイル項目ID" len="30" type="string"/>
    <item  name="患者プロファイル項目名称" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１" len="50" col="$journal.pat_personal_main.pat_blood_type_abo" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ２" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム２" len="50" col="$journal.pat_personal_main.pat_blood_type_rh" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ３" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム３" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ４" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム４" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ５" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム５" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ６" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム６" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ７" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム７" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ８" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム８" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ９" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム９" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１０" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１０" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１１" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１１" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１２" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１２" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１３" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１３" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１４" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１４" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１５" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１５" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１６" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１６" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１７" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１７" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１８" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１８" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１９" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１９" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ２０" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム２０" len="50" type="string"/>
    <item  name="患者プロファイル更新使用者ID" len="8" type="string"/>
    <item  name="患者プロファイル更新日" len="8" type="string"/>
    <item  name="患者プロファイル更新時間" len="6" type="string"/>
</root>', '{}', '1', '0', 4126, '2019-12-23 07:03:12', '2019-12-23 07:03:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-203000003, 'F_hosp', 'profile', 'R', '患者プロファイル詳細', '緊急連絡先', '富士通想定患者プロファイル患者プロファイル項目', '患者プロファイル項目', '1', '<root name="患者プロファイル詳細(緊急連絡先)">
    <item  name="患者プロファイル項目属性" len="5" type="string"/>
    <item  name="患者プロファイル項目ID" len="30" type="string"/>
    <item  name="患者プロファイル項目名称" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１" len="50" col="$journal.detail.pat_personal_main_1.other_contact_info.last_name" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ２" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム２" len="50" col="$journal.detail.pat_personal_main_1.other_contact_info.tel1" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ３" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム３" len="50" col="$journal.detail.pat_personal_main_1.other_contact_info.relation_cd" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ４" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム４" len="50" col="$journal.detail.pat_personal_main_1.other_contact_info.tel2" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ５" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム５" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ６" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム６" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ７" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム７" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ８" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム８" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ９" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム９" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１０" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１０" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１１" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１１" len="50" col="$journal.detail.pat_personal_main_1.other_contact_info.memo1" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１２" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１２" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１３" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１３" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１４" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１４" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１５" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１５" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１６" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１６" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１７" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１７" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１８" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１８" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１９" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１９" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ２０" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム２０" len="50" type="string"/>
    <item  name="患者プロファイル更新使用者ID" len="8" type="string"/>
    <item  name="患者プロファイル更新日" len="8" type="string"/>
    <item  name="患者プロファイル更新時間" len="6" type="string"/>
</root>', '{}', '1', '0', 4126, '2019-12-23 07:03:12', '2019-12-23 07:03:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-203000004, 'F_hosp', 'profile', 'R', '患者プロファイル詳細', '感染症', '富士通想定患者プロファイル患者プロファイル項目', '患者プロファイル項目', '1', '<root name="患者プロファイル詳細(感染症)">
    <item  name="患者プロファイル項目属性" len="5" type="string"/>
    <item  name="患者プロファイル項目ID" len="30" col="$journal.detail.pat_main_1.infect_info.infection_cd" type="string"/>
    <item  name="患者プロファイル項目名称" len="50" col="$journal.detail.pat_main_1.infect_info.name" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１" len="50" col="$journal.detail.pat_main_1.infect_info.infect" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ２" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム２" len="50" col="$journal.detail.pat_main_1.infect_info.exam_date" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ３" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム３" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ４" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム４" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ５" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム５" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ６" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム６" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ７" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム７" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ８" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム８" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ９" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム９" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１０" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１０" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１１" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１１" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１２" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１２" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１３" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１３" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１４" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１４" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１５" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１５" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１６" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１６" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１７" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１７" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１８" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１８" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１９" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１９" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ２０" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム２０" len="50" type="string"/>
    <item  name="患者プロファイル更新使用者ID" len="8" type="string"/>
    <item  name="患者プロファイル更新日" len="8" type="string"/>
    <item  name="患者プロファイル更新時間" len="6" type="string"/>
</root>
', '{}', '1', '0', 4126, '2019-12-23 07:03:12', '2019-12-23 07:03:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-203000005, 'F_hosp', 'profile', 'R', '患者プロファイル詳細', '生存有無', '富士通想定患者プロファイル患者プロファイル項目', '患者プロファイル項目', '1', '<root name="患者プロファイル詳細(生存の有無)">
    <item  name="患者プロファイル項目属性" len="5" type="string"/>
    <item  name="患者プロファイル項目ID" len="30" type="string"/>
    <item  name="患者プロファイル項目名称" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１" len="50" col="$journal.pat_personal_main.is_die" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ２" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム２" len="50" col="$journal.pat_personal_main.die_date" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ３" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム３" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ４" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム４" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ５" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム５" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ６" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム６" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ７" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム７" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ８" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム８" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ９" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム９" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１０" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１０" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１１" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１１" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１２" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１２" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１３" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１３" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１４" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１４" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１５" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１５" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１６" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１６" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１７" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１７" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１８" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１８" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１９" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１９" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ２０" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム２０" len="50" type="string"/>
    <item  name="患者プロファイル更新使用者ID" len="8" type="string"/>
    <item  name="患者プロファイル更新日" len="8" type="string"/>
    <item  name="患者プロファイル更新時間" len="6" type="string"/>
</root>', '{}', '1', '0', 4126, '2019-12-23 07:03:12', '2019-12-23 07:03:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-203000006, 'F_hosp', 'profile', 'R', '患者プロファイル詳細', '禁忌', '富士通想定患者プロファイル患者プロファイル項目', '患者プロファイル項目', '1', '<root name="患者プロファイル詳細(禁忌)">
    <item  name="患者プロファイル項目属性" len="5" type="string"/>
    <item  name="患者プロファイル項目ID" len="30" type="string"/>
    <item  name="患者プロファイル項目名称" len="50" col="$journal.detail.pat_main.taboo_allergy_info.memo" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１" len="50" col="$journal.detail.pat_main.taboo_allergy_info.taboo_allergy_cd" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ２" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム２" len="50" col="$journal.detail.pat_main.taboo_allergy_info.content" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ３" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム３" len="50" col="$journal.detail.pat_main.taboo_allergy_info.symptom" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ４" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム４" len="50" col="$journal.detail.pat_main.taboo_allergy_info.start_date" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ５" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム５" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ６" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム６" len="50" col="$journal.detail.pat_main.taboo_allergy_info.stop_flag" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ７" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム７" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ８" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム８" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ９" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム９" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１０" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１０" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１１" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１１" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１２" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１２" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１３" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１３" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１４" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１４" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１５" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１５" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１６" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１６" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１７" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１７" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１８" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１８" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１９" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１９" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ２０" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム２０" len="50" type="string"/>
    <item  name="患者プロファイル更新使用者ID" len="8" type="string"/>
    <item  name="患者プロファイル更新日" len="8" type="string"/>
    <item  name="患者プロファイル更新時間" len="6" type="string"/>
</root>
', '{}', '1', '0', 4126, '2019-12-23 07:03:12', '2019-12-23 07:03:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-203000007, 'F_hosp', 'profile', 'R', '患者プロファイル詳細', '身長', '富士通想定患者プロファイル患者プロファイル項目', '患者プロファイル項目', '1', '<root name="患者プロファイル詳細(身長)">
    <item  name="患者プロファイル項目属性" len="5" type="string"/>
    <item  name="患者プロファイル項目ID" len="30" type="string"/>
    <item  name="患者プロファイル項目名称" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１" len="50" col="$journal.detail.pat_unique.physical_info.height" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ２" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム２" len="50" col="$journal.detail.pat_unique.physical_info.exam_date" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ３" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム３" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ４" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム４" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ５" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム５" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ６" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム６" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ７" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム７" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ８" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム８" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ９" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム９" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１０" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１０" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１１" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１１" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１２" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１２" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１３" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１３" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１４" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１４" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１５" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１５" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１６" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１６" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１７" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１７" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１８" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１８" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１９" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１９" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ２０" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム２０" len="50" type="string"/>
    <item  name="患者プロファイル更新使用者ID" len="8" type="string"/>
    <item  name="患者プロファイル更新日" len="8" type="string"/>
    <item  name="患者プロファイル更新時間" len="6" type="string"/>
</root>
', '{}', '1', '0', 4126, '2019-12-23 07:03:12', '2019-12-23 07:03:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-203000008, 'F_hosp', 'profile', 'R', '患者プロファイル詳細', 'アレルギー情報', '富士通想定患者プロファイル患者プロファイル項目', '患者プロファイル項目', '1', '<root name="患者プロファイル詳細(アレルギー)">
    <item  name="患者プロファイル項目属性" len="5" type="string"/>
    <item  name="患者プロファイル項目ID" len="30" type="string"/>
    <item  name="患者プロファイル項目名称" len="50" col="$journal.detail.pat_main.taboo_allergy_info.memo" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１" len="50" col="$journal.detail.pat_main.taboo_allergy_info.taboo_allergy_cd" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ２" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム２" len="50" col="$journal.detail.pat_main.taboo_allergy_info.content" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ３" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム３" len="50" col="$journal.detail.pat_main.taboo_allergy_info.symptom" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ４" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム４" len="50" col="$journal.detail.pat_main.taboo_allergy_info.start_date" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ５" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム５" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ６" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム６" len="50" col="$journal.detail.pat_main.taboo_allergy_info.stop_flag" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ７" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム７" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ８" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム８" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ９" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム９" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１０" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１０" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１１" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１１" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１２" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１２" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１３" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１３" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１４" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１４" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１５" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１５" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１６" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１６" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１７" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１７" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１８" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１８" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１９" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１９" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ２０" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム２０" len="50" type="string"/>
    <item  name="患者プロファイル更新使用者ID" len="8" type="string"/>
    <item  name="患者プロファイル更新日" len="8" type="string"/>
    <item  name="患者プロファイル更新時間" len="6" type="string"/>
</root>
', '{}', '1', '0', 4126, '2019-12-23 07:03:12', '2019-12-23 07:03:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-203000009, 'F_hosp', 'profile', 'R', '患者プロファイル詳細', '空白', '富士通想定患者プロファイル患者プロファイル項目', '患者プロファイル項目', '1', '<root name="患者プロファイル詳細(空白)">
    <item  name="患者プロファイル項目属性" len="5" type="string"/>
    <item  name="患者プロファイル項目ID" len="30" type="string"/>
    <item  name="患者プロファイル項目名称" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ２" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム２" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ３" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム３" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ４" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム４" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ５" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム５" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ６" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム６" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ７" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム７" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ８" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム８" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ９" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム９" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１０" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１０" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１１" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１１" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１２" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１２" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１３" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１３" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１４" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１４" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１５" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１５" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１６" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１６" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１７" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１７" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１８" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１８" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１９" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１９" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ２０" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム２０" len="50" type="string"/>
    <item  name="患者プロファイル更新使用者ID" len="8" type="string"/>
    <item  name="患者プロファイル更新日" len="8" type="string"/>
    <item  name="患者プロファイル更新時間" len="6" type="string"/>
</root>
', '{}', '1', '0', 4126, '2019-12-23 07:03:12', '2019-12-23 07:03:12');
