delete from "mst_coop_layout" where "ctl_no" in (-5040001,-5040002,-5040003);
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-5040001, 'S_hosp', 'ind_dial', '', 'S', 'cre', 'xml', 'SSI', 'SSI', '予定送信', '1', '<SsiData Type="DIALYSISPLAN">
    <PlanData>
        <PatientID>dataset:-500001.hosp_pat_id8</PatientID>
        <DIALYSIS_DATE>dataset:-13.dialysis_date</DIALYSIS_DATE>
        <DIALYSIS_NO>const:0</DIALYSIS_NO>
        <BED_NO>dataset:-13.bed_cd1</BED_NO>
        <BED_NAME>dataset:-13.bed_name</BED_NAME>
        <KUR_CD>dataset:-13.kur_cd1</KUR_CD>
        <KUR_NAME>dataset:-13.kur_name</KUR_NAME>
        <VALID>0</VALID>
        <DIALYSIS_TIME>dataset:-13.dialysis_time_m</DIALYSIS_TIME>
        <DIALYSIS_COND info="透析条件情報">
            <COND_INFO CTL_NO="dataset:-307.e01" _sqlCode="-307">
                <DIALYSIS_ITEM_NAME>dataset:-307.e02</DIALYSIS_ITEM_NAME>
                <VALUE>dataset:-307.e03</VALUE>
                <VALUE_NAME>dataset:-307.e04</VALUE_NAME>
                <UNIT>dataset:-307.e05</UNIT>
            </COND_INFO>
        </DIALYSIS_COND>
        <DIALYSIS_EQUIP info="医材詳細">
            <EQUIP_INFO CTL_NO="dataset:-305.cost_no" _sqlCode="-305">
                <EQUIP_CD>dataset:-305.e01</EQUIP_CD>
                <EQUIP_NAME>dataset:-305.e02</EQUIP_NAME>
                <EQUIP_CLASS_NAME>dataset:-305.e03</EQUIP_CLASS_NAME>
                <PUNCTURE_CLASS>dataset:-305.e04</PUNCTURE_CLASS>
                <AMOUNT>dataset:-305.e05</AMOUNT>
                <UNIT>dataset:-305.e06</UNIT>
            </EQUIP_INFO>
        </DIALYSIS_EQUIP>
        <DIALYSIS_MEDI info="薬剤詳細">
            <MEDI_INFO CTL_NO="dataset:-306.cost_no" _sqlCode="-306">
                <MEDICINE_CD>dataset:-306.e01</MEDICINE_CD>
                <MEDICINE_NAME>dataset:-306.e02</MEDICINE_NAME>
                <MEDI_CLASS_NAME>dataset:-306.e03</MEDI_CLASS_NAME>
                <AMOUNT>dataset:-306.e04</AMOUNT>
                <UNIT>dataset:-306.e05</UNIT>
                <PROCEDURE_CD>dataset:-306.e06</PROCEDURE_CD>
                <PROCEDURE_NAME>dataset:-306.e07</PROCEDURE_NAME>
            </MEDI_INFO>
        </DIALYSIS_MEDI>
    </PlanData>
</SsiData>', '{"dataset": [{"patId": "patId", "sqlCode": -500001}, {"ordNo": "ordNo", "sqlCode": -13}, {"ordNo": "ordNo", "sqlCode": -305}, {"ordNo": "ordNo", "sqlCode": -306}, {"ordNo": "ordNo", "sqlCode": -307}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99989}}', '1', '0', 4, '2020-05-25 11:02:55.825', '2020-05-25 11:03:01.324');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-5040002, 'S_hosp', 'ind_dial', '', 'S', 'upd', 'xml', 'SSI', 'SSI', '予定送信', '1', '<SsiData Type="DIALYSISPLAN">
    <PlanData>
        <PatientID>dataset:-500001.hosp_pat_id8</PatientID>
        <DIALYSIS_DATE>dataset:-13.dialysis_date</DIALYSIS_DATE>
        <DIALYSIS_NO>const:0</DIALYSIS_NO>
        <BED_NO>dataset:-13.bed_cd1</BED_NO>
        <BED_NAME>dataset:-13.bed_name</BED_NAME>
        <KUR_CD>dataset:-13.kur_cd1</KUR_CD>
        <KUR_NAME>dataset:-13.kur_name</KUR_NAME>
        <VALID>1</VALID>
        <DIALYSIS_TIME>dataset:-13.dialysis_time_m</DIALYSIS_TIME>
        <DIALYSIS_COND info="透析条件情報">
            <COND_INFO CTL_NO="dataset:-307.e01" _sqlCode="-307">
                <DIALYSIS_ITEM_NAME>dataset:-307.e02</DIALYSIS_ITEM_NAME>
                <VALUE>dataset:-307.e03</VALUE>
                <VALUE_NAME>dataset:-307.e04</VALUE_NAME>
                <UNIT>dataset:-307.e05</UNIT>
            </COND_INFO>
        </DIALYSIS_COND>
        <DIALYSIS_EQUIP info="医材詳細">
            <EQUIP_INFO CTL_NO="dataset:-305.cost_no" _sqlCode="-305">
                <EQUIP_CD>dataset:-305.e01</EQUIP_CD>
                <EQUIP_NAME>dataset:-305.e02</EQUIP_NAME>
                <EQUIP_CLASS_NAME>dataset:-305.e03</EQUIP_CLASS_NAME>
                <PUNCTURE_CLASS>dataset:-305.e04</PUNCTURE_CLASS>
                <AMOUNT>dataset:-305.e05</AMOUNT>
                <UNIT>dataset:-305.e06</UNIT>
            </EQUIP_INFO>
        </DIALYSIS_EQUIP>
        <DIALYSIS_MEDI info="薬剤詳細">
            <MEDI_INFO CTL_NO="dataset:-306.cost_no" _sqlCode="-306">
                <MEDICINE_CD>dataset:-306.e01</MEDICINE_CD>
                <MEDICINE_NAME>dataset:-306.e02</MEDICINE_NAME>
                <MEDI_CLASS_NAME>dataset:-306.e03</MEDI_CLASS_NAME>
                <AMOUNT>dataset:-306.e04</AMOUNT>
                <UNIT>dataset:-306.e05</UNIT>
                <PROCEDURE_CD>dataset:-306.e06</PROCEDURE_CD>
                <PROCEDURE_NAME>dataset:-306.e07</PROCEDURE_NAME>
            </MEDI_INFO>
        </DIALYSIS_MEDI>
    </PlanData>
</SsiData>', '{"dataset": [{"patId": "patId", "sqlCode": -500001}, {"ordNo": "ordNo", "sqlCode": -13}, {"ordNo": "ordNo", "sqlCode": -305}, {"ordNo": "ordNo", "sqlCode": -306}, {"ordNo": "ordNo", "sqlCode": -307}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99989}}', '1', '0', 4, '2020-05-25 11:02:55.825', '2020-05-25 11:03:01.324');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-5040003, 'S_hosp', 'ind_dial', '', 'S', 'del', 'xml', 'SSI', 'SSI', '予定送信', '1', '<SsiData Type="DIALYSISPLAN">
    <PlanData>
        <PatientID>dataset:-500001.hosp_pat_id8</PatientID>
        <DIALYSIS_DATE>dataset:-13.dialysis_date</DIALYSIS_DATE>
        <DIALYSIS_NO>const:0</DIALYSIS_NO>
        <BED_NO>dataset:-13.bed_cd1</BED_NO>
        <BED_NAME>dataset:-13.bed_name</BED_NAME>
        <KUR_CD>dataset:-13.kur_cd1</KUR_CD>
        <KUR_NAME>dataset:-13.kur_name</KUR_NAME>
        <VALID>9</VALID>
        <DIALYSIS_TIME>dataset:-13.dialysis_time_m</DIALYSIS_TIME>
        <DIALYSIS_COND info="透析条件情報">
            <COND_INFO CTL_NO="dataset:-307.e01" _sqlCode="-307">
                <DIALYSIS_ITEM_NAME>dataset:-307.e02</DIALYSIS_ITEM_NAME>
                <VALUE>dataset:-307.e03</VALUE>
                <VALUE_NAME>dataset:-307.e04</VALUE_NAME>
                <UNIT>dataset:-307.e05</UNIT>
            </COND_INFO>
        </DIALYSIS_COND>
        <DIALYSIS_EQUIP info="医材詳細">
            <EQUIP_INFO CTL_NO="dataset:-305.cost_no" _sqlCode="-305">
                <EQUIP_CD>dataset:-305.e01</EQUIP_CD>
                <EQUIP_NAME>dataset:-305.e02</EQUIP_NAME>
                <EQUIP_CLASS_NAME>dataset:-305.e03</EQUIP_CLASS_NAME>
                <PUNCTURE_CLASS>dataset:-305.e04</PUNCTURE_CLASS>
                <AMOUNT>dataset:-305.e05</AMOUNT>
                <UNIT>dataset:-305.e06</UNIT>
            </EQUIP_INFO>
        </DIALYSIS_EQUIP>
        <DIALYSIS_MEDI info="薬剤詳細">
            <MEDI_INFO CTL_NO="dataset:-306.cost_no" _sqlCode="-306">
                <MEDICINE_CD>dataset:-306.e01</MEDICINE_CD>
                <MEDICINE_NAME>dataset:-306.e02</MEDICINE_NAME>
                <MEDI_CLASS_NAME>dataset:-306.e03</MEDI_CLASS_NAME>
                <AMOUNT>dataset:-306.e04</AMOUNT>
                <UNIT>dataset:-306.e05</UNIT>
                <PROCEDURE_CD>dataset:-306.e06</PROCEDURE_CD>
                <PROCEDURE_NAME>dataset:-306.e07</PROCEDURE_NAME>
            </MEDI_INFO>
        </DIALYSIS_MEDI>
    </PlanData>
</SsiData>', '{"dataset": [{"patId": "patId", "sqlCode": -500001}, {"ordNo": "ordNo", "sqlCode": -13}, {"ordNo": "ordNo", "sqlCode": -305}, {"ordNo": "ordNo", "sqlCode": -306}, {"ordNo": "ordNo", "sqlCode": -307}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99989}}', '1', '0', 4, '2020-05-25 11:02:55.825', '2020-05-25 11:03:01.324');
