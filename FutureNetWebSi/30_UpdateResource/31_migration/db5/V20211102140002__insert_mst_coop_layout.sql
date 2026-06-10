delete from "mst_coop_layout" where "ctl_no" in (-4070001,-4070004);
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
                        <Order Code="dataset:-460.e01" Name="dataset:-460.e02" Count="dataset:-460.e03" Unit="dataset:-460.e04" Cutoff="dataset:-460.e05" SeqNo="$COUNT" _sqlCode="-460"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id01" Application="頓服" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-461.e01" Name="dataset:-461.e02" Count="dataset:-461.e03" Unit="dataset:-461.e04" Cutoff="dataset:-461.e05" SeqNo="$COUNT" _sqlCode="-461"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id02" Application="外用" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-462.e01" Name="dataset:-462.e02" Count="dataset:-462.e03" Unit="dataset:-462.e04" Cutoff="dataset:-462.e05" SeqNo="$COUNT" _sqlCode="-462"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id03" Application="自己注射" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-463.e01" Name="dataset:-463.e02" Count="dataset:-463.e03" Unit="dataset:-463.e04" Cutoff="dataset:-463.e05" SeqNo="$COUNT" _sqlCode="-463"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                </Order_Category>
                <Order_Category Category="注射">
                    <Order_Units Order_UnitsID="dataset:-459.order_id20" Application="静注" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-464.e01" Name="dataset:-464.e02" Count="dataset:-464.e03" Unit="dataset:-464.e04" Cutoff="dataset:-464.e05" SeqNo="$COUNT" _sqlCode="-464"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id21" Application="筋注" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-465.e01" Name="dataset:-465.e02" Count="dataset:-465.e03" Unit="dataset:-465.e04" Cutoff="dataset:-465.e05" SeqNo="$COUNT" _sqlCode="-465"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id23" Application="皮内注" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-467.e01" Name="dataset:-467.e02" Count="dataset:-467.e03" Unit="dataset:-467.e04" Cutoff="dataset:-467.e05" SeqNo="$COUNT" _sqlCode="-467"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id22" Application="皮下注" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-466.e01" Name="dataset:-466.e02" Count="dataset:-466.e03" Unit="dataset:-466.e04" Cutoff="dataset:-466.e05" SeqNo="$COUNT" _sqlCode="-466"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id24" Application="点滴" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-468.e01" Name="dataset:-468.e02" Count="dataset:-468.e03" Unit="dataset:-468.e04" Cutoff="dataset:-468.e05" SeqNo="$COUNT" _sqlCode="-468"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id25" Application="特注" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-469.e01" Name="dataset:-469.e02" Count="dataset:-469.e03" Unit="dataset:-469.e04" Cutoff="dataset:-469.e05" SeqNo="$COUNT" _sqlCode="-469"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                </Order_Category>
                <Order_Category Category="処置">
                    <Order_Units Order_UnitsID="dataset:-459.order_id30" Application="処置" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-470.e01" Name="dataset:-470.e02" Count="dataset:-470.e03" Unit="dataset:-470.e04" Cutoff="dataset:-470.e05" SeqNo="$COUNT" _sqlCode="-470"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id40" Application="処置" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-471.e01" Name="dataset:-471.e02" Count="dataset:-471.e03" Unit="dataset:-471.e04" Cutoff="dataset:-471.e05" SeqNo="$COUNT" _sqlCode="-471"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id31" Application="処置" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-472.e01" Name="dataset:-472.e02" Count="dataset:-472.e03" Unit="dataset:-472.e04" Cutoff="dataset:-472.e05" SeqNo="$COUNT" _sqlCode="-472"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id32" Application="処置" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-473.e01" Name="dataset:-473.e02" Count="dataset:-473.e03" Unit="dataset:-473.e04" Cutoff="dataset:-473.e05" SeqNo="$COUNT" _sqlCode="-473"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                </Order_Category>
                <Order_Category Category="診察">
                    <Order_Units Order_UnitsID="dataset:-459.order_id41" Application="診察" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-474.e01" Name="dataset:-474.e02" Count="dataset:-474.e03" Unit="dataset:-474.e04" Cutoff="dataset:-474.e05" SeqNo="$COUNT" _sqlCode="-474"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id42" Application="診察" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-475.e01" Name="dataset:-475.e02" Count="dataset:-475.e03" Unit="dataset:-475.e04" Cutoff="dataset:-475.e05" SeqNo="$COUNT" _sqlCode="-475"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id43" Application="診察" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-476.e01" Name="dataset:-476.e02" Count="dataset:-476.e03" Unit="dataset:-476.e04" Cutoff="dataset:-476.e05" SeqNo="$COUNT" _sqlCode="-476"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id44" Application="診察" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-477.e01" Name="dataset:-477.e02" Count="dataset:-477.e03" Unit="dataset:-477.e04" Cutoff="dataset:-477.e05" SeqNo="$COUNT" _sqlCode="-477"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id45" Application="診察" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-478.e01" Name="dataset:-478.e02" Count="dataset:-478.e03" Unit="dataset:-478.e04" Cutoff="dataset:-478.e05" SeqNo="$COUNT" _sqlCode="-478"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id46" Application="診察" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-479.e01" Name="dataset:-479.e02" Count="dataset:-479.e03" Unit="dataset:-479.e04" Cutoff="dataset:-479.e05" SeqNo="$COUNT" _sqlCode="-479"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id47" Application="診察" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-480.e01" Name="dataset:-480.e02" Count="dataset:-480.e03" Unit="dataset:-480.e04" Cutoff="dataset:-480.e05" SeqNo="$COUNT" _sqlCode="-480"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id48" Application="診察" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-481.e01" Name="dataset:-481.e02" Count="dataset:-481.e03" Unit="dataset:-481.e04" Cutoff="dataset:-481.e05" SeqNo="$COUNT" _sqlCode="-481"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id49" Application="診察" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-482.e01" Name="dataset:-482.e02" Count="dataset:-482.e03" Unit="dataset:-482.e04" Cutoff="dataset:-482.e05" SeqNo="$COUNT" _sqlCode="-482"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                </Order_Category>
                <Order_Category Category="手術・麻酔">
                    <Order_Units Order_UnitsID="dataset:-459.order_id50" Application="手術・麻酔" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-483.e01" Name="dataset:-483.e02" Count="dataset:-483.e03" Unit="dataset:-483.e04" Cutoff="dataset:-483.e05" SeqNo="$COUNT" _sqlCode="-483"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                </Order_Category>
                <Order_Category Category="検査">
                    <Order_Units Order_UnitsID="dataset:-459.order_id60" Application="検査" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-484.e01" Name="dataset:-484.e02" Count="dataset:-484.e03" Unit="dataset:-484.e04" Cutoff="dataset:-484.e05" SeqNo="$COUNT" _sqlCode="-484"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id61" Application="検査" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-485.e01" Name="dataset:-485.e02" Count="dataset:-485.e03" Unit="dataset:-485.e04" Cutoff="dataset:-485.e05" SeqNo="$COUNT" _sqlCode="-485"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id62" Application="検査" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-486.e01" Name="dataset:-486.e02" Count="dataset:-486.e03" Unit="dataset:-486.e04" Cutoff="dataset:-486.e05" SeqNo="$COUNT" _sqlCode="-486"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id63" Application="検査" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-487.e01" Name="dataset:-487.e02" Count="dataset:-487.e03" Unit="dataset:-487.e04" Cutoff="dataset:-487.e05" SeqNo="$COUNT" _sqlCode="-487"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id64" Application="検査" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-488.e01" Name="dataset:-488.e02" Count="dataset:-488.e03" Unit="dataset:-488.e04" Cutoff="dataset:-488.e05" SeqNo="$COUNT" _sqlCode="-488"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id65" Application="検査" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-489.e01" Name="dataset:-489.e02" Count="dataset:-489.e03" Unit="dataset:-489.e04" Cutoff="dataset:-489.e05" SeqNo="$COUNT" _sqlCode="-489"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id66" Application="検査" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-490.e01" Name="dataset:-490.e02" Count="dataset:-490.e03" Unit="dataset:-490.e04" Cutoff="dataset:-490.e05" SeqNo="$COUNT" _sqlCode="-490"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id67" Application="検査" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-491.e01" Name="dataset:-491.e02" Count="dataset:-491.e03" Unit="dataset:-491.e04" Cutoff="dataset:-491.e05" SeqNo="$COUNT" _sqlCode="-491"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id68" Application="検査" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-492.e01" Name="dataset:-492.e02" Count="dataset:-492.e03" Unit="dataset:-492.e04" Cutoff="dataset:-492.e05" SeqNo="$COUNT" _sqlCode="-492"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id69" Application="検査" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-493.e01" Name="dataset:-493.e02" Count="dataset:-493.e03" Unit="dataset:-493.e04" Cutoff="dataset:-493.e05" SeqNo="$COUNT" _sqlCode="-493"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                </Order_Category>
            </Order_Info>
        </Consultation>
    </Consultation_Data>
