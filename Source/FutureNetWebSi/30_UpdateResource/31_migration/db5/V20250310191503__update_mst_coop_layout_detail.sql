DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no IN (-501000001, -501000002, -501000003, -501000004, -502000001, -503000001, -503000002, -503000003, -503000004, -503000005, -503000006, -503000007, -504000001, -504000002, -504000003, -504000004, -504000005, -507000001, -507000002, -507000003, -507000004, -507000005, -507000006, -507000007, -507000008, -507000009, -507000010);

INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-501000001, 'S_hosp', 'rep_dial', 'S', 'report', '05', 'SSI 透析レポート', '透析レポート', '1', '<root><REPORT STARTDATE="dataset:-500006.start_date8a" STARTTIME="dataset:-500006.start_date6a" DATETIMEVALUE="dataset:-500006.start_date14" BEDNAME="dataset:-500006.bed_name" DIALYSIS_NO="dataset:-500006.dialysis_no" EDITION="dataset:-500006.edition" UPDATE_DATETIME="dataset:-500006.up_date" /></root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -500006}]}'::jsonb, '1', '0', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-501000002, 'S_hosp', 'ord_dial', 'R', '風袋情報', 'all', 'SSI_透析オーダ受け連携', '透析オーダ受信', '1', '<root name="透析オーダ受け(風袋情報)">
  <item name="detailNo" len="0" type="string" col="$journal.detail.ord_main_4.ind_tare_info.no" value="%%record_no%%"/>
  <item name="風袋-名称" len="16" col="$journal.detail.ord_main_4.ind_tare_info.name_" type="string"/>
  <item name="風袋-量" len="5" col="$journal.detail.ord_main_4.ind_tare_info.weight_" type="string"/>
</root>
', '{}'::jsonb, '1', '0', -1, '2019-12-13 09:30:47.000', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-501000003, 'S_hosp', 'ord_dial', 'R', '除水補正情報', 'all', 'SSI_透析オーダ受け連携', '透析オーダ受信', '1', '<root name="透析オーダ受け(除水補正情報)">
  <item name="detailNo" len="0" type="string" col="$journal.detail.ord_main_3.ind_off_water_info.no" value="%%record_no%%"/>
  <item name="除水補正-名称" len="16" col="$journal.detail.ord_main_3.ind_off_water_info.name_" type="string"/>
  <item name="除水補正-量" len="5" col="$journal.detail.ord_main_3.ind_off_water_info.weight_" type="string"/>
</root>
', '{}'::jsonb, '1', '0', -1, '2019-12-13 09:30:47.000', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-501000004, 'S_hosp', 'ord_dial', 'R', '処方情報', 'all', 'SSI_透析オーダ受け連携', '透析オーダ受信', '1', '<root name="透析オーダ受け(処方情報)">
  <item name="detailNo" len="0" type="string" col="$journal.detail.ord_main_2.ind_medi_info.no" value="%%record_no%%"/>
  <item name="薬剤-コード" len="10" col="$journal.detail.ord_main_2.ind_medi_info.cd" type="string"/>
  <item name="薬剤-名称" len="80" col="$journal.detail.ord_main_2.ind_medi_info.name" type="string"/>
  <item name="薬剤-数量" len="7" col="$journal.detail.ord_main_2.ind_medi_info.amount" type="string"/>
  <item name="薬剤-単位" len="20" col="$journal.detail.ord_main_2.ind_medi_info.unit" type="string"/>
  <item name="服用-コード" len="10" col="$journal.detail.ord_main_2.ind_medi_info.procedure_cd" type="string"/>
  <item name="服用-名称" len="80" col="$journal.detail.ord_main_2.ind_medi_info.procedure_name" type="string"/>
