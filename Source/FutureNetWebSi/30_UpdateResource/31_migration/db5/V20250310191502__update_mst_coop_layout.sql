DELETE FROM ntss.mst_coop_layout
WHERE ctl_no IN (-5010001, -5010002, -5010003, -5010004, -5010005, -5010006, -5010007, -5010008, -5010009, -5010010, -5010011, -5020001, -5020002, -5020003, -5020004, -5020005, -5020006, -5020007, -5020008, -5020009, -5030001, -5040001, -5040002, -5040003, -5070001, -5070002, -5070003, -5170001, -5170002, -5170003);

INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5010001, 'S_hosp', 'rep_dial', '', 'S', 'cre', 'xml', 'SSI 透析レポート', 'SSI', 'テスト用report', '1', '<coop_info>
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
    <hosp_pat_id>dataset:-500001.hosp_pat_id</hosp_pat_id>
    <!-- 電文内容 -->
    <dump>
        <rootNode>
            <!-- 患者情報 -->
            <PAT_BASIC_INFO>
                <!-- 表示用患者ID -->
                <DISP_PATID>$JOURNAL.pat_id</DISP_PATID>
                <!-- 患者ID -->
                <PATID>dataset:-500001.hosp_pat_id</PATID>
                <!-- 名前 -->
                <NAME>dataset:-500001.pat_name</NAME>
                <!-- フリガナ -->
                <NAME_KANA>dataset:-500001.pat_name_kana</NAME_KANA>
                <!-- 生年月日 -->
                <BIRTHDAY>dataset:-500001.pat_birthday</BIRTHDAY>
                <!-- 性別 -->
                <SEX_CD>dataset:-500001.pat_sex</SEX_CD>
                <!-- 血液型ABO -->
                <BLOOD_TYPE_ABO>dataset:-500001.pat_blood_type_abo</BLOOD_TYPE_ABO>
                <!-- 血液型RH -->
                <BLOOD_TYPE_RH>dataset:-500001.pat_blood_type_rh</BLOOD_TYPE_RH>
                <!-- 入外区分 -->
                <INOUT_FLG>dataset:-500001.in_out_class</INOUT_FLG>
            </PAT_BASIC_INFO>
            <!-- レポート一覧 -->
            <RST_DIALYSIS_HST>
                <!-- 透析番号 -->
                <DIALYSIS_NO>dataset:-500006.dialysis_no</DIALYSIS_NO>
                <!-- 開始日＆開始時刻 -->
                <START_DATE>dataset:-500006.start_date14a</START_DATE>
                <!-- 版番 -->
                <EDITION>dataset:-500006.edition</EDITION>
                <!-- ベッドマスタ -->
                <MST_BED>
                    <!-- ベッド名 -->
                    <BED_NAME>dataset:-500006.bed_name</BED_NAME>
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
</coop_info>', '{"dataset": [{"patId": "patId", "sqlCode": -500001}, {"ordNo": "ordNo", "sqlCode": -500006}]}'::jsonb, '1', '0', 4, '2020-05-25 18:26:36.811', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5010002, 'S_hosp', 'rep_dial', '', 'S', 'upd', 'xml', 'SSI 透析レポート', 'SSI', 'テスト用report', '1', '<coop_info>
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
    <hosp_pat_id>dataset:-500001.hosp_pat_id</hosp_pat_id>
    <!-- 電文内容 -->
    <dump>
        <rootNode>
            <!-- 患者情報 -->
            <PAT_BASIC_INFO>
                <!-- 表示用患者ID -->
                <DISP_PATID>$JOURNAL.pat_id</DISP_PATID>
                <!-- 患者ID -->
                <PATID>dataset:-500001.hosp_pat_id</PATID>
                <!-- 名前 -->
                <NAME>dataset:-500001.pat_name</NAME>
                <!-- フリガナ -->
                <NAME_KANA>dataset:-500001.pat_name_kana</NAME_KANA>
                <!-- 生年月日 -->
                <BIRTHDAY>dataset:-500001.pat_birthday</BIRTHDAY>
                <!-- 性別 -->
                <SEX_CD>dataset:-500001.pat_sex</SEX_CD>
                <!-- 血液型ABO -->
                <BLOOD_TYPE_ABO>dataset:-500001.pat_blood_type_abo</BLOOD_TYPE_ABO>
                <!-- 血液型RH -->
                <BLOOD_TYPE_RH>dataset:-500001.pat_blood_type_rh</BLOOD_TYPE_RH>
                <!-- 入外区分 -->
                <INOUT_FLG>dataset:-500001.in_out_class</INOUT_FLG>
            </PAT_BASIC_INFO>
            <!-- レポート一覧 -->
            <RST_DIALYSIS_HST>
                <!-- 透析番号 -->
                <DIALYSIS_NO>dataset:-500006.dialysis_no</DIALYSIS_NO>
                <!-- 開始日＆開始時刻 -->
                <START_DATE>dataset:-500006.start_date14a</START_DATE>
                <!-- 版番 -->
                <EDITION>dataset:-500006.edition</EDITION>
                <!-- ベッドマスタ -->
                <MST_BED>
                    <!-- ベッド名 -->
                    <BED_NAME>dataset:-500006.bed_name</BED_NAME>
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
</coop_info>', '{"dataset": [{"patId": "patId", "sqlCode": -500001}, {"ordNo": "ordNo", "sqlCode": -500006}]}'::jsonb, '1', '0', 4, '2025-01-02 18:26:36.811', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5010003, 'S_hosp', 'rep_dial', '', 'S', 'del', 'xml', 'SSI 透析レポート', 'SSI', 'テスト用report', '1', '<coop_info>
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
    <hosp_pat_id>dataset:-500001.hosp_pat_id</hosp_pat_id>
    <!-- 電文内容 -->
    <dump>
        <rootNode>
            <!-- 患者情報 -->
            <PAT_BASIC_INFO>
                <!-- 表示用患者ID -->
                <DISP_PATID>$JOURNAL.pat_id</DISP_PATID>
                <!-- 患者ID -->
                <PATID>dataset:-500001.hosp_pat_id</PATID>
                <!-- 名前 -->
                <NAME>dataset:-500001.pat_name</NAME>
                <!-- フリガナ -->
                <NAME_KANA>dataset:-500001.pat_name_kana</NAME_KANA>
                <!-- 生年月日 -->
                <BIRTHDAY>dataset:-500001.pat_birthday</BIRTHDAY>
                <!-- 性別 -->
                <SEX_CD>dataset:-500001.pat_sex</SEX_CD>
                <!-- 血液型ABO -->
                <BLOOD_TYPE_ABO>dataset:-500001.pat_blood_type_abo</BLOOD_TYPE_ABO>
                <!-- 血液型RH -->
                <BLOOD_TYPE_RH>dataset:-500001.pat_blood_type_rh</BLOOD_TYPE_RH>
                <!-- 入外区分 -->
                <INOUT_FLG>dataset:-500001.in_out_class</INOUT_FLG>
            </PAT_BASIC_INFO>
            <!-- レポート一覧 -->
            <RST_DIALYSIS_HST>
                <!-- 透析番号 -->
                <DIALYSIS_NO>dataset:-500006.dialysis_no</DIALYSIS_NO>
                <!-- 開始日＆開始時刻 -->
                <START_DATE>dataset:-500006.start_date14a</START_DATE>
                <!-- 版番 -->
                <EDITION>dataset:-500006.edition</EDITION>
                <!-- ベッドマスタ -->
                <MST_BED>
                    <!-- ベッド名 -->
                    <BED_NAME>dataset:-500006.bed_name</BED_NAME>
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
</coop_info>', '{"dataset": [{"patId": "patId", "sqlCode": -500001}, {"ordNo": "ordNo", "sqlCode": -500006}]}'::jsonb, '1', '0', 4, '2025-01-02 18:26:36.811', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5010004, 'S_hosp', 'rep_dial', 'xml', 'S', 'cre', 'xml', 'SSI 透析レポート(xml)', 'SSI', 'テスト用report', '1', '<rootNode>
  <PATIENT UPDATE_DATETIME="dataset:-500001.up_date">
    <DISP_PATID>dataset:-500001.hosp_pat_id</DISP_PATID>
    <PATID>$JOURNAL.pat_id</PATID>
    <NAME>dataset:-500001.pat_name</NAME>
    <KANA>dataset:-500001.pat_name_kana</KANA>
    <BIRTHDAY>dataset:-500001.pat_birthday</BIRTHDAY>
    <AGE>dataset:-500001.pat_age</AGE>
    <SEX>dataset:-500001.pat_sex</SEX>
    <INOUT>dataset:-500001.in_out_class</INOUT>
  </PATIENT>
  <REPORTS _detail="report" _sqlCode="-500000">
  </REPORTS>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -500001}, {"sqlCode": -500000}]}'::jsonb, '1', '0', -1, '2021-09-01 07:38:44.069', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5010005, 'S_hosp', 'rep_dial', 'xml', 'S', 'upd', 'xml', 'SSI 透析レポート(xml)', 'SSI', 'テスト用report', '1', '<rootNode>
  <PATIENT UPDATE_DATETIME="dataset:-500001.up_date">
    <DISP_PATID>dataset:-500001.hosp_pat_id</DISP_PATID>
    <PATID>$JOURNAL.pat_id</PATID>
    <NAME>dataset:-500001.pat_name</NAME>
    <KANA>dataset:-500001.pat_name_kana</KANA>
    <BIRTHDAY>dataset:-500001.pat_birthday</BIRTHDAY>
    <AGE>dataset:-500001.pat_age</AGE>
    <SEX>dataset:-500001.pat_sex</SEX>
    <INOUT>dataset:-500001.in_out_class</INOUT>
  </PATIENT>
  <REPORTS _detail="report" _sqlCode="-500000">
  </REPORTS>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -500001}, {"sqlCode": -500000}]}'::jsonb, '1', '0', -1, '2021-09-01 07:38:44.069', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5010006, 'S_hosp', 'rep_dial', 'listxml', 'S', 'upd', 'xml', 'SSI 透析レポート(listxml)', 'SSI', 'テスト用report', '1', '<rootNode DISP_PATID_LENGTH="dataset:-500010.hosp_pat_id_len">
<PATIENT DISP_PATID="dataset:-500001.hosp_pat_id" PATID="$JOURNAL.pat_id"  NAME="dataset:-500001.pat_name" KANA="dataset:-500001.pat_name_kana"  SEX="dataset:-500001.pat_sex" BLOODABO="dataset:-500001.pat_blood_type_abo" BLOODRH="dataset:-500001.pat_blood_type_rh" AGE="dataset:-500001.pat_age" UPDATE_DATETIME="dataset:-500001.up_date"></PATIENT>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -500001}, {"sqlCode": -500010, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}]}'::jsonb, '1', '0', -1, '2021-09-01 07:38:44.069', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5010007, 'S_hosp', 'rep_dial', 'listxml', 'S', 'cre', 'xml', 'SSI 透析レポート(listxml)', 'SSI', 'テスト用report', '1', '<rootNode DISP_PATID_LENGTH="dataset:-500010.hosp_pat_id_len">
<PATIENT DISP_PATID="dataset:-500001.hosp_pat_id" PATID="$JOURNAL.pat_id"  NAME="dataset:-500001.pat_name" KANA="dataset:-500001.pat_name_kana"  SEX="dataset:-500001.pat_sex" BLOODABO="dataset:-500001.pat_blood_type_abo" BLOODRH="dataset:-500001.pat_blood_type_rh" AGE="dataset:-500001.pat_age" UPDATE_DATETIME="dataset:-500001.up_date"></PATIENT>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -500001}, {"sqlCode": -500010, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}]}'::jsonb, '1', '0', -1, '2021-09-01 07:38:44.069', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5010008, 'S_hosp', 'rep_dial', 'pdf', 'S', 'upd', 'pdf', 'SSI 透析レポート(pdf)', 'SSI', 'テスト用report', '1', '<rootnode></rootnode>', NULL, '1', '0', -1, '2021-09-01 07:38:44.069', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5010009, 'S_hosp', 'rep_dial', 'pdf', 'S', 'cre', 'pdf', 'SSI 透析レポート(pdf)', 'SSI', 'テスト用report', '1', '<rootnode></rootnode>', NULL, '1', '0', -1, '2021-09-01 07:38:44.069', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5010010, 'S_hosp', 'rep_dial', 'tar', 'S', 'upd', 'xml', 'SSI 透析レポート(tar)', 'SSI', 'テスト用report', '1', '<rootNode>
  <PATIENT UPDATE_DATETIME="dataset:-500001.up_date">
    <DISP_PATID>dataset:-500001.hosp_pat_id</DISP_PATID>
    <PATID>$JOURNAL.pat_id</PATID>
    <NAME>dataset:-500001.pat_name</NAME>
    <KANA>dataset:-500001.pat_name_kana</KANA>
    <BIRTHDAY>dataset:-500001.pat_birthday</BIRTHDAY>
    <AGE>dataset:-500001.pat_age</AGE>
    <SEX>dataset:-500001.pat_sex</SEX>
    <INOUT>dataset:-500001.in_out_class</INOUT>
  </PATIENT>
  <REPORTS _detail="report" _sqlCode="-500000">
  </REPORTS>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -500001}, {"sqlCode": -500000}]}'::jsonb, '1', '0', -1, '2021-09-01 07:38:44.069', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5010011, 'S_hosp', 'rep_dial', 'tar', 'S', 'cre', 'xml', 'SSI 透析レポート(tar)', 'SSI', 'テスト用report', '1', '<rootNode>
  <PATIENT UPDATE_DATETIME="dataset:-500001.up_date">
    <DISP_PATID>dataset:-500001.hosp_pat_id</DISP_PATID>
    <PATID>$JOURNAL.pat_id</PATID>
    <NAME>dataset:-500001.pat_name</NAME>
    <KANA>dataset:-500001.pat_name_kana</KANA>
    <BIRTHDAY>dataset:-500001.pat_birthday</BIRTHDAY>
    <AGE>dataset:-500001.pat_age</AGE>
    <SEX>dataset:-500001.pat_sex</SEX>
    <INOUT>dataset:-500001.in_out_class</INOUT>
  </PATIENT>
  <REPORTS _detail="report" _sqlCode="-500000">
  </REPORTS>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -500001}, {"sqlCode": -500000}]}'::jsonb, '1', '0', -1, '2021-09-01 07:38:44.069', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5020001, 'S_hosp', 'ord_dial', '', 'R', 'pre', 'text', 'SSI_透析オーダ受け連携', 'SSI', '透析オーダ受け連携(標準)', '1', '<root name="透析オーダ受け連携(標準 pre)">
    <item name="期間開始日" len="8" type="string"/>
    <item name="期間終了日" len="8" type="string"/>
    <item name="透析日" len="8" type="string"/>
    <item name="開始時刻" len="4" key="shori_kbn" type="string"/>
    <item name="患者ID" len="12" type="string"/>
    <item name="患者名" len="20" type="string"/>
    <item name="透析時間" len="3" type="string"/>
    <item name="治療方法" len="20" type="string"/>
    <item name="ベッド-コード" len="10" type="string"/>
    <item name="ベッド-名称" len="20" type="string"/>
    <item name="ダイアライザ-コード" len="10" type="string"/>
    <item name="ダイアライザ-名称" len="20" type="string"/>
    <item name="A針-コード" len="10" type="string"/>
    <item name="A針-名称" len="40" type="string"/>
    <item name="V針-コード" len="10" type="string"/>
    <item name="V針-名称" len="40" type="string"/>
    <item name="透析液-コード" len="10" type="string"/>
    <item name="透析液-名称" len="80" type="string"/>
    <item name="透析液-数量" len="7" type="string"/>
    <item name="透析液-単位" len="20" type="string"/>
    <item name="抗凝固剤-コード" len="10" type="string"/>
    <item name="抗凝固剤-名称" len="80" type="string"/>
    <item name="抗凝固剤-ワンショット量" len="7" type="string"/>
    <item name="抗凝固剤-持続注入量" len="7" type="string"/>
    <item name="抗凝固剤-持続総量" len="7" type="string"/>
    <item name="抗凝固剤-単位" len="20" type="string"/>
    <item name="DW" len="5" type="string"/>
    <item name="DW更新日" len="8" type="string"/>
    <item name="CTR" len="4" type="string"/>
    <item name="CTR更新日" len="8" type="string"/>
    <item name="血流量" len="3" type="string"/>
    <item name="IP速度" len="3" type="string"/>
    <item name="補液量" len="3" type="string"/>
    <item name="除水量制限" len="4" type="string"/>
    <item name="除水速度制限" len="4" type="string"/>
    <item name="ブラッドアクセスコード" len="10" type="string"/>
    <item name="ブラッドアクセス名称" len="40" type="string"/>
    <item name="ブラッドアクセス部位" len="1" type="string"/>
    <item name="ブラッドアクセス更新日" len="8" type="string"/>
    <occ name="消耗品情報" len="0" repeat="10" detail="消耗品情報"/>
    <occ name="処方情報" len="0" repeat="20" detail="処方情報"/>
    <occ name="除水補正情報" len="0" repeat="5" detail="除水補正情報"/>
    <occ name="風袋情報" len="0" repeat="5" detail="風袋情報"/>
    <item name="ダイアライザ２-コード２" len="10" type="string"/>
    <item name="ダイアライザ２-名称２" len="20" type="string"/>
    <item name="吸着器コード" len="10" type="string"/>
    <item name="吸着器名称" len="20" type="string"/>
    <item name="透析液-温度" len="3" type="string"/>
    <item name="補液-コード" len="10" type="string"/>
    <item name="補液-名称" len="40" type="string"/>
    <item name="補液-使用数" len="3" type="string"/>
    <item name="補液-速度" len="4" type="string"/>
    <item name="担当医-コード" len="10" type="string"/>
    <item name="担当医名" len="20" type="string"/>
    <item name="CRLF" len="2" type="string"/>
