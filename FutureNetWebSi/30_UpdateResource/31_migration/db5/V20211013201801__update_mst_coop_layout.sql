delete from "mst_coop_layout" where "ctl_no" in (-6010001,-6020001,-6020002,-6020003,-6030001,-6030002,-6030003,-6040001,-6040002,-6040003,-6050001,-6050002,-6050003,-6060001);
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6010001, 'C_hosp', 'profile', '', 'S', 'cre', 'xml', 'CSI患者プロファイル', 'MIRAIs', '患者プロファイル', '1', '<coop_info>
    <facility_cd>$JOURNAL.facility_cd</facility_cd>
    <coop_cd>profile</coop_cd>
    <crud>C</crud>
    <direction>S</direction>
    <hosp_pat_id>$JOURNAL.hosp_pat_id</hosp_pat_id>
    <coop_ord_no>$JOURNAL.coop_ord_no</coop_ord_no>
    <dump>
        <rootNode>
            <PAT_BASIC_INFO>
                <PATID></PATID>
                <NAME></NAME>
                <INFECT></INFECT>
                <DIE_FLG></DIE_FLG>
            </PAT_BASIC_INFO>
            <PAT_CONTACT>
                <CTL_NO></CTL_NO>
                <DISP_NO></DISP_NO>
            </PAT_CONTACT>
        </rootNode>
   </dump>
