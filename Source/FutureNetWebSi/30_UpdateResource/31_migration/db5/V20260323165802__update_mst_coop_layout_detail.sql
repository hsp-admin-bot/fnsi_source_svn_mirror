DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no IN (-607000001,-607000003);

INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-607000001, 'C_hosp', 'rst_dial', 'S', 'medicine', '05', '調製薬剤使用薬剤繰り返し', 'CSI透析実績(透析条件)', '1', '<root>
  <!-- 6.投薬履歴 -->
  <CTL_NO>dataset:-604167.ctl_no</CTL_NO>
  <!-- 指示実施フラグ -->
  <EFFECT_FLG>dataset:-604167.effect_flg</EFFECT_FLG>
  <!-- 薬剤コード -->
  <SET_MEDICINE_CD>dataset:-604167.medicine_cd</SET_MEDICINE_CD>
  <!-- 手技コード -->
  <PROCEDURE_CD>dataset:-604167.procedure_cd</PROCEDURE_CD>
  <!-- 実施日 -->
  <EFFECT_DATE>dataset:-604167.effect_date</EFFECT_DATE>
  <!-- セット薬剤使用フラグ -->
  <SET_MEDICINE_FLG>dataset:-604167.set_medicine_flg</SET_MEDICINE_FLG>
  <!-- 使用量 -->
  <AMOUNT>dataset:-604167.amount</AMOUNT>
  <!-- 薬剤マスタ -->
  <MST_MEDICINE>
    <!-- 注射フラグ -->
    <SHOT>dataset:-604167.mmd_is_shot</SHOT>
    <!-- 薬剤コード(院内コード) -->
    <IN_HOSPITAL_CD>dataset:-604167.mmd_in_hospital_cd_1</IN_HOSPITAL_CD>
    <!-- 薬剤コード(院内コード2) -->
    <IN_HOSPITAL_CD2>dataset:-604167.mmd_in_hospital_cd_2</IN_HOSPITAL_CD2>
    <!-- 薬剤コード -->
    <MEDICINE_CD>dataset:-604167.mmd_medicine_cd</MEDICINE_CD>
    <!-- 薬剤グループコード -->
    <MEDICINE_GROUP_CD>dataset:-604167.class_cd</MEDICINE_GROUP_CD>
  </MST_MEDICINE>
  <!-- 手技マスタ -->
  <MST_PROCEDURE>
    <!-- ルート項目コード(院内コード) -->
    <IN_HOSPITAL_CD1>dataset:-604167.mp_in_hospital_cd_1</IN_HOSPITAL_CD1>
    <!-- 投与方法項目コード(院内コード) -->
    <IN_HOSPITAL_CD2>dataset:-604167.mp_in_hospital_cd_2</IN_HOSPITAL_CD2>
  </MST_PROCEDURE>
  <MST_SET_MEDI_NAME>
    <!-- ※NTSSに薬剤セットが無し -->
    <!-- 薬剤セットマスタ -->
    <MST_SET_MEDICINE _detail="medicine" _sqlCode="-604175">
    </MST_SET_MEDICINE>
    <!-- 院内コード２ -->
    <IN_HOSPITAL_CD2/>
  </MST_SET_MEDI_NAME>
</root>
', '{"dataset": [{"ctlNo": "-604174.ctl_no", "ordNo": "-604174.ord_no", "sqlCode": -604167}, {"ctlNo": "-604174.ctl_no", "ordNo": "-604174.ord_no", "sqlCode": -604175}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'CSI');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-607000003, 'C_hosp', 'rst_dial', 'S', 'medicine', '07', '調製薬剤使用薬剤繰り返し', 'CSI透析実績(透析条件)', '1', '<root>
  <!-- 7.愁訴処置 -->
  <!-- 薬剤コード -->
  <TREAT_MEDICINE_CD>dataset:-604168.medicine_cd</TREAT_MEDICINE_CD>
  <!-- 手技コード -->
  <PROCEDURE_CD>dataset:-604168.procedure_cd</PROCEDURE_CD>
  <!-- 入力数 -->
  <AMOUNT>dataset:-604168.amount</AMOUNT>
  <!-- 酸素吸入量(処置区分) -->
  <TREAT_CLASS>dataset:-604168.treat_class</TREAT_CLASS>
  <!-- 酸素吸入量(実績番号) -->
  <RESULT_NO>dataset:-604168.result_no</RESULT_NO>
  <!-- 酸素吸入量(発生日時) -->
  <OCCUR_DATE>dataset:-604168.occur_date_start</OCCUR_DATE>
  <!-- 酸素吸入量(使用量) -->
  <OXYGEN_AMOUNT>dataset:-604168.oxygen_amount</OXYGEN_AMOUNT>
  <!-- 酸素吸入量(酸素吸入開始日時) -->
  <OXYGEN_START>dataset:-604168.oxygen_start_new</OXYGEN_START>
  <!-- 酸素吸入量(酸素吸入時間) -->
  <OXYGEN_TIME>dataset:-604168.oxygen_time_new</OXYGEN_TIME>
  <!-- 薬剤マスタ -->
  <MST_MEDICINE>
    <!-- 注射フラグ -->
    <SHOT>dataset:-604168.mmd_is_shot</SHOT>
    <!-- 薬剤コード(院内コード) -->
    <IN_HOSPITAL_CD>dataset:-604168.mmd_in_hospital_cd_1</IN_HOSPITAL_CD>
    <!-- 薬剤コード(院内コード2) -->
    <IN_HOSPITAL_CD2>dataset:-604168.mmd_in_hospital_cd_2</IN_HOSPITAL_CD2>
    <!-- 薬剤コード -->
    <MEDICINE_CD>dataset:-604168.mmd_medicine_cd</MEDICINE_CD>
    <!-- 薬剤グループコード -->
    <MEDICINE_GROUP_CD>dataset:-604168.mmd_class_cd</MEDICINE_GROUP_CD>
  </MST_MEDICINE>
  <MST_PROCEDURE>
    <!-- ルート項目コード(院内コード) -->
    <IN_HOSPITAL_CD1>dataset:-604168.mp_in_hospital_cd_1</IN_HOSPITAL_CD1>
    <!-- 投与方法項目コード(院内コード) -->
    <IN_HOSPITAL_CD2>dataset:-604168.mp_in_hospital_cd_2</IN_HOSPITAL_CD2>
  </MST_PROCEDURE>
  <MST_SET_MEDI_NAME>
    <!-- ※NTSSに薬剤セットが無し -->
    <!-- 薬剤セットマスタ -->
    <MST_SET_MEDICINE _detail="medicine" _sqlCode="-604178">
    </MST_SET_MEDICINE>
    <!-- 院内コード２ -->
    <IN_HOSPITAL_CD2></IN_HOSPITAL_CD2>
  </MST_SET_MEDI_NAME>
</root>
', '{"dataset": [{"ctlNo": "-604177.ctl_no", "ordNo": "-604177.ord_no", "dispNo": "-604177.disp_no", "sqlCode": -604168}, {"ctlNo": "-604174.ctl_no", "ordNo": "-604174.ord_no", "sqlCode": -604178}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'CSI');