delete from "mst_coop_layout_detail" where  "ctl_no" in (-203000001,-203000007,-203000010);
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-203000001, 'F_hosp', 'profile', 'R', '患者プロファイル詳細', 'pre', '富士通想定患者プロファイル患者プロファイル項目', '患者プロファイル項目', '1', '<root name="患者プロファイル詳細(pre)">
    <item  name="患者プロファイル項目属性" len="5" key="項目属性" type="string"/>
    <item  name="患者プロファイル項目ＩＤ" len="30" type="string"/>
    <item  name="患者プロファイル項目名称" len="50" type="string"/>
    <item  name="患者プロファイルタイプ・アイテム" len="1060" type="string"/>
    <item  name="患者プロファイル更新利用者ＩＤ" len="8" type="string"/>
    <item  name="患者プロファイル更新日" len="8" type="string"/>
    <item  name="患者プロファイル更新時間" len="6" type="string"/>
</root>', '{"key": {"項目属性": {"00001": "禁忌", "00002": "禁忌", "ARG01": "アレルギー情報", "ARG10": "アレルギー情報", "ARG90": "アレルギー情報", "ARGN1": "アレルギー情報", "BDY01": "身長", "BDY02": "体重", "BDY10": "血液型情報", "BDY20": "感染症", "BDY21": "感染症", "BDY22": "感染症", "BDY23": "感染症", "BDY24": "感染症", "BDY25": "感染症", "BDY26": "感染症", "BDY27": "感染症", "BDY28": "感染症", "BDY29": "感染症", "BDY30": "感染症", "BDY31": "感染症", "BDY32": "感染症", "BDY33": "感染症", "BDY34": "感染症", "BDY35": "感染症", "BDY36": "感染症", "BDY37": "感染症", "BDY38": "感染症", "BDY39": "感染症", "BDY77": "感染症", "EBD40": "アレルギー情報", "INPLT": "アレルギー情報", "NBS14": "緊急連絡先", "NBS15": "緊急連絡先", "NBS16": "緊急連絡先", "OTS21": "生存有無"}}}', '1', '0', 4126, '2019-12-23 07:03:12', '2019-12-23 07:03:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-203000007, 'F_hosp', 'profile', 'R', '患者プロファイル詳細', '身長', '富士通想定患者プロファイル患者プロファイル項目', '患者プロファイル項目', '1', '<root name="患者プロファイル詳細(身長)">
    <item  name="患者プロファイル項目属性" len="5" type="string"/>
    <item  name="患者プロファイル項目ID" len="30" type="string"/>
    <item  name="患者プロファイル項目名称" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１" len="50" col="$journal.detail.pat_unique.physical_info.height" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ２" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム２" len="50" col="$journal.detail.pat_unique.physical_info.exam_date1" type="string"/>
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
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-203000010, 'F_hosp', 'profile', 'R', '患者プロファイル詳細', '体重', '富士通想定患者プロファイル患者プロファイル項目', '患者プロファイル項目', '1', '<root name="患者プロファイル詳細(体重)">
    <item  name="患者プロファイル項目属性" len="5" type="string"/>
    <item  name="患者プロファイル項目ID" len="30" type="string"/>
    <item  name="患者プロファイル項目名称" len="50" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ１" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム１" len="50" col="$journal.detail.pat_unique.physical_info.ctr_weight" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルタイプ２" len="3" type="string"/>
    <item  name="患者プロファイル項目情報プロファイルアイテム２" len="50" col="$journal.detail.pat_unique.physical_info.exam_date2" type="string"/>
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