</coop_info>', '{}', '1', '0', -1, '2021-09-01 07:38:44.069', '2021-09-01 07:38:44.069');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6020001, 'C_hosp', 'ind_dial', '', 'S', 'cre', 'xml', 'CSI透析予約', 'MIRAIs', '透析予約', '1', '<coop_info>
    <!-- 電文種別 -->
    <facility_cd>$JOURNAL.facility_cd</facility_cd>
    <!-- 電文種別 -->
    <coop_cd>ind_dial</coop_cd>
    <!-- 作成更新区分 -->
    <crud>C</crud>
    <!-- 向き（送受信） -->
    <direction>S</direction>
    <!-- （連携先)オーダ番号 -->
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
                <DOCTOR_CD1>dataset:-436.staff_cd1</DOCTOR_CD1>
                <!-- 医師2 -->
                <DOCTOR_CD2>dataset:-436.staff_cd2</DOCTOR_CD2>
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
    <crud>U</crud>
    <!-- 向き（送受信） -->
    <direction>S</direction>
    <!-- （連携先)オーダ番号 -->
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
                <DOCTOR_CD1>dataset:-436.staff_cd1</DOCTOR_CD1>
                <!-- 医師2 -->
                <DOCTOR_CD2>dataset:-436.staff_cd2</DOCTOR_CD2>
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
    <crud>D</crud>
    <!-- 向き（送受信） -->
    <direction>S</direction>
    <!-- （連携先)オーダ番号 -->
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
                <DOCTOR_CD1>dataset:-436.staff_cd1</DOCTOR_CD1>
                <!-- 医師2 -->
                <DOCTOR_CD2>dataset:-436.staff_cd2</DOCTOR_CD2>
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
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6030001, 'C_hosp', 'rst_dial', '', 'S', 'cre', 'xml', 'CSI透析実績', 'MIRAIs', '実績送信', '1', '<coop_info>
    <!-- 電文種別 -->
    <facility_cd>$JOURNAL.facility_cd</facility_cd>
    <!-- 電文種別 -->
    <coop_cd>rst_dial</coop_cd>
    <!-- 作成更新区分 -->
    <crud>C</crud>
    <!-- 向き（送受信） -->
    <direction>S</direction>
    <!-- （連携先)オーダ番号 -->
    <coop_ord_no>$JOURNAL.coop_ord_no</coop_ord_no>
    <!-- 患者番号（連携用） -->
    <hosp_pat_id>dataset:-200001.hosp_pat_id</hosp_pat_id>
    <!-- 電文内容 -->
    <dump>
        <rootNode>
            <!-- 1.患者基本情報 -->
            <PAT_BASIC_INFO>
                <!-- 表示用患者ID -->
                <DISP_PATID>dataset:-200001.hosp_pat_id</DISP_PATID>
                <!-- 患者ID -->
                <PATID>$JOURNAL.pat_id</PATID>
                <!-- 患者名 -->
                <NAME>dataset:-200001.pat_name</NAME>
                <!-- 医師1 -->
                <DOCTOR_CD1>dataset:-444.staff_cd1</DOCTOR_CD1>
                <!-- 医師2 -->
                <DOCTOR_CD2>dataset:-444.staff_cd2</DOCTOR_CD2>
                <MST_PAT_GROUP>
                    <!--患者基本情報・患者グループの院内コード-->
                    <IN_HOSPITAL_CD>dataset:-444.kur_cd1</IN_HOSPITAL_CD>
                </MST_PAT_GROUP>
                <!--患者基本情報・透析導入日-->
                <DIAL_START_DATE>dataset:-444.dialysis_start_date</DIAL_START_DATE>
                <!--患者基本情報・透析困難有無-->
                <DIAL_DIFF>dataset:-200001.dial_diff_com_info_flag</DIAL_DIFF>
                <MST_DIAL_DIFF_COMENT>
                    <!--患者基本情報・マスタ透析困難コメント・透析困難コメント-->
                    <DIAL_DIFF_COMMENT>dataset:-445.dialysis_difficulty_name</DIAL_DIFF_COMMENT>
                </MST_DIAL_DIFF_COMENT>
                <!--患者基本情報・入外区分-->
                <INOUT_FLG>dataset:-200001.in_out_class</INOUT_FLG>
                <MST_WARD>
                    <!--患者情報基本情報・病棟コード-->
                    <IN_HOSPITAL_CD>dataset:-444.course_cd1</IN_HOSPITAL_CD>
                </MST_WARD>
            </PAT_BASIC_INFO>
            <!-- 2.透析実績履歴 -->
            <RST_DIALYSIS_HST>
                <!--透析実績履歴・透析番号-->
                <DIALYSIS_NO>dataset:-444.rst_fn_dialysis_no</DIALYSIS_NO>
                <!--透析実績履歴・版番号-->
                <EDITION>dataset:-444.rst_edition</EDITION>
                <!--透析実績履歴・透析開始日時-->
                <START_DATE>dataset:-444.rst_start_date</START_DATE>
                <!--透析実績履歴・透析終了日時-->
                <END_DATE>dataset:-444.rst_end_date</END_DATE>
                <!-- ベッドコード -->
                <BED_NO>dataset:-444.bed_cd1</BED_NO>
                <MST_KUR>
                    <!--透析実績履歴・クールマスタ・クール名-->
                    <KUR_NAME>dataset:-444.kur_cd1</KUR_NAME>
                </MST_KUR>
                <!--透析実績履歴・透析時間-->
                <DIALYSIS_TIME>dataset:-444.rst_running_time</DIALYSIS_TIME>
                <!--透析実績履歴・病棟コード-->
                <WARD_CD>dataset:-444.course_cd1</WARD_CD>
                <MST_WARD>
                    <!--透析実績履歴・病棟マスタ・院内コード-->
                    <IN_HOSPITAL_CD>dataset:-444.rst_course_cd1</IN_HOSPITAL_CD>
                </MST_WARD>
            </RST_DIALYSIS_HST>
            <!-- 3.透析実績版番管理 -->
            <RST_DIALYSIS_EDITION>
                <!--透析実績版番管理.版確定者-->
                <DECIDER>dataset:-444.up_ind_user_id</DECIDER>
                <!--スタッフマスタ:版確定者-->
                <MST_STAFF STAFF_CD="dataset:-444.up_ind_user_id">
                    <!-- スタッフマスタ.職種コード-->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
            </RST_DIALYSIS_EDITION>
            <RST_RECEIPT_MEMO_HST _sqlCode="-448" NAME="dataset:-448.detail_id" DIVISION="0" ADD_FLG="0" MAIN_DIAL_DIFF="dataset:-448.is_main">
                <!-- 4.透析困難コメント:主たる透析困難コメントフラグ-->
                <!-- 透析困難コメント -->
                <ITEM_NAME>dataset:-448.dialysis_difficulty_name</ITEM_NAME>
            </RST_RECEIPT_MEMO_HST>
            <RST_DIALYSIS_COND_HST _sqlCode="-447" CTL_NO="dataset:-447.item_cd" NAME="dataset:-447.item_name">
                <!-- 5.透析条件履歴:透析条件項目コード -->
                <!-- 項目コード -->
                <CTL_NO>dataset:-447.item_cd</CTL_NO>
                <!-- 設定値 -->
                <VALUE>dataset:-447.item_value</VALUE>
                <!-- 治療方法マスタ -->
                <MST_TREAT_ITEM>
                    <!-- 治療項目マスタ・院内コード:複数データの場合，カンマ[,]区切り -->
                    <IN_HOSPITAL_CD>dataset:-447.mtt_in_hospital_cd</IN_HOSPITAL_CD>
                    <!-- 治療方法名称 -->
                    <TREAT_ITEM_NAME>dataset:-447.mtt_treatment_name</TREAT_ITEM_NAME>
                </MST_TREAT_ITEM>
                <!-- 薬剤マスタ -->
                <MST_MEDICINE>
                    <!-- 薬剤マスタ・注射フラグ -->
                    <SHOT>dataset:-447.med_is_shot</SHOT>
                    <!-- 院内コード -->
                    <IN_HOSPITAL_CD>dataset:-447.med_in_hospital_cd</IN_HOSPITAL_CD>
                </MST_MEDICINE>
                <MST_SET_MEDI_NAME>
                <!-- ※NTSSに薬剤セットが無し -->
                    <!-- 薬剤セットマスタ -->
                    <MST_SET_MEDICINE>
                        <!-- 薬剤マスタ -->
                        <MST_MEDICINE>
                            <!-- 薬剤マスタ・注射フラグ -->
                            <SHOT></SHOT>
                            <!-- 院内コード -->
                            <IN_HOSPITAL_CD></IN_HOSPITAL_CD>
                        </MST_MEDICINE>
                        <!-- 使用薬剤数 -->
                        <MEDI_USE_NUM></MEDI_USE_NUM>
                    </MST_SET_MEDICINE>
                </MST_SET_MEDI_NAME>
                <!-- ダイアライザマスタ -->
                <MST_DIALYZER>
                    <!-- 院内コード -->
                    <IN_HOSPITAL_CD>dataset:-447.mdr_in_hospital_cd</IN_HOSPITAL_CD>
                </MST_DIALYZER>
                <!-- 医療材料マスタ -->
                <MST_EQUIPMENT>
                    <!-- 院内コード -->
                    <IN_HOSPITAL_CD>dataset:-447.meqa_in_hospital_cd</IN_HOSPITAL_CD>
                </MST_EQUIPMENT>
            </RST_DIALYSIS_COND_HST>
            <RST_DIALYSIS_MEDICATION_HST _sqlCode="-450" CTL_NO="dataset:-450.ctl_no">
                <!-- 6.投薬履歴 -->
                <!-- 指示実施フラグ -->
                <EFFECT_FLG>dataset:-450.effect_flg</EFFECT_FLG>
                <!-- 薬剤コード -->
                <SET_MEDICINE_CD>dataset:-450.medicine_cd</SET_MEDICINE_CD>
                <!-- 手技コード -->
                <PROCEDURE_CD>dataset:-450.procedure_cd</PROCEDURE_CD>
                <!-- 実施日 -->
                <EFFECT_DATE>dataset:-450.effect_date</EFFECT_DATE>
                <!-- セット薬剤使用フラグ -->
                <SET_MEDICINE_FLG>dataset:-450.set_medicine_flg</SET_MEDICINE_FLG>
                <!-- 使用量 -->
                <AMOUNT>dataset:-450.amount</AMOUNT>
                <!-- 薬剤マスタ -->
                <MST_MEDICINE>
                    <!-- 注射フラグ -->
                    <SHOT>dataset:-450.mmd_is_shot</SHOT>
                    <!-- 薬剤コード(院内コード) -->
                    <IN_HOSPITAL_CD>dataset:-450.mmd_in_hospital_cd_1</IN_HOSPITAL_CD>
                    <!-- 薬剤コード(院内コード2) -->
                    <IN_HOSPITAL_CD2>dataset:-450.mmd_in_hospital_cd_2</IN_HOSPITAL_CD2>
                    <!-- 薬剤コード -->
                    <MEDICINE_CD>dataset:-450.mmd_medicine_cd</MEDICINE_CD>
                    <!-- 薬剤グループコード -->
                    <MEDICINE_GROUP_CD>dataset:-450.class_cd</MEDICINE_GROUP_CD>
                </MST_MEDICINE>
                <!-- 手技マスタ -->
                <MST_PROCEDURE>
                    <!-- ルート項目コード(院内コード) -->
                    <IN_HOSPITAL_CD1>dataset:-450.mp_in_hospital_cd_1</IN_HOSPITAL_CD1>
                    <!-- 投与方法項目コード(院内コード) -->
                    <IN_HOSPITAL_CD2>dataset:-450.mp_in_hospital_cd_2</IN_HOSPITAL_CD2>
                </MST_PROCEDURE>
                <MST_SET_MEDI_NAME>
                <!-- ※NTSSに薬剤セットが無し -->
                    <!-- 薬剤セットマスタ -->
                    <MST_SET_MEDICINE>
                        <!-- 薬剤マスタ -->
                        <MST_MEDICINE>
                            <!-- 薬剤マスタ・注射フラグ -->
                            <SHOT></SHOT>
                            <!-- 院内コード -->
                            <IN_HOSPITAL_CD></IN_HOSPITAL_CD>
                            <!-- 薬剤グループコード -->
                            <MEDICINE_GROUP_CD></MEDICINE_GROUP_CD>
                        </MST_MEDICINE>
                        <!-- 手技コード -->
                        <PROCEDURE_CD></PROCEDURE_CD>
                        <!-- 手技マスタ -->
                        <MST_PROCEDURE>
                            <!-- ルート項目コード(院内コード) -->
                            <IN_HOSPITAL_CD1></IN_HOSPITAL_CD1>
                            <!-- 投与方法項目コード(院内コード) -->
                            <IN_HOSPITAL_CD2></IN_HOSPITAL_CD2>
                        </MST_PROCEDURE>
                        <!-- 使用薬剤数 -->
                        <MEDI_USE_NUM></MEDI_USE_NUM>
                    </MST_SET_MEDICINE>
                    <!-- 院内コード２ -->
                    <IN_HOSPITAL_CD2></IN_HOSPITAL_CD2>
                </MST_SET_MEDI_NAME>
            </RST_DIALYSIS_MEDICATION_HST>
            <RST_DIALYSIS_TREATMENT_HST _sqlCode="-451" CTL_NO="dataset:-451.disp_no" NAME="dataset:-451.disp_name">
                <!-- 7.愁訴処置 -->
                <!-- 薬剤コード -->
                <TREAT_MEDICINE_CD>dataset:-451.medicine_cd</TREAT_MEDICINE_CD>
                <!-- 手技コード -->
                <PROCEDURE_CD>dataset:-451.procedure_cd</PROCEDURE_CD>
                <!-- 入力数 -->
                <AMOUNT>dataset:-451.amount</AMOUNT>
                <!-- 酸素吸入量(処置区分) -->
                <TREAT_CLASS>dataset:-451.treat_class</TREAT_CLASS>
                <!-- 酸素吸入量(実績番号) -->
                <RESULT_NO>dataset:-451.result_no</RESULT_NO>
                <!-- 酸素吸入量(発生日時) -->
                <OCCUR_DATE>dataset:-451.occur_date_start</OCCUR_DATE>
                <!-- 酸素吸入量(使用量) -->
                <OXYGEN_AMOUNT>dataset:-451.oxygen_amount</OXYGEN_AMOUNT>
                <!-- 酸素吸入量(酸素吸入開始日時) -->
                <OXYGEN_START>dataset:-451.oxygen_start_new</OXYGEN_START>
                <!-- 酸素吸入量(酸素吸入時間) -->
                <OXYGEN_TIME>dataset:-451.oxygen_time_new</OXYGEN_TIME>
                <!-- 薬剤マスタ -->
                <MST_MEDICINE>
                    <!-- 注射フラグ -->
                    <SHOT>dataset:-451.mmd_is_shot</SHOT>
                    <!-- 薬剤コード(院内コード) -->
                    <IN_HOSPITAL_CD>dataset:-451.mmd_in_hospital_cd_1</IN_HOSPITAL_CD>
                    <!-- 薬剤コード(院内コード2) -->
                    <IN_HOSPITAL_CD2>dataset:-451.mmd_in_hospital_cd_2</IN_HOSPITAL_CD2>
                    <!-- 薬剤コード -->
                    <MEDICINE_CD>dataset:-451.mmd_medicine_cd</MEDICINE_CD>
                    <!-- 薬剤グループコード -->
                    <MEDICINE_GROUP_CD>dataset:-451.mmd_class_cd</MEDICINE_GROUP_CD>
                </MST_MEDICINE>
                <MST_PROCEDURE>
                    <!-- ルート項目コード(院内コード) -->
                    <IN_HOSPITAL_CD1>dataset:-451.mp_in_hospital_cd_1</IN_HOSPITAL_CD1>
                    <!-- 投与方法項目コード(院内コード) -->
                    <IN_HOSPITAL_CD2>dataset:-451.mp_in_hospital_cd_2</IN_HOSPITAL_CD2>
                </MST_PROCEDURE>
                <MST_SET_MEDI_NAME>
                <!-- ※NTSSに薬剤セットが無し -->
                    <!-- 薬剤セットマスタ -->
                    <MST_SET_MEDICINE>
                        <!-- 薬剤マスタ -->
                        <MST_MEDICINE>
                            <!-- 薬剤マスタ・注射フラグ -->
                            <SHOT></SHOT>
                            <!-- 院内コード -->
                            <IN_HOSPITAL_CD></IN_HOSPITAL_CD>
                            <!-- 薬剤グループコード -->
                            <MEDICINE_GROUP_CD></MEDICINE_GROUP_CD>
                        </MST_MEDICINE>
                        <!-- 手技コード -->
                        <PROCEDURE_CD></PROCEDURE_CD>
                        <!-- 手技マスタ -->
                        <MST_PROCEDURE>
                            <!-- ルート項目コード(院内コード) -->
                            <IN_HOSPITAL_CD1></IN_HOSPITAL_CD1>
                            <!-- 投与方法項目コード(院内コード) -->
                            <IN_HOSPITAL_CD2></IN_HOSPITAL_CD2>
                        </MST_PROCEDURE>
                        <!-- 使用薬剤数 -->
                        <MEDI_USE_NUM></MEDI_USE_NUM>
                    </MST_SET_MEDICINE>
                    <!-- 院内コード２ -->
                    <IN_HOSPITAL_CD2></IN_HOSPITAL_CD2>
                </MST_SET_MEDI_NAME>
            </RST_DIALYSIS_TREATMENT_HST>
            <SYS_COOP_EXEC_DATA>
                <A00001>
                    <SYS_STAFF_AUTH>
                        <ACL>1</ACL>
                    </SYS_STAFF_AUTH>
                </A00001>
                <A00002>
                    <MST_BED>
                        <BED_NO>200</BED_NO>
                    </MST_BED>
                </A00002>
                <A10002>
                    <USER_TABLES>
                        <TABLE_NAME>IF_EVENT_LOG</TABLE_NAME>
                    </USER_TABLES>
                </A10002>
                <A20001>
                    <SYS_SYSTEM_DEFINE>
                        <VALUE>1</VALUE>
                    </SYS_SYSTEM_DEFINE>
                </A20001>
            </SYS_COOP_EXEC_DATA>
        </rootNode>
    </dump>
