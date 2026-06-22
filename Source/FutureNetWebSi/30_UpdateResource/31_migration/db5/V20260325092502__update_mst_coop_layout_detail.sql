DELETE FROM ntss.mst_coop_layout_detail WHERE ctl_no=-607000005;
DELETE FROM ntss.mst_coop_layout_detail WHERE ctl_no=-607000006;
DELETE FROM ntss.mst_coop_layout_detail WHERE ctl_no=-607000007;
DELETE FROM ntss.mst_coop_layout_detail WHERE ctl_no=-607000008;

INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-607000005, 'C_hosp', 'rst_dial', 'S', 'medicine', '09', '調製薬剤使用薬剤繰り返し', 'CSI透析実績(投薬履歴 削除電文用)', '1', '<root>
  <!-- 6.投薬履歴 -->
  <CTL_NO>dataset:-604193.e01</CTL_NO>
  <!-- 指示実施フラグ -->
  <EFFECT_FLG>dataset:-604193.e02</EFFECT_FLG>
  <!-- 薬剤コード -->
  <SET_MEDICINE_CD>dataset:-604193.e03</SET_MEDICINE_CD>
  <!-- 手技コード -->
  <PROCEDURE_CD>dataset:-604193.e04</PROCEDURE_CD>
  <!-- 実施日 -->
  <EFFECT_DATE>dataset:-604193.e05</EFFECT_DATE>
  <!-- セット薬剤使用フラグ -->
  <SET_MEDICINE_FLG>dataset:-604193.e06</SET_MEDICINE_FLG>
  <!-- 使用量 -->
  <AMOUNT>dataset:-604193.e07</AMOUNT>
  <!-- 薬剤マスタ -->
  <MST_MEDICINE>
    <!-- 注射フラグ -->
    <SHOT>dataset:-604193.e08</SHOT>
    <!-- 薬剤コード(院内コード) -->
    <IN_HOSPITAL_CD>dataset:-604193.e09</IN_HOSPITAL_CD>
    <!-- 薬剤コード(院内コード2) -->
    <IN_HOSPITAL_CD2>dataset:-604193.e10</IN_HOSPITAL_CD2>
    <!-- 薬剤コード -->
    <MEDICINE_CD>dataset:-604193.e11</MEDICINE_CD>
    <!-- 薬剤グループコード -->
    <MEDICINE_GROUP_CD>dataset:-604193.e12</MEDICINE_GROUP_CD>
  </MST_MEDICINE>
  <!-- 手技マスタ -->
  <MST_PROCEDURE>
    <!-- ルート項目コード(院内コード) -->
    <IN_HOSPITAL_CD1>dataset:-604193.e13</IN_HOSPITAL_CD1>
    <!-- 投与方法項目コード(院内コード) -->
    <IN_HOSPITAL_CD2>dataset:-604193.e14</IN_HOSPITAL_CD2>
  </MST_PROCEDURE>
  <MST_SET_MEDI_NAME>
    <!-- ※NTSSに薬剤セットが無し -->
    <!-- 薬剤セットマスタ -->
    <MST_SET_MEDICINE _detail="medicine" _sqlCode="-604194">
    </MST_SET_MEDICINE>
    <!-- 院内コード２ -->
    <IN_HOSPITAL_CD2/>
  </MST_SET_MEDI_NAME>
