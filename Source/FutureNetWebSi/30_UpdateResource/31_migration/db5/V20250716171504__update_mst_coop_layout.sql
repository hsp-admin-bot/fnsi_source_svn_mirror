DELETE FROM mst_coop_layout WHERE ctl_no IN 
(-12081001,-12082001,-12083001,-12081002,-12082002,-12082003,-12081003,-12082004,-12081004,-12083002,-12083003);


INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-12081001, 'F_SX', 'rep_dial', '', 'S', 'cre', 'xml', 'SX連携_透析レポート', 'F_SX', 'テスト用report', '1', '<coop_info>
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
    <hosp_pat_id>dataset:-400001.hosp_pat_id</hosp_pat_id>
    <!-- 電文内容 -->
    <dump>
        <rootNode>
            <!-- 患者情報 -->
            <PAT_BASIC_INFO>
                <!-- 表示用患者ID -->
                <DISP_PATID>$JOURNAL.pat_id</DISP_PATID>
                <!-- 患者ID -->
                <PATID>dataset:-400001.hosp_pat_id</PATID>
                <!-- 名前 -->
                <NAME>dataset:-400001.pat_name</NAME>
                <!-- フリガナ -->
                <NAME_KANA>dataset:-400001.pat_name_kana</NAME_KANA>
                <!-- 生年月日 -->
                <BIRTHDAY>dataset:-400001.pat_birthday</BIRTHDAY>
                <!-- 性別 -->
                <SEX_CD>dataset:-400001.pat_sex</SEX_CD>
                <!-- 血液型ABO -->
                <BLOOD_TYPE_ABO>dataset:-400001.pat_blood_type_abo</BLOOD_TYPE_ABO>
                <!-- 血液型RH -->
                <BLOOD_TYPE_RH>dataset:-400001.pat_blood_type_rh</BLOOD_TYPE_RH>
                <!-- 入外区分 -->
                <INOUT_FLG>dataset:-400001.in_out_class</INOUT_FLG>
            </PAT_BASIC_INFO>
            <!-- レポート一覧 -->
            <RST_DIALYSIS_HST>
                <!-- 透析番号 -->
                <DIALYSIS_NO>dataset:-400006.dialysis_no</DIALYSIS_NO>
                <!-- 開始日＆開始時刻 -->
                <START_DATE>dataset:-400006.start_date14a</START_DATE>
                <!-- 版番 -->
                <EDITION>dataset:-400006.edition</EDITION>
                <!-- ベッドマスタ -->
                <MST_BED>
                    <!-- ベッド名 -->
                    <BED_NAME>dataset:-400006.bed_name</BED_NAME>
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
</coop_info>', '{"dataset": [{"patId": "patId", "sqlCode": -400001}, {"ordNo": "ordNo", "sqlCode": -400006}]}'::jsonb, '1', '0', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'F_SX');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-12081002, 'F_SX', 'rep_dial', 'xml', 'S', 'cre', 'xml', 'SX連携_透析レポート(xml)', 'F_SX', 'テスト用report', '1', '<rootNode>
  <PATIENT UPDATE_DATETIME="dataset:-400001.up_date">
    <DISP_PATID>dataset:-400001.hosp_pat_id</DISP_PATID>
    <PATID>$JOURNAL.pat_id</PATID>
    <NAME>dataset:-400001.pat_name</NAME>
    <KANA>dataset:-400001.pat_name_kana</KANA>
    <BIRTHDAY>dataset:-400001.pat_birthday</BIRTHDAY>
    <AGE>dataset:-400001.pat_age</AGE>
    <SEX>dataset:-400001.pat_sex</SEX>
    <INOUT>dataset:-400001.in_out_class</INOUT>
  </PATIENT>
  <REPORTS _detail="report" _sqlCode="-400000">
  </REPORTS>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -400001}, {"sqlCode": -400000}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'F_SX');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-12081003, 'F_SX', 'rep_dial', 'listxml', 'S', 'cre', 'xml', 'SX連携_透析レポート(listxml)', 'F_SX', 'テスト用report', '1', '<rootNode DISP_PATID_LENGTH="dataset:-400010.hosp_pat_id_len">
