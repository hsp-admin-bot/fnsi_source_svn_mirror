DELETE FROM mst_coop_layout
WHERE ctl_no IN (-4060001, -4061001, -4070001, -4070003, -4070004, -4100001, -4100002, -4100003, -4170001, -4170002);

INSERT INTO mst_coop_layout
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
', '{"dataset": [{"patId": "patId", "sqlCode": -306001}, {"patId": "patId", "sqlCode": -455}, {"ordNo": "ordNo", "sqlCode": -456, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -457, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -1001, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -306101, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -306103, "facilityCd": "facilityCd"}], "dumpFileName": {"key0": "key0", "patId": "patId", "sqlCode": -306102}}'::jsonb, '1', '0', -1, '2025-03-07 12:00:13.562', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout
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
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -306001}, {"patId": "patId", "sqlCode": -455}, {"ordNo": "ordNo", "sqlCode": -456, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -457, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -1001}], "dumpFileName": {"key0": "key0", "patId": "patId", "sqlCode": -306102}}'::jsonb, '1', '0', -2, '2020-03-17 16:25:14.394', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout
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
', '{"dataset": [{"patId": "patId", "sqlCode": -306001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -458}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307001, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307002, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307003, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307004}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307069, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307086, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307093}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307098, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307102, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307131, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307132, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307133, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307134, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307135, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307136, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307137, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "patId": "patId", "sqlCode": -99997}}'::jsonb, '1', '0', -1, '2025-04-22 15:54:25.194', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout
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
        <Consultation_Type>dataset:-307086.visit_category</Consultation_Type>
        <Consultation_Department DepartmentID="dataset:-307089.course_cd">dataset:-307089.course_name</Consultation_Department>
        <Insurance InsuranceID="dataset:-307004.insurance_id">dataset:-307004.insurance</Insurance>
        <Prescription_INOUT>dataset:-307001.presciption_inout</Prescription_INOUT>
        <Message>dataset:-458.memo</Message>
      </Basic_Info>
    </Consultation>
  </Consultation_Data>