</root>', '{"key": {"shori_kbn": {"9999": "削除", "_DEFAULT": "登録"}}, "dataset": {"sqlGroup1": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}], "sqlGroup2": [{"crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500041, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の確定転入出状態が対象外のデータがあります。", "ExceptionCondition": "<>0"}], "sqlGroup3": [{"crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500064, "@indBedCd": "$journal.ord_main.ind_bed_cd", "@indBedName": "$journal.ord_main.ind_bed_name", "ExceptionMessage": "ベッド[@indBedCd]は取込対象外です。", "ExceptionCondition": "<>0"}], "sqlGroup4": [{"crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500012, "@indBedCd": "$journal.ord_main.ind_bed_cd", "@indBedName": "$journal.ord_main.ind_bed_name", "ExceptionMessage": "ベッド[@indBedCd]は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}], "sqlGroup5": [{"crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_treatment", "ctl_no": "1", "sqlCode": -500011, "@treatDate": "$journal.const.date_yyyymmdd", "ExceptionMessage": "治療方法[@indTreatmentName]は存在しません。", "@indTreatmentName": "$journal.ord_main.ind_treatment_name", "ExceptionCondition": "=0"}], "sqlGroup6": [{"crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500058, "@treatDate": "$journal.const.date_yyyymmdd", "@dialysisTime": "$journal.ord_main.ind_cond_info.001.value", "ExceptionMessage": "透析時間[@dialysisTime]が治療時間上限値を超えています。", "@indTreatmentName": "$journal.ord_main.ind_treatment_name", "ExceptionCondition": "=1"}], "sqlGroup7": [{"crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500059, "@treatDate": "$journal.const.date_yyyymmdd", "@dialysisTime": "$journal.ord_main.ind_cond_info.001.value", "ExceptionMessage": "特殊浄化[@dialysisTime]が治療時間上限値を超えています。", "@indTreatmentName": "$journal.ord_main.ind_treatment_name", "ExceptionCondition": "=1"}], "sqlGroup8": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500013, "insertResult": "{@ordNo:''''}", "@indTreatmentName": "$journal.ord_main.ind_treatment_name", "@indCondInfo.005.name": "$journal.ord_main.ind_cond_info.005.value_name_1", "@indCondInfo.005.value": "$journal.ord_main.ind_cond_info.005.value"}, {"No1": "ダイアライザ or 1次膜登録", "crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": -500054, "@indEquipInfo.cd": "$journal.ord_main.ind_cond_info.005.value", "@indTreatmentName": "$journal.ord_main.ind_treatment_name", "@indEquipInfo.name": "$journal.ord_main.ind_cond_info.005.value_name_1", "@indCondInfo.005.name": "$journal.ord_main.ind_cond_info.005.value_name_1", "@indCondInfo.005.value": "$journal.ord_main.ind_cond_info.005.value"}], "sqlGroup9": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500039, "@indVaCd": "$journal.ord_main.blood_access_info.cd", "insertResult": "{@ordNo:''''}"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": -500053, "@indVaCd": "$journal.ord_main.blood_access_info.cd", "@indVaName": "$journal.ord_main.blood_access_info.name", "@indVaPart": "$journal.ord_main.blood_access_info.part"}], "sqlGroup10": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500015, "insertResult": "{@ordNo:''''}", "@indCondInfo.010.name": "$journal.ord_main.ind_cond_info.010.value_name_1", "@indCondInfo.010.value": "$journal.ord_main.ind_cond_info.010.value"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": -500044, "@indCondInfo.010.name": "$journal.ord_main.ind_cond_info.010.value_name_1", "@indCondInfo.010.value": "$journal.ord_main.ind_cond_info.010.value"}], "sqlGroup11": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500037, "insertResult": "{@ordNo:''''}", "@indCondInfo.011.name": "$journal.ord_main.ind_cond_info.011.value_name_1", "@indCondInfo.011.value": "$journal.ord_main.ind_cond_info.011.value"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": -500052, "@indCondInfo.011.name": "$journal.ord_main.ind_cond_info.011.value_name_1", "@indCondInfo.011.value": "$journal.ord_main.ind_cond_info.011.value"}], "sqlGroup12": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500017, "insertResult": "{@ordNo:''''}", "@indCondInfo.015.name": "$journal.ord_main.ind_cond_info.015.value_name_1", "@indCondInfo.015.value": "$journal.ord_main.ind_cond_info.015.value"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": -500045, "@indCondInfo.015.name": "$journal.ord_main.ind_cond_info.015.value_name_1", "@indCondInfo.015.unit": "$journal.ord_main.ind_cond_info.015.unit", "@indCondInfo.015.value": "$journal.ord_main.ind_cond_info.015.value"}], "sqlGroup13": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main_1", "ctl_no": "1", "sqlCode": -500019, "insertResult": "{@ordNo:''''}", "@indEquipInfo.cd": "$journal.detail.ord_main_1.ind_equip_info.cd"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main_1", "ctl_no": "2", "sqlCode": -500046, "@indEquipInfo.cd": "$journal.detail.ord_main_1.ind_equip_info.cd", "@indEquipInfo.name": "$journal.detail.ord_main_1.ind_equip_info.name", "@indEquipInfo.amount": "$journal.detail.ord_main_1.ind_equip_info.amount"}], "sqlGroup14": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500025, "insertResult": "{@ordNo:''''}", "@indEquipInfo.cd": "$journal.ord_main.ind_equip_info.cd", "@indEquipInfo.name": "$journal.ord_main.ind_equip_info.name"}, {"No1": "2次膜登録", "crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": -500062, "@indEquipInfo.cd": "$journal.ord_main.ind_equip_info.cd", "@indTreatmentName": "$journal.ord_main.ind_treatment_name", "@indEquipInfo.name": "$journal.ord_main.ind_equip_info.name"}], "sqlGroup15": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500027, "insertResult": "{@ordNo:''''}", "@indCondInfo.006.name": "$journal.ord_main.ind_cond_info.006.value_name_1", "@indCondInfo.006.value": "$journal.ord_main.ind_cond_info.006.value"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": -500049, "@indCondInfo.006.name": "$journal.ord_main.ind_cond_info.006.value_name_1", "@indCondInfo.006.value": "$journal.ord_main.ind_cond_info.006.value"}], "sqlGroup16": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500029, "insertResult": "{@ordNo:''''}", "@indCondInfo.019.name": "$journal.ord_main.ind_cond_info.019.value_name_1", "@indCondInfo.019.value": "$journal.ord_main.ind_cond_info.019.value"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": -500050, "@indCondInfo.019.name": "$journal.ord_main.ind_cond_info.019.value_name_1", "@indCondInfo.019.value": "$journal.ord_main.ind_cond_info.019.value"}], "sqlGroup17": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500035, "insertResult": "{@ordNo:''''}", "@indCondInfo.025.name": "$journal.ord_main.ind_cond_info.025.value_name_1", "@indCondInfo.025.value": "$journal.ord_main.ind_cond_info.025.value"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": -500051, "@indCondInfo.025.name": "$journal.ord_main.ind_cond_info.025.value_name_1", "@indCondInfo.025.unit": "$journal.ord_main.ind_cond_info.025.unit", "@indCondInfo.025.value": "$journal.ord_main.ind_cond_info.025.value"}], "sqlGroup18": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": 8101, "@treatDate": "$journal.const.date_yyyymmdd", "insertResult": "{@ordNo:'''', @patId:'''', @fnPatId:'''', @treatDate:'''', @treatWeek:'''', @facilityCd:'''', @facilityName:'''', @indVaCd:'''', @indTreatmentCd:'''', @indTreatmentName:'''', @indKurCd:'''', @indKurName:'''', @indTreatStartTime:'''', @indBedCd:'''', @indBedName:'''', @indScheduleUserInfoFlg:'''', @indScheduleUserInfo.indUserId:'''', @indScheduleUserInfo.indUserLastName:'''', @indScheduleUserInfo.indUserFirstName:'''', @indScheduleUserInfo.updUserId:'''', @indScheduleUserInfo.updUserLastName:'''', @indScheduleUserInfo.updUserFirstName:'''', @indCondInfo:''{}'', @indMediInfoValue:''[]'', @indEquipInfoValue:''[]'', @indIndCommentInfoValue:''[]'', @indTareInfoFlg:'''', @indTareInfo.name1:'''', @indTareInfo.name2:'''', @indTareInfo.name3:'''', @indTareInfo.name4:'''', @indTareInfo.name5:'''', @indTareInfo.weight1:'''', @indTareInfo.weight2:'''', @indTareInfo.weight3:'''', @indTareInfo.weight4:'''', @indTareInfo.weight5:'''', @indOffWaterInfoFlg:'''', @indOffWaterInfo.name1:'''', @indOffWaterInfo.name2:'''', @indOffWaterInfo.name3:'''', @indOffWaterInfo.name4:'''', @indOffWaterInfo.name5:'''', @indOffWaterInfo.weight1:'''', @indOffWaterInfo.weight2:'''', @indOffWaterInfo.weight3:'''', @indOffWaterInfo.weight4:'''', @indOffWaterInfo.weight5:'''', @indDeviceSetInfo:''{}'', @rstFnDialysisNo:'''', @rstRelationDialysisNo:'''', @rstEdition:''0'', @rstIsUpdateEdition:'''', @rstInputClass:'''', @rstDialysisState:''0'', @rstTreatmentCd:'''', @rstTreatmentName:'''', @rstKurCd:'''', @rstKurName:'''', @rstBedCd:'''', @rstBedName:'''', @rstMachineNo:'''', @rstMachineName:'''', @rstCondSendDate_Date:'''', @rstAcceptDate_Date:'''', @rstStartDate_Date:'''', @rstEndDate_Date:'''', @rstReturnHomeDate_Date:'''', @rstInOutClass:'''', @rstDialysisCnt:'''', @rstWardCd:'''', @rstWardName:'''', @rstCourseCd:'''', @rstCourseName:'''', @rstPunctureUserInfo:'''', @rstReturnUserInfo:'''', @rstChargeUserInfo:'''', @rstBloodCirculateTotal:'''', @rstRunningTime:'''', @rstKtV:'''', @recSetDate_Date:'''', @sendCtlNo:'''', @bloodPurifierName:'''', @pullLeaveAmount:'''', @rstCondInfo:'''', @rstMediInfo:'''', @rstEquipInfo:'''', @rstIndCommentInfo:'''', @rstTareInfo:'''', @rstOffWaterInfo:'''', @rstDeviceSetInfo:'''', @rstWeightInfo:'''', @rstVitalInfo:'''', @rstComplaintInfo:'''', @rstTreatmentInfo:'''', @rstTreatStaffInfo:'''', @rstRoundsInfo:'''', @isDel:''0'', @upDate_Date:'''', @regDate_Date:'''', @rstDw:'''', @weightScaleNo:'''', @treatType:''1'', @isConfirm:''0'', @indDw:'''', @rstPurificationCnt:'''', @additionInfo:'''', @upIndUserId:'''', @upUserId:'''', @rstEditionDate_Date:'''', @curEditionDate_Date:'''', @fnPlural:''''}", "updateResult": "{@ordNo:''ord_no'', @patId:''pat_id'', @fnPatId:''fn_pat_id'', @treatDate:''treat_date'', @treatWeek:''treat_week'', @facilityCd:''facility_cd'', @facilityName:''facility_name'', @indVaCd:''ind_va_cd'', @indTreatmentCd:''ind_treatment_cd'', @indTreatmentName:''ind_treatment_name'', @indKurCd:''ind_kur_cd'', @indKurName:''ind_kur_name'', @indTreatStartTime:''ind_treat_start_time'', @indBedCd:''ind_bed_cd'', @indBedName:''ind_bed_name'', @indScheduleUserInfoFlg:'''', @indScheduleUserInfoValue:''ind_schedule_user_info'', @indScheduleUserInfo.indUserId:'''', @indScheduleUserInfo.indUserLastName:'''', @indScheduleUserInfo.indUserFirstName:'''', @indScheduleUserInfo.updUserId:'''', @indScheduleUserInfo.updUserLastName:'''', @indScheduleUserInfo.updUserFirstName:'''', @indCondInfo:''ind_cond_info'', @indMediInfoValue:''ind_medi_info'', @indEquipInfoValue:''ind_equip_info'', @indIndCommentInfoValue:''ind_ind_comment_info'', @indTareInfoFlg:'''', @indTareInfoValue:''ind_tare_info'', @indTareInfo.name1:'''', @indTareInfo.name2:'''', @indTareInfo.name3:'''', @indTareInfo.name4:'''', @indTareInfo.name5:'''', @indTareInfo.weight1:'''', @indTareInfo.weight2:'''', @indTareInfo.weight3:'''', @indTareInfo.weight4:'''', @indTareInfo.weight5:'''', @indOffWaterInfoFlg:'''', @indOffWaterInfoValue:''ind_off_water_info'', @indOffWaterInfo.name1:'''', @indOffWaterInfo.name2:'''', @indOffWaterInfo.name3:'''', @indOffWaterInfo.name4:'''', @indOffWaterInfo.name5:'''', @indOffWaterInfo.weight1:'''', @indOffWaterInfo.weight2:'''', @indOffWaterInfo.weight3:'''', @indOffWaterInfo.weight4:'''', @indOffWaterInfo.weight5:'''', @indDeviceSetInfo:''ind_device_set_info'', @rstFnDialysisNo:''rst_fn_dialysis_no'', @rstRelationDialysisNo:''rst_relation_dialysis_no'', @rstEdition:''rst_edition'', @rstIsUpdateEdition:''rst_is_update_edition'', @rstInputClass:''rst_input_class'', @rstDialysisState:''rst_dialysis_state'', @rstTreatmentCd:''rst_treatment_cd'', @rstTreatmentName:''rst_treatment_name'', @rstKurCd:''rst_kur_cd'', @rstKurName:''rst_kur_name'', @rstBedCd:''rst_bed_cd'', @rstBedName:''rst_bed_name'', @rstMachineNo:''rst_machine_no'', @rstMachineName:''rst_machine_name'', @rstCondSendDate_Date:''rst_cond_send_date'', @rstAcceptDate_Date:''rst_accept_date'', @rstStartDate_Date:''rst_start_date'', @rstEndDate_Date:''rst_end_date'', @rstReturnHomeDate_Date:''rst_return_home_date'', @rstInOutClass:''rst_in_out_class'', @rstDialysisCnt:''rst_dialysis_cnt'', @rstWardCd:''rst_ward_cd'', @rstWardName:''rst_ward_name'', @rstCourseCd:''rst_course_cd'', @rstCourseName:''rst_course_name'', @rstPunctureUserInfo:''rst_puncture_user_info'', @rstReturnUserInfo:''rst_return_user_info'', @rstChargeUserInfo:''rst_charge_user_info'', @rstBloodCirculateTotal:''rst_blood_circulate_total'', @rstRunningTime:''rst_running_time'', @rstKtV:''rst_kt_v'', @recSetDate_Date:''rec_set_date'', @sendCtlNo:''send_ctl_no'', @bloodPurifierName:''blood_purifier_name'', @pullLeaveAmount:''pull_leave_amount'', @rstCondInfo:''rst_cond_info'', @rstMediInfo:''rst_medi_info'', @rstEquipInfo:''rst_equip_info'', @rstIndCommentInfo:''rst_ind_comment_info'', @rstTareInfo:''rst_tare_info'', @rstOffWaterInfo:''rst_off_water_info'', @rstDeviceSetInfo:''rst_device_set_info'', @rstWeightInfo:''rst_weight_info'', @rstVitalInfo:''rst_vital_info'', @rstComplaintInfo:''rst_complaint_info'', @rstTreatmentInfo:''rst_treatment_info'', @rstTreatStaffInfo:''rst_treat_staff_info'', @rstRoundsInfo:''rst_rounds_info'', @isDel:''is_del'', @upDate_Date:''up_date'', @regDate_Date:''reg_date'', @rstDw:''rst_dw'', @weightScaleNo:''weight_scale_no'', @treatType:''treat_type'', @isConfirm:''is_confirm'', @indDw:''ind_dw'', @rstPurificationCnt:''rst_purification_cnt'', @additionInfo:''addition_info'', @upIndUserId:''up_ind_user_id'', @upUserId:''up_user_id'', @rstEditionDate_Date:''rst_edition_date'', @curEditionDate_Date:''cur_edition_date'', @fnPlural:''fn_plural''}"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": 8102, "@indVaCd": "$journal.ord_main.blood_access_info.cd", "@indBedCd": "$journal.ord_main.ind_bed_cd", "@upUserId": "$journal.ord_main.ind_schedule_user_info.upd_user_id", "@treatDate": "$journal.const.date_yyyymmdd", "@indBedName": "$journal.ord_main.ind_bed_name", "@indEquipInfo.cd": "$journal.ord_main.ind_equip_info.cd", "@indTreatmentName": "$journal.ord_main.ind_treatment_name", "@indEquipInfo.name": "$journal.ord_main.ind_equip_info.name", "@indTreatStartTime": "$journal.ord_main.ind_treat_start_time", "@chargeStaffInfo.staffCd": "$journal.ord_main.ind_schedule_user_info.upd_user_id", "@indScheduleUserInfo.indUserId": "$journal.ord_main.ind_schedule_user_info.upd_user_id", "@indScheduleUserInfo.updUserId": "$journal.ord_main.ind_schedule_user_info.upd_user_id", "@indScheduleUserInfo.indUserLastName": "$journal.ord_main.ind_schedule_user_info.upd_user_name", "@indScheduleUserInfo.updUserLastName": "$journal.ord_main.ind_schedule_user_info.upd_user_name", "@indScheduleUserInfo.indUserFirstName": "$journal.ord_main.ind_schedule_user_info.upd_user_name", "@indScheduleUserInfo.updUserFirstName": "$journal.ord_main.ind_schedule_user_info.upd_user_name"}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "3", "sqlCode": 8103, "@indBedCd": "$journal.ord_main.ind_bed_cd", "@upUserId": "$journal.ord_main.ind_schedule_user_info.upd_user_id", "@treatDate": "$journal.const.date_yyyymmdd", "@indBedName": "$journal.ord_main.ind_bed_name", "@indEquipInfo.cd": "$journal.ord_main.ind_equip_info.cd", "@indTreatmentName": "$journal.ord_main.ind_treatment_name", "@indEquipInfo.name": "$journal.ord_main.ind_equip_info.name", "@indTreatStartTime": "$journal.ord_main.ind_treat_start_time", "@chargeStaffInfo.staffCd": "$journal.ord_main.ind_schedule_user_info.upd_user_id", "@indScheduleUserInfo.indUserId": "$journal.ord_main.ind_schedule_user_info.upd_user_id", "@indScheduleUserInfo.updUserId": "$journal.ord_main.ind_schedule_user_info.upd_user_id", "@indScheduleUserInfo.indUserLastName": "$journal.ord_main.ind_schedule_user_info.upd_user_name", "@indScheduleUserInfo.updUserLastName": "$journal.ord_main.ind_schedule_user_info.upd_user_name", "@indScheduleUserInfo.indUserFirstName": "$journal.ord_main.ind_schedule_user_info.upd_user_name", "@indScheduleUserInfo.updUserFirstName": "$journal.ord_main.ind_schedule_user_info.upd_user_name"}], "sqlGroup19": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": 8101, "@treatDate": "$journal.const.date_yyyymmdd", "updateResult": "{@ordNo:''ord_no''}"}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": 8104, "@indVaCd": "$journal.ord_main.blood_access_info.cd", "@treatDate": "$journal.const.date_yyyymmdd", "@indEquipInfo.cd": "$journal.ord_main.ind_equip_info.cd", "@indTreatmentName": "$journal.ord_main.ind_treatment_name", "@indCondInfo.format": "Standard", "@indCondInfo.005.name": "$journal.ord_main.ind_cond_info.005.value_name_1", "@indCondInfo.006.name": "$journal.ord_main.ind_cond_info.006.value_name_1", "@indCondInfo.010.name": "$journal.ord_main.ind_cond_info.010.value_name_1", "@indCondInfo.011.name": "$journal.ord_main.ind_cond_info.011.value_name_1", "@indCondInfo.015.name": "$journal.ord_main.ind_cond_info.015.value_name_1", "@indCondInfo.015.unit": "$journal.ord_main.ind_cond_info.015.unit", "@indCondInfo.019.name": "$journal.ord_main.ind_cond_info.019.value_name_1", "@indCondInfo.025.name": "$journal.ord_main.ind_cond_info.025.value_name_1", "@indCondInfo.025.unit": "$journal.ord_main.ind_cond_info.025.unit", "@indCondInfo.001.value": "$journal.ord_main.ind_cond_info.001.value", "@indCondInfo.004.value": "$journal.ord_main.ind_cond_info.004.value", "@indCondInfo.005.value": "$journal.ord_main.ind_cond_info.005.value", "@indCondInfo.006.value": "$journal.ord_main.ind_cond_info.006.value", "@indCondInfo.010.value": "$journal.ord_main.ind_cond_info.010.value", "@indCondInfo.011.value": "$journal.ord_main.ind_cond_info.011.value", "@indCondInfo.014.value": "$journal.ord_main.ind_cond_info.014.value", "@indCondInfo.015.value": "$journal.ord_main.ind_cond_info.015.value", "@indCondInfo.017.value": "$journal.ord_main.ind_cond_info.017.value", "@indCondInfo.018.value": "$journal.ord_main.ind_cond_info.018.value", "@indCondInfo.019.value": "$journal.ord_main.ind_cond_info.019.value", "@indCondInfo.020.value": "$journal.ord_main.ind_cond_info.020.value", "@indCondInfo.022.value": "$journal.ord_main.ind_cond_info.022.value", "@indCondInfo.024.value": "$journal.ord_main.ind_cond_info.024.value", "@indCondInfo.025.value": "$journal.ord_main.ind_cond_info.025.value", "@indCondInfo.026.value": "$journal.ord_main.ind_cond_info.026.value", "@indCondInfo.027.value": "$journal.ord_main.ind_cond_info.027.value", "@indCondInfo.028.value": "$journal.ord_main.ind_cond_info.028.value", "@indCondInfo.033.value": "$journal.ord_main.ind_cond_info.033.value", "@indCondInfo.039.value": "$journal.pat_unique.physical_info.dw"}], "sqlGroup20": [{"crud": "S", "kind": "0", "judge": "$journal.const.crud#=#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -503001, "@treatDate": "$journal.const.date_yyyymmdd", "ExceptionMessage": "オーダー番号[@ordNo]治療条件送信後にスケジュール変更はできません。", "ExceptionCondition": "=1"}], "sqlGroup21": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#=#D", "table": "ord_main", "ctl_no": "1", "sqlCode": 8101, "@treatDate": "$journal.const.date_yyyymmdd", "updateResult": "{@ordNo:''ord_no''}"}, {"crud": "U", "kind": "1", "note": "倫理削除処理", "judge": "$journal.const.crud#=#D", "table": "ord_main", "ctl_no": "2", "sqlCode": 8105, "@upUserId": "$journal.ord_main.ind_schedule_user_info.upd_user_id", "@chargeStaffInfo.staffCd": "$journal.ord_main.ind_schedule_user_info.upd_user_id"}], "sqlGroup22": [{"crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.crud#<>#D", "table": "ord_main_1", "ctl_no": "1", "sqlCode": -500042, "@treatDate": "$journal.const.date_yyyymmdd", "updateResult": "{@indEquipInfoValue:''ind_equip_info''}"}, {"Note": "json場合、[D]の設定が必要です。しかし、消耗品情報をクリアしません。judgeに[crud#=#NG]を設定する。", "crud": "D", "kind": "1", "judge": "$journal.const.crud#=#NG", "table": "ord_main_1", "ctl_no": "2", "sqlCode": 8106}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main_1", "ctl_no": "3", "sqlCode": 8107, "@indEquipInfo.cd": "$journal.detail.ord_main_1.ind_equip_info.cd", "@indEquipInfo.name": "$journal.detail.ord_main_1.ind_equip_info.name", "@indEquipInfo.amount": "$journal.detail.ord_main_1.ind_equip_info.amount", "@indEquipInfo.isEditable": "1"}], "sqlGroup23": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main_2", "ctl_no": "1", "sqlCode": -500068, "insertResult": "{@ordNo:''''}", "@indMediInfo.cd": "$journal.detail.ord_main_2.ind_medi_info.cd", "@indMediInfo.name": "$journal.detail.ord_main_2.ind_medi_info.name"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main_2", "ctl_no": "2", "sqlCode": -500073, "@indMediInfo.cd": "$journal.detail.ord_main_2.ind_medi_info.cd", "@indMediInfo.name": "$journal.detail.ord_main_2.ind_medi_info.name", "@indMediInfo.unit": "$journal.detail.ord_main_2.ind_medi_info.unit"}], "sqlGroup24": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main_2", "ctl_no": "1", "sqlCode": -500023, "insertResult": "{@ordNo:''''}", "@indMediInfo.procedureCd": "$journal.detail.ord_main_2.ind_medi_info.procedure_cd", "@indMediInfo.procedureName": "$journal.detail.ord_main_2.ind_medi_info.procedure_name"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main_2", "ctl_no": "2", "sqlCode": -500048, "@indMediInfo.procedureCd": "$journal.detail.ord_main_2.ind_medi_info.procedure_cd", "@indMediInfo.procedureName": "$journal.detail.ord_main_2.ind_medi_info.procedure_name"}], "sqlGroup25": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500065, "insertResult": "{@mediInfoNo:''''}"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": -500066}], "sqlGroup26": [{"crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500043, "@treatDate": "$journal.const.date_yyyymmdd", "updateResult": "{@indMediInfoValue:''ind_medi_info'', @rstMediInfoValue:''rst_medi_info''}"}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": 8108}], "sqlGroup27": [{"crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.crud#<>#D", "table": "ord_main_2", "ctl_no": "1", "sqlCode": -500043, "@treatDate": "$journal.const.date_yyyymmdd", "updateResult": "{@indMediInfoValue:''ind_medi_info'', @rstMediInfoValue:''rst_medi_info''}"}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main_2", "ctl_no": "2", "sqlCode": 8109, "@indMediInfo.cd": "$journal.detail.ord_main_2.ind_medi_info.cd", "@indMediInfo.name": "$journal.detail.ord_main_2.ind_medi_info.name", "@indMediInfo.unit": "$journal.detail.ord_main_2.ind_medi_info.unit", "@indMediInfo.amount": "$journal.detail.ord_main_2.ind_medi_info.amount", "@indMediInfo.initDate": "$journal.const.date_yyyymmdd", "@indMediInfo.inputClass": 2, "@indMediInfo.isEditable": "1", "@chargeStaffInfo.staffCd": "$journal.ord_main.ind_schedule_user_info.upd_user_id", "@indMediInfo.procedureCd": "$journal.detail.ord_main_2.ind_medi_info.procedure_cd", "@indMediInfo.medicineType": "1", "@indMediInfo.procedureName": "$journal.detail.ord_main_2.ind_medi_info.procedure_name"}]}}'::jsonb, '1', '0', 4, '2020-05-14 09:30:43.362', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5020002, 'S_hosp', 'ord_dial', '', 'R', '登録', 'text', 'SSI_透析オーダ受け連携', 'SSI', '透析オーダ受け連携(標準)', '1', '<root name="透析オーダ受け連携(標準 登録)">
  <item name="CRUD" len="0" col="$journal.const.crud" type="string" value="const:C"/>
  <item name="期間開始日" len="8" type="string" note="取込対象外"/>
  <item name="期間終了日" len="8" type="string" note="取込対象外"/>
  <item name="透析日" len="8" col="$journal.const.date_yyyymmdd" type="string"/>
  <item name="開始時刻" len="4" col="$journal.ord_main.ind_treat_start_time" type="string"/>
  <item name="患者ID" len="12" col="$journal.pat_personal_main.hosp_pat_id" type="string"/>
  <item name="患者名" len="20" col="$journal.pat_personal_main.pat_name" type="string" note="取込対象外"/>
  <item name="透析時間" len="3" col="$journal.ord_main.ind_cond_info.001.value" type="string"/>
  <item name="治療方法" len="20" col="$journal.ord_main.ind_treatment_name" type="string"/>
  <item name="ベッド-コード" len="10" col="$journal.ord_main.ind_bed_cd" type="string"/>
  <item name="ベッド-名称" len="20" col="$journal.ord_main.ind_bed_name" type="string" note="取込対象外"/>
  <item name="ダイアライザ-コード" len="10" col="$journal.ord_main.ind_cond_info.005.value" type="string"/>
  <item name="ダイアライザ-名称" len="20" col="$journal.ord_main.ind_cond_info.005.value_name_1" type="string"/>
  <item name="A針-コード" len="10" col="$journal.ord_main.ind_cond_info.010.value" type="string"/>
  <item name="A針-名称" len="40" col="$journal.ord_main.ind_cond_info.010.value_name_1" type="string"/>
  <item name="V針-コード" len="10" col="$journal.ord_main.ind_cond_info.011.value" type="string"/>
  <item name="V針-名称" len="40" col="$journal.ord_main.ind_cond_info.011.value_name_1" type="string"/>
  <item name="透析液-コード" len="10" col="$journal.ord_main.ind_cond_info.015.value" type="string"/>
  <item name="透析液-名称" len="80" col="$journal.ord_main.ind_cond_info.015.value_name_1" type="string"/>
  <item name="透析液-数量" len="7" col="$journal.ord_main.ind_cond_info.017.value" type="string"/>
  <item name="透析液-単位" len="20" col="$journal.ord_main.ind_cond_info.015.unit" type="string"/>
  <item name="抗凝固剤-コード" len="10" col="$journal.ord_main.ind_cond_info.025.value" type="string"/>
  <item name="抗凝固剤-名称" len="80" col="$journal.ord_main.ind_cond_info.025.value_name_1" type="string"/>
  <item name="抗凝固剤-ワンショット量" len="7" col="$journal.ord_main.ind_cond_info.026.value" type="string"/>
  <item name="抗凝固剤-持続注入量" len="7" col="$journal.ord_main.ind_cond_info.027.value" type="string"/>
  <item name="抗凝固剤-持続総量" len="7" col="$journal.ord_main.ind_cond_info.028.value" type="string"/>
  <item name="抗凝固剤-単位" len="20" col="$journal.ord_main.ind_cond_info.025.unit" type="string"/>
  <item name="DW" len="5" col="$journal.pat_unique.physical_info.dw" type="string" note="取込対象外"/>
  <item name="DW更新日" len="8" col="$journal.pat_unique.physical_info.exam_date" type="string" note="取込対象外"/>
  <item name="CTR" len="4" col="$journal.pat_unique.physical_info.ctr" type="string" note="取込対象外"/>
  <item name="CTR更新日" len="8" col="$journal.pat_unique.physical_info.exam_date" type="string" note="取込対象外"/>
  <item name="血流量" len="3" col="$journal.ord_main.ind_cond_info.014.value" type="string"/>
  <item name="IP速度" len="3" col="$journal.ord_main.ind_cond_info.033.value" type="string"/>
  <item name="補液量" len="3" col="$journal.ord_main.ind_cond_info.020.value" type="string"/>
  <item name="除水量制限" len="4" col="$journal.ord_main.ind_cond_info.004.value" type="string"/>
  <item name="除水速度制限" len="4" col="$journal.pat_main.device_set_info.ope.dev.A.181" type="string" note="取込対象外"/>
  <item name="ブラッドアクセスコード" len="10" col="$journal.ord_main.blood_access_info.cd" type="string" note="NTSS関連項目が無し、取込対象外"/>
  <item name="ブラッドアクセス名称" len="40" col="$journal.ord_main.blood_access_info.name" type="string" note="NTSS関連項目が無し、取込対象外"/>
  <item name="ブラッドアクセス部位" len="1" col="$journal.ord_main.blood_access_info.part" type="string" note="NTSS関連項目が無し、取込対象外"/>
  <item name="ブラッドアクセス更新日" len="8" col="$journal.ord_main.blood_access_info.up_date" type="string" note="NTSS関連項目が無し、取込対象外"/>
  <occ name="消耗品情報" len="0" repeat="10" detail="消耗品情報"/>
  <occ name="処方情報" len="0" repeat="20" detail="処方情報"/>
  <item name="除水補正-名称-1" len="16" col="$journal.ord_main.ind_off_water_info.name_1" type="string"/>
  <item name="除水補正-量-1" len="5" col="$journal.ord_main.ind_off_water_info.weight_1" type="string"/>
  <item name="除水補正-名称-2" len="16" col="$journal.ord_main.ind_off_water_info.name_2" type="string"/>
  <item name="除水補正-量-2" len="5" col="$journal.ord_main.ind_off_water_info.weight_2" type="string"/>
  <item name="除水補正-名称-3" len="16" col="$journal.ord_main.ind_off_water_info.name_3" type="string"/>
  <item name="除水補正-量-3" len="5" col="$journal.ord_main.ind_off_water_info.weight_3" type="string"/>
  <item name="除水補正-名称-4" len="16" col="$journal.ord_main.ind_off_water_info.name_4" type="string"/>
  <item name="除水補正-量-4" len="5" col="$journal.ord_main.ind_off_water_info.weight_4" type="string"/>
  <item name="除水補正-名称-5" len="16" col="$journal.ord_main.ind_off_water_info.name_5" type="string"/>
  <item name="除水補正-量-5" len="5" col="$journal.ord_main.ind_off_water_info.weight_5" type="string"/>
  <item name="風袋-名称-1" len="16" col="$journal.ord_main.ind_tare_info.name_1" type="string"/>
  <item name="風袋-量-1" len="5" col="$journal.ord_main.ind_tare_info.weight_1" type="string"/>
  <item name="風袋-名称-2" len="16" col="$journal.ord_main.ind_tare_info.name_2" type="string"/>
  <item name="風袋-量-2" len="5" col="$journal.ord_main.ind_tare_info.weight_2" type="string"/>
  <item name="風袋-名称-3" len="16" col="$journal.ord_main.ind_tare_info.name_3" type="string"/>
  <item name="風袋-量-3" len="5" col="$journal.ord_main.ind_tare_info.weight_3" type="string"/>
  <item name="風袋-名称-4" len="16" col="$journal.ord_main.ind_tare_info.name_4" type="string"/>
  <item name="風袋-量-4" len="5" col="$journal.ord_main.ind_tare_info.weight_4" type="string"/>
  <item name="風袋-名称-5" len="16" col="$journal.ord_main.ind_tare_info.name_5" type="string"/>
  <item name="風袋-量-5" len="5" col="$journal.ord_main.ind_tare_info.weight_5" type="string"/>
  <item name="ダイアライザ２-コード２" len="10" col="$journal.ord_main.ind_equip_info.cd" type="string"/>
  <item name="ダイアライザ２-名称２" len="20" col="$journal.ord_main.ind_equip_info.name" type="string"/>
  <item name="吸着器コード" len="10" col="$journal.ord_main.ind_cond_info.006.value" type="string"/>
  <item name="吸着器名称" len="20" col="$journal.ord_main.ind_cond_info.006.value_name_1" type="string"/>
  <item name="透析液-温度" len="3" col="$journal.ord_main.ind_cond_info.018.value" type="string"/>
  <item name="補液-コード" len="10" col="$journal.ord_main.ind_cond_info.019.value" type="string"/>
  <item name="補液-名称" len="40" col="$journal.ord_main.ind_cond_info.019.value_name_1" type="string"/>
  <item name="補液-使用数" len="3" col="$journal.ord_main.ind_cond_info.022.value" type="string"/>
  <item name="補液-速度" len="4" col="$journal.ord_main.ind_cond_info.024.value" type="string"/>
  <item name="担当医-コード" len="10" col="$journal.ord_main.ind_schedule_user_info.upd_user_id" type="string"/>
  <item name="担当医名" len="20" col="$journal.ord_main.ind_schedule_user_info.upd_user_name" type="string"/>
  <item name="CRLF" len="2" type="string"/>
</root>
', '{}'::jsonb, '1', '0', 4, '2020-05-14 09:30:43.362', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5020003, 'S_hosp', 'ord_dial', '', 'R', '削除', 'text', 'SSI_透析オーダ受け連携', 'SSI', '透析オーダ受け連携(標準)', '1', '<root name="透析オーダ受け連携(標準 削除)">
  <item name="CRUD" len="0" col="$journal.const.crud" type="string" value="const:D"/>
  <item name="期間開始日" len="8" type="string" note="取込対象外"/>
  <item name="期間終了日" len="8" type="string" note="取込対象外"/>
  <item name="透析日" len="8" col="$journal.const.date_yyyymmdd" type="string"/>
  <item name="開始時刻" len="4" col="$journal.ord_main.ind_treat_start_time" type="string"/>
  <item name="患者ID" len="12" col="$journal.pat_personal_main.hosp_pat_id" type="string"/>
  <item name="患者名" len="20" col="$journal.pat_personal_main.pat_name" type="string" note="取込対象外"/>
  <item name="透析時間" len="3" col="$journal.ord_main.ind_cond_info.001.value" type="string"/>
  <item name="治療方法" len="20" col="$journal.ord_main.ind_treatment_name" type="string"/>
  <item name="ベッド-コード" len="10" col="$journal.ord_main.ind_bed_cd" type="string"/>
  <item name="ベッド-名称" len="20" col="$journal.ord_main.ind_bed_name" type="string" note="取込対象外"/>
  <item name="ダイアライザ-コード" len="10" col="$journal.ord_main.ind_cond_info.005.value" type="string"/>
  <item name="ダイアライザ-名称" len="20" col="$journal.ord_main.ind_cond_info.005.value_name_1" type="string"/>
  <item name="A針-コード" len="10" col="$journal.ord_main.ind_cond_info.010.value" type="string"/>
  <item name="A針-名称" len="40" col="$journal.ord_main.ind_cond_info.010.value_name_1" type="string"/>
  <item name="V針-コード" len="10" col="$journal.ord_main.ind_cond_info.011.value" type="string"/>
  <item name="V針-名称" len="40" col="$journal.ord_main.ind_cond_info.011.value_name_1" type="string"/>
  <item name="透析液-コード" len="10" col="$journal.ord_main.ind_cond_info.015.value" type="string"/>
  <item name="透析液-名称" len="80" col="$journal.ord_main.ind_cond_info.015.value_name_1" type="string"/>
  <item name="透析液-数量" len="7" col="$journal.ord_main.ind_cond_info.017.value" type="string"/>
  <item name="透析液-単位" len="20" col="$journal.ord_main.ind_cond_info.015.unit" type="string"/>
  <item name="抗凝固剤-コード" len="10" col="$journal.ord_main.ind_cond_info.025.value" type="string"/>
  <item name="抗凝固剤-名称" len="80" col="$journal.ord_main.ind_cond_info.025.value_name_1" type="string"/>
  <item name="抗凝固剤-ワンショット量" len="7" col="$journal.ord_main.ind_cond_info.026.value" type="string"/>
  <item name="抗凝固剤-持続注入量" len="7" col="$journal.ord_main.ind_cond_info.027.value" type="string"/>
  <item name="抗凝固剤-持続総量" len="7" col="$journal.ord_main.ind_cond_info.028.value" type="string"/>
  <item name="抗凝固剤-単位" len="20" col="$journal.ord_main.ind_cond_info.025.unit" type="string"/>
  <item name="DW" len="5" col="$journal.pat_unique.physical_info.dw" type="string" note="取込対象外"/>
  <item name="DW更新日" len="8" col="$journal.pat_unique.physical_info.exam_date" type="string" note="取込対象外"/>
  <item name="CTR" len="4" col="$journal.pat_unique.physical_info.ctr" type="string" note="取込対象外"/>
  <item name="CTR更新日" len="8" col="$journal.pat_unique.physical_info.exam_date" type="string" note="取込対象外"/>
  <item name="血流量" len="3" col="$journal.ord_main.ind_cond_info.014.value" type="string"/>
  <item name="IP速度" len="3" col="$journal.ord_main.ind_cond_info.033.value" type="string"/>
  <item name="補液量" len="3" col="$journal.ord_main.ind_cond_info.020.value" type="string"/>
  <item name="除水量制限" len="4" col="$journal.ord_main.ind_cond_info.004.value" type="string"/>
  <item name="除水速度制限" len="4" col="$journal.pat_main.device_set_info.ope.dev.A.181" type="string" note="取込対象外"/>
  <item name="ブラッドアクセスコード" len="10" col="$journal.ord_main.blood_access_info.cd" type="string" note="NTSS関連項目が無し、取込対象外"/>
  <item name="ブラッドアクセス名称" len="40" col="$journal.ord_main.blood_access_info.name" type="string" note="NTSS関連項目が無し、取込対象外"/>
  <item name="ブラッドアクセス部位" len="1" col="$journal.ord_main.blood_access_info.part" type="string" note="NTSS関連項目が無し、取込対象外"/>
  <item name="ブラッドアクセス更新日" len="8" col="$journal.ord_main.blood_access_info.up_date" type="string" note="NTSS関連項目が無し、取込対象外"/>
  <occ name="消耗品情報" len="0" repeat="10" detail="消耗品情報"/>
  <occ name="処方情報" len="0" repeat="20" detail="処方情報"/>
  <item name="除水補正-名称-1" len="16" col="$journal.ord_main.ind_off_water_info.name_1" type="string"/>
  <item name="除水補正-量-1" len="5" col="$journal.ord_main.ind_off_water_info.weight_1" type="string"/>
  <item name="除水補正-名称-2" len="16" col="$journal.ord_main.ind_off_water_info.name_2" type="string"/>
  <item name="除水補正-量-2" len="5" col="$journal.ord_main.ind_off_water_info.weight_2" type="string"/>
  <item name="除水補正-名称-3" len="16" col="$journal.ord_main.ind_off_water_info.name_3" type="string"/>
  <item name="除水補正-量-3" len="5" col="$journal.ord_main.ind_off_water_info.weight_3" type="string"/>
  <item name="除水補正-名称-4" len="16" col="$journal.ord_main.ind_off_water_info.name_4" type="string"/>
  <item name="除水補正-量-4" len="5" col="$journal.ord_main.ind_off_water_info.weight_4" type="string"/>
  <item name="除水補正-名称-5" len="16" col="$journal.ord_main.ind_off_water_info.name_5" type="string"/>
  <item name="除水補正-量-5" len="5" col="$journal.ord_main.ind_off_water_info.weight_5" type="string"/>
  <item name="風袋-名称-1" len="16" col="$journal.ord_main.ind_tare_info.name_1" type="string"/>
  <item name="風袋-量-1" len="5" col="$journal.ord_main.ind_tare_info.weight_1" type="string"/>
  <item name="風袋-名称-2" len="16" col="$journal.ord_main.ind_tare_info.name_2" type="string"/>
  <item name="風袋-量-2" len="5" col="$journal.ord_main.ind_tare_info.weight_2" type="string"/>
  <item name="風袋-名称-3" len="16" col="$journal.ord_main.ind_tare_info.name_3" type="string"/>
  <item name="風袋-量-3" len="5" col="$journal.ord_main.ind_tare_info.weight_3" type="string"/>
  <item name="風袋-名称-4" len="16" col="$journal.ord_main.ind_tare_info.name_4" type="string"/>
  <item name="風袋-量-4" len="5" col="$journal.ord_main.ind_tare_info.weight_4" type="string"/>
  <item name="風袋-名称-5" len="16" col="$journal.ord_main.ind_tare_info.name_5" type="string"/>
  <item name="風袋-量-5" len="5" col="$journal.ord_main.ind_tare_info.weight_5" type="string"/>
  <item name="ダイアライザ２-コード２" len="10" col="$journal.ord_main.ind_equip_info.cd" type="string"/>
  <item name="ダイアライザ２-名称２" len="20" col="$journal.ord_main.ind_equip_info.name" type="string"/>
  <item name="吸着器コード" len="10" col="$journal.ord_main.ind_cond_info.006.value" type="string"/>
  <item name="吸着器名称" len="20" col="$journal.ord_main.ind_cond_info.006.value_name_1" type="string"/>
  <item name="透析液-温度" len="3" col="$journal.ord_main.ind_cond_info.018.value" type="string"/>
  <item name="補液-コード" len="10" col="$journal.ord_main.ind_cond_info.019.value" type="string"/>
  <item name="補液-名称" len="40" col="$journal.ord_main.ind_cond_info.019.value_name_1" type="string"/>
  <item name="補液-使用数" len="3" col="$journal.ord_main.ind_cond_info.022.value" type="string"/>
  <item name="補液-速度" len="4" col="$journal.ord_main.ind_cond_info.024.value" type="string"/>
  <item name="担当医-コード" len="10" col="$journal.ord_main.ind_schedule_user_info.upd_user_id" type="string"/>
  <item name="担当医名" len="20" col="$journal.ord_main.ind_schedule_user_info.upd_user_name" type="string"/>
  <item name="CRLF" len="2" type="string"/>
</root>
', '{}'::jsonb, '1', '0', 4, '2020-05-14 09:30:43.362', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5020004, 'S_hosp', 'ord_dial', '', 'R', 'pre', 'text', 'SSI_透析オーダ受け連携', 'SSI', '透析オーダ受け連携(拡張)', '1', '<root name="透析オーダ受け連携(拡張 pre)">
  <item name="期間開始日" len="8" type="string"/>
  <item name="期間終了日" len="8" type="string"/>
  <item name="透析日" len="8" type="string"/>
  <item name="開始時刻" len="4" key="shori_kbn" type="string"/>
  <item name="患者ID" len="12" type="string"/>
  <item name="患者名" len="20" type="string"/>
  <item name="透析時間" len="4" type="string"/>
  <item name="治療方法" len="20" type="string"/>
  <item name="ベッド-コード" len="10" type="string"/>
  <item name="ベッド-名称" len="20" type="string"/>
  <item name="ダイアライザ-コード" len="10" type="string"/>
  <item name="ダイアライザ-名称" len="20" type="string"/>
  <item name="A針-コード" len="10" type="string"/>
  <item name="A針-名称" len="40" type="string"/>
  <item name="V針-コード" len="10" type="string"/>
  <item name="V針-名称" len="40" type="string"/>
  <item name="透析液-コード" len="10" type="string"/>
  <item name="透析液-名称" len="80" type="string"/>
  <item name="透析液-数量" len="7" type="string"/>
  <item name="透析液-単位" len="20" type="string"/>
  <item name="抗凝固剤-コード" len="10" type="string"/>
  <item name="抗凝固剤-名称" len="80" type="string"/>
  <item name="抗凝固剤-ワンショット量" len="7" type="string"/>
  <item name="抗凝固剤-持続注入量" len="7" type="string"/>
  <item name="抗凝固剤-持続総量" len="7" type="string"/>
  <item name="抗凝固剤-単位" len="20" type="string"/>
  <item name="DW" len="5" type="string"/>
  <item name="DW更新日" len="8" type="string"/>
  <item name="CTR" len="4" type="string"/>
  <item name="CTR更新日" len="8" type="string"/>
  <item name="血流量" len="3" type="string"/>
  <item name="IP速度" len="3" type="string"/>
  <item name="補液量" len="4" type="string"/>
  <item name="除水量制限" len="4" type="string"/>
  <item name="除水速度制限" len="4" type="string"/>
  <item name="ブラッドアクセスコード" len="10" type="string"/>
  <item name="ブラッドアクセス名称" len="40" type="string"/>
  <item name="ブラッドアクセス部位" len="1" type="string"/>
  <item name="ブラッドアクセス更新日" len="8" type="string"/>
  <occ name="消耗品情報" len="0" repeat="10" detail="消耗品情報"/>
  <occ name="処方情報" len="0" repeat="20" detail="処方情報"/>
  <item name="除水補正-名称-1" len="16" type="string"/>
  <item name="除水補正-量-1" len="5" type="string"/>
  <item name="除水補正-名称-2" len="16" type="string"/>
  <item name="除水補正-量-2" len="5" type="string"/>
  <item name="除水補正-名称-3" len="16" type="string"/>
  <item name="除水補正-量-3" len="5" type="string"/>
  <item name="除水補正-名称-4" len="16" type="string"/>
  <item name="除水補正-量-4" len="5" type="string"/>
  <item name="除水補正-名称-5" len="16" type="string"/>
  <item name="除水補正-量-5" len="5" type="string"/>
  <item name="風袋-名称-1" len="16" type="string"/>
  <item name="風袋-量-1" len="5" type="string"/>
  <item name="風袋-名称-2" len="16" type="string"/>
  <item name="風袋-量-2" len="5" type="string"/>
  <item name="風袋-名称-3" len="16" type="string"/>
  <item name="風袋-量-3" len="5" type="string"/>
  <item name="風袋-名称-4" len="16" type="string"/>
  <item name="風袋-量-4" len="5" type="string"/>
  <item name="風袋-名称-5" len="16" type="string"/>
  <item name="風袋-量-5" len="5" type="string"/>
  <item name="ダイアライザ２-コード２" len="10" type="string"/>
  <item name="ダイアライザ２-名称２" len="20" type="string"/>
  <item name="吸着器コード" len="10" type="string"/>
  <item name="吸着器名称" len="20" type="string"/>
  <item name="透析液-温度" len="3" type="string"/>
  <item name="補液-コード" len="10" type="string"/>
  <item name="補液-名称" len="40" type="string"/>
  <item name="補液-使用数" len="5" type="string"/>
  <item name="補液-速度" len="4" type="string"/>
  <item name="担当医-コード" len="10" type="string"/>
  <item name="担当医名" len="20" type="string"/>
  <item name="CRLF" len="2" type="string"/>
</root>
', '{"key": {"shori_kbn": {"9999": "削除", "_DEFAULT": "登録"}}, "dataset": {"sqlGroup1": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}], "sqlGroup2": [{"crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500041, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@treatDate": "$journal.const.date_yyyymmdd", "ExceptionMessage": "患者[@hospPatId]の転入出状態が対象外のデータがあります。", "ExceptionCondition": "<>0"}], "sqlGroup3": [{"crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500064, "@indBedCd": "$journal.ord_main.ind_bed_cd", "@indBedName": "$journal.ord_main.ind_bed_name", "ExceptionMessage": "ベッド[@indBedCd]は取込対象外です。", "ExceptionCondition": "<>0"}], "sqlGroup4": [{"crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500012, "@indBedCd": "$journal.ord_main.ind_bed_cd", "@indBedName": "$journal.ord_main.ind_bed_name", "ExceptionMessage": "ベッド[@indBedCd]は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}], "sqlGroup5": [{"crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_treatment", "ctl_no": "1", "sqlCode": -500011, "@treatDate": "$journal.const.date_yyyymmdd", "ExceptionMessage": "治療方法[@indTreatmentName]は存在しません。", "@indTreatmentName": "$journal.ord_main.ind_treatment_name", "ExceptionCondition": "=0"}], "sqlGroup6": [{"crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_treatment", "ctl_no": "1", "sqlCode": -500087, "ExceptionMessage": "治療方法セットが存在しません。", "ExceptionCondition": "=0"}], "sqlGroup7": [{"crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500058, "@treatDate": "$journal.const.date_yyyymmdd", "@dialysisTime": "$journal.ord_main.ind_cond_info.001.value", "ExceptionMessage": "透析時間[@dialysisTime]が治療時間上限値を超えています。", "@indTreatmentName": "$journal.ord_main.ind_treatment_name", "ExceptionCondition": "=1"}], "sqlGroup8": [{"crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500059, "@treatDate": "$journal.const.date_yyyymmdd", "@dialysisTime": "$journal.ord_main.ind_cond_info.001.value", "ExceptionMessage": "特殊浄化[@dialysisTime]が治療時間上限値を超えています。", "@indTreatmentName": "$journal.ord_main.ind_treatment_name", "ExceptionCondition": "=1"}], "sqlGroup9": [{"crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500074, "@treatDate": "$journal.const.date_yyyymmdd", "ExceptionMessage": "補液量が補液量上限値を超えています。", "@indTreatmentName": "$journal.ord_main.ind_treatment_name", "ExceptionCondition": "=1", "@indCondInfo.001.value": "$journal.ord_main.ind_cond_info.001.value", "@indCondInfo.020.value": "$journal.ord_main.ind_cond_info.020.value", "@indCondInfo.024.value": "$journal.ord_main.ind_cond_info.024.value"}], "sqlGroup10": [{"crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500084, "@treatDate": "$journal.const.date_yyyymmdd", "ExceptionMessage": "透析液以外の補液項目が登録されています。オンライン透析を行う場合は補液に透析液を登録して下さい。", "@indTreatmentName": "$journal.ord_main.ind_treatment_name", "ExceptionCondition": "=1", "@indCondInfo.015.value": "$journal.ord_main.ind_cond_info.015.value", "@indCondInfo.019.value": "$journal.ord_main.ind_cond_info.019.value"}], "sqlGroup11": [{"crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500086, "ExceptionMessage": "指示医が登録されていません。", "ExceptionCondition": "<>1", "@chargeStaffInfo.staffCd": "$journal.ord_main.ind_schedule_user_info.upd_user_id"}], "sqlGroup12": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500013, "insertResult": "{}", "@indTreatmentName": "$journal.ord_main.ind_treatment_name", "@indCondInfo.005.name": "$journal.ord_main.ind_cond_info.005.value_name_1", "@indCondInfo.005.value": "$journal.ord_main.ind_cond_info.005.value"}, {"No1": "ダイアライザ or 1次膜登録", "crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": -500054, "@indEquipInfo.cd": "$journal.ord_main.ind_cond_info.005.value", "@indTreatmentName": "$journal.ord_main.ind_treatment_name", "@indEquipInfo.name": "$journal.ord_main.ind_cond_info.005.value_name_1", "@indCondInfo.005.name": "$journal.ord_main.ind_cond_info.005.value_name_1", "@indCondInfo.005.value": "$journal.ord_main.ind_cond_info.005.value"}], "sqlGroup13": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500039, "@indVaCd": "$journal.ord_main.blood_access_info.cd", "insertResult": "{}"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": -500053, "@indVaCd": "$journal.ord_main.blood_access_info.cd", "@indVaName": "$journal.ord_main.blood_access_info.name", "@indVaPart": "$journal.ord_main.blood_access_info.part"}], "sqlGroup14": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500015, "insertResult": "{}", "@indCondInfo.010.name": "$journal.ord_main.ind_cond_info.010.value_name_1", "@indCondInfo.010.value": "$journal.ord_main.ind_cond_info.010.value"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": -500044, "@indCondInfo.010.name": "$journal.ord_main.ind_cond_info.010.value_name_1", "@indCondInfo.010.value": "$journal.ord_main.ind_cond_info.010.value"}], "sqlGroup15": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500037, "insertResult": "{}", "@indCondInfo.011.name": "$journal.ord_main.ind_cond_info.011.value_name_1", "@indCondInfo.011.value": "$journal.ord_main.ind_cond_info.011.value"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": -500052, "@indCondInfo.011.name": "$journal.ord_main.ind_cond_info.011.value_name_1", "@indCondInfo.011.value": "$journal.ord_main.ind_cond_info.011.value"}], "sqlGroup16": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500017, "insertResult": "{}", "@indCondInfo.015.name": "$journal.ord_main.ind_cond_info.015.value_name_1", "@indCondInfo.015.value": "$journal.ord_main.ind_cond_info.015.value"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": -500045, "@indCondInfo.015.name": "$journal.ord_main.ind_cond_info.015.value_name_1", "@indCondInfo.015.unit": "$journal.ord_main.ind_cond_info.015.unit", "@indCondInfo.015.value": "$journal.ord_main.ind_cond_info.015.value"}], "sqlGroup17": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main_1", "ctl_no": "1", "sqlCode": -500019, "insertResult": "{}", "@indEquipInfo.cd": "$journal.detail.ord_main_1.ind_equip_info.cd"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main_1", "ctl_no": "2", "sqlCode": -500046, "@indEquipInfo.cd": "$journal.detail.ord_main_1.ind_equip_info.cd", "@indEquipInfo.no": "$journal.detail.ord_main_1.ind_equip_info.no", "@indEquipInfo.name": "$journal.detail.ord_main_1.ind_equip_info.name", "@indEquipInfo.amount": "$journal.detail.ord_main_1.ind_equip_info.amount"}], "sqlGroup18": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500025, "insertResult": "{}", "@indEquipInfo.cd": "$journal.ord_main.ind_equip_info.cd", "@indEquipInfo.name": "$journal.ord_main.ind_equip_info.name"}, {"No1": "2次膜登録", "crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": -500062, "@indEquipInfo.cd": "$journal.ord_main.ind_equip_info.cd", "@indTreatmentName": "$journal.ord_main.ind_treatment_name", "@indEquipInfo.name": "$journal.ord_main.ind_equip_info.name"}], "sqlGroup19": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500027, "insertResult": "{}", "@indCondInfo.006.name": "$journal.ord_main.ind_cond_info.006.value_name_1", "@indCondInfo.006.value": "$journal.ord_main.ind_cond_info.006.value"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": -500049, "@indCondInfo.006.name": "$journal.ord_main.ind_cond_info.006.value_name_1", "@indCondInfo.006.value": "$journal.ord_main.ind_cond_info.006.value"}], "sqlGroup20": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500029, "insertResult": "{}", "@indCondInfo.019.name": "$journal.ord_main.ind_cond_info.019.value_name_1", "@indCondInfo.019.value": "$journal.ord_main.ind_cond_info.019.value"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": -500050, "@indCondInfo.019.name": "$journal.ord_main.ind_cond_info.019.value_name_1", "@indCondInfo.019.value": "$journal.ord_main.ind_cond_info.019.value"}], "sqlGroup21": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500035, "insertResult": "{}", "@indCondInfo.025.name": "$journal.ord_main.ind_cond_info.025.value_name_1", "@indCondInfo.025.value": "$journal.ord_main.ind_cond_info.025.value"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": -500051, "@indCondInfo.025.name": "$journal.ord_main.ind_cond_info.025.value_name_1", "@indCondInfo.025.unit": "$journal.ord_main.ind_cond_info.025.unit", "@indCondInfo.025.value": "$journal.ord_main.ind_cond_info.025.value"}], "sqlGroup22": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": 8101, "@treatDate": "$journal.const.date_yyyymmdd", "insertResult": "{@patId:'''', @fnPatId:'''', @treatDate:'''', @treatWeek:'''', @facilityCd:'''', @facilityName:'''', @indVaCd:'''', @indTreatmentCd:'''', @indTreatmentName:'''', @indKurCd:'''', @indKurName:'''', @indTreatStartTime:'''', @indBedCd:'''', @indBedName:'''', @indScheduleUserInfoFlg:'''', @indScheduleUserInfo.indUserId:'''', @indScheduleUserInfo.indUserLastName:'''', @indScheduleUserInfo.indUserFirstName:'''', @indScheduleUserInfo.updUserId:'''', @indScheduleUserInfo.updUserLastName:'''', @indScheduleUserInfo.updUserFirstName:'''', @indCondInfo:''{}'', @indMediInfoValue:''[]'', @indEquipInfoValue:''[]'', @indIndCommentInfoValue:''[]'', @indTareInfoFlg:'''', @indTareInfo.name1:'''', @indTareInfo.name2:'''', @indTareInfo.name3:'''', @indTareInfo.name4:'''', @indTareInfo.name5:'''', @indTareInfo.weight1:'''', @indTareInfo.weight2:'''', @indTareInfo.weight3:'''', @indTareInfo.weight4:'''', @indTareInfo.weight5:'''', @indOffWaterInfoFlg:'''', @indOffWaterInfo.name1:'''', @indOffWaterInfo.name2:'''', @indOffWaterInfo.name3:'''', @indOffWaterInfo.name4:'''', @indOffWaterInfo.name5:'''', @indOffWaterInfo.weight1:'''', @indOffWaterInfo.weight2:'''', @indOffWaterInfo.weight3:'''', @indOffWaterInfo.weight4:'''', @indOffWaterInfo.weight5:'''', @indDeviceSetInfo:''{}'', @rstFnDialysisNo:'''', @rstRelationDialysisNo:'''', @rstEdition:''0'', @rstIsUpdateEdition:'''', @rstInputClass:'''', @rstDialysisState:''0'', @rstTreatmentCd:'''', @rstTreatmentName:'''', @rstKurCd:'''', @rstKurName:'''', @rstBedCd:'''', @rstBedName:'''', @rstMachineNo:'''', @rstMachineName:'''', @rstCondSendDate_Date:'''', @rstAcceptDate_Date:'''', @rstStartDate_Date:'''', @rstEndDate_Date:'''', @rstReturnHomeDate_Date:'''', @rstInOutClass:'''', @rstDialysisCnt:'''', @rstWardCd:'''', @rstWardName:'''', @rstCourseCd:'''', @rstCourseName:'''', @rstPunctureUserInfo:'''', @rstReturnUserInfo:'''', @rstChargeUserInfo:'''', @rstBloodCirculateTotal:'''', @rstRunningTime:'''', @rstKtV:'''', @recSetDate_Date:'''', @sendCtlNo:'''', @bloodPurifierName:'''', @pullLeaveAmount:'''', @rstCondInfo:'''', @rstMediInfo:'''', @rstEquipInfo:'''', @rstIndCommentInfo:'''', @rstTareInfo:'''', @rstOffWaterInfo:'''', @rstDeviceSetInfo:'''', @rstWeightInfo:'''', @rstVitalInfo:'''', @rstComplaintInfo:'''', @rstTreatmentInfo:'''', @rstTreatStaffInfo:'''', @rstRoundsInfo:'''', @isDel:''0'', @upDate_Date:'''', @regDate_Date:'''', @rstDw:'''', @weightScaleNo:'''', @treatType:''1'', @isConfirm:''0'', @indDw:'''', @rstPurificationCnt:'''', @additionInfo:'''', @upIndUserId:'''', @upUserId:'''', @rstEditionDate_Date:'''', @curEditionDate_Date:'''', @fnPlural:''''}", "updateResult": "{@patId:''pat_id'', @fnPatId:''fn_pat_id'', @treatDate:''treat_date'', @treatWeek:''treat_week'', @facilityCd:''facility_cd'', @facilityName:''facility_name'', @indVaCd:''ind_va_cd'', @indTreatmentCd:''ind_treatment_cd'', @indTreatmentName:''ind_treatment_name'', @indKurCd:''ind_kur_cd'', @indKurName:''ind_kur_name'', @indTreatStartTime:''ind_treat_start_time'', @indBedCd:''ind_bed_cd'', @indBedName:''ind_bed_name'', @indScheduleUserInfoFlg:'''', @indScheduleUserInfoValue:''ind_schedule_user_info'', @indScheduleUserInfo.indUserId:'''', @indScheduleUserInfo.indUserLastName:'''', @indScheduleUserInfo.indUserFirstName:'''', @indScheduleUserInfo.updUserId:'''', @indScheduleUserInfo.updUserLastName:'''', @indScheduleUserInfo.updUserFirstName:'''', @indCondInfo:''ind_cond_info'', @indMediInfoValue:''ind_medi_info'', @indEquipInfoValue:''ind_equip_info'', @indIndCommentInfoValue:''ind_ind_comment_info'', @indTareInfoFlg:'''', @indTareInfoValue:''ind_tare_info'', @indTareInfo.name1:'''', @indTareInfo.name2:'''', @indTareInfo.name3:'''', @indTareInfo.name4:'''', @indTareInfo.name5:'''', @indTareInfo.weight1:'''', @indTareInfo.weight2:'''', @indTareInfo.weight3:'''', @indTareInfo.weight4:'''', @indTareInfo.weight5:'''', @indOffWaterInfoFlg:'''', @indOffWaterInfoValue:''ind_off_water_info'', @indOffWaterInfo.name1:'''', @indOffWaterInfo.name2:'''', @indOffWaterInfo.name3:'''', @indOffWaterInfo.name4:'''', @indOffWaterInfo.name5:'''', @indOffWaterInfo.weight1:'''', @indOffWaterInfo.weight2:'''', @indOffWaterInfo.weight3:'''', @indOffWaterInfo.weight4:'''', @indOffWaterInfo.weight5:'''', @indDeviceSetInfo:''ind_device_set_info'', @rstFnDialysisNo:''rst_fn_dialysis_no'', @rstRelationDialysisNo:''rst_relation_dialysis_no'', @rstEdition:''rst_edition'', @rstIsUpdateEdition:''rst_is_update_edition'', @rstInputClass:''rst_input_class'', @rstDialysisState:''rst_dialysis_state'', @rstTreatmentCd:''rst_treatment_cd'', @rstTreatmentName:''rst_treatment_name'', @rstKurCd:''rst_kur_cd'', @rstKurName:''rst_kur_name'', @rstBedCd:''rst_bed_cd'', @rstBedName:''rst_bed_name'', @rstMachineNo:''rst_machine_no'', @rstMachineName:''rst_machine_name'', @rstCondSendDate_Date:''rst_cond_send_date'', @rstAcceptDate_Date:''rst_accept_date'', @rstStartDate_Date:''rst_start_date'', @rstEndDate_Date:''rst_end_date'', @rstReturnHomeDate_Date:''rst_return_home_date'', @rstInOutClass:''rst_in_out_class'', @rstDialysisCnt:''rst_dialysis_cnt'', @rstWardCd:''rst_ward_cd'', @rstWardName:''rst_ward_name'', @rstCourseCd:''rst_course_cd'', @rstCourseName:''rst_course_name'', @rstPunctureUserInfo:''rst_puncture_user_info'', @rstReturnUserInfo:''rst_return_user_info'', @rstChargeUserInfo:''rst_charge_user_info'', @rstBloodCirculateTotal:''rst_blood_circulate_total'', @rstRunningTime:''rst_running_time'', @rstKtV:''rst_kt_v'', @recSetDate_Date:''rec_set_date'', @sendCtlNo:''send_ctl_no'', @bloodPurifierName:''blood_purifier_name'', @pullLeaveAmount:''pull_leave_amount'', @rstCondInfo:''rst_cond_info'', @rstMediInfo:''rst_medi_info'', @rstEquipInfo:''rst_equip_info'', @rstIndCommentInfo:''rst_ind_comment_info'', @rstTareInfo:''rst_tare_info'', @rstOffWaterInfo:''rst_off_water_info'', @rstDeviceSetInfo:''rst_device_set_info'', @rstWeightInfo:''rst_weight_info'', @rstVitalInfo:''rst_vital_info'', @rstComplaintInfo:''rst_complaint_info'', @rstTreatmentInfo:''rst_treatment_info'', @rstTreatStaffInfo:''rst_treat_staff_info'', @rstRoundsInfo:''rst_rounds_info'', @isDel:''is_del'', @upDate_Date:''up_date'', @regDate_Date:''reg_date'', @rstDw:''rst_dw'', @weightScaleNo:''weight_scale_no'', @treatType:''treat_type'', @isConfirm:''is_confirm'', @indDw:''ind_dw'', @rstPurificationCnt:''rst_purification_cnt'', @additionInfo:''addition_info'', @upIndUserId:''up_ind_user_id'', @upUserId:''up_user_id'', @rstEditionDate_Date:''rst_edition_date'', @curEditionDate_Date:''cur_edition_date'', @fnPlural:''fn_plural''}"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": 8102, "@indVaCd": "$journal.ord_main.blood_access_info.cd", "@indBedCd": "$journal.ord_main.ind_bed_cd", "@upUserId": "$journal.ord_main.ind_schedule_user_info.upd_user_id", "@treatDate": "$journal.const.date_yyyymmdd", "@indBedName": "$journal.ord_main.ind_bed_name", "@indEquipInfo.cd": "$journal.ord_main.ind_equip_info.cd", "@indTreatmentName": "$journal.ord_main.ind_treatment_name", "@indEquipInfo.name": "$journal.ord_main.ind_equip_info.name", "@indTreatStartTime": "$journal.ord_main.ind_treat_start_time", "@chargeStaffInfo.staffCd": "$journal.ord_main.ind_schedule_user_info.upd_user_id", "@indScheduleUserInfo.indUserId": "$journal.ord_main.ind_schedule_user_info.upd_user_id", "@indScheduleUserInfo.updUserId": "$journal.ord_main.ind_schedule_user_info.upd_user_id", "@indScheduleUserInfo.indUserLastName": "$journal.ord_main.ind_schedule_user_info.upd_user_name", "@indScheduleUserInfo.updUserLastName": "$journal.ord_main.ind_schedule_user_info.upd_user_name", "@indScheduleUserInfo.indUserFirstName": "$journal.ord_main.ind_schedule_user_info.upd_user_name", "@indScheduleUserInfo.updUserFirstName": "$journal.ord_main.ind_schedule_user_info.upd_user_name"}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "3", "sqlCode": 8103, "@indBedCd": "$journal.ord_main.ind_bed_cd", "@upUserId": "$journal.ord_main.ind_schedule_user_info.upd_user_id", "@treatDate": "$journal.const.date_yyyymmdd", "@indBedName": "$journal.ord_main.ind_bed_name", "@indEquipInfo.cd": "$journal.ord_main.ind_equip_info.cd", "@indTreatmentName": "$journal.ord_main.ind_treatment_name", "@indEquipInfo.name": "$journal.ord_main.ind_equip_info.name", "@indTreatStartTime": "$journal.ord_main.ind_treat_start_time", "@chargeStaffInfo.staffCd": "$journal.ord_main.ind_schedule_user_info.upd_user_id", "@indScheduleUserInfo.indUserId": "$journal.ord_main.ind_schedule_user_info.upd_user_id", "@indScheduleUserInfo.updUserId": "$journal.ord_main.ind_schedule_user_info.upd_user_id", "@indScheduleUserInfo.indUserLastName": "$journal.ord_main.ind_schedule_user_info.upd_user_name", "@indScheduleUserInfo.updUserLastName": "$journal.ord_main.ind_schedule_user_info.upd_user_name", "@indScheduleUserInfo.indUserFirstName": "$journal.ord_main.ind_schedule_user_info.upd_user_name", "@indScheduleUserInfo.updUserFirstName": "$journal.ord_main.ind_schedule_user_info.upd_user_name"}], "sqlGroup23": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": 8101, "@treatDate": "$journal.const.date_yyyymmdd", "updateResult": "{}"}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": 8104, "@indVaCd": "$journal.ord_main.blood_access_info.cd", "@treatDate": "$journal.const.date_yyyymmdd", "@indEquipInfo.cd": "$journal.ord_main.ind_equip_info.cd", "@indTreatmentName": "$journal.ord_main.ind_treatment_name", "@indCondInfo.format": "Extension", "@indCondInfo.005.name": "$journal.ord_main.ind_cond_info.005.value_name_1", "@indCondInfo.006.name": "$journal.ord_main.ind_cond_info.006.value_name_1", "@indCondInfo.010.name": "$journal.ord_main.ind_cond_info.010.value_name_1", "@indCondInfo.011.name": "$journal.ord_main.ind_cond_info.011.value_name_1", "@indCondInfo.015.name": "$journal.ord_main.ind_cond_info.015.value_name_1", "@indCondInfo.015.unit": "$journal.ord_main.ind_cond_info.015.unit", "@indCondInfo.019.name": "$journal.ord_main.ind_cond_info.019.value_name_1", "@indCondInfo.025.name": "$journal.ord_main.ind_cond_info.025.value_name_1", "@indCondInfo.025.unit": "$journal.ord_main.ind_cond_info.025.unit", "@indCondInfo.001.value": "$journal.ord_main.ind_cond_info.001.value", "@indCondInfo.004.value": "$journal.ord_main.ind_cond_info.004.value", "@indCondInfo.005.value": "$journal.ord_main.ind_cond_info.005.value", "@indCondInfo.006.value": "$journal.ord_main.ind_cond_info.006.value", "@indCondInfo.008.value": "$journal.ord_main.ind_equip_info.cd", "@indCondInfo.010.value": "$journal.ord_main.ind_cond_info.010.value", "@indCondInfo.011.value": "$journal.ord_main.ind_cond_info.011.value", "@indCondInfo.014.value": "$journal.ord_main.ind_cond_info.014.value", "@indCondInfo.015.value": "$journal.ord_main.ind_cond_info.015.value", "@indCondInfo.017.value": "$journal.ord_main.ind_cond_info.017.value", "@indCondInfo.018.value": "$journal.ord_main.ind_cond_info.018.value", "@indCondInfo.019.value": "$journal.ord_main.ind_cond_info.019.value", "@indCondInfo.020.value": "$journal.ord_main.ind_cond_info.020.value", "@indCondInfo.022.value": "$journal.ord_main.ind_cond_info.022.value", "@indCondInfo.024.value": "$journal.ord_main.ind_cond_info.024.value", "@indCondInfo.025.value": "$journal.ord_main.ind_cond_info.025.value", "@indCondInfo.026.value": "$journal.ord_main.ind_cond_info.026.value", "@indCondInfo.027.value": "$journal.ord_main.ind_cond_info.027.value", "@indCondInfo.028.value": "$journal.ord_main.ind_cond_info.028.value", "@indCondInfo.033.value": "$journal.ord_main.ind_cond_info.033.value", "@indCondInfo.039.value": "$journal.pat_unique.physical_info.dw", "@ind_tare_info.ind_tare_info.name_1": "$journal.ord_main.ind_tare_info.name_1", "@ind_tare_info.ind_tare_info.name_2": "$journal.ord_main.ind_tare_info.name_2", "@ind_tare_info.ind_tare_info.name_3": "$journal.ord_main.ind_tare_info.name_3", "@ind_tare_info.ind_tare_info.name_4": "$journal.ord_main.ind_tare_info.name_4", "@ind_tare_info.ind_tare_info.name_5": "$journal.ord_main.ind_tare_info.name_5", "@ind_tare_info.ind_tare_info.weight_1": "$journal.ord_main.ind_tare_info.weight_1", "@ind_tare_info.ind_tare_info.weight_2": "$journal.ord_main.ind_tare_info.weight_2", "@ind_tare_info.ind_tare_info.weight_3": "$journal.ord_main.ind_tare_info.weight_3", "@ind_tare_info.ind_tare_info.weight_4": "$journal.ord_main.ind_tare_info.weight_4", "@ind_tare_info.ind_tare_info.weight_5": "$journal.ord_main.ind_tare_info.weight_5", "@ind_off_water_info.ind_off_water_info.name_1": "$journal.ord_main.ind_off_water_info.name_1", "@ind_off_water_info.ind_off_water_info.name_2": "$journal.ord_main.ind_off_water_info.name_2", "@ind_off_water_info.ind_off_water_info.name_3": "$journal.ord_main.ind_off_water_info.name_3", "@ind_off_water_info.ind_off_water_info.name_4": "$journal.ord_main.ind_off_water_info.name_4", "@ind_off_water_info.ind_off_water_info.name_5": "$journal.ord_main.ind_off_water_info.name_5", "@ind_off_water_info.ind_off_water_info.weight_1": "$journal.ord_main.ind_off_water_info.weight_1", "@ind_off_water_info.ind_off_water_info.weight_2": "$journal.ord_main.ind_off_water_info.weight_2", "@ind_off_water_info.ind_off_water_info.weight_3": "$journal.ord_main.ind_off_water_info.weight_3", "@ind_off_water_info.ind_off_water_info.weight_4": "$journal.ord_main.ind_off_water_info.weight_4", "@ind_off_water_info.ind_off_water_info.weight_5": "$journal.ord_main.ind_off_water_info.weight_5"}], "sqlGroup24": [{"crud": "S", "kind": "0", "judge": "$journal.const.crud#=#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -503001, "@treatDate": "$journal.const.date_yyyymmdd", "ExceptionMessage": "オーダー番号[@ordNo]治療条件送信後にスケジュール変更はできません。", "ExceptionCondition": "=1"}], "sqlGroup25": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#=#D", "table": "ord_main", "ctl_no": "1", "sqlCode": 8101, "@treatDate": "$journal.const.date_yyyymmdd", "updateResult": "{}"}, {"crud": "U", "kind": "1", "note": "倫理削除処理", "judge": "$journal.const.crud#=#D", "table": "ord_main", "ctl_no": "2", "sqlCode": 8105, "@upUserId": "$journal.ord_main.ind_schedule_user_info.upd_user_id", "@chargeStaffInfo.staffCd": "$journal.ord_main.ind_schedule_user_info.upd_user_id"}], "sqlGroup26": [{"crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500043, "@treatDate": "$journal.const.date_yyyymmdd", "updateResult": "{@indEquipInfoValue:''ind_equip_info''}"}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": 8106}], "sqlGroup27": [{"crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.crud#<>#D", "table": "ord_main_1", "ctl_no": "1", "sqlCode": -500042, "@treatDate": "$journal.const.date_yyyymmdd", "updateResult": "{@indEquipInfoValue:''ind_equip_info''}"}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main_1", "ctl_no": "3", "sqlCode": 8107, "@indEquipInfo.cd": "$journal.detail.ord_main_1.ind_equip_info.cd", "@indEquipInfo.name": "$journal.detail.ord_main_1.ind_equip_info.name", "@indEquipInfo.amount": "$journal.detail.ord_main_1.ind_equip_info.amount", "@indEquipInfo.isEditable": "1"}], "sqlGroup28": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main_2", "ctl_no": "1", "sqlCode": -500068, "insertResult": "{}", "@indMediInfo.cd": "$journal.detail.ord_main_2.ind_medi_info.cd", "@indMediInfo.name": "$journal.detail.ord_main_2.ind_medi_info.name"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main_2", "ctl_no": "2", "sqlCode": -500073, "@indMediInfo.cd": "$journal.detail.ord_main_2.ind_medi_info.cd", "@indMediInfo.no": "$journal.detail.ord_main_2.ind_medi_info.no", "@indMediInfo.name": "$journal.detail.ord_main_2.ind_medi_info.name", "@indMediInfo.unit": "$journal.detail.ord_main_2.ind_medi_info.unit"}], "sqlGroup29": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main_2", "ctl_no": "1", "sqlCode": -500023, "insertResult": "{}", "@indMediInfo.procedureCd": "$journal.detail.ord_main_2.ind_medi_info.procedure_cd", "@indMediInfo.procedureName": "$journal.detail.ord_main_2.ind_medi_info.procedure_name"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main_2", "ctl_no": "2", "sqlCode": -500048, "@indMediInfo.procedureCd": "$journal.detail.ord_main_2.ind_medi_info.procedure_cd", "@indMediInfo.procedureName": "$journal.detail.ord_main_2.ind_medi_info.procedure_name"}], "sqlGroup30": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500065, "insertResult": "{@mediInfoNo:''''}"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": -500066}], "sqlGroup31": [{"crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500043, "@treatDate": "$journal.const.date_yyyymmdd", "updateResult": "{@indMediInfoValue:''ind_medi_info'', @rstMediInfoValue:''rst_medi_info''}"}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": 8108}], "sqlGroup32": [{"crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.crud#<>#D", "table": "ord_main_2", "ctl_no": "1", "sqlCode": -500043, "@treatDate": "$journal.const.date_yyyymmdd", "updateResult": "{@indMediInfoValue:''ind_medi_info'', @rstMediInfoValue:''rst_medi_info''}"}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main_2", "ctl_no": "2", "sqlCode": 8109, "@indMediInfo.cd": "$journal.detail.ord_main_2.ind_medi_info.cd", "@indMediInfo.name": "$journal.detail.ord_main_2.ind_medi_info.name", "@indMediInfo.unit": "$journal.detail.ord_main_2.ind_medi_info.unit", "@indMediInfo.amount": "$journal.detail.ord_main_2.ind_medi_info.amount", "@indMediInfo.initDate": "$journal.const.date_yyyymmdd", "@indMediInfo.inputClass": 2, "@indMediInfo.isEditable": "1", "@chargeStaffInfo.staffCd": "$journal.ord_main.ind_schedule_user_info.upd_user_id", "@indMediInfo.procedureCd": "$journal.detail.ord_main_2.ind_medi_info.procedure_cd", "@indMediInfo.medicineType": "1", "@indMediInfo.procedureName": "$journal.detail.ord_main_2.ind_medi_info.procedure_name"}], "sqlGroup33": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500032}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": -500033, "@indBedCd": "$journal.ord_main.ind_bed_cd", "@treatDate": "$journal.const.date_yyyymmdd", "@indBedName": "$journal.ord_main.ind_bed_name", "@indTreatStartTime": "$journal.ord_main.ind_treat_start_time"}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "3", "sqlCode": -500034, "@indBedCd": "$journal.ord_main.ind_bed_cd", "@treatDate": "$journal.const.date_yyyymmdd", "@indBedName": "$journal.ord_main.ind_bed_name", "@indTreatStartTime": "$journal.ord_main.ind_treat_start_time"}]}}'::jsonb, '1', '1', 4, '2020-05-14 09:30:43.362', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5020005, 'S_hosp', 'ord_dial', '', 'R', '登録', 'text', 'SSI_透析オーダ受け連携', 'SSI', '透析オーダ受け連携(拡張)', '1', '<root name="透析オーダ受け連携(拡張 登録)">
  <item name="CRUD" len="0" col="$journal.const.crud" type="string" value="const:C"/>
  <item name="期間開始日" len="8" type="string" note="取込対象外"/>
  <item name="期間終了日" len="8" type="string" note="取込対象外"/>
  <item name="透析日" len="8" col="$journal.const.date_yyyymmdd" type="string"/>
  <item name="開始時刻" len="4" col="$journal.ord_main.ind_treat_start_time" type="string"/>
  <item name="患者ID" len="12" col="$journal.pat_personal_main.hosp_pat_id" type="string"/>
  <item name="患者名" len="20" col="$journal.pat_personal_main.pat_name" type="string" note="取込対象外"/>
  <item name="透析時間" len="4" col="$journal.ord_main.ind_cond_info.001.value" type="string"/>
  <item name="治療方法" len="20" col="$journal.ord_main.ind_treatment_name" type="string"/>
  <item name="ベッド-コード" len="10" col="$journal.ord_main.ind_bed_cd" type="string"/>
  <item name="ベッド-名称" len="20" col="$journal.ord_main.ind_bed_name" type="string" note="取込対象外"/>
  <item name="ダイアライザ-コード" len="10" col="$journal.ord_main.ind_cond_info.005.value" type="string"/>
  <item name="ダイアライザ-名称" len="20" col="$journal.ord_main.ind_cond_info.005.value_name_1" type="string"/>
  <item name="A針-コード" len="10" col="$journal.ord_main.ind_cond_info.010.value" type="string"/>
  <item name="A針-名称" len="40" col="$journal.ord_main.ind_cond_info.010.value_name_1" type="string"/>
  <item name="V針-コード" len="10" col="$journal.ord_main.ind_cond_info.011.value" type="string"/>
  <item name="V針-名称" len="40" col="$journal.ord_main.ind_cond_info.011.value_name_1" type="string"/>
  <item name="透析液-コード" len="10" col="$journal.ord_main.ind_cond_info.015.value" type="string"/>
  <item name="透析液-名称" len="80" col="$journal.ord_main.ind_cond_info.015.value_name_1" type="string"/>
  <item name="透析液-数量" len="7" col="$journal.ord_main.ind_cond_info.017.value" type="string"/>
  <item name="透析液-単位" len="20" col="$journal.ord_main.ind_cond_info.015.unit" type="string"/>
  <item name="抗凝固剤-コード" len="10" col="$journal.ord_main.ind_cond_info.025.value" type="string"/>
  <item name="抗凝固剤-名称" len="80" col="$journal.ord_main.ind_cond_info.025.value_name_1" type="string"/>
  <item name="抗凝固剤-ワンショット量" len="7" col="$journal.ord_main.ind_cond_info.026.value" type="string"/>
  <item name="抗凝固剤-持続注入量" len="7" col="$journal.ord_main.ind_cond_info.027.value" type="string"/>
  <item name="抗凝固剤-持続総量" len="7" col="$journal.ord_main.ind_cond_info.028.value" type="string"/>
  <item name="抗凝固剤-単位" len="20" col="$journal.ord_main.ind_cond_info.025.unit" type="string"/>
  <item name="DW" len="5" col="$journal.pat_unique.physical_info.dw" type="string" note="取込対象外"/>
  <item name="DW更新日" len="8" col="$journal.pat_unique.physical_info.exam_date" type="string" note="取込対象外"/>
  <item name="CTR" len="4" col="$journal.pat_unique.physical_info.ctr" type="string" note="取込対象外"/>
  <item name="CTR更新日" len="8" col="$journal.pat_unique.physical_info.exam_date" type="string" note="取込対象外"/>
  <item name="血流量" len="3" col="$journal.ord_main.ind_cond_info.014.value" type="string"/>
  <item name="IP速度" len="3" col="$journal.ord_main.ind_cond_info.033.value" type="string"/>
  <item name="補液量" len="4" col="$journal.ord_main.ind_cond_info.020.value" type="string"/>
  <item name="除水量制限" len="4" col="$journal.ord_main.ind_cond_info.004.value" type="string"/>
  <item name="除水速度制限" len="4" col="$journal.pat_main.device_set_info.ope.dev.A.181" type="string" note="取込対象外"/>
  <item name="ブラッドアクセスコード" len="10" col="$journal.ord_main.blood_access_info.cd" type="string" note="NTSS関連項目が無し、取込対象外"/>
  <item name="ブラッドアクセス名称" len="40" col="$journal.ord_main.blood_access_info.name" type="string" note="NTSS関連項目が無し、取込対象外"/>
  <item name="ブラッドアクセス部位" len="1" col="$journal.ord_main.blood_access_info.part" type="string" note="NTSS関連項目が無し、取込対象外"/>
  <item name="ブラッドアクセス更新日" len="8" col="$journal.ord_main.blood_access_info.up_date" type="string" note="NTSS関連項目が無し、取込対象外"/>
  <occ name="消耗品情報" len="0" repeat="10" detail="消耗品情報"/>
  <occ name="処方情報" len="0" repeat="20" detail="処方情報"/>
  <item name="除水補正-名称-1" len="16" col="$journal.ord_main.ind_off_water_info.name_1" type="string"/>
  <item name="除水補正-量-1" len="5" col="$journal.ord_main.ind_off_water_info.weight_1" type="string"/>
  <item name="除水補正-名称-2" len="16" col="$journal.ord_main.ind_off_water_info.name_2" type="string"/>
  <item name="除水補正-量-2" len="5" col="$journal.ord_main.ind_off_water_info.weight_2" type="string"/>
  <item name="除水補正-名称-3" len="16" col="$journal.ord_main.ind_off_water_info.name_3" type="string"/>
  <item name="除水補正-量-3" len="5" col="$journal.ord_main.ind_off_water_info.weight_3" type="string"/>
  <item name="除水補正-名称-4" len="16" col="$journal.ord_main.ind_off_water_info.name_4" type="string"/>
  <item name="除水補正-量-4" len="5" col="$journal.ord_main.ind_off_water_info.weight_4" type="string"/>
  <item name="除水補正-名称-5" len="16" col="$journal.ord_main.ind_off_water_info.name_5" type="string"/>
  <item name="除水補正-量-5" len="5" col="$journal.ord_main.ind_off_water_info.weight_5" type="string"/>
  <item name="風袋-名称-1" len="16" col="$journal.ord_main.ind_tare_info.name_1" type="string"/>
  <item name="風袋-量-1" len="5" col="$journal.ord_main.ind_tare_info.weight_1" type="string"/>
  <item name="風袋-名称-2" len="16" col="$journal.ord_main.ind_tare_info.name_2" type="string"/>
  <item name="風袋-量-2" len="5" col="$journal.ord_main.ind_tare_info.weight_2" type="string"/>
  <item name="風袋-名称-3" len="16" col="$journal.ord_main.ind_tare_info.name_3" type="string"/>
  <item name="風袋-量-3" len="5" col="$journal.ord_main.ind_tare_info.weight_3" type="string"/>
  <item name="風袋-名称-4" len="16" col="$journal.ord_main.ind_tare_info.name_4" type="string"/>
  <item name="風袋-量-4" len="5" col="$journal.ord_main.ind_tare_info.weight_4" type="string"/>
  <item name="風袋-名称-5" len="16" col="$journal.ord_main.ind_tare_info.name_5" type="string"/>
  <item name="風袋-量-5" len="5" col="$journal.ord_main.ind_tare_info.weight_5" type="string"/>
  <item name="ダイアライザ２-コード２" len="10" col="$journal.ord_main.ind_equip_info.cd" type="string"/>
  <item name="ダイアライザ２-名称２" len="20" col="$journal.ord_main.ind_equip_info.name" type="string"/>
  <item name="吸着器コード" len="10" col="$journal.ord_main.ind_cond_info.006.value" type="string"/>
  <item name="吸着器名称" len="20" col="$journal.ord_main.ind_cond_info.006.value_name_1" type="string"/>
  <item name="透析液-温度" len="3" col="$journal.ord_main.ind_cond_info.018.value" type="string"/>
  <item name="補液-コード" len="10" col="$journal.ord_main.ind_cond_info.019.value" type="string"/>
  <item name="補液-名称" len="40" col="$journal.ord_main.ind_cond_info.019.value_name_1" type="string"/>
  <item name="補液-使用数" len="5" col="$journal.ord_main.ind_cond_info.022.value" type="string"/>
  <item name="補液-速度" len="4" col="$journal.ord_main.ind_cond_info.024.value" type="string"/>
  <item name="担当医-コード" len="10" col="$journal.ord_main.ind_schedule_user_info.upd_user_id" type="string"/>
  <item name="担当医名" len="20" col="$journal.ord_main.ind_schedule_user_info.upd_user_name" type="string"/>
  <item name="CRLF" len="2" type="string"/>
