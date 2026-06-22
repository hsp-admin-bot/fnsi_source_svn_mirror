DELETE FROM mst_coop_layout WHERE ctl_no IN (
  -4070001,-4070004,-4070003
  );

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
        <Consultation_Doctor DoctorID="dataset:-307002.doctor_id">dataset:-307003.doctor_name</Consultation_Doctor>
        <Consultation_Type>dataset:-307086.visit_category</Consultation_Type>
        <Consultation_Department DepartmentID="dataset:-307001.department_cd">dataset:-307001.department_name</Consultation_Department>
        <Insurance InsuranceID="dataset:-307004.insurance_id">dataset:-307004.insurance</Insurance>
        <Prescription_INOUT>dataset:-307001.presciption_inout</Prescription_INOUT>
        <Message>dataset:-458.memo</Message>
      </Basic_Info>
      <Order_Info>
        <Order_Category Category="dataset:-307086.category_name_medicine">
          <Order_Units Order_UnitsID="dataset:-307086.order_units_id_00" Application="dataset:-307086.prescription_details_oral" InputUserCode="dataset:-307094.staff_cd" InputUserName="dataset:-307094.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="medicine" _sqlCode="-307008">
            <Order_Administration></Order_Administration>
            <OrderUnits_Memo></OrderUnits_Memo>
          </Order_Units>
          <Order_Units Order_UnitsID="dataset:-307086.order_units_id_01" Application="dataset:-307086.prescription_details_prn" InputUserCode="dataset:-307094.staff_cd" InputUserName="dataset:-307094.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="medicine" _sqlCode="-307010">
            <Order_Administration></Order_Administration>
            <OrderUnits_Memo></OrderUnits_Memo>
          </Order_Units>
          <Order_Units Order_UnitsID="dataset:-307086.order_units_id_02" Application="dataset:-307086.prescription_details_external" InputUserCode="dataset:-307094.staff_cd" InputUserName="dataset:-307094.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="medicine" _sqlCode="-307012">
            <Order_Administration></Order_Administration>
            <OrderUnits_Memo></OrderUnits_Memo>
          </Order_Units>
          <Order_Units Order_UnitsID="dataset:-307086.order_units_id_03" Application="dataset:-307086.prescription_details_self_injection" InputUserCode="dataset:-307094.staff_cd" InputUserName="dataset:-307094.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="medicine" _sqlCode="-307014">
            <Order_Administration></Order_Administration>
            <OrderUnits_Memo></OrderUnits_Memo>
          </Order_Units>
        </Order_Category>
        <Order_Category Category="dataset:-307086.category_name_injection">
          <Order_Units Order_UnitsID="dataset:-307086.order_units_id_20" Application="dataset:-307086.prescription_details_iv_injection" InputUserCode="dataset:-307095.staff_cd" InputUserName="dataset:-307095.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="injection" _sqlCode="-307016">
            <Order_Administration></Order_Administration>
            <OrderUnits_Memo></OrderUnits_Memo>
          </Order_Units>
          <Order_Units Order_UnitsID="dataset:-307086.order_units_id_21" Application="dataset:-307086.prescription_details_im_injection" InputUserCode="dataset:-307095.staff_cd" InputUserName="dataset:-307095.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="injection" _sqlCode="-307018">
            <Order_Administration></Order_Administration>
            <OrderUnits_Memo></OrderUnits_Memo>
          </Order_Units>
          <Order_Units Order_UnitsID="dataset:-307086.order_units_id_23" Application="dataset:-307086.prescription_details_id_injection" InputUserCode="dataset:-307095.staff_cd" InputUserName="dataset:-307095.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="injection" _sqlCode="-307020">
            <Order_Administration></Order_Administration>
            <OrderUnits_Memo></OrderUnits_Memo>
          </Order_Units>
          <Order_Units Order_UnitsID="dataset:-307086.order_units_id_22" Application="dataset:-307086.prescription_details_sc_injection" InputUserCode="dataset:-307095.staff_cd" InputUserName="dataset:-307095.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="injection" _sqlCode="-307022">
            <Order_Administration></Order_Administration>
            <OrderUnits_Memo></OrderUnits_Memo>
          </Order_Units>
          <Order_Units Order_UnitsID="dataset:-307086.order_units_id_24" Application="dataset:-307086.prescription_details_iv_drip" InputUserCode="dataset:-307095.staff_cd" InputUserName="dataset:-307095.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="injection" _sqlCode="-307024">
            <Order_Administration></Order_Administration>
            <OrderUnits_Memo></OrderUnits_Memo>
          </Order_Units>
          <Order_Units Order_UnitsID="dataset:-307086.order_units_id_25" Application="dataset:-307086.prescription_details_custom_made_medication" InputUserCode="dataset:-307095.staff_cd" InputUserName="dataset:-307095.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="injection" _sqlCode="-307026">
            <Order_Administration></Order_Administration>
            <OrderUnits_Memo></OrderUnits_Memo>
          </Order_Units>
        </Order_Category>
        <Order_Category Category="dataset:-307086.category_name_treatment">
          <Order_Units Order_UnitsID="dataset:-307086.order_units_id_treatment" Application="dataset:-307086.prescription_details_treatment" InputUserCode="dataset:-307098.staff_cd" InputUserName="dataset:-307098.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date">
            <Order Code="dataset:-307074.code" Name="dataset:-307074.name" Count="dataset:-307074.count" Unit="dataset:-307074.unit" Cutoff="dataset:-307074.cutoff" SeqNo="dataset:-307074.seq_no" _sqlCode="-307074"/>
            <Order_Administration/>
            <OrderUnits_Memo>dataset:-307076.order_units_memo</OrderUnits_Memo>
          </Order_Units>
        <Order_Units Order_UnitsID="dataset:-307086.order_units_id_oxygen" Application="dataset:-307086.prescription_details_oxygen" InputUserCode="dataset:-307097.staff_cd" InputUserName="dataset:-307097.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date">
          <Order Code="dataset:-307127.code" Name="dataset:-307127.name" Count="dataset:-307127.count" Unit="dataset:-307127.unit" Cutoff="dataset:-307127.cutoff" SeqNo="dataset:-307127.seq_no" _sqlCode="-307127"/>
          <Order_Administration/>
          <OrderUnits_Memo/>
        </Order_Units>
        </Order_Category>
        <Order_Category Category="dataset:-307086.category_name_holiday">
          <Order_Units Order_UnitsID="dataset:-307086.order_units_id_rece_holi" Application="dataset:-307086.prescription_details_holiday" InputUserCode="dataset:-307099.staff_cd" InputUserName="dataset:-307099.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="treatment" _sqlCode="-307063">
            <Order_Administration></Order_Administration>
            <OrderUnits_Memo></OrderUnits_Memo>
          </Order_Units>
        </Order_Category>
        <Order_Category Category="dataset:-307086.category_name_dialysis">
          <Order_Units Order_UnitsID="dataset:-307086.order_units_id_rece_dial" Application="dataset:-307086.prescription_details_dialysis" InputUserCode="dataset:-307101.staff_cd" InputUserName="dataset:-307101.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="treatment" _sqlCode="-307065">
            <Order_Administration></Order_Administration>
            <OrderUnits_Memo></OrderUnits_Memo>
          </Order_Units>
        </Order_Category>
        <Order_Category Category="dataset:-307086.category_name_consultation" _sqlCode="-307069">
          <Order_Units Order_UnitsID="dataset:-307069.order_units_id" Application="dataset:-307086.prescription_details_consultation" InputUserCode="dataset:-307102.staff_cd" InputUserName="dataset:-307102.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date">
            <Order Code="dataset:-307069.code" Name="dataset:-307069.name" Count="dataset:-307069.count" Unit="dataset:-307069.unit" Cutoff="dataset:-307069.cutoff" SeqNo="dataset:-307069.seq_no"/>
            <Order_Administration></Order_Administration>
            <OrderUnits_Memo></OrderUnits_Memo>
          </Order_Units>
        </Order_Category>
        <Order_Category Category="dataset:-307086.category_name_surgery">
          <Order_Units Order_UnitsID="dataset:-307086.order_units_id_surgery" Application="dataset:-307086.prescription_details_surgery" InputUserCode="dataset:-307096.staff_cd" InputUserName="dataset:-307096.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="surgery" _sqlCode="-307071">
            <Order_Administration></Order_Administration>
            <OrderUnits_Memo></OrderUnits_Memo>
          </Order_Units>
        </Order_Category>
        <Order_Category Category="dataset:-307086.category_name_examination">
          <Order_Units Order_UnitsID="dataset:-307073.order_units_id" Application="dataset:-307073.application" InputUserCode="dataset:-307073.input_user_code" InputUserName="dataset:-307073.input_user_name" InputTime="dataset:-307073.input_time" LastUpdateTime="dataset:-307073.last_update_time" _detail="test" _sqlCode="-307073">
            <Order_Administration/>
            <OrderUnits_Memo/>
          </Order_Units>
        </Order_Category>
      </Order_Info>
    </Consultation>
  </Consultation_Data>