</Consultation_Datas>
', '{"dataset": [{"key0": "key0", "patId": "patId", "sqlCode": -307128, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"patId": "patId", "sqlCode": -306001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -458}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307001, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307002, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307003, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307004}, {"ordNo": "ordNo", "sqlCode": -307085}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307086, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307087, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307088, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307089, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "patId": "patId", "sqlCode": -307084}}'::jsonb, '1', '0', -1, '2025-04-24 16:10:44.511', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout
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
', '{"dataset": [{"patId": "patId", "sqlCode": -306001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -458}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307001, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307002, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307003, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307004}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307069, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307086, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307093}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307098, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307102, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307131, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307132, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307133, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307134, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307135, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307136, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307137, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "patId": "patId", "sqlCode": -99997}}'::jsonb, '1', '0', -1, '2025-04-22 15:54:25.194', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4100001, 'P_hosp', 'exam_ord', '', 'S', 'cre', 'text', 'Medicom検査オーダ', 'Medicom', '検査オーダ', '1', '<root name="検査依頼">
  <item name="レコード区分" len="2" value="const:O1"/>
  <item name="検査機関コード" len="6" value="dataset:-310001.exam_institution_cd"/>
  <item name="依頼者KEY（日付）" len="6" value="$SYSDATE" subMode="R"/>
  <item name="依頼者KEY（受付番号）" len="4" value="$JOURNAL.accept_no" padding_format="zero" padding_position="left"/>
  <item name="RSV" len="10" value="$BLANK"/>
  <item name="科コード・科名" len="15" value="dataset:-310003.course_in_hospital_cd"/>
  <item name="病棟コード・病棟名" len="15" value="dataset:-310003.ward_in_hospital_cd"/>
  <item name="入院外来区分" len="1" value="dataset:-310004.in_out_class"/>
  <item name="提出医" len="10" value="dataset:-310009.user_name"/>
  <item name="披験者ID" len="10" value="dataset:-310005.hosp_pat_id"/>
  <item name="RSV" len="5" value="$BLANK"/>
  <item name="カルテNO" len="10" value="dataset:-310005.hosp_pat_id"/>
  <item name="RSV" len="5" value="$BLANK"/>
  <item name="被験者名" len="20" value="dataset:-310005.pat_name_kana"/>
  <item name="性別" len="1" value="dataset:-310005.pat_sex"/>
  <item name="年齢区分" len="1" value="const:Y"/>
  <item name="年齢" len="3" value="dataset:-310004.pat_age"/>
  <item name="生年月日区分" len="1" value="$BLANK"/>
  <item name="生年月日" len="8" value="dataset:-310004.pat_birthday_yyyymmdd"/>
  <item name="採取日" len="8" value="dataset:-310006.exam_date"/>
  <item name="採取時間" len="4" value="dataset:-310006.exam_time"/>
  <item name="項目数" len="3" value="dataset:-310011.exam_set_cnt"/>
  <item name="身長" len="4" value="$BLANK"/>
  <item name="体重" len="4" value="$BLANK"/>
  <item name="尿量（量）" len="4" value="$BLANK"/>
  <item name="尿量（単位）" len="2" value="$BLANK"/>
  <item name="妊娠週数" len="2" value="$BLANK"/>
  <item name="透析前後" len="1" value="dataset:-310006.exam_timing"/>
  <item name="至急報告" len="1" value="$BLANK"/>
  <item name="依頼コメント内容" len="50" value="$BLANK"/>
  <item name="施設NO" len="6" value="dataset:-310002.facility_no"/>
  <item name="RSV" len="30" value="$BLANK"/>
  <item name="ベッド番号" len="4" value="dataset:-310006.bed_cd"/>
  <item name="改行" len="1" value="$CR"/>
  <occ name="明細.検査項目" len="0" detail="検査項目" sqlCode="-310010"/>
</root>
', '{"dataset": [{"ordNo": "ordNo", "patId": "patId", "sqlCode": -310016, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"patId": "patId", "sqlCode": -310004}, {"key0": "key0", "patId": "patId", "sqlCode": -310003, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -310002, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -310005, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -310010, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -310011, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -310006, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -310008, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -310009, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -310001, "facilityCd": "facilityCd"}], "dumpFileName": {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -310007, "facilityCd": "facilityCd"}}'::jsonb, '1', '0', -1, '2020-05-13 18:35:00.661', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4100002, 'P_hosp', 'exam_ord', '', 'S', 'upd', 'text', 'Medicom検査オーダ', 'Medicom', '検査オーダ', '1', '<root name="検査依頼">
  <item name="レコード区分" len="2" value="dataset:-310012.kbn"/>
  <item name="検査機関コード" len="6" value="dataset:-310001.exam_institution_cd"/>
  <item name="依頼者KEY（日付）" len="6" value="$SYSDATE" subMode="R"/>
  <item name="依頼者KEY（受付番号）" len="4" value="$JOURNAL.accept_no" padding_format="zero" padding_position="left"/>
  <item name="RSV" len="10" value="$BLANK"/>
  <item name="科コード・科名" len="15" value="dataset:-310003.course_in_hospital_cd"/>
  <item name="病棟コード・病棟名" len="15" value="dataset:-310003.ward_in_hospital_cd"/>
  <item name="入院外来区分" len="1" value="dataset:-310004.in_out_class"/>
  <item name="提出医" len="10" value="dataset:-310009.user_name"/>
  <item name="披験者ID" len="10" value="dataset:-310005.hosp_pat_id"/>
  <item name="RSV" len="5" value="$BLANK"/>
  <item name="カルテNO" len="10" value="dataset:-310005.hosp_pat_id"/>
  <item name="RSV" len="5" value="$BLANK"/>
  <item name="被験者名" len="20" value="dataset:-310005.pat_name_kana"/>
  <item name="性別" len="1" value="dataset:-310005.pat_sex"/>
  <item name="年齢区分" len="1" value="const:Y"/>
  <item name="年齢" len="3" value="dataset:-310004.pat_age"/>
  <item name="生年月日区分" len="1" value="$BLANK"/>
  <item name="生年月日" len="8" value="dataset:-310004.pat_birthday_yyyymmdd"/>
  <item name="採取日" len="8" value="dataset:-310006.exam_date"/>
  <item name="採取時間" len="4" value="dataset:-310006.exam_time"/>
  <item name="項目数" len="3" value="dataset:-310011.exam_set_cnt"/>
  <item name="身長" len="4" value="$BLANK"/>
  <item name="体重" len="4" value="$BLANK"/>
  <item name="尿量（量）" len="4" value="$BLANK"/>
  <item name="尿量（単位）" len="2" value="$BLANK"/>
  <item name="妊娠週数" len="2" value="$BLANK"/>
  <item name="透析前後" len="1" value="dataset:-310006.exam_timing"/>
  <item name="至急報告" len="1" value="$BLANK"/>
  <item name="依頼コメント内容" len="50" value="$BLANK"/>
  <item name="施設NO" len="6" value="dataset:-310002.facility_no"/>
  <item name="RSV" len="30" value="$BLANK"/>
  <item name="ベッド番号" len="4" value="dataset:-310006.bed_cd"/>
  <item name="改行" len="1" value="$CR"/>
  <occ name="明細.検査項目" len="0" detail="検査項目" sqlCode="-310010"/>
