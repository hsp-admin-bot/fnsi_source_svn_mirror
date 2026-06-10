DELETE FROM mst_coop_layout WHERE ctl_no IN (
  -4070004,-4070001,-4070003,-4060001,-4060002,-4060003,-4061001
  );

INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4070004, 'P_hosp', 'rst_dial', '', 'S', 'upd', 'xml', 'パナソニック 透析実績(処方薬剤連携)', 'Medicom', '透析実績(処方薬剤連携)', '1', '<Consultation_Datas S_Version="dataset:-307086.s_version">
  <SystemInfo>
    <SystemName>dataset:-307086.device_identifier</SystemName>
  </SystemInfo>
  <Consultation_Data>
    <Patient_Info>
      <Patient_ID>dataset:-306001.hosp_pat_id</Patient_ID>
    </Patient_Info>
    <Consultation>
      <Basic_Info Consultation_DataID="$JOURNAL.coop_ord_no">
        <InPatientFlag>dataset:-307001.in_patient_flag</InPatientFlag>
        <Consultation_Date>dataset:-458.start_date14</Consultation_Date>
        <Consultation_Doctor DoctorID="dataset:-307002.doctor_id">
                        dataset:-307003.doctor_name</Consultation_Doctor>
        <Consultation_Type>dataset:-307086.visit_category</Consultation_Type>
        <Consultation_Department DepartmentID="dataset:-307001.department_cd">
                        dataset:-307001.department_name</Consultation_Department>
        <Insurance InsuranceID="dataset:-307004.insurance_id">dataset:-307004.insurance</Insurance>
        <Prescription_INOUT>dataset:-307001.presciption_inout</Prescription_INOUT>
        <Message>dataset:-458.memo</Message>
      </Basic_Info>
      <Order_Info>
        <Order_Category Category="dataset:-307086.category_name_medicine" _detail="medicine_units" _sqlCode="-307131"/>
        <Order_Category Category="dataset:-307086.category_name_injection" _detail="injection_units" _sqlCode="-307132"/>
        <Order_Category Category="dataset:-307086.category_name_treatment" _detail="treatment_units" _sqlCode="-307133"/>
        <Order_Category Category="dataset:-307086.category_name_holiday" _detail="holiday_units" _sqlCode="-307134"/>
        <Order_Category Category="dataset:-307086.category_name_dialysis" _detail="dialysis_units" _sqlCode="-307135"/>
        <Order_Category Category="dataset:-307086.category_name_consultation" _sqlCode="-307069">
          <Order_Units Order_UnitsID="dataset:-307069.order_units_id" Application="dataset:-307086.prescription_details_consultation" InputUserCode="dataset:-307102.staff_cd" InputUserName="dataset:-307102.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date">
            <Order Code="dataset:-307069.code" Name="dataset:-307069.name" Count="dataset:-307069.count" Unit="dataset:-307069.unit" Cutoff="dataset:-307069.cutoff" SeqNo="dataset:-307069.seq_no"/>
            <Order_Administration/>
            <OrderUnits_Memo/>
          </Order_Units>
        </Order_Category>
        <Order_Category Category="dataset:-307086.category_name_surgery" _detail="surgery_units" _sqlCode="-307136"/>
        <Order_Category Category="dataset:-307086.category_name_examination" _detail="examination_units" _sqlCode="-307137"/>
      </Order_Info>
    </Consultation>
  </Consultation_Data>
