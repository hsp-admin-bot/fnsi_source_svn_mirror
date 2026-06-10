delete from "mst_coop_layout_detail" where "ctl_no" in (-507000001,-507000002,-507000003,-507000004,-507000005,-507000006,-507000007,-507000008,-507000009,-507000010);
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-507000001, 'S_hosp', 'rst_dial', 'S', '条件詳細', '透析条件', 'SSI', '実績送信(★無効設定。mst_coop_layoutに設定内容を移動しました。)', '1', '<root>
		<COND_INFO CTL_NO="dataset:-304.e01">
			<DIALYSIS_ITEM_NAME>dataset:-304.e02</DIALYSIS_ITEM_NAME>
			<VALUE>dataset:-304.e03</VALUE>
			<VALUE_NAME>dataset:-304.e04</VALUE_NAME>
			<UNIT>dataset:-304.e05</UNIT>
		</COND_INFO>
</root>', '{}', '1', '1', 4, '2020-05-22 12:45:38.325', '2020-05-22 12:45:41.419');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-507000002, 'S_hosp', 'rst_dial', 'S', '薬剤詳細', '処置薬剤', 'SSI', '実績送信(★無効設定。mst_coop_layoutに設定内容を移動しました。)', '1', '<root>
		<MEDI_INFO CTL_NO="dataset:-303.cost_no">
			<MEDICINE_CD>dataset:-303.e01</MEDICINE_CD>
			<MEDICINE_NAME>dataset:-303.e02</MEDICINE_NAME>
			<MEDI_CLASS_NAME>dataset:-303.e03</MEDI_CLASS_NAME>
			<AMOUNT>dataset:-303.e04</AMOUNT>
			<UNIT>dataset:-303.e05</UNIT>
			<!-- <PROCEDURE_CD>dataset:-303.e06</PROCEDURE_CD> -->
			<PROCEDURE_NAME>dataset:-303.e07</PROCEDURE_NAME>
		</MEDI_INFO>
</root>', '{}', '1', '1', 4, '2020-05-22 12:45:38.325', '2020-05-22 12:45:41.419');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-507000003, 'S_hosp', 'rst_dial', 'S', '薬剤詳細', '投与薬剤', 'SSI', '実績送信(★無効設定。mst_coop_layoutに設定内容を移動しました。)', '1', '<root>
		<MEDI_INFO CTL_NO="dataset:-303.cost_no">
			<MEDICINE_CD>dataset:-303.e01</MEDICINE_CD>
			<MEDICINE_NAME>dataset:-303.e02</MEDICINE_NAME>
			<MEDI_CLASS_NAME>dataset:-303.e03</MEDI_CLASS_NAME>
			<AMOUNT>dataset:-303.e04</AMOUNT>
			<UNIT>dataset:-303.e05</UNIT>
			<!-- <PROCEDURE_CD>dataset:-303.e06</PROCEDURE_CD> -->
			<PROCEDURE_NAME>dataset:-303.e07</PROCEDURE_NAME>
		</MEDI_INFO>
</root>', '{}', '1', '1', 4, '2020-05-22 12:45:38.325', '2020-05-22 12:45:41.419');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-507000004, 'S_hosp', 'rst_dial', 'S', '医材詳細', '医材', 'SSI', '実績送信(★無効設定。mst_coop_layoutに設定内容を移動しました。)', '1', '<root>
		<EQUIP_INFO CTL_NO="dataset:-302.cost_no">
			<EQUIP_CD>dataset:-302.e01</EQUIP_CD>
			<EQUIP_NAME>dataset:-302.e02</EQUIP_NAME>
			<EQUIP_CLASS_NAME>dataset:-302.e03</EQUIP_CLASS_NAME>
			<AMOUNT>dataset:-302.e04</AMOUNT>
			<UNIT>dataset:-302.e05</UNIT>
		</EQUIP_INFO>
