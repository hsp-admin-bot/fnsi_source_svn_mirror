delete from "mst_coop_layout" where "ctl_no" in (-4070001,-4070004);
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4070001, 'P_hosp', 'rst_dial', '', 'S', 'cre', 'xml', 'パナソニック 透析実績(処方薬剤連携)', 'Medicom', '透析実績(処方薬剤連携)', '1', '<Consultation_Datas S_Version="1.00">
    <SystemInfo>
        <SystemName>FUTURENET</SystemName>
    </SystemInfo>
    <Consultation_Data>
        <Patient_Info>
            <Patient_ID>dataset:-300001.hosp_pat_id</Patient_ID>
        </Patient_Info>
        <Consultation>
            <Basic_Info Consultation_DataID="$JOURNAL.coop_ord_no">
                <InPatientFlag>dataset:-300001.in_out_class_name</InPatientFlag>
                <Consultation_Date>dataset:-458.start_date14</Consultation_Date>
                <Consultation_Doctor DoctorID="auth_id:-458.staff_cd">staff_name:-458.staff_cd</Consultation_Doctor>
                <Consultation_Type>再診</Consultation_Type>
                <Consultation_Department DepartmentID="dataset:-458.course_cd">dataset:-458.course_name</Consultation_Department>
                <Insurance InsuranceID="dataset:-300001.insu_class">dataset:-300001.insu_name</Insurance>
                <Prescription_INOUT>院外</Prescription_INOUT>
                <Message>dataset:-458.memo</Message>
            </Basic_Info>
            <Order_Info>
                <Order_Category Category="投薬">
                    <Order_Units Order_UnitsID="dataset:-459.order_id00" Application="内服" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-460.medicine_cd" Name="dataset:-460.medicine_name" Count="dataset:-460.amount" Unit="dataset:-460.unit" Cutoff="dataset:-460.cutoff" SeqNo="$COUNT" _sqlCode="-460"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id01" Application="頓服" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-461.medicine_cd" Name="dataset:-461.medicine_name" Count="dataset:-461.amount" Unit="dataset:-461.unit" Cutoff="dataset:-461.cutoff" SeqNo="$COUNT" _sqlCode="-461"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id02" Application="外用" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-462.medicine_cd" Name="dataset:-462.medicine_name" Count="dataset:-462.amount" Unit="dataset:-462.unit" Cutoff="dataset:-462.cutoff" SeqNo="$COUNT" _sqlCode="-462"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id03" Application="自己注射" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-463.medicine_cd" Name="dataset:-463.medicine_name" Count="dataset:-463.amount" Unit="dataset:-463.unit" Cutoff="dataset:-463.cutoff" SeqNo="$COUNT" _sqlCode="-463"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                </Order_Category>
                <Order_Category Category="注射">
                    <Order_Units Order_UnitsID="dataset:-459.order_id20" Application="静注" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-464.medicine_cd" Name="dataset:-464.medicine_name" Count="dataset:-464.amount" Unit="dataset:-464.unit" Cutoff="dataset:-464.cutoff" SeqNo="$COUNT" _sqlCode="-464"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id21" Application="筋注" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-465.medicine_cd" Name="dataset:-465.medicine_name" Count="dataset:-465.amount" Unit="dataset:-465.unit" Cutoff="dataset:-465.cutoff" SeqNo="$COUNT" _sqlCode="-465"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id23" Application="皮内注" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-467.medicine_cd" Name="dataset:-467.medicine_name" Count="dataset:-467.amount" Unit="dataset:-467.unit" Cutoff="dataset:-467.cutoff" SeqNo="$COUNT" _sqlCode="-467"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id22" Application="皮下注" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-466.medicine_cd" Name="dataset:-466.medicine_name" Count="dataset:-466.amount" Unit="dataset:-466.unit" Cutoff="dataset:-466.cutoff" SeqNo="$COUNT" _sqlCode="-466"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id24" Application="点滴" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-468.medicine_cd" Name="dataset:-468.medicine_name" Count="dataset:-468.amount" Unit="dataset:-468.unit" Cutoff="dataset:-468.cutoff" SeqNo="$COUNT" _sqlCode="-468"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id25" Application="特注" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-469.medicine_cd" Name="dataset:-469.medicine_name" Count="dataset:-469.amount" Unit="dataset:-469.unit" Cutoff="dataset:-469.cutoff" SeqNo="$COUNT" _sqlCode="-469"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                </Order_Category>
            </Order_Info>
        </Consultation>
    </Consultation_Data>
