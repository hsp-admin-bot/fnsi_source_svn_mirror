delete from "mst_coop_layout_detail" where "ctl_no" in (-504000004,-504000005,-504000003,-504000001,-504000002);
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-504000004, 'S_hosp', 'ind_dial', 'S', '医材詳細', '医材', 'SSI', '予約送信(★無効設定。mst_coop_layoutに設定内容を移動しました。)', '1', '		<EQUIP_INFO CTL_NO="dataset:-305.cost_no">
			<EQUIP_CD>dataset:-305.e01</EQUIP_CD>
			<EQUIP_NAME>dataset:-305.e02</EQUIP_NAME>
			<EQUIP_CLASS_NAME>dataset:-305.e03</EQUIP_CLASS_NAME>
			<AMOUNT>dataset:-305.e04</AMOUNT>
			<UNIT>dataset:-305.e05</UNIT>
		</EQUIP_INFO>', '{}', '1', '1', 4, '2020-05-22 10:00:23.169', '2020-05-22 10:00:31.502');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-504000005, 'S_hosp', 'ind_dial', 'S', '条件詳細', '透析条件', 'SSI', '予約送信(★無効設定。mst_coop_layoutに設定内容を移動しました。)', '1', '		<COND_INFO CTL_NO="dataset:-307.e01">
			<DIALYSIS_ITEM_NAME>dataset:-307.e02</DIALYSIS_ITEM_NAME>
			<VALUE>dataset:-307.e03</VALUE>
			<VALUE_NAME>dataset:-307.e04</VALUE_NAME>
			<UNIT>dataset:-307.e05</UNIT>
		</COND_INFO>', '{}', '1', '1', 4, '2020-05-22 12:45:38.325', '2020-05-22 12:45:41.419');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-504000003, 'S_hosp', 'ind_dial', 'S', '薬剤詳細', '投与薬剤', 'SSI', '予約送信(★無効設定。mst_coop_layoutに設定内容を移動しました。)', '1', '		<MEDI_INFO CTL_NO="dataset:-306.cost_no">
			<MEDICINE_CD>dataset:-306.e01</MEDICINE_CD>
			<MEDICINE_NAME>dataset:-306.e02</MEDICINE_NAME>
			<MEDI_CLASS_NAME>dataset:-306.e03</MEDI_CLASS_NAME>
			<AMOUNT>dataset:-306.e04</AMOUNT>
			<UNIT>dataset:-306.e05</UNIT>
			<PROCEDURE_CD>dataset:-306.e06</PROCEDURE_CD>
			<PROCEDURE_NAME>dataset:-306.e07</PROCEDURE_NAME>
		</MEDI_INFO>', '{}', '1', '1', 4, '2020-05-22 12:45:38.325', '2020-05-22 12:45:41.419');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-504000001, 'S_hosp', 'ind_dial', 'S', '医材詳細', '血液回路', 'SSI', '予約送信(★無効設定。mst_coop_layoutに設定内容を移動しました。)', '1', '		<EQUIP_INFO CTL_NO="dataset:-305.cost_no">
			<EQUIP_CD>dataset:-305.e01</EQUIP_CD>
			<EQUIP_NAME>dataset:-305.e02</EQUIP_NAME>
			<EQUIP_CLASS_NAME>dataset:-305.e03</EQUIP_CLASS_NAME>
			<AMOUNT>dataset:-305.e04</AMOUNT>
			<UNIT>dataset:-305.e05</UNIT>
		</EQUIP_INFO>', '{}', '1', '1', 4, '2020-05-22 10:00:23.169', '2020-05-22 10:00:31.502');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-504000002, 'S_hosp', 'ind_dial', 'S', '医材詳細', '穿刺針', 'SSI', '予約送信(★無効設定。mst_coop_layoutに設定内容を移動しました。)', '1', '		<EQUIP_INFO CTL_NO="dataset:-305.cost_no">
			<EQUIP_CD>dataset:-305.e01</EQUIP_CD>
			<EQUIP_NAME>dataset:-305.e02</EQUIP_NAME>
			<EQUIP_CLASS_NAME>dataset:-305.e03</EQUIP_CLASS_NAME>
			<AMOUNT>dataset:-305.e04</AMOUNT>
			<UNIT>dataset:-305.e05</UNIT>
		</EQUIP_INFO>', '{}', '1', '1', 4, '2020-05-22 10:00:23.169', '2020-05-22 10:00:31.502');