</root>
', '{}'::jsonb, '1', '1', 4, '2020-05-14 09:30:43.362', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5020006, 'S_hosp', 'ord_dial', '', 'R', '削除', 'text', 'SSI_透析オーダ受け連携', 'SSI', '透析オーダ受け連携(拡張)', '1', '<root name="透析オーダ受け連携(拡張 削除)">
  <item name="CRUD" len="0" col="$journal.const.crud" type="string" value="const:D"/>
  <item name="期間開始日" len="8" type="string" note="取込対象外"/>
  <item name="期間終了日" len="8" type="string" note="取込対象外"/>
  <item name="透析日" len="8" col="$journal.const.date_yyyymmdd" type="string"/>
  <item name="開始時刻" len="4" col="$journal.ord_main.ind_treat_start_time" type="string"/>
  <item name="患者ID" len="12" col="$journal.pat_personal_main.hosp_pat_id" type="string"/>
  <item name="患者名" len="20" col="$journal.pat_personal_main.pat_name" type="string" note="取込対象外"/>
  <item name="透析時間" len="4" col="$journal.ord_main.ind_cond_info.001.value" type="string"/>
  <item name="治療方法" len="20" col="$journal.ord_main.ind_treatment_name" type="string"/>
  <item name="ベッド-コード" len="10" col="$journal.ord_main.ind_bed_cd" type="string"/>
  <item name="ベッド-名称" len="20" col="$journal.ord_main.ind_bed_name" type="string" note="取込対象外"/>
  <item name="ダイアライザ-コード" len="10" col="$journal.ord_main.ind_cond_info.005.value" type="string"/>
  <item name="ダイアライザ-名称" len="20" col="$journal.ord_main.ind_cond_info.005.value_name_1" type="string"/>
  <item name="A針-コード" len="10" col="$journal.ord_main.ind_cond_info.010.value" type="string"/>
  <item name="A針-名称" len="40" col="$journal.ord_main.ind_cond_info.010.value_name_1" type="string"/>
  <item name="V針-コード" len="10" col="$journal.ord_main.ind_cond_info.011.value" type="string"/>
  <item name="V針-名称" len="40" col="$journal.ord_main.ind_cond_info.011.value_name_1" type="string"/>
  <item name="透析液-コード" len="10" col="$journal.ord_main.ind_cond_info.015.value" type="string"/>
  <item name="透析液-名称" len="80" col="$journal.ord_main.ind_cond_info.015.value_name_1" type="string"/>
  <item name="透析液-数量" len="7" col="$journal.ord_main.ind_cond_info.017.value" type="string"/>
  <item name="透析液-単位" len="20" col="$journal.ord_main.ind_cond_info.015.unit" type="string"/>
  <item name="抗凝固剤-コード" len="10" col="$journal.ord_main.ind_cond_info.025.value" type="string"/>
  <item name="抗凝固剤-名称" len="80" col="$journal.ord_main.ind_cond_info.025.value_name_1" type="string"/>
  <item name="抗凝固剤-ワンショット量" len="7" col="$journal.ord_main.ind_cond_info.026.value" type="string"/>
  <item name="抗凝固剤-持続注入量" len="7" col="$journal.ord_main.ind_cond_info.027.value" type="string"/>
  <item name="抗凝固剤-持続総量" len="7" col="$journal.ord_main.ind_cond_info.028.value" type="string"/>
  <item name="抗凝固剤-単位" len="20" col="$journal.ord_main.ind_cond_info.025.unit" type="string"/>
  <item name="DW" len="5" col="$journal.pat_unique.physical_info.dw" type="string" note="取込対象外"/>
  <item name="DW更新日" len="8" col="$journal.pat_unique.physical_info.exam_date" type="string" note="取込対象外"/>
  <item name="CTR" len="4" col="$journal.pat_unique.physical_info.ctr" type="string" note="取込対象外"/>
  <item name="CTR更新日" len="8" col="$journal.pat_unique.physical_info.exam_date" type="string" note="取込対象外"/>
  <item name="血流量" len="3" col="$journal.ord_main.ind_cond_info.014.value" type="string"/>
  <item name="IP速度" len="3" col="$journal.ord_main.ind_cond_info.033.value" type="string"/>
  <item name="補液量" len="4" col="$journal.ord_main.ind_cond_info.020.value" type="string"/>
  <item name="除水量制限" len="4" col="$journal.ord_main.ind_cond_info.004.value" type="string"/>
  <item name="除水速度制限" len="4" col="$journal.pat_main.device_set_info.ope.dev.A.181" type="string" note="取込対象外"/>
  <item name="ブラッドアクセスコード" len="10" col="$journal.ord_main.blood_access_info.cd" type="string" note="NTSS関連項目が無し、取込対象外"/>
  <item name="ブラッドアクセス名称" len="40" col="$journal.ord_main.blood_access_info.name" type="string" note="NTSS関連項目が無し、取込対象外"/>
  <item name="ブラッドアクセス部位" len="1" col="$journal.ord_main.blood_access_info.part" type="string" note="NTSS関連項目が無し、取込対象外"/>
  <item name="ブラッドアクセス更新日" len="8" col="$journal.ord_main.blood_access_info.up_date" type="string" note="NTSS関連項目が無し、取込対象外"/>
  <occ name="消耗品情報" len="0" repeat="10" detail="消耗品情報"/>
  <occ name="処方情報" len="0" repeat="20" detail="処方情報"/>
  <item name="除水補正-名称-1" len="16" col="$journal.ord_main.ind_off_water_info.name_1" type="string"/>
  <item name="除水補正-量-1" len="5" col="$journal.ord_main.ind_off_water_info.weight_1" type="string"/>
  <item name="除水補正-名称-2" len="16" col="$journal.ord_main.ind_off_water_info.name_2" type="string"/>
  <item name="除水補正-量-2" len="5" col="$journal.ord_main.ind_off_water_info.weight_2" type="string"/>
  <item name="除水補正-名称-3" len="16" col="$journal.ord_main.ind_off_water_info.name_3" type="string"/>
  <item name="除水補正-量-3" len="5" col="$journal.ord_main.ind_off_water_info.weight_3" type="string"/>
  <item name="除水補正-名称-4" len="16" col="$journal.ord_main.ind_off_water_info.name_4" type="string"/>
  <item name="除水補正-量-4" len="5" col="$journal.ord_main.ind_off_water_info.weight_4" type="string"/>
  <item name="除水補正-名称-5" len="16" col="$journal.ord_main.ind_off_water_info.name_5" type="string"/>
  <item name="除水補正-量-5" len="5" col="$journal.ord_main.ind_off_water_info.weight_5" type="string"/>
  <item name="風袋-名称-1" len="16" col="$journal.ord_main.ind_tare_info.name_1" type="string"/>
  <item name="風袋-量-1" len="5" col="$journal.ord_main.ind_tare_info.weight_1" type="string"/>
  <item name="風袋-名称-2" len="16" col="$journal.ord_main.ind_tare_info.name_2" type="string"/>
  <item name="風袋-量-2" len="5" col="$journal.ord_main.ind_tare_info.weight_2" type="string"/>
  <item name="風袋-名称-3" len="16" col="$journal.ord_main.ind_tare_info.name_3" type="string"/>
  <item name="風袋-量-3" len="5" col="$journal.ord_main.ind_tare_info.weight_3" type="string"/>
  <item name="風袋-名称-4" len="16" col="$journal.ord_main.ind_tare_info.name_4" type="string"/>
  <item name="風袋-量-4" len="5" col="$journal.ord_main.ind_tare_info.weight_4" type="string"/>
  <item name="風袋-名称-5" len="16" col="$journal.ord_main.ind_tare_info.name_5" type="string"/>
  <item name="風袋-量-5" len="5" col="$journal.ord_main.ind_tare_info.weight_5" type="string"/>
  <item name="ダイアライザ２-コード２" len="10" col="$journal.ord_main.ind_equip_info.cd" type="string"/>
  <item name="ダイアライザ２-名称２" len="20" col="$journal.ord_main.ind_equip_info.name" type="string"/>
  <item name="吸着器コード" len="10" col="$journal.ord_main.ind_cond_info.006.value" type="string"/>
  <item name="吸着器名称" len="20" col="$journal.ord_main.ind_cond_info.006.value_name_1" type="string"/>
  <item name="透析液-温度" len="3" col="$journal.ord_main.ind_cond_info.018.value" type="string"/>
  <item name="補液-コード" len="10" col="$journal.ord_main.ind_cond_info.019.value" type="string"/>
  <item name="補液-名称" len="40" col="$journal.ord_main.ind_cond_info.019.value_name_1" type="string"/>
  <item name="補液-使用数" len="5" col="$journal.ord_main.ind_cond_info.022.value" type="string"/>
  <item name="補液-速度" len="4" col="$journal.ord_main.ind_cond_info.024.value" type="string"/>
  <item name="担当医-コード" len="10" col="$journal.ord_main.ind_schedule_user_info.upd_user_id" type="string"/>
  <item name="担当医名" len="20" col="$journal.ord_main.ind_schedule_user_info.upd_user_name" type="string"/>
  <item name="CRLF" len="2" type="string"/>
