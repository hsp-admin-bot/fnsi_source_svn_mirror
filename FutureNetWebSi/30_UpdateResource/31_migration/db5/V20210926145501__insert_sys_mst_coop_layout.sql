DELETE FROM "mst_coop_layout"  WHERE "ctl_no" IN (-6010001,-6010002,-6020001,-6020002,-6020003,-6040001,-6040002,-6040003,-6050001,-6050002,-6050003,-6060001,-6060002);INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6010001, 'C_hosp', 'profile', '', 'S', 'cre', 'xml', 'CSI患者プロファイル', 'MIRAIs', '患者プロファイル', '1', '<coop_info>
    <facility_cd>$JOURNAL.facility_cd</facility_cd>
    <coop_cd>profile</coop_cd>
    <crud>1</crud>
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
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6010002, 'C_hosp', 'profile', 'send_time', 'S', 'cre', 'xml', '定時一括送信機能（CSI患者プロファイル用）', 'MIRAIs', '患者プロファイル(定時)', '1', NULL, '{"dataset": [{"sqlCode": -2400, "facilityCd": "facilityCd", "PreSqlInfoItem": ["@ord_no", "@pat_id"]}]}', '1', '0', -1, '2021-09-01 07:38:44.069', '2021-09-01 07:38:44.069');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6020001, 'C_hosp', 'ind_dial', '', 'S', 'cre', 'xml', 'CSI透析予約', 'MIRAIs', '透析予約', '1', '<coop_info>
    <!-- 電文種別 -->
    <facility_cd>$JOURNAL.facility_cd</facility_cd>
    <!-- 電文種別 -->
    <coop_cd>ind_dial</coop_cd>
    <!-- 作成更新区分 -->
    <crud>1</crud>
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
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6040001, 'C_hosp', 'rep_dial', '', 'S', 'cre', 'xml', 'CSI透析レポート', 'MIRAIs', 'テスト用report', '1', '<coop_info>
    <!-- 施設コード -->
    <facility_cd>$JOURNAL.facility_cd</facility_cd>
    <!-- 電文種別 -->
    <coop_cd>rep_dial</coop_cd>
    <!-- 作成更新区分 -->
    <crud>1</crud>
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
    <crud>2</crud>
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
    <crud>3</crud>
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
    <crud>1</crud>
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
                <DOCTOR_CD1></DOCTOR_CD1>
                <!-- 医師2 -->
                <DOCTOR_CD2></DOCTOR_CD2>
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
</coop_info>', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -442}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -443}], "CoopIniConvUtil": {"$journal.pat_personal_main.is_die": "is_die", "$journal.pat_personal_main.pat_sex": "pat_sex", "$journal.pat_personal_main.in_out_class": "in_out_class", "$journal.detail.pat_main.infect_info.infect": "infect", "$journal.pat_personal_main.pat_blood_type_rh": "pat_blood_type_rh", "$journal.pat_personal_main.pat_blood_type_abo": "pat_blood_type_abo", "$journal.pat_main.medical_care_info.main_course_cd": "main_course_cd"}}', '1', '0', -1, '2021-09-06 11:38:27', '2021-09-06 11:38:31');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6050002, 'C_hosp', 'exam_ord', '', 'S', 'upd', 'xml', 'CSI検査オーダ', 'MIRAIs', '検査オーダ', '1', '<coop_info>
    <!-- 電文種別 -->
    <facility_cd>$JOURNAL.facility_cd</facility_cd>
    <!-- 電文種別 -->
    <coop_cd>exam_ord</coop_cd>
    <!-- 作成更新区分 -->
    <crud>2</crud>
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
                <DOCTOR_CD1></DOCTOR_CD1>
                <!-- 医師2 -->
                <DOCTOR_CD2></DOCTOR_CD2>
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
    <crud>3</crud>
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
                <DOCTOR_CD1></DOCTOR_CD1>
                <!-- 医師2 -->
                <DOCTOR_CD2></DOCTOR_CD2>
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
		<crud>1</crud>
    <direction>S</direction>
    <dump></dump>
</coop_info>', '{}', '1', '0', -1, '2019-12-23 06:35:38', '2020-01-14 11:01:43.398');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6060002, 'C_hosp', 'exam_rst', 'send_time', 'S', 'cre', 'xml', '定時一括送信機能(CSI検査結果)', 'MIRAIs', '検査結果(定時)', '1', NULL, '{}', '1', '0', -1, '2021-09-01 07:38:44.069', '2021-09-01 07:38:44.069');