<PATIENT DISP_PATID="dataset:-400001.hosp_pat_id" PATID="$JOURNAL.pat_id"  NAME="dataset:-400001.pat_name" KANA="dataset:-400001.pat_name_kana"  SEX="dataset:-400001.pat_sex" BLOODABO="dataset:-400016.pat_blood_type_abo" BLOODRH="dataset:-400016.pat_blood_type_rh" AGE="dataset:-400001.pat_age" UPDATE_DATETIME="dataset:-400001.up_date"></PATIENT>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -400001}, {"sqlCode": -400010, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}, {"patId": "patId", "sqlCode": -400016}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'F_SX');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-12081004, 'F_SX', 'rep_dial', 'pdf', 'S', 'cre', 'pdf', 'SX連携_透析レポート(pdf)', 'F_SX', 'テスト用report', '1', '<rootnode></rootnode>', NULL, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'F_SX');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-12082001, 'F_SX', 'rep_dial', '', 'S', 'upd', 'xml', 'SX連携_透析レポート', 'F_SX', 'テスト用report', '1', '<coop_info>
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
    <hosp_pat_id>dataset:-400001.hosp_pat_id</hosp_pat_id>
    <!-- 電文内容 -->
    <dump>
        <rootNode>
            <!-- 患者情報 -->
            <PAT_BASIC_INFO>
                <!-- 表示用患者ID -->
                <DISP_PATID>$JOURNAL.pat_id</DISP_PATID>
                <!-- 患者ID -->
                <PATID>dataset:-400001.hosp_pat_id</PATID>
                <!-- 名前 -->
                <NAME>dataset:-400001.pat_name</NAME>
                <!-- フリガナ -->
                <NAME_KANA>dataset:-400001.pat_name_kana</NAME_KANA>
                <!-- 生年月日 -->
                <BIRTHDAY>dataset:-400001.pat_birthday</BIRTHDAY>
                <!-- 性別 -->
                <SEX_CD>dataset:-400001.pat_sex</SEX_CD>
                <!-- 血液型ABO -->
                <BLOOD_TYPE_ABO>dataset:-400001.pat_blood_type_abo</BLOOD_TYPE_ABO>
                <!-- 血液型RH -->
                <BLOOD_TYPE_RH>dataset:-400001.pat_blood_type_rh</BLOOD_TYPE_RH>
                <!-- 入外区分 -->
                <INOUT_FLG>dataset:-400001.in_out_class</INOUT_FLG>
            </PAT_BASIC_INFO>
            <!-- レポート一覧 -->
            <RST_DIALYSIS_HST>
                <!-- 透析番号 -->
                <DIALYSIS_NO>dataset:-400006.dialysis_no</DIALYSIS_NO>
                <!-- 開始日＆開始時刻 -->
                <START_DATE>dataset:-400006.start_date14a</START_DATE>
                <!-- 版番 -->
                <EDITION>dataset:-400006.edition</EDITION>
                <!-- ベッドマスタ -->
                <MST_BED>
                    <!-- ベッド名 -->
                    <BED_NAME>dataset:-400006.bed_name</BED_NAME>
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
</coop_info>', '{"dataset": [{"patId": "patId", "sqlCode": -400001}, {"ordNo": "ordNo", "sqlCode": -400006}]}'::jsonb, '1', '0', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'F_SX');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-12082002, 'F_SX', 'rep_dial', 'xml', 'S', 'upd', 'xml', 'SX連携_透析レポート(xml)', 'F_SX', 'テスト用report', '1', '<rootNode>
  <PATIENT UPDATE_DATETIME="dataset:-400001.up_date">
    <DISP_PATID>dataset:-400001.hosp_pat_id</DISP_PATID>
    <PATID>$JOURNAL.pat_id</PATID>
    <NAME>dataset:-400001.pat_name</NAME>
    <KANA>dataset:-400001.pat_name_kana</KANA>
    <BIRTHDAY>dataset:-400001.pat_birthday</BIRTHDAY>
    <AGE>dataset:-400001.pat_age</AGE>
    <SEX>dataset:-400001.pat_sex</SEX>
    <INOUT>dataset:-400001.in_out_class</INOUT>
  </PATIENT>
  <REPORTS _detail="report" _sqlCode="-400000">
  </REPORTS>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -400001}, {"sqlCode": -400000}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'F_SX');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-12082003, 'F_SX', 'rep_dial', 'listxml', 'S', 'upd', 'xml', 'SX連携_透析レポート(listxml)', 'F_SX', 'テスト用report', '1', '<rootNode DISP_PATID_LENGTH="dataset:-400010.hosp_pat_id_len">
