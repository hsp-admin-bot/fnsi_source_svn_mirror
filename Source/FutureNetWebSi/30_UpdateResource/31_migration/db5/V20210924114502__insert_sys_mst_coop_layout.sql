delete from "mst_coop_layout" where "ctl_no" >=-6020003 AND "ctl_no" <=-6020001;INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6020001, 'C_hosp', 'ind_dial', '', 'S', 'cre', 'xml', 'CSI透析予約', 'MIRAIs', '透析予約', '1', '<coop_info>
    <!-- 電文種別 -->
    <facility_cd>$JOURNAL.facility_cd</facility_cd>
    <!-- 電文種別 -->
    <coop_cd>ind_dial</coop_cd>
    <!-- 作成更新区分 -->
    <crud>1</crud>
    <!-- 向き（送受信） -->
    <direction>S</direction>
    <!-- ord_no -->
    <coop_ord_no>$JOURNAL.coop_ord_no</coop_ord_no>
    <!-- 患者番号（連携用） -->
    <hosp_pat_id>dataset:-200001.hosp_pat_id</hosp_pat_id>
    <!-- 電文内容 -->
    <dump>
        <rootNode>
            <!-- 患者情報 -->
            <PAT_BASIC_INFO>
                <!-- 表示用患者ID -->
                <DISP_PATID>dataset:-200001.hosp_pat_id</DISP_PATID>
                <!-- 患者ID -->
                <PATID>$JOURNAL.pat_id</PATID>
                <!-- 患者名 -->
                <NAME>dataset:-200001.pat_name</NAME>
                <!-- 医師1 -->
                <DOCTOR_CD1></DOCTOR_CD1>
                <!-- 医師2 -->
                <DOCTOR_CD2></DOCTOR_CD2>
                <MST_PAT_GROUP>
                    <!-- 科コード -->
                    <IN_HOSPITAL_CD>dataset:-436.course_cd1</IN_HOSPITAL_CD>
                </MST_PAT_GROUP>
            </PAT_BASIC_INFO>
            <!-- 透析スケジュール -->
            <SCH_DIALYSIS_PLAN>
                <!-- ベッド番号 -->
                <BED_NO>dataset:-436.bed_cd1</BED_NO>
                <!-- クールコード -->
                <KUR_CD>dataset:-436.kur_cd1</KUR_CD>
                <!-- 透析日 -->
                <DIALYSIS_DATE>dataset:-436.treat_date</DIALYSIS_DATE>
                <!-- クールマスタ -->
                <MST_KUR>
                    <!-- クール内標準開始時間 -->
                    <STANDARD_START_TIME>dataset:-436.kur_standard_start_time</STANDARD_START_TIME>
                </MST_KUR>
                <!-- ベッドマスタ -->
                <MST_BED>
                    <!-- ベッド名 -->
                    <BED_NAME>dataset:-436.bed_name</BED_NAME>
                </MST_BED>
            </SCH_DIALYSIS_PLAN>
            <IND_DIALYSIS_COND DIALYSIS_ITEM_CD="dataset:-437.item_cd" NAME="dataset:-437.item_name" VALUE="dataset:-437.item_value" _sqlCode="-437">
            <!-- 条件指示 詳細：項目番号, 項目名, 設定値-->
                <!-- 指示者 -->
                <INDICATOR_CD>dataset:-437.ind_user_id</INDICATOR_CD>
                <!-- スタッフマスタ：指示者の値 -->
                <MST_STAFF STAFF_CD="dataset:-437.ind_user_id">
                    <!-- 職種コード -->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 更新者 -->
                <UPDATE_STAFF_CD>dataset:-437.upd_user_id</UPDATE_STAFF_CD>
                <!-- 更新時間 -->
                <UP_DATE>dataset:-437.up_date</UP_DATE>
                <!-- 装置:モード -->
                <MST_TREAT_ITEM DEVICE_MODE="dataset:-437.add_item"/>
            </IND_DIALYSIS_COND>
            <IND_DIALYSIS_PLAN CTL_NO="$COUNT" _sqlCode="-438">
            <!-- 予約指示 詳細:番号 -->
                <!-- 指示者 -->
                <INDICATOR_CD>dataset:-438.ind_user_id</INDICATOR_CD>
                <!-- スタッフマスタ：指示者の値-->
                <MST_STAFF STAFF_CD="dataset:-438.ind_user_id">
                    <!-- 職種コード-->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 更新者 -->
                <UPDATE_STAFF_CD>dataset:-438.upd_user_id</UPDATE_STAFF_CD>
                <!-- 更新時間 -->
                <UP_DATE>dataset:-438.up_date</UP_DATE>
            </IND_DIALYSIS_PLAN>
            <IND_DIALYSIS_MEDI CTL_NO="$COUNT" _sqlCode="-439">
            <!-- 投薬指示 詳細:番号 -->
                <!-- 指示者 -->
                <INDICATOR_CD>dataset:-439.ind_user_id</INDICATOR_CD>
                <!-- スタッフマスタ：指示者の値-->
                <MST_STAFF STAFF_CD="dataset:-439.ind_user_id">
                    <!-- 職種コード-->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 更新者 -->
                <UPDATE_STAFF_CD>dataset:-439.upd_user_id</UPDATE_STAFF_CD>
                <!-- 更新時間 -->
                <UP_DATE>dataset:-439.up_date</UP_DATE>
            </IND_DIALYSIS_MEDI>
            <IND_DIALYSIS_EQUIP CTL_NO="$COUNT" _sqlCode="-440">
            <!-- 材料指示 詳細:番号 -->
                <!-- 指示者 -->
                <INDICATOR_CD>dataset:-440.ind_user_id</INDICATOR_CD>
                <!-- スタッフマスタ：指示者の値-->
                <MST_STAFF STAFF_CD="dataset:-440.ind_user_id">
                    <!-- 職種コード-->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 更新者 -->
                <UPDATE_STAFF_CD>dataset:-440.upd_user_id</UPDATE_STAFF_CD>
                <!-- 更新時間 -->
                <UP_DATE>dataset:-440.up_date</UP_DATE>
            </IND_DIALYSIS_EQUIP>
            <IND_DIALYSIS_ADD CTL_NO="$COUNT" _sqlCode="-441">
            <!-- 指示簿指示 詳細:番号 -->
                <!-- 指示者 -->
                <INDICATOR_CD>dataset:-441.ind_user_id</INDICATOR_CD>
                <!-- スタッフマスタ：指示者の値-->
                <MST_STAFF STAFF_CD="dataset:-441.ind_user_id">
                    <!-- 職種コード-->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 更新者 -->
                <UPDATE_STAFF_CD>dataset:-441.upd_user_id</UPDATE_STAFF_CD>
                <!-- 更新時間 -->
                <UP_DATE>dataset:-441.up_date</UP_DATE>
            </IND_DIALYSIS_ADD>
            <SYS_COOP_EXEC_DATA>
                <A00001>
                    <SYS_STAFF_AUTH>
                        <ACL>1</ACL>
                    </SYS_STAFF_AUTH>
                </A00001>
                <A00002>
                    <MST_BED>
                        <BED_NO>1</BED_NO>
                    </MST_BED>
                </A00002>
                <A10001></A10001>
                <A10002>
                    <USER_TABLES>
                        <TABLE_NAME>COOP_LAYOUT</TABLE_NAME>
                    </USER_TABLES>
                </A10002>
            </SYS_COOP_EXEC_DATA>
        </rootNode>
    </dump>