</Consultation_Datas>
', '{"dataset": [{"key0": "key0", "patId": "patId", "sqlCode": -307128, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"patId": "patId", "sqlCode": -300001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -458}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -459}, {"ordNo": "ordNo", "sqlCode": -460}, {"ordNo": "ordNo", "sqlCode": -461}, {"ordNo": "ordNo", "sqlCode": -462}, {"ordNo": "ordNo", "sqlCode": -463}, {"ordNo": "ordNo", "sqlCode": -464}, {"ordNo": "ordNo", "sqlCode": -465}, {"ordNo": "ordNo", "sqlCode": -466}, {"ordNo": "ordNo", "sqlCode": -467}, {"ordNo": "ordNo", "sqlCode": -468}, {"ordNo": "ordNo", "sqlCode": -469}, {"ordNo": "ordNo", "sqlCode": -470}, {"ordNo": "ordNo", "sqlCode": -471}, {"ordNo": "ordNo", "sqlCode": -472}, {"ordNo": "ordNo", "sqlCode": -473}, {"ordNo": "ordNo", "sqlCode": -474}, {"ordNo": "ordNo", "sqlCode": -475}, {"ordNo": "ordNo", "sqlCode": -476}, {"ordNo": "ordNo", "sqlCode": -477}, {"ordNo": "ordNo", "sqlCode": -478}, {"ordNo": "ordNo", "sqlCode": -479}, {"ordNo": "ordNo", "sqlCode": -480}, {"ordNo": "ordNo", "sqlCode": -481}, {"ordNo": "ordNo", "sqlCode": -482}, {"ordNo": "ordNo", "sqlCode": -483}, {"ordNo": "ordNo", "sqlCode": -484}, {"ordNo": "ordNo", "sqlCode": -485}, {"ordNo": "ordNo", "sqlCode": -486}, {"ordNo": "ordNo", "sqlCode": -487}, {"ordNo": "ordNo", "sqlCode": -488}, {"ordNo": "ordNo", "sqlCode": -489}, {"ordNo": "ordNo", "sqlCode": -490}, {"ordNo": "ordNo", "sqlCode": -491}, {"ordNo": "ordNo", "sqlCode": -492}, {"ordNo": "ordNo", "sqlCode": -493}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307001, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307002, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307003, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307004}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -307005}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -307007, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307008, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307009}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307010, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307011}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307012, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307013}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307014, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307015}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307016, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307017}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307018, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307019}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307020, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307021}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307022, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307023}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307024, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307025}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307026, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307027}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307028, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307029}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307030, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307031}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307032, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307033}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307035, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307036}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307037, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307038}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307039, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307040}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307041, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307042}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307043, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307044}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307045, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307046}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307047, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307048}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307049, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307050}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307051, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307052}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307053, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307054}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307055, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307056}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307057, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307058}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307059, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307060}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307061, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307062}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307063, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307064}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307065, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307066}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307067, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307068}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307069, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307070}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307071, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307072}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307073, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307074, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307076, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307094, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307095, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307096, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307097, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307098, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307099, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307101, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307102, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307086, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307093}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307127, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "patId": "patId", "sqlCode": -99997}}'::jsonb, '1', '0', 5843, '2025-04-03 10:57:10.878', CURRENT_TIMESTAMP, 'MED');
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
        <Consultation_Doctor DoctorID="dataset:-307002.doctor_id">dataset:-307003.doctor_name</Consultation_Doctor>
        <Consultation_Type>dataset:-307086.visit_category</Consultation_Type>
        <Consultation_Department DepartmentID="dataset:-307001.department_cd">dataset:-307001.department_name</Consultation_Department>
        <Insurance InsuranceID="dataset:-307004.insurance_id">dataset:-307004.insurance</Insurance>
        <Prescription_INOUT>dataset:-307001.presciption_inout</Prescription_INOUT>
        <Message>dataset:-458.memo</Message>
      </Basic_Info>
      <Order_Info>
        <Order_Category Category="dataset:-307086.category_name_medicine">
          <Order_Units Order_UnitsID="dataset:-307086.order_units_id_00" Application="dataset:-307086.prescription_details_oral" InputUserCode="dataset:-307094.staff_cd" InputUserName="dataset:-307094.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="medicine" _sqlCode="-307008">
            <Order_Administration></Order_Administration>
            <OrderUnits_Memo></OrderUnits_Memo>
          </Order_Units>
          <Order_Units Order_UnitsID="dataset:-307086.order_units_id_01" Application="dataset:-307086.prescription_details_prn" InputUserCode="dataset:-307094.staff_cd" InputUserName="dataset:-307094.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="medicine" _sqlCode="-307010">
            <Order_Administration></Order_Administration>
            <OrderUnits_Memo></OrderUnits_Memo>
          </Order_Units>
          <Order_Units Order_UnitsID="dataset:-307086.order_units_id_02" Application="dataset:-307086.prescription_details_external" InputUserCode="dataset:-307094.staff_cd" InputUserName="dataset:-307094.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="medicine" _sqlCode="-307012">
            <Order_Administration></Order_Administration>
            <OrderUnits_Memo></OrderUnits_Memo>
          </Order_Units>
          <Order_Units Order_UnitsID="dataset:-307086.order_units_id_03" Application="dataset:-307086.prescription_details_self_injection" InputUserCode="dataset:-307094.staff_cd" InputUserName="dataset:-307094.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="medicine" _sqlCode="-307014">
            <Order_Administration></Order_Administration>
            <OrderUnits_Memo></OrderUnits_Memo>
          </Order_Units>
        </Order_Category>
        <Order_Category Category="dataset:-307086.category_name_injection">
          <Order_Units Order_UnitsID="dataset:-307086.order_units_id_20" Application="dataset:-307086.prescription_details_iv_injection" InputUserCode="dataset:-307095.staff_cd" InputUserName="dataset:-307095.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="injection" _sqlCode="-307016">
            <Order_Administration></Order_Administration>
            <OrderUnits_Memo></OrderUnits_Memo>
          </Order_Units>
          <Order_Units Order_UnitsID="dataset:-307086.order_units_id_21" Application="dataset:-307086.prescription_details_im_injection" InputUserCode="dataset:-307095.staff_cd" InputUserName="dataset:-307095.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="injection" _sqlCode="-307018">
            <Order_Administration></Order_Administration>
            <OrderUnits_Memo></OrderUnits_Memo>
          </Order_Units>
          <Order_Units Order_UnitsID="dataset:-307086.order_units_id_23" Application="dataset:-307086.prescription_details_id_injection" InputUserCode="dataset:-307095.staff_cd" InputUserName="dataset:-307095.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="injection" _sqlCode="-307020">
            <Order_Administration></Order_Administration>
            <OrderUnits_Memo></OrderUnits_Memo>
          </Order_Units>
          <Order_Units Order_UnitsID="dataset:-307086.order_units_id_22" Application="dataset:-307086.prescription_details_sc_injection" InputUserCode="dataset:-307095.staff_cd" InputUserName="dataset:-307095.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="injection" _sqlCode="-307022">
            <Order_Administration></Order_Administration>
            <OrderUnits_Memo></OrderUnits_Memo>
          </Order_Units>
          <Order_Units Order_UnitsID="dataset:-307086.order_units_id_24" Application="dataset:-307086.prescription_details_iv_drip" InputUserCode="dataset:-307095.staff_cd" InputUserName="dataset:-307095.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="injection" _sqlCode="-307024">
            <Order_Administration></Order_Administration>
            <OrderUnits_Memo></OrderUnits_Memo>
          </Order_Units>
          <Order_Units Order_UnitsID="dataset:-307086.order_units_id_25" Application="dataset:-307086.prescription_details_custom_made_medication" InputUserCode="dataset:-307095.staff_cd" InputUserName="dataset:-307095.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="injection" _sqlCode="-307026">
            <Order_Administration></Order_Administration>
            <OrderUnits_Memo></OrderUnits_Memo>
          </Order_Units>
        </Order_Category>
        <Order_Category Category="dataset:-307086.category_name_treatment">
          <Order_Units Order_UnitsID="dataset:-307086.order_units_id_treatment" Application="dataset:-307086.prescription_details_treatment" InputUserCode="dataset:-307098.staff_cd" InputUserName="dataset:-307098.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date">
            <Order Code="dataset:-307074.code" Name="dataset:-307074.name" Count="dataset:-307074.count" Unit="dataset:-307074.unit" Cutoff="dataset:-307074.cutoff" SeqNo="dataset:-307074.seq_no" _sqlCode="-307074"/>
            <Order_Administration/>
            <OrderUnits_Memo>dataset:-307076.order_units_memo</OrderUnits_Memo>
          </Order_Units>
        <Order_Units Order_UnitsID="dataset:-307086.order_units_id_oxygen" Application="dataset:-307086.prescription_details_oxygen" InputUserCode="dataset:-307097.staff_cd" InputUserName="dataset:-307097.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date">
          <Order Code="dataset:-307127.code" Name="dataset:-307127.name" Count="dataset:-307127.count" Unit="dataset:-307127.unit" Cutoff="dataset:-307127.cutoff" SeqNo="dataset:-307127.seq_no" _sqlCode="-307127"/>
          <Order_Administration/>
          <OrderUnits_Memo/>
        </Order_Units>
        </Order_Category>
        <Order_Category Category="dataset:-307086.category_name_holiday">
          <Order_Units Order_UnitsID="dataset:-307086.order_units_id_rece_holi" Application="dataset:-307086.prescription_details_holiday" InputUserCode="dataset:-307099.staff_cd" InputUserName="dataset:-307099.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="treatment" _sqlCode="-307063">
            <Order_Administration></Order_Administration>
            <OrderUnits_Memo></OrderUnits_Memo>
          </Order_Units>
        </Order_Category>
        <Order_Category Category="dataset:-307086.category_name_dialysis">
          <Order_Units Order_UnitsID="dataset:-307086.order_units_id_rece_dial" Application="dataset:-307086.prescription_details_dialysis" InputUserCode="dataset:-307101.staff_cd" InputUserName="dataset:-307101.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="treatment" _sqlCode="-307065">
            <Order_Administration></Order_Administration>
            <OrderUnits_Memo></OrderUnits_Memo>
          </Order_Units>
        </Order_Category>
        <Order_Category Category="dataset:-307086.category_name_consultation" _sqlCode="-307069">
          <Order_Units Order_UnitsID="dataset:-307069.order_units_id" Application="dataset:-307086.prescription_details_consultation" InputUserCode="dataset:-307102.staff_cd" InputUserName="dataset:-307102.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date">
            <Order Code="dataset:-307069.code" Name="dataset:-307069.name" Count="dataset:-307069.count" Unit="dataset:-307069.unit" Cutoff="dataset:-307069.cutoff" SeqNo="dataset:-307069.seq_no"/>
            <Order_Administration></Order_Administration>
            <OrderUnits_Memo></OrderUnits_Memo>
          </Order_Units>
        </Order_Category>
        <Order_Category Category="dataset:-307086.category_name_surgery">
          <Order_Units Order_UnitsID="dataset:-307086.order_units_id_surgery" Application="dataset:-307086.prescription_details_surgery" InputUserCode="dataset:-307096.staff_cd" InputUserName="dataset:-307096.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="surgery" _sqlCode="-307071">
            <Order_Administration></Order_Administration>
            <OrderUnits_Memo></OrderUnits_Memo>
          </Order_Units>
        </Order_Category>
        <Order_Category Category="dataset:-307086.category_name_examination">
          <Order_Units Order_UnitsID="dataset:-307073.order_units_id" Application="dataset:-307073.application" InputUserCode="dataset:-307073.input_user_code" InputUserName="dataset:-307073.input_user_name" InputTime="dataset:-307073.input_time" LastUpdateTime="dataset:-307073.last_update_time" _detail="test" _sqlCode="-307073">
            <Order_Administration/>
            <OrderUnits_Memo/>
          </Order_Units>
        </Order_Category>
      </Order_Info>
    </Consultation>
  </Consultation_Data>