</coop_info>', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -444}, {"patId": "patId", "sqlCode": -445}, {"ordNo": "ordNo", "sqlCode": -447}, {"patId": "patId", "sqlCode": -448}, {"ordNo": "ordNo", "sqlCode": -450}, {"ordNo": "ordNo", "sqlCode": -451}], "dumpFileName": {"patId": "patId", "sqlCode": -99997}}', '1', '0', -1, '2021-10-13 07:01:35.63', '2021-10-13 07:01:35.63');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6030002, 'C_hosp', 'rst_dial', '', 'S', 'upd', 'xml', 'CSI透析実績', 'MIRAIs', '実績送信', '1', '<coop_info>
    <!-- 電文種別 -->
    <facility_cd>$JOURNAL.facility_cd</facility_cd>
    <!-- 電文種別 -->
    <coop_cd>rst_dial</coop_cd>
    <!-- 作成更新区分 -->
    <crud>U</crud>
    <!-- 向き（送受信） -->
    <direction>S</direction>
    <!-- （連携先)オーダ番号 -->
    <coop_ord_no>$JOURNAL.coop_ord_no</coop_ord_no>
    <!-- 患者番号（連携用） -->
    <hosp_pat_id>dataset:-200001.hosp_pat_id</hosp_pat_id>
    <!-- 電文内容 -->
    <dump>
        <rootNode>
            <!-- 1.患者基本情報 -->
            <PAT_BASIC_INFO>
                <!-- 表示用患者ID -->
                <DISP_PATID>dataset:-200001.hosp_pat_id</DISP_PATID>
                <!-- 患者ID -->
                <PATID>$JOURNAL.pat_id</PATID>
                <!-- 患者名 -->
                <NAME>dataset:-200001.pat_name</NAME>
                <!-- 医師1 -->
                <DOCTOR_CD1>dataset:-444.staff_cd1</DOCTOR_CD1>
                <!-- 医師2 -->
                <DOCTOR_CD2>dataset:-444.staff_cd2</DOCTOR_CD2>
                <MST_PAT_GROUP>
                    <!--患者基本情報・患者グループの院内コード-->
                    <IN_HOSPITAL_CD>dataset:-444.kur_cd1</IN_HOSPITAL_CD>
                </MST_PAT_GROUP>
                <!--患者基本情報・透析導入日-->
                <DIAL_START_DATE>dataset:-444.dialysis_start_date</DIAL_START_DATE>
                <!--患者基本情報・透析困難有無-->
                <DIAL_DIFF>dataset:-200001.dial_diff_com_info_flag</DIAL_DIFF>
                <MST_DIAL_DIFF_COMENT>
                    <!--患者基本情報・マスタ透析困難コメント・透析困難コメント-->
                    <DIAL_DIFF_COMMENT>dataset:-445.dialysis_difficulty_name</DIAL_DIFF_COMMENT>
                </MST_DIAL_DIFF_COMENT>
                <!--患者基本情報・入外区分-->
                <INOUT_FLG>dataset:-200001.in_out_class</INOUT_FLG>
                <MST_WARD>
                    <!--患者情報基本情報・病棟コード-->
                    <IN_HOSPITAL_CD>dataset:-444.course_cd1</IN_HOSPITAL_CD>
                </MST_WARD>
            </PAT_BASIC_INFO>
            <!-- 2.透析実績履歴 -->
            <RST_DIALYSIS_HST>
                <!--透析実績履歴・透析番号-->
                <DIALYSIS_NO>dataset:-444.rst_fn_dialysis_no</DIALYSIS_NO>
                <!--透析実績履歴・版番号-->
                <EDITION>dataset:-444.rst_edition</EDITION>
                <!--透析実績履歴・透析開始日時-->
                <START_DATE>dataset:-444.rst_start_date</START_DATE>
                <!--透析実績履歴・透析終了日時-->
                <END_DATE>dataset:-444.rst_end_date</END_DATE>
                <!-- ベッドコード -->
                <BED_NO>dataset:-444.bed_cd1</BED_NO>
                <MST_KUR>
                    <!--透析実績履歴・クールマスタ・クール名-->
                    <KUR_NAME>dataset:-444.kur_cd1</KUR_NAME>
                </MST_KUR>
                <!--透析実績履歴・透析時間-->
                <DIALYSIS_TIME>dataset:-444.rst_running_time</DIALYSIS_TIME>
                <!--透析実績履歴・病棟コード-->
                <WARD_CD>dataset:-444.course_cd1</WARD_CD>
                <MST_WARD>
                    <!--透析実績履歴・病棟マスタ・院内コード-->
                    <IN_HOSPITAL_CD>dataset:-444.rst_course_cd1</IN_HOSPITAL_CD>
                </MST_WARD>
            </RST_DIALYSIS_HST>
            <!-- 3.透析実績版番管理 -->
            <RST_DIALYSIS_EDITION>
                <!--透析実績版番管理.版確定者-->
                <DECIDER>dataset:-444.up_ind_user_id</DECIDER>
                <!--スタッフマスタ:版確定者-->
                <MST_STAFF STAFF_CD="dataset:-444.up_ind_user_id">
                    <!-- スタッフマスタ.職種コード-->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
            </RST_DIALYSIS_EDITION>
            <RST_RECEIPT_MEMO_HST _sqlCode="-448" NAME="dataset:-448.detail_id" DIVISION="0" ADD_FLG="0" MAIN_DIAL_DIFF="dataset:-448.is_main">
                <!-- 4.透析困難コメント:主たる透析困難コメントフラグ-->
                <!-- 透析困難コメント -->
                <ITEM_NAME>dataset:-448.dialysis_difficulty_name</ITEM_NAME>
            </RST_RECEIPT_MEMO_HST>
            <RST_DIALYSIS_COND_HST _sqlCode="-447" CTL_NO="dataset:-447.item_cd" NAME="dataset:-447.item_name">
                <!-- 5.透析条件履歴:透析条件項目コード -->
                <!-- 項目コード -->
                <CTL_NO>dataset:-447.item_cd</CTL_NO>
                <!-- 設定値 -->
                <VALUE>dataset:-447.item_value</VALUE>
                <!-- 治療方法マスタ -->
                <MST_TREAT_ITEM>
                    <!-- 治療項目マスタ・院内コード:複数データの場合，カンマ[,]区切り -->
                    <IN_HOSPITAL_CD>dataset:-447.mtt_in_hospital_cd</IN_HOSPITAL_CD>
                    <!-- 治療方法名称 -->
                    <TREAT_ITEM_NAME>dataset:-447.mtt_treatment_name</TREAT_ITEM_NAME>
                </MST_TREAT_ITEM>
                <!-- 薬剤マスタ -->
                <MST_MEDICINE>
                    <!-- 薬剤マスタ・注射フラグ -->
                    <SHOT>dataset:-447.med_is_shot</SHOT>
                    <!-- 院内コード -->
                    <IN_HOSPITAL_CD>dataset:-447.med_in_hospital_cd</IN_HOSPITAL_CD>
                </MST_MEDICINE>
                <MST_SET_MEDI_NAME>
                <!-- ※NTSSに薬剤セットが無し -->
                    <!-- 薬剤セットマスタ -->
                    <MST_SET_MEDICINE>
                        <!-- 薬剤マスタ -->
                        <MST_MEDICINE>
                            <!-- 薬剤マスタ・注射フラグ -->
                            <SHOT></SHOT>
                            <!-- 院内コード -->
                            <IN_HOSPITAL_CD></IN_HOSPITAL_CD>
                        </MST_MEDICINE>
                        <!-- 使用薬剤数 -->
                        <MEDI_USE_NUM></MEDI_USE_NUM>
                    </MST_SET_MEDICINE>
                </MST_SET_MEDI_NAME>
                <!-- ダイアライザマスタ -->
                <MST_DIALYZER>
                    <!-- 院内コード -->
                    <IN_HOSPITAL_CD>dataset:-447.mdr_in_hospital_cd</IN_HOSPITAL_CD>
                </MST_DIALYZER>
                <!-- 医療材料マスタ -->
                <MST_EQUIPMENT>
                    <!-- 院内コード -->
                    <IN_HOSPITAL_CD>dataset:-447.meqa_in_hospital_cd</IN_HOSPITAL_CD>
                </MST_EQUIPMENT>
            </RST_DIALYSIS_COND_HST>
            <RST_DIALYSIS_MEDICATION_HST _sqlCode="-450" CTL_NO="dataset:-450.ctl_no">
                <!-- 6.投薬履歴 -->
                <!-- 指示実施フラグ -->
                <EFFECT_FLG>dataset:-450.effect_flg</EFFECT_FLG>
                <!-- 薬剤コード -->
                <SET_MEDICINE_CD>dataset:-450.medicine_cd</SET_MEDICINE_CD>
                <!-- 手技コード -->
                <PROCEDURE_CD>dataset:-450.procedure_cd</PROCEDURE_CD>
                <!-- 実施日 -->
                <EFFECT_DATE>dataset:-450.effect_date</EFFECT_DATE>
                <!-- セット薬剤使用フラグ -->
                <SET_MEDICINE_FLG>dataset:-450.set_medicine_flg</SET_MEDICINE_FLG>
                <!-- 使用量 -->
                <AMOUNT>dataset:-450.amount</AMOUNT>
                <!-- 薬剤マスタ -->
                <MST_MEDICINE>
                    <!-- 注射フラグ -->
                    <SHOT>dataset:-450.mmd_is_shot</SHOT>
                    <!-- 薬剤コード(院内コード) -->
                    <IN_HOSPITAL_CD>dataset:-450.mmd_in_hospital_cd_1</IN_HOSPITAL_CD>
                    <!-- 薬剤コード(院内コード2) -->
                    <IN_HOSPITAL_CD2>dataset:-450.mmd_in_hospital_cd_2</IN_HOSPITAL_CD2>
                    <!-- 薬剤コード -->
                    <MEDICINE_CD>dataset:-450.mmd_medicine_cd</MEDICINE_CD>
                    <!-- 薬剤グループコード -->
                    <MEDICINE_GROUP_CD>dataset:-450.class_cd</MEDICINE_GROUP_CD>
                </MST_MEDICINE>
                <!-- 手技マスタ -->
                <MST_PROCEDURE>
                    <!-- ルート項目コード(院内コード) -->
                    <IN_HOSPITAL_CD1>dataset:-450.mp_in_hospital_cd_1</IN_HOSPITAL_CD1>
                    <!-- 投与方法項目コード(院内コード) -->
                    <IN_HOSPITAL_CD2>dataset:-450.mp_in_hospital_cd_2</IN_HOSPITAL_CD2>
                </MST_PROCEDURE>
                <MST_SET_MEDI_NAME>
                <!-- ※NTSSに薬剤セットが無し -->
                    <!-- 薬剤セットマスタ -->
                    <MST_SET_MEDICINE>
                        <!-- 薬剤マスタ -->
                        <MST_MEDICINE>
                            <!-- 薬剤マスタ・注射フラグ -->
                            <SHOT></SHOT>
                            <!-- 院内コード -->
                            <IN_HOSPITAL_CD></IN_HOSPITAL_CD>
                            <!-- 薬剤グループコード -->
                            <MEDICINE_GROUP_CD></MEDICINE_GROUP_CD>
                        </MST_MEDICINE>
                        <!-- 手技コード -->
                        <PROCEDURE_CD></PROCEDURE_CD>
                        <!-- 手技マスタ -->
                        <MST_PROCEDURE>
                            <!-- ルート項目コード(院内コード) -->
                            <IN_HOSPITAL_CD1></IN_HOSPITAL_CD1>
                            <!-- 投与方法項目コード(院内コード) -->
                            <IN_HOSPITAL_CD2></IN_HOSPITAL_CD2>
                        </MST_PROCEDURE>
                        <!-- 使用薬剤数 -->
                        <MEDI_USE_NUM></MEDI_USE_NUM>
                    </MST_SET_MEDICINE>
                    <!-- 院内コード２ -->
                    <IN_HOSPITAL_CD2></IN_HOSPITAL_CD2>
                </MST_SET_MEDI_NAME>
            </RST_DIALYSIS_MEDICATION_HST>
            <RST_DIALYSIS_TREATMENT_HST _sqlCode="-451" CTL_NO="dataset:-451.disp_no" NAME="dataset:-451.disp_name">
                <!-- 7.愁訴処置 -->
                <!-- 薬剤コード -->
                <TREAT_MEDICINE_CD>dataset:-451.medicine_cd</TREAT_MEDICINE_CD>
                <!-- 手技コード -->
                <PROCEDURE_CD>dataset:-451.procedure_cd</PROCEDURE_CD>
                <!-- 入力数 -->
                <AMOUNT>dataset:-451.amount</AMOUNT>
                <!-- 酸素吸入量(処置区分) -->
                <TREAT_CLASS>dataset:-451.treat_class</TREAT_CLASS>
                <!-- 酸素吸入量(実績番号) -->
                <RESULT_NO>dataset:-451.result_no</RESULT_NO>
                <!-- 酸素吸入量(発生日時) -->
                <OCCUR_DATE>dataset:-451.occur_date_start</OCCUR_DATE>
                <!-- 酸素吸入量(使用量) -->
                <OXYGEN_AMOUNT>dataset:-451.oxygen_amount</OXYGEN_AMOUNT>
                <!-- 酸素吸入量(酸素吸入開始日時) -->
                <OXYGEN_START>dataset:-451.oxygen_start_new</OXYGEN_START>
                <!-- 酸素吸入量(酸素吸入時間) -->
                <OXYGEN_TIME>dataset:-451.oxygen_time_new</OXYGEN_TIME>
                <!-- 薬剤マスタ -->
                <MST_MEDICINE>
                    <!-- 注射フラグ -->
                    <SHOT>dataset:-451.mmd_is_shot</SHOT>
                    <!-- 薬剤コード(院内コード) -->
                    <IN_HOSPITAL_CD>dataset:-451.mmd_in_hospital_cd_1</IN_HOSPITAL_CD>
                    <!-- 薬剤コード(院内コード2) -->
                    <IN_HOSPITAL_CD2>dataset:-451.mmd_in_hospital_cd_2</IN_HOSPITAL_CD2>
                    <!-- 薬剤コード -->
                    <MEDICINE_CD>dataset:-451.mmd_medicine_cd</MEDICINE_CD>
                    <!-- 薬剤グループコード -->
                    <MEDICINE_GROUP_CD>dataset:-451.mmd_class_cd</MEDICINE_GROUP_CD>
                </MST_MEDICINE>
                <MST_PROCEDURE>
                    <!-- ルート項目コード(院内コード) -->
                    <IN_HOSPITAL_CD1>dataset:-451.mp_in_hospital_cd_1</IN_HOSPITAL_CD1>
                    <!-- 投与方法項目コード(院内コード) -->
                    <IN_HOSPITAL_CD2>dataset:-451.mp_in_hospital_cd_2</IN_HOSPITAL_CD2>
                </MST_PROCEDURE>
                <MST_SET_MEDI_NAME>
                <!-- ※NTSSに薬剤セットが無し -->
                    <!-- 薬剤セットマスタ -->
                    <MST_SET_MEDICINE>
                        <!-- 薬剤マスタ -->
                        <MST_MEDICINE>
                            <!-- 薬剤マスタ・注射フラグ -->
                            <SHOT></SHOT>
                            <!-- 院内コード -->
                            <IN_HOSPITAL_CD></IN_HOSPITAL_CD>
                            <!-- 薬剤グループコード -->
                            <MEDICINE_GROUP_CD></MEDICINE_GROUP_CD>
                        </MST_MEDICINE>
                        <!-- 手技コード -->
                        <PROCEDURE_CD></PROCEDURE_CD>
                        <!-- 手技マスタ -->
                        <MST_PROCEDURE>
                            <!-- ルート項目コード(院内コード) -->
                            <IN_HOSPITAL_CD1></IN_HOSPITAL_CD1>
                            <!-- 投与方法項目コード(院内コード) -->
                            <IN_HOSPITAL_CD2></IN_HOSPITAL_CD2>
                        </MST_PROCEDURE>
                        <!-- 使用薬剤数 -->
                        <MEDI_USE_NUM></MEDI_USE_NUM>
                    </MST_SET_MEDICINE>
                    <!-- 院内コード２ -->
                    <IN_HOSPITAL_CD2></IN_HOSPITAL_CD2>
                </MST_SET_MEDI_NAME>
            </RST_DIALYSIS_TREATMENT_HST>
            <SYS_COOP_EXEC_DATA>
                <A00001>
                    <SYS_STAFF_AUTH>
                        <ACL>1</ACL>
                    </SYS_STAFF_AUTH>
                </A00001>
                <A00002>
                    <MST_BED>
                        <BED_NO>200</BED_NO>
                    </MST_BED>
                </A00002>
                <A10002>
                    <USER_TABLES>
                        <TABLE_NAME>IF_EVENT_LOG</TABLE_NAME>
                    </USER_TABLES>
                </A10002>
                <A20001>
                    <SYS_SYSTEM_DEFINE>
                        <VALUE>1</VALUE>
                    </SYS_SYSTEM_DEFINE>
                </A20001>
            </SYS_COOP_EXEC_DATA>
        </rootNode>
    </dump>