</root>
', '{}'::jsonb, '1', '0', -1, '2019-12-13 09:30:47.000', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-502000001, 'S_hosp', 'ord_dial', 'R', '消耗品情報', 'all', 'SSI_透析オーダ受け連携', '透析オーダ受信', '1', '<root name="透析オーダ受け(消耗品情報)">
  <item name="detailNo" len="0" type="string" col="$journal.detail.ord_main_1.ind_equip_info.no" value="%%record_no%%"/>
  <item name="消耗品-コード" len="10" col="$journal.detail.ord_main_1.ind_equip_info.cd" type="string"/>
  <item name="消耗品-名称" len="40" col="$journal.detail.ord_main_1.ind_equip_info.name" type="string"/>
  <item name="消耗品-数量" len="3" col="$journal.detail.ord_main_1.ind_equip_info.amount" type="string"/>
</root>
', '{}'::jsonb, '1', '0', -1, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-503000001, 'S_hosp', 'profile', 'R', '患者主治医', 'all', 'SSI_患者属性連携', '患者情報受信', '1', '<Doctor Code="col:$journal.detail.pat_main.charge_staff_info.staff_cd" IsMain="col:$journal.detail.pat_main.charge_staff_info.is_main,const:1" IsCharge="col:$journal.detail.pat_main.charge_staff_info.is_charge,const:0" isPuncture="col:$journal.detail.pat_main.charge_staff_info.is_puncture,const:0"></Doctor>', '{}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-503000002, 'S_hosp', 'profile', 'R', '透析主治医', 'all', 'SSI_患者属性連携', '患者情報受信', '1', '<DialysisDoctor Code="col:$journal.detail.pat_main.charge_staff_info.staff_cd" IsMain="col:$journal.detail.pat_main.charge_staff_info.is_main,const:0" IsCharge="col:$journal.detail.pat_main.charge_staff_info.is_charge,const:1" isPuncture="col:$journal.detail.pat_main.charge_staff_info.is_puncture,const:0"></DialysisDoctor>', '{}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-503000003, 'S_hosp', 'profile', 'R', '透析看護師', 'all', 'SSI_患者属性連携', '患者情報受信', '1', '<DialysisNurse Code="col:$journal.detail.pat_main.charge_staff_info.staff_cd" IsMain="col:$journal.detail.pat_main.charge_staff_info.is_main,const:0" IsCharge="col:$journal.detail.pat_main.charge_staff_info.is_charge,const:0" isPuncture="col:$journal.detail.pat_main.charge_staff_info.is_puncture,const:1"></DialysisNurse>', '{}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-503000004, 'S_hosp', 'profile', 'R', '入院主治医', 'all', 'SSI_患者属性連携', '患者情報受信', '1', '<AdmissionDoctor Code="col:$journal.detail.pat_main.charge_staff_info.staff_cd" IsMain="col:$journal.detail.pat_main.charge_staff_info.is_main,const:1" IsCharge="col:$journal.detail.pat_main.charge_staff_info.is_charge,const:0" isPuncture="col:$journal.detail.pat_main.charge_staff_info.is_puncture,const:0"></AdmissionDoctor>', '{}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-503000005, 'S_hosp', 'profile', 'R', '感染症情報', 'all', 'SSI_患者属性連携', '患者情報受信', '1', '<Infection Code="col:$journal.detail.pat_main_2.infect_info.infection_cd,default:NoXmlTag">
    col:$journal.detail.pat_main_2.infect_info.infection_name,default:NoXmlTag
  <Status>col:$journal.detail.pat_main_2.infect_info.infect</Status>
  <Comment/>
  <!-- 連携対象外 -->
  <Date>col:$journal.detail.pat_main_2.infect_info.exam_date,default:NoXmlTag</Date>
</Infection>
', '{}'::jsonb, '1', '0', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-503000006, 'S_hosp', 'profile', 'R', 'アレルギー情報', 'all', 'SSI_患者属性連携', '患者情報受信', '1', '<Allergy Code="col:$journal.detail.pat_main_1.taboo_allergy_info.taboo_allergy_cd">
  col:$journal.detail.pat_main_1.taboo_allergy_info.content
  <Status>col:$journal.detail.pat_main_1.taboo_allergy_info.status</Status>
  <Comment>col:$journal.detail.pat_main_1.taboo_allergy_info.memo</Comment>
  <Date/>
  <!-- 連携対象外 -->
