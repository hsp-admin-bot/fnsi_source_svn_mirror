DELETE FROM mst_coop_layout WHERE ctl_no IN (
  -5070001, -5070002, -5070003
  );

INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5070001, 'S_hosp', 'rst_dial', '', 'S', 'cre', 'xml', 'SSI', 'SSI', '実績送信', '1', '<SsiData Type="DIALYSISRST">
  <RSTData>
    <PatientID>dataset:-500001.hosp_pat_id8</PatientID>
    <DIALYSIS_DATE>dataset:-504000.treat_date</DIALYSIS_DATE>
    <DIALYSIS_NO>dataset:-504000.ord_no</DIALYSIS_NO>
    <BED_NO>dataset:-504000.bed_cd1</BED_NO>
    <BED_NAME>dataset:-504000.bed_name</BED_NAME>
    <KUR_CD>dataset:-504000.kur_cd1</KUR_CD>
    <KUR_NAME>dataset:-504000.kur_name</KUR_NAME>
    <VALID>0</VALID>
    <DEVICE_NO>dataset:-504000.machine_no</DEVICE_NO>
    <DEVICE_NAME>dataset:-504000.machine_name</DEVICE_NAME>
    <START_DATE>dataset:-504000.start_date</START_DATE>
    <END_DATE>dataset:-504000.end_date</END_DATE>
    <DIALYSIS_TIME>dataset:-504000.running_time_cal</DIALYSIS_TIME>
    <WEIGHT_BEFORE>dataset:-504000.weight_before</WEIGHT_BEFORE>
    <WEIGHT_AFTER>dataset:-504000.weight_after</WEIGHT_AFTER>
    <BP_BEFORE_MAX>dataset:-35.bp_high</BP_BEFORE_MAX>
    <BP_BEFORE_MIN>dataset:-35.bp_low</BP_BEFORE_MIN>
    <BP_AFTER_MAX>dataset:-36.bp_high</BP_AFTER_MAX>
    <BP_AFTER_MIN>dataset:-36.bp_low</BP_AFTER_MIN>
    <PULSE_BEFORE>dataset:-35.pulse</PULSE_BEFORE>
    <PULSE_AFTER>dataset:-36.pulse</PULSE_AFTER>
    <CHARGE_1_CODE>auth_id:-504000.charge1_id</CHARGE_1_CODE>
    <CHARGE_1_NAME>dataset:-504000.charge1_name</CHARGE_1_NAME>
    <CHARGE_2_CODE>auth_id:-504000.charge2_id</CHARGE_2_CODE>
    <CHARGE_2_NAME>dataset:-504000.charge2_name</CHARGE_2_NAME>
    <PUNCTURE_1_CODE>auth_id:-504000.puncture1_id</PUNCTURE_1_CODE>
    <PUNCTURE_1_NAME>dataset:-504000.puncture1_name</PUNCTURE_1_NAME>
    <PUNCTURE_2_CODE>auth_id:-504000.puncture2_id</PUNCTURE_2_CODE>
    <PUNCTURE_2_NAME>dataset:-504000.puncture2_name</PUNCTURE_2_NAME>
    <COLLECT_1_CODE>auth_id:-504000.return1_id</COLLECT_1_CODE>
    <COLLECT_1_NAME>dataset:-504000.return1_name</COLLECT_1_NAME>
    <COLLECT_2_CODE>auth_id:-504000.return2_id</COLLECT_2_CODE>
    <COLLECT_2_NAME>dataset:-504000.return2_name</COLLECT_2_NAME>
    <DISPOSE info="処置、検査情報">
      <DISPOSE_INFO DISPOSE_CTL_NO="dataset:-301.cost_no" _sqlCode="-301">
        <TENCD>dataset:-301.e01</TENCD>
        <TKJNAM>dataset:-301.e02</TKJNAM>
        <AMOUNT>dataset:-301.e03</AMOUNT>
        <UNIT>dataset:-301.e04</UNIT>
      </DISPOSE_INFO>
    </DISPOSE>
    <DIALYSIS_COND info="透析条件情報">
      <COND_INFO CTL_NO="dataset:-504001.e01" _sqlCode="-504001">
        <DIALYSIS_ITEM_NAME>dataset:-504001.e02</DIALYSIS_ITEM_NAME>
        <VALUE>dataset:-504001.e03</VALUE>
        <VALUE_NAME>dataset:-504001.e04</VALUE_NAME>
        <UNIT>dataset:-504001.e05</UNIT>
      </COND_INFO>
    </DIALYSIS_COND>
    <DIALYSIS_EQUIP info="医材詳細">
      <EQUIP_INFO CTL_NO="dataset:-501102.cost_no" _sqlCode="-501102">
        <EQUIP_CD>dataset:-501102.e01</EQUIP_CD>
        <EQUIP_NAME>dataset:-501102.e02</EQUIP_NAME>
        <EQUIP_CLASS_NAME>dataset:-501102.e03</EQUIP_CLASS_NAME>
        <PUNCTURE_CLASS>dataset:-501102.e04</PUNCTURE_CLASS>
        <AMOUNT>dataset:-501102.e05</AMOUNT>
        <UNIT>dataset:-501102.e06</UNIT>
      </EQUIP_INFO>
    </DIALYSIS_EQUIP>
    <DIALYSIS_MEDI info="薬剤詳細">
      <MEDI_INFO CTL_NO="dataset:-501103.cost_no" _sqlCode="-501103">
        <MEDICINE_CD>dataset:-501103.e01</MEDICINE_CD>
        <MEDICINE_NAME>dataset:-501103.e02</MEDICINE_NAME>
        <MEDI_CLASS_NAME>dataset:-501103.e03</MEDI_CLASS_NAME>
        <AMOUNT>dataset:-501103.e04</AMOUNT>
        <UNIT>dataset:-501103.e05</UNIT>
        <PROCEDURE_CD>dataset:-501103.e06</PROCEDURE_CD>
        <PROCEDURE_NAME>dataset:-501103.e07</PROCEDURE_NAME>
      </MEDI_INFO>
    </DIALYSIS_MEDI>
  </RSTData>
