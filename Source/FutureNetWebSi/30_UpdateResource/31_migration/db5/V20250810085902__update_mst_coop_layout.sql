DELETE FROM mst_coop_layout
WHERE ctl_no IN (-4170001,-4170002);

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
', '{"dataset": [{"key0": "key0", "ordNo": "ordNo", "sqlCode": -11, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -14}, {"patId": "patId", "sqlCode": -417}, {"patId": "patId", "sqlCode": -418}, {"patId": "patId", "sqlCode": -421}, {"ordNo": "ordNo", "sqlCode": -426}, {"ordNo": "ordNo", "sqlCode": -427}, {"patId": "patId", "sqlCode": -317102}, {"ordNo": "ordNo", "sqlCode": -317104, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -317105}, {"ordNo": "ordNo", "sqlCode": -317107}, {"ordNo": "ordNo", "sqlCode": -317108}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317111, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -317112, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -317113, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -317114, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -317115}, {"key0": "key0", "patId": "patId", "sqlCode": -317116, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317118, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317120, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317121, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317122, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317123, "facilityCd": "facilityCd"}, {"sqlCode": -317124, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -317141, "facilityCd": "facilityCd", "is_zero_end": "true"}], "dumpFileName": {"sqlCode": -317106, "facilityCd": "facilityCd"}}'::jsonb, '1', '0', -1, '2025-04-07 15:30:21.282', CURRENT_TIMESTAMP, 'MED');
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
', '{"dataset": [{"key0": "key0", "ordNo": "ordNo", "sqlCode": -11, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -14}, {"patId": "patId", "sqlCode": -417}, {"patId": "patId", "sqlCode": -418}, {"patId": "patId", "sqlCode": -421}, {"ordNo": "ordNo", "sqlCode": -426}, {"ordNo": "ordNo", "sqlCode": -427}, {"patId": "patId", "sqlCode": -317102}, {"ordNo": "ordNo", "sqlCode": -317104, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -317105}, {"ordNo": "ordNo", "sqlCode": -317107}, {"ordNo": "ordNo", "sqlCode": -317108}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317111, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -317112, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -317113, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -317114, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -317115}, {"key0": "key0", "patId": "patId", "sqlCode": -317116, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317118, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317120, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317121, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317122, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317123, "facilityCd": "facilityCd"}, {"sqlCode": -317124, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -317019, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "patId": "patId", "sqlCode": -317141, "facilityCd": "facilityCd", "is_zero_end": "true"}], "dumpFileName": {"sqlCode": -317106, "facilityCd": "facilityCd"}}'::jsonb, '1', '0', -1, '2025-04-07 15:30:21.282', CURRENT_TIMESTAMP, 'MED');