</root>
', '{}'::jsonb, '1', '1', 4, '2020-05-14 09:30:43.362', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5020007, 'S_hosp', 'ord_dial', 'M', 'R', 'pre', 'text', 'SSI_透析オーダ受け連携', 'SSI', '透析オーダ受け連携(標準)', '1', '<root name="透析オーダ受け連携(標準 pre)">
  <item name="期間開始日" len="8" type="string"/>
  <item name="期間終了日" len="8" type="string"/>
  <item name="透析日" len="8" type="string"/>
  <item name="開始時刻" len="4" key="shori_kbn" type="string"/>
  <item name="患者ID" len="12" type="string"/>
  <item name="患者名" len="20" type="string"/>
  <item name="透析時間" len="3" type="string"/>
  <item name="治療方法" len="20" type="string"/>
  <item name="ベッド-コード" len="10" type="string"/>
  <item name="ベッド-名称" len="20" type="string"/>
  <item name="ダイアライザ-コード" len="10" type="string"/>
  <item name="ダイアライザ-名称" len="20" type="string"/>
  <item name="A針-コード" len="10" type="string"/>
  <item name="A針-名称" len="40" type="string"/>
  <item name="V針-コード" len="10" type="string"/>
  <item name="V針-名称" len="40" type="string"/>
  <item name="透析液-コード" len="10" type="string"/>
  <item name="透析液-名称" len="80" type="string"/>
  <item name="透析液-数量" len="7" type="string"/>
  <item name="透析液-単位" len="20" type="string"/>
  <item name="抗凝固剤-コード" len="10" type="string"/>
  <item name="抗凝固剤-名称" len="80" type="string"/>
  <item name="抗凝固剤-ワンショット量" len="7" type="string"/>
  <item name="抗凝固剤-持続注入量" len="7" type="string"/>
  <item name="抗凝固剤-持続総量" len="7" type="string"/>
  <item name="抗凝固剤-単位" len="20" type="string"/>
  <item name="DW" len="5" type="string"/>
  <item name="DW更新日" len="8" type="string"/>
  <item name="CTR" len="4" type="string"/>
  <item name="CTR更新日" len="8" type="string"/>
  <item name="血流量" len="3" type="string"/>
  <item name="IP速度" len="3" type="string"/>
  <item name="補液量" len="3" type="string"/>
  <item name="除水量制限" len="4" type="string"/>
  <item name="除水速度制限" len="4" type="string"/>
  <item name="ブラッドアクセスコード" len="10" type="string"/>
  <item name="ブラッドアクセス名称" len="40" type="string"/>
  <item name="ブラッドアクセス部位" len="1" type="string"/>
  <item name="ブラッドアクセス更新日" len="8" type="string"/>
  <occ name="消耗品情報" len="0" repeat="10" detail="消耗品情報"/>
  <occ name="処方情報" len="0" repeat="20" detail="処方情報"/>
  <item name="除水補正-名称-1" len="16" type="string"/>
  <item name="除水補正-量-1" len="5" type="string"/>
  <item name="除水補正-名称-2" len="16" type="string"/>
  <item name="除水補正-量-2" len="5" type="string"/>
  <item name="除水補正-名称-3" len="16" type="string"/>
  <item name="除水補正-量-3" len="5" type="string"/>
  <item name="除水補正-名称-4" len="16" type="string"/>
  <item name="除水補正-量-4" len="5" type="string"/>
  <item name="除水補正-名称-5" len="16" type="string"/>
  <item name="除水補正-量-5" len="5" type="string"/>
  <item name="風袋-名称-1" len="16" type="string"/>
  <item name="風袋-量-1" len="5" type="string"/>
  <item name="風袋-名称-2" len="16" type="string"/>
  <item name="風袋-量-2" len="5" type="string"/>
  <item name="風袋-名称-3" len="16" type="string"/>
  <item name="風袋-量-3" len="5" type="string"/>
  <item name="風袋-名称-4" len="16" type="string"/>
  <item name="風袋-量-4" len="5" type="string"/>
  <item name="風袋-名称-5" len="16" type="string"/>
  <item name="風袋-量-5" len="5" type="string"/>
  <item name="ダイアライザ２-コード２" len="10" type="string"/>
  <item name="ダイアライザ２-名称２" len="20" type="string"/>
  <item name="吸着器コード" len="10" type="string"/>
  <item name="吸着器名称" len="20" type="string"/>
  <item name="透析液-温度" len="3" type="string"/>
  <item name="補液-コード" len="10" type="string"/>
  <item name="補液-名称" len="40" type="string"/>
  <item name="補液-使用数" len="3" type="string"/>
  <item name="補液-速度" len="4" type="string"/>
  <item name="担当医-コード" len="10" type="string"/>
  <item name="担当医名" len="20" type="string"/>
  <item name="CRLF" len="2" type="string"/>