</root>
', '{"dataset": [{"ordNo": "ordNo", "patId": "patId", "sqlCode": -310016, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -310012, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"patId": "patId", "sqlCode": -310004}, {"key0": "key0", "patId": "patId", "sqlCode": -310003, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -310002, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -310005, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -310010, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -310011, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -310006, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -310008, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -310009, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -310001, "facilityCd": "facilityCd"}], "dumpFileName": {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -310007, "facilityCd": "facilityCd"}}'::jsonb, '1', '0', -1, '2020-05-13 18:35:00.661', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4100003, 'P_hosp', 'exam_ord', '', 'S', 'del', 'text', 'Medicom検査オーダ', 'Medicom', '検査オーダ', '1', '<root name="検査依頼">
  <item name="レコード区分" len="2" value="dataset:-310013.O1"/>
  <item name="検査機関コード" len="6" value="dataset:-310001.exam_institution_cd"/>
  <item name="依頼者KEY（日付）" len="6" value="$SYSDATE" subMode="R"/>
  <item name="依頼者KEY（受付番号）" len="4" value="$JOURNAL.accept_no" padding_format="zero" padding_position="left"/>
  <item name="RSV" len="10" value="$BLANK"/>
  <item name="科コード・科名" len="15" value="dataset:-310003.course_in_hospital_cd" padding_format="blank" padding_position="left"/>
  <item name="病棟コード・病棟名" len="15" value="dataset:-310003.ward_in_hospital_cd"/>
  <item name="入院外来区分" len="1" value="dataset:-310004.in_out_class"/>
  <item name="提出医" len="10" value="dataset:-310009.user_name"/>
  <item name="披験者ID" len="10" value="dataset:-310005.hosp_pat_id"/>
  <item name="RSV" len="5" value="$BLANK"/>
  <item name="カルテNO" len="10" value="dataset:-310005.hosp_pat_id"/>
  <item name="RSV" len="5" value="$BLANK"/>
  <item name="被験者名" len="20" value="dataset:-310005.pat_name"/>
  <item name="性別" len="1" value="dataset:-310005.pat_sex"/>
  <item name="年齢区分" len="1" value="const:Y"/>
  <item name="年齢" len="3" value="dataset:-310004.pat_age"/>
  <item name="生年月日区分" len="1" value="$BLANK"/>
  <item name="生年月日" len="8" value="dataset:-310004.pat_birthday_yyyymmdd"/>
  <item name="採取日" len="8" value="dataset:-310006.exam_date"/>
  <item name="採取時間" len="4" value="dataset:-310006.exam_time"/>
  <item name="項目数" len="3" value="dataset:-310011.exam_set_cnt"/>
  <item name="身長" len="4" value="$BLANK"/>
  <item name="体重" len="4" value="$BLANK"/>
  <item name="尿量（量）" len="4" value="$BLANK"/>
  <item name="尿量（単位）" len="2" value="$BLANK"/>
  <item name="妊娠週数" len="2" value="$BLANK"/>
  <item name="透析前後" len="1" value="dataset:-310006.exam_timing"/>
  <item name="至急報告" len="1" value="$BLANK"/>
  <item name="依頼コメント内容" len="50" value="$BLANK"/>
  <item name="施設NO" len="6" value="dataset:-310002.facility_no"/>
  <item name="RSV" len="30" value="$BLANK"/>
  <item name="ベッド番号" len="4" value="dataset:-310006.bed_cd"/>
  <item name="改行" len="1" value="$CR"/>
  <occ name="明細.検査項目" len="0" detail="検査項目" sqlCode="-310013"/>
