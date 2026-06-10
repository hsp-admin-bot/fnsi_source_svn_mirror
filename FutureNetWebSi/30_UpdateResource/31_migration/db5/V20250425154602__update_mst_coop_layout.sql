DELETE FROM ntss.mst_coop_layout
WHERE ctl_no=-4070003;

INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4070003, 'P_hosp', 'rst_dial', '', 'S', 'del', 'xml', 'パナソニック 透析実績(処方薬剤連携)', 'Medicom', '透析実績(処方薬剤連携)', '1', '<Consultation_Datas S_Version="1.00">
  <SystemInfo>
    <SystemName>dataset:-307086.device_identifier</SystemName>
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
', '{"dataset": [{"key0": "key0", "patId": "patId", "sqlCode": -307128, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"patId": "patId", "sqlCode": -306001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -458}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307001, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307002, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307003, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -307004}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -307085, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -307086, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -307087, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307088, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -307089, "facilityCd": "facilityCd"}], "dumpFileName": {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -307084, "facilityCd": "facilityCd"}}'::jsonb, '1', '0', 5843, '2025-04-25 14:36:48.396', current_timestamp, 'MED');