</coop_info>', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -444}, {"patId": "patId", "sqlCode": -445}, {"ordNo": "ordNo", "sqlCode": -447}, {"patId": "patId", "sqlCode": -448}, {"ordNo": "ordNo", "sqlCode": -450}, {"ordNo": "ordNo", "sqlCode": -451}], "dumpFileName": {"patId": "patId", "sqlCode": -99997}}', '1', '0', -1, '2021-10-13 07:01:35.63', '2021-10-13 07:01:35.63');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6030003, 'C_hosp', 'rst_dial', '', 'S', 'del', 'xml', 'CSI透析実績', 'MIRAIs', '実績送信', '1', '<coop_info>
    <!-- 電文種別 -->
    <facility_cd>$JOURNAL.facility_cd</facility_cd>
    <!-- 電文種別 -->
    <coop_cd>rst_dial</coop_cd>
    <!-- 作成更新区分 -->
    <crud>D</crud>
    <!-- 向き（送受信） -->
    <direction>S</direction>
    <!-- （連携先)オーダ番号 -->
    <coop_ord_no>$JOURNAL.coop_ord_no</coop_ord_no>
    <!-- 患者番号（連携用） -->
    <hosp_pat_id>dataset:-200001.hosp_pat_id</hosp_pat_id>
    <!-- 電文内容 -->
    <dump>
        <rootNode>
            <!-- 1.患者基本情報 -->
            <PAT_BASIC_INFO>
                <!-- 表示用患者ID -->
                <DISP_PATID>dataset:-200001.hosp_pat_id</DISP_PATID>
                <!-- 患者ID -->
                <PATID>$JOURNAL.pat_id</PATID>
                <!-- 患者名 -->
                <NAME>dataset:-200001.pat_name</NAME>
                <!-- 医師1 -->
                <DOCTOR_CD1>dataset:-444.staff_cd1</DOCTOR_CD1>
                <!-- 医師2 -->
                <DOCTOR_CD2>dataset:-444.staff_cd2</DOCTOR_CD2>
                <MST_PAT_GROUP>
                    <!--患者基本情報・患者グループの院内コード-->
                    <IN_HOSPITAL_CD>dataset:-444.kur_cd1</IN_HOSPITAL_CD>
                </MST_PAT_GROUP>
                <!--患者基本情報・透析導入日-->
                <DIAL_START_DATE>dataset:-444.dialysis_start_date</DIAL_START_DATE>
                <!--患者基本情報・透析困難有無-->
                <DIAL_DIFF>dataset:-200001.dial_diff_com_info_flag</DIAL_DIFF>
                <MST_DIAL_DIFF_COMENT>
                    <!--患者基本情報・マスタ透析困難コメント・透析困難コメント-->
                    <DIAL_DIFF_COMMENT>dataset:-445.dialysis_difficulty_name</DIAL_DIFF_COMMENT>
                </MST_DIAL_DIFF_COMENT>
                <!--患者基本情報・入外区分-->
                <INOUT_FLG>dataset:-200001.in_out_class</INOUT_FLG>
                <MST_WARD>
                    <!--患者情報基本情報・病棟コード-->
                    <IN_HOSPITAL_CD>dataset:-444.course_cd1</IN_HOSPITAL_CD>
                </MST_WARD>
            </PAT_BASIC_INFO>
            <!-- 2.透析実績履歴 -->
            <RST_DIALYSIS_HST>
                <!--透析実績履歴・透析番号-->
                <DIALYSIS_NO>dataset:-444.rst_fn_dialysis_no</DIALYSIS_NO>
                <!--透析実績履歴・版番号-->
                <EDITION>dataset:-444.rst_edition</EDITION>
                <!--透析実績履歴・透析開始日時-->
                <START_DATE>dataset:-444.rst_start_date</START_DATE>
                <!--透析実績履歴・透析終了日時-->
                <END_DATE>dataset:-444.rst_end_date</END_DATE>
                <!-- ベッドコード -->
                <BED_NO>dataset:-444.bed_cd1</BED_NO>
                <MST_KUR>
                    <!--透析実績履歴・クールマスタ・クール名-->
                    <KUR_NAME>dataset:-444.kur_cd1</KUR_NAME>
                </MST_KUR>
                <!--透析実績履歴・透析時間-->
                <DIALYSIS_TIME>dataset:-444.rst_running_time</DIALYSIS_TIME>
                <!--透析実績履歴・病棟コード-->
                <WARD_CD>dataset:-444.course_cd1</WARD_CD>
                <MST_WARD>
                    <!--透析実績履歴・病棟マスタ・院内コード-->
                    <IN_HOSPITAL_CD>dataset:-444.rst_course_cd1</IN_HOSPITAL_CD>
                </MST_WARD>
            </RST_DIALYSIS_HST>
            <!-- 3.透析実績版番管理 -->
            <RST_DIALYSIS_EDITION>
                <!--透析実績版番管理.版確定者-->
                <DECIDER>dataset:-444.up_ind_user_id</DECIDER>
                <!--スタッフマスタ:版確定者-->
                <MST_STAFF STAFF_CD="dataset:-444.up_ind_user_id">
                    <!-- スタッフマスタ.職種コード-->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
            </RST_DIALYSIS_EDITION>
            <RST_RECEIPT_MEMO_HST _sqlCode="-448" NAME="dataset:-448.detail_id" DIVISION="0" ADD_FLG="0" MAIN_DIAL_DIFF="dataset:-448.is_main">
                <!-- 4.透析困難コメント:主たる透析困難コメントフラグ-->
                <!-- 透析困難コメント -->
                <ITEM_NAME>dataset:-448.dialysis_difficulty_name</ITEM_NAME>
            </RST_RECEIPT_MEMO_HST>
            <RST_DIALYSIS_COND_HST _sqlCode="-447" CTL_NO="dataset:-447.item_cd" NAME="dataset:-447.item_name">
                <!-- 5.透析条件履歴:透析条件項目コード -->
                <!-- 項目コード -->
                <CTL_NO>dataset:-447.item_cd</CTL_NO>
                <!-- 設定値 -->
                <VALUE>dataset:-447.item_value</VALUE>
                <!-- 治療方法マスタ -->
                <MST_TREAT_ITEM>
                    <!-- 治療項目マスタ・院内コード:複数データの場合，カンマ[,]区切り -->
                    <IN_HOSPITAL_CD>dataset:-447.mtt_in_hospital_cd</IN_HOSPITAL_CD>
                    <!-- 治療方法名称 -->
                    <TREAT_ITEM_NAME>dataset:-447.mtt_treatment_name</TREAT_ITEM_NAME>
                </MST_TREAT_ITEM>
                <!-- 薬剤マスタ -->
                <MST_MEDICINE>
                    <!-- 薬剤マスタ・注射フラグ -->
                    <SHOT>dataset:-447.med_is_shot</SHOT>
                    <!-- 院内コード -->
                    <IN_HOSPITAL_CD>dataset:-447.med_in_hospital_cd</IN_HOSPITAL_CD>
                </MST_MEDICINE>
                <MST_SET_MEDI_NAME>
                <!-- ※NTSSに薬剤セットが無し -->
                    <!-- 薬剤セットマスタ -->
                    <MST_SET_MEDICINE>
                        <!-- 薬剤マスタ -->
                        <MST_MEDICINE>
                            <!-- 薬剤マスタ・注射フラグ -->
                            <SHOT></SHOT>
                            <!-- 院内コード -->
                            <IN_HOSPITAL_CD></IN_HOSPITAL_CD>
                        </MST_MEDICINE>
                        <!-- 使用薬剤数 -->
                        <MEDI_USE_NUM></MEDI_USE_NUM>
                    </MST_SET_MEDICINE>
                </MST_SET_MEDI_NAME>
                <!-- ダイアライザマスタ -->
                <MST_DIALYZER>
                    <!-- 院内コード -->
                    <IN_HOSPITAL_CD>dataset:-447.mdr_in_hospital_cd</IN_HOSPITAL_CD>
                </MST_DIALYZER>
                <!-- 医療材料マスタ -->
                <MST_EQUIPMENT>
                    <!-- 院内コード -->
                    <IN_HOSPITAL_CD>dataset:-447.meqa_in_hospital_cd</IN_HOSPITAL_CD>
                </MST_EQUIPMENT>
            </RST_DIALYSIS_COND_HST>
            <RST_DIALYSIS_MEDICATION_HST _sqlCode="-450" CTL_NO="dataset:-450.ctl_no">
                <!-- 6.投薬履歴 -->
                <!-- 指示実施フラグ -->
                <EFFECT_FLG>dataset:-450.effect_flg</EFFECT_FLG>
                <!-- 薬剤コード -->
                <SET_MEDICINE_CD>dataset:-450.medicine_cd</SET_MEDICINE_CD>
                <!-- 手技コード -->
                <PROCEDURE_CD>dataset:-450.procedure_cd</PROCEDURE_CD>
                <!-- 実施日 -->
                <EFFECT_DATE>dataset:-450.effect_date</EFFECT_DATE>
                <!-- セット薬剤使用フラグ -->
                <SET_MEDICINE_FLG>dataset:-450.set_medicine_flg</SET_MEDICINE_FLG>
                <!-- 使用量 -->
                <AMOUNT>dataset:-450.amount</AMOUNT>
                <!-- 薬剤マスタ -->
                <MST_MEDICINE>
                    <!-- 注射フラグ -->
                    <SHOT>dataset:-450.mmd_is_shot</SHOT>
                    <!-- 薬剤コード(院内コード) -->
                    <IN_HOSPITAL_CD>dataset:-450.mmd_in_hospital_cd_1</IN_HOSPITAL_CD>
                    <!-- 薬剤コード(院内コード2) -->
                    <IN_HOSPITAL_CD2>dataset:-450.mmd_in_hospital_cd_2</IN_HOSPITAL_CD2>
                    <!-- 薬剤コード -->
                    <MEDICINE_CD>dataset:-450.mmd_medicine_cd</MEDICINE_CD>
                    <!-- 薬剤グループコード -->
                    <MEDICINE_GROUP_CD>dataset:-450.class_cd</MEDICINE_GROUP_CD>
                </MST_MEDICINE>
                <!-- 手技マスタ -->
                <MST_PROCEDURE>
                    <!-- ルート項目コード(院内コード) -->
                    <IN_HOSPITAL_CD1>dataset:-450.mp_in_hospital_cd_1</IN_HOSPITAL_CD1>
                    <!-- 投与方法項目コード(院内コード) -->
                    <IN_HOSPITAL_CD2>dataset:-450.mp_in_hospital_cd_2</IN_HOSPITAL_CD2>
                </MST_PROCEDURE>
                <MST_SET_MEDI_NAME>
                <!-- ※NTSSに薬剤セットが無し -->
                    <!-- 薬剤セットマスタ -->
                    <MST_SET_MEDICINE>
                        <!-- 薬剤マスタ -->
                        <MST_MEDICINE>
                            <!-- 薬剤マスタ・注射フラグ -->
                            <SHOT></SHOT>
                            <!-- 院内コード -->
                            <IN_HOSPITAL_CD></IN_HOSPITAL_CD>
                            <!-- 薬剤グループコード -->
                            <MEDICINE_GROUP_CD></MEDICINE_GROUP_CD>
                        </MST_MEDICINE>
                        <!-- 手技コード -->
                        <PROCEDURE_CD></PROCEDURE_CD>
                        <!-- 手技マスタ -->
                        <MST_PROCEDURE>
                            <!-- ルート項目コード(院内コード) -->
                            <IN_HOSPITAL_CD1></IN_HOSPITAL_CD1>
                            <!-- 投与方法項目コード(院内コード) -->
                            <IN_HOSPITAL_CD2></IN_HOSPITAL_CD2>
                        </MST_PROCEDURE>
                        <!-- 使用薬剤数 -->
                        <MEDI_USE_NUM></MEDI_USE_NUM>
                    </MST_SET_MEDICINE>
                    <!-- 院内コード２ -->
                    <IN_HOSPITAL_CD2></IN_HOSPITAL_CD2>
                </MST_SET_MEDI_NAME>
            </RST_DIALYSIS_MEDICATION_HST>
            <RST_DIALYSIS_TREATMENT_HST _sqlCode="-451" CTL_NO="dataset:-451.disp_no" NAME="dataset:-451.disp_name">
                <!-- 7.愁訴処置 -->
                <!-- 薬剤コード -->
                <TREAT_MEDICINE_CD>dataset:-451.medicine_cd</TREAT_MEDICINE_CD>
                <!-- 手技コード -->
                <PROCEDURE_CD>dataset:-451.procedure_cd</PROCEDURE_CD>
                <!-- 入力数 -->
                <AMOUNT>dataset:-451.amount</AMOUNT>
                <!-- 酸素吸入量(処置区分) -->
                <TREAT_CLASS>dataset:-451.treat_class</TREAT_CLASS>
                <!-- 酸素吸入量(実績番号) -->
                <RESULT_NO>dataset:-451.result_no</RESULT_NO>
                <!-- 酸素吸入量(発生日時) -->
                <OCCUR_DATE>dataset:-451.occur_date_start</OCCUR_DATE>
                <!-- 酸素吸入量(使用量) -->
                <OXYGEN_AMOUNT>dataset:-451.oxygen_amount</OXYGEN_AMOUNT>
                <!-- 酸素吸入量(酸素吸入開始日時) -->
                <OXYGEN_START>dataset:-451.oxygen_start_new</OXYGEN_START>
                <!-- 酸素吸入量(酸素吸入時間) -->
                <OXYGEN_TIME>dataset:-451.oxygen_time_new</OXYGEN_TIME>
                <!-- 薬剤マスタ -->
                <MST_MEDICINE>
                    <!-- 注射フラグ -->
                    <SHOT>dataset:-451.mmd_is_shot</SHOT>
                    <!-- 薬剤コード(院内コード) -->
                    <IN_HOSPITAL_CD>dataset:-451.mmd_in_hospital_cd_1</IN_HOSPITAL_CD>
                    <!-- 薬剤コード(院内コード2) -->
                    <IN_HOSPITAL_CD2>dataset:-451.mmd_in_hospital_cd_2</IN_HOSPITAL_CD2>
                    <!-- 薬剤コード -->
                    <MEDICINE_CD>dataset:-451.mmd_medicine_cd</MEDICINE_CD>
                    <!-- 薬剤グループコード -->
                    <MEDICINE_GROUP_CD>dataset:-451.mmd_class_cd</MEDICINE_GROUP_CD>
                </MST_MEDICINE>
                <MST_PROCEDURE>
                    <!-- ルート項目コード(院内コード) -->
                    <IN_HOSPITAL_CD1>dataset:-451.mp_in_hospital_cd_1</IN_HOSPITAL_CD1>
                    <!-- 投与方法項目コード(院内コード) -->
                    <IN_HOSPITAL_CD2>dataset:-451.mp_in_hospital_cd_2</IN_HOSPITAL_CD2>
                </MST_PROCEDURE>
                <MST_SET_MEDI_NAME>
                <!-- ※NTSSに薬剤セットが無し -->
                    <!-- 薬剤セットマスタ -->
                    <MST_SET_MEDICINE>
                        <!-- 薬剤マスタ -->
                        <MST_MEDICINE>
                            <!-- 薬剤マスタ・注射フラグ -->
                            <SHOT></SHOT>
                            <!-- 院内コード -->
                            <IN_HOSPITAL_CD></IN_HOSPITAL_CD>
                            <!-- 薬剤グループコード -->
                            <MEDICINE_GROUP_CD></MEDICINE_GROUP_CD>
                        </MST_MEDICINE>
                        <!-- 手技コード -->
                        <PROCEDURE_CD></PROCEDURE_CD>
                        <!-- 手技マスタ -->
                        <MST_PROCEDURE>
                            <!-- ルート項目コード(院内コード) -->
                            <IN_HOSPITAL_CD1></IN_HOSPITAL_CD1>
                            <!-- 投与方法項目コード(院内コード) -->
                            <IN_HOSPITAL_CD2></IN_HOSPITAL_CD2>
                        </MST_PROCEDURE>
                        <!-- 使用薬剤数 -->
                        <MEDI_USE_NUM></MEDI_USE_NUM>
                    </MST_SET_MEDICINE>
                    <!-- 院内コード２ -->
                    <IN_HOSPITAL_CD2></IN_HOSPITAL_CD2>
                </MST_SET_MEDI_NAME>
            </RST_DIALYSIS_TREATMENT_HST>
            <SYS_COOP_EXEC_DATA>
                <A00001>
                    <SYS_STAFF_AUTH>
                        <ACL>1</ACL>
                    </SYS_STAFF_AUTH>
                </A00001>
                <A00002>
                    <MST_BED>
                        <BED_NO>200</BED_NO>
                    </MST_BED>
                </A00002>
                <A10002>
                    <USER_TABLES>
                        <TABLE_NAME>IF_EVENT_LOG</TABLE_NAME>
                    </USER_TABLES>
                </A10002>
                <A20001>
                    <SYS_SYSTEM_DEFINE>
                        <VALUE>1</VALUE>
                    </SYS_SYSTEM_DEFINE>
                </A20001>
            </SYS_COOP_EXEC_DATA>
        </rootNode>
    </dump>