</root>
', '{"key": {"shori_kbn": {"9999": "削除", "_DEFAULT": "登録"}}, "dataset": {"sqlGroup1": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}], "sqlGroup2": [{"crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500041, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@treatDate": "$journal.const.date_yyyymmdd", "ExceptionMessage": "患者[@hospPatId]の転入出状態が対象外のデータがあります。", "ExceptionCondition": "<>0"}], "sqlGroup3": [{"crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -503002, "@treatDate": "$journal.const.date_yyyymmdd", "ExceptionMessage": "投薬オーダーは治療中の場合のみ取り込みできます。", "ExceptionCondition": "=0"}], "sqlGroup4": [{"crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500086, "ExceptionMessage": "指示医が登録されていません。", "ExceptionCondition": "<>1", "@chargeStaffInfo.staffCd": "$journal.ord_main.ind_schedule_user_info.upd_user_id"}], "sqlGroup5": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main_2", "ctl_no": "1", "sqlCode": -500068, "insertResult": "{}", "@indMediInfo.cd": "$journal.detail.ord_main_2.ind_medi_info.cd", "@indMediInfo.name": "$journal.detail.ord_main_2.ind_medi_info.name"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main_2", "ctl_no": "2", "sqlCode": -500073, "@indMediInfo.cd": "$journal.detail.ord_main_2.ind_medi_info.cd", "@indMediInfo.no": "$journal.detail.ord_main_2.ind_medi_info.no", "@indMediInfo.name": "$journal.detail.ord_main_2.ind_medi_info.name", "@indMediInfo.unit": "$journal.detail.ord_main_2.ind_medi_info.unit"}], "sqlGroup6": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main_2", "ctl_no": "1", "sqlCode": -500023, "insertResult": "{}", "@indMediInfo.procedureCd": "$journal.detail.ord_main_2.ind_medi_info.procedure_cd", "@indMediInfo.procedureName": "$journal.detail.ord_main_2.ind_medi_info.procedure_name"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main_2", "ctl_no": "2", "sqlCode": -500048, "@indMediInfo.procedureCd": "$journal.detail.ord_main_2.ind_medi_info.procedure_cd", "@indMediInfo.procedureName": "$journal.detail.ord_main_2.ind_medi_info.procedure_name"}], "sqlGroup7": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500065, "insertResult": "{@mediInfoNo:''''}"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": -500066}], "sqlGroup8": [{"crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500043, "@treatDate": "$journal.const.date_yyyymmdd", "updateResult": "{@indMediInfoValue:''ind_medi_info'', @rstMediInfoValue:''rst_medi_info''}"}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": -500071}], "sqlGroup9": [{"crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.crud#<>#D", "table": "ord_main_2", "ctl_no": "1", "sqlCode": -500043, "@treatDate": "$journal.const.date_yyyymmdd", "updateResult": "{@indMediInfoValue:''ind_medi_info'', @rstMediInfoValue:''rst_medi_info''}"}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main_2", "ctl_no": "2", "sqlCode": -500072, "@indMediInfo.cd": "$journal.detail.ord_main_2.ind_medi_info.cd", "@indMediInfo.name": "$journal.detail.ord_main_2.ind_medi_info.name", "@indMediInfo.unit": "$journal.detail.ord_main_2.ind_medi_info.unit", "@indMediInfo.amount": "$journal.detail.ord_main_2.ind_medi_info.amount", "@indMediInfo.initDate": "$journal.const.date_yyyymmdd", "@indMediInfo.inputClass": 2, "@indMediInfo.isEditable": "1", "@chargeStaffInfo.staffCd": "$journal.ord_main.ind_schedule_user_info.upd_user_id", "@indMediInfo.procedureCd": "$journal.detail.ord_main_2.ind_medi_info.procedure_cd", "@indMediInfo.medicineType": "1", "@indMediInfo.procedureName": "$journal.detail.ord_main_2.ind_medi_info.procedure_name"}]}}'::jsonb, '1', '0', 4, '2025-03-10 18:49:44.588', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5020008, 'S_hosp', 'ord_dial', 'M', 'R', '登録', 'text', 'SSI_透析オーダ受け連携', 'SSI', '透析オーダ受け連携(標準)', '1', '<root name="透析オーダ受け連携(標準 登録)">
  <item name="CRUD" len="0" col="$journal.const.crud" type="string" value="const:C"/>
  <item name="期間開始日" len="8" type="string" note="取込対象外"/>
  <item name="期間終了日" len="8" type="string" note="取込対象外"/>
  <item name="透析日" len="8" col="$journal.const.date_yyyymmdd" type="string"/>
  <item name="開始時刻" len="4" col="$journal.const.start_time_hhmm" type="string"/>
  <item name="患者ID" len="12" col="$journal.pat_personal_main.hosp_pat_id" type="string"/>
  <item name="患者名" len="20" col="$journal.pat_personal_main.pat_name" type="string" note="取込対象外"/>
  <item name="透析時間" len="3" col="$journal.ord_main.ind_cond_info.001.value" type="string"/>
  <item name="治療方法" len="20" col="$journal.ord_main.ind_treatment_name" type="string"/>
  <item name="ベッド-コード" len="10" col="$journal.ord_main.ind_bed_cd" type="string"/>
  <item name="ベッド-名称" len="20" col="$journal.ord_main.ind_bed_name" type="string" note="取込対象外"/>
  <item name="ダイアライザ-コード" len="10" col="$journal.ord_main.ind_cond_info.005.value" type="string"/>
  <item name="ダイアライザ-名称" len="20" col="$journal.ord_main.ind_cond_info.005.value_name_1" type="string"/>
  <item name="A針-コード" len="10" col="$journal.ord_main.ind_cond_info.010.value" type="string"/>
  <item name="A針-名称" len="40" col="$journal.ord_main.ind_cond_info.010.value_name_1" type="string"/>
  <item name="V針-コード" len="10" col="$journal.ord_main.ind_cond_info.011.value" type="string"/>
  <item name="V針-名称" len="40" col="$journal.ord_main.ind_cond_info.011.value_name_1" type="string"/>
  <item name="透析液-コード" len="10" col="$journal.ord_main.ind_cond_info.015.value" type="string"/>
  <item name="透析液-名称" len="80" col="$journal.ord_main.ind_cond_info.015.value_name_1" type="string"/>
  <item name="透析液-数量" len="7" col="$journal.ord_main.ind_cond_info.017.value" type="string"/>
  <item name="透析液-単位" len="20" col="$journal.ord_main.ind_cond_info.015.unit" type="string"/>
  <item name="抗凝固剤-コード" len="10" col="$journal.ord_main.ind_cond_info.025.value" type="string"/>
  <item name="抗凝固剤-名称" len="80" col="$journal.ord_main.ind_cond_info.025.value_name_1" type="string"/>
  <item name="抗凝固剤-ワンショット量" len="7" col="$journal.ord_main.ind_cond_info.026.value" type="string"/>
  <item name="抗凝固剤-持続注入量" len="7" col="$journal.ord_main.ind_cond_info.027.value" type="string"/>
  <item name="抗凝固剤-持続総量" len="7" col="$journal.ord_main.ind_cond_info.028.value" type="string"/>
  <item name="抗凝固剤-単位" len="20" col="$journal.ord_main.ind_cond_info.025.unit" type="string"/>
  <item name="DW" len="5" col="$journal.pat_unique.physical_info.dw" type="string" note="取込対象外"/>
  <item name="DW更新日" len="8" col="$journal.pat_unique.physical_info.exam_date" type="string" note="取込対象外"/>
  <item name="CTR" len="4" col="$journal.pat_unique.physical_info.ctr" type="string" note="取込対象外"/>
  <item name="CTR更新日" len="8" col="$journal.pat_unique.physical_info.exam_date" type="string" note="取込対象外"/>
  <item name="血流量" len="3" col="$journal.ord_main.ind_cond_info.014.value" type="string"/>
  <item name="IP速度" len="3" col="$journal.ord_main.ind_cond_info.033.value" type="string"/>
  <item name="補液量" len="3" col="$journal.ord_main.ind_cond_info.020.value" type="string"/>
  <item name="除水量制限" len="4" col="$journal.ord_main.ind_cond_info.004.value" type="string"/>
  <item name="除水速度制限" len="4" col="$journal.pat_main.device_set_info.ope.dev.A.181" type="string" note="取込対象外"/>
  <item name="ブラッドアクセスコード" len="10" col="$journal.ord_main.blood_access_info.cd" type="string" note="NTSS関連項目が無し、取込対象外"/>
  <item name="ブラッドアクセス名称" len="40" col="$journal.ord_main.blood_access_info.name" type="string" note="NTSS関連項目が無し、取込対象外"/>
  <item name="ブラッドアクセス部位" len="1" col="$journal.ord_main.blood_access_info.part" type="string" note="NTSS関連項目が無し、取込対象外"/>
  <item name="ブラッドアクセス更新日" len="8" col="$journal.ord_main.blood_access_info.up_date" type="string" note="NTSS関連項目が無し、取込対象外"/>
  <occ name="消耗品情報" len="0" repeat="10" detail="消耗品情報"/>
  <occ name="処方情報" len="0" repeat="20" detail="処方情報"/>
  <item name="除水補正-名称-1" len="16" col="$journal.ord_main.ind_off_water_info.name_1" type="string"/>
  <item name="除水補正-量-1" len="5" col="$journal.ord_main.ind_off_water_info.weight_1" type="string"/>
  <item name="除水補正-名称-2" len="16" col="$journal.ord_main.ind_off_water_info.name_2" type="string"/>
  <item name="除水補正-量-2" len="5" col="$journal.ord_main.ind_off_water_info.weight_2" type="string"/>
  <item name="除水補正-名称-3" len="16" col="$journal.ord_main.ind_off_water_info.name_3" type="string"/>
  <item name="除水補正-量-3" len="5" col="$journal.ord_main.ind_off_water_info.weight_3" type="string"/>
  <item name="除水補正-名称-4" len="16" col="$journal.ord_main.ind_off_water_info.name_4" type="string"/>
  <item name="除水補正-量-4" len="5" col="$journal.ord_main.ind_off_water_info.weight_4" type="string"/>
  <item name="除水補正-名称-5" len="16" col="$journal.ord_main.ind_off_water_info.name_5" type="string"/>
  <item name="除水補正-量-5" len="5" col="$journal.ord_main.ind_off_water_info.weight_5" type="string"/>
  <item name="風袋-名称-1" len="16" col="$journal.ord_main.ind_tare_info.name_1" type="string"/>
  <item name="風袋-量-1" len="5" col="$journal.ord_main.ind_tare_info.weight_1" type="string"/>
  <item name="風袋-名称-2" len="16" col="$journal.ord_main.ind_tare_info.name_2" type="string"/>
  <item name="風袋-量-2" len="5" col="$journal.ord_main.ind_tare_info.weight_2" type="string"/>
  <item name="風袋-名称-3" len="16" col="$journal.ord_main.ind_tare_info.name_3" type="string"/>
  <item name="風袋-量-3" len="5" col="$journal.ord_main.ind_tare_info.weight_3" type="string"/>
  <item name="風袋-名称-4" len="16" col="$journal.ord_main.ind_tare_info.name_4" type="string"/>
  <item name="風袋-量-4" len="5" col="$journal.ord_main.ind_tare_info.weight_4" type="string"/>
  <item name="風袋-名称-5" len="16" col="$journal.ord_main.ind_tare_info.name_5" type="string"/>
  <item name="風袋-量-5" len="5" col="$journal.ord_main.ind_tare_info.weight_5" type="string"/>
  <item name="ダイアライザ２-コード２" len="10" col="$journal.ord_main.ind_equip_info.cd" type="string"/>
  <item name="ダイアライザ２-名称２" len="20" col="$journal.ord_main.ind_equip_info.name" type="string"/>
  <item name="吸着器コード" len="10" col="$journal.ord_main.ind_cond_info.006.value" type="string"/>
  <item name="吸着器名称" len="20" col="$journal.ord_main.ind_cond_info.006.value_name_1" type="string"/>
  <item name="透析液-温度" len="3" col="$journal.ord_main.ind_cond_info.018.value" type="string"/>
  <item name="補液-コード" len="10" col="$journal.ord_main.ind_cond_info.019.value" type="string"/>
  <item name="補液-名称" len="40" col="$journal.ord_main.ind_cond_info.019.value_name_1" type="string"/>
  <item name="補液-使用数" len="3" col="$journal.ord_main.ind_cond_info.022.value" type="string"/>
  <item name="補液-速度" len="4" col="$journal.ord_main.ind_cond_info.024.value" type="string"/>
  <item name="担当医-コード" len="10" col="$journal.ord_main.ind_schedule_user_info.upd_user_id" type="string"/>
  <item name="担当医名" len="20" col="$journal.ord_main.ind_schedule_user_info.upd_user_name" type="string"/>
  <item name="CRLF" len="2" type="string"/>
