delete from "ntss"."mst_coop_layout" where "ctl_no" in (-7040003,-7040002,-7040001);
INSERT INTO "ntss"."mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-7040002, 'NEC-iS', 'exam_rst', 'send_time', 'S', 'cre', 'xml', 'NEC-iS 検査結果連携(定時一括送信用）', 'NEC-iS(MegaOakiS)', '検査結果連携（要求応答型の送受信）', '1', NULL, '{"dataset": [{"sqlCode": -2400, "facilityCd": "facilityCd", "PreSqlInfoItem": ["@ord_no", "@pat_id"]}]}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO "ntss"."mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-7040001, 'NEC-iS', 'exam_rst', '', 'S', 'cre', 'xml', 'NEC-iS 検査結果連携', 'NEC-iS(MegaOakiS)', '検査結果連携（要求応答型の送受信）', '1', '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
<soap:Body>
  <Request xmlns="http://medical.nec.co.jp/">
    <requestData>
      <Request>
        <Header>
          <Command>B01_GeneralTestResultsByPatientIdAndPeriod</Command>
          <Type>SELECT</Type>
          <Conditions>
            <Condition>
              <PatientId>dataset:-1004.hosp_pat_id10</PatientId>
              <StartDate>dataset:-1003.start_date</StartDate>
              <StartTime>0000</StartTime>
              <EndDate>dataset:-1003.end_date</EndDate>
              <EndTime>2359</EndTime>
            </Condition>
          </Conditions>
          <RequesterInfomation>
            <EventDateTime>$SYSDATE yyyy/MM/dd HH:mm:ss</EventDateTime>
            <UserId></UserId>
            <UserName></UserName>
            <ProfessionCode></ProfessionCode>
            <ProfessionName></ProfessionName>
            <DepartmentCode></DepartmentCode>
            <DepartmentName></DepartmentName>
            <SystemIdTypeCode>4</SystemIdTypeCode>
            <SystemId>dataset:-1003.system_id</SystemId>
            <ComputerIdTypeCode></ComputerIdTypeCode>
            <ComputerId></ComputerId>
            <ApplicationName></ApplicationName>
          </RequesterInfomation>
        </Header>
        <Contents>
        </Contents>
      </Request>
    </requestData>
  </Request>
</soap:Body>
</soap:Envelope>', '{"dataset": [{"sqlCode": -1003, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "sqlCode": -1004}]}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO "ntss"."mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-7040003, 'NEC-iS', 'exam_rst', '', 'S', 'upd', 'xml', 'NEC-iS 検査結果連携', 'NEC-iS(MegaOakiS)', '検査結果連携（要求応答型の送受信）', '1', '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
<soap:Body>
  <Request xmlns="http://medical.nec.co.jp/">
    <requestData>
      <Request>
        <Header>
          <Command>B01_GeneralTestResultsByPatientIdAndPeriod</Command>
          <Type>SELECT</Type>
          <Conditions>
            <Condition>
              <PatientId>dataset:-1004.hosp_pat_id10</PatientId>
              <StartDate>dataset:-1003.start_date</StartDate>
              <StartTime>0000</StartTime>
              <EndDate>dataset:-1003.end_date</EndDate>
              <EndTime>2359</EndTime>
            </Condition>
          </Conditions>
          <RequesterInfomation>
            <EventDateTime>$SYSDATE yyyy/MM/dd HH:mm:ss</EventDateTime>
            <UserId></UserId>
            <UserName></UserName>
            <ProfessionCode></ProfessionCode>
            <ProfessionName></ProfessionName>
            <DepartmentCode></DepartmentCode>
            <DepartmentName></DepartmentName>
            <SystemIdTypeCode>4</SystemIdTypeCode>
            <SystemId>dataset:-1003.system_id</SystemId>
            <ComputerIdTypeCode></ComputerIdTypeCode>
            <ComputerId></ComputerId>
            <ApplicationName></ApplicationName>
          </RequesterInfomation>
        </Header>
        <Contents>
        </Contents>
      </Request>
    </requestData>
  </Request>
</soap:Body>
</soap:Envelope>', '{"dataset": [{"sqlCode": -1003, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "sqlCode": -1004}]}', '1', '0', -1, '2021-12-14 06:06:01.279', '2021-12-14 06:06:01.279');