</Consultation_Datas>
', '{"dataset": [{"patId": "patId", "sqlCode": -300001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -458}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -459}, {"ordNo": "ordNo", "sqlCode": -460}, {"ordNo": "ordNo", "sqlCode": -461}, {"ordNo": "ordNo", "sqlCode": -462}, {"ordNo": "ordNo", "sqlCode": -463}, {"ordNo": "ordNo", "sqlCode": -464}, {"ordNo": "ordNo", "sqlCode": -465}, {"ordNo": "ordNo", "sqlCode": -466}, {"ordNo": "ordNo", "sqlCode": -467}, {"ordNo": "ordNo", "sqlCode": -468}, {"ordNo": "ordNo", "sqlCode": -469}, {"ordNo": "ordNo", "sqlCode": -470}, {"ordNo": "ordNo", "sqlCode": -471}, {"ordNo": "ordNo", "sqlCode": -472}, {"ordNo": "ordNo", "sqlCode": -473}, {"ordNo": "ordNo", "sqlCode": -474}, {"ordNo": "ordNo", "sqlCode": -475}, {"ordNo": "ordNo", "sqlCode": -476}, {"ordNo": "ordNo", "sqlCode": -477}, {"ordNo": "ordNo", "sqlCode": -478}, {"ordNo": "ordNo", "sqlCode": -479}, {"ordNo": "ordNo", "sqlCode": -480}, {"ordNo": "ordNo", "sqlCode": -481}, {"ordNo": "ordNo", "sqlCode": -482}, {"ordNo": "ordNo", "sqlCode": -483}, {"ordNo": "ordNo", "sqlCode": -484}, {"ordNo": "ordNo", "sqlCode": -485}, {"ordNo": "ordNo", "sqlCode": -486}, {"ordNo": "ordNo", "sqlCode": -487}, {"ordNo": "ordNo", "sqlCode": -488}, {"ordNo": "ordNo", "sqlCode": -489}, {"ordNo": "ordNo", "sqlCode": -490}, {"ordNo": "ordNo", "sqlCode": -491}, {"ordNo": "ordNo", "sqlCode": -492}, {"ordNo": "ordNo", "sqlCode": -493}], "dumpFileName": {"ordNo": "ordNo", "patId": "patId", "sqlCode": -99997}}', '1', '0', 4, '2020-06-05 11:34:51.616', '2020-06-05 11:34:55.028');
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
                        <Order Code="dataset:-460.e01" Name="dataset:-460.e02" Count="dataset:-460.e03" Unit="dataset:-460.e04" Cutoff="dataset:-460.e05" SeqNo="$COUNT" _sqlCode="-460"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id01" Application="頓服" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-461.e01" Name="dataset:-461.e02" Count="dataset:-461.e03" Unit="dataset:-461.e04" Cutoff="dataset:-461.e05" SeqNo="$COUNT" _sqlCode="-461"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id02" Application="外用" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-462.e01" Name="dataset:-462.e02" Count="dataset:-462.e03" Unit="dataset:-462.e04" Cutoff="dataset:-462.e05" SeqNo="$COUNT" _sqlCode="-462"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id03" Application="自己注射" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-463.e01" Name="dataset:-463.e02" Count="dataset:-463.e03" Unit="dataset:-463.e04" Cutoff="dataset:-463.e05" SeqNo="$COUNT" _sqlCode="-463"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                </Order_Category>
                <Order_Category Category="注射">
                    <Order_Units Order_UnitsID="dataset:-459.order_id20" Application="静注" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-464.e01" Name="dataset:-464.e02" Count="dataset:-464.e03" Unit="dataset:-464.e04" Cutoff="dataset:-464.e05" SeqNo="$COUNT" _sqlCode="-464"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id21" Application="筋注" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-465.e01" Name="dataset:-465.e02" Count="dataset:-465.e03" Unit="dataset:-465.e04" Cutoff="dataset:-465.e05" SeqNo="$COUNT" _sqlCode="-465"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id23" Application="皮内注" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-467.e01" Name="dataset:-467.e02" Count="dataset:-467.e03" Unit="dataset:-467.e04" Cutoff="dataset:-467.e05" SeqNo="$COUNT" _sqlCode="-467"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id22" Application="皮下注" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-466.e01" Name="dataset:-466.e02" Count="dataset:-466.e03" Unit="dataset:-466.e04" Cutoff="dataset:-466.e05" SeqNo="$COUNT" _sqlCode="-466"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id24" Application="点滴" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-468.e01" Name="dataset:-468.e02" Count="dataset:-468.e03" Unit="dataset:-468.e04" Cutoff="dataset:-468.e05" SeqNo="$COUNT" _sqlCode="-468"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id25" Application="特注" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-469.e01" Name="dataset:-469.e02" Count="dataset:-469.e03" Unit="dataset:-469.e04" Cutoff="dataset:-469.e05" SeqNo="$COUNT" _sqlCode="-469"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                </Order_Category>
                <Order_Category Category="処置">
                    <Order_Units Order_UnitsID="dataset:-459.order_id30" Application="処置" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-470.e01" Name="dataset:-470.e02" Count="dataset:-470.e03" Unit="dataset:-470.e04" Cutoff="dataset:-470.e05" SeqNo="$COUNT" _sqlCode="-470"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id40" Application="処置" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-471.e01" Name="dataset:-471.e02" Count="dataset:-471.e03" Unit="dataset:-471.e04" Cutoff="dataset:-471.e05" SeqNo="$COUNT" _sqlCode="-471"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id31" Application="処置" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-472.e01" Name="dataset:-472.e02" Count="dataset:-472.e03" Unit="dataset:-472.e04" Cutoff="dataset:-472.e05" SeqNo="$COUNT" _sqlCode="-472"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id32" Application="処置" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-473.e01" Name="dataset:-473.e02" Count="dataset:-473.e03" Unit="dataset:-473.e04" Cutoff="dataset:-473.e05" SeqNo="$COUNT" _sqlCode="-473"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                </Order_Category>
                <Order_Category Category="診察">
                    <Order_Units Order_UnitsID="dataset:-459.order_id41" Application="診察" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-474.e01" Name="dataset:-474.e02" Count="dataset:-474.e03" Unit="dataset:-474.e04" Cutoff="dataset:-474.e05" SeqNo="$COUNT" _sqlCode="-474"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id42" Application="診察" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-475.e01" Name="dataset:-475.e02" Count="dataset:-475.e03" Unit="dataset:-475.e04" Cutoff="dataset:-475.e05" SeqNo="$COUNT" _sqlCode="-475"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id43" Application="診察" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-476.e01" Name="dataset:-476.e02" Count="dataset:-476.e03" Unit="dataset:-476.e04" Cutoff="dataset:-476.e05" SeqNo="$COUNT" _sqlCode="-476"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id44" Application="診察" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-477.e01" Name="dataset:-477.e02" Count="dataset:-477.e03" Unit="dataset:-477.e04" Cutoff="dataset:-477.e05" SeqNo="$COUNT" _sqlCode="-477"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id45" Application="診察" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-478.e01" Name="dataset:-478.e02" Count="dataset:-478.e03" Unit="dataset:-478.e04" Cutoff="dataset:-478.e05" SeqNo="$COUNT" _sqlCode="-478"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id46" Application="診察" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-479.e01" Name="dataset:-479.e02" Count="dataset:-479.e03" Unit="dataset:-479.e04" Cutoff="dataset:-479.e05" SeqNo="$COUNT" _sqlCode="-479"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id47" Application="診察" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-480.e01" Name="dataset:-480.e02" Count="dataset:-480.e03" Unit="dataset:-480.e04" Cutoff="dataset:-480.e05" SeqNo="$COUNT" _sqlCode="-480"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id48" Application="診察" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-481.e01" Name="dataset:-481.e02" Count="dataset:-481.e03" Unit="dataset:-481.e04" Cutoff="dataset:-481.e05" SeqNo="$COUNT" _sqlCode="-481"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id49" Application="診察" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-482.e01" Name="dataset:-482.e02" Count="dataset:-482.e03" Unit="dataset:-482.e04" Cutoff="dataset:-482.e05" SeqNo="$COUNT" _sqlCode="-482"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                </Order_Category>
                <Order_Category Category="手術・麻酔">
                    <Order_Units Order_UnitsID="dataset:-459.order_id50" Application="手術・麻酔" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-483.e01" Name="dataset:-483.e02" Count="dataset:-483.e03" Unit="dataset:-483.e04" Cutoff="dataset:-483.e05" SeqNo="$COUNT" _sqlCode="-483"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                </Order_Category>
                <Order_Category Category="検査">
                    <Order_Units Order_UnitsID="dataset:-459.order_id60" Application="検査" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-484.e01" Name="dataset:-484.e02" Count="dataset:-484.e03" Unit="dataset:-484.e04" Cutoff="dataset:-484.e05" SeqNo="$COUNT" _sqlCode="-484"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id61" Application="検査" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-485.e01" Name="dataset:-485.e02" Count="dataset:-485.e03" Unit="dataset:-485.e04" Cutoff="dataset:-485.e05" SeqNo="$COUNT" _sqlCode="-485"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id62" Application="検査" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-486.e01" Name="dataset:-486.e02" Count="dataset:-486.e03" Unit="dataset:-486.e04" Cutoff="dataset:-486.e05" SeqNo="$COUNT" _sqlCode="-486"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id63" Application="検査" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-487.e01" Name="dataset:-487.e02" Count="dataset:-487.e03" Unit="dataset:-487.e04" Cutoff="dataset:-487.e05" SeqNo="$COUNT" _sqlCode="-487"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id64" Application="検査" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-488.e01" Name="dataset:-488.e02" Count="dataset:-488.e03" Unit="dataset:-488.e04" Cutoff="dataset:-488.e05" SeqNo="$COUNT" _sqlCode="-488"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id65" Application="検査" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-489.e01" Name="dataset:-489.e02" Count="dataset:-489.e03" Unit="dataset:-489.e04" Cutoff="dataset:-489.e05" SeqNo="$COUNT" _sqlCode="-489"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id66" Application="検査" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-490.e01" Name="dataset:-490.e02" Count="dataset:-490.e03" Unit="dataset:-490.e04" Cutoff="dataset:-490.e05" SeqNo="$COUNT" _sqlCode="-490"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id67" Application="検査" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-491.e01" Name="dataset:-491.e02" Count="dataset:-491.e03" Unit="dataset:-491.e04" Cutoff="dataset:-491.e05" SeqNo="$COUNT" _sqlCode="-491"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id68" Application="検査" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-492.e01" Name="dataset:-492.e02" Count="dataset:-492.e03" Unit="dataset:-492.e04" Cutoff="dataset:-492.e05" SeqNo="$COUNT" _sqlCode="-492"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                    <Order_Units Order_UnitsID="dataset:-459.order_id69" Application="検査" InputUserCode="dataset:-459.ind_user_id" InputUserName="dataset:-459.ind_user_name" InputTime="dataset:-459.rst_start_date" LastUpdateTime="dataset:-459.up_date">
                        <Order Code="dataset:-493.e01" Name="dataset:-493.e02" Count="dataset:-493.e03" Unit="dataset:-493.e04" Cutoff="dataset:-493.e05" SeqNo="$COUNT" _sqlCode="-493"/>
                        <Order_Administration />
                        <OrderUnits_Memo />
                    </Order_Units>
                </Order_Category>
            </Order_Info>
        </Consultation>
    </Consultation_Data>
</Consultation_Datas>
', '{"dataset": [{"patId": "patId", "sqlCode": -300001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -458}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -459}, {"ordNo": "ordNo", "sqlCode": -460}, {"ordNo": "ordNo", "sqlCode": -461}, {"ordNo": "ordNo", "sqlCode": -462}, {"ordNo": "ordNo", "sqlCode": -463}, {"ordNo": "ordNo", "sqlCode": -464}, {"ordNo": "ordNo", "sqlCode": -465}, {"ordNo": "ordNo", "sqlCode": -466}, {"ordNo": "ordNo", "sqlCode": -467}, {"ordNo": "ordNo", "sqlCode": -468}, {"ordNo": "ordNo", "sqlCode": -469}, {"ordNo": "ordNo", "sqlCode": -470}, {"ordNo": "ordNo", "sqlCode": -471}, {"ordNo": "ordNo", "sqlCode": -472}, {"ordNo": "ordNo", "sqlCode": -473}, {"ordNo": "ordNo", "sqlCode": -474}, {"ordNo": "ordNo", "sqlCode": -475}, {"ordNo": "ordNo", "sqlCode": -476}, {"ordNo": "ordNo", "sqlCode": -477}, {"ordNo": "ordNo", "sqlCode": -478}, {"ordNo": "ordNo", "sqlCode": -479}, {"ordNo": "ordNo", "sqlCode": -480}, {"ordNo": "ordNo", "sqlCode": -481}, {"ordNo": "ordNo", "sqlCode": -482}, {"ordNo": "ordNo", "sqlCode": -483}, {"ordNo": "ordNo", "sqlCode": -484}, {"ordNo": "ordNo", "sqlCode": -485}, {"ordNo": "ordNo", "sqlCode": -486}, {"ordNo": "ordNo", "sqlCode": -487}, {"ordNo": "ordNo", "sqlCode": -488}, {"ordNo": "ordNo", "sqlCode": -489}, {"ordNo": "ordNo", "sqlCode": -490}, {"ordNo": "ordNo", "sqlCode": -491}, {"ordNo": "ordNo", "sqlCode": -492}, {"ordNo": "ordNo", "sqlCode": -493}], "dumpFileName": {"ordNo": "ordNo", "patId": "patId", "sqlCode": -99997}}', '1', '0', 4, '2020-06-05 11:34:51.616', '2020-06-05 11:34:55.028');