</Consultation_Datas>
', '{"dataset": [{"patId": "patId", "sqlCode": -306001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -458}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307001, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307002, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307003, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307004}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307069, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307086, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307093}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307098, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307102, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307131, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307132, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307133, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307134, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307135, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307136, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307137, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "patId": "patId", "sqlCode": -99997}}'::jsonb, '1', '0', 5843, '2025-04-22 15:54:25.194', CURRENT_TIMESTAMP, 'MED');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4070001, 'P_hosp', 'rst_dial', '', 'S', 'cre', 'xml', 'パナソニック 透析実績(処方薬剤連携)', 'Medicom', '透析実績(処方薬剤連携)', '1', '<Consultation_Datas S_Version="dataset:-307086.s_version">
  <SystemInfo>
    <SystemName>dataset:-307086.device_identifier</SystemName>
  </SystemInfo>
  <Consultation_Data>
    <Patient_Info>
      <Patient_ID>dataset:-306001.hosp_pat_id</Patient_ID>
    </Patient_Info>
    <Consultation>
      <Basic_Info Consultation_DataID="$JOURNAL.coop_ord_no">
        <InPatientFlag>dataset:-307001.in_patient_flag</InPatientFlag>
        <Consultation_Date>dataset:-458.start_date14</Consultation_Date>
        <Consultation_Doctor DoctorID="dataset:-307002.doctor_id">
                        dataset:-307003.doctor_name</Consultation_Doctor>
        <Consultation_Type>dataset:-307086.visit_category</Consultation_Type>
        <Consultation_Department DepartmentID="dataset:-307001.department_cd">
                        dataset:-307001.department_name</Consultation_Department>
        <Insurance InsuranceID="dataset:-307004.insurance_id">dataset:-307004.insurance</Insurance>
        <Prescription_INOUT>dataset:-307001.presciption_inout</Prescription_INOUT>
        <Message>dataset:-458.memo</Message>
      </Basic_Info>
      <Order_Info>
        <Order_Category Category="dataset:-307086.category_name_medicine" _detail="medicine_units" _sqlCode="-307131"/>
        <Order_Category Category="dataset:-307086.category_name_injection" _detail="injection_units" _sqlCode="-307132"/>
        <Order_Category Category="dataset:-307086.category_name_treatment" _detail="treatment_units" _sqlCode="-307133"/>
        <Order_Category Category="dataset:-307086.category_name_holiday" _detail="holiday_units" _sqlCode="-307134"/>
        <Order_Category Category="dataset:-307086.category_name_dialysis" _detail="dialysis_units" _sqlCode="-307135"/>
        <Order_Category Category="dataset:-307086.category_name_consultation" _sqlCode="-307069">
          <Order_Units Order_UnitsID="dataset:-307069.order_units_id" Application="dataset:-307086.prescription_details_consultation" InputUserCode="dataset:-307102.staff_cd" InputUserName="dataset:-307102.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date">
            <Order Code="dataset:-307069.code" Name="dataset:-307069.name" Count="dataset:-307069.count" Unit="dataset:-307069.unit" Cutoff="dataset:-307069.cutoff" SeqNo="dataset:-307069.seq_no"/>
            <Order_Administration/>
            <OrderUnits_Memo/>
          </Order_Units>
        </Order_Category>
        <Order_Category Category="dataset:-307086.category_name_surgery" _detail="surgery_units" _sqlCode="-307136"/>
        <Order_Category Category="dataset:-307086.category_name_examination" _detail="examination_units" _sqlCode="-307137"/>
      </Order_Info>
    </Consultation>
  </Consultation_Data>
</Consultation_Datas>
', '{"dataset": [{"patId": "patId", "sqlCode": -306001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -458}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307001, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307002, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307003, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307004}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307069, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307086, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307093}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307098, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307102, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307131, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307132, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307133, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307134, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307135, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307136, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307137, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "patId": "patId", "sqlCode": -99997}}'::jsonb, '1', '0', 5843, '2025-04-22 15:54:25.194', CURRENT_TIMESTAMP, 'MED');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4070003, 'P_hosp', 'rst_dial', '', 'S', 'del', 'xml', 'パナソニック 透析実績(処方薬剤連携)', 'Medicom', '透析実績(処方薬剤連携)', '1', '<Consultation_Datas S_Version="1.00">
  <SystemInfo>
    <SystemName>FUTURENET</SystemName>
  </SystemInfo>
  <Consultation_Data>
    <Patient_Info>
      <Patient_ID>dataset:-306001.hosp_pat_id</Patient_ID>
    </Patient_Info>
    <Consultation>
      <Basic_Info Consultation_DataID="$JOURNAL.coop_ord_no">
        <InPatientFlag _sqlCode="-307087">dataset:-307087.in_patient_flag</InPatientFlag>
        <Consultation_Date>dataset:-307085.rst_start_date</Consultation_Date>
        <Consultation_Doctor DoctorID="dataset:-307088.doctor_code">dataset:-307088.doctor_name</Consultation_Doctor>
        <Consultation_Type>dataset:-306086.visit_category</Consultation_Type>
        <Consultation_Department DepartmentID="dataset:-307089.course_cd">dataset:-307089.course_name</Consultation_Department>
        <Insurance InsuranceID="dataset:-307004.insurance_id">dataset:-307004.insurance</Insurance>
        <Prescription_INOUT>dataset:-307001.presciption_inout</Prescription_INOUT>
        <Message>dataset:-458.memo</Message>
      </Basic_Info>
    </Consultation>
  </Consultation_Data>
