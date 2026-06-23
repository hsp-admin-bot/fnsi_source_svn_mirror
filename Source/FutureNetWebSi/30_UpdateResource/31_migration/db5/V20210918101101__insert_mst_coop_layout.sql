delete from "mst_coop_layout" where "ctl_no" <= -6040001 and "ctl_no" >= -6040011;
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6040001, 'C_hosp', 'rep_dial', '', 'S', 'cre', 'xml', 'CSI透析レポート', 'MIRAIs', 'テスト用report', '1', '<coop_info>

    <!-- 施設コード -->

    <facility_cd>$JOURNAL.facility_cd</facility_cd>

    <!-- 電文種別 -->

    <coop_cd>rep_dial</coop_cd>

    <!-- 作成更新区分 -->

    <crud>1</crud>

    <!-- 向き（送受信） -->

    <direction>S</direction>

    <!-- ord_no -->

    <coop_ord_no>$JOURNAL.ord_no</coop_ord_no>

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

    <!-- ord_no -->

    <coop_ord_no>$JOURNAL.ord_no</coop_ord_no>

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

    <crud>2</crud>

    <!-- 向き（送受信） -->

    <direction>S</direction>

    <!-- ord_no -->

    <coop_ord_no>$JOURNAL.ord_no</coop_ord_no>

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
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6040004, 'C_hosp', 'rep_dial', 'xml', 'S', 'cre', 'xml', 'CSI透析レポート(xml)', 'MIRAIs', 'テスト用report', '1', '<rootNode>
  <PATIENT UPDATE_DATETIME="dataset:-200001.up_date">
    <DISP_PATID>dataset:-200001.hosp_pat_id</DISP_PATID>
    <PATID>$JOURNAL.pat_id</PATID>
    <NAME>dataset:-200001.pat_name</NAME>
    <KANA>dataset:-200001.pat_name_kana</KANA>
    <BIRTHDAY>dataset:-200001.pat_birthday</BIRTHDAY>
    <AGE>dataset:-200001.pat_age</AGE>
    <SEX>dataset:-200001.pat_sex</SEX>
    <INOUT>dataset:-200001.in_out_class</INOUT>
  </PATIENT>
  <REPORTS _detail="report" _sqlCode="-200000">
  </REPORTS>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"sqlCode": -200000}]}', '1', '0', -1, '2021-09-01 07:38:44.069', '2021-09-01 07:38:44.069');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6040005, 'C_hosp', 'rep_dial', 'xml', 'S', 'upd', 'xml', 'CSI透析レポート(xml)', 'MIRAIs', 'テスト用report', '1', '<rootNode>
  <PATIENT UPDATE_DATETIME="dataset:-200001.up_date">
    <DISP_PATID>dataset:-200001.hosp_pat_id</DISP_PATID>
    <PATID>$JOURNAL.pat_id</PATID>
    <NAME>dataset:-200001.pat_name</NAME>
    <KANA>dataset:-200001.pat_name_kana</KANA>
    <BIRTHDAY>dataset:-200001.pat_birthday</BIRTHDAY>
    <AGE>dataset:-200001.pat_age</AGE>
    <SEX>dataset:-200001.pat_sex</SEX>
    <INOUT>dataset:-200001.in_out_class</INOUT>
  </PATIENT>
  <REPORTS _detail="report" _sqlCode="-200000">
  </REPORTS>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"sqlCode": -200000}]}', '1', '0', -1, '2021-09-01 07:38:44.069', '2021-09-01 07:38:44.069');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6040006, 'C_hosp', 'rep_dial', 'listxml', 'S', 'upd', 'xml', 'CSI透析レポート(listxml)', 'MIRAIs', 'テスト用report', '1', '<rootNode DISP_PATID_LENGTH="dataset:-200010.hosp_pat_id_len">