</Consultation_Datas>
', '{"dataset": [{"patId": "patId", "sqlCode": -300001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -458}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -459}, {"ordNo": "ordNo", "sqlCode": -460}, {"ordNo": "ordNo", "sqlCode": -461}, {"ordNo": "ordNo", "sqlCode": -462}, {"ordNo": "ordNo", "sqlCode": -463}, {"ordNo": "ordNo", "sqlCode": -464}, {"ordNo": "ordNo", "sqlCode": -465}, {"ordNo": "ordNo", "sqlCode": -466}, {"ordNo": "ordNo", "sqlCode": -467}, {"ordNo": "ordNo", "sqlCode": -468}, {"ordNo": "ordNo", "sqlCode": -469}], "dumpFileName": {"ordNo": "ordNo", "patId": "patId", "sqlCode": -99997}}', '1', '0', 4, '2020-06-05 11:34:51.616', '2020-06-05 11:34:55.028');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4070004, 'P_hosp', 'rst_dial', '', 'S', 'upd', 'xml', 'パナソニック 透析実績(処方薬剤連携)', 'Medicom', '透析実績(処方薬剤連携)', '1', '<Consultation_Datas S_Version="1.00">
    <SystemInfo>
        <SystemName>FUTURENET</SystemName>
    </SystemInfo>
    <Consultation_Data>
        <Patient_Info>
            <Patient_ID>dataset:-300001.hosp_pat_id</Patient_ID>
        </Patient_Info>
        <Consultation>
            <Basic_Info Consultation_DataID="$JOURNAL.coop_ord_no">
                <InPatientFlag>dataset:-300001.in_out_class_name</InPatientFlag>
                <Consultation_Date>dataset:-458.start_date14</Consultation_Date>
                <Consultation_Doctor DoctorID="auth_id:-458.staff_cd">staff_name:-458.staff_cd</Consultation_Doctor>
                <Consultation_Type>再診</Consultation_Type>
                <Consultation_Department DepartmentID="dataset:-458.course_cd">dataset:-458.course_name</Consultation_Department>
                <Insurance InsuranceID="dataset:-300001.insu_class">dataset:-300001.insu_name</Insurance>
                <Prescription_INOUT>院外</Prescription_INOUT>
                <Message>dataset:-458.memo</Message>
            </Basic_Info>
            <Order_Info>
                <Order_Category Category="投薬">
                    <Order_Units Order_UnitsID="dataset:-459.order_id00" Application="内服" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-460.medicine_cd" Name="dataset:-460.medicine_name" Count="dataset:-460.amount" Unit="dataset:-460.unit" Cutoff="dataset:-460.cutoff" SeqNo="$COUNT" _sqlCode="-460"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id01" Application="頓服" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-461.medicine_cd" Name="dataset:-461.medicine_name" Count="dataset:-461.amount" Unit="dataset:-461.unit" Cutoff="dataset:-461.cutoff" SeqNo="$COUNT" _sqlCode="-461"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id02" Application="外用" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-462.medicine_cd" Name="dataset:-462.medicine_name" Count="dataset:-462.amount" Unit="dataset:-462.unit" Cutoff="dataset:-462.cutoff" SeqNo="$COUNT" _sqlCode="-462"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id03" Application="自己注射" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-463.medicine_cd" Name="dataset:-463.medicine_name" Count="dataset:-463.amount" Unit="dataset:-463.unit" Cutoff="dataset:-463.cutoff" SeqNo="$COUNT" _sqlCode="-463"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                </Order_Category>
                <Order_Category Category="注射">
                    <Order_Units Order_UnitsID="dataset:-459.order_id20" Application="静注" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-464.medicine_cd" Name="dataset:-464.medicine_name" Count="dataset:-464.amount" Unit="dataset:-464.unit" Cutoff="dataset:-464.cutoff" SeqNo="$COUNT" _sqlCode="-464"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id21" Application="筋注" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-465.medicine_cd" Name="dataset:-465.medicine_name" Count="dataset:-465.amount" Unit="dataset:-465.unit" Cutoff="dataset:-465.cutoff" SeqNo="$COUNT" _sqlCode="-465"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id23" Application="皮内注" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-467.medicine_cd" Name="dataset:-467.medicine_name" Count="dataset:-467.amount" Unit="dataset:-467.unit" Cutoff="dataset:-467.cutoff" SeqNo="$COUNT" _sqlCode="-467"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id22" Application="皮下注" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-466.medicine_cd" Name="dataset:-466.medicine_name" Count="dataset:-466.amount" Unit="dataset:-466.unit" Cutoff="dataset:-466.cutoff" SeqNo="$COUNT" _sqlCode="-466"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id24" Application="点滴" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-468.medicine_cd" Name="dataset:-468.medicine_name" Count="dataset:-468.amount" Unit="dataset:-468.unit" Cutoff="dataset:-468.cutoff" SeqNo="$COUNT" _sqlCode="-468"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id25" Application="特注" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-469.medicine_cd" Name="dataset:-469.medicine_name" Count="dataset:-469.amount" Unit="dataset:-469.unit" Cutoff="dataset:-469.cutoff" SeqNo="$COUNT" _sqlCode="-469"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                </Order_Category>
            </Order_Info>
        </Consultation>
    </Consultation_Data>
</Consultation_Datas>
', '{"dataset": [{"patId": "patId", "sqlCode": -300001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -458}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -459}, {"ordNo": "ordNo", "sqlCode": -460}, {"ordNo": "ordNo", "sqlCode": -461}, {"ordNo": "ordNo", "sqlCode": -462}, {"ordNo": "ordNo", "sqlCode": -463}, {"ordNo": "ordNo", "sqlCode": -464}, {"ordNo": "ordNo", "sqlCode": -465}, {"ordNo": "ordNo", "sqlCode": -466}, {"ordNo": "ordNo", "sqlCode": -467}, {"ordNo": "ordNo", "sqlCode": -468}, {"ordNo": "ordNo", "sqlCode": -469}], "dumpFileName": {"ordNo": "ordNo", "patId": "patId", "sqlCode": -99997}}', '1', '0', 4, '2020-06-05 11:34:51.616', '2020-06-05 11:34:55.028');
