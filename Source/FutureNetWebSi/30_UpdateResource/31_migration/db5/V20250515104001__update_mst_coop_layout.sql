DELETE FROM mst_coop_layout WHERE ctl_no IN (-5040001, -5040002, -5040003);

INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5040001, 'S_hosp', 'ind_dial', '', 'S', 'cre', 'xml', 'SSI', 'SSI', '予定送信', '1', '<SsiData Type="DIALYSISPLAN">
  <PlanData>
    <PatientID>dataset:-500001.hosp_pat_id8</PatientID>
    <DIALYSIS_DATE>dataset:-503000.dialysis_date</DIALYSIS_DATE>
    <DIALYSIS_NO>0</DIALYSIS_NO>
    <BED_NO>dataset:-503000.bed_cd1</BED_NO>
    <BED_NAME>dataset:-503000.bed_name</BED_NAME>
    <KUR_CD>dataset:-503000.kur_cd1</KUR_CD>
    <KUR_NAME>dataset:-503000.kur_name</KUR_NAME>
    <VALID>0</VALID>
    <DIALYSIS_TIME>dataset:-503000.dialysis_time_m</DIALYSIS_TIME>
    <DIALYSIS_COND info="透析条件情報">
      <COND_INFO CTL_NO="dataset:-501106.e01" _sqlCode="-501106">
        <DIALYSIS_ITEM_NAME>dataset:-501106.e02</DIALYSIS_ITEM_NAME>
        <VALUE>dataset:-501106.e03</VALUE>
        <VALUE_NAME>dataset:-501106.e04</VALUE_NAME>
        <UNIT>dataset:-501106.e05</UNIT>
      </COND_INFO>
    </DIALYSIS_COND>
    <DIALYSIS_EQUIP info="医材詳細">
      <EQUIP_INFO CTL_NO="dataset:-501104.cost_no" _sqlCode="-501104">
        <EQUIP_CD>dataset:-501104.e01</EQUIP_CD>
        <EQUIP_NAME>dataset:-501104.e02</EQUIP_NAME>
        <EQUIP_CLASS_NAME>dataset:-501104.e03</EQUIP_CLASS_NAME>
        <PUNCTURE_CLASS>dataset:-501104.e04</PUNCTURE_CLASS>
        <AMOUNT>dataset:-501104.e05</AMOUNT>
        <UNIT>dataset:-501104.e06</UNIT>
      </EQUIP_INFO>
    </DIALYSIS_EQUIP>
    <DIALYSIS_MEDI info="薬剤詳細">
      <MEDI_INFO CTL_NO="dataset:-501105.cost_no" _sqlCode="-501105">
        <MEDICINE_CD>dataset:-501105.e01</MEDICINE_CD>
        <MEDICINE_NAME>dataset:-501105.e02</MEDICINE_NAME>
        <MEDI_CLASS_NAME>dataset:-501105.e03</MEDI_CLASS_NAME>
        <AMOUNT>dataset:-501105.e04</AMOUNT>
        <UNIT>dataset:-501105.e05</UNIT>
        <PROCEDURE_CD>dataset:-501105.e06</PROCEDURE_CD>
        <PROCEDURE_NAME>dataset:-501105.e07</PROCEDURE_NAME>
      </MEDI_INFO>
    </DIALYSIS_MEDI>
  </PlanData>
</SsiData>
', '{"dataset": [{"patId": "patId", "sqlCode": -500001}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -503000, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -501104, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -501105, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -501106, "facilityCd": "facilityCd"}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99989}}'::jsonb, '1', '0', 4, '2020-05-25 11:02:55.825', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5040002, 'S_hosp', 'ind_dial', '', 'S', 'upd', 'xml', 'SSI', 'SSI', '予定送信', '1', '<SsiData Type="DIALYSISPLAN">
  <PlanData>
    <PatientID>dataset:-500001.hosp_pat_id8</PatientID>
    <DIALYSIS_DATE>dataset:-503000.dialysis_date</DIALYSIS_DATE>
    <DIALYSIS_NO>0</DIALYSIS_NO>
    <BED_NO>dataset:-503000.bed_cd1</BED_NO>
    <BED_NAME>dataset:-503000.bed_name</BED_NAME>
    <KUR_CD>dataset:-503000.kur_cd1</KUR_CD>
    <KUR_NAME>dataset:-503000.kur_name</KUR_NAME>
    <VALID>1</VALID>
    <DIALYSIS_TIME>dataset:-503000.dialysis_time_m</DIALYSIS_TIME>
    <DIALYSIS_COND info="透析条件情報">
      <COND_INFO CTL_NO="dataset:-501106.e01" _sqlCode="-501106">
        <DIALYSIS_ITEM_NAME>dataset:-501106.e02</DIALYSIS_ITEM_NAME>
        <VALUE>dataset:-501106.e03</VALUE>
        <VALUE_NAME>dataset:-501106.e04</VALUE_NAME>
        <UNIT>dataset:-501106.e05</UNIT>
      </COND_INFO>
    </DIALYSIS_COND>
    <DIALYSIS_EQUIP info="医材詳細">
      <EQUIP_INFO CTL_NO="dataset:-501104.cost_no" _sqlCode="-501104">
        <EQUIP_CD>dataset:-501104.e01</EQUIP_CD>
        <EQUIP_NAME>dataset:-501104.e02</EQUIP_NAME>
        <EQUIP_CLASS_NAME>dataset:-501104.e03</EQUIP_CLASS_NAME>
        <PUNCTURE_CLASS>dataset:-501104.e04</PUNCTURE_CLASS>
        <AMOUNT>dataset:-501104.e05</AMOUNT>
        <UNIT>dataset:-501104.e06</UNIT>
      </EQUIP_INFO>
    </DIALYSIS_EQUIP>
    <DIALYSIS_MEDI info="薬剤詳細">
      <MEDI_INFO CTL_NO="dataset:-501105.cost_no" _sqlCode="-501105">
        <MEDICINE_CD>dataset:-501105.e01</MEDICINE_CD>
        <MEDICINE_NAME>dataset:-501105.e02</MEDICINE_NAME>
        <MEDI_CLASS_NAME>dataset:-501105.e03</MEDI_CLASS_NAME>
        <AMOUNT>dataset:-501105.e04</AMOUNT>
        <UNIT>dataset:-501105.e05</UNIT>
        <PROCEDURE_CD>dataset:-501105.e06</PROCEDURE_CD>
        <PROCEDURE_NAME>dataset:-501105.e07</PROCEDURE_NAME>
      </MEDI_INFO>
    </DIALYSIS_MEDI>
  </PlanData>
