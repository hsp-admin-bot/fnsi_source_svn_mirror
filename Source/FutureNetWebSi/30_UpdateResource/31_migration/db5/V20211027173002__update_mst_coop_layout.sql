delete from "mst_coop_layout" where "facility_cd" = 'P_hosp' and "coop_cd" = 'karte_ord';
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4170001, 'P_hosp', 'karte_ord', '', 'S', 'cre', 'xml', 'カルテ記載(透析経過データ連携)', 'medicom', 'Medicomのカルテ記載(透析経過データ連携)', '1', '<MCSSData ver="Ver.03.80 2011-01-31">
    <Header>
        <ContentType>FactInputData</ContentType>
        <FileVersion>01.00</FileVersion>
        <DepartmentName>dataset:-11.course_name</DepartmentName>
        <DoctorName>dataset:-37.user_name</DoctorName>
        <InPatientFlag>dataset:-11.in_out_class</InPatientFlag>
        <ConsultationDate>dataset:-14.start_date8a</ConsultationDate>
        <ConsultationTime>dataset:-14.start_date6a</ConsultationTime>
        <ExaminationDate>dataset:-14.start_date8a</ExaminationDate>
        <ExaminationTime>dataset:-14.start_date6a</ExaminationTime>
        <Comment>透析経過データ連携</Comment>
        <PatientCode>dataset:1.hosp_pat_id</PatientCode>
        <InquirylnpDataFileID>0</InquirylnpDataFileID>
    </Header>
    <Content>
        <Row RowCount="1" MasterID="88" detail="血液浄化法" >
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-401">dataset:-401.e01</INPUTDATA>
        </Row>
        <Row RowCount="2" MasterID="89" detail="透析日">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-402">dataset:-402.e01</INPUTDATA>
        </Row>
        <Row RowCount="3" MasterID="90" detail="予定時間">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-403">dataset:-403.e01</INPUTDATA>
        </Row>
        <Row RowCount="4" MasterID="91" detail="開始時刻">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-404">dataset:-404.e01</INPUTDATA>
        </Row>
        <Row RowCount="5" MasterID="92" detail="終了時刻">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-405">dataset:-405.e01</INPUTDATA>
        </Row>
        <Row RowCount="6" MasterID="93" detail="透析時間">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-406">dataset:-406.e01</INPUTDATA>
        </Row>
        <Row RowCount="7" MasterID="93" detail="実績時間">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-407">dataset:-407.e01</INPUTDATA>
        </Row>
        <Row RowCount="8" MasterID="94" detail="透析回数">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-408">dataset:-408.e01</INPUTDATA>
        </Row>
        <Row RowCount="9" MasterID="95" detail="血流量">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-409">dataset:-409.e01</INPUTDATA>
        </Row>
        <Row RowCount="10" MasterID="96" detail="CTR">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-410">dataset:-410.e01</INPUTDATA>
        </Row>
        <Row RowCount="11" MasterID="97" detail="穿刺者">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-411">dataset:-411.e01</INPUTDATA>
        </Row>
        <Row RowCount="12" MasterID="98" detail="回収者">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-412">dataset:-412.e01</INPUTDATA>
        </Row>
        <Row RowCount="13" MasterID="99" detail="担当者">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-413">dataset:-413.e01</INPUTDATA>
        </Row>
        <Row RowCount="14" MasterID="100" detail="ダイアライザ">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-414">dataset:-414.e01</INPUTDATA>
        </Row>
        <Row RowCount="15" MasterID="101" detail="ブラッドアクセス">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-415">dataset:-415.e01</INPUTDATA>
        </Row>
        <Row RowCount="16" MasterID="101" detail="バスキュラーアクセス">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-416">dataset:-416.e01</INPUTDATA>
        </Row>
        <Row RowCount="17" MasterID="102" detail="透析導入日">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-417">dataset:-417.e01</INPUTDATA>
        </Row>
        <Row RowCount="18" MasterID="103" detail="感染症情報">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-418">dataset:-418.e01</INPUTDATA>
        </Row>
        <Row RowCount="19" MasterID="104" detail="血液">
            <INPUTDATA SeqNo="1">dataset:-419.abo</INPUTDATA>
            <INPUTDATA SeqNo="2">dataset:-419.rh</INPUTDATA>
        </Row>
        <Row RowCount="20" MasterID="105" detail="透析困難コメント">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-421">dataset:-421.e01</INPUTDATA>
        </Row>
        <Row RowCount="21" MasterID="124" detail="SOAP">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-422">dataset:-422.e01</INPUTDATA>
        </Row>
        <Row RowCount="22" MasterID="125" detail="看護メモ">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-423">dataset:-423.e01</INPUTDATA>
        </Row>
        <Row RowCount="23" MasterID="122" detail="Ｄｒ">
            <INPUTDATA SeqNo="1">dataset:-424.e01</INPUTDATA>
            <INPUTDATA SeqNo="2">dataset:-424.e02</INPUTDATA>
        </Row>
        <Row RowCount="24" MasterID="123" detail="担当Ｎｓ">
            <INPUTDATA SeqNo="1">dataset:-425.e01</INPUTDATA>
            <INPUTDATA SeqNo="2">dataset:-425.e02</INPUTDATA>
        </Row>
        <Row RowCount="25" MasterID="110" detail="体重管理">
            <INPUTDATA SeqNo="1">dataset:-426.e01</INPUTDATA>
            <INPUTDATA SeqNo="2">dataset:-426.e02</INPUTDATA>
            <INPUTDATA SeqNo="3">dataset:-426.e03</INPUTDATA>
            <INPUTDATA SeqNo="4">dataset:-426.e04</INPUTDATA>
            <INPUTDATA SeqNo="5">dataset:-426.e05</INPUTDATA>
            <INPUTDATA SeqNo="6">dataset:-426.e06</INPUTDATA>
            <INPUTDATA SeqNo="7">dataset:-426.e07</INPUTDATA>
        </Row>
        <Row RowCount="26" MasterID="111" detail="除水">
            <INPUTDATA SeqNo="1">dataset:-427.e01</INPUTDATA>
            <INPUTDATA SeqNo="2">dataset:-427.e02</INPUTDATA>
            <INPUTDATA SeqNo="3">dataset:-427.e03</INPUTDATA>
        </Row>
        <Row RowCount="27" MasterID="114" detail="抗凝固剤">
            <INPUTDATA SeqNo="1">dataset:-428.e01</INPUTDATA>
            <INPUTDATA SeqNo="2">dataset:-428.e02</INPUTDATA>
            <INPUTDATA SeqNo="3">dataset:-428.e03</INPUTDATA>
            <INPUTDATA SeqNo="4">dataset:-428.e04</INPUTDATA>
        </Row>
        <Row RowCount="28" MasterID="112" detail="前・脈・血圧">
            <INPUTDATA SeqNo="1">dataset:-35.bp_high</INPUTDATA>
            <INPUTDATA SeqNo="2">dataset:-35.bp_low</INPUTDATA>
            <INPUTDATA SeqNo="3">dataset:-35.bp_ave</INPUTDATA>
            <INPUTDATA SeqNo="4">dataset:-35.pulse</INPUTDATA>
        </Row>
        <Row RowCount="29" MasterID="113" detail="後・脈・血圧">
            <INPUTDATA SeqNo="1">dataset:-36.bp_high</INPUTDATA>
            <INPUTDATA SeqNo="2">dataset:-36.bp_low</INPUTDATA>
            <INPUTDATA SeqNo="3">dataset:-36.bp_ave</INPUTDATA>
            <INPUTDATA SeqNo="4">dataset:-36.pulse</INPUTDATA>
        </Row>
    </Content>