</coop_info>', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -444}, {"patId": "patId", "sqlCode": -445}, {"ordNo": "ordNo", "sqlCode": -447}, {"patId": "patId", "sqlCode": -448}, {"ordNo": "ordNo", "sqlCode": -450}, {"ordNo": "ordNo", "sqlCode": -451}], "dumpFileName": {"patId": "patId", "sqlCode": -99997}}', '1', '0', -1, '2021-10-13 07:01:35.63', '2021-10-13 07:01:35.63');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6040001, 'C_hosp', 'rep_dial', '', 'S', 'cre', 'xml', 'CSI透析レポート', 'MIRAIs', 'テスト用report', '1', '<coop_info>
    <!-- 施設コード -->
    <facility_cd>$JOURNAL.facility_cd</facility_cd>
    <!-- 電文種別 -->
    <coop_cd>rep_dial</coop_cd>
    <!-- 作成更新区分 -->
    <crud>C</crud>
    <!-- 向き（送受信） -->
    <direction>S</direction>
    <!-- （連携先)オーダ番号 -->
    <coop_ord_no>$JOURNAL.coop_ord_no</coop_ord_no>
    <!-- 患者番号（連携用） -->
    <hosp_pat_id>dataset:-200001.hosp_pat_id</hosp_pat_id>
    <!-- 電文内容 -->
    <dump>
        <rootNode>
            <!-- 患者情報 -->
            <PAT_BASIC_INFO>
                <!-- 表示用患者ID -->
                <DISP_PATID>$JOURNAL.pat_id</DISP_PATID>
                <!-- 患者ID -->
                <PATID>dataset:-200001.hosp_pat_id</PATID>
                <!-- 名前 -->
                <NAME>dataset:-200001.pat_name</NAME>
                <!-- フリガナ -->
                <NAME_KANA>dataset:-200001.pat_name_kana</NAME_KANA>
                <!-- 生年月日 -->
                <BIRTHDAY>dataset:-200001.pat_birthday</BIRTHDAY>
                <!-- 性別 -->
                <SEX_CD>dataset:-200001.pat_sex</SEX_CD>
                <!-- 血液型ABO -->
                <BLOOD_TYPE_ABO>dataset:-200001.pat_blood_type_abo</BLOOD_TYPE_ABO>
                <!-- 血液型RH -->
                <BLOOD_TYPE_RH>dataset:-200001.pat_blood_type_rh</BLOOD_TYPE_RH>
                <!-- 入外区分 -->
                <INOUT_FLG>dataset:-200001.in_out_class</INOUT_FLG>
            </PAT_BASIC_INFO>
            <!-- レポート一覧 -->
            <RST_DIALYSIS_HST>
                <!-- 透析番号 -->
                <DIALYSIS_NO>dataset:-200006.dialysis_no</DIALYSIS_NO>
                <!-- 開始日＆開始時刻 -->
                <START_DATE>dataset:-200006.start_date14a</START_DATE>
                <!-- 版番 -->
                <EDITION>dataset:-200006.edition</EDITION>
                <!-- ベッドマスタ -->
                <MST_BED>
                    <!-- ベッド名 -->
                    <BED_NAME>dataset:-200006.bed_name</BED_NAME>
                </MST_BED>
            </RST_DIALYSIS_HST>
            <SYS_COOP_EXEC_DATA>
                <A00001>
                    <RST_DIALYSIS>
                        <DEL_FLG>0</DEL_FLG>
                    </RST_DIALYSIS>
                </A00001>
            </SYS_COOP_EXEC_DATA>
        </rootNode>
   </dump>