</Consultation_Datas>
', '{"dataset": [{"key0": "key0", "patId": "patId", "sqlCode": -307128, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"patId": "patId", "sqlCode": -300001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -458}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -459}, {"ordNo": "ordNo", "sqlCode": -460}, {"ordNo": "ordNo", "sqlCode": -461}, {"ordNo": "ordNo", "sqlCode": -462}, {"ordNo": "ordNo", "sqlCode": -463}, {"ordNo": "ordNo", "sqlCode": -464}, {"ordNo": "ordNo", "sqlCode": -465}, {"ordNo": "ordNo", "sqlCode": -466}, {"ordNo": "ordNo", "sqlCode": -467}, {"ordNo": "ordNo", "sqlCode": -468}, {"ordNo": "ordNo", "sqlCode": -469}, {"ordNo": "ordNo", "sqlCode": -470}, {"ordNo": "ordNo", "sqlCode": -471}, {"ordNo": "ordNo", "sqlCode": -472}, {"ordNo": "ordNo", "sqlCode": -473}, {"ordNo": "ordNo", "sqlCode": -474}, {"ordNo": "ordNo", "sqlCode": -475}, {"ordNo": "ordNo", "sqlCode": -476}, {"ordNo": "ordNo", "sqlCode": -477}, {"ordNo": "ordNo", "sqlCode": -478}, {"ordNo": "ordNo", "sqlCode": -479}, {"ordNo": "ordNo", "sqlCode": -480}, {"ordNo": "ordNo", "sqlCode": -481}, {"ordNo": "ordNo", "sqlCode": -482}, {"ordNo": "ordNo", "sqlCode": -483}, {"ordNo": "ordNo", "sqlCode": -484}, {"ordNo": "ordNo", "sqlCode": -485}, {"ordNo": "ordNo", "sqlCode": -486}, {"ordNo": "ordNo", "sqlCode": -487}, {"ordNo": "ordNo", "sqlCode": -488}, {"ordNo": "ordNo", "sqlCode": -489}, {"ordNo": "ordNo", "sqlCode": -490}, {"ordNo": "ordNo", "sqlCode": -491}, {"ordNo": "ordNo", "sqlCode": -492}, {"ordNo": "ordNo", "sqlCode": -493}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307001, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307002, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307003, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307004}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -307005}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -307007, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307008, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307009}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307010, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307011}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307012, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307013}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307014, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307015}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307016, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307017}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307018, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307019}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307020, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307021}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307022, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307023}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307024, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307025}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307026, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307027}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307028, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307029}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307030, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307031}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307032, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307033}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307035, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307036}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307037, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307038}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307039, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307040}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307041, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307042}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307043, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307044}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307045, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307046}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307047, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307048}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307049, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307050}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307051, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307052}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307053, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307054}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307055, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307056}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307057, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307058}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307059, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307060}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307061, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307062}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307063, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307064}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307065, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307066}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307067, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307068}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307069, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307070}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307071, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307072}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307073, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307074, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307076, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307094, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307095, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307096, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307097, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307098, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307099, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307101, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307102, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307086, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307093}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307127, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "patId": "patId", "sqlCode": -99997}}'::jsonb, '1', '0', 5843, '2025-04-03 10:57:10.878', CURRENT_TIMESTAMP, 'MED');


INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4070003, 'P_hosp', 'rst_dial', '', 'S', 'del', 'xml', 'パナソニック 透析実績(処方薬剤連携)', 'Medicom', '透析実績(処方薬剤連携)', '1', '<Consultation_Datas S_Version="1.00">
  <SystemInfo>
    <SystemName>FUTURENET</SystemName>
  </SystemInfo>
  <Consultation_Data>
    <Patient_Info>
      <Patient_ID>dataset:-300001.hosp_pat_id</Patient_ID>
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
', '{"dataset": [{"key0": "key0", "patId": "patId", "sqlCode": -307128, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"patId": "patId", "sqlCode": -300001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -458}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307001, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307002, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307003, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307004}, {"ordNo": "ordNo", "sqlCode": -307085}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307087, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307088, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307089, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "patId": "patId", "sqlCode": -307084}}'::jsonb, '1', '0', 5843, '2025-04-09 17:49:49.574', CURRENT_TIMESTAMP, 'MED');