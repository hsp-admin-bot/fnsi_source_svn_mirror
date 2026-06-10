DELETE FROM "mst_coop_layout" WHERE "ctl_no" >= -6050003 AND "ctl_no" <= -6050001;
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6050001, 'C_hosp', 'exam_ord', '', 'S', 'cre', 'xml', 'CSI検査オーダ', 'MIRAIs', '検査オーダ', '1', '<coop_info>

    <!-- 電文種別 -->

    <facility_cd>$JOURNAL.facility_cd</facility_cd>

    <!-- 電文種別 -->

    <coop_cd>exam_ord</coop_cd>

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