</root>
', '{}'::jsonb, '1', '0', 4, '2025-03-10 18:49:44.598', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5020009, 'S_hosp', 'ord_dial', 'M', 'R', '削除', 'text', 'SSI_透析オーダ受け連携', 'SSI', '透析オーダ受け連携(標準)', '1', '<root name="透析オーダ受け連携(標準 削除)">
  <item name="CRUD" len="0" col="$journal.const.crud" type="string" value="const:D"/>
  <item name="期間開始日" len="8" type="string" note="取込対象外"/>
  <item name="期間終了日" len="8" type="string" note="取込対象外"/>
  <item name="透析日" len="8" col="$journal.const.date_yyyymmdd" type="string"/>
  <item name="開始時刻" len="4" col="$journal.const.start_time_hhmm" type="string"/>
  <item name="患者ID" len="12" col="$journal.pat_personal_main.hosp_pat_id" type="string"/>
  <item name="患者名" len="20" col="$journal.pat_personal_main.pat_name" type="string" note="取込対象外"/>
  <item name="透析時間" len="3" col="$journal.ord_main.ind_cond_info.001.value" type="string"/>
  <item name="治療方法" len="20" col="$journal.ord_main.ind_treatment_name" type="string"/>
  <item name="ベッド-コード" len="10" col="$journal.ord_main.ind_bed_cd" type="string"/>
  <item name="ベッド-名称" len="20" col="$journal.ord_main.ind_bed_name" type="string" note="取込対象外"/>
  <item name="ダイアライザ-コード" len="10" col="$journal.ord_main.ind_cond_info.005.value" type="string"/>
  <item name="ダイアライザ-名称" len="20" col="$journal.ord_main.ind_cond_info.005.value_name_1" type="string"/>
  <item name="A針-コード" len="10" col="$journal.ord_main.ind_cond_info.010.value" type="string"/>
  <item name="A針-名称" len="40" col="$journal.ord_main.ind_cond_info.010.value_name_1" type="string"/>
  <item name="V針-コード" len="10" col="$journal.ord_main.ind_cond_info.011.value" type="string"/>
  <item name="V針-名称" len="40" col="$journal.ord_main.ind_cond_info.011.value_name_1" type="string"/>
  <item name="透析液-コード" len="10" col="$journal.ord_main.ind_cond_info.015.value" type="string"/>
  <item name="透析液-名称" len="80" col="$journal.ord_main.ind_cond_info.015.value_name_1" type="string"/>
  <item name="透析液-数量" len="7" col="$journal.ord_main.ind_cond_info.017.value" type="string"/>
  <item name="透析液-単位" len="20" col="$journal.ord_main.ind_cond_info.015.unit" type="string"/>
  <item name="抗凝固剤-コード" len="10" col="$journal.ord_main.ind_cond_info.025.value" type="string"/>
  <item name="抗凝固剤-名称" len="80" col="$journal.ord_main.ind_cond_info.025.value_name_1" type="string"/>
  <item name="抗凝固剤-ワンショット量" len="7" col="$journal.ord_main.ind_cond_info.026.value" type="string"/>
  <item name="抗凝固剤-持続注入量" len="7" col="$journal.ord_main.ind_cond_info.027.value" type="string"/>
  <item name="抗凝固剤-持続総量" len="7" col="$journal.ord_main.ind_cond_info.028.value" type="string"/>
  <item name="抗凝固剤-単位" len="20" col="$journal.ord_main.ind_cond_info.025.unit" type="string"/>
  <item name="DW" len="5" col="$journal.pat_unique.physical_info.dw" type="string" note="取込対象外"/>
  <item name="DW更新日" len="8" col="$journal.pat_unique.physical_info.exam_date" type="string" note="取込対象外"/>
  <item name="CTR" len="4" col="$journal.pat_unique.physical_info.ctr" type="string" note="取込対象外"/>
  <item name="CTR更新日" len="8" col="$journal.pat_unique.physical_info.exam_date" type="string" note="取込対象外"/>
  <item name="血流量" len="3" col="$journal.ord_main.ind_cond_info.014.value" type="string"/>
  <item name="IP速度" len="3" col="$journal.ord_main.ind_cond_info.033.value" type="string"/>
  <item name="補液量" len="3" col="$journal.ord_main.ind_cond_info.020.value" type="string"/>
  <item name="除水量制限" len="4" col="$journal.ord_main.ind_cond_info.004.value" type="string"/>
  <item name="除水速度制限" len="4" col="$journal.pat_main.device_set_info.ope.dev.A.181" type="string" note="取込対象外"/>
  <item name="ブラッドアクセスコード" len="10" col="$journal.ord_main.blood_access_info.cd" type="string" note="NTSS関連項目が無し、取込対象外"/>
  <item name="ブラッドアクセス名称" len="40" col="$journal.ord_main.blood_access_info.name" type="string" note="NTSS関連項目が無し、取込対象外"/>
  <item name="ブラッドアクセス部位" len="1" col="$journal.ord_main.blood_access_info.part" type="string" note="NTSS関連項目が無し、取込対象外"/>
  <item name="ブラッドアクセス更新日" len="8" col="$journal.ord_main.blood_access_info.up_date" type="string" note="NTSS関連項目が無し、取込対象外"/>
  <occ name="消耗品情報" len="0" repeat="10" detail="消耗品情報"/>
  <occ name="処方情報" len="0" repeat="20" detail="処方情報"/>
  <item name="除水補正-名称-1" len="16" col="$journal.ord_main.ind_off_water_info.name_1" type="string"/>
  <item name="除水補正-量-1" len="5" col="$journal.ord_main.ind_off_water_info.weight_1" type="string"/>
  <item name="除水補正-名称-2" len="16" col="$journal.ord_main.ind_off_water_info.name_2" type="string"/>
  <item name="除水補正-量-2" len="5" col="$journal.ord_main.ind_off_water_info.weight_2" type="string"/>
  <item name="除水補正-名称-3" len="16" col="$journal.ord_main.ind_off_water_info.name_3" type="string"/>
  <item name="除水補正-量-3" len="5" col="$journal.ord_main.ind_off_water_info.weight_3" type="string"/>
  <item name="除水補正-名称-4" len="16" col="$journal.ord_main.ind_off_water_info.name_4" type="string"/>
  <item name="除水補正-量-4" len="5" col="$journal.ord_main.ind_off_water_info.weight_4" type="string"/>
  <item name="除水補正-名称-5" len="16" col="$journal.ord_main.ind_off_water_info.name_5" type="string"/>
  <item name="除水補正-量-5" len="5" col="$journal.ord_main.ind_off_water_info.weight_5" type="string"/>
  <item name="風袋-名称-1" len="16" col="$journal.ord_main.ind_tare_info.name_1" type="string"/>
  <item name="風袋-量-1" len="5" col="$journal.ord_main.ind_tare_info.weight_1" type="string"/>
  <item name="風袋-名称-2" len="16" col="$journal.ord_main.ind_tare_info.name_2" type="string"/>
  <item name="風袋-量-2" len="5" col="$journal.ord_main.ind_tare_info.weight_2" type="string"/>
  <item name="風袋-名称-3" len="16" col="$journal.ord_main.ind_tare_info.name_3" type="string"/>
  <item name="風袋-量-3" len="5" col="$journal.ord_main.ind_tare_info.weight_3" type="string"/>
  <item name="風袋-名称-4" len="16" col="$journal.ord_main.ind_tare_info.name_4" type="string"/>
  <item name="風袋-量-4" len="5" col="$journal.ord_main.ind_tare_info.weight_4" type="string"/>
  <item name="風袋-名称-5" len="16" col="$journal.ord_main.ind_tare_info.name_5" type="string"/>
  <item name="風袋-量-5" len="5" col="$journal.ord_main.ind_tare_info.weight_5" type="string"/>
  <item name="ダイアライザ２-コード２" len="10" col="$journal.ord_main.ind_equip_info.cd" type="string"/>
  <item name="ダイアライザ２-名称２" len="20" col="$journal.ord_main.ind_equip_info.name" type="string"/>
  <item name="吸着器コード" len="10" col="$journal.ord_main.ind_cond_info.006.value" type="string"/>
  <item name="吸着器名称" len="20" col="$journal.ord_main.ind_cond_info.006.value_name_1" type="string"/>
  <item name="透析液-温度" len="3" col="$journal.ord_main.ind_cond_info.018.value" type="string"/>
  <item name="補液-コード" len="10" col="$journal.ord_main.ind_cond_info.019.value" type="string"/>
  <item name="補液-名称" len="40" col="$journal.ord_main.ind_cond_info.019.value_name_1" type="string"/>
  <item name="補液-使用数" len="3" col="$journal.ord_main.ind_cond_info.022.value" type="string"/>
  <item name="補液-速度" len="4" col="$journal.ord_main.ind_cond_info.024.value" type="string"/>
  <item name="担当医-コード" len="10" col="$journal.ord_main.ind_schedule_user_info.upd_user_id" type="string"/>
  <item name="担当医名" len="20" col="$journal.ord_main.ind_schedule_user_info.upd_user_name" type="string"/>
  <item name="CRLF" len="2" type="string"/>
</root>
', '{}'::jsonb, '1', '0', 4, '2025-03-10 18:49:44.603', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5030001, 'S_hosp', 'profile', '', 'R', 'all', 'xml', 'SSI_患者属性連携', 'SSI', '患者情報受信', '1', '<SsiData Type="PAT_INF">
  <CRUD>col:$journal.const.crud,const:C</CRUD>
  <!-- 患者属性情報 -->
  <PatientData>
    <!-- 患者情報 -->
    <PatientID>col:$journal.pat_personal_main.hosp_pat_id</PatientID>
    <PatientName>col:$journal.pat_personal_main.pat_name</PatientName>
    <PatientKanaName>col:$journal.pat_personal_main.pat_name_kana</PatientKanaName>
    <PatientSex>col:$journal.pat_personal_main.pat_sex</PatientSex>
    <PatientBirthDay>col:$journal.pat_personal_main.pat_birthday</PatientBirthDay>
    <PatientEtcInfo>
      <!-- 患者付属情報 -->
      <PatientBloodTypeABO>col:$journal.pat_personal_main.pat_blood_type_abo,default:NoXmlTag</PatientBloodTypeABO>
      <PatientBloodTypeRH>col:$journal.pat_personal_main.pat_blood_type_rh,default:NoXmlTag</PatientBloodTypeRH>
      <PostNumber>col:$journal.pat_personal_main.pat_contact_info.zip_cd,default:NoXmlTag</PostNumber>
      <Address>col:$journal.pat_personal_main.pat_contact_info.address,default:NoXmlTag</Address>
      <Tel>col:$journal.pat_personal_main.pat_contact_info.tel1,default:NoXmlTag</Tel>
      <Comment>col:$journal.pat_personal_main.pat_contact_info.memo1,default:NoXmlTag</Comment>
    </PatientEtcInfo>
    <PatientDIALYSISInfo>
      <!-- 患者透析情報 -->
      <DIALYSISStartYMD>col:$journal.pat_main.medical_care_info.dialysis_start_date,default:NoXmlTag</DIALYSISStartYMD>
      <GENSIKKAN Code="col:$journal.pat_unique.medical_hst_info.disease_cd">col:$journal.pat_unique.medical_hst_info.disease_name</GENSIKKAN>
      <GENSIKKANYMD>col:$journal.pat_unique.medical_hst_info.disease_date,default:NoXmlTag</GENSIKKANYMD>
      <TENKI>col:$journal.pat_unique.medical_hst_info.out_come,default:NoXmlTag</TENKI>
      <TENKIYMD>col:$journal.pat_unique.medical_hst_info.out_come_date,default:NoXmlTag</TENKIYMD>
      <DIEDOF Code="col:$journal.pat_personal_main.die_cd,default:NoXmlTag">col:$journal.pat_personal_main.die_name</DIEDOF>
      <DOUNYU/>
      <!-- 導入院所; 連携対象外 -->
      <SYOKAI/>
      <!-- 紹介院所; 連携対象外 -->
      <Ctr>col:$journal.detail.pat_unique_1.physical_info.ctr</Ctr>
      <CTR>col:$journal.detail.pat_unique_1.physical_info.ctr_2</CTR>
      <CTR_UPDATE>col:$journal.detail.pat_unique_1.physical_info.exam_date</CTR_UPDATE>
      <Doctor Code="col:$journal.pat_main.charge_staff_info.doctor_cd,default:NoXmlTag"/>
      <DialysisDoctor Code="col:$journal.pat_main.charge_staff_info.dialysis_doctor_cd,default:NoXmlTag"/>
      <DialysisNurse Code="col:$journal.pat_main.charge_staff_info.dialysis_nurse_cd,default:NoXmlTag"/>
    </PatientDIALYSISInfo>
    <AdmissionInfo>
      <!-- 入院情報 -->
      <AdmissionStatus>col:$journal.pat_personal_main.in_out_class,default:NoXmlTag</AdmissionStatus>
      <Ward Code="col:$journal.pat_main.medical_care_info.ward_cd,default:NoXmlTag">col:$journal.pat_main.medical_care_info.ward_name</Ward>
      <InRoom Code=""/>
      <!-- 連携対象外 -->
      <Bed Code=""/>
      <!-- 連携対象外 -->
      <AdmissionDate/>
      <!-- 連携対象外 -->
      <DischargeDate/>
      <!-- 連携対象外 -->
      <AdmissionSnk Code="col:$journal.pat_main.medical_care_info.main_course_cd,default:NoXmlTag">col:$journal.pat_main.medical_care_info.course_name</AdmissionSnk>
      <AdmissionDoctor Code="col:$journal.pat_main.charge_staff_info.admission_doctor_cd,default:NoXmlTag"/>
    </AdmissionInfo>
    <InsuranceInfo ctlNo="col:$journal.detail.pat_insurance.ctl_no,const:0">
      <!-- 主保険情報 -->
      <InsuranceNumber>col:$journal.detail.pat_insurance.insu_info.insu_no,default:NoXmlTag</InsuranceNumber>
      <InsuranceDivision>col:$journal.detail.pat_insurance.insu_info.insu_kbn,default:NoXmlTag</InsuranceDivision>
      <InsuredSign>col:$journal.detail.pat_insurance.insu_info.insu_pat_mark,default:NoXmlTag</InsuredSign>
      <InsuredNumber>col:$journal.detail.pat_insurance.insu_info.insu_pat_no,default:NoXmlTag</InsuredNumber>
    </InsuranceInfo>
    <InfectionInfo>
      <!-- 感染症情報 -->
      <Infection detail="感染症情報,Code"/>
    </InfectionInfo>
    <AllergyInfo>
      <!-- アレルギー情報 -->
      <Allergy detail="アレルギー情報,Code"/>
    </AllergyInfo>
    <DrugAllergyInfo>
      <!-- 薬剤アレルギー情報 -->
      <Drug detail="薬剤アレルギー情報,Code"/>
    </DrugAllergyInfo>
  </PatientData>