<PATIENT DISP_PATID="dataset:-200001.hosp_pat_id" PATID="$JOURNAL.pat_id"  NAME="dataset:-200001.pat_name" KANA="dataset:-200001.pat_name_kana"  SEX="dataset:-200001.pat_sex" BLOODABO="dataset:-200001.pat_blood_type_abo" BLOODRH="dataset:-200001.pat_blood_type_rh" AGE="dataset:-200001.pat_age" UPDATE_DATETIME="dataset:-200001.up_date"></PATIENT>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"sqlCode": -200010, "facilityCd": "facilityCd"}]}', '1', '0', -1, '2021-09-01 07:38:44.069', '2021-09-01 07:38:44.069');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6040007, 'C_hosp', 'rep_dial', 'listxml', 'S', 'cre', 'xml', 'CSI透析レポート(listxml)', 'MIRAIs', 'テスト用report', '1', '<rootNode DISP_PATID_LENGTH="dataset:-200010.hosp_pat_id_len">
<PATIENT DISP_PATID="dataset:-200001.hosp_pat_id" PATID="$JOURNAL.pat_id"  NAME="dataset:-200001.pat_name" KANA="dataset:-200001.pat_name_kana"  SEX="dataset:-200001.pat_sex" BLOODABO="dataset:-200001.pat_blood_type_abo" BLOODRH="dataset:-200001.pat_blood_type_rh" AGE="dataset:-200001.pat_age" UPDATE_DATETIME="dataset:-200001.up_date"></PATIENT>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"sqlCode": -200010, "facilityCd": "facilityCd"}]}', '1', '0', -1, '2021-09-01 07:38:44.069', '2021-09-01 07:38:44.069');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6040008, 'C_hosp', 'rep_dial', 'pdf', 'S', 'upd', 'pdf', 'CSI透析レポート(pdf)', 'MIRAIs', 'テスト用report', '1', NULL, NULL, '1', '0', -1, '2021-09-01 07:38:44.069', '2021-09-01 07:38:44.069');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6040009, 'C_hosp', 'rep_dial', 'pdf', 'S', 'cre', 'pdf', 'CSI透析レポート(pdf)', 'MIRAIs', 'テスト用report', '1', NULL, NULL, '1', '0', -1, '2021-09-01 07:38:44.069', '2021-09-01 07:38:44.069');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6040010, 'C_hosp', 'rep_dial', 'tar', 'S', 'upd', 'xml', 'CSI透析レポート(tar)', 'MIRAIs', 'テスト用report', '1', '<rootNode>
  <PATIENT UPDATE_DATETIME="dataset:-200001.up_date">
    <DISP_PATID>dataset:-200001.hosp_pat_id</DISP_PATID>
    <PATID>$JOURNAL.pat_id</PATID>
    <NAME>dataset:-200001.pat_name</NAME>
    <KANA>dataset:-200001.pat_name_kana</KANA>
    <BIRTHDAY>dataset:-200001.pat_birthday</BIRTHDAY>
    <AGE>dataset:-200001.pat_age</AGE>
    <SEX>dataset:-200001.pat_sex</SEX>
    <INOUT>dataset:-200001.in_out_class</INOUT>
  </PATIENT>
  <REPORTS _detail="report" _sqlCode="-200000">
  </REPORTS>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"sqlCode": -200000}]}', '1', '0', -1, '2021-09-01 07:38:44.069', '2021-09-01 07:38:44.069');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6040011, 'C_hosp', 'rep_dial', 'tar', 'S', 'cre', 'xml', 'CSI透析レポート(tar)', 'MIRAIs', 'テスト用report', '1', '<rootNode>
  <PATIENT UPDATE_DATETIME="dataset:-200001.up_date">
    <DISP_PATID>dataset:-200001.hosp_pat_id</DISP_PATID>
    <PATID>$JOURNAL.pat_id</PATID>
    <NAME>dataset:-200001.pat_name</NAME>
    <KANA>dataset:-200001.pat_name_kana</KANA>
    <BIRTHDAY>dataset:-200001.pat_birthday</BIRTHDAY>
    <AGE>dataset:-200001.pat_age</AGE>
    <SEX>dataset:-200001.pat_sex</SEX>
    <INOUT>dataset:-200001.in_out_class</INOUT>
  </PATIENT>
  <REPORTS _detail="report" _sqlCode="-200000">
  </REPORTS>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"sqlCode": -200000}]}', '1', '0', -1, '2021-09-01 07:38:44.069', '2021-09-01 07:38:44.069');