</Allergy>
', '{}'::jsonb, '1', '0', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-503000007, 'S_hosp', 'profile', 'R', '薬剤アレルギー情報', 'all', 'SSI_患者属性連携', '患者情報受信', '1', '<Drug Code="col:$journal.detail.pat_main_4.taboo_allergy_info.taboo_allergy_cd">
      col:$journal.detail.pat_main_4.taboo_allergy_info.content
  <Status>col:$journal.detail.pat_main_4.taboo_allergy_info.status</Status>
  <Comment>col:$journal.detail.pat_main_4.taboo_allergy_info.memo</Comment>
</Drug>
', '{}'::jsonb, '1', '0', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-504000001, 'S_hosp', 'ind_dial', 'S', '医材詳細', '血液回路', 'SSI', '予約送信(★無効設定。mst_coop_layoutに設定内容を移動しました。)', '1', '		<EQUIP_INFO CTL_NO="dataset:-305.cost_no">
			<EQUIP_CD>dataset:-305.e01</EQUIP_CD>
			<EQUIP_NAME>dataset:-305.e02</EQUIP_NAME>
			<EQUIP_CLASS_NAME>dataset:-305.e03</EQUIP_CLASS_NAME>
			<AMOUNT>dataset:-305.e04</AMOUNT>
			<UNIT>dataset:-305.e05</UNIT>
		</EQUIP_INFO>', '{}'::jsonb, '1', '1', 4, '2020-05-22 10:00:23.169', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-504000002, 'S_hosp', 'ind_dial', 'S', '医材詳細', '穿刺針', 'SSI', '予約送信(★無効設定。mst_coop_layoutに設定内容を移動しました。)', '1', '		<EQUIP_INFO CTL_NO="dataset:-305.cost_no">
			<EQUIP_CD>dataset:-305.e01</EQUIP_CD>
			<EQUIP_NAME>dataset:-305.e02</EQUIP_NAME>
			<EQUIP_CLASS_NAME>dataset:-305.e03</EQUIP_CLASS_NAME>
			<AMOUNT>dataset:-305.e04</AMOUNT>
			<UNIT>dataset:-305.e05</UNIT>
		</EQUIP_INFO>', '{}'::jsonb, '1', '1', 4, '2020-05-22 10:00:23.169', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-504000003, 'S_hosp', 'ind_dial', 'S', '薬剤詳細', '投与薬剤', 'SSI', '予約送信(★無効設定。mst_coop_layoutに設定内容を移動しました。)', '1', '		<MEDI_INFO CTL_NO="dataset:-306.cost_no">
			<MEDICINE_CD>dataset:-306.e01</MEDICINE_CD>
			<MEDICINE_NAME>dataset:-306.e02</MEDICINE_NAME>
			<MEDI_CLASS_NAME>dataset:-306.e03</MEDI_CLASS_NAME>
			<AMOUNT>dataset:-306.e04</AMOUNT>
			<UNIT>dataset:-306.e05</UNIT>
			<PROCEDURE_CD>dataset:-306.e06</PROCEDURE_CD>
			<PROCEDURE_NAME>dataset:-306.e07</PROCEDURE_NAME>
		</MEDI_INFO>', '{}'::jsonb, '1', '1', 4, '2020-05-22 12:45:38.325', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-504000004, 'S_hosp', 'ind_dial', 'S', '医材詳細', '医材', 'SSI', '予約送信(★無効設定。mst_coop_layoutに設定内容を移動しました。)', '1', '		<EQUIP_INFO CTL_NO="dataset:-305.cost_no">
			<EQUIP_CD>dataset:-305.e01</EQUIP_CD>
			<EQUIP_NAME>dataset:-305.e02</EQUIP_NAME>
			<EQUIP_CLASS_NAME>dataset:-305.e03</EQUIP_CLASS_NAME>
			<AMOUNT>dataset:-305.e04</AMOUNT>
			<UNIT>dataset:-305.e05</UNIT>
		</EQUIP_INFO>', '{}'::jsonb, '1', '1', 4, '2020-05-22 10:00:23.169', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-504000005, 'S_hosp', 'ind_dial', 'S', '条件詳細', '透析条件', 'SSI', '予約送信(★無効設定。mst_coop_layoutに設定内容を移動しました。)', '1', '		<COND_INFO CTL_NO="dataset:-307.e01">
			<DIALYSIS_ITEM_NAME>dataset:-307.e02</DIALYSIS_ITEM_NAME>
			<VALUE>dataset:-307.e03</VALUE>
			<VALUE_NAME>dataset:-307.e04</VALUE_NAME>
			<UNIT>dataset:-307.e05</UNIT>
		</COND_INFO>', '{}'::jsonb, '1', '1', 4, '2020-05-22 12:45:38.325', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-507000001, 'S_hosp', 'rst_dial', 'S', '条件詳細', '透析条件', 'SSI', '実績送信(★無効設定。mst_coop_layoutに設定内容を移動しました。)', '1', '<root>
		<COND_INFO CTL_NO="dataset:-304.e01">
			<DIALYSIS_ITEM_NAME>dataset:-304.e02</DIALYSIS_ITEM_NAME>
			<VALUE>dataset:-304.e03</VALUE>
			<VALUE_NAME>dataset:-304.e04</VALUE_NAME>
			<UNIT>dataset:-304.e05</UNIT>
		</COND_INFO>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-22 12:45:38.325', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-507000002, 'S_hosp', 'rst_dial', 'S', '薬剤詳細', '処置薬剤', 'SSI', '実績送信(★無効設定。mst_coop_layoutに設定内容を移動しました。)', '1', '<root>
		<MEDI_INFO CTL_NO="dataset:-303.cost_no">
			<MEDICINE_CD>dataset:-303.e01</MEDICINE_CD>
			<MEDICINE_NAME>dataset:-303.e02</MEDICINE_NAME>
			<MEDI_CLASS_NAME>dataset:-303.e03</MEDI_CLASS_NAME>
			<AMOUNT>dataset:-303.e04</AMOUNT>
			<UNIT>dataset:-303.e05</UNIT>
			<!-- <PROCEDURE_CD>dataset:-303.e06</PROCEDURE_CD> -->
			<PROCEDURE_NAME>dataset:-303.e07</PROCEDURE_NAME>
		</MEDI_INFO>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-22 12:45:38.325', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-507000003, 'S_hosp', 'rst_dial', 'S', '薬剤詳細', '投与薬剤', 'SSI', '実績送信(★無効設定。mst_coop_layoutに設定内容を移動しました。)', '1', '<root>
		<MEDI_INFO CTL_NO="dataset:-303.cost_no">
			<MEDICINE_CD>dataset:-303.e01</MEDICINE_CD>
			<MEDICINE_NAME>dataset:-303.e02</MEDICINE_NAME>
			<MEDI_CLASS_NAME>dataset:-303.e03</MEDI_CLASS_NAME>
			<AMOUNT>dataset:-303.e04</AMOUNT>
			<UNIT>dataset:-303.e05</UNIT>
			<!-- <PROCEDURE_CD>dataset:-303.e06</PROCEDURE_CD> -->
			<PROCEDURE_NAME>dataset:-303.e07</PROCEDURE_NAME>
		</MEDI_INFO>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-22 12:45:38.325', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-507000004, 'S_hosp', 'rst_dial', 'S', '医材詳細', '医材', 'SSI', '実績送信(★無効設定。mst_coop_layoutに設定内容を移動しました。)', '1', '<root>
		<EQUIP_INFO CTL_NO="dataset:-302.cost_no">
			<EQUIP_CD>dataset:-302.e01</EQUIP_CD>
			<EQUIP_NAME>dataset:-302.e02</EQUIP_NAME>
			<EQUIP_CLASS_NAME>dataset:-302.e03</EQUIP_CLASS_NAME>
			<AMOUNT>dataset:-302.e04</AMOUNT>
			<UNIT>dataset:-302.e05</UNIT>
		</EQUIP_INFO>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-22 10:00:23.169', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-507000005, 'S_hosp', 'rst_dial', 'S', '医材詳細', '穿刺針', 'SSI', '実績送信(★無効設定。mst_coop_layoutに設定内容を移動しました。)', '1', '<root>
		<EQUIP_INFO CTL_NO="dataset:-302.cost_no">
			<EQUIP_CD>dataset:-302.e01</EQUIP_CD>
			<EQUIP_NAME>dataset:-302.e02</EQUIP_NAME>
			<EQUIP_CLASS_NAME>dataset:-302.e03</EQUIP_CLASS_NAME>
			<AMOUNT>dataset:-302.e04</AMOUNT>
			<UNIT>dataset:-302.e05</UNIT>
		</EQUIP_INFO>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-22 10:00:23.169', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-507000006, 'S_hosp', 'rst_dial', 'S', '医材詳細', '血液回路', 'SSI', '実績送信(★無効設定。mst_coop_layoutに設定内容を移動しました。)', '1', '<root>
		<EQUIP_INFO CTL_NO="dataset:-302.cost_no">
			<EQUIP_CD>dataset:-302.e01</EQUIP_CD>
			<EQUIP_NAME>dataset:-302.e02</EQUIP_NAME>
			<EQUIP_CLASS_NAME>dataset:-302.e03</EQUIP_CLASS_NAME>
			<AMOUNT>dataset:-302.e04</AMOUNT>
			<UNIT>dataset:-302.e05</UNIT>
		</EQUIP_INFO>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-22 10:00:23.169', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-507000007, 'S_hosp', 'rst_dial', 'S', '処置詳細', '酸素吸入量', 'SSI', '実績送信(★無効設定。mst_coop_layoutに設定内容を移動しました。)', '1', '<root>
		<DISPOSE_INFO DISPOSE_CTL_NO="dataset:-301.cost_no">
			<TENCD>dataset:-301.e01</TENCD>
			<TKJNAM>dataset:-301.e02</TKJNAM>
			<AMOUNT>dataset:-301.e03</AMOUNT>
			<UNIT>dataset:-301.e04</UNIT>
		</DISPOSE_INFO>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-22 10:00:23.169', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-507000008, 'S_hosp', 'rst_dial', 'S', '処置詳細', '処置材料', 'SSI', '実績送信(★無効設定。mst_coop_layoutに設定内容を移動しました。)', '1', '<root>
		<DISPOSE_INFO DISPOSE_CTL_NO="dataset:-301.cost_no">
			<TENCD>dataset:-301.e01</TENCD>
			<TKJNAM>dataset:-301.e02</TKJNAM>
			<AMOUNT>dataset:-301.e03</AMOUNT>
			<UNIT>dataset:-301.e04</UNIT>
		</DISPOSE_INFO>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-22 10:00:23.169', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-507000009, 'S_hosp', 'rst_dial', 'S', '処置詳細', '酸素手技', 'SSI', '実績送信(★無効設定。mst_coop_layoutに設定内容を移動しました。)', '1', '<root>
		<DISPOSE_INFO DISPOSE_CTL_NO="dataset:-301.cost_no">
			<TENCD>dataset:-301.e01</TENCD>
			<TKJNAM>dataset:-301.e02</TKJNAM>
			<AMOUNT>dataset:-301.e03</AMOUNT>
			<UNIT></UNIT>
		</DISPOSE_INFO>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-22 10:00:20.531', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-507000010, 'S_hosp', 'rst_dial', 'S', '処置詳細', '処置行為', 'SSI', '実績送信(★無効設定。mst_coop_layoutに設定内容を移動しました。)', '1', '<root>
		<DISPOSE_INFO DISPOSE_CTL_NO="dataset:-301.cost_no">
			<TENCD>dataset:-301.e01</TENCD>
			<TKJNAM>dataset:-301.e02</TKJNAM>
			<AMOUNT>dataset:-301.e03</AMOUNT>
			<UNIT></UNIT>
		</DISPOSE_INFO>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-22 10:00:17.365', CURRENT_TIMESTAMP, 'SSI');