</SsiData>
', '{"dataset": [{"patId": "patId", "sqlCode": -500001}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -504002, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -504000, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -35}, {"ordNo": "ordNo", "sqlCode": -36}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -301, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -501102, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -501103, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -504001}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99988}}'::jsonb, '1', '0', -1, '2020-05-22 09:38:28.418', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5070002, 'S_hosp', 'rst_dial', '', 'S', 'upd', 'xml', 'SSI', 'SSI', '実績送信', '1', '<SsiData Type="DIALYSISRST">
  <RSTData>
    <PatientID>dataset:-500001.hosp_pat_id8</PatientID>
    <DIALYSIS_DATE>dataset:-504000.treat_date</DIALYSIS_DATE>
    <DIALYSIS_NO>dataset:-504000.ord_no</DIALYSIS_NO>
    <BED_NO>dataset:-504000.bed_cd1</BED_NO>
    <BED_NAME>dataset:-504000.bed_name</BED_NAME>
    <KUR_CD>dataset:-504000.kur_cd1</KUR_CD>
    <KUR_NAME>dataset:-504000.kur_name</KUR_NAME>
    <VALID>1</VALID>
    <DEVICE_NO>dataset:-504000.machine_no</DEVICE_NO>
    <DEVICE_NAME>dataset:-504000.machine_name</DEVICE_NAME>
    <START_DATE>dataset:-504000.start_date</START_DATE>
    <END_DATE>dataset:-504000.end_date</END_DATE>
    <DIALYSIS_TIME>dataset:-504000.running_time_cal</DIALYSIS_TIME>
    <WEIGHT_BEFORE>dataset:-504000.weight_before</WEIGHT_BEFORE>
    <WEIGHT_AFTER>dataset:-504000.weight_after</WEIGHT_AFTER>
    <BP_BEFORE_MAX>dataset:-35.bp_high</BP_BEFORE_MAX>
    <BP_BEFORE_MIN>dataset:-35.bp_low</BP_BEFORE_MIN>
    <BP_AFTER_MAX>dataset:-36.bp_high</BP_AFTER_MAX>
    <BP_AFTER_MIN>dataset:-36.bp_low</BP_AFTER_MIN>
    <PULSE_BEFORE>dataset:-35.pulse</PULSE_BEFORE>
    <PULSE_AFTER>dataset:-36.pulse</PULSE_AFTER>
    <CHARGE_1_CODE>auth_id:-504000.charge1_id</CHARGE_1_CODE>
    <CHARGE_1_NAME>dataset:-504000.charge1_name</CHARGE_1_NAME>
    <CHARGE_2_CODE>auth_id:-504000.charge2_id</CHARGE_2_CODE>
    <CHARGE_2_NAME>dataset:-504000.charge2_name</CHARGE_2_NAME>
    <PUNCTURE_1_CODE>auth_id:-504000.puncture1_id</PUNCTURE_1_CODE>
    <PUNCTURE_1_NAME>dataset:-504000.puncture1_name</PUNCTURE_1_NAME>
    <PUNCTURE_2_CODE>auth_id:-504000.puncture2_id</PUNCTURE_2_CODE>
    <PUNCTURE_2_NAME>dataset:-504000.puncture2_name</PUNCTURE_2_NAME>
    <COLLECT_1_CODE>auth_id:-504000.return1_id</COLLECT_1_CODE>
    <COLLECT_1_NAME>dataset:-504000.return1_name</COLLECT_1_NAME>
    <COLLECT_2_CODE>auth_id:-504000.return2_id</COLLECT_2_CODE>
    <COLLECT_2_NAME>dataset:-504000.return2_name</COLLECT_2_NAME>
    <DISPOSE info="処置、検査情報">
      <DISPOSE_INFO DISPOSE_CTL_NO="dataset:-301.cost_no" _sqlCode="-301">
        <TENCD>dataset:-301.e01</TENCD>
        <TKJNAM>dataset:-301.e02</TKJNAM>
        <AMOUNT>dataset:-301.e03</AMOUNT>
        <UNIT>dataset:-301.e04</UNIT>
      </DISPOSE_INFO>
    </DISPOSE>
    <DIALYSIS_COND info="透析条件情報">
      <COND_INFO CTL_NO="dataset:-504001.e01" _sqlCode="-504001">
        <DIALYSIS_ITEM_NAME>dataset:-504001.e02</DIALYSIS_ITEM_NAME>
        <VALUE>dataset:-504001.e03</VALUE>
        <VALUE_NAME>dataset:-504001.e04</VALUE_NAME>
        <UNIT>dataset:-504001.e05</UNIT>
      </COND_INFO>
    </DIALYSIS_COND>
    <DIALYSIS_EQUIP info="医材詳細">
      <EQUIP_INFO CTL_NO="dataset:-501102.cost_no" _sqlCode="-501102">
        <EQUIP_CD>dataset:-501102.e01</EQUIP_CD>
        <EQUIP_NAME>dataset:-501102.e02</EQUIP_NAME>
        <EQUIP_CLASS_NAME>dataset:-501102.e03</EQUIP_CLASS_NAME>
        <PUNCTURE_CLASS>dataset:-501102.e04</PUNCTURE_CLASS>
        <AMOUNT>dataset:-501102.e05</AMOUNT>
        <UNIT>dataset:-501102.e06</UNIT>
      </EQUIP_INFO>
    </DIALYSIS_EQUIP>
    <DIALYSIS_MEDI info="薬剤詳細">
      <MEDI_INFO CTL_NO="dataset:-501103.cost_no" _sqlCode="-501103">
        <MEDICINE_CD>dataset:-501103.e01</MEDICINE_CD>
        <MEDICINE_NAME>dataset:-501103.e02</MEDICINE_NAME>
        <MEDI_CLASS_NAME>dataset:-501103.e03</MEDI_CLASS_NAME>
        <AMOUNT>dataset:-501103.e04</AMOUNT>
        <UNIT>dataset:-501103.e05</UNIT>
        <PROCEDURE_CD>dataset:-501103.e06</PROCEDURE_CD>
        <PROCEDURE_NAME>dataset:-501103.e07</PROCEDURE_NAME>
      </MEDI_INFO>
    </DIALYSIS_MEDI>
  </RSTData>