</MCSSData>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": -37}, {"ordNo": "ordNo", "sqlCode": -14}, {"patId": "patId", "sqlCode": 1}, {"ordNo": "ordNo", "sqlCode": -401}, {"ordNo": "ordNo", "sqlCode": -402}, {"ordNo": "ordNo", "sqlCode": -403}, {"ordNo": "ordNo", "sqlCode": -404}, {"ordNo": "ordNo", "sqlCode": -405}, {"ordNo": "ordNo", "sqlCode": -406}, {"ordNo": "ordNo", "sqlCode": -407}, {"ordNo": "ordNo", "sqlCode": -408}, {"ordNo": "ordNo", "sqlCode": -409}, {"ordNo": "ordNo", "sqlCode": -410}, {"ordNo": "ordNo", "sqlCode": -411}, {"ordNo": "ordNo", "sqlCode": -412}, {"ordNo": "ordNo", "sqlCode": -413}, {"ordNo": "ordNo", "sqlCode": -414}, {"ordNo": "ordNo", "sqlCode": -415}, {"ordNo": "ordNo", "sqlCode": -416}, {"patId": "patId", "sqlCode": -417}, {"patId": "patId", "sqlCode": -418}, {"patId": "patId", "sqlCode": -419}, {"patId": "patId", "sqlCode": -421}, {"ordNo": "ordNo", "sqlCode": -422}, {"ordNo": "ordNo", "sqlCode": -423}, {"ordNo": "ordNo", "sqlCode": -424}, {"ordNo": "ordNo", "sqlCode": -425}, {"ordNo": "ordNo", "sqlCode": -426}, {"ordNo": "ordNo", "sqlCode": -427}, {"ordNo": "ordNo", "sqlCode": -428}, {"ordNo": "ordNo", "sqlCode": -35}, {"ordNo": "ordNo", "sqlCode": -36}], "dumpFileName": {"patId": "patId", "sqlCode": -99994}}', '1', '0', 4, '2020-03-31 14:33:42.641', '2020-03-31 14:33:45.599');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4170002, 'P_hosp', 'karte_ord', '', 'S', 'upd', 'xml', 'カルテ記載(透析経過データ連携)', 'medicom', 'Medicomのカルテ記載(透析経過データ連携)', '1', '<MCSSData ver="Ver.03.80 2011-01-31">
    <Header>
        <ContentType>FactInputData</ContentType>
        <FileVersion>01.00</FileVersion>
        <DepartmentName>dataset:-11.course_name</DepartmentName>
        <DoctorName>dataset:-37.user_name</DoctorName>
        <InPatientFlag>dataset:-11.in_out_class</InPatientFlag>
        <ConsultationDate>dataset:-14.start_date8a</ConsultationDate>
        <ConsultationTime>dataset:-14.start_date6a</ConsultationTime>
        <ExaminationDate>dataset:-14.start_date8a</ExaminationDate>
        <ExaminationTime>dataset:-14.start_date6a</ExaminationTime>
        <Comment>透析経過データ連携</Comment>
        <PatientCode>dataset:1.hosp_pat_id</PatientCode>
        <InquirylnpDataFileID>0</InquirylnpDataFileID>
    </Header>
    <Content>
        <Row RowCount="1" MasterID="88" detail="血液浄化法" >
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-401">dataset:-401.e01</INPUTDATA>
        </Row>
        <Row RowCount="2" MasterID="89" detail="透析日">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-402">dataset:-402.e01</INPUTDATA>
        </Row>
        <Row RowCount="3" MasterID="90" detail="予定時間">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-403">dataset:-403.e01</INPUTDATA>
        </Row>
        <Row RowCount="4" MasterID="91" detail="開始時刻">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-404">dataset:-404.e01</INPUTDATA>
        </Row>
        <Row RowCount="5" MasterID="92" detail="終了時刻">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-405">dataset:-405.e01</INPUTDATA>
        </Row>
        <Row RowCount="6" MasterID="93" detail="透析時間">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-406">dataset:-406.e01</INPUTDATA>
        </Row>
        <Row RowCount="7" MasterID="93" detail="実績時間">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-407">dataset:-407.e01</INPUTDATA>
        </Row>
        <Row RowCount="8" MasterID="94" detail="透析回数">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-408">dataset:-408.e01</INPUTDATA>
        </Row>
        <Row RowCount="9" MasterID="95" detail="血流量">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-409">dataset:-409.e01</INPUTDATA>
        </Row>
        <Row RowCount="10" MasterID="96" detail="CTR">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-410">dataset:-410.e01</INPUTDATA>
        </Row>
        <Row RowCount="11" MasterID="97" detail="穿刺者">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-411">dataset:-411.e01</INPUTDATA>
        </Row>
        <Row RowCount="12" MasterID="98" detail="回収者">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-412">dataset:-412.e01</INPUTDATA>
        </Row>
        <Row RowCount="13" MasterID="99" detail="担当者">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-413">dataset:-413.e01</INPUTDATA>
        </Row>
        <Row RowCount="14" MasterID="100" detail="ダイアライザ">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-414">dataset:-414.e01</INPUTDATA>
        </Row>
        <Row RowCount="15" MasterID="101" detail="ブラッドアクセス">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-415">dataset:-415.e01</INPUTDATA>
        </Row>
        <Row RowCount="16" MasterID="101" detail="バスキュラーアクセス">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-416">dataset:-416.e01</INPUTDATA>
        </Row>
        <Row RowCount="17" MasterID="102" detail="透析導入日">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-417">dataset:-417.e01</INPUTDATA>
        </Row>
        <Row RowCount="18" MasterID="103" detail="感染症情報">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-418">dataset:-418.e01</INPUTDATA>
        </Row>
        <Row RowCount="19" MasterID="104" detail="血液">
            <INPUTDATA SeqNo="1">dataset:-419.abo</INPUTDATA>
            <INPUTDATA SeqNo="2">dataset:-419.rh</INPUTDATA>
        </Row>
        <Row RowCount="20" MasterID="105" detail="透析困難コメント">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-421">dataset:-421.e01</INPUTDATA>
        </Row>
        <Row RowCount="21" MasterID="124" detail="SOAP">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-422">dataset:-422.e01</INPUTDATA>
        </Row>
        <Row RowCount="22" MasterID="125" detail="看護メモ">
            <INPUTDATA SeqNo="$COUNT" _sqlCode="-423">dataset:-423.e01</INPUTDATA>
        </Row>
        <Row RowCount="23" MasterID="122" detail="Ｄｒ">
            <INPUTDATA SeqNo="1">dataset:-424.e01</INPUTDATA>
            <INPUTDATA SeqNo="2">dataset:-424.e02</INPUTDATA>
        </Row>
        <Row RowCount="24" MasterID="123" detail="担当Ｎｓ">
            <INPUTDATA SeqNo="1">dataset:-425.e01</INPUTDATA>
            <INPUTDATA SeqNo="2">dataset:-425.e02</INPUTDATA>
        </Row>
        <Row RowCount="25" MasterID="110" detail="体重管理">
            <INPUTDATA SeqNo="1">dataset:-426.e01</INPUTDATA>
            <INPUTDATA SeqNo="2">dataset:-426.e02</INPUTDATA>
            <INPUTDATA SeqNo="3">dataset:-426.e03</INPUTDATA>
            <INPUTDATA SeqNo="4">dataset:-426.e04</INPUTDATA>
            <INPUTDATA SeqNo="5">dataset:-426.e05</INPUTDATA>
            <INPUTDATA SeqNo="6">dataset:-426.e06</INPUTDATA>
            <INPUTDATA SeqNo="7">dataset:-426.e07</INPUTDATA>
        </Row>
        <Row RowCount="26" MasterID="111" detail="除水">
            <INPUTDATA SeqNo="1">dataset:-427.e01</INPUTDATA>
            <INPUTDATA SeqNo="2">dataset:-427.e02</INPUTDATA>
            <INPUTDATA SeqNo="3">dataset:-427.e03</INPUTDATA>
        </Row>
        <Row RowCount="27" MasterID="114" detail="抗凝固剤">
            <INPUTDATA SeqNo="1">dataset:-428.e01</INPUTDATA>
            <INPUTDATA SeqNo="2">dataset:-428.e02</INPUTDATA>
            <INPUTDATA SeqNo="3">dataset:-428.e03</INPUTDATA>
            <INPUTDATA SeqNo="4">dataset:-428.e04</INPUTDATA>
        </Row>
        <Row RowCount="28" MasterID="112" detail="前・脈・血圧">
            <INPUTDATA SeqNo="1">dataset:-35.bp_high</INPUTDATA>
            <INPUTDATA SeqNo="2">dataset:-35.bp_low</INPUTDATA>
            <INPUTDATA SeqNo="3">dataset:-35.bp_ave</INPUTDATA>
            <INPUTDATA SeqNo="4">dataset:-35.pulse</INPUTDATA>
        </Row>
        <Row RowCount="29" MasterID="113" detail="後・脈・血圧">
            <INPUTDATA SeqNo="1">dataset:-36.bp_high</INPUTDATA>
            <INPUTDATA SeqNo="2">dataset:-36.bp_low</INPUTDATA>
            <INPUTDATA SeqNo="3">dataset:-36.bp_ave</INPUTDATA>
            <INPUTDATA SeqNo="4">dataset:-36.pulse</INPUTDATA>
        </Row>
    </Content>
