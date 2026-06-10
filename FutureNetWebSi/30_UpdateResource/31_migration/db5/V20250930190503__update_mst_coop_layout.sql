DELETE FROM ntss.mst_coop_layout
WHERE ctl_no=-5070003;
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5070003, 'S_hosp', 'rst_dial', '', 'S', 'del', 'xml', 'SSI', 'SSI', '実績送信', '1', '<SsiData Type="DIALYSISRST">
  <RSTData>
    <PatientID>dataset:-504008.hosp_pat_id8</PatientID>
    <DIALYSIS_DATE>dataset:-504007.treat_date</DIALYSIS_DATE>
    <DIALYSIS_NO>dataset:-504007.ord_no</DIALYSIS_NO>
    <BED_NO>dataset:-504007.bed_cd1</BED_NO>
    <BED_NAME>dataset:-504007.bed_name</BED_NAME>
    <KUR_CD>dataset:-504007.kur_cd1</KUR_CD>
    <KUR_NAME>dataset:-504007.kur_name</KUR_NAME>
    <VALID>9</VALID>
    <DEVICE_NO>dataset:-504007.machine_no</DEVICE_NO>
    <DEVICE_NAME>dataset:-504007.machine_name</DEVICE_NAME>
    <START_DATE>dataset:-504007.start_date</START_DATE>
    <END_DATE>dataset:-504007.end_date</END_DATE>
    <DIALYSIS_TIME>dataset:-504007.running_time_cal</DIALYSIS_TIME>
    <WEIGHT_BEFORE>dataset:-504007.weight_before</WEIGHT_BEFORE>
    <WEIGHT_AFTER>dataset:-504007.weight_after</WEIGHT_AFTER>
    <BP_BEFORE_MAX>dataset:-504009.bp_high</BP_BEFORE_MAX>
    <BP_BEFORE_MIN>dataset:-504009.bp_low</BP_BEFORE_MIN>
    <BP_AFTER_MAX>dataset:-504010.bp_high</BP_AFTER_MAX>
    <BP_AFTER_MIN>dataset:-504010.bp_low</BP_AFTER_MIN>
    <PULSE_BEFORE>dataset:-504009.pulse</PULSE_BEFORE>
    <PULSE_AFTER>dataset:-504010.pulse</PULSE_AFTER>
    <CHARGE_1_CODE>auth_id:-504013.charge1_id</CHARGE_1_CODE>
    <CHARGE_1_NAME>dataset:-504013.charge1_name</CHARGE_1_NAME>
    <CHARGE_2_CODE>auth_id:-504013.charge2_id</CHARGE_2_CODE>
    <CHARGE_2_NAME>dataset:-504013.charge2_name</CHARGE_2_NAME>
    <PUNCTURE_1_CODE>auth_id:-504013.puncture1_id</PUNCTURE_1_CODE>
    <PUNCTURE_1_NAME>dataset:-504013.puncture1_name</PUNCTURE_1_NAME>
    <PUNCTURE_2_CODE>auth_id:-504013.puncture2_id</PUNCTURE_2_CODE>
    <PUNCTURE_2_NAME>dataset:-504013.puncture2_name</PUNCTURE_2_NAME>
    <COLLECT_1_CODE>auth_id:-504013.return1_id</COLLECT_1_CODE>
    <COLLECT_1_NAME>dataset:-504013.return1_name</COLLECT_1_NAME>
    <COLLECT_2_CODE>auth_id:-504013.return2_id</COLLECT_2_CODE>
    <COLLECT_2_NAME>dataset:-504013.return2_name</COLLECT_2_NAME>
    <DISPOSE info="処置、検査情報">
      <DISPOSE_INFO DISPOSE_CTL_NO="dataset:-504004.cost_no" _sqlCode="-504004">
        <TENCD>dataset:-504004.e01</TENCD>
        <TKJNAM>dataset:-504004.e02</TKJNAM>
        <AMOUNT>dataset:-504004.e03</AMOUNT>
        <UNIT>dataset:-504004.e04</UNIT>
      </DISPOSE_INFO>
    </DISPOSE>
    <DIALYSIS_COND info="透析条件情報">
      <COND_INFO CTL_NO="dataset:-504003.e01" _sqlCode="-504003">
        <DIALYSIS_ITEM_NAME>dataset:-504003.e02</DIALYSIS_ITEM_NAME>
        <VALUE>dataset:-504003.e03</VALUE>
        <VALUE_NAME>dataset:-504003.e04</VALUE_NAME>
        <UNIT>dataset:-504003.e05</UNIT>
      </COND_INFO>
    </DIALYSIS_COND>
    <DIALYSIS_EQUIP info="医材詳細">
      <EQUIP_INFO CTL_NO="dataset:-504005.cost_no" _sqlCode="-504005">
        <EQUIP_CD>dataset:-504005.e01</EQUIP_CD>
        <EQUIP_NAME>dataset:-504005.e02</EQUIP_NAME>
        <EQUIP_CLASS_NAME>dataset:-504005.e03</EQUIP_CLASS_NAME>
        <PUNCTURE_CLASS>dataset:-504005.e04</PUNCTURE_CLASS>
        <AMOUNT>dataset:-504005.e05</AMOUNT>
        <UNIT>dataset:-504005.e06</UNIT>
      </EQUIP_INFO>
    </DIALYSIS_EQUIP>
    <DIALYSIS_MEDI info="薬剤詳細">
      <MEDI_INFO CTL_NO="dataset:-504006.cost_no" _sqlCode="-504006">
        <MEDICINE_CD>dataset:-504006.e01</MEDICINE_CD>
        <MEDICINE_NAME>dataset:-504006.e02</MEDICINE_NAME>
        <MEDI_CLASS_NAME>dataset:-504006.e03</MEDI_CLASS_NAME>
        <AMOUNT>dataset:-504006.e04</AMOUNT>
        <UNIT>dataset:-504006.e05</UNIT>
        <PROCEDURE_CD>dataset:-504006.e06</PROCEDURE_CD>
        <PROCEDURE_NAME>dataset:-504006.e07</PROCEDURE_NAME>
      </MEDI_INFO>
    </DIALYSIS_MEDI>
  </RSTData>
</SsiData>
', '{"dataset": [{"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "comment": "単一行SQL: -504007 透析基本情報", "content": "content", "sqlCode": -504007, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "comment": "単一行SQL: -504008 患者個人情報（別スキーマ）", "sqlCode": -504008, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "comment": "単一行SQL: -504009 透析前バイタル", "content": "content", "sqlCode": -504009, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "comment": "単一行SQL: -504010 透析後バイタル", "content": "content", "sqlCode": -504010, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "comment": "単一行SQL: -504011 スタッフ情報", "content": "content", "sqlCode": -504011, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "comment": "複数行SQL: -504003 透析条件情報", "content": "content", "sqlCode": -504003, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "comment": "複数行SQL: -504004 処置・検査情報", "content": "content", "sqlCode": -504004, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "comment": "複数行SQL: -504005 医材詳細情報", "content": "content", "sqlCode": -504005, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "comment": "複数行SQL: -504006 薬剤詳細情報", "content": "content", "sqlCode": -504006, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "comment": "単一行SQL: -504013 ジャーナル取得", "content": "content", "sqlCode": -504013, "facilityCd": "facilityCd"}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99988}}'::jsonb, '1', '0', -1, '2020-05-22 09:38:28.418', '2025-06-19 10:57:10.408', 'SSI');