</root>', '{}', '1', '1', 4, '2020-05-22 10:00:23.169', '2020-05-22 10:00:31.502');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-507000005, 'S_hosp', 'rst_dial', 'S', '医材詳細', '穿刺針', 'SSI', '実績送信(★無効設定。mst_coop_layoutに設定内容を移動しました。)', '1', '<root>
		<EQUIP_INFO CTL_NO="dataset:-302.cost_no">
			<EQUIP_CD>dataset:-302.e01</EQUIP_CD>
			<EQUIP_NAME>dataset:-302.e02</EQUIP_NAME>
			<EQUIP_CLASS_NAME>dataset:-302.e03</EQUIP_CLASS_NAME>
			<AMOUNT>dataset:-302.e04</AMOUNT>
			<UNIT>dataset:-302.e05</UNIT>
		</EQUIP_INFO>
</root>', '{}', '1', '1', 4, '2020-05-22 10:00:23.169', '2020-05-22 10:00:31.502');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-507000006, 'S_hosp', 'rst_dial', 'S', '医材詳細', '血液回路', 'SSI', '実績送信(★無効設定。mst_coop_layoutに設定内容を移動しました。)', '1', '<root>
		<EQUIP_INFO CTL_NO="dataset:-302.cost_no">
			<EQUIP_CD>dataset:-302.e01</EQUIP_CD>
			<EQUIP_NAME>dataset:-302.e02</EQUIP_NAME>
			<EQUIP_CLASS_NAME>dataset:-302.e03</EQUIP_CLASS_NAME>
			<AMOUNT>dataset:-302.e04</AMOUNT>
			<UNIT>dataset:-302.e05</UNIT>
		</EQUIP_INFO>
</root>', '{}', '1', '1', 4, '2020-05-22 10:00:23.169', '2020-05-22 10:00:31.502');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-507000007, 'S_hosp', 'rst_dial', 'S', '処置詳細', '酸素吸入量', 'SSI', '実績送信(★無効設定。mst_coop_layoutに設定内容を移動しました。)', '1', '<root>
		<DISPOSE_INFO DISPOSE_CTL_NO="dataset:-301.cost_no">
			<TENCD>dataset:-301.e01</TENCD>
			<TKJNAM>dataset:-301.e02</TKJNAM>
			<AMOUNT>dataset:-301.e03</AMOUNT>
			<UNIT>dataset:-301.e04</UNIT>
		</DISPOSE_INFO>
</root>', '{}', '1', '1', 4, '2020-05-22 10:00:23.169', '2020-05-22 10:00:31.502');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-507000008, 'S_hosp', 'rst_dial', 'S', '処置詳細', '処置材料', 'SSI', '実績送信(★無効設定。mst_coop_layoutに設定内容を移動しました。)', '1', '<root>
		<DISPOSE_INFO DISPOSE_CTL_NO="dataset:-301.cost_no">
			<TENCD>dataset:-301.e01</TENCD>
			<TKJNAM>dataset:-301.e02</TKJNAM>
			<AMOUNT>dataset:-301.e03</AMOUNT>
			<UNIT>dataset:-301.e04</UNIT>
		</DISPOSE_INFO>
</root>', '{}', '1', '1', 4, '2020-05-22 10:00:23.169', '2020-05-22 10:00:31.502');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-507000009, 'S_hosp', 'rst_dial', 'S', '処置詳細', '酸素手技', 'SSI', '実績送信(★無効設定。mst_coop_layoutに設定内容を移動しました。)', '1', '<root>
		<DISPOSE_INFO DISPOSE_CTL_NO="dataset:-301.cost_no">
			<TENCD>dataset:-301.e01</TENCD>
			<TKJNAM>dataset:-301.e02</TKJNAM>
			<AMOUNT>dataset:-301.e03</AMOUNT>
			<UNIT></UNIT>
		</DISPOSE_INFO>
</root>', '{}', '1', '1', 4, '2020-05-22 10:00:20.531', '2020-05-22 10:00:28.493');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-507000010, 'S_hosp', 'rst_dial', 'S', '処置詳細', '処置行為', 'SSI', '実績送信(★無効設定。mst_coop_layoutに設定内容を移動しました。)', '1', '<root>
		<DISPOSE_INFO DISPOSE_CTL_NO="dataset:-301.cost_no">
			<TENCD>dataset:-301.e01</TENCD>
			<TKJNAM>dataset:-301.e02</TKJNAM>
			<AMOUNT>dataset:-301.e03</AMOUNT>
			<UNIT></UNIT>
		</DISPOSE_INFO>
</root>', '{}', '1', '1', 4, '2020-05-22 10:00:17.365', '2020-05-22 10:00:25.841');