</MCSSData>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": -37}, {"ordNo": "ordNo", "sqlCode": -14}, {"patId": "patId", "sqlCode": 1}, {"ordNo": "ordNo", "sqlCode": -401}, {"ordNo": "ordNo", "sqlCode": -402}, {"ordNo": "ordNo", "sqlCode": -403}, {"ordNo": "ordNo", "sqlCode": -404}, {"ordNo": "ordNo", "sqlCode": -405}, {"ordNo": "ordNo", "sqlCode": -406}, {"ordNo": "ordNo", "sqlCode": -407}, {"ordNo": "ordNo", "sqlCode": -408}, {"ordNo": "ordNo", "sqlCode": -409}, {"ordNo": "ordNo", "sqlCode": -410}, {"ordNo": "ordNo", "sqlCode": -411}, {"ordNo": "ordNo", "sqlCode": -412}, {"ordNo": "ordNo", "sqlCode": -413}, {"ordNo": "ordNo", "sqlCode": -414}, {"ordNo": "ordNo", "sqlCode": -415}, {"ordNo": "ordNo", "sqlCode": -416}, {"patId": "patId", "sqlCode": -417}, {"patId": "patId", "sqlCode": -418}, {"patId": "patId", "sqlCode": -419}, {"patId": "patId", "sqlCode": -421}, {"ordNo": "ordNo", "sqlCode": -422}, {"ordNo": "ordNo", "sqlCode": -423}, {"ordNo": "ordNo", "sqlCode": -424}, {"ordNo": "ordNo", "sqlCode": -425}, {"ordNo": "ordNo", "sqlCode": -426}, {"ordNo": "ordNo", "sqlCode": -427}, {"ordNo": "ordNo", "sqlCode": -428}, {"ordNo": "ordNo", "sqlCode": -35}, {"ordNo": "ordNo", "sqlCode": -36}], "dumpFileName": {"patId": "patId", "sqlCode": -99994}}', '1', '0', 4, '2020-03-31 14:33:42.641', '2020-03-31 14:33:45.599');