</coop_info>', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "sqlCode": -200006}]}', '1', '0', 4, '2020-05-25 18:26:36.811', '2020-05-25 18:26:41.871');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6040002, 'C_hosp', 'rep_dial', '', 'S', 'upd', 'xml', 'CSI透析レポート', 'MIRAIs', 'テスト用report', '1', '<coop_info>
    <!-- 施設コード -->
    <facility_cd>$JOURNAL.facility_cd</facility_cd>
    <!-- 電文種別 -->
    <coop_cd>rep_dial</coop_cd>
    <!-- 作成更新区分 -->
    <crud>U</crud>
    <!-- 向き（送受信） -->
    <direction>S</direction>
    <!-- （連携先)オーダ番号 -->
    <coop_ord_no>$JOURNAL.coop_ord_no</coop_ord_no>
    <!-- 患者番号（連携用） -->
    <hosp_pat_id>dataset:-200001.hosp_pat_id</hosp_pat_id>
    <!-- 電文内容 -->
    <dump>
        <rootNode>
            <!-- 患者情報 -->
            <PAT_BASIC_INFO>
                <!-- 表示用患者ID -->
                <DISP_PATID>$JOURNAL.pat_id</DISP_PATID>
                <!-- 患者ID -->
                <PATID>dataset:-200001.hosp_pat_id</PATID>
                <!-- 名前 -->
                <NAME>dataset:-200001.pat_name</NAME>
                <!-- フリガナ -->
                <NAME_KANA>dataset:-200001.pat_name_kana</NAME_KANA>
                <!-- 生年月日 -->
                <BIRTHDAY>dataset:-200001.pat_birthday</BIRTHDAY>
                <!-- 性別 -->
                <SEX_CD>dataset:-200001.pat_sex</SEX_CD>
                <!-- 血液型ABO -->
                <BLOOD_TYPE_ABO>dataset:-200001.pat_blood_type_abo</BLOOD_TYPE_ABO>
                <!-- 血液型RH -->
                <BLOOD_TYPE_RH>dataset:-200001.pat_blood_type_rh</BLOOD_TYPE_RH>
                <!-- 入外区分 -->
                <INOUT_FLG>dataset:-200001.in_out_class</INOUT_FLG>
            </PAT_BASIC_INFO>
            <!-- レポート一覧 -->
            <RST_DIALYSIS_HST>
                <!-- 透析番号 -->
                <DIALYSIS_NO>dataset:-200006.dialysis_no</DIALYSIS_NO>
                <!-- 開始日＆開始時刻 -->
                <START_DATE>dataset:-200006.start_date14a</START_DATE>
                <!-- 版番 -->
                <EDITION>dataset:-200006.edition</EDITION>
                <!-- ベッドマスタ -->
                <MST_BED>
                    <!-- ベッド名 -->
                    <BED_NAME>dataset:-200006.bed_name</BED_NAME>
                </MST_BED>
            </RST_DIALYSIS_HST>
            <SYS_COOP_EXEC_DATA>
                <A00001>
                    <RST_DIALYSIS>
                        <DEL_FLG>0</DEL_FLG>
                    </RST_DIALYSIS>
                </A00001>
            </SYS_COOP_EXEC_DATA>
        </rootNode>
   </dump>