</coop_info>
', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -436}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -437}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -438}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -439}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -440}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -441}], "dumpFileName": {"patId": "patId", "sqlCode": -102}}', '1', '0', -1, '2021-09-06 11:38:27', '2021-09-06 11:38:31');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6020002, 'C_hosp', 'ind_dial', '', 'S', 'upd', 'xml', 'CSI透析予約', 'MIRAIs', '透析予約', '1', '<coop_info>
    <!-- 電文種別 -->
    <facility_cd>$JOURNAL.facility_cd</facility_cd>
    <!-- 電文種別 -->
    <coop_cd>ind_dial</coop_cd>
    <!-- 作成更新区分 -->
    <crud>2</crud>
    <!-- 向き（送受信） -->
    <direction>S</direction>
    <!-- ord_no -->
    <coop_ord_no>$JOURNAL.coop_ord_no</coop_ord_no>
    <!-- 患者番号（連携用） -->
    <hosp_pat_id>dataset:-200001.hosp_pat_id</hosp_pat_id>
    <!-- 電文内容 -->
    <dump>
        <rootNode>
            <!-- 患者情報 -->
            <PAT_BASIC_INFO>
                <!-- 表示用患者ID -->
                <DISP_PATID>dataset:-200001.hosp_pat_id</DISP_PATID>
                <!-- 患者ID -->
                <PATID>$JOURNAL.pat_id</PATID>
                <!-- 患者名 -->
                <NAME>dataset:-200001.pat_name</NAME>
                <!-- 医師1 -->
                <DOCTOR_CD1></DOCTOR_CD1>
                <!-- 医師2 -->
                <DOCTOR_CD2></DOCTOR_CD2>
                <MST_PAT_GROUP>
                    <!-- 科コード -->
                    <IN_HOSPITAL_CD>dataset:-436.course_cd1</IN_HOSPITAL_CD>
                </MST_PAT_GROUP>
            </PAT_BASIC_INFO>
            <!-- 透析スケジュール -->
            <SCH_DIALYSIS_PLAN>
                <!-- ベッド番号 -->
                <BED_NO>dataset:-436.bed_cd1</BED_NO>
                <!-- クールコード -->
                <KUR_CD>dataset:-436.kur_cd1</KUR_CD>
                <!-- 透析日 -->
                <DIALYSIS_DATE>dataset:-436.treat_date</DIALYSIS_DATE>
                <!-- クールマスタ -->
                <MST_KUR>
                    <!-- クール内標準開始時間 -->
                    <STANDARD_START_TIME>dataset:-436.kur_standard_start_time</STANDARD_START_TIME>
                </MST_KUR>
                <!-- ベッドマスタ -->
                <MST_BED>
                    <!-- ベッド名 -->
                    <BED_NAME>dataset:-436.bed_name</BED_NAME>
                </MST_BED>
            </SCH_DIALYSIS_PLAN>
            <IND_DIALYSIS_COND DIALYSIS_ITEM_CD="dataset:-437.item_cd" NAME="dataset:-437.item_name" VALUE="dataset:-437.item_value" _sqlCode="-437">
            <!-- 条件指示 詳細：項目番号, 項目名, 設定値-->
                <!-- 指示者 -->
                <INDICATOR_CD>dataset:-437.ind_user_id</INDICATOR_CD>
                <!-- スタッフマスタ：指示者の値 -->
                <MST_STAFF STAFF_CD="dataset:-437.ind_user_id">
                    <!-- 職種コード -->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 更新者 -->
                <UPDATE_STAFF_CD>dataset:-437.upd_user_id</UPDATE_STAFF_CD>
                <!-- 更新時間 -->
                <UP_DATE>dataset:-437.up_date</UP_DATE>
                <!-- 装置:モード -->
                <MST_TREAT_ITEM DEVICE_MODE="dataset:-437.add_item"/>
            </IND_DIALYSIS_COND>
            <IND_DIALYSIS_PLAN CTL_NO="$COUNT" _sqlCode="-438">
            <!-- 予約指示 詳細:番号 -->
                <!-- 指示者 -->
                <INDICATOR_CD>dataset:-438.ind_user_id</INDICATOR_CD>
                <!-- スタッフマスタ：指示者の値-->
                <MST_STAFF STAFF_CD="dataset:-438.ind_user_id">
                    <!-- 職種コード-->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 更新者 -->
                <UPDATE_STAFF_CD>dataset:-438.upd_user_id</UPDATE_STAFF_CD>
                <!-- 更新時間 -->
                <UP_DATE>dataset:-438.up_date</UP_DATE>
            </IND_DIALYSIS_PLAN>
            <IND_DIALYSIS_MEDI CTL_NO="$COUNT" _sqlCode="-439">
            <!-- 投薬指示 詳細:番号 -->
                <!-- 指示者 -->
                <INDICATOR_CD>dataset:-439.ind_user_id</INDICATOR_CD>
                <!-- スタッフマスタ：指示者の値-->
                <MST_STAFF STAFF_CD="dataset:-439.ind_user_id">
                    <!-- 職種コード-->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 更新者 -->
                <UPDATE_STAFF_CD>dataset:-439.upd_user_id</UPDATE_STAFF_CD>
                <!-- 更新時間 -->
                <UP_DATE>dataset:-439.up_date</UP_DATE>
            </IND_DIALYSIS_MEDI>
            <IND_DIALYSIS_EQUIP CTL_NO="$COUNT" _sqlCode="-440">
            <!-- 材料指示 詳細:番号 -->
                <!-- 指示者 -->
                <INDICATOR_CD>dataset:-440.ind_user_id</INDICATOR_CD>
                <!-- スタッフマスタ：指示者の値-->
                <MST_STAFF STAFF_CD="dataset:-440.ind_user_id">
                    <!-- 職種コード-->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 更新者 -->
                <UPDATE_STAFF_CD>dataset:-440.upd_user_id</UPDATE_STAFF_CD>
                <!-- 更新時間 -->
                <UP_DATE>dataset:-440.up_date</UP_DATE>
            </IND_DIALYSIS_EQUIP>
            <IND_DIALYSIS_ADD CTL_NO="$COUNT" _sqlCode="-441">
            <!-- 指示簿指示 詳細:番号 -->
                <!-- 指示者 -->
                <INDICATOR_CD>dataset:-441.ind_user_id</INDICATOR_CD>
                <!-- スタッフマスタ：指示者の値-->
                <MST_STAFF STAFF_CD="dataset:-441.ind_user_id">
                    <!-- 職種コード-->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 更新者 -->
                <UPDATE_STAFF_CD>dataset:-441.upd_user_id</UPDATE_STAFF_CD>
                <!-- 更新時間 -->
                <UP_DATE>dataset:-441.up_date</UP_DATE>
            </IND_DIALYSIS_ADD>
            <SYS_COOP_EXEC_DATA>
                <A00001>
                    <SYS_STAFF_AUTH>
                        <ACL>1</ACL>
                    </SYS_STAFF_AUTH>
                </A00001>
                <A00002>
                    <MST_BED>
                        <BED_NO>1</BED_NO>
                    </MST_BED>
                </A00002>
                <A10001></A10001>
                <A10002>
                    <USER_TABLES>
                        <TABLE_NAME>COOP_LAYOUT</TABLE_NAME>
                    </USER_TABLES>
                </A10002>
            </SYS_COOP_EXEC_DATA>
        </rootNode>
    </dump>