</SsiData>
', '{"key": {"感染症情報": {"_DEFAULT": "all"}, "アレルギー情報": {"_DEFAULT": "all"}, "薬剤アレルギー情報": {"_DEFAULT": "all"}}, "dataset": {"sqlGroup1": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": -501051, "@patLastName": "$journal.pat_personal_main.pat_name", "@patFirstName": "$journal.pat_personal_main.pat_name", "@patLastNmKana": "$journal.pat_personal_main.pat_name_kana", "@patFirstNmKana": "$journal.pat_personal_main.pat_name_kana", "ExceptionMessage": "氏名が入力されていない。", "ExceptionCondition": "=1"}], "sqlGroup2": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": -502003, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "SKIPEND 死亡患者は更新されません。", "ExceptionCondition": "=1"}], "sqlGroup3": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "insertResult": "{@fnPatId:'''',@hospPatId:'''',@nkkPatId:'''',@facilityCd:'''',@patLastName:'''',@patFirstName:'''',@patLastNmKana:'''',@patFirstNmKana:'''',@patLastNmAlpha:'''',@patFirstNmAlpha:'''',@patBirthName:'''',@patBirthNmKana:'''',@patBirthNmAlpha:'''',@patBirthday:'''',@patSex:'''',@nationality:'''',@patBloodTypeAbo:'''',@patBloodTypeRh:'''',@patBloodTypeSerovar:'''',@inOutClass:'''',@isDie:'''',@dieCd:'''',@dieDate_Date:'''',@dialDiffComInfoValue:''[]'',@severityCd:'''',@transportCd:'''',@patContactInfoFlg:'''',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''[]'',@vendorContactInfoValue:''[]'',@insuranceInfoValue:''[]'',@primaryDiseaseCd:'''',@remoteMonitorService:'''',@remoteMonitorUserId:'''',@remoteMonitorUserPw:''''}", "ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"crud": "C", "kind": "0", "judge": "", "table": "pat_personal_main", "@tenki": "$journal.pat_unique.medical_hst_info.out_come", "ctl_no": "2", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": -501091, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "$journal.pat_personal_main.in_out_class", "@diseaseCode": "$journal.pat_personal_main.die_cd", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_name", "@dieDate_Date": "$journal.pat_personal_main.die_date", "@patLastNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeRh": "$journal.pat_personal_main.pat_blood_type_rh", "@patBloodTypeAbo": "$journal.pat_personal_main.pat_blood_type_abo", "@patContactInfo.tel1": "$journal.pat_personal_main.pat_contact_info.tel1", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address"}], "sqlGroup4": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_unique", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "updateResult": "{@hospPatId:''hosp_pat_id''}"}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_unique", "@tenki": "$journal.pat_unique.medical_hst_info.out_come", "ctl_no": "2", "sqlCode": -501081, "@dieDate": "$journal.pat_unique.medical_hst_info.out_come_date"}], "sqlGroup5": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_main_2", "ctl_no": "1", "sqlCode": -501001, "insertResult": "{@infectInfo.Cd:''''}", "@infectInfo.Cd": "$journal.detail.pat_main_2.infect_info.infection_cd", "ExceptionMessage": "感染症[@infectInfo.infectionCd]に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"crud": "C", "kind": "0", "judge": "", "table": "pat_main_2", "ctl_no": "2", "sqlCode": -501003, "@infectInfo.Cd": "$journal.detail.pat_main_2.infect_info.infection_cd", "@infectInfo.infectionName": "$journal.detail.pat_main_2.infect_info.infection_name"}], "sqlGroup6": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_unique", "ctl_no": "1", "sqlCode": -501011, "insertResult": "{@medicalHstInfo.diseaseCd:''''}", "ExceptionMessage": "病名[@medicalHstInfo.diseaseCd]に複数のデータが存在する。", "ExceptionCondition": "=N", "@medicalHstInfo.diseaseCd": "$journal.pat_unique.medical_hst_info.disease_cd", "@medicalHstInfo.diseaseName": "$journal.pat_unique.medical_hst_info.disease_name"}, {"crud": "C", "kind": "0", "judge": "", "table": "pat_unique", "ctl_no": "2", "sqlCode": -501013, "@medicalHstInfo.diseaseCd": "$journal.pat_unique.medical_hst_info.disease_cd", "@medicalHstInfo.diseaseName": "$journal.pat_unique.medical_hst_info.disease_name"}], "sqlGroup7": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_main", "ctl_no": "1", "sqlCode": -501021, "insertResult": "{@medicalCareInfo.wardCd:''''}", "ExceptionMessage": "病棟[@medicalCareInfo.wardCd]に複数のデータが存在する。", "ExceptionCondition": "=N", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd"}, {"crud": "C", "kind": "0", "judge": "", "table": "pat_main", "ctl_no": "2", "sqlCode": -501023, "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@medicalCareInfo.wardName": "$journal.pat_main.medical_care_info.ward_name"}], "sqlGroup8": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_main", "ctl_no": "1", "sqlCode": -501031, "insertResult": "{@medicalCareInfo.wardCd:''''}", "ExceptionMessage": "診療科[@medicalCareInfo.wardCd]に複数のデータが存在する。", "ExceptionCondition": "=N", "@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd"}, {"crud": "C", "kind": "0", "judge": "", "table": "pat_main", "ctl_no": "2", "sqlCode": -501033, "@medicalCareInfo.CourseName": "$journal.pat_main.medical_care_info.course_name", "@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd"}], "sqlGroup9": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_unique", "ctl_no": "1", "sqlCode": 1601, "insertResult": "{@patId:'''', @facilityCd:'''', @medicalHstInfoValue:''[]'', @inOutVisitHistoryInfoValue:''[]'', @physicalInfoFlg:'''', @physicalInfoValue:''[]''}"}, {"crud": "C", "kind": "0", "judge": "", "table": "pat_unique", "ctl_no": "2", "sqlCode": 1602}], "sqlGroup10": [{"crud": "S", "kind": "0", "type": "json", "judge": "", "table": "pat_unique", "ctl_no": "1", "sqlCode": 1701, "updateResult": "{@nextCtlNo2:''next_ctl_no_2'', @medicalHstInfoFlg:'''', @medicalHstInfoValue:''medical_hst_info'', @medicalHstInfo.memo:'''', @medicalHstInfo.ctlNo:'''', @medicalHstInfo.dieDate:'''', @medicalHstInfo.outCome:'''', @medicalHstInfo.courseCd:'''', @medicalHstInfo.isNotice:'''', @medicalHstInfo.diseaseCd:'''', @medicalHstInfo.dispOrder:'''', @medicalHstInfo.diseaseDay:'''', @medicalHstInfo.facilityCd:'''', @medicalHstInfo.diseaseDate:'''', @medicalHstInfo.diseaseYear:'''', @medicalHstInfo.isDiagnosed:'''', @medicalHstInfo.diagnosisDay:'''', @medicalHstInfo.diseaseMonth:'''', @medicalHstInfo.outComeDate:'''', @medicalHstInfo.courseIsFree:'''', @medicalHstInfo.diagnosisDate:'''', @medicalHstInfo.diagnosisYear:'''', @medicalHstInfo.diagnosisMonth:'''', @medicalHstInfo.isMainDisease:'''', @medicalHstInfo.diagnosticianCd:'''', @medicalHstInfo.diagnosisFacilityCd:'''', @medicalHstInfo.diagnosticianIsFree:'''', @medicalHstInfo.isConfirmationBiopsy:'''', @medicalHstInfo.diagnosisFacilityIsFree:'''', @medicalHstInfo.isDialysisUnderlyingDisease:''''}"}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_unique", "@tenki": "$journal.pat_unique.medical_hst_info.out_come", "ctl_no": "3", "sqlCode": -501100, "@dieCode": "$journal.pat_personal_main.die_cd", "@inOutClass": "$journal.pat_personal_main.in_out_class", "@diseaseCode": "$journal.pat_unique.medical_hst_info.disease_cd", "@medicalHstInfo.outCome": "$journal.pat_unique.medical_hst_info.out_come", "@medicalHstInfo.diseaseCd": "$journal.pat_unique.medical_hst_info.disease_cd", "@medicalHstInfo.diseaseDate": "$journal.pat_unique.medical_hst_info.disease_date", "@medicalHstInfo.outComeDate": "$journal.pat_unique.medical_hst_info.out_come_date"}], "sqlGroup11": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "updateResult": "{@fnPatId:''fn_pat_id'',@hospPatId:''hosp_pat_id'',@nkkPatId:''nkk_pat_id'',@facilityCd:''facility_cd'',@patLastName:''pat_last_name'',@patFirstName:''pat_first_name'',@patLastNmKana:''pat_last_name_kana'',@patFirstNmKana:''pat_first_name_kana'',@patLastNmAlpha:''pat_last_name_alpha'',@patFirstNmAlpha:''pat_first_name_alpha'',@patBirthName:''pat_birth_name'',@patBirthNmKana:''pat_birth_name_kana'',@patBirthNmAlpha:''pat_birth_name_alpha'',@patBirthday:''pat_birthday'',@patSex:''pat_sex'',@nationality:''nationality'',@patBloodTypeAbo:''pat_blood_type_abo'',@patBloodTypeRh:''pat_blood_type_rh'',@patBloodTypeSerovar:''pat_blood_type_serovar'',@inOutClass:''in_out_class'',@isDie:''is_die'',@dieCd:''die_cd'',@dieDate_Date:''die_date'',@dialDiffComInfoValue:''dial_diff_com_info'',@severityCd:''severity_cd'',@transportCd:''transport_cd'',@patContactInfoFlg:'''',@patContactInfoValue:''pat_contact_info'',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''other_contact_info'',@vendorContactInfoValue:''vendor_contact_info'',@insuranceInfoValue:''insurance_info'',@regDate:''reg_date'',@primaryDiseaseCd:''primary_disease_cd'',@remoteMonitorService:''remote_monitor_service'',@remoteMonitorUserId:''remote_monitor_user_id'',@remoteMonitorUserPw:''remote_monitor_user_pw''}", "ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_personal_main", "@tenki": "$journal.pat_unique.medical_hst_info.out_come", "ctl_no": "3", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": -501092, "@dieDate": "$journal.pat_personal_main.die_date", "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "$journal.pat_personal_main.in_out_class", "@diseaseCode": "$journal.pat_personal_main.die_cd", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_name", "@patLastNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeRh": "$journal.pat_personal_main.pat_blood_type_rh", "@patBloodTypeAbo": "$journal.pat_personal_main.pat_blood_type_abo", "@patContactInfo.tel1": "$journal.pat_personal_main.pat_contact_info.tel1", "@patContactInfo.memo1": "$journal.pat_personal_main.pat_contact_info.memo1", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address"}], "sqlGroup12": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_main", "ctl_no": "1", "sqlCode": 1201, "insertResult": "{@patId:'''',@facilityCd:'''',@isSame:'''',@isImplant:'''',@isInfect:'''',@isDiabetes:'''',@isBloodSugerExam:'''',@inOutCurrentState:'''',@inOutPlanState:'''',@inOutPlanDate_Date:'''',@patMemoInfoValue:''[]'',@additionInfoValue:''[]'',@chargeStaffInfoValue:''[]'',@patGroupInfoValue:''[]'',@tabooAllergyInfoValue:''[]'',@infectInfoValue:''[]'',@implantInfoValue:''[]'',@tareInfoValue:''{}'',@offWaterInfoValue:''{}'',@deviceSetInfoValue:''{}'',@acceptanceStatusInfoValue:''[]'',@isWheelChair:'''',@medicalCareInfoFlg:'''',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.patDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:'''',@schExtStatus:'''',@cardIdm:'''',@oldUpDate_Date:''''}", "updateResult": "{@patId:''pat_id'',@facilityCd:''facility_cd'',@isSame:''is_same'',@isImplant:''is_implant'',@isInfect:''is_infect'',@isDiabetes:''is_diabetes'',@isBloodSugerExam:''is_blood_suger_exam'',@inOutCurrentState:''in_out_current_state'',@inOutPlanState:''in_out_plan_state'',@inOutPlanDate_Date:''in_out_plan_date'',@patMemoInfoValue:''pat_memo_info'',@additionInfoValue:''addition_info'',@chargeStaffInfoValue:''charge_staff_info'',@patGroupInfoValue:''pat_group_info'',@tabooAllergyInfoValue:''taboo_allergy_info'',@infectInfoValue:''infect_info'',@implantInfoValue:''implant_info'',@tareInfoValue:''tare_info'',@offWaterInfoValue:''off_water_info'',@deviceSetInfoValue:''device_set_info'',@acceptanceStatusInfoValue:''acceptance_status_info'',@isWheelChair:''is_wheel_chair'',@medicalCareInfoFlg:'''',@medicalCareInfoValue:''medical_care_info'',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.patDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:''sch_ext_end_date'',@schExtStatus:''sch_ext_status'',@cardIdm:''card_idm'',@oldUpDate_Date:''old_up_date''}"}, {"crud": "C", "kind": "0", "judge": "", "table": "pat_main", "ctl_no": "2", "sqlCode": -501093, "@inOutClass": "$journal.pat_personal_main.in_out_class", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd", "@medicalCareInfo.dialysisStartDate": "$journal.pat_main.medical_care_info.dialysis_start_date"}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_main", "ctl_no": "3", "sqlCode": -501094, "@inOutClass": "$journal.pat_personal_main.in_out_class", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd", "@medicalCareInfo.dialysisStartDate": "$journal.pat_main.medical_care_info.dialysis_start_date"}], "sqlGroup13": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_insurance", "@ctlNo": "$journal.detail.pat_insurance.ctl_no", "ctl_no": "1", "sqlCode": 1301, "insertResult": "{@patId:''0'',@facilityCd:''0'',@ctlNo:'''',@fnPatId:'''',@insuClass:'''',@insuName:'''',@insuNmShort:'''',@insuInfoFlg:'''',@insuInfo.insuNo:'''',@insuInfo.insuPatName:'''',@insuInfo.insuPatNo:'''',@insuInfo.insuKbn:'''',@insuInfo.insuPatMark:'''',@insuInfo.ckiClass:'''',@insuInfo.kkiClass:'''',@insuInfo.undSix:'''',@insuInfo.futan-g:'''',@insuInfo.futan-n:'''',@insuPubInfoFlg:'''',@insuPubInfo.insuPubName:'''',@insuPubInfo.insuPubNo:'''',@insuPubInfo.insuPubPatNo:'''',@insuSetInfoFlg:'''',@insuSetInfo.insuCd:'''',@insuSetInfo.insuPub1Cd:'''',@insuSetInfo.insuPub2Cd:'''',@insuSetInfo.insuPub3Cd:'''',@insuSetInfo.insuPub4Cd:'''',@isSelected:'''',@isDisp:''1'',@coopCode:'''',@isCoop:'''',@startDate:'''',@endDate:'''',@checkDate:'''',@oldUpDate_Date:''''}", "updateResult": "{@patId:''pat_id'',@facilityCd:''facility_cd'',@ctlNo:''ctl_no'',@fnPatId:''fn_pat_id'',@insuClass:''insu_class'',@insuName:''insu_name'',@insuNmShort:''insu_name_short'',@insuInfoFlg:'''',@insuInfoValue:''insu_info'',@insuInfo.insuNo:'''',@insuInfo.insuPatName:'''',@insuInfo.insuPatNo:'''',@insuInfo.insuKbn:'''',@insuInfo.insuPatMark:'''',@insuInfo.ckiClass:'''',@insuInfo.kkiClass:'''',@insuInfo.undSix:'''',@insuInfo.futan-g:'''',@insuInfo.futan-n:'''',@insuPubInfoFlg:'''',@insuPubInfoValue:''insu_pub_info'',@insuPubInfo.insuPubName:'''',@insuPubInfo.insuPubNo:'''',@insuPubInfo.insuPubPatNo:'''',@insuSetInfoFlg:'''',@insuSetInfoValue:''insu_set_info'',@insuSetInfo.insuCd:'''',@insuSetInfo.insuPub1Cd:'''',@insuSetInfo.insuPub2Cd:'''',@insuSetInfo.insuPub3Cd:'''',@insuSetInfo.insuPub4Cd:'''',@isSelected:''is_selected'',@isDisp:''is_disp'',@coopCode:''coop_code'',@isCoop:''is_coop'',@startDate:''start_date'',@endDate:''end_date'',@checkDate:''check_date'',@oldUpDate_Date:''old_up_date''}"}, {"crud": "C", "kind": "0", "judge": "", "table": "pat_insurance", "@ctlNo": "$journal.detail.pat_insurance.ctl_no", "ctl_no": "2", "sqlCode": -501095, "@insuInfo.insuNo": "$journal.detail.pat_insurance.insu_info.insu_no", "@insuInfo.insuKbn": "$journal.detail.pat_insurance.insu_info.insu_kbn", "@insuInfo.insuPatNo": "$journal.detail.pat_insurance.insu_info.insu_pat_no", "@insuInfo.insuPatMark": "$journal.detail.pat_insurance.insu_info.insu_pat_mark"}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_insurance", "@ctlNo": "$journal.detail.pat_insurance.ctl_no", "ctl_no": "3", "sqlCode": -501096, "@insuInfo.insuNo": "$journal.detail.pat_insurance.insu_info.insu_no", "@insuInfo.insuKbn": "$journal.detail.pat_insurance.insu_info.insu_kbn", "@insuInfo.insuPatNo": "$journal.detail.pat_insurance.insu_info.insu_pat_no", "@insuInfo.insuPatMark": "$journal.detail.pat_insurance.insu_info.insu_pat_mark"}], "sqlGroup14": [{"crud": "S", "kind": "0", "type": "json", "judge": "", "table": "pat_main", "ctl_no": "1", "sqlCode": 1201, "updateResult": "{@nextCtlNo2:''next_ctl_no_2'', @chargeStaffInfoFlg:'''', @chargeStaffInfoValue:''charge_staff_info'', @chargeStaffInfo.ctlNo:'''', @chargeStaffInfo.dispOrder:'''', @chargeStaffInfo.staffCd:'''', @chargeStaffInfo.isMain:'''', @chargeStaffInfo.isCharge:'''', @chargeStaffInfo.isPuncture:''''}"}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_main", "ctl_no": "3", "sqlCode": -501097, "@chargeStaffInfo.doctorCd": "$journal.pat_main.charge_staff_info.doctor_cd", "@chargeStaffInfo.dialysisNurseCd": "$journal.pat_main.charge_staff_info.dialysis_nurse_cd", "@chargeStaffInfo.dialysisDoctorCd": "$journal.pat_main.charge_staff_info.dialysis_doctor_cd", "@chargeStaffInfo.admissionDoctorCd": "$journal.pat_main.charge_staff_info.admission_doctor_cd"}], "sqlGroup15": [{"crud": "S", "kind": "0", "type": "json", "judge": "", "table": "pat_main_1", "ctl_no": "1", "sqlCode": 1201, "updateResult": "{@nextCtlNo3:''next_ctl_no_3'', @tabooAllergyInfoFlg:'''', @tabooAllergyInfoValue:''taboo_allergy_info'', @tabooAllergyInfo.memo:'''', @tabooAllergyInfo.ctlNo:'''', @tabooAllergyInfo.content:'''', @tabooAllergyInfo.dispOrder:'''', @tabooAllergyInfo.categoryClass:'''', @tabooAllergyInfo.tabooAllergyCd:'''', @tabooAllergyInfo.tabooAllergyClass:''''}"}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_main_1", "ctl_no": "3", "sqlCode": -501098, "@tabooAllergyInfo.memo": "$journal.detail.pat_main_1.taboo_allergy_info.memo", "@tabooAllergyInfo.status": "$journal.detail.pat_main_1.taboo_allergy_info.status", "@tabooAllergyInfo.content": "$journal.detail.pat_main_1.taboo_allergy_info.content", "@tabooAllergyInfo.tabooAllergyCd": "$journal.detail.pat_main_1.taboo_allergy_info.taboo_allergy_cd"}], "sqlGroup16": [{"crud": "S", "kind": "0", "type": "json", "judge": "", "table": "pat_main_4", "ctl_no": "1", "sqlCode": 1201, "updateResult": "{@nextCtlNo3:''next_ctl_no_3'', @tabooAllergyInfoFlg:'''', @tabooAllergyInfoValue:''taboo_allergy_info'', @tabooAllergyInfo.memo:'''', @tabooAllergyInfo.ctlNo:'''', @tabooAllergyInfo.content:'''', @tabooAllergyInfo.dispOrder:'''', @tabooAllergyInfo.categoryClass:'''', @tabooAllergyInfo.tabooAllergyCd:'''', @tabooAllergyInfo.tabooAllergyClass:''''}"}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_main_4", "ctl_no": "3", "sqlCode": -501098, "@tabooAllergyInfo.memo": "$journal.detail.pat_main_4.taboo_allergy_info.memo", "@tabooAllergyInfo.status": "$journal.detail.pat_main_4.taboo_allergy_info.status", "@tabooAllergyInfo.content": "$journal.detail.pat_main_4.taboo_allergy_info.content", "@tabooAllergyInfo.tabooAllergyCd": "$journal.detail.pat_main_4.taboo_allergy_info.taboo_allergy_cd"}], "sqlGroup17": [{"crud": "S", "kind": "0", "type": "json", "judge": "", "table": "pat_main_2", "ctl_no": "1", "sqlCode": 1201, "updateResult": "{@nextCtlNo4:''next_ctl_no_4'', @infectInfoFlg:'''', @infectInfoValue:''infect_info'', @infectInfo.ctlNo:'''', @infectInfo.infectionCd:'''', @infectInfo.infect:'''', @infectInfo.examDate:'''', @infectInfo.upDate:''''}"}, {"Note": "json場合、[D]の設定が必要です。しかし、感染症情報をクリアしません。judgeに[crud#=#NG]を設定する。", "crud": "D", "kind": "0", "judge": "", "table": "pat_main_2", "ctl_no": "2", "sqlCode": 7205, "@infect_info.infection_cd": "$journal.detail.pat_main_2.infect_info.infection_cd"}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_main_2", "ctl_no": "3", "sqlCode": -501099, "@infectInfo.Cd": "$journal.detail.pat_main_2.infect_info.infection_cd", "@infectInfo.infect": "$journal.detail.pat_main_2.infect_info.infect", "@infectInfo.examDate": "$journal.detail.pat_main_2.infect_info.exam_date", "@infectInfo.infectionCd": "$journal.detail.pat_main_2.infect_info.infection_cd"}], "sqlGroup18": [{"crud": "S", "kind": "0", "type": "json", "judge": "", "table": "pat_unique_1", "ctl_no": "1", "sqlCode": 1701, "updateResult": "{@nextCtlNo1:''next_ctl_no_1'', @physicalInfoFlg:'''', @physicalInfoValue:''physical_info'', @physicalInfo.ctlNo:'''', @physicalInfo.examDate:'''', @physicalInfo.orderClass:'''', @physicalInfo.height:'''', @physicalInfo.ctrWeight:'''', @physicalInfo.breastDia:'''', @physicalInfo.chestDia:'''', @physicalInfo.ctr:'''', @physicalInfo.dw:'''', @physicalInfo.indicatorCd:'''', @physicalInfo.indicatorStartDate:'''', @physicalInfo.memo:'''', @physicalInfo.preScaleUpper:'''', @physicalInfo.preScaleLower:'''', @physicalInfo.targetWeight:'''', @physicalInfo.facilityCd:''''}"}, {"Note": "json場合、[D]の設定が必要です。しかし、身体情報をクリアしません。judgeに[crud#=#NG]を設定する。", "crud": "D", "kind": "1", "judge": "$journal.const.crud#=#NG", "table": "pat_unique_1", "ctl_no": "2", "sqlCode": 0}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_unique_1", "ctl_no": "3", "sqlCode": -501101, "@physicalInfo.ctr": "$journal.detail.pat_unique_1.physical_info.ctr", "@physicalInfo.ctr2": "$journal.detail.pat_unique_1.physical_info.ctr_2", "@physicalInfo.examDate": "$journal.detail.pat_unique_1.physical_info.exam_date"}]}, "CoopIniConvUtil": {"$journal.pat_personal_main.pat_sex": "CONV_SEX_TO_FNW", "$journal.pat_personal_main.in_out_class": "CONV_INOUT_TO_FNW", "$journal.pat_personal_main.pat_blood_type_rh": "CONV_BLOOD_RH_TO_FNW", "$journal.detail.pat_main_2.infect_info.infect": "CONV_INFECTION_TO_FNW", "$journal.pat_personal_main.pat_blood_type_abo": "CONV_BLOOD_ABO_TO_FNW", "$journal.detail.pat_insurance.insu_info.insu_kbn": "CONV_INSU_KBN_TO_FNW", "$journal.detail.pat_main_1.taboo_allergy_info.status": "CONV_INFECTION_TO_FNW", "$journal.detail.pat_main_4.taboo_allergy_info.status": "CONV_INFECTION_TO_FNW"}}'::jsonb, '1', '0', -1, '2020-05-07 12:00:00.000', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5040001, 'S_hosp', 'ind_dial', '', 'S', 'cre', 'xml', 'SSI', 'SSI', '予定送信', '1', '<SsiData Type="DIALYSISPLAN">
  <PlanData>
    <PatientID>dataset:-500001.hosp_pat_id8</PatientID>
    <DIALYSIS_DATE>dataset:-503000.dialysis_date</DIALYSIS_DATE>
    <DIALYSIS_NO>0</DIALYSIS_NO>
    <BED_NO>dataset:-503000.bed_cd1</BED_NO>
    <BED_NAME>dataset:-503000.bed_name</BED_NAME>
    <KUR_CD>dataset:-503000.kur_cd1</KUR_CD>
    <KUR_NAME>dataset:-503000.kur_name</KUR_NAME>
    <VALID>0</VALID>
    <DIALYSIS_TIME>dataset:-503000.dialysis_time_m</DIALYSIS_TIME>
    <DIALYSIS_COND info="透析条件情報">
      <COND_INFO CTL_NO="dataset:-501106.e01" _sqlCode="-501106">
        <DIALYSIS_ITEM_NAME>dataset:-501106.e02</DIALYSIS_ITEM_NAME>
        <VALUE>dataset:-501106.e03</VALUE>
        <VALUE_NAME>dataset:-501106.e04</VALUE_NAME>
        <UNIT>dataset:-501106.e05</UNIT>
      </COND_INFO>
    </DIALYSIS_COND>
    <DIALYSIS_EQUIP info="医材詳細">
      <EQUIP_INFO CTL_NO="dataset:-501104.cost_no" _sqlCode="-501104">
        <EQUIP_CD>dataset:-501104.e01</EQUIP_CD>
        <EQUIP_NAME>dataset:-501104.e02</EQUIP_NAME>
        <EQUIP_CLASS_NAME>dataset:-501104.e03</EQUIP_CLASS_NAME>
        <PUNCTURE_CLASS>dataset:-501104.e04</PUNCTURE_CLASS>
        <AMOUNT>dataset:-501104.e05</AMOUNT>
        <UNIT>dataset:-501104.e06</UNIT>
      </EQUIP_INFO>
    </DIALYSIS_EQUIP>
    <DIALYSIS_MEDI info="薬剤詳細">
      <MEDI_INFO CTL_NO="dataset:-501105.cost_no" _sqlCode="-501105">
        <MEDICINE_CD>dataset:-501105.e01</MEDICINE_CD>
        <MEDICINE_NAME>dataset:-501105.e02</MEDICINE_NAME>
        <MEDI_CLASS_NAME>dataset:-501105.e03</MEDI_CLASS_NAME>
        <AMOUNT>dataset:-501105.e04</AMOUNT>
        <UNIT>dataset:-501105.e05</UNIT>
        <PROCEDURE_CD>dataset:-501105.e06</PROCEDURE_CD>
        <PROCEDURE_NAME>dataset:-501105.e07</PROCEDURE_NAME>
      </MEDI_INFO>
    </DIALYSIS_MEDI>
  </PlanData>
</SsiData>
', '{"dataset": [{"patId": "patId", "sqlCode": -500001}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -503000, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -501104, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -501105, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -501106}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99989}}'::jsonb, '1', '0', 4, '2020-05-25 11:02:55.825', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5040002, 'S_hosp', 'ind_dial', '', 'S', 'upd', 'xml', 'SSI', 'SSI', '予定送信', '1', '<SsiData Type="DIALYSISPLAN">
  <PlanData>
    <PatientID>dataset:-500001.hosp_pat_id8</PatientID>
    <DIALYSIS_DATE>dataset:-503000.dialysis_date</DIALYSIS_DATE>
    <DIALYSIS_NO>0</DIALYSIS_NO>
    <BED_NO>dataset:-503000.bed_cd1</BED_NO>
    <BED_NAME>dataset:-503000.bed_name</BED_NAME>
    <KUR_CD>dataset:-503000.kur_cd1</KUR_CD>
    <KUR_NAME>dataset:-503000.kur_name</KUR_NAME>
    <VALID>1</VALID>
    <DIALYSIS_TIME>dataset:-503000.dialysis_time_m</DIALYSIS_TIME>
    <DIALYSIS_COND info="透析条件情報">
      <COND_INFO CTL_NO="dataset:-501106.e01" _sqlCode="-501106">
        <DIALYSIS_ITEM_NAME>dataset:-501106.e02</DIALYSIS_ITEM_NAME>
        <VALUE>dataset:-501106.e03</VALUE>
        <VALUE_NAME>dataset:-501106.e04</VALUE_NAME>
        <UNIT>dataset:-501106.e05</UNIT>
      </COND_INFO>
    </DIALYSIS_COND>
    <DIALYSIS_EQUIP info="医材詳細">
      <EQUIP_INFO CTL_NO="dataset:-501104.cost_no" _sqlCode="-501104">
        <EQUIP_CD>dataset:-501104.e01</EQUIP_CD>
        <EQUIP_NAME>dataset:-501104.e02</EQUIP_NAME>
        <EQUIP_CLASS_NAME>dataset:-501104.e03</EQUIP_CLASS_NAME>
        <PUNCTURE_CLASS>dataset:-501104.e04</PUNCTURE_CLASS>
        <AMOUNT>dataset:-501104.e05</AMOUNT>
        <UNIT>dataset:-501104.e06</UNIT>
      </EQUIP_INFO>
    </DIALYSIS_EQUIP>
    <DIALYSIS_MEDI info="薬剤詳細">
      <MEDI_INFO CTL_NO="dataset:-501105.cost_no" _sqlCode="-501105">
        <MEDICINE_CD>dataset:-501105.e01</MEDICINE_CD>
        <MEDICINE_NAME>dataset:-501105.e02</MEDICINE_NAME>
        <MEDI_CLASS_NAME>dataset:-501105.e03</MEDI_CLASS_NAME>
        <AMOUNT>dataset:-501105.e04</AMOUNT>
        <UNIT>dataset:-501105.e05</UNIT>
        <PROCEDURE_CD>dataset:-501105.e06</PROCEDURE_CD>
        <PROCEDURE_NAME>dataset:-501105.e07</PROCEDURE_NAME>
      </MEDI_INFO>
    </DIALYSIS_MEDI>
  </PlanData>
</SsiData>
', '{"dataset": [{"patId": "patId", "sqlCode": -500001}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -503000, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -501104, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -501105, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -501106}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99989}}'::jsonb, '1', '0', 4, '2020-05-25 11:02:55.825', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5040003, 'S_hosp', 'ind_dial', '', 'S', 'del', 'xml', 'SSI', 'SSI', '予定送信', '1', '<SsiData Type="DIALYSISPLAN">
  <PlanData>
    <PatientID>dataset:-500001.hosp_pat_id8</PatientID>
    <DIALYSIS_DATE>dataset:-503000.dialysis_date</DIALYSIS_DATE>
    <DIALYSIS_NO>0</DIALYSIS_NO>
    <BED_NO>dataset:-503000.bed_cd1</BED_NO>
    <BED_NAME>dataset:-503000.bed_name</BED_NAME>
    <KUR_CD>dataset:-503000.kur_cd1</KUR_CD>
    <KUR_NAME>dataset:-503000.kur_name</KUR_NAME>
    <VALID>9</VALID>
    <DIALYSIS_TIME>dataset:-503000.dialysis_time_m</DIALYSIS_TIME>
    <DIALYSIS_COND info="透析条件情報">
      <COND_INFO CTL_NO="dataset:-501106.e01" _sqlCode="-501106">
        <DIALYSIS_ITEM_NAME>dataset:-501106.e02</DIALYSIS_ITEM_NAME>
        <VALUE>dataset:-501106.e03</VALUE>
        <VALUE_NAME>dataset:-501106.e04</VALUE_NAME>
        <UNIT>dataset:-501106.e05</UNIT>
      </COND_INFO>
    </DIALYSIS_COND>
    <DIALYSIS_EQUIP info="医材詳細">
      <EQUIP_INFO CTL_NO="dataset:-501104.cost_no" _sqlCode="-501104">
        <EQUIP_CD>dataset:-501104.e01</EQUIP_CD>
        <EQUIP_NAME>dataset:-501104.e02</EQUIP_NAME>
        <EQUIP_CLASS_NAME>dataset:-501104.e03</EQUIP_CLASS_NAME>
        <PUNCTURE_CLASS>dataset:-501104.e04</PUNCTURE_CLASS>
        <AMOUNT>dataset:-501104.e05</AMOUNT>
        <UNIT>dataset:-501104.e06</UNIT>
      </EQUIP_INFO>
    </DIALYSIS_EQUIP>
    <DIALYSIS_MEDI info="薬剤詳細">
      <MEDI_INFO CTL_NO="dataset:-501105.cost_no" _sqlCode="-501105">
        <MEDICINE_CD>dataset:-501105.e01</MEDICINE_CD>
        <MEDICINE_NAME>dataset:-501105.e02</MEDICINE_NAME>
        <MEDI_CLASS_NAME>dataset:-501105.e03</MEDI_CLASS_NAME>
        <AMOUNT>dataset:-501105.e04</AMOUNT>
        <UNIT>dataset:-501105.e05</UNIT>
        <PROCEDURE_CD>dataset:-501105.e06</PROCEDURE_CD>
        <PROCEDURE_NAME>dataset:-501105.e07</PROCEDURE_NAME>
      </MEDI_INFO>
    </DIALYSIS_MEDI>
  </PlanData>
</SsiData>
', '{"dataset": [{"patId": "patId", "sqlCode": -500001}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -503000, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -501104, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -501105, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -501106}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99989}}'::jsonb, '1', '0', 4, '2020-05-25 11:02:55.825', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5070001, 'S_hosp', 'rst_dial', '', 'S', 'cre', 'xml', 'SSI', 'SSI', '実績送信', '1', '<SsiData Type="DIALYSISRST">
  <RSTData>
    <PatientID>dataset:-500001.hosp_pat_id8</PatientID>
    <DIALYSIS_DATE>dataset:-504000.treat_date</DIALYSIS_DATE>
    <DIALYSIS_NO>dataset:-504000.ord_no</DIALYSIS_NO>
    <BED_NO>dataset:-504000.bed_cd1</BED_NO>
    <BED_NAME>dataset:-504000.bed_name</BED_NAME>
    <KUR_CD>dataset:-504000.kur_cd1</KUR_CD>
    <KUR_NAME>dataset:-504000.kur_name</KUR_NAME>
    <VALID>0</VALID>
    <DEVICE_NO>dataset:-504000.machine_no</DEVICE_NO>
    <DEVICE_NAME>dataset:-504000.machine_name</DEVICE_NAME>
    <START_DATE>dataset:-504000.start_date</START_DATE>
    <END_DATE>dataset:-504000.end_date</END_DATE>
    <DIALYSIS_TIME>dataset:-504000.running_time_cal</DIALYSIS_TIME>
    <WEIGHT_BEFORE>dataset:-504000.weight_before</WEIGHT_BEFORE>
    <WEIGHT_AFTER>dataset:-504000.weight_after</WEIGHT_AFTER>
    <BP_BEFORE_MAX>dataset:-35.bp_high</BP_BEFORE_MAX>
    <BP_BEFORE_MIN>dataset:-35.bp_low</BP_BEFORE_MIN>
    <BP_AFTER_MAX>dataset:-36.bp_high</BP_AFTER_MAX>
    <BP_AFTER_MIN>dataset:-36.bp_low</BP_AFTER_MIN>
    <PULSE_BEFORE>dataset:-35.pulse</PULSE_BEFORE>
    <PULSE_AFTER>dataset:-36.pulse</PULSE_AFTER>
    <CHARGE_1_CODE>dataset:-504000.charge1_id</CHARGE_1_CODE>
    <CHARGE_1_NAME>dataset:-504000.charge1_name</CHARGE_1_NAME>
    <CHARGE_2_CODE>dataset:-504000.charge2_id</CHARGE_2_CODE>
    <CHARGE_2_NAME>dataset:-504000.charge2_name</CHARGE_2_NAME>
    <PUNCTURE_1_CODE>dataset:-504000.puncture1_id</PUNCTURE_1_CODE>
    <PUNCTURE_1_NAME>dataset:-504000.puncture1_name</PUNCTURE_1_NAME>
    <PUNCTURE_2_CODE>dataset:-504000.puncture2_id</PUNCTURE_2_CODE>
    <PUNCTURE_2_NAME>dataset:-504000.puncture2_name</PUNCTURE_2_NAME>
    <COLLECT_1_CODE>dataset:-504000.return1_id</COLLECT_1_CODE>
    <COLLECT_1_NAME>dataset:-504000.return1_name</COLLECT_1_NAME>
    <COLLECT_2_CODE>dataset:-504000.return2_id</COLLECT_2_CODE>
    <COLLECT_2_NAME>dataset:-504000.return2_name</COLLECT_2_NAME>
    <DISPOSE info="処置、検査情報">
      <DISPOSE_INFO DISPOSE_CTL_NO="dataset:-301.cost_no" _sqlCode="-301">
        <TENCD>dataset:-301.e01</TENCD>
        <TKJNAM>dataset:-301.e02</TKJNAM>
        <AMOUNT>dataset:-301.e03</AMOUNT>
        <UNIT>dataset:-301.e04</UNIT>
      </DISPOSE_INFO>
    </DISPOSE>
    <DIALYSIS_COND info="透析条件情報">
      <COND_INFO CTL_NO="dataset:-504001.e01" _sqlCode="-504001">
        <DIALYSIS_ITEM_NAME>dataset:-504001.e02</DIALYSIS_ITEM_NAME>
        <VALUE>dataset:-504001.e03</VALUE>
        <VALUE_NAME>dataset:-504001.e04</VALUE_NAME>
        <UNIT>dataset:-504001.e05</UNIT>
      </COND_INFO>
    </DIALYSIS_COND>
    <DIALYSIS_EQUIP info="医材詳細">
      <EQUIP_INFO CTL_NO="dataset:-501102.cost_no" _sqlCode="-501102">
        <EQUIP_CD>dataset:-501102.e01</EQUIP_CD>
        <EQUIP_NAME>dataset:-501102.e02</EQUIP_NAME>
        <EQUIP_CLASS_NAME>dataset:-501102.e03</EQUIP_CLASS_NAME>
        <PUNCTURE_CLASS>dataset:-501102.e04</PUNCTURE_CLASS>
        <AMOUNT>dataset:-501102.e05</AMOUNT>
        <UNIT>dataset:-501102.e06</UNIT>
      </EQUIP_INFO>
    </DIALYSIS_EQUIP>
    <DIALYSIS_MEDI info="薬剤詳細">
      <MEDI_INFO CTL_NO="dataset:-501103.cost_no" _sqlCode="-501103">
        <MEDICINE_CD>dataset:-501103.e01</MEDICINE_CD>
        <MEDICINE_NAME>dataset:-501103.e02</MEDICINE_NAME>
        <MEDI_CLASS_NAME>dataset:-501103.e03</MEDI_CLASS_NAME>
        <AMOUNT>dataset:-501103.e04</AMOUNT>
        <UNIT>dataset:-501103.e05</UNIT>
        <PROCEDURE_CD>dataset:-501103.e06</PROCEDURE_CD>
        <PROCEDURE_NAME>dataset:-501103.e07</PROCEDURE_NAME>
      </MEDI_INFO>
    </DIALYSIS_MEDI>
  </RSTData>
</SsiData>
', '{"dataset": [{"patId": "patId", "sqlCode": -500001}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -504002, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -504000, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -35}, {"ordNo": "ordNo", "sqlCode": -36}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -301, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -501102, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -501103, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -504001}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99988}}'::jsonb, '1', '0', -1, '2020-05-22 09:38:28.418', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5070002, 'S_hosp', 'rst_dial', '', 'S', 'upd', 'xml', 'SSI', 'SSI', '実績送信', '1', '<SsiData Type="DIALYSISRST">
  <RSTData>
    <PatientID>dataset:-500001.hosp_pat_id8</PatientID>
    <DIALYSIS_DATE>dataset:-504000.treat_date</DIALYSIS_DATE>
    <DIALYSIS_NO>dataset:-504000.ord_no</DIALYSIS_NO>
    <BED_NO>dataset:-504000.bed_cd1</BED_NO>
    <BED_NAME>dataset:-504000.bed_name</BED_NAME>
    <KUR_CD>dataset:-504000.kur_cd1</KUR_CD>
    <KUR_NAME>dataset:-504000.kur_name</KUR_NAME>
    <VALID>1</VALID>
    <DEVICE_NO>dataset:-504000.machine_no</DEVICE_NO>
    <DEVICE_NAME>dataset:-504000.machine_name</DEVICE_NAME>
    <START_DATE>dataset:-504000.start_date</START_DATE>
    <END_DATE>dataset:-504000.end_date</END_DATE>
    <DIALYSIS_TIME>dataset:-504000.running_time_cal</DIALYSIS_TIME>
    <WEIGHT_BEFORE>dataset:-504000.weight_before</WEIGHT_BEFORE>
    <WEIGHT_AFTER>dataset:-504000.weight_after</WEIGHT_AFTER>
    <BP_BEFORE_MAX>dataset:-35.bp_high</BP_BEFORE_MAX>
    <BP_BEFORE_MIN>dataset:-35.bp_low</BP_BEFORE_MIN>
    <BP_AFTER_MAX>dataset:-36.bp_high</BP_AFTER_MAX>
    <BP_AFTER_MIN>dataset:-36.bp_low</BP_AFTER_MIN>
    <PULSE_BEFORE>dataset:-35.pulse</PULSE_BEFORE>
    <PULSE_AFTER>dataset:-36.pulse</PULSE_AFTER>
    <CHARGE_1_CODE>dataset:-504000.charge1_id</CHARGE_1_CODE>
    <CHARGE_1_NAME>dataset:-504000.charge1_name</CHARGE_1_NAME>
    <CHARGE_2_CODE>dataset:-504000.charge2_id</CHARGE_2_CODE>
    <CHARGE_2_NAME>dataset:-504000.charge2_name</CHARGE_2_NAME>
    <PUNCTURE_1_CODE>dataset:-504000.puncture1_id</PUNCTURE_1_CODE>
    <PUNCTURE_1_NAME>dataset:-504000.puncture1_name</PUNCTURE_1_NAME>
    <PUNCTURE_2_CODE>dataset:-504000.puncture2_id</PUNCTURE_2_CODE>
    <PUNCTURE_2_NAME>dataset:-504000.puncture2_name</PUNCTURE_2_NAME>
    <COLLECT_1_CODE>dataset:-504000.return1_id</COLLECT_1_CODE>
    <COLLECT_1_NAME>dataset:-504000.return1_name</COLLECT_1_NAME>
    <COLLECT_2_CODE>dataset:-504000.return2_id</COLLECT_2_CODE>
    <COLLECT_2_NAME>dataset:-504000.return2_name</COLLECT_2_NAME>
    <DISPOSE info="処置、検査情報">
      <DISPOSE_INFO DISPOSE_CTL_NO="dataset:-301.cost_no" _sqlCode="-301">
        <TENCD>dataset:-301.e01</TENCD>
        <TKJNAM>dataset:-301.e02</TKJNAM>
        <AMOUNT>dataset:-301.e03</AMOUNT>
        <UNIT>dataset:-301.e04</UNIT>
      </DISPOSE_INFO>
    </DISPOSE>
    <DIALYSIS_COND info="透析条件情報">
      <COND_INFO CTL_NO="dataset:-504001.e01" _sqlCode="-504001">
        <DIALYSIS_ITEM_NAME>dataset:-504001.e02</DIALYSIS_ITEM_NAME>
        <VALUE>dataset:-504001.e03</VALUE>
        <VALUE_NAME>dataset:-504001.e04</VALUE_NAME>
        <UNIT>dataset:-504001.e05</UNIT>
      </COND_INFO>
    </DIALYSIS_COND>
    <DIALYSIS_EQUIP info="医材詳細">
      <EQUIP_INFO CTL_NO="dataset:-501102.cost_no" _sqlCode="-501102">
        <EQUIP_CD>dataset:-501102.e01</EQUIP_CD>
        <EQUIP_NAME>dataset:-501102.e02</EQUIP_NAME>
        <EQUIP_CLASS_NAME>dataset:-501102.e03</EQUIP_CLASS_NAME>
        <PUNCTURE_CLASS>dataset:-501102.e04</PUNCTURE_CLASS>
        <AMOUNT>dataset:-501102.e05</AMOUNT>
        <UNIT>dataset:-501102.e06</UNIT>
      </EQUIP_INFO>
    </DIALYSIS_EQUIP>
    <DIALYSIS_MEDI info="薬剤詳細">
      <MEDI_INFO CTL_NO="dataset:-501103.cost_no" _sqlCode="-501103">
        <MEDICINE_CD>dataset:-501103.e01</MEDICINE_CD>
        <MEDICINE_NAME>dataset:-501103.e02</MEDICINE_NAME>
        <MEDI_CLASS_NAME>dataset:-501103.e03</MEDI_CLASS_NAME>
        <AMOUNT>dataset:-501103.e04</AMOUNT>
        <UNIT>dataset:-501103.e05</UNIT>
        <PROCEDURE_CD>dataset:-501103.e06</PROCEDURE_CD>
        <PROCEDURE_NAME>dataset:-501103.e07</PROCEDURE_NAME>
      </MEDI_INFO>
    </DIALYSIS_MEDI>
  </RSTData>
</SsiData>
', '{"dataset": [{"patId": "patId", "sqlCode": -500001}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -504000, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -35}, {"ordNo": "ordNo", "sqlCode": -36}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -301, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -501102, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -501103, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -504001}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99988}}'::jsonb, '1', '0', -1, '2020-05-22 09:38:28.418', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5070003, 'S_hosp', 'rst_dial', '', 'S', 'del', 'xml', 'SSI', 'SSI', '実績送信', '1', '<SsiData Type="DIALYSISRST">
  <RSTData>
    <PatientID>dataset:-500001.hosp_pat_id8</PatientID>
    <DIALYSIS_DATE>dataset:-504000.treat_date</DIALYSIS_DATE>
    <DIALYSIS_NO>dataset:-504000.ord_no</DIALYSIS_NO>
    <BED_NO>dataset:-504000.bed_cd1</BED_NO>
    <BED_NAME>dataset:-504000.bed_name</BED_NAME>
    <KUR_CD>dataset:-504000.kur_cd1</KUR_CD>
    <KUR_NAME>dataset:-504000.kur_name</KUR_NAME>
    <VALID>9</VALID>
    <DEVICE_NO>dataset:-504000.machine_no</DEVICE_NO>
    <DEVICE_NAME>dataset:-504000.machine_name</DEVICE_NAME>
    <START_DATE>dataset:-504000.start_date</START_DATE>
    <END_DATE>dataset:-504000.end_date</END_DATE>
    <DIALYSIS_TIME>dataset:-504000.running_time_cal</DIALYSIS_TIME>
    <WEIGHT_BEFORE>dataset:-504000.weight_before</WEIGHT_BEFORE>
    <WEIGHT_AFTER>dataset:-504000.weight_after</WEIGHT_AFTER>
    <BP_BEFORE_MAX>dataset:-35.bp_high</BP_BEFORE_MAX>
    <BP_BEFORE_MIN>dataset:-35.bp_low</BP_BEFORE_MIN>
    <BP_AFTER_MAX>dataset:-36.bp_high</BP_AFTER_MAX>
    <BP_AFTER_MIN>dataset:-36.bp_low</BP_AFTER_MIN>
    <PULSE_BEFORE>dataset:-35.pulse</PULSE_BEFORE>
    <PULSE_AFTER>dataset:-36.pulse</PULSE_AFTER>
    <CHARGE_1_CODE>dataset:-504000.charge1_id</CHARGE_1_CODE>
    <CHARGE_1_NAME>dataset:-504000.charge1_name</CHARGE_1_NAME>
    <CHARGE_2_CODE>dataset:-504000.charge2_id</CHARGE_2_CODE>
    <CHARGE_2_NAME>dataset:-504000.charge2_name</CHARGE_2_NAME>
    <PUNCTURE_1_CODE>dataset:-504000.puncture1_id</PUNCTURE_1_CODE>
    <PUNCTURE_1_NAME>dataset:-504000.puncture1_name</PUNCTURE_1_NAME>
    <PUNCTURE_2_CODE>dataset:-504000.puncture2_id</PUNCTURE_2_CODE>
    <PUNCTURE_2_NAME>dataset:-504000.puncture2_name</PUNCTURE_2_NAME>
    <COLLECT_1_CODE>dataset:-504000.return1_id</COLLECT_1_CODE>
    <COLLECT_1_NAME>dataset:-504000.return1_name</COLLECT_1_NAME>
    <COLLECT_2_CODE>dataset:-504000.return2_id</COLLECT_2_CODE>
    <COLLECT_2_NAME>dataset:-504000.return2_name</COLLECT_2_NAME>
    <DISPOSE info="処置、検査情報">
      <DISPOSE_INFO DISPOSE_CTL_NO="dataset:-301.cost_no" _sqlCode="-301">
        <TENCD>dataset:-301.e01</TENCD>
        <TKJNAM>dataset:-301.e02</TKJNAM>
        <AMOUNT>dataset:-301.e03</AMOUNT>
        <UNIT>dataset:-301.e04</UNIT>
      </DISPOSE_INFO>
    </DISPOSE>
    <DIALYSIS_COND info="透析条件情報">
      <COND_INFO CTL_NO="dataset:-504001.e01" _sqlCode="-504001">
        <DIALYSIS_ITEM_NAME>dataset:-504001.e02</DIALYSIS_ITEM_NAME>
        <VALUE>dataset:-504001.e03</VALUE>
        <VALUE_NAME>dataset:-504001.e04</VALUE_NAME>
        <UNIT>dataset:-504001.e05</UNIT>
      </COND_INFO>
    </DIALYSIS_COND>
    <DIALYSIS_EQUIP info="医材詳細">
      <EQUIP_INFO CTL_NO="dataset:-501102.cost_no" _sqlCode="-501102">
        <EQUIP_CD>dataset:-501102.e01</EQUIP_CD>
        <EQUIP_NAME>dataset:-501102.e02</EQUIP_NAME>
        <EQUIP_CLASS_NAME>dataset:-501102.e03</EQUIP_CLASS_NAME>
        <PUNCTURE_CLASS>dataset:-501102.e04</PUNCTURE_CLASS>
        <AMOUNT>dataset:-501102.e05</AMOUNT>
        <UNIT>dataset:-501102.e06</UNIT>
      </EQUIP_INFO>
    </DIALYSIS_EQUIP>
    <DIALYSIS_MEDI info="薬剤詳細">
      <MEDI_INFO CTL_NO="dataset:-501103.cost_no" _sqlCode="-501103">
        <MEDICINE_CD>dataset:-501103.e01</MEDICINE_CD>
        <MEDICINE_NAME>dataset:-501103.e02</MEDICINE_NAME>
        <MEDI_CLASS_NAME>dataset:-501103.e03</MEDI_CLASS_NAME>
        <AMOUNT>dataset:-501103.e04</AMOUNT>
        <UNIT>dataset:-501103.e05</UNIT>
        <PROCEDURE_CD>dataset:-501103.e06</PROCEDURE_CD>
        <PROCEDURE_NAME>dataset:-501103.e07</PROCEDURE_NAME>
      </MEDI_INFO>
    </DIALYSIS_MEDI>
  </RSTData>
</SsiData>
', '{"dataset": [{"patId": "patId", "sqlCode": -500001}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -504002, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -504000, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -35}, {"ordNo": "ordNo", "sqlCode": -36}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -301, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -501102, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -501103, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -504001}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99988}}'::jsonb, '1', '0', -1, '2020-05-22 09:38:28.418', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5170001, 'S_hosp', 'karte_ord', '', 'S', 'cre', 'xml', 'SSI', 'SSI', 'karte', '1', '<SsiData Type="KARTE_NOTIFY">
  <NotifyDate>$SYSDATE yyyyMMdd</NotifyDate>
  <!-- yyyyMMdd,yyyy/MM/dd,yyyy-MM-dd -->
  <NotifyTime>$SYSTIME HHmmss</NotifyTime>
  <!-- HHmmssSSS,HHmmss,HH:mm:ss.SSS,HH:mm:ss -->
  <Karte>
    <PatientID>dataset:-500001.hosp_pat_id8</PatientID>
    <AccessionNumber>dataset:-505000.ord_no12</AccessionNumber>
    <OperateMode>NW</OperateMode>
    <Class>dataset:-505000.karte_class</Class>
    <Nyuugai>dataset:-505000.in_out_s</Nyuugai>
    <SnkCode>dataset:-505000.course_cd</SnkCode>
    <Syosaisin/>
    <Importance/>
    <InsuranceNo/>
    <SubTitle/>
    <MakeUser UserID="auth_id:-505000.user_id">staff_name:-505000.user_id</MakeUser>
    <MakeDate>dataset:-505000.start_date8</MakeDate>
    <MakeTime>dataset:-505000.start_date6</MakeTime>
    <InpUser UserID="auth_id:-505000.user_id">staff_name:-505000.user_id</InpUser>
    <InpDate>dataset:-505000.inp_date</InpDate>
    <InpTime>dataset:-505000.inp_time</InpTime>
    <Document>
      <Content>#karte_content#</Content>
    </Document>
  </Karte>
</SsiData>
', '{"dataset": [{"patId": "patId", "sqlCode": -500001}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -505000, "facilityCd": "facilityCd"}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99987}}'::jsonb, '1', '0', 4, '2020-05-22 09:38:28.418', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5170002, 'S_hosp', 'karte_ord', '', 'S', 'upd', 'xml', 'SSI', 'SSI', 'karte', '1', '<SsiData Type="KARTE_NOTIFY">
  <NotifyDate>$SYSDATE yyyyMMdd</NotifyDate>
  <!-- yyyyMMdd,yyyy/MM/dd,yyyy-MM-dd -->
  <NotifyTime>$SYSTIME HHmmss</NotifyTime>
  <!-- HHmmssSSS,HHmmss,HH:mm:ss.SSS,HH:mm:ss -->
  <Karte>
    <PatientID>dataset:-500001.hosp_pat_id8</PatientID>
    <AccessionNumber>dataset:-505000.ord_no12</AccessionNumber>
    <OperateMode>NW</OperateMode>
    <Class>dataset:-505000.karte_class</Class>
    <Nyuugai>dataset:-505000.in_out_s</Nyuugai>
    <SnkCode>dataset:-505000.course_cd</SnkCode>
    <Syosaisin/>
    <Importance/>
    <InsuranceNo/>
    <SubTitle/>
    <MakeUser UserID="auth_id:-505000.user_id">staff_name:-505000.user_id</MakeUser>
    <MakeDate>dataset:-505000.start_date8</MakeDate>
    <MakeTime>dataset:-505000.start_date6</MakeTime>
    <InpUser UserID="auth_id:-505000.user_id">staff_name:-505000.user_id</InpUser>
    <InpDate>dataset:-505000.inp_date</InpDate>
    <InpTime>dataset:-505000.inp_time</InpTime>
    <Document>
      <Content>#karte_content#</Content>
    </Document>
  </Karte>
</SsiData>
', '{"dataset": [{"patId": "patId", "sqlCode": -500001}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -505000, "facilityCd": "facilityCd"}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99987}}'::jsonb, '1', '0', 4, '2020-05-22 09:38:28.418', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5170003, 'S_hosp', 'karte_ord', '', 'S', 'del', 'xml', 'SSI', 'SSI', 'karte', '1', '<SsiData Type="KARTE_NOTIFY">
  <NotifyDate>$SYSDATE yyyyMMdd</NotifyDate>
  <!-- yyyyMMdd,yyyy/MM/dd,yyyy-MM-dd -->
  <NotifyTime>$SYSTIME HHmmss</NotifyTime>
  <!-- HHmmssSSS,HHmmss,HH:mm:ss.SSS,HH:mm:ss -->
  <Karte>
    <PatientID>dataset:-500001.hosp_pat_id8</PatientID>
    <AccessionNumber>dataset:-505002.ord_no12</AccessionNumber>
    <OperateMode>CA</OperateMode>
    <Class>dataset:-505002.karte_class</Class>
    <Nyuugai>dataset:-505002.in_out_s</Nyuugai>
    <SnkCode>dataset:-505002.course_cd</SnkCode>
    <Syosaisin/>
    <Importance/>
    <InsuranceNo/>
    <SubTitle/>
    <MakeUser UserID="auth_id:-505002.user_id">staff_name:-505002.user_id</MakeUser>
    <MakeDate>dataset:-505002.start_date8</MakeDate>
    <MakeTime>dataset:-505002.start_date6</MakeTime>
    <InpUser UserID="auth_id:-505002.user_id">staff_name:-505002.user_id</InpUser>
    <InpDate>dataset:-505002.inp_date</InpDate>
    <InpTime>dataset:-505002.inp_time</InpTime>
    <Document>
      <Content/>
    </Document>
  </Karte>
</SsiData>
', '{"dataset": [{"patId": "patId", "sqlCode": -500001}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -505002, "facilityCd": "facilityCd"}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99987}}'::jsonb, '1', '0', 4, '2020-05-22 09:38:28.418', CURRENT_TIMESTAMP, 'SSI');