</coop_info>', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "sqlCode": -200006}]}', '1', '0', 4, '2025-01-02 18:26:36.811', '2025-01-02 18:26:41.871');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6040003, 'C_hosp', 'rep_dial', '', 'S', 'del', 'xml', 'CSI透析レポート', 'MIRAIs', 'テスト用report', '1', '<coop_info>
    <!-- 施設コード -->
    <facility_cd>$JOURNAL.facility_cd</facility_cd>
    <!-- 電文種別 -->
    <coop_cd>rep_dial</coop_cd>
    <!-- 作成更新区分 -->
    <crud>D</crud>
    <!-- 向き（送受信） -->
    <direction>S</direction>
    <!-- （連携先)オーダ番号 -->
    <coop_ord_no>$JOURNAL.coop_ord_no</coop_ord_no>
    <!-- 患者番号（連携用） -->
    <hosp_pat_id>dataset:-200001.hosp_pat_id</hosp_pat_id>
    <!-- 電文内容 -->
    <dump>
        <rootNode>
            <!-- 患者情報 -->
            <PAT_BASIC_INFO>
                <!-- 表示用患者ID -->
                <DISP_PATID>$JOURNAL.pat_id</DISP_PATID>
                <!-- 患者ID -->
                <PATID>dataset:-200001.hosp_pat_id</PATID>
                <!-- 名前 -->
                <NAME>dataset:-200001.pat_name</NAME>
                <!-- フリガナ -->
                <NAME_KANA>dataset:-200001.pat_name_kana</NAME_KANA>
                <!-- 生年月日 -->
                <BIRTHDAY>dataset:-200001.pat_birthday</BIRTHDAY>
                <!-- 性別 -->
                <SEX_CD>dataset:-200001.pat_sex</SEX_CD>
                <!-- 血液型ABO -->
                <BLOOD_TYPE_ABO>dataset:-200001.pat_blood_type_abo</BLOOD_TYPE_ABO>
                <!-- 血液型RH -->
                <BLOOD_TYPE_RH>dataset:-200001.pat_blood_type_rh</BLOOD_TYPE_RH>
                <!-- 入外区分 -->
                <INOUT_FLG>dataset:-200001.in_out_class</INOUT_FLG>
            </PAT_BASIC_INFO>
            <!-- レポート一覧 -->
            <RST_DIALYSIS_HST>
                <!-- 透析番号 -->
                <DIALYSIS_NO>dataset:-200006.dialysis_no</DIALYSIS_NO>
                <!-- 開始日＆開始時刻 -->
                <START_DATE>dataset:-200006.start_date14a</START_DATE>
                <!-- 版番 -->
                <EDITION>dataset:-200006.edition</EDITION>
                <!-- ベッドマスタ -->
                <MST_BED>
                    <!-- ベッド名 -->
                    <BED_NAME>dataset:-200006.bed_name</BED_NAME>
                </MST_BED>
            </RST_DIALYSIS_HST>
            <SYS_COOP_EXEC_DATA>
                <A00001>
                    <RST_DIALYSIS>
                        <DEL_FLG>0</DEL_FLG>
                    </RST_DIALYSIS>
                </A00001>
            </SYS_COOP_EXEC_DATA>
        </rootNode>
   </dump>
</coop_info>', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "sqlCode": -200006}]}', '1', '0', 4, '2025-01-02 18:26:36.811', '2025-01-02 18:26:41.871');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6050001, 'C_hosp', 'exam_ord', '', 'S', 'cre', 'xml', 'CSI検査オーダ', 'MIRAIs', '検査オーダ', '1', '<coop_info>
    <!-- 電文種別 -->
    <facility_cd>$JOURNAL.facility_cd</facility_cd>
    <!-- 電文種別 -->
    <coop_cd>exam_ord</coop_cd>
    <!-- 作成更新区分 -->
    <crud>C</crud>
    <!-- 向き（送受信） -->
    <direction>S</direction>
    <!-- （連携先)オーダ番号 -->
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
                <DOCTOR_CD1>dataset:-442.staff_cd1</DOCTOR_CD1>
                <!-- 医師2 -->
                <DOCTOR_CD2>dataset:-442.staff_cd2</DOCTOR_CD2>
                <MST_PAT_GROUP>
                    <!-- 科コード -->
                    <IN_HOSPITAL_CD>dataset:-442.course_cd1</IN_HOSPITAL_CD>
                </MST_PAT_GROUP>
            </PAT_BASIC_INFO>
            <!-- 検査スケジュール -->
            <PAT_EXAMIN_SCHEDULE>
                <!-- 指示者 -->
                <DOCTOR_CODE>dataset:-442.ind_user_id</DOCTOR_CODE>
                <!-- スタッフマスタ：指示者の値 -->
                <MST_STAFF STAFF_CD="dataset:-442.ind_user_id">
                    <!-- 職種コード -->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 検査区分 -->
                <EXAM_DIVISION>dataset:-442.reg_order_class</EXAM_DIVISION>
                <!-- オーダ日時 -->
                <UP_DATE>dataset:-442.up_date</UP_DATE>
                <!-- オーダ入力者 -->
                <ORDER_STAFF>dataset:-442.reg_staff</ORDER_STAFF>
                <!-- 更新者 -->
                <UPDATE_CODE>dataset:-442.up_staff</UPDATE_CODE>
                <!-- 検査予定日 -->
                <EXAM_DATE>dataset:-442.reg_exam_date</EXAM_DATE>
                <!-- 検査セット -->
                <MST_EXAM_SET>
                    <MST_EXAM_SET_DETAIL>
                        <MST_EXAM_ITEM>
                            <!-- 検査項目 -->
                            <IN_HOSPITAL_CD2 _sqlCode="-443" NAME="dataset:-443.item_name">dataset:-443.in_hospital_cd1</IN_HOSPITAL_CD2>
                        </MST_EXAM_ITEM>
                    </MST_EXAM_SET_DETAIL>
                    <!-- その他開始時刻 -->
                    <OTHER_EXAM_TIME>dataset:-442.other_exam_time</OTHER_EXAM_TIME>
                </MST_EXAM_SET>
            </PAT_EXAMIN_SCHEDULE>
            <!-- 透析後/透析後 -->
            <SCH_DIALYSIS_PLAN>
                <MST_KUR>
                    <!-- クール標準開始時間 -->
                    <STANDARD_START_TIME>dataset:-442.standard_start_time</STANDARD_START_TIME>
                </MST_KUR>
                <BED_NO>???</BED_NO>
            </SCH_DIALYSIS_PLAN>
            <!-- 透析後:CTL_NO="002" -->
            <IND_DIALYSIS_COND CTL_NO="002">
                <!-- 予定透析時間 -->
                <VALUE>dataset:-442.ind_dialysis_time</VALUE>
            </IND_DIALYSIS_COND>
            <RST_DIALYSIS_HST>
                <!-- 透析番号 -->
                <DIALYSIS_NO>???</DIALYSIS_NO>
                <!-- 版番 -->
                <EDITION>???</EDITION>
            </RST_DIALYSIS_HST>
            <!-- 血液検査送信 BLOOD_EXAM_SEND_INFO-->
            <血液検査送信>
                <!--検査日 -->
                <EXAM_DATE>dataset:-442.reg_exam_date</EXAM_DATE>
                <!-- 検査区分 -->
                <EXAM_DIVISION>dataset:-442.reg_order_class</EXAM_DIVISION>
                <!-- 検査セットコード -->
                <EXAM_SET_CD>dataset:-442.exam_set_cd</EXAM_SET_CD>
            </血液検査送信>
            <SYS_COOP_EXEC_DATA>
                <A00001>
                    <PAT_EXAMIN_SCHEDULE>
                        <UPDATE_CODE>100</UPDATE_CODE>
                    </PAT_EXAMIN_SCHEDULE>
                </A00001>
                <A00002>
                    <PAT_EXAMIN_SCHEDULE>
                        <UPDATE_CODE>200</UPDATE_CODE>
                    </PAT_EXAMIN_SCHEDULE>
                </A00002>
                <A00003>
                    <SYS_STAFF_AUTH>
                        <ACL>1000</ACL>
                    </SYS_STAFF_AUTH>
                </A00003>
                <A00004>
                    <MST_BED>
                        <BED_NO>PAT_GROUP_FLG</BED_NO>
                    </MST_BED>
                </A00004>
                <A10002>
                    <USER_TABLES>
                        <TABLE_NAME>IF_EVENT_LOG</TABLE_NAME>
                    </USER_TABLES>
                </A10002>
            </SYS_COOP_EXEC_DATA>
        </rootNode>
    </dump>