</coop_info>
', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -436}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -437}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -438}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -439}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -440}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -441}], "dumpFileName": {"patId": "patId", "sqlCode": -102}}', '1', '0', -1, '2021-09-06 11:38:27', '2021-09-06 11:38:31');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6020003, 'C_hosp', 'ind_dial', '', 'S', 'del', 'xml', 'CSI透析予約', 'MIRAIs', '透析予約', '1', '<coop_info>
    <!-- 電文種別 -->
    <facility_cd>$JOURNAL.facility_cd</facility_cd>
    <!-- 電文種別 -->
    <coop_cd>ind_dial</coop_cd>
    <!-- 作成更新区分 -->
    <crud>3</crud>
    <!-- 向き（送受信） -->
    <direction>S</direction>
    <!-- ord_no -->
    <coop_ord_no>$JOURNAL.coop_ord_no</coop_ord_no>
    <!-- 患者番号（連携用） -->
    <hosp_pat_id>dataset:-200001.hosp_pat_id</hosp_pat_id>
    <!-- 電文内容 -->
    <dump>
        <rootNode>
            <!-- 患者情報 -->
            <PAT_BASIC_INFO>
                <!-- 表示用患者ID -->
                <DISP_PATID>dataset:-200001.hosp_pat_id</DISP_PATID>
                <!-- 患者ID -->
                <PATID>$JOURNAL.pat_id</PATID>
                <!-- 患者名 -->
                <NAME>dataset:-200001.pat_name</NAME>
                <!-- 医師1 -->
                <DOCTOR_CD1></DOCTOR_CD1>
                <!-- 医師2 -->
                <DOCTOR_CD2></DOCTOR_CD2>
                <MST_PAT_GROUP>
                    <!-- 科コード -->
                    <IN_HOSPITAL_CD>dataset:-436.course_cd1</IN_HOSPITAL_CD>
                </MST_PAT_GROUP>
            </PAT_BASIC_INFO>
            <!-- 透析スケジュール -->
            <SCH_DIALYSIS_PLAN>
                <!-- ベッド番号 -->
                <BED_NO>dataset:-436.bed_cd1</BED_NO>
                <!-- クールコード -->
                <KUR_CD>dataset:-436.kur_cd1</KUR_CD>
                <!-- 透析日 -->
                <DIALYSIS_DATE>dataset:-436.treat_date</DIALYSIS_DATE>
                <!-- クールマスタ -->
                <MST_KUR>
                    <!-- クール内標準開始時間 -->
                    <STANDARD_START_TIME>dataset:-436.kur_standard_start_time</STANDARD_START_TIME>
                </MST_KUR>
                <!-- ベッドマスタ -->
                <MST_BED>
                    <!-- ベッド名 -->
                    <BED_NAME>dataset:-436.bed_name</BED_NAME>
                </MST_BED>
            </SCH_DIALYSIS_PLAN>
            <IND_DIALYSIS_COND DIALYSIS_ITEM_CD="dataset:-437.item_cd" NAME="dataset:-437.item_name" VALUE="dataset:-437.item_value" _sqlCode="-437">
            <!-- 条件指示 詳細：項目番号, 項目名, 設定値-->
                <!-- 指示者 -->
                <INDICATOR_CD>dataset:-437.ind_user_id</INDICATOR_CD>
                <!-- スタッフマスタ：指示者の値 -->
                <MST_STAFF STAFF_CD="dataset:-437.ind_user_id">
                    <!-- 職種コード -->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 更新者 -->
                <UPDATE_STAFF_CD>dataset:-437.upd_user_id</UPDATE_STAFF_CD>
                <!-- 更新時間 -->
                <UP_DATE>dataset:-437.up_date</UP_DATE>
                <!-- 装置:モード -->
                <MST_TREAT_ITEM DEVICE_MODE="dataset:-437.add_item"/>
            </IND_DIALYSIS_COND>
            <IND_DIALYSIS_PLAN CTL_NO="$COUNT" _sqlCode="-438">
            <!-- 予約指示 詳細:番号 -->
                <!-- 指示者 -->
                <INDICATOR_CD>dataset:-438.ind_user_id</INDICATOR_CD>
                <!-- スタッフマスタ：指示者の値-->
                <MST_STAFF STAFF_CD="dataset:-438.ind_user_id">
                    <!-- 職種コード-->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 更新者 -->
                <UPDATE_STAFF_CD>dataset:-438.upd_user_id</UPDATE_STAFF_CD>
                <!-- 更新時間 -->
                <UP_DATE>dataset:-438.up_date</UP_DATE>
            </IND_DIALYSIS_PLAN>
            <IND_DIALYSIS_MEDI CTL_NO="$COUNT" _sqlCode="-439">
            <!-- 投薬指示 詳細:番号 -->
                <!-- 指示者 -->
                <INDICATOR_CD>dataset:-439.ind_user_id</INDICATOR_CD>
                <!-- スタッフマスタ：指示者の値-->
                <MST_STAFF STAFF_CD="dataset:-439.ind_user_id">
                    <!-- 職種コード-->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 更新者 -->
                <UPDATE_STAFF_CD>dataset:-439.upd_user_id</UPDATE_STAFF_CD>
                <!-- 更新時間 -->
                <UP_DATE>dataset:-439.up_date</UP_DATE>
            </IND_DIALYSIS_MEDI>
            <IND_DIALYSIS_EQUIP CTL_NO="$COUNT" _sqlCode="-440">
            <!-- 材料指示 詳細:番号 -->
                <!-- 指示者 -->
                <INDICATOR_CD>dataset:-440.ind_user_id</INDICATOR_CD>
                <!-- スタッフマスタ：指示者の値-->
                <MST_STAFF STAFF_CD="dataset:-440.ind_user_id">
                    <!-- 職種コード-->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 更新者 -->
                <UPDATE_STAFF_CD>dataset:-440.upd_user_id</UPDATE_STAFF_CD>
                <!-- 更新時間 -->
                <UP_DATE>dataset:-440.up_date</UP_DATE>
            </IND_DIALYSIS_EQUIP>
            <IND_DIALYSIS_ADD CTL_NO="$COUNT" _sqlCode="-441">
            <!-- 指示簿指示 詳細:番号 -->
                <!-- 指示者 -->
                <INDICATOR_CD>dataset:-441.ind_user_id</INDICATOR_CD>
                <!-- スタッフマスタ：指示者の値-->
                <MST_STAFF STAFF_CD="dataset:-441.ind_user_id">
                    <!-- 職種コード-->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 更新者 -->
                <UPDATE_STAFF_CD>dataset:-441.upd_user_id</UPDATE_STAFF_CD>
                <!-- 更新時間 -->
                <UP_DATE>dataset:-441.up_date</UP_DATE>
            </IND_DIALYSIS_ADD>
            <SYS_COOP_EXEC_DATA>
                <A00001>
                    <SYS_STAFF_AUTH>
                        <ACL>1</ACL>
                    </SYS_STAFF_AUTH>
                </A00001>
                <A00002>
                    <MST_BED>
                        <BED_NO>1</BED_NO>
                    </MST_BED>
                </A00002>
                <A10001></A10001>
                <A10002>
                    <USER_TABLES>
                        <TABLE_NAME>COOP_LAYOUT</TABLE_NAME>
                    </USER_TABLES>
                </A10002>
            </SYS_COOP_EXEC_DATA>
        </rootNode>
    </dump>
</coop_info>
', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -436}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -437}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -438}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -439}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -440}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -441}], "dumpFileName": {"patId": "patId", "sqlCode": -102}}', '1', '0', -1, '2021-09-06 11:38:27', '2021-09-06 11:38:31');
