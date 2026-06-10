delete from "mst_coop_layout" where "ctl_no" in (-5070001,-5070002,-5070003);
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-5070001, 'S_hosp', 'rst_dial', '', 'S', 'cre', 'xml', 'SSI', 'SSI', '実績送信', '1', '<SsiData Type="DIALYSISRST">
    <RSTData>
        <PatientID>dataset:-500001.hosp_pat_id8</PatientID>
        <DIALYSIS_DATE>dataset:-11.treat_date</DIALYSIS_DATE>
        <DIALYSIS_NO>dataset:-11.ord_no</DIALYSIS_NO>
        <BED_NO>dataset:-11.bed_cd1</BED_NO>
        <BED_NAME>dataset:-11.bed_name</BED_NAME>
        <KUR_CD>dataset:-11.kur_cd1</KUR_CD>
        <KUR_NAME>dataset:-11.kur_name</KUR_NAME>
        <VALID>0</VALID>
        <DEVICE_NO>dataset:-11.machine_no</DEVICE_NO>
        <DEVICE_NAME>dataset:-11.machine_name</DEVICE_NAME>
        <START_DATE>dataset:-11.start_date</START_DATE>
        <END_DATE>dataset:-11.end_date</END_DATE>
        <DIALYSIS_TIME>dataset:-11.running_time_cal</DIALYSIS_TIME>
        <WEIGHT_BEFORE>dataset:-11.weight_before</WEIGHT_BEFORE>
        <WEIGHT_AFTER>dataset:-11.weight_after</WEIGHT_AFTER>
        <BP_BEFORE_MAX>dataset:-35.bp_high</BP_BEFORE_MAX>
        <BP_BEFORE_MIN>dataset:-35.bp_low</BP_BEFORE_MIN>
        <BP_AFTER_MAX>dataset:-36.bp_high</BP_AFTER_MAX>
        <BP_AFTER_MIN>dataset:-36.bp_low</BP_AFTER_MIN>
        <PULSE_BEFORE>dataset:-35.pulse</PULSE_BEFORE>
        <PULSE_AFTER>dataset:-36.pulse</PULSE_AFTER>
        <CHARGE_1_CODE>dataset:-11.charge1_id</CHARGE_1_CODE>
        <CHARGE_1_NAME>dataset:-11.charge1_name</CHARGE_1_NAME>
        <CHARGE_2_CODE>dataset:-11.charge2_id</CHARGE_2_CODE>
        <CHARGE_2_NAME>dataset:-11.charge2_name</CHARGE_2_NAME>
        <PUNCTURE_1_CODE>dataset:-11.puncture1_id</PUNCTURE_1_CODE>
        <PUNCTURE_1_NAME>dataset:-11.puncture1_name</PUNCTURE_1_NAME>
        <PUNCTURE_2_CODE>dataset:-11.puncture2_id</PUNCTURE_2_CODE>
        <PUNCTURE_2_NAME>dataset:-11.puncture2_name</PUNCTURE_2_NAME>
        <COLLECT_1_CODE>dataset:-11.return1_id</COLLECT_1_CODE>
        <COLLECT_1_NAME>dataset:-11.return1_name</COLLECT_1_NAME>
        <COLLECT_2_CODE>dataset:-11.return2_id</COLLECT_2_CODE>
        <COLLECT_2_NAME>dataset:-11.return2_name</COLLECT_2_NAME>
        <DISPOSE info="処置、検査情報">
            <DISPOSE_INFO DISPOSE_CTL_NO="dataset:-301.cost_no" _sqlCode="-301">
                <TENCD>dataset:-301.e01</TENCD>
                <TKJNAM>dataset:-301.e02</TKJNAM>
                <AMOUNT>dataset:-301.e03</AMOUNT>
                <UNIT></UNIT>
            </DISPOSE_INFO>
        </DISPOSE>
        <DIALYSIS_COND info="透析条件情報">
            <COND_INFO CTL_NO="dataset:-304.e01" _sqlCode="-304">
                <DIALYSIS_ITEM_NAME>dataset:-304.e02</DIALYSIS_ITEM_NAME>
                <VALUE>dataset:-304.e03</VALUE>
                <VALUE_NAME>dataset:-304.e04</VALUE_NAME>
                <UNIT>dataset:-304.e05</UNIT>
            </COND_INFO>
        </DIALYSIS_COND>
        <DIALYSIS_EQUIP info="医材詳細">
            <EQUIP_INFO CTL_NO="dataset:-302.cost_no" _sqlCode="-302">
                <EQUIP_CD>dataset:-302.e01</EQUIP_CD>
                <EQUIP_NAME>dataset:-302.e02</EQUIP_NAME>
                <EQUIP_CLASS_NAME>dataset:-302.e03</EQUIP_CLASS_NAME>
                <AMOUNT>dataset:-302.e04</AMOUNT>
                <UNIT>dataset:-302.e05</UNIT>
            </EQUIP_INFO>
        </DIALYSIS_EQUIP>
        <DIALYSIS_MEDI  info="薬剤詳細">
            <MEDI_INFO CTL_NO="dataset:-303.cost_no" _sqlCode="-303">
                <MEDICINE_CD>dataset:-303.e01</MEDICINE_CD>
                <MEDICINE_NAME>dataset:-303.e02</MEDICINE_NAME>
                <MEDI_CLASS_NAME>dataset:-303.e03</MEDI_CLASS_NAME>
                <AMOUNT>dataset:-303.e04</AMOUNT>
                <UNIT>dataset:-303.e05</UNIT>
                <PROCEDURE_CD>dataset:-303.e06</PROCEDURE_CD>
                <PROCEDURE_NAME>dataset:-303.e07</PROCEDURE_NAME>
            </MEDI_INFO>
        </DIALYSIS_MEDI>
    </RSTData>
