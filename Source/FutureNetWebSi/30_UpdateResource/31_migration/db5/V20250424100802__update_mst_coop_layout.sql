DELETE FROM ntss.mst_coop_layout
WHERE ctl_no=-4070001;
DELETE FROM ntss.mst_coop_layout
WHERE ctl_no=-4070004;

INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4070001, 'P_hosp', 'rst_dial', '', 'S', 'cre', 'xml', 'パナソニック 透析実績(処方薬剤連携)', 'Medicom', '透析実績(処方薬剤連携)', '1', '<Consultation_Datas S_Version="dataset:-307086.s_version">
  <SystemInfo>
    <SystemName>dataset:-307086.device_identifier</SystemName>
  </SystemInfo>
  <Consultation_Data>
    <Patient_Info>
      <Patient_ID>dataset:-300001.hosp_pat_id</Patient_ID>
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
', '{"dataset": [{"patId": "patId", "sqlCode": -300001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -458}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307001, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307002, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307003, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307004}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307069, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307086, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307093}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307098, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307102, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307131, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307132, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307133, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307134, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307135, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307136, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307137, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "patId": "patId", "sqlCode": -99997}}'::jsonb, '1', '0', 5843, '2025-04-22 15:54:25.194', current_timestamp, 'MED');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4070004, 'P_hosp', 'rst_dial', '', 'S', 'upd', 'xml', 'パナソニック 透析実績(処方薬剤連携)', 'Medicom', '透析実績(処方薬剤連携)', '1', '<Consultation_Datas S_Version="dataset:-307086.s_version">
    <SystemInfo>
      <SystemName>dataset:-307086.device_identifier</SystemName>
    </SystemInfo>
    <Consultation_Data>
      <Patient_Info>
        <Patient_ID>dataset:-300001.hosp_pat_id</Patient_ID>
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
          <Order_Category Category="dataset:-307086.category_name_medicine" _detail="medicine_units" _sqlCode="-307131" />
          <Order_Category Category="dataset:-307086.category_name_injection" _detail="injection_units" _sqlCode="-307132" />
          <Order_Category Category="dataset:-307086.category_name_treatment" _detail="treatment_units" _sqlCode="-307133" />
          <Order_Category Category="dataset:-307086.category_name_holiday" _detail="holiday_units" _sqlCode="-307134" />
          <Order_Category Category="dataset:-307086.category_name_dialysis" _detail="dialysis_units" _sqlCode="-307135" />
          <Order_Category Category="dataset:-307086.category_name_consultation" _sqlCode="-307069">
            <Order_Units Order_UnitsID="dataset:-307069.order_units_id" Application="dataset:-307086.prescription_details_consultation" InputUserCode="dataset:-307102.staff_cd" InputUserName="dataset:-307102.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date">
              <Order Code="dataset:-307069.code" Name="dataset:-307069.name" Count="dataset:-307069.count" Unit="dataset:-307069.unit" Cutoff="dataset:-307069.cutoff" SeqNo="dataset:-307069.seq_no"/>
              <Order_Administration/>
              <OrderUnits_Memo/>
            </Order_Units>
          </Order_Category>
          <Order_Category Category="dataset:-307086.category_name_surgery" _detail="surgery_units" _sqlCode="-307136" />
          <Order_Category Category="dataset:-307086.category_name_examination" _detail="examination_units" _sqlCode="-307137" />
        </Order_Info>
      </Consultation>
    </Consultation_Data>
  </Consultation_Datas>
  ', '{"dataset": [{"patId": "patId", "sqlCode": -300001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -458}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307001, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307002, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307003, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307004}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307069, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307086, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307093}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307098, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307102, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307131, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307132, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307133, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307134, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307135, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307136, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307137, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "patId": "patId", "sqlCode": -99997}}'::jsonb, '1', '0', 5843, '2025-04-22 15:54:25.194', current_timestamp, 'MED');