</root>', '{"dataset": [{"e01": "-604188.ctl_no", "e02": "-604188.effect_flg", "e03": "-604188.medicine_cd", "e04": "-604188.procedure_cd", "e05": "-604188.effect_date", "e06": "-604188.set_medicine_flg", "e07": "-604188.amount", "e08": "-604188.mmd_is_shot", "e09": "-604188.mmd_in_hospital_cd_1", "e10": "-604188.mmd_in_hospital_cd_2", "e11": "-604188.mmd_medicine_cd", "e12": "-604188.class_cd", "e13": "-604188.mp_in_hospital_cd_1", "e14": "-604188.mp_in_hospital_cd_2", "e15": "-604188.mix_med_in_hospital_cd2", "e16": "''''", "sqlCode": -604193}, {"ctlNo": "-604188.journal_ctl_no", "ordNo": "-604188.ord_no", "patId": "-604188.pat_id", "sqlCode": -604194, "facilityCd": "-604188.facility_cd", "targetCtlNo": "-604188.ctl_no"}]}'::jsonb, '1', '0', -1, current_timestamp, current_timestamp, 'CSI');
INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-607000006, 'C_hosp', 'rst_dial', 'S', 'medicine', '10', '調製薬剤使用薬剤繰り返し', 'CSI透析実績(愁訴処置 削除電文用)', '1', '<root>
  <!-- 7.愁訴処置 -->
  <!-- 薬剤コード -->
  <TREAT_MEDICINE_CD>dataset:-604193.e01</TREAT_MEDICINE_CD>
  <!-- 手技コード -->
  <PROCEDURE_CD>dataset:-604193.e02</PROCEDURE_CD>
  <!-- 入力数 -->
  <AMOUNT>dataset:-604193.e03</AMOUNT>
  <!-- 酸素吸入量(処置区分) -->
  <TREAT_CLASS>dataset:-604193.e04</TREAT_CLASS>
  <!-- 酸素吸入量(実績番号) -->
  <RESULT_NO>dataset:-604193.e05</RESULT_NO>
  <!-- 酸素吸入量(発生日時) -->
  <OCCUR_DATE>dataset:-604193.e06</OCCUR_DATE>
  <!-- 酸素吸入量(使用量) -->
  <OXYGEN_AMOUNT>dataset:-604193.e07</OXYGEN_AMOUNT>
  <!-- 酸素吸入量(酸素吸入開始日時) -->
  <OXYGEN_START>dataset:-604193.e08</OXYGEN_START>
  <!-- 酸素吸入量(酸素吸入時間) -->
  <OXYGEN_TIME>dataset:-604193.e09</OXYGEN_TIME>
  <!-- 薬剤マスタ -->
  <MST_MEDICINE>
    <!-- 注射フラグ -->
    <SHOT>dataset:-604193.e10</SHOT>
    <!-- 薬剤コード(院内コード) -->
    <IN_HOSPITAL_CD>dataset:-604193.e11</IN_HOSPITAL_CD>
    <!-- 薬剤コード(院内コード2) -->
    <IN_HOSPITAL_CD2>dataset:-604193.e12</IN_HOSPITAL_CD2>
    <!-- 薬剤コード -->
    <MEDICINE_CD>dataset:-604193.e13</MEDICINE_CD>
    <!-- 薬剤グループコード -->
    <MEDICINE_GROUP_CD>dataset:-604193.e14</MEDICINE_GROUP_CD>
  </MST_MEDICINE>
  <MST_PROCEDURE>
    <!-- ルート項目コード(院内コード) -->
    <IN_HOSPITAL_CD1>dataset:-604193.e15</IN_HOSPITAL_CD1>
    <!-- 投与方法項目コード(院内コード) -->
    <IN_HOSPITAL_CD2>dataset:-604193.e16</IN_HOSPITAL_CD2>
  </MST_PROCEDURE>
  <MST_SET_MEDI_NAME>
    <!-- ※NTSSに薬剤セットが無し -->
    <!-- 薬剤セットマスタ -->
    <MST_SET_MEDICINE _detail="medicine" _sqlCode="-604195">
    </MST_SET_MEDICINE>
    <!-- 院内コード２ -->
    <IN_HOSPITAL_CD2/>
  </MST_SET_MEDI_NAME>
</root>
', '{"dataset": [{"e01": "-604189.medicine_cd", "e02": "-604189.procedure_cd", "e03": "-604189.amount", "e04": "-604189.treat_class", "e05": "-604189.result_no", "e06": "-604189.occur_date_start", "e07": "-604189.oxygen_amount", "e08": "-604189.oxygen_start_new", "e09": "-604189.oxygen_time_new", "e10": "-604189.mmd_is_shot", "e11": "-604189.mmd_in_hospital_cd_1", "e12": "-604189.mmd_in_hospital_cd_2", "e13": "-604189.mmd_medicine_cd", "e14": "-604189.mmd_class_cd", "e15": "-604189.mp_in_hospital_cd_1", "e16": "-604189.mp_in_hospital_cd_2", "sqlCode": -604193}, {"ctlNo": "-604188.journal_ctl_no", "ordNo": "-604189.ord_no", "patId": "-604189.pat_id", "sqlCode": -604195, "facilityCd": "-604189.facility_cd", "targetCtlNo": "-604189.ctl_no"}]}'::jsonb, '1', '0', -1, current_timestamp, current_timestamp, 'CSI');
INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-607000007, 'C_hosp', 'rst_dial', 'S', 'medicine', '11', '調製薬剤使用薬剤繰り返し', 'CSI透析実績(投薬履歴 調整薬剤 削除電文用)', '1', '<root>
  <!-- 薬剤マスタ -->
  <MST_MEDICINE>
    <!-- 薬剤マスタ・注射フラグ -->
    <SHOT>dataset:-604193.e01</SHOT>
    <!-- 院内コード -->
    <IN_HOSPITAL_CD>dataset:-604193.e02</IN_HOSPITAL_CD>
    <!-- 薬剤グループコード -->
    <MEDICINE_GROUP_CD>dataset:-604193.e03</MEDICINE_GROUP_CD>
  </MST_MEDICINE>
  <!-- 手技コード -->
  <PROCEDURE_CD>dataset:-604193.e04</PROCEDURE_CD>
  <!-- 手技マスタ -->
  <MST_PROCEDURE>
    <!-- ルート項目コード(院内コード) -->
    <IN_HOSPITAL_CD1>dataset:-604193.e05</IN_HOSPITAL_CD1>
    <!-- 投与方法項目コード(院内コード) -->
    <IN_HOSPITAL_CD2>dataset:-604193.e06</IN_HOSPITAL_CD2>
  </MST_PROCEDURE>
  <!-- 使用薬剤数 -->
  <MEDI_USE_NUM>dataset:-604193.e07</MEDI_USE_NUM>
</root>', '{"dataset": [{"e01": "-604194.mmd_is_shot", "e02": "-604194.mmd_in_hospital_cd_1", "e03": "-604194.class_cd", "e04": "-604194.procedure_cd", "e05": "-604194.mp_in_hospital_cd_1", "e06": "-604194.mp_in_hospital_cd_2", "e07": "-604194.amount", "e08": "''''", "e09": "''''", "e10": "''''", "e11": "''''", "e12": "''''", "e13": "''''", "e14": "''''", "e15": "''''", "e16": "''''", "sqlCode": -604193}]}'::jsonb, '1', '0', -1, current_timestamp, current_timestamp, 'CSI');
INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-607000008, 'C_hosp', 'rst_dial', 'S', 'medicine', '12', '調製薬剤使用薬剤繰り返し', 'CSI透析実績(愁訴処置 調整薬剤 削除電文用)', '1', '<root>
  <!-- 薬剤マスタ -->
  <MST_MEDICINE>
    <!-- 薬剤マスタ・注射フラグ -->
    <SHOT>dataset:-604193.e01</SHOT>
    <!-- 院内コード -->
    <IN_HOSPITAL_CD>dataset:-604193.e02</IN_HOSPITAL_CD>
    <!-- 薬剤グループコード -->
    <MEDICINE_GROUP_CD>dataset:-604193.e03</MEDICINE_GROUP_CD>
  </MST_MEDICINE>
  <!-- 手技コード -->
  <PROCEDURE_CD>dataset:-604193.e04</PROCEDURE_CD>
  <!-- 手技マスタ -->
  <MST_PROCEDURE>
    <!-- ルート項目コード(院内コード) -->
    <IN_HOSPITAL_CD1>dataset:-604193.e05</IN_HOSPITAL_CD1>
    <!-- 投与方法項目コード(院内コード) -->
    <IN_HOSPITAL_CD2>dataset:-604193.e06</IN_HOSPITAL_CD2>
  </MST_PROCEDURE>
  <!-- 使用薬剤数 -->
  <MEDI_USE_NUM>dataset:-604193.e07</MEDI_USE_NUM>
</root>', '{"dataset": [{"e01": "-604195.mmd_is_shot", "e02": "-604195.mmd_in_hospital_cd_1", "e03": "-604195.class_cd", "e04": "-604195.procedure_cd", "e05": "-604195.mp_in_hospital_cd_1", "e06": "-604195.mp_in_hospital_cd_2", "e07": "-604195.amount", "e08": "''''", "e09": "''''", "e10": "''''", "e11": "''''", "e12": "''''", "e13": "''''", "e14": "''''", "e15": "''''", "e16": "''''", "sqlCode": -604193}]}'::jsonb, '1', '0', -1, current_timestamp, current_timestamp, 'CSI');