</SsiData>
', '{"dataset": [{"patId": "patId", "sqlCode": -500001}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -503000, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -501104, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -501105, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -501106, "facilityCd": "facilityCd"}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99989}}'::jsonb, '1', '0', 4, '2020-05-25 11:02:55.825', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5040003, 'S_hosp', 'ind_dial', '', 'S', 'del', 'xml', 'SSI', 'SSI', '予定送信', '1', '<SsiData Type="DIALYSISPLAN">
  <PlanData>
    <PatientID>dataset:-500001.hosp_pat_id8</PatientID>
    <DIALYSIS_DATE>dataset:-503000.dialysis_date</DIALYSIS_DATE>
    <DIALYSIS_NO>0</DIALYSIS_NO>
    <BED_NO>dataset:-503000.bed_cd1</BED_NO>
    <BED_NAME>dataset:-503000.bed_name</BED_NAME>
    <KUR_CD>dataset:-503000.kur_cd1</KUR_CD>
    <KUR_NAME>dataset:-503000.kur_name</KUR_NAME>
    <VALID>9</VALID>
    <DIALYSIS_TIME>dataset:-503000.dialysis_time_m</DIALYSIS_TIME>
    <DIALYSIS_COND info="透析条件情報">
      <COND_INFO CTL_NO="dataset:-501106.e01" _sqlCode="-501106">
        <DIALYSIS_ITEM_NAME>dataset:-501106.e02</DIALYSIS_ITEM_NAME>
        <VALUE>dataset:-501106.e03</VALUE>
        <VALUE_NAME>dataset:-501106.e04</VALUE_NAME>
        <UNIT>dataset:-501106.e05</UNIT>
      </COND_INFO>
    </DIALYSIS_COND>
    <DIALYSIS_EQUIP info="医材詳細">
      <EQUIP_INFO CTL_NO="dataset:-501104.cost_no" _sqlCode="-501104">
        <EQUIP_CD>dataset:-501104.e01</EQUIP_CD>
        <EQUIP_NAME>dataset:-501104.e02</EQUIP_NAME>
        <EQUIP_CLASS_NAME>dataset:-501104.e03</EQUIP_CLASS_NAME>
        <PUNCTURE_CLASS>dataset:-501104.e04</PUNCTURE_CLASS>
        <AMOUNT>dataset:-501104.e05</AMOUNT>
        <UNIT>dataset:-501104.e06</UNIT>
      </EQUIP_INFO>
    </DIALYSIS_EQUIP>
    <DIALYSIS_MEDI info="薬剤詳細">
      <MEDI_INFO CTL_NO="dataset:-501105.cost_no" _sqlCode="-501105">
        <MEDICINE_CD>dataset:-501105.e01</MEDICINE_CD>
        <MEDICINE_NAME>dataset:-501105.e02</MEDICINE_NAME>
        <MEDI_CLASS_NAME>dataset:-501105.e03</MEDI_CLASS_NAME>
        <AMOUNT>dataset:-501105.e04</AMOUNT>
        <UNIT>dataset:-501105.e05</UNIT>
        <PROCEDURE_CD>dataset:-501105.e06</PROCEDURE_CD>
        <PROCEDURE_NAME>dataset:-501105.e07</PROCEDURE_NAME>
      </MEDI_INFO>
    </DIALYSIS_MEDI>
  </PlanData>
</SsiData>
', '{"dataset": [{"patId": "patId", "sqlCode": -500001}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -503000, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -501104, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -501105, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -501106, "facilityCd": "facilityCd"}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99989}}'::jsonb, '1', '0', 4, '2020-05-25 11:02:55.825', CURRENT_TIMESTAMP, 'SSI');