</root>
', '{"dataset": [{"ordNo": "ordNo", "patId": "patId", "sqlCode": -310016, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"sqlCode": -310013, "is_zero_end": "true"}, {"patId": "patId", "sqlCode": -310004}, {"key0": "key0", "patId": "patId", "sqlCode": -310003, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -310002, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -310005, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -310010, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -310011, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -310006, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -310008, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -310009, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -310001, "facilityCd": "facilityCd"}], "dumpFileName": {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -310007, "facilityCd": "facilityCd"}}'::jsonb, '1', '0', -1, '2020-05-13 18:35:00.661', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4170001, 'P_hosp', 'karte_ord', '', 'S', 'cre', 'xml', 'カルテ記載(透析経過データ連携)', 'medicom', 'Medicomのカルテ記載(透析経過データ連携)', '1', '<MCSSData ver="Ver.03.02 2010-01-20">
  <Header>
    <ContentType>dataset:-317124.e03</ContentType>
    <FileVersion>dataset:-317141.e01</FileVersion>
    <InPatientFlag>dataset:-11.in_out_class</InPatientFlag>
    <DepartmentName>dataset:-317104.e12</DepartmentName>
    <DoctorName>dataset:-317111.e01</DoctorName>
    <ConsultationDate>dataset:-14.start_date8a</ConsultationDate>
    <ConsultationTime>dataset:-14.start_date6a</ConsultationTime>
    <ExaminationDate>dataset:-14.start_date8a</ExaminationDate>
    <ExaminationTime>dataset:-14.start_date6a</ExaminationTime>
    <Comment>dataset:-317124.e01</Comment>
    <PatientCode>dataset:-317102.e01</PatientCode>
    <InquirylnpDataFileID>dataset:-317124.e02</InquirylnpDataFileID>
  </Header>
  <Content>
    <Row RowCount="$ROW_COUNT" MasterID="88" detail="血液浄化法">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e01</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="89" detail="透析日">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e02</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="90" detail="予定時間">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e03</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="91" detail="開始時刻">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e04</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="92" detail="終了時刻">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e05</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="93" detail="透析時間">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e06</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="94" detail="透析回数">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e07</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="95" detail="血流量">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e08</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="96" detail="CTR">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e09</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="97" detail="穿刺者">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317112">dataset:-317112.e01</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="98" detail="回収者">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317113">dataset:-317113.e01</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="99" detail="担当者">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317114">dataset:-317114.e01</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="100" detail="ダイアライザ">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e10</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="101" detail="バスキュラーアクセス">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e11</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="102" detail="透析導入日">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-417">dataset:-417.e01</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="103" detail="感染症情報">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-418">dataset:-418.e01</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="104" detail="血液">
      <INPUTDATA SeqNo="1">dataset:-317116.abo</INPUTDATA>
      <INPUTDATA SeqNo="2">dataset:-317116.rh</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="105" detail="透析困難コメント">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-421">dataset:-421.e01</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="124" detail="SOAP" _detail="soap" _sqlCode="-317121" _isZeroDisp="true">
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="125" detail="看護メモ" _detail="nurse_memo" _sqlCode="-317122" _isZeroDisp="true">
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="126" detail="問診記録" _detail="medical_record" _sqlCode="-317123" _isZeroDisp="true">
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="122" detail="Ｄｒ">
      <INPUTDATA SeqNo="1">dataset:-317118.e01</INPUTDATA>
      <INPUTDATA SeqNo="2">dataset:-317118.e02</INPUTDATA>
      <INPUTDATA SeqNo="3">dataset:-317118.e03</INPUTDATA>
      <INPUTDATA SeqNo="4">dataset:-317118.e04</INPUTDATA>
      <INPUTDATA SeqNo="5">dataset:-317118.e05</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="123" detail="担当Ｎｓ">
      <INPUTDATA SeqNo="1">dataset:-317120.e01</INPUTDATA>
      <INPUTDATA SeqNo="2">dataset:-317120.e02</INPUTDATA>
      <INPUTDATA SeqNo="3">dataset:-317120.e03</INPUTDATA>
      <INPUTDATA SeqNo="4">dataset:-317120.e04</INPUTDATA>
      <INPUTDATA SeqNo="5">dataset:-317120.e05</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="110" detail="体重管理">
      <INPUTDATA SeqNo="1">dataset:-426.e01</INPUTDATA>
      <INPUTDATA SeqNo="2">dataset:-426.e02</INPUTDATA>
      <INPUTDATA SeqNo="3">dataset:-426.e03</INPUTDATA>
      <INPUTDATA SeqNo="4">dataset:-426.e04</INPUTDATA>
      <INPUTDATA SeqNo="5">dataset:-426.e05</INPUTDATA>
      <INPUTDATA SeqNo="6">dataset:-426.e06</INPUTDATA>
      <INPUTDATA SeqNo="7">dataset:-426.e07</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="111" detail="除水">
      <INPUTDATA SeqNo="1">dataset:-427.e01</INPUTDATA>
      <INPUTDATA SeqNo="2">dataset:-427.e02</INPUTDATA>
      <INPUTDATA SeqNo="3">dataset:-427.e03</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="112" detail="前・脈・血圧">
      <INPUTDATA SeqNo="1">dataset:-317107.bp_high</INPUTDATA>
      <INPUTDATA SeqNo="2">dataset:-317107.bp_low</INPUTDATA>
      <INPUTDATA SeqNo="3">dataset:-317107.bp_ave</INPUTDATA>
      <INPUTDATA SeqNo="4">dataset:-317107.pulse</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="113" detail="後・脈・血圧">
      <INPUTDATA SeqNo="1">dataset:-317108.bp_high</INPUTDATA>
      <INPUTDATA SeqNo="2">dataset:-317108.bp_low</INPUTDATA>
      <INPUTDATA SeqNo="3">dataset:-317108.bp_ave</INPUTDATA>
      <INPUTDATA SeqNo="4">dataset:-317108.pulse</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="114" detail="抗凝固剤">
      <INPUTDATA SeqNo="1">dataset:-317104.e13</INPUTDATA>
      <INPUTDATA SeqNo="2">dataset:-317104.e14</INPUTDATA>
      <INPUTDATA SeqNo="3">dataset:-317104.e15</INPUTDATA>
      <INPUTDATA SeqNo="4">dataset:-317104.e16</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="115" detail="拮抗剤"/>
  </Content>