</SsiData>
', '{"dataset": [{"patId": "patId", "sqlCode": -500001}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -504000, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -35}, {"ordNo": "ordNo", "sqlCode": -36}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -301, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -501102, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -501103, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -504001}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99988}}'::jsonb, '1', '0', -1, '2020-05-22 09:38:28.418', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5070003, 'S_hosp', 'rst_dial', '', 'S', 'del', 'xml', 'SSI', 'SSI', '実績送信', '1', '<SsiData Type="DIALYSISRST">
  <RSTData>
    <PatientID>dataset:-500001.hosp_pat_id8</PatientID>
    <DIALYSIS_DATE>dataset:-504000.treat_date</DIALYSIS_DATE>
    <DIALYSIS_NO>dataset:-504000.ord_no</DIALYSIS_NO>
    <BED_NO>dataset:-504000.bed_cd1</BED_NO>
    <BED_NAME>dataset:-504000.bed_name</BED_NAME>
    <KUR_CD>dataset:-504000.kur_cd1</KUR_CD>
    <KUR_NAME>dataset:-504000.kur_name</KUR_NAME>
    <VALID>9</VALID>
    <DEVICE_NO>dataset:-504000.machine_no</DEVICE_NO>
    <DEVICE_NAME>dataset:-504000.machine_name</DEVICE_NAME>
    <START_DATE>dataset:-504000.start_date</START_DATE>
    <END_DATE>dataset:-504000.end_date</END_DATE>
    <DIALYSIS_TIME>dataset:-504000.running_time_cal</DIALYSIS_TIME>
    <WEIGHT_BEFORE>dataset:-504000.weight_before</WEIGHT_BEFORE>
    <WEIGHT_AFTER>dataset:-504000.weight_after</WEIGHT_AFTER>
    <BP_BEFORE_MAX>dataset:-35.bp_high</BP_BEFORE_MAX>
    <BP_BEFORE_MIN>dataset:-35.bp_low</BP_BEFORE_MIN>
    <BP_AFTER_MAX>dataset:-36.bp_high</BP_AFTER_MAX>
    <BP_AFTER_MIN>dataset:-36.bp_low</BP_AFTER_MIN>
    <PULSE_BEFORE>dataset:-35.pulse</PULSE_BEFORE>
    <PULSE_AFTER>dataset:-36.pulse</PULSE_AFTER>
    <CHARGE_1_CODE>auth_id:-504000.charge1_id</CHARGE_1_CODE>
    <CHARGE_1_NAME>dataset:-504000.charge1_name</CHARGE_1_NAME>
    <CHARGE_2_CODE>auth_id:-504000.charge2_id</CHARGE_2_CODE>
    <CHARGE_2_NAME>dataset:-504000.charge2_name</CHARGE_2_NAME>
    <PUNCTURE_1_CODE>auth_id:-504000.puncture1_id</PUNCTURE_1_CODE>
    <PUNCTURE_1_NAME>dataset:-504000.puncture1_name</PUNCTURE_1_NAME>
    <PUNCTURE_2_CODE>auth_id:-504000.puncture2_id</PUNCTURE_2_CODE>
    <PUNCTURE_2_NAME>dataset:-504000.puncture2_name</PUNCTURE_2_NAME>
    <COLLECT_1_CODE>auth_id:-504000.return1_id</COLLECT_1_CODE>
    <COLLECT_1_NAME>dataset:-504000.return1_name</COLLECT_1_NAME>
    <COLLECT_2_CODE>auth_id:-504000.return2_id</COLLECT_2_CODE>
    <COLLECT_2_NAME>dataset:-504000.return2_name</COLLECT_2_NAME>
    <DISPOSE info="処置、検査情報">
      <DISPOSE_INFO DISPOSE_CTL_NO="dataset:-301.cost_no" _sqlCode="-301">
        <TENCD>dataset:-301.e01</TENCD>
        <TKJNAM>dataset:-301.e02</TKJNAM>
        <AMOUNT>dataset:-301.e03</AMOUNT>
        <UNIT>dataset:-301.e04</UNIT>
      </DISPOSE_INFO>
    </DISPOSE>
    <DIALYSIS_COND info="透析条件情報">
      <COND_INFO CTL_NO="dataset:-504001.e01" _sqlCode="-504001">
        <DIALYSIS_ITEM_NAME>dataset:-504001.e02</DIALYSIS_ITEM_NAME>
        <VALUE>dataset:-504001.e03</VALUE>
        <VALUE_NAME>dataset:-504001.e04</VALUE_NAME>
        <UNIT>dataset:-504001.e05</UNIT>
      </COND_INFO>
    </DIALYSIS_COND>
    <DIALYSIS_EQUIP info="医材詳細">
      <EQUIP_INFO CTL_NO="dataset:-501102.cost_no" _sqlCode="-501102">
        <EQUIP_CD>dataset:-501102.e01</EQUIP_CD>
        <EQUIP_NAME>dataset:-501102.e02</EQUIP_NAME>
        <EQUIP_CLASS_NAME>dataset:-501102.e03</EQUIP_CLASS_NAME>
        <PUNCTURE_CLASS>dataset:-501102.e04</PUNCTURE_CLASS>
        <AMOUNT>dataset:-501102.e05</AMOUNT>
        <UNIT>dataset:-501102.e06</UNIT>
      </EQUIP_INFO>
    </DIALYSIS_EQUIP>
    <DIALYSIS_MEDI info="薬剤詳細">
      <MEDI_INFO CTL_NO="dataset:-501103.cost_no" _sqlCode="-501103">
        <MEDICINE_CD>dataset:-501103.e01</MEDICINE_CD>
        <MEDICINE_NAME>dataset:-501103.e02</MEDICINE_NAME>
        <MEDI_CLASS_NAME>dataset:-501103.e03</MEDI_CLASS_NAME>
        <AMOUNT>dataset:-501103.e04</AMOUNT>
        <UNIT>dataset:-501103.e05</UNIT>
        <PROCEDURE_CD>dataset:-501103.e06</PROCEDURE_CD>
        <PROCEDURE_NAME>dataset:-501103.e07</PROCEDURE_NAME>
      </MEDI_INFO>
    </DIALYSIS_MEDI>
  </RSTData>
</SsiData>
', '{"dataset": [{"patId": "patId", "sqlCode": -500001}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -504002, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -504000, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -35}, {"ordNo": "ordNo", "sqlCode": -36}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -301, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -501102, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -501103, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -504001}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99988}}'::jsonb, '1', '0', -1, '2020-05-22 09:38:28.418', CURRENT_TIMESTAMP, 'SSI');