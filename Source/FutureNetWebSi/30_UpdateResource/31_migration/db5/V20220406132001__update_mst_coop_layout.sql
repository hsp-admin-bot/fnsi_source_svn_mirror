DELETE FROM "ntss"."mst_coop_layout" where "ctl_no" IN (-5170001,-5170002);
INSERT INTO "ntss"."mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-5170001, 'S_hosp', 'karte_ord', '', 'S', 'cre', 'xml', 'SSI', 'SSI', 'karte', '1', '<SsiData Type="KARTE_NOTIFY">
    <NotifyDate>$SYSDATE yyyyMMdd</NotifyDate><!-- yyyyMMdd,yyyy/MM/dd,yyyy-MM-dd -->
    <NotifyTime>$SYSTIME HHmmss</NotifyTime><!-- HHmmssSSS,HHmmss,HH:mm:ss.SSS,HH:mm:ss -->
    <Karte>
        <PatientID>dataset:-500001.hosp_pat_id8</PatientID><!-- パラメータをジャーナルのid -->
        <AccessionNumber>dataset:-11.ord_no12</AccessionNumber>
        <OperateMode>NW</OperateMode>
        <Class>0060</Class>
        <Nyuugai>dataset:-11.in_out_s</Nyuugai>
        <SnkCode>dataset:-11.course_cd</SnkCode>
        <Syosaisin></Syosaisin>
        <Importance></Importance>
        <InsuranceNo></InsuranceNo>
        <SubTitle></SubTitle>
        <MakeUser UserID="dataset:-38.user_id">staff_name:-38.user_id</MakeUser><!-- パラメータをジャーナルのid -->
        <MakeDate>dataset:-14.start_date8</MakeDate>
        <MakeTime>dataset:-14.start_date6</MakeTime>
        <InpUser UserID="dataset:-38.user_id">staff_name:-38.user_id</InpUser><!-- パラメータをジャーナルのid -->
        <InpDate>dataset:-38.inp_date</InpDate>
        <InpTime>dataset:-38.inp_time</InpTime>
        <Document>
            <Content>dataset:-65.values</Content>
        </Document>
    </Karte>
</SsiData>
', '{"dataset": [{"patId": "patId", "sqlCode": -500001}, {"ordNo": "ordNo", "sqlCode": -11}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -38}, {"ordNo": "ordNo", "sqlCode": -14}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -65, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -1}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99987}}', '1', '0', 4, '2020-05-22 09:38:28.418', CURRENT_TIMESTAMP);
INSERT INTO "ntss"."mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-5170002, 'S_hosp', 'karte_ord', '', 'S', 'upd', 'xml', 'SSI', 'SSI', 'karte', '1', '<SsiData Type="KARTE_NOTIFY">
    <NotifyDate>$SYSDATE yyyyMMdd</NotifyDate><!-- yyyyMMdd,yyyy/MM/dd,yyyy-MM-dd -->
    <NotifyTime>$SYSTIME HHmmss</NotifyTime><!-- HHmmssSSS,HHmmss,HH:mm:ss.SSS,HH:mm:ss -->
    <Karte>
        <PatientID>dataset:-500001.hosp_pat_id8</PatientID><!-- パラメータをジャーナルのid -->
        <AccessionNumber>dataset:-11.ord_no12</AccessionNumber>
        <OperateMode>NW</OperateMode>
        <Class>0060</Class>
        <Nyuugai>dataset:-11.in_out_s</Nyuugai>
        <SnkCode>dataset:-11.course_cd</SnkCode>
        <Syosaisin></Syosaisin>
        <Importance></Importance>
        <InsuranceNo></InsuranceNo>
        <SubTitle></SubTitle>
        <MakeUser UserID="dataset:-38.user_id">staff_name:-38.user_id</MakeUser><!-- パラメータをジャーナルのid -->
        <MakeDate>dataset:-14.start_date8</MakeDate>
        <MakeTime>dataset:-14.start_date6</MakeTime>
        <InpUser UserID="dataset:-38.user_id">staff_name:-38.user_id</InpUser><!-- パラメータをジャーナルのid -->
        <InpDate>dataset:-38.inp_date</InpDate>
        <InpTime>dataset:-38.inp_time</InpTime>
        <Document>
            <Content>dataset:-65.values</Content>
        </Document>
    </Karte>
</SsiData>
', '{"dataset": [{"patId": "patId", "sqlCode": -500001}, {"ordNo": "ordNo", "sqlCode": -11}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -38}, {"ordNo": "ordNo", "sqlCode": -14}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -65, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -1}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99987}}', '1', '0', 4, '2020-05-22 09:38:28.418', CURRENT_TIMESTAMP);