</coop_info>', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -442}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -443}]}', '1', '0', -1, '2021-09-06 11:38:27', '2021-09-06 11:38:31');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6050002, 'C_hosp', 'exam_ord', '', 'S', 'upd', 'xml', 'CSI検査オーダ', 'MIRAIs', '検査オーダ', '1', '<coop_info>
    <!-- 電文種別 -->
    <facility_cd>$JOURNAL.facility_cd</facility_cd>
    <!-- 電文種別 -->
    <coop_cd>exam_ord</coop_cd>
    <!-- 作成更新区分 -->
    <crud>U</crud>
    <!-- 向き（送受信） -->
    <direction>S</direction>
    <!-- （連携先)オーダ番号 -->
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
                <DOCTOR_CD1>dataset:-442.staff_cd1</DOCTOR_CD1>
                <!-- 医師2 -->
                <DOCTOR_CD2>dataset:-442.staff_cd2</DOCTOR_CD2>
                <MST_PAT_GROUP>
                    <!-- 科コード -->
                    <IN_HOSPITAL_CD>dataset:-442.course_cd1</IN_HOSPITAL_CD>
                </MST_PAT_GROUP>
            </PAT_BASIC_INFO>
            <!-- 検査スケジュール -->
            <PAT_EXAMIN_SCHEDULE>
                <!-- 指示者 -->
                <DOCTOR_CODE>dataset:-442.ind_user_id</DOCTOR_CODE>
                <!-- スタッフマスタ：指示者の値 -->
                <MST_STAFF STAFF_CD="dataset:-442.ind_user_id">
                    <!-- 職種コード -->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 検査区分 -->
                <EXAM_DIVISION>dataset:-442.reg_order_class</EXAM_DIVISION>
                <!-- オーダ日時 -->
                <UP_DATE>dataset:-442.up_date</UP_DATE>
                <!-- オーダ入力者 -->
                <ORDER_STAFF>dataset:-442.reg_staff</ORDER_STAFF>
                <!-- 更新者 -->
                <UPDATE_CODE>dataset:-442.up_staff</UPDATE_CODE>
                <!-- 検査予定日 -->
                <EXAM_DATE>dataset:-442.reg_exam_date</EXAM_DATE>
                <!-- 検査セット -->
                <MST_EXAM_SET>
                    <MST_EXAM_SET_DETAIL>
                        <MST_EXAM_ITEM>
                            <!-- 検査項目 -->
                            <IN_HOSPITAL_CD2 _sqlCode="-443" NAME="dataset:-443.item_name">dataset:-443.in_hospital_cd1</IN_HOSPITAL_CD2>
                        </MST_EXAM_ITEM>
                    </MST_EXAM_SET_DETAIL>
                    <!-- その他開始時刻 -->
                    <OTHER_EXAM_TIME>dataset:-442.other_exam_time</OTHER_EXAM_TIME>
                </MST_EXAM_SET>
            </PAT_EXAMIN_SCHEDULE>
            <!-- 透析後/透析後 -->
            <SCH_DIALYSIS_PLAN>
                <MST_KUR>
                    <!-- クール標準開始時間 -->
                    <STANDARD_START_TIME>dataset:-442.standard_start_time</STANDARD_START_TIME>
                </MST_KUR>
                <BED_NO>???</BED_NO>
            </SCH_DIALYSIS_PLAN>
            <!-- 透析後:CTL_NO="002" -->
            <IND_DIALYSIS_COND CTL_NO="002">
                <!-- 予定透析時間 -->
                <VALUE>dataset:-442.ind_dialysis_time</VALUE>
            </IND_DIALYSIS_COND>
            <RST_DIALYSIS_HST>
                <!-- 透析番号 -->
                <DIALYSIS_NO>???</DIALYSIS_NO>
                <!-- 版番 -->
                <EDITION>???</EDITION>
            </RST_DIALYSIS_HST>
            <!-- 血液検査送信 BLOOD_EXAM_SEND_INFO-->
            <血液検査送信>
                <!--検査日 -->
                <EXAM_DATE>dataset:-442.reg_exam_date</EXAM_DATE>
                <!-- 検査区分 -->
                <EXAM_DIVISION>dataset:-442.reg_order_class</EXAM_DIVISION>
                <!-- 検査セットコード -->
                <EXAM_SET_CD>dataset:-442.exam_set_cd</EXAM_SET_CD>
            </血液検査送信>
            <SYS_COOP_EXEC_DATA>
                <A00001>
                    <PAT_EXAMIN_SCHEDULE>
                        <UPDATE_CODE>100</UPDATE_CODE>
                    </PAT_EXAMIN_SCHEDULE>
                </A00001>
                <A00002>
                    <PAT_EXAMIN_SCHEDULE>
                        <UPDATE_CODE>200</UPDATE_CODE>
                    </PAT_EXAMIN_SCHEDULE>
                </A00002>
                <A00003>
                    <SYS_STAFF_AUTH>
                        <ACL>1000</ACL>
                    </SYS_STAFF_AUTH>
                </A00003>
                <A00004>
                    <MST_BED>
                        <BED_NO>PAT_GROUP_FLG</BED_NO>
                    </MST_BED>
                </A00004>
                <A10002>
                    <USER_TABLES>
                        <TABLE_NAME>IF_EVENT_LOG</TABLE_NAME>
                    </USER_TABLES>
                </A10002>
            </SYS_COOP_EXEC_DATA>
        </rootNode>
    </dump>
</coop_info>', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -442}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -443}]}', '1', '0', -1, '2021-09-06 11:38:27', '2021-09-06 11:38:31');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6050003, 'C_hosp', 'exam_ord', '', 'S', 'del', 'xml', 'CSI検査オーダ', 'MIRAIs', '検査オーダ', '1', '<coop_info>
    <!-- 電文種別 -->
    <facility_cd>$JOURNAL.facility_cd</facility_cd>
    <!-- 電文種別 -->
    <coop_cd>exam_ord</coop_cd>
    <!-- 作成更新区分 -->
    <crud>D</crud>
    <!-- 向き（送受信） -->
    <direction>S</direction>
    <!-- （連携先)オーダ番号 -->
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
                <DOCTOR_CD1>dataset:-442.staff_cd1</DOCTOR_CD1>
                <!-- 医師2 -->
                <DOCTOR_CD2>dataset:-442.staff_cd2</DOCTOR_CD2>
                <MST_PAT_GROUP>
                    <!-- 科コード -->
                    <IN_HOSPITAL_CD>dataset:-442.course_cd1</IN_HOSPITAL_CD>
                </MST_PAT_GROUP>
            </PAT_BASIC_INFO>
            <!-- 検査スケジュール -->
            <PAT_EXAMIN_SCHEDULE>
                <!-- 指示者 -->
                <DOCTOR_CODE>dataset:-442.ind_user_id</DOCTOR_CODE>
                <!-- スタッフマスタ：指示者の値 -->
                <MST_STAFF STAFF_CD="dataset:-442.ind_user_id">
                    <!-- 職種コード -->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 検査区分 -->
                <EXAM_DIVISION>dataset:-442.reg_order_class</EXAM_DIVISION>
                <!-- オーダ日時 -->
                <UP_DATE>dataset:-442.up_date</UP_DATE>
                <!-- オーダ入力者 -->
                <ORDER_STAFF>dataset:-442.reg_staff</ORDER_STAFF>
                <!-- 更新者 -->
                <UPDATE_CODE>dataset:-442.up_staff</UPDATE_CODE>
                <!-- 検査予定日 -->
                <EXAM_DATE>dataset:-442.reg_exam_date</EXAM_DATE>
                <!-- 検査セット -->
                <MST_EXAM_SET>
                    <MST_EXAM_SET_DETAIL>
                        <MST_EXAM_ITEM>
                            <!-- 検査項目 -->
                            <IN_HOSPITAL_CD2 _sqlCode="-443" NAME="dataset:-443.item_name">dataset:-443.in_hospital_cd1</IN_HOSPITAL_CD2>
                        </MST_EXAM_ITEM>
                    </MST_EXAM_SET_DETAIL>
                    <!-- その他開始時刻 -->
                    <OTHER_EXAM_TIME>dataset:-442.other_exam_time</OTHER_EXAM_TIME>
                </MST_EXAM_SET>
            </PAT_EXAMIN_SCHEDULE>
            <!-- 透析後/透析後 -->
            <SCH_DIALYSIS_PLAN>
                <MST_KUR>
                    <!-- クール標準開始時間 -->
                    <STANDARD_START_TIME>dataset:-442.standard_start_time</STANDARD_START_TIME>
                </MST_KUR>
                <BED_NO>???</BED_NO>
            </SCH_DIALYSIS_PLAN>
            <!-- 透析後:CTL_NO="002" -->
            <IND_DIALYSIS_COND CTL_NO="002">
                <!-- 予定透析時間 -->
                <VALUE>dataset:-442.ind_dialysis_time</VALUE>
            </IND_DIALYSIS_COND>
            <RST_DIALYSIS_HST>
                <!-- 透析番号 -->
                <DIALYSIS_NO>???</DIALYSIS_NO>
                <!-- 版番 -->
                <EDITION>???</EDITION>
            </RST_DIALYSIS_HST>
            <!-- 血液検査送信 BLOOD_EXAM_SEND_INFO-->
            <血液検査送信>
                <!--検査日 -->
                <EXAM_DATE>dataset:-442.reg_exam_date</EXAM_DATE>
                <!-- 検査区分 -->
                <EXAM_DIVISION>dataset:-442.reg_order_class</EXAM_DIVISION>
                <!-- 検査セットコード -->
                <EXAM_SET_CD>dataset:-442.exam_set_cd</EXAM_SET_CD>
            </血液検査送信>
            <SYS_COOP_EXEC_DATA>
                <A00001>
                    <PAT_EXAMIN_SCHEDULE>
                        <UPDATE_CODE>100</UPDATE_CODE>
                    </PAT_EXAMIN_SCHEDULE>
                </A00001>
                <A00002>
                    <PAT_EXAMIN_SCHEDULE>
                        <UPDATE_CODE>200</UPDATE_CODE>
                    </PAT_EXAMIN_SCHEDULE>
                </A00002>
                <A00003>
                    <SYS_STAFF_AUTH>
                        <ACL>1000</ACL>
                    </SYS_STAFF_AUTH>
                </A00003>
                <A00004>
                    <MST_BED>
                        <BED_NO>PAT_GROUP_FLG</BED_NO>
                    </MST_BED>
                </A00004>
                <A10002>
                    <USER_TABLES>
                        <TABLE_NAME>IF_EVENT_LOG</TABLE_NAME>
                    </USER_TABLES>
                </A10002>
            </SYS_COOP_EXEC_DATA>
        </rootNode>
    </dump>
</coop_info>', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -442}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -443}]}', '1', '0', -1, '2021-09-06 11:38:27', '2021-09-06 11:38:31');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6060001, 'C_hosp', 'exam_rst', '', 'S', 'cre', 'xml', 'CSI検査結果', 'MIRAIs', '検査結果', '1', '<coop_info>
    <facility_cd>$JOURNAL.facility_cd</facility_cd>
    <coop_cd>exam_rst</coop_cd>
		<crud>C</crud>
    <direction>S</direction>
    <dump></dump>
</coop_info>', '{}', '1', '0', -1, '2019-12-23 06:35:38', '2020-01-14 11:01:43.398');