<PATIENT DISP_PATID="dataset:-400001.hosp_pat_id" PATID="$JOURNAL.pat_id"  NAME="dataset:-400001.pat_name" KANA="dataset:-400001.pat_name_kana"  SEX="dataset:-400001.pat_sex" BLOODABO="dataset:-400016.pat_blood_type_abo" BLOODRH="dataset:-400016.pat_blood_type_rh" AGE="dataset:-400001.pat_age" UPDATE_DATETIME="dataset:-400001.up_date"></PATIENT>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -400001}, {"sqlCode": -400010, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}, {"patId": "patId", "sqlCode": -400016}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'F_SX');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-12082004, 'F_SX', 'rep_dial', 'pdf', 'S', 'upd', 'pdf', 'SX連携_透析レポート(pdf)', 'F_SX', 'テスト用report', '1', '<rootnode></rootnode>', NULL, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'F_SX');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-12083001, 'F_SX', 'rep_dial', '', 'S', 'del', 'xml', 'SX連携_透析レポート', 'F_SX', 'テスト用report', '1', '<coop_info>
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
    <hosp_pat_id>dataset:-400001.hosp_pat_id</hosp_pat_id>
    <!-- 電文内容 -->
    <dump>
        <rootNode>
            <!-- 患者情報 -->
            <PAT_BASIC_INFO>
                <!-- 表示用患者ID -->
                <DISP_PATID>$JOURNAL.pat_id</DISP_PATID>
                <!-- 患者ID -->
                <PATID>dataset:-400001.hosp_pat_id</PATID>
                <!-- 名前 -->
                <NAME>dataset:-400001.pat_name</NAME>
                <!-- フリガナ -->
                <NAME_KANA>dataset:-400001.pat_name_kana</NAME_KANA>
                <!-- 生年月日 -->
                <BIRTHDAY>dataset:-400001.pat_birthday</BIRTHDAY>
                <!-- 性別 -->
                <SEX_CD>dataset:-400001.pat_sex</SEX_CD>
                <!-- 血液型ABO -->
                <BLOOD_TYPE_ABO>dataset:-400001.pat_blood_type_abo</BLOOD_TYPE_ABO>
                <!-- 血液型RH -->
                <BLOOD_TYPE_RH>dataset:-400001.pat_blood_type_rh</BLOOD_TYPE_RH>
                <!-- 入外区分 -->
                <INOUT_FLG>dataset:-400001.in_out_class</INOUT_FLG>
            </PAT_BASIC_INFO>
            <!-- レポート一覧 -->
            <RST_DIALYSIS_HST>
                <!-- 透析番号 -->
                <DIALYSIS_NO>dataset:-400006.dialysis_no</DIALYSIS_NO>
                <!-- 開始日＆開始時刻 -->
                <START_DATE>dataset:-400006.start_date14a</START_DATE>
                <!-- 版番 -->
                <EDITION>dataset:-400006.edition</EDITION>
                <!-- ベッドマスタ -->
                <MST_BED>
                    <!-- ベッド名 -->
                    <BED_NAME>dataset:-400006.bed_name</BED_NAME>
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
</coop_info>', '{"dataset": [{"patId": "patId", "sqlCode": -400001}, {"ordNo": "ordNo", "sqlCode": -400006}]}'::jsonb, '1', '0', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'F_SX');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-12083002, 'F_SX', 'rep_dial', 'listxml', 'S', 'del', 'xml', 'SX連携_透析レポート(listxml)', 'F_SX', 'テスト用report', '1', '<rootNode DISP_PATID_LENGTH="dataset:-400010.hosp_pat_id_len">
<PATIENT DISP_PATID="dataset:-400001.hosp_pat_id" PATID="$JOURNAL.pat_id"  NAME="dataset:-400001.pat_name" KANA="dataset:-400001.pat_name_kana"  SEX="dataset:-400001.pat_sex" BLOODABO="dataset:-400016.pat_blood_type_abo" BLOODRH="dataset:-400016.pat_blood_type_rh" AGE="dataset:-400001.pat_age" UPDATE_DATETIME="dataset:-400001.up_date"></PATIENT>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -400001}, {"sqlCode": -400010, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}, {"patId": "patId", "sqlCode": -400016}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'F_SX');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-12083003, 'F_SX', 'rep_dial', 'xml', 'S', 'del', 'xml', 'SX連携_透析レポート(xml)', 'F_SX', 'テスト用report', '1', '<rootNode>
  <PATIENT UPDATE_DATETIME="dataset:-400001.up_date">
    <DISP_PATID>dataset:-400001.hosp_pat_id</DISP_PATID>
    <PATID>$JOURNAL.pat_id</PATID>
    <NAME>dataset:-400001.pat_name</NAME>
    <KANA>dataset:-400001.pat_name_kana</KANA>
    <BIRTHDAY>dataset:-400001.pat_birthday</BIRTHDAY>
    <AGE>dataset:-400001.pat_age</AGE>
    <SEX>dataset:-400001.pat_sex</SEX>
    <INOUT>dataset:-400001.in_out_class</INOUT>
  </PATIENT>
  <REPORTS>
    <REPORT_DEL DIALYSIS_NO="dataset:-400019.dialysis_no" />
  </REPORTS>
</rootNode>
', '{"dataset": [{"patId": "patId", "sqlCode": -400001}, {"ordNo": "ordNo", "sqlCode": -400019}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'F_SX');