</MCSSData>
', '{"dataset": [{"key0": "key0", "ordNo": "ordNo", "sqlCode": -11, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -14}, {"patId": "patId", "sqlCode": -417}, {"patId": "patId", "sqlCode": -418}, {"patId": "patId", "sqlCode": -421}, {"ordNo": "ordNo", "sqlCode": -426}, {"ordNo": "ordNo", "sqlCode": -427}, {"patId": "patId", "sqlCode": -317102}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -317104, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -317105}, {"ordNo": "ordNo", "sqlCode": -317107}, {"ordNo": "ordNo", "sqlCode": -317108}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317111, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -317112, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -317113, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -317114, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -317115}, {"key0": "key0", "patId": "patId", "sqlCode": -317116, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317118, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317120, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317121, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317122, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317123, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -317124, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -317141, "facilityCd": "facilityCd", "is_zero_end": "true"}], "dumpFileName": {"key0": "key0", "sqlCode": -317106, "facilityCd": "facilityCd"}}'::jsonb, '1', '0', -1, '2025-04-07 15:30:21.282', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4170002, 'P_hosp', 'karte_ord', '', 'S', 'upd', 'xml', 'カルテ記載(透析経過データ連携)', 'medicom', 'Medicomのカルテ記載(透析経過データ連携)', '1', '<MCSSData ver="Ver.03.02 2010-01-20">
  <Header>
    <ContentType>dataset:-317124.e03</ContentType>
    <FileVersion>dataset:-317141.e01</FileVersion>
    <InPatientFlag>dataset:-11.in_out_class</InPatientFlag>
    <DepartmentName>dataset:-317104.e12</DepartmentName>
    <DoctorName>dataset:-317111.e01</DoctorName>
    <ConsultationDate>dataset:-14.start_date8a</ConsultationDate>
    <ConsultationTime>dataset:-14.start_date6a</ConsultationTime>
    <ExaminationDate>dataset:-14.start_date8a</ExaminationDate>
    <ExaminationTime>dataset:-14.start_date6a</ExaminationTime>
    <Comment>dataset:-317124.e01</Comment>
    <PatientCode>dataset:-317102.e01</PatientCode>
    <InquirylnpDataFileID>dataset:-317124.e02</InquirylnpDataFileID>
  </Header>
  <Content>
    <Row RowCount="$ROW_COUNT" MasterID="88" detail="血液浄化法">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e01</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="89" detail="透析日">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e02</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="90" detail="予定時間">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e03</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="91" detail="開始時刻">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e04</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="92" detail="終了時刻">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e05</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="93" detail="透析時間">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e06</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="94" detail="透析回数">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e07</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="95" detail="血流量">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e08</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="96" detail="CTR">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e09</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="97" detail="穿刺者">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317112">dataset:-317112.e01</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="98" detail="回収者">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317113">dataset:-317113.e01</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="99" detail="担当者">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317114">dataset:-317114.e01</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="100" detail="ダイアライザ">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e10</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="101" detail="バスキュラーアクセス">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e11</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="102" detail="透析導入日">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-417">dataset:-417.e01</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="103" detail="感染症情報">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-418">dataset:-418.e01</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="104" detail="血液">
      <INPUTDATA SeqNo="1">dataset:-317116.abo</INPUTDATA>
      <INPUTDATA SeqNo="2">dataset:-317116.rh</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="105" detail="透析困難コメント">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-421">dataset:-421.e01</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="124" detail="SOAP" _detail="soap" _sqlCode="-317121" _isZeroDisp="true">
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="125" detail="看護メモ" _detail="nurse_memo" _sqlCode="-317122" _isZeroDisp="true">
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="126" detail="問診記録" _detail="medical_record" _sqlCode="-317123" _isZeroDisp="true">
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="122" detail="Ｄｒ">
      <INPUTDATA SeqNo="1">dataset:-317118.e01</INPUTDATA>
      <INPUTDATA SeqNo="2">dataset:-317118.e02</INPUTDATA>
      <INPUTDATA SeqNo="3">dataset:-317118.e03</INPUTDATA>
      <INPUTDATA SeqNo="4">dataset:-317118.e04</INPUTDATA>
      <INPUTDATA SeqNo="5">dataset:-317118.e05</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="123" detail="担当Ｎｓ">
      <INPUTDATA SeqNo="1">dataset:-317120.e01</INPUTDATA>
      <INPUTDATA SeqNo="2">dataset:-317120.e02</INPUTDATA>
      <INPUTDATA SeqNo="3">dataset:-317120.e03</INPUTDATA>
      <INPUTDATA SeqNo="4">dataset:-317120.e04</INPUTDATA>
      <INPUTDATA SeqNo="5">dataset:-317120.e05</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="110" detail="体重管理">
      <INPUTDATA SeqNo="1">dataset:-426.e01</INPUTDATA>
      <INPUTDATA SeqNo="2">dataset:-426.e02</INPUTDATA>
      <INPUTDATA SeqNo="3">dataset:-426.e03</INPUTDATA>
      <INPUTDATA SeqNo="4">dataset:-426.e04</INPUTDATA>
      <INPUTDATA SeqNo="5">dataset:-426.e05</INPUTDATA>
      <INPUTDATA SeqNo="6">dataset:-426.e06</INPUTDATA>
      <INPUTDATA SeqNo="7">dataset:-426.e07</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="111" detail="除水">
      <INPUTDATA SeqNo="1">dataset:-427.e01</INPUTDATA>
      <INPUTDATA SeqNo="2">dataset:-427.e02</INPUTDATA>
      <INPUTDATA SeqNo="3">dataset:-427.e03</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="112" detail="前・脈・血圧">
      <INPUTDATA SeqNo="1">dataset:-317107.bp_high</INPUTDATA>
      <INPUTDATA SeqNo="2">dataset:-317107.bp_low</INPUTDATA>
      <INPUTDATA SeqNo="3">dataset:-317107.bp_ave</INPUTDATA>
      <INPUTDATA SeqNo="4">dataset:-317107.pulse</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="113" detail="後・脈・血圧">
      <INPUTDATA SeqNo="1">dataset:-317108.bp_high</INPUTDATA>
      <INPUTDATA SeqNo="2">dataset:-317108.bp_low</INPUTDATA>
      <INPUTDATA SeqNo="3">dataset:-317108.bp_ave</INPUTDATA>
      <INPUTDATA SeqNo="4">dataset:-317108.pulse</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="114" detail="抗凝固剤">
      <INPUTDATA SeqNo="1">dataset:-317104.e13</INPUTDATA>
      <INPUTDATA SeqNo="2">dataset:-317104.e14</INPUTDATA>
      <INPUTDATA SeqNo="3">dataset:-317104.e15</INPUTDATA>
      <INPUTDATA SeqNo="4">dataset:-317104.e16</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="115" detail="拮抗剤"/>
  </Content>
</MCSSData>
', '{"dataset": [{"key0": "key0", "ordNo": "ordNo", "sqlCode": -11, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -14}, {"patId": "patId", "sqlCode": -417}, {"patId": "patId", "sqlCode": -418}, {"patId": "patId", "sqlCode": -421}, {"ordNo": "ordNo", "sqlCode": -426}, {"ordNo": "ordNo", "sqlCode": -427}, {"patId": "patId", "sqlCode": -317102}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -317104, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -317105}, {"ordNo": "ordNo", "sqlCode": -317107}, {"ordNo": "ordNo", "sqlCode": -317108}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317111, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -317112, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -317113, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -317114, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -317115}, {"key0": "key0", "patId": "patId", "sqlCode": -317116, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317118, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317120, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317121, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317122, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317123, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -317124, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -317019, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "patId": "patId", "sqlCode": -317141, "facilityCd": "facilityCd", "is_zero_end": "true"}], "dumpFileName": {"key0": "key0", "sqlCode": -317106, "facilityCd": "facilityCd"}}'::jsonb, '1', '0', -1, '2025-04-07 15:30:21.282', CURRENT_TIMESTAMP, 'MED');