</Consultation_Datas>
', '{"dataset": [{"key0": "key0", "patId": "patId", "sqlCode": -307128, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"patId": "patId", "sqlCode": -306001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -458}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307001, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307002, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307003, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307004}, {"ordNo": "ordNo", "sqlCode": -307085}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307087, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307088, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307089, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "patId": "patId", "sqlCode": -307084}}'::jsonb, '1', '0', 5843, '2025-04-09 17:49:49.574', CURRENT_TIMESTAMP, 'MED');

INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4060001, 'P_hosp', 'accept', '', 'S', 'cre', 'text', 'パナソニック 受付情報', 'Medicom', '受付情報', '1', '<root name="再来受付">
  <item name="再受機No" len="2" value="dataset:-457.reconnection"/>
  <item name="患者コード" len="13" value="dataset:-306001.hosp_pat_id"/>
  <item name="保険種別" len="3" value="$BLANK"/>
  <item name="外/入" len="1" value="const:1"/>
  <item name="初/再" len="1" value="const:2"/>
  <item name="来院理由" len="4" value="dataset:-457.in_hosptial_reason"/>
  <item name="初回来院" len="1" value="$BLANK"/>
  <item name="保険追加" len="1" value="$BLANK"/>
  <item name="頭書修正" len="1" value="$BLANK"/>
  <item name="予備" len="1" value="$BLANK"/>
  <item name="予約/緊急" len="1" value="$BLANK"/>
  <item name="医師１" len="4" value="dataset:-306103.staff_cd"/>
  <item name="予備" len="4" value="$BLANK"/>
  <item name="予備" len="4" value="$BLANK"/>
  <item name="予備" len="4" value="$BLANK"/>
  <item name="処理フラグ" len="1" value="$BLANK"/>
  <item name="当日外フラグ" len="1" value="$BLANK"/>
  <item name="抹消フラグ" len="1" value="$BLANK"/>
  <item name="予備" len="3" value="$BLANK"/>
  <item name="受付処理.年" len="4" value="dataset:-456.date_year"/>
  <item name="受付処理.月日" len="4" value="dataset:-456.date_month_day"/>
  <item name="受付時間" len="6" value="dataset:-456.date_time"/>
  <item name="コメント" len="40" value="dataset:-306101.comment" padding_format="fblank" padding_position="right" subMode="L"/>
  <item name="受診科１" len="3" value="dataset:-456.in_hospital_cd"/>
  <item name="予備" len="3" value="$BLANK"/>
  <item name="予備" len="3" value="$BLANK"/>
  <item name="予備" len="3" value="$BLANK"/>
  <item name="主科" len="3" value="$BLANK"/>
  <item name="受付番号種別" len="1" value="const:K"/>
  <item name="受付番号" len="4" value="$JOURNAL.accept_no" padding_format="zero" padding_position="left"/>
  <item name="予備" len="3" value="$BLANK"/>
  <item name="予約年月日" len="8" value="dataset:-1001.treat_date"/>
  <item name="予約時間" len="4" value="dataset:-1001.ind_treat_start_time"/>
  <item name="予備" len="20" value="$BLANK"/>
  <item name="終端" len="1" value="$CR"/>
  <item name="終端" len="1" value="$LF"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -306001}, {"patId": "patId", "sqlCode": -455}, {"ordNo": "ordNo", "sqlCode": -456, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -457, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -1001, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -306101, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -306103, "facilityCd": "facilityCd"}], "dumpFileName": {"patId": "patId", "sqlCode": -306102}}'::jsonb, '1', '0', 5843, '2025-03-07 12:00:13.562', CURRENT_TIMESTAMP, 'MED');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4060002, 'P_hosp', 'accept', '', 'S', 'upd', 'text', 'パナソニック 受付情報', 'Medicom', '受付情報', '1', '<root name="再来受付">
  <item name="再受機No" len="2" value="dataset:-457.reconnection"/>
  <item name="患者コード" len="13" value="dataset:-306001.hosp_pat_id"/>
  <item name="保険種別" len="3" value="$BLANK"/>
  <item name="外/入" len="1" value="const:1"/>
  <item name="初/再" len="1" value="const:2"/>
  <item name="来院理由" len="4" value="dataset:-457.in_hosptial_reason"/>
  <item name="初回来院" len="1" value="$BLANK"/>
  <item name="保険追加" len="1" value="$BLANK"/>
  <item name="頭書修正" len="1" value="$BLANK"/>
  <item name="予備" len="1" value="$BLANK"/>
  <item name="予約/緊急" len="1" value="$BLANK"/>
  <item name="医師１" len="4" value="dataset:-457.staff_cd"/>
  <item name="予備" len="4" value="$BLANK"/>
  <item name="予備" len="4" value="$BLANK"/>
  <item name="予備" len="4" value="$BLANK"/>
  <item name="処理フラグ" len="1" value="$BLANK"/>
  <item name="当日外フラグ" len="1" value="$BLANK"/>
  <item name="抹消フラグ" len="1" value="$BLANK"/>
  <item name="予備" len="3" value="$BLANK"/>
  <item name="受付処理.年" len="4" value="dataset:-456.date_year"/>
  <item name="受付処理.月日" len="4" value="dataset:-456.date_month_day"/>
  <item name="受付時間" len="6" value="dataset:-456.date_time"/>
  <item name="コメント" len="40" value="dataset:-455.comment" padding_format="fblank" padding_position="right" subMode="L"/>
  <item name="受診科１" len="3" value="dataset:-456.in_hospital_cd"/>
  <item name="予備" len="3" value="$BLANK"/>
  <item name="予備" len="3" value="$BLANK"/>
  <item name="予備" len="3" value="$BLANK"/>
  <item name="主科" len="3" value="$BLANK"/>
  <item name="受付番号種別" len="1" value="const:K"/>
  <item name="受付番号" len="4" value="$JOURNAL.accept_no" padding_format="zero" padding_position="left"/>
  <item name="予備" len="3" value="$BLANK"/>
  <item name="予約年月日" len="8" value="dataset:-1001.treat_date"/>
  <item name="予約時間" len="4" value="dataset:-1001.ind_treat_start_time"/>
  <item name="予備" len="20" value="$BLANK"/>
  <item name="終端" len="1" value="$CR"/>
  <item name="終端" len="1" value="$LF"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -306001}, {"patId": "patId", "sqlCode": -455}, {"ordNo": "ordNo", "sqlCode": -456, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -457, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -1001, "facilityCd": "facilityCd"}], "dumpFileName": {"patId": "patId", "sqlCode": -99998}}'::jsonb, '1', '0', 5843, '2025-03-07 12:00:13.562', CURRENT_TIMESTAMP, 'MED');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4060003, 'P_hosp', 'accept', '', 'S', 'del', 'text', 'パナソニック 受付情報', 'Medicom', '受付情報', '1', '<root name="再来受付">
  <item name="再受機No" len="2" value="dataset:-457.reconnection"/>
  <item name="患者コード" len="13" value="dataset:-306001.hosp_pat_id"/>
  <item name="保険種別" len="3" value="$BLANK"/>
  <item name="外/入" len="1" value="const:1"/>
  <item name="初/再" len="1" value="const:2"/>
  <item name="来院理由" len="4" value="dataset:-457.in_hosptial_reason"/>
  <item name="初回来院" len="1" value="$BLANK"/>
  <item name="保険追加" len="1" value="$BLANK"/>
  <item name="頭書修正" len="1" value="$BLANK"/>
  <item name="予備" len="1" value="$BLANK"/>
  <item name="予約/緊急" len="1" value="$BLANK"/>
  <item name="医師１" len="4" value="dataset:-457.staff_cd"/>
  <item name="予備" len="4" value="$BLANK"/>
  <item name="予備" len="4" value="$BLANK"/>
  <item name="予備" len="4" value="$BLANK"/>
  <item name="処理フラグ" len="1" value="$BLANK"/>
  <item name="当日外フラグ" len="1" value="$BLANK"/>
  <item name="抹消フラグ" len="1" value="$BLANK"/>
  <item name="予備" len="3" value="$BLANK"/>
  <item name="受付処理.年" len="4" value="dataset:-456.date_year"/>
  <item name="受付処理.月日" len="4" value="dataset:-456.date_month_day"/>
  <item name="受付時間" len="6" value="dataset:-456.date_time"/>
  <item name="コメント" len="40" value="dataset:-455.comment" padding_format="fblank" padding_position="right" subMode="L"/>
  <item name="受診科１" len="3" value="dataset:-456.in_hospital_cd"/>
  <item name="予備" len="3" value="$BLANK"/>
  <item name="予備" len="3" value="$BLANK"/>
  <item name="予備" len="3" value="$BLANK"/>
  <item name="主科" len="3" value="$BLANK"/>
  <item name="受付番号種別" len="1" value="const:K"/>
  <item name="受付番号" len="4" value="$JOURNAL.accept_no" padding_format="zero" padding_position="left"/>
  <item name="予備" len="3" value="$BLANK"/>
  <item name="予約年月日" len="8" value="dataset:-1001.treat_date"/>
  <item name="予約時間" len="4" value="dataset:-1001.ind_treat_start_time"/>
  <item name="予備" len="20" value="$BLANK"/>
  <item name="終端" len="1" value="$CR"/>
  <item name="終端" len="1" value="$LF"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -306001}, {"patId": "patId", "sqlCode": -455}, {"ordNo": "ordNo", "sqlCode": -456, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -457, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -1001, "facilityCd": "facilityCd"}], "dumpFileName": {"patId": "patId", "sqlCode": -99998}}'::jsonb, '1', '0', 5843, '2025-03-07 12:00:13.562', CURRENT_TIMESTAMP, 'MED');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4061001, 'P_hosp', 'accept', '', 'S', 'cre', 'text', 'パナソニック 受付情報', 'Medicom', '受付情報', '1', '<root name="再来受付">
    <item  name="再受機No" len="2" value="dataset:-457.reconnection"/>
    <item  name="患者コード" len="13" value="dataset:-306001.hosp_pat_id"/>
    <item  name="保険種別" len="3" value="$BLANK"/>
    <item  name="外/入" len="1" value="const:1"/>
    <item  name="初/再" len="1" value="const:2"/>
    <item  name="来院理由" len="4" value="dataset:-457.in_hosptial_reason"/>
    <item  name="初回来院" len="1" value="$BLANK"/>
    <item  name="保険追加" len="1" value="$BLANK"/>
    <item  name="頭書修正" len="1" value="$BLANK"/>
    <item  name="予備" len="1" value="$BLANK"/>
    <item  name="予約/緊急" len="1" value="$BLANK"/>
    <item  name="医師１" len="4" value="dataset:-306103.staff_cd"/>
    <item  name="予備" len="4" value="$BLANK"/>
    <item  name="予備" len="4" value="$BLANK"/>
    <item  name="予備" len="4" value="$BLANK"/>
    <item  name="処理フラグ" len="1" value="$BLANK"/>
    <item  name="当日外フラグ" len="1" value="$BLANK"/>
    <item  name="抹消フラグ" len="1" value="$BLANK"/>
    <item  name="予備" len="3" value="$BLANK"/>
    <item  name="受付処理.年" len="4" value="dataset:-456.date_year"/>
    <item  name="受付処理.月日" len="4" value="dataset:-456.date_month_day"/>
    <item  name="受付時間" len="6" value="dataset:-456.date_time"/>
    <item  name="コメント" len="40" value="dataset:-306101.comment" padding_format="fblank" padding_position="right" subMode="L"/>
    <item  name="受診科１" len="3" value="dataset:-456.in_hospital_cd"/>
    <item  name="予備" len="3" value="$BLANK"/>
    <item  name="予備" len="3" value="$BLANK"/>
    <item  name="予備" len="3" value="$BLANK"/>
    <item  name="主科" len="3" value="$BLANK"/>
    <item  name="受付番号種別" len="1" value="const:K"/>
    <item  name="受付番号" len="4"  value="$JOURNAL.accept_no" padding_format="zero" padding_position="left"/>
    <item  name="予備" len="3" value="$BLANK"/>
    <item  name="予約年月日" len="8" value="dataset:-1001.treat_date"/>
    <item  name="予約時間" len="4" value="dataset:-1001.kur_standard_start_time"/>
    <item  name="予備" len="20" value="$BLANK"/>
    <item  name="終端" len="1" value="$CR"/>
    <item  name="終端" len="1" value="$LF"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -306001}, {"patId": "patId", "sqlCode": -455}, {"ordNo": "ordNo", "sqlCode": -456, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -457, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -1001}], "dumpFileName": {"patId": "patId", "sqlCode": -306102}}'::jsonb, '1', '0', -2, '2020-03-17 16:25:14.394', CURRENT_TIMESTAMP, 'MED');