</SsiData>', '{"dataset": [{"patId": "patId", "sqlCode": -500001}, {"ordNo": "ordNo", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": -35}, {"ordNo": "ordNo", "sqlCode": -36}, {"ordNo": "ordNo", "sqlCode": -301}, {"ordNo": "ordNoo", "sqlCode": -302}, {"ordNo": "ordNo", "sqlCode": -303}, {"ordNo": "ordNo", "sqlCode": -304}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99988}}', '1', '0', 4, '2020-05-22 09:38:28.418', '2020-05-22 09:38:33.3');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-5070002, 'S_hosp', 'rst_dial', '', 'S', 'upd', 'xml', 'SSI', 'SSI', '実績送信', '1', '<SsiData Type="DIALYSISRST">
    <RSTData>
        <PatientID>dataset:-500001.hosp_pat_id8</PatientID>
        <DIALYSIS_DATE>dataset:-11.treat_date</DIALYSIS_DATE>
        <DIALYSIS_NO>dataset:-11.ord_no</DIALYSIS_NO>
        <BED_NO>dataset:-11.bed_cd1</BED_NO>
        <BED_NAME>dataset:-11.bed_name</BED_NAME>
        <KUR_CD>dataset:-11.kur_cd1</KUR_CD>
        <KUR_NAME>dataset:-11.kur_name</KUR_NAME>
        <VALID>1</VALID>
        <DEVICE_NO>dataset:-11.machine_no</DEVICE_NO>
        <DEVICE_NAME>dataset:-11.machine_name</DEVICE_NAME>
        <START_DATE>dataset:-11.start_date</START_DATE>
        <END_DATE>dataset:-11.end_date</END_DATE>
        <DIALYSIS_TIME>dataset:-11.running_time_cal</DIALYSIS_TIME>
        <WEIGHT_BEFORE>dataset:-11.weight_before</WEIGHT_BEFORE>
        <WEIGHT_AFTER>dataset:-11.weight_after</WEIGHT_AFTER>
        <BP_BEFORE_MAX>dataset:-35.bp_high</BP_BEFORE_MAX>
        <BP_BEFORE_MIN>dataset:-35.bp_low</BP_BEFORE_MIN>
        <BP_AFTER_MAX>dataset:-36.bp_high</BP_AFTER_MAX>
        <BP_AFTER_MIN>dataset:-36.bp_low</BP_AFTER_MIN>
        <PULSE_BEFORE>dataset:-35.pulse</PULSE_BEFORE>
        <PULSE_AFTER>dataset:-36.pulse</PULSE_AFTER>
        <CHARGE_1_CODE>dataset:-11.charge1_id</CHARGE_1_CODE>
        <CHARGE_1_NAME>dataset:-11.charge1_name</CHARGE_1_NAME>
        <CHARGE_2_CODE>dataset:-11.charge2_id</CHARGE_2_CODE>
        <CHARGE_2_NAME>dataset:-11.charge2_name</CHARGE_2_NAME>
        <PUNCTURE_1_CODE>dataset:-11.puncture1_id</PUNCTURE_1_CODE>
        <PUNCTURE_1_NAME>dataset:-11.puncture1_name</PUNCTURE_1_NAME>
        <PUNCTURE_2_CODE>dataset:-11.puncture2_id</PUNCTURE_2_CODE>
        <PUNCTURE_2_NAME>dataset:-11.puncture2_name</PUNCTURE_2_NAME>
        <COLLECT_1_CODE>dataset:-11.return1_id</COLLECT_1_CODE>
        <COLLECT_1_NAME>dataset:-11.return1_name</COLLECT_1_NAME>
        <COLLECT_2_CODE>dataset:-11.return2_id</COLLECT_2_CODE>
        <COLLECT_2_NAME>dataset:-11.return2_name</COLLECT_2_NAME>
        <DISPOSE info="処置、検査情報">
            <DISPOSE_INFO DISPOSE_CTL_NO="dataset:-301.cost_no" _sqlCode="-301">
                <TENCD>dataset:-301.e01</TENCD>
                <TKJNAM>dataset:-301.e02</TKJNAM>
                <AMOUNT>dataset:-301.e03</AMOUNT>
                <UNIT></UNIT>
            </DISPOSE_INFO>
        </DISPOSE>
        <DIALYSIS_COND info="透析条件情報">
            <COND_INFO CTL_NO="dataset:-304.e01" _sqlCode="-304">
                <DIALYSIS_ITEM_NAME>dataset:-304.e02</DIALYSIS_ITEM_NAME>
                <VALUE>dataset:-304.e03</VALUE>
                <VALUE_NAME>dataset:-304.e04</VALUE_NAME>
                <UNIT>dataset:-304.e05</UNIT>
            </COND_INFO>
        </DIALYSIS_COND>
        <DIALYSIS_EQUIP info="医材詳細">
            <EQUIP_INFO CTL_NO="dataset:-302.cost_no" _sqlCode="-302">
                <EQUIP_CD>dataset:-302.e01</EQUIP_CD>
                <EQUIP_NAME>dataset:-302.e02</EQUIP_NAME>
                <EQUIP_CLASS_NAME>dataset:-302.e03</EQUIP_CLASS_NAME>
                <AMOUNT>dataset:-302.e04</AMOUNT>
                <UNIT>dataset:-302.e05</UNIT>
            </EQUIP_INFO>
        </DIALYSIS_EQUIP>
        <DIALYSIS_MEDI  info="薬剤詳細">
            <MEDI_INFO CTL_NO="dataset:-303.cost_no" _sqlCode="-303">
                <MEDICINE_CD>dataset:-303.e01</MEDICINE_CD>
                <MEDICINE_NAME>dataset:-303.e02</MEDICINE_NAME>
                <MEDI_CLASS_NAME>dataset:-303.e03</MEDI_CLASS_NAME>
                <AMOUNT>dataset:-303.e04</AMOUNT>
                <UNIT>dataset:-303.e05</UNIT>
                <PROCEDURE_CD>dataset:-303.e06</PROCEDURE_CD>
                <PROCEDURE_NAME>dataset:-303.e07</PROCEDURE_NAME>
            </MEDI_INFO>
        </DIALYSIS_MEDI>
    </RSTData>
</SsiData>', '{"dataset": [{"patId": "patId", "sqlCode": -500001}, {"ordNo": "ordNo", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": -35}, {"ordNo": "ordNo", "sqlCode": -36}, {"ordNo": "ordNo", "sqlCode": -301}, {"ordNo": "ordNoo", "sqlCode": -302}, {"ordNo": "ordNo", "sqlCode": -303}, {"ordNo": "ordNo", "sqlCode": -304}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99988}}', '1', '0', 4, '2020-05-22 09:38:28.418', '2020-05-22 09:38:33.3');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-5070003, 'S_hosp', 'rst_dial', '', 'S', 'del', 'xml', 'SSI', 'SSI', '実績送信', '1', '<SsiData Type="DIALYSISRST">
    <RSTData>
        <PatientID>dataset:-500001.hosp_pat_id8</PatientID>
        <DIALYSIS_DATE>dataset:-11.treat_date</DIALYSIS_DATE>
        <DIALYSIS_NO>dataset:-11.ord_no</DIALYSIS_NO>
        <BED_NO>dataset:-11.bed_cd1</BED_NO>
        <BED_NAME>dataset:-11.bed_name</BED_NAME>
        <KUR_CD>dataset:-11.kur_cd1</KUR_CD>
        <KUR_NAME>dataset:-11.kur_name</KUR_NAME>
        <VALID>9</VALID>
        <DEVICE_NO>dataset:-11.machine_no</DEVICE_NO>
        <DEVICE_NAME>dataset:-11.machine_name</DEVICE_NAME>
        <START_DATE>dataset:-11.start_date</START_DATE>
        <END_DATE>dataset:-11.end_date</END_DATE>
        <DIALYSIS_TIME>dataset:-11.running_time_cal</DIALYSIS_TIME>
        <WEIGHT_BEFORE>dataset:-11.weight_before</WEIGHT_BEFORE>
        <WEIGHT_AFTER>dataset:-11.weight_after</WEIGHT_AFTER>
        <BP_BEFORE_MAX>dataset:-35.bp_high</BP_BEFORE_MAX>
        <BP_BEFORE_MIN>dataset:-35.bp_low</BP_BEFORE_MIN>
        <BP_AFTER_MAX>dataset:-36.bp_high</BP_AFTER_MAX>
        <BP_AFTER_MIN>dataset:-36.bp_low</BP_AFTER_MIN>
        <PULSE_BEFORE>dataset:-35.pulse</PULSE_BEFORE>
        <PULSE_AFTER>dataset:-36.pulse</PULSE_AFTER>
        <CHARGE_1_CODE>dataset:-11.charge1_id</CHARGE_1_CODE>
        <CHARGE_1_NAME>dataset:-11.charge1_name</CHARGE_1_NAME>
        <CHARGE_2_CODE>dataset:-11.charge2_id</CHARGE_2_CODE>
        <CHARGE_2_NAME>dataset:-11.charge2_name</CHARGE_2_NAME>
        <PUNCTURE_1_CODE>dataset:-11.puncture1_id</PUNCTURE_1_CODE>
        <PUNCTURE_1_NAME>dataset:-11.puncture1_name</PUNCTURE_1_NAME>
        <PUNCTURE_2_CODE>dataset:-11.puncture2_id</PUNCTURE_2_CODE>
        <PUNCTURE_2_NAME>dataset:-11.puncture2_name</PUNCTURE_2_NAME>
        <COLLECT_1_CODE>dataset:-11.return1_id</COLLECT_1_CODE>
        <COLLECT_1_NAME>dataset:-11.return1_name</COLLECT_1_NAME>
        <COLLECT_2_CODE>dataset:-11.return2_id</COLLECT_2_CODE>
        <COLLECT_2_NAME>dataset:-11.return2_name</COLLECT_2_NAME>
        <DISPOSE info="処置、検査情報">
            <DISPOSE_INFO DISPOSE_CTL_NO="dataset:-301.cost_no" _sqlCode="-301">
                <TENCD>dataset:-301.e01</TENCD>
                <TKJNAM>dataset:-301.e02</TKJNAM>
                <AMOUNT>dataset:-301.e03</AMOUNT>
                <UNIT></UNIT>
            </DISPOSE_INFO>
        </DISPOSE>
        <DIALYSIS_COND info="透析条件情報">
            <COND_INFO CTL_NO="dataset:-304.e01" _sqlCode="-304">
                <DIALYSIS_ITEM_NAME>dataset:-304.e02</DIALYSIS_ITEM_NAME>
                <VALUE>dataset:-304.e03</VALUE>
                <VALUE_NAME>dataset:-304.e04</VALUE_NAME>
                <UNIT>dataset:-304.e05</UNIT>
            </COND_INFO>
        </DIALYSIS_COND>
        <DIALYSIS_EQUIP info="医材詳細">
            <EQUIP_INFO CTL_NO="dataset:-302.cost_no" _sqlCode="-302">
                <EQUIP_CD>dataset:-302.e01</EQUIP_CD>
                <EQUIP_NAME>dataset:-302.e02</EQUIP_NAME>
                <EQUIP_CLASS_NAME>dataset:-302.e03</EQUIP_CLASS_NAME>
                <AMOUNT>dataset:-302.e04</AMOUNT>
                <UNIT>dataset:-302.e05</UNIT>
            </EQUIP_INFO>
        </DIALYSIS_EQUIP>
        <DIALYSIS_MEDI  info="薬剤詳細">
            <MEDI_INFO CTL_NO="dataset:-303.cost_no" _sqlCode="-303">
                <MEDICINE_CD>dataset:-303.e01</MEDICINE_CD>
                <MEDICINE_NAME>dataset:-303.e02</MEDICINE_NAME>
                <MEDI_CLASS_NAME>dataset:-303.e03</MEDI_CLASS_NAME>
                <AMOUNT>dataset:-303.e04</AMOUNT>
                <UNIT>dataset:-303.e05</UNIT>
                <PROCEDURE_CD>dataset:-303.e06</PROCEDURE_CD>
                <PROCEDURE_NAME>dataset:-303.e07</PROCEDURE_NAME>
            </MEDI_INFO>
        </DIALYSIS_MEDI>
    </RSTData>
</SsiData>', '{"dataset": [{"patId": "patId", "sqlCode": -500001}, {"ordNo": "ordNo", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": -35}, {"ordNo": "ordNo", "sqlCode": -36}, {"ordNo": "ordNo", "sqlCode": -301}, {"ordNo": "ordNoo", "sqlCode": -302}, {"ordNo": "ordNo", "sqlCode": -303}, {"ordNo": "ordNo", "sqlCode": -304}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99988}}', '1', '0', 4, '2020-05-22 09:38:28.418', '2020-05-22 09:38:33.3');
