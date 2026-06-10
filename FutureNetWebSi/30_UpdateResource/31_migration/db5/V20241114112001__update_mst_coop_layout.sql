DELETE FROM "ntss"."mst_coop_layout" where ctl_no in (-6010001,-6020001,-6020002,-6020003,-6030001,-6030002,-6030003,-6050001,-6050002,-6050003,-6060003);
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-6010001, 'C_hosp', 'profile', '', 'S', 'cre', 'xml', 'CSI患者プロファイル', 'MIRAIs', '患者プロファイル', '1', '<coop_info>
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
            <SYS_COOP_INI_DATA>
                <row _sqlCode="-610004">
                    <INI_SECTION>dataset:-610004.ini_section</INI_SECTION>
                    <INI_KEY>dataset:-610004.ini_key</INI_KEY>
                    <INI_VALUE>dataset:-610004.ini_value</INI_VALUE>
                </row>
            </SYS_COOP_INI_DATA>
              </rootNode>
   </dump>
</coop_info>', '{"dataset": [{"key0": "key0", "sqlCode": -610004, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', -1, '2023-09-28 13:12:37.521', CURRENT_TIMESTAMP, 'CSI');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-6020001, 'C_hosp', 'ind_dial', '', 'S', 'cre', 'xml', 'CSI透析予約', 'MIRAIs', '透析予約', '1', '<coop_info>
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
          <IN_HOSPITAL_CD>dataset:-610905.in_hospital_cd_1</IN_HOSPITAL_CD>
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
          <STANDARD_START_TIME>dataset:-436.kur_standard_start_time_6</STANDARD_START_TIME>
        </MST_KUR>
        <!-- ベッドマスタ -->
        <MST_BED>
          <!-- ベッド名 -->
          <BED_NAME>dataset:-436.bed_name</BED_NAME>
        </MST_BED>
      </SCH_DIALYSIS_PLAN>
      <IND_DIALYSIS_PLAN CTL_NO="$COUNT" _sqlCode="-604108">
        <!-- 予約指示 詳細:番号 -->
        <!-- 指示者 -->
        <INDICATOR_CD>dataset:-604108.ind_user_id</INDICATOR_CD>
        <!-- スタッフマスタ：指示者の値-->
        <MST_STAFF>
          <STAFF_CD>dataset:-604108.ind_user_id</STAFF_CD>
          <!-- 職種コード-->
          <JOB_CLASS_CD>dataset:-604108.is_doctor</JOB_CLASS_CD>
        </MST_STAFF>
        <!-- 更新者 -->
        <UPDATE_STAFF_CD>dataset:-604108.upd_user_id</UPDATE_STAFF_CD>
        <!-- 更新時間 -->
        <UP_DATE>dataset:-604108.up_date</UP_DATE>
      </IND_DIALYSIS_PLAN>
      <IND_DIALYSIS_COND ID="$COUNT" _sqlCode="-604153">
        <DIALYSIS_ITEM_CD>dataset:-604153.item_cd</DIALYSIS_ITEM_CD>
        <NAME>dataset:-604153.item_name</NAME>
        <VALUE>dataset:-604153.item_value</VALUE>
        <!-- 条件指示 詳細：項目番号, 項目名, 設定値-->
        <!-- 指示者 -->
        <INDICATOR_CD>dataset:-604153.ind_user_id</INDICATOR_CD>
        <!-- スタッフマスタ：指示者の値 -->
        <MST_STAFF>
          <STAFF_CD>dataset:-604153.ind_user_id</STAFF_CD>
          <!-- 職種コード -->
          <JOB_CLASS_CD>dataset:-604153.is_doctor</JOB_CLASS_CD>
        </MST_STAFF>
        <!-- 更新者 -->
        <UPDATE_STAFF_CD>dataset:-604153.upd_user_id</UPDATE_STAFF_CD>
        <!-- 更新時間 -->
        <UP_DATE>dataset:-604153.up_date</UP_DATE>
        <!-- 装置:モード -->
        <MST_TREAT_ITEM>
          <DEVICE_MODE>dataset:-604153.add_item</DEVICE_MODE>
        </MST_TREAT_ITEM>
      </IND_DIALYSIS_COND>
      <IND_DIALYSIS_MEDI CTL_NO="$COUNT" _sqlCode="-604104">
        <!-- 投薬指示 詳細:番号 -->
        <!-- 指示者 -->
        <INDICATOR_CD>dataset:-604104.ind_user_id</INDICATOR_CD>
        <!-- スタッフマスタ：指示者の値-->
        <MST_STAFF>
          <STAFF_CD>dataset:-604104.ind_user_id</STAFF_CD>
          <!-- 職種コード-->
          <JOB_CLASS_CD>dataset:-604104.is_doctor</JOB_CLASS_CD>
        </MST_STAFF>
        <!-- 更新者 -->
        <UPDATE_STAFF_CD>dataset:-604104.upd_user_id</UPDATE_STAFF_CD>
        <!-- 更新時間 -->
        <UP_DATE>dataset:-604104.up_date</UP_DATE>
      </IND_DIALYSIS_MEDI>
      <IND_DIALYSIS_EQUIP CTL_NO="$COUNT" _sqlCode="-604157">
        <!-- 材料指示 詳細:番号 -->
        <!-- 指示者 -->
        <INDICATOR_CD>dataset:-604157.ind_user_id</INDICATOR_CD>
        <!-- スタッフマスタ：指示者の値-->
        <MST_STAFF>
          <STAFF_CD>dataset:-604157.ind_user_id</STAFF_CD>
          <!-- 職種コード-->
          <JOB_CLASS_CD>dataset:-604157.is_doctor</JOB_CLASS_CD>
        </MST_STAFF>
        <!-- 更新者 -->
        <UPDATE_STAFF_CD>dataset:-604157.upd_user_id</UPDATE_STAFF_CD>
        <!-- 更新時間 -->
        <UP_DATE>dataset:-604157.up_date</UP_DATE>
      </IND_DIALYSIS_EQUIP>
      <IND_DIALYSIS_ADD CTL_NO="$COUNT" _sqlCode="-604161">
        <!-- 指示簿指示 詳細:番号 -->
        <!-- 指示者 -->
        <INDICATOR_CD>dataset:-604161.ind_user_id</INDICATOR_CD>
        <!-- スタッフマスタ：指示者の値-->
        <MST_STAFF>
          <STAFF_CD>dataset:-604161.ind_user_id</STAFF_CD>
          <!-- 職種コード-->
          <JOB_CLASS_CD>dataset:-604161.is_doctor</JOB_CLASS_CD>
        </MST_STAFF>
        <!-- 更新者 -->
        <UPDATE_STAFF_CD>dataset:-604161.upd_user_id</UPDATE_STAFF_CD>
        <!-- 更新時間 -->
        <UP_DATE>dataset:-604161.up_date</UP_DATE>
      </IND_DIALYSIS_ADD>
      <SYS_COOP_EXEC_DATA>
        <A00001>
          <SYS_STAFF_AUTH>
            <ACL>dataset:-604901.acl</ACL>
          </SYS_STAFF_AUTH>
        </A00001>
        <A00002>
          <MST_BED>
            <BED_NO _sqlCode="-610903">dataset:-610903.in_hospital_cd_1</BED_NO>
          </MST_BED>
        </A00002>
        <A10001/>
        <A10002>
          <USER_TABLES>
            <TABLE_NAME>IF_EVENT_LOG</TABLE_NAME>
          </USER_TABLES>
        </A10002>
      </SYS_COOP_EXEC_DATA>
      <SYS_COOP_INI_DATA>
        <row _sqlCode="-610004">
          <INI_SECTION>dataset:-610004.ini_section</INI_SECTION>
          <INI_KEY>dataset:-610004.ini_key</INI_KEY>
          <INI_VALUE>dataset:-610004.ini_value</INI_VALUE>
        </row>
      </SYS_COOP_INI_DATA>
    </rootNode>
  </dump>
</coop_info>
', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -436}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -437}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -438}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -439}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -440}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -441}, {"ordNo": "ordNo", "sqlCode": -604104}, {"ordNo": "ordNo", "sqlCode": -604108}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604153}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604157}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604161}, {"ordNo": "ordNo", "sqlCode": -604901}, {"sqlCode": -610903, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -610004, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -610905, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', -1, '2023-09-28 13:12:37.521', CURRENT_TIMESTAMP, 'CSI');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-6020002, 'C_hosp', 'ind_dial', '', 'S', 'upd', 'xml', 'CSI透析予約', 'MIRAIs', '透析予約', '1', '<coop_info>
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
          <IN_HOSPITAL_CD>dataset:-610905.in_hospital_cd_1</IN_HOSPITAL_CD>
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
          <STANDARD_START_TIME>dataset:-436.kur_standard_start_time_6</STANDARD_START_TIME>
        </MST_KUR>
        <!-- ベッドマスタ -->
        <MST_BED>
          <!-- ベッド名 -->
          <BED_NAME>dataset:-436.bed_name</BED_NAME>
        </MST_BED>
      </SCH_DIALYSIS_PLAN>
      <IND_DIALYSIS_PLAN CTL_NO="$COUNT" _sqlCode="-604108">
        <!-- 予約指示 詳細:番号 -->
        <!-- 指示者 -->
        <INDICATOR_CD>dataset:-604108.ind_user_id</INDICATOR_CD>
        <!-- スタッフマスタ：指示者の値-->
        <MST_STAFF>
          <STAFF_CD>dataset:-604108.ind_user_id</STAFF_CD>
          <!-- 職種コード-->
          <JOB_CLASS_CD>dataset:-604108.is_doctor</JOB_CLASS_CD>
        </MST_STAFF>
        <!-- 更新者 -->
        <UPDATE_STAFF_CD>dataset:-604108.upd_user_id</UPDATE_STAFF_CD>
        <!-- 更新時間 -->
        <UP_DATE>dataset:-604108.up_date</UP_DATE>
      </IND_DIALYSIS_PLAN>
      <IND_DIALYSIS_COND ID="$COUNT" _sqlCode="-604153">
        <DIALYSIS_ITEM_CD>dataset:-604153.item_cd</DIALYSIS_ITEM_CD>
        <NAME>dataset:-604153.item_name</NAME>
        <VALUE>dataset:-604153.item_value</VALUE>
        <!-- 条件指示 詳細：項目番号, 項目名, 設定値-->
        <!-- 指示者 -->
        <INDICATOR_CD>dataset:-604153.ind_user_id</INDICATOR_CD>
        <!-- スタッフマスタ：指示者の値 -->
        <MST_STAFF>
          <STAFF_CD>dataset:-604153.ind_user_id</STAFF_CD>
          <!-- 職種コード -->
          <JOB_CLASS_CD>dataset:-604153.is_doctor</JOB_CLASS_CD>
        </MST_STAFF>
        <!-- 更新者 -->
        <UPDATE_STAFF_CD>dataset:-604153.upd_user_id</UPDATE_STAFF_CD>
        <!-- 更新時間 -->
        <UP_DATE>dataset:-604153.up_date</UP_DATE>
        <!-- 装置:モード -->
        <MST_TREAT_ITEM>
          <DEVICE_MODE>dataset:-604153.add_item</DEVICE_MODE>
        </MST_TREAT_ITEM>
      </IND_DIALYSIS_COND>
      <!--IND_DIALYSIS_MEDI CTL_NO="$COUNT" _sqlCode="-604104"-->
      <IND_DIALYSIS_MEDI CTL_NO="$COUNT" _sqlCode="-604104">
        <!-- 投薬指示 詳細:番号 -->
        <!-- 指示者 -->
        <INDICATOR_CD>dataset:-604104.ind_user_id</INDICATOR_CD>
        <!-- スタッフマスタ：指示者の値-->
        <MST_STAFF>
          <STAFF_CD>dataset:-604104.ind_user_id</STAFF_CD>
          <!-- 職種コード-->
          <JOB_CLASS_CD>dataset:-604104.is_doctor</JOB_CLASS_CD>
        </MST_STAFF>
        <!-- 更新者 -->
        <UPDATE_STAFF_CD>dataset:-604104.upd_user_id</UPDATE_STAFF_CD>
        <!-- 更新時間 -->
        <UP_DATE>dataset:-604104.up_date</UP_DATE>
      </IND_DIALYSIS_MEDI>
      <IND_DIALYSIS_EQUIP CTL_NO="$COUNT" _sqlCode="-604157">
        <!-- 材料指示 詳細:番号 -->
        <!-- 指示者 -->
        <INDICATOR_CD>dataset:-604157.ind_user_id</INDICATOR_CD>
        <!-- スタッフマスタ：指示者の値-->
        <MST_STAFF>
          <STAFF_CD>dataset:-604157.ind_user_id</STAFF_CD>
          <!-- 職種コード-->
          <JOB_CLASS_CD>dataset:-604157.is_doctor</JOB_CLASS_CD>
        </MST_STAFF>
        <!-- 更新者 -->
        <UPDATE_STAFF_CD>dataset:-604157.upd_user_id</UPDATE_STAFF_CD>
        <!-- 更新時間 -->
        <UP_DATE>dataset:-604157.up_date</UP_DATE>
      </IND_DIALYSIS_EQUIP>
      <IND_DIALYSIS_ADD CTL_NO="$COUNT" _sqlCode="-604161">
        <!-- 指示簿指示 詳細:番号 -->
        <!-- 指示者 -->
        <INDICATOR_CD>dataset:-604161.ind_user_id</INDICATOR_CD>
        <!-- スタッフマスタ：指示者の値-->
        <MST_STAFF>
          <STAFF_CD>dataset:-604161.ind_user_id</STAFF_CD>
          <!-- 職種コード-->
          <JOB_CLASS_CD>dataset:-604161.is_doctor</JOB_CLASS_CD>
        </MST_STAFF>
        <!-- 更新者 -->
        <UPDATE_STAFF_CD>dataset:-604161.upd_user_id</UPDATE_STAFF_CD>
        <!-- 更新時間 -->
        <UP_DATE>dataset:-604161.up_date</UP_DATE>
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
        <A10001/>
        <A10002>
          <USER_TABLES>
            <TABLE_NAME>COOP_LAYOUT</TABLE_NAME>
          </USER_TABLES>
        </A10002>
      </SYS_COOP_EXEC_DATA>
      <SYS_COOP_INI_DATA>
        <row _sqlCode="-610004">
          <INI_SECTION>dataset:-610004.ini_section</INI_SECTION>
          <INI_KEY>dataset:-610004.ini_key</INI_KEY>
          <INI_VALUE>dataset:-610004.ini_value</INI_VALUE>
        </row>
      </SYS_COOP_INI_DATA>
    </rootNode>
  </dump>
</coop_info>
', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -436}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -437}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -438}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -439}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -440}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -441}, {"ordNo": "ordNo", "sqlCode": -604104}, {"ordNo": "ordNo", "sqlCode": -604108}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604153}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604157}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604161}, {"ordNo": "ordNo", "sqlCode": -604901}, {"sqlCode": -610903, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -610004, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -610905, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', -1, '2023-09-28 13:12:37.521', CURRENT_TIMESTAMP, 'CSI');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-6020003, 'C_hosp', 'ind_dial', '', 'S', 'del', 'xml', 'CSI透析予約', 'MIRAIs', '透析予約', '1', '<coop_info>
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
          <IN_HOSPITAL_CD>dataset:-610905.in_hospital_cd_1</IN_HOSPITAL_CD>
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
          <STANDARD_START_TIME>dataset:-436.kur_standard_start_time_6</STANDARD_START_TIME>
        </MST_KUR>
        <!-- ベッドマスタ -->
        <MST_BED>
          <!-- ベッド名 -->
          <BED_NAME>dataset:-436.bed_name</BED_NAME>
        </MST_BED>
      </SCH_DIALYSIS_PLAN>
      <IND_DIALYSIS_PLAN CTL_NO="$COUNT" _sqlCode="-604165">
        <!-- 予約指示 詳細:番号 -->
        <!-- 指示者 -->
        <INDICATOR_CD>dataset:-604165.user_id</INDICATOR_CD>
        <!-- スタッフマスタ：指示者の値-->
        <MST_STAFF>
          <STAFF_CD>dataset:-604165.user_id</STAFF_CD>
          <!-- 職種コード-->
          <JOB_CLASS_CD>dataset:-604165.is_doctor</JOB_CLASS_CD>
        </MST_STAFF>
        <!-- 更新者 -->
        <UPDATE_STAFF_CD>dataset:-604165.user_id</UPDATE_STAFF_CD>
        <!-- 更新時間 -->
        <UP_DATE>dataset:-437.up_date</UP_DATE>
        <TEST_UP_DATE>dataset:-437.up_date</TEST_UP_DATE>
      </IND_DIALYSIS_PLAN>
      <IND_DIALYSIS_COND ID="$COUNT" _sqlCode="-604165">
        <DIALYSIS_ITEM_CD/>
        <NAME/>
        <VALUE/>
        <!-- 条件指示 詳細：項目番号, 項目名, 設定値-->
        <!-- 指示者 -->
        <INDICATOR_CD>dataset:-604165.user_id</INDICATOR_CD>
        <!-- スタッフマスタ：指示者の値 -->
        <MST_STAFF>
          <STAFF_CD>dataset:-604165.user_id</STAFF_CD>
          <!-- 職種コード -->
          <JOB_CLASS_CD>dataset:-604165.is_doctor</JOB_CLASS_CD>
        </MST_STAFF>
        <!-- 更新者 -->
        <UPDATE_STAFF_CD>dataset:-604165.user_id</UPDATE_STAFF_CD>
        <!-- 更新時間 -->
        <UP_DATE>dataset:-604165.up_date</UP_DATE>
        <!-- 装置:モード -->
        <MST_TREAT_ITEM>
          <DEVICE_MODE/>
        </MST_TREAT_ITEM>
      </IND_DIALYSIS_COND>
      <IND_DIALYSIS_MEDI CTL_NO="$COUNT" _sqlCode="-604165">
        <!-- 投薬指示 詳細:番号 -->
        <!-- 指示者 -->
        <INDICATOR_CD>dataset:-604165.user_id</INDICATOR_CD>
        <!-- スタッフマスタ：指示者の値-->
        <MST_STAFF>
          <STAFF_CD>dataset:-604165.user_id</STAFF_CD>
          <!-- 職種コード-->
          <JOB_CLASS_CD>dataset:-604165.is_doctor</JOB_CLASS_CD>
        </MST_STAFF>
        <!-- 更新者 -->
        <UPDATE_STAFF_CD>dataset:-604165.user_id</UPDATE_STAFF_CD>
        <!-- 更新時間 -->
        <UP_DATE>dataset:-604165.up_date</UP_DATE>
      </IND_DIALYSIS_MEDI>
      <IND_DIALYSIS_EQUIP CTL_NO="$COUNT" _sqlCode="-604165">
        <!-- 材料指示 詳細:番号 -->
        <!-- 指示者 -->
        <INDICATOR_CD>dataset:-604165.user_id</INDICATOR_CD>
        <!-- スタッフマスタ：指示者の値-->
        <MST_STAFF>
          <STAFF_CD>dataset:-604165.user_id</STAFF_CD>
          <!-- 職種コード-->
          <JOB_CLASS_CD>dataset:-604165.is_doctor</JOB_CLASS_CD>
        </MST_STAFF>
        <!-- 更新者 -->
        <UPDATE_STAFF_CD>dataset:-604165.user_id</UPDATE_STAFF_CD>
        <!-- 更新時間 -->
        <UP_DATE>dataset:-604165.up_date</UP_DATE>
      </IND_DIALYSIS_EQUIP>
      <IND_DIALYSIS_ADD CTL_NO="$COUNT" _sqlCode="-604165">
        <!-- 指示簿指示 詳細:番号 -->
        <!-- 指示者 -->
        <INDICATOR_CD>dataset:-604165.user_id</INDICATOR_CD>
        <!-- スタッフマスタ：指示者の値-->
        <MST_STAFF>
          <STAFF_CD>dataset:-604165.user_id</STAFF_CD>
          <!-- 職種コード-->
          <JOB_CLASS_CD>dataset:-604165.is_doctor</JOB_CLASS_CD>
        </MST_STAFF>
        <!-- 更新者 -->
        <UPDATE_STAFF_CD>dataset:-604165.user_id</UPDATE_STAFF_CD>
        <!-- 更新時間 -->
        <UP_DATE>dataset:-604165.up_date</UP_DATE>
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
        <A10001/>
        <A10002>
          <USER_TABLES>
            <TABLE_NAME>COOP_LAYOUT</TABLE_NAME>
          </USER_TABLES>
        </A10002>
      </SYS_COOP_EXEC_DATA>
      <SYS_COOP_INI_DATA>
        <row _sqlCode="-610004">
          <INI_SECTION>dataset:-610004.ini_section</INI_SECTION>
          <INI_KEY>dataset:-610004.ini_key</INI_KEY>
          <INI_VALUE>dataset:-610004.ini_value</INI_VALUE>
        </row>
      </SYS_COOP_INI_DATA>
    </rootNode>
  </dump>
</coop_info>
', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -436}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -437}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -438}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -439}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -440}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -441}, {"ordNo": "ordNo", "sqlCode": -604104}, {"ordNo": "ordNo", "sqlCode": -604108}, {"ctlNo": "ctlNo", "sqlCode": -604165}, {"key0": "key0", "sqlCode": -610004, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -610905, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', -1, '2023-09-28 13:12:37.521', CURRENT_TIMESTAMP, 'CSI');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-6030001, 'C_hosp', 'rst_dial', '', 'S', 'cre', 'xml', 'CSI透析実績', 'MIRAIs', '実績送信', '1', '<coop_info>
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
        <DOCTOR_CD1>dataset:-607001.staff_cd1</DOCTOR_CD1>
        <!-- 医師2 -->
        <DOCTOR_CD2>dataset:-607001.staff_cd2</DOCTOR_CD2>
        <MST_PAT_GROUP>
          <!--患者基本情報・患者グループの院内コード-->
          <IN_HOSPITAL_CD>dataset:-610905.in_hospital_cd_1</IN_HOSPITAL_CD>
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
          <IN_HOSPITAL_CD>dataset:-444.in_hospital_cd_1</IN_HOSPITAL_CD>
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
          <KUR_NAME>dataset:-444.kur_name</KUR_NAME>
        </MST_KUR>
        <!--透析実績履歴・透析時間-->
        <!--DIALYSIS_TIME>dataset:-444.rst_running_time</DIALYSIS_TIME-->
        <DIALYSIS_TIME>240</DIALYSIS_TIME>
        <!--透析実績履歴・病棟コード-->
        <WARD_CD>dataset:-444.in_hospital_cd_1</WARD_CD>
        <MST_WARD>
          <!--透析実績履歴・病棟マスタ・院内コード-->
          <IN_HOSPITAL_CD>dataset:-444.in_hospital_cd_1</IN_HOSPITAL_CD>
        </MST_WARD>
      </RST_DIALYSIS_HST>
      <!-- 3.透析実績版番管理 -->
      <RST_DIALYSIS_EDITION>
        <!--透析実績版番管理.版確定者-->
        <DECIDER>dataset:-607001.up_ind_user_id</DECIDER>
        <!--スタッフマスタ:版確定者-->
        <!--MST_STAFF STAFF_CD="D100"-->
        <MST_STAFF>
          <STAFF_CD>dataset:-607001.up_ind_user_id</STAFF_CD>
          <!-- スタッフマスタ.職種コード-->
          <JOB_CLASS_CD>dataset:-607003.is_doctor</JOB_CLASS_CD>
        </MST_STAFF>
      </RST_DIALYSIS_EDITION>
      <RST_RECEIPT_MEMO_HST _sqlCode="-448" NAME="dataset:-448.detail_id" DIVISION="0" ADD_FLG="0" MAIN_DIAL_DIFF="dataset:-448.is_main">
        <!-- 4.透析困難コメント:主たる透析困難コメントフラグ-->
        <!-- 透析困難コメント -->
        <ITEM_NAME>dataset:-448.dialysis_difficulty_name</ITEM_NAME>
      </RST_RECEIPT_MEMO_HST>
      <RST_DIALYSIS_COND_HST _sqlCode="-604166" CTL_NO="dataset:-604166.item_cd" NAME="dataset:-604166.item_name">
        <!-- 5.透析条件履歴:透析条件項目コード -->
        <!-- 項目コード -->
        <CTL_NO>dataset:-604166.item_cd</CTL_NO>
        <!-- 設定値 -->
        <VALUE>dataset:-604166.item_value</VALUE>
        <!-- 治療方法マスタ -->
        <MST_TREAT_ITEM>
          <!-- 治療項目マスタ・院内コード:複数データの場合，カンマ[,]区切り -->
          <IN_HOSPITAL_CD>dataset:-604166.mtt_in_hospital_cd</IN_HOSPITAL_CD>
          <!-- 治療方法名称 -->
          <TREAT_ITEM_NAME>dataset:-604166.mtt_treatment_name</TREAT_ITEM_NAME>
        </MST_TREAT_ITEM>
        <!-- 薬剤マスタ -->
        <MST_MEDICINE>
          <!-- 薬剤マスタ・注射フラグ -->
          <SHOT>dataset:-604166.med_is_shot</SHOT>
          <!-- 院内コード -->
          <IN_HOSPITAL_CD>dataset:-604166.med_in_hospital_cd</IN_HOSPITAL_CD>
        </MST_MEDICINE>
        <MST_SET_MEDI_NAME>
          <!-- ※NTSSに薬剤セットが無し -->
          <!-- 薬剤セットマスタ -->
          <MST_SET_MEDICINE>
            <!-- 薬剤マスタ -->
            <MST_MEDICINE>
              <!-- 薬剤マスタ・注射フラグ -->
              <SHOT/>
              <!-- 院内コード -->
              <IN_HOSPITAL_CD/>
            </MST_MEDICINE>
            <!-- 使用薬剤数 -->
            <MEDI_USE_NUM/>
          </MST_SET_MEDICINE>
        </MST_SET_MEDI_NAME>
        <!-- ダイアライザマスタ -->
        <MST_DIALYZER>
          <!-- 院内コード -->
          <IN_HOSPITAL_CD>dataset:-604166.mdr_in_hospital_cd</IN_HOSPITAL_CD>
        </MST_DIALYZER>
        <!-- 医療材料マスタ -->
        <MST_EQUIPMENT>
          <!-- 院内コード -->
          <IN_HOSPITAL_CD>dataset:-604166.meqa_in_hospital_cd</IN_HOSPITAL_CD>
        </MST_EQUIPMENT>
      </RST_DIALYSIS_COND_HST>
      <RST_DIALYSIS_COND_HST CTL_NO="dataset:-604170.item_cd" NAME="dataset:-604170.item_name">
        <!-- 5.透析条件履歴:透析条件項目コード -->
        <!-- 項目コード -->
        <CTL_NO>dataset:-604170.item_cd</CTL_NO>
        <!-- 設定値 -->
        <VALUE>dataset:-604170.item_value</VALUE>
        <!-- 治療方法マスタ -->
        <MST_TREAT_ITEM>
          <!-- 治療項目マスタ・院内コード:複数データの場合，カンマ[,]区切り -->
          <IN_HOSPITAL_CD>dataset:-604170.mtt_in_hospital_cd</IN_HOSPITAL_CD>
          <!-- 治療方法名称 -->
          <TREAT_ITEM_NAME>dataset:-604170.mtt_treatment_name</TREAT_ITEM_NAME>
        </MST_TREAT_ITEM>
        <!-- 薬剤マスタ -->
        <MST_MEDICINE>
          <!-- 薬剤マスタ・注射フラグ -->
          <SHOT>dataset:-604170.med_is_shot</SHOT>
          <!-- 院内コード -->
          <IN_HOSPITAL_CD>dataset:-604170.med_in_hospital_cd</IN_HOSPITAL_CD>
        </MST_MEDICINE>
        <MST_SET_MEDI_NAME _sqlCode="-604171">
          <!-- ※NTSSに薬剤セットが無し -->
          <!-- 薬剤セットマスタ -->
          <MST_SET_MEDICINE>
            <!-- 薬剤マスタ -->
            <MST_MEDICINE>
              <!-- 薬剤マスタ・注射フラグ -->
              <SHOT/>
              <!-- 院内コード -->
              <IN_HOSPITAL_CD>dataset:-604171.mix_med_in_hospital_cd</IN_HOSPITAL_CD>
            </MST_MEDICINE>
            <!-- 使用薬剤数 -->
            <MEDI_USE_NUM>dataset:-604171.mix_amout</MEDI_USE_NUM>
          </MST_SET_MEDICINE>
        </MST_SET_MEDI_NAME>
        <!-- ダイアライザマスタ -->
        <MST_DIALYZER>
          <!-- 院内コード -->
          <IN_HOSPITAL_CD>dataset:-604170.mdr_in_hospital_cd</IN_HOSPITAL_CD>
        </MST_DIALYZER>
        <!-- 医療材料マスタ -->
        <MST_EQUIPMENT>
          <!-- 院内コード -->
          <IN_HOSPITAL_CD>dataset:-604170.meqa_in_hospital_cd</IN_HOSPITAL_CD>
        </MST_EQUIPMENT>
      </RST_DIALYSIS_COND_HST>
      <RST_DIALYSIS_EQUIP_HST _sqlCode="-604173">
        <AMOUNT>dataset:-604173.amount</AMOUNT>
        <MST_EQUIPMENT>
          <IN_HOSPITAL_CD>dataset:-604173.in_hospital_cd_1</IN_HOSPITAL_CD>
        </MST_EQUIPMENT>
      </RST_DIALYSIS_EQUIP_HST>
      <RST_DIALYSIS_MEDICATION_HST _sqlCode="-604174" CTL_NO="dataset:-604174.ctl_no" _detail="medicine">
      </RST_DIALYSIS_MEDICATION_HST>
      <RST_DIALYSIS_TREATMENT_HST _sqlCode="-604177" CTL_NO="dataset:-604177.disp_no" NAME="dataset:-604177.disp_name"  _detail="medicine">
      </RST_DIALYSIS_TREATMENT_HST>
      <SYS_COOP_EXEC_DATA>
        <A00001>
          <SYS_STAFF_AUTH>
            <ACL>dataset:-604901.acl</ACL>
          </SYS_STAFF_AUTH>
        </A00001>
        <A00002>
          <MST_BED>
            <BED_NO _sqlCode="-610903">dataset:-610903.in_hospital_cd_1</BED_NO>
          </MST_BED>
        </A00002>
        <A10001/>
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
      <SYS_COOP_INI_DATA>
        <row _sqlCode="-610004">
          <INI_SECTION>dataset:-610004.ini_section</INI_SECTION>
          <INI_KEY>dataset:-610004.ini_key</INI_KEY>
          <INI_VALUE>dataset:-610004.ini_value</INI_VALUE>
        </row>
      </SYS_COOP_INI_DATA>
    </rootNode>
  </dump>
</coop_info>
', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -444}, {"patId": "patId", "sqlCode": -445}, {"ordNo": "ordNo", "sqlCode": -447}, {"patId": "patId", "sqlCode": -448}, {"ordNo": "ordNo", "sqlCode": -450}, {"ordNo": "ordNo", "sqlCode": -451}, {"ordNo": "ordNo", "sqlCode": -604901}, {"sqlCode": -610903, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -607001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -607003}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604166}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604168}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -604169}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604170}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604171}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -604172}, {"ordNo": "ordNo", "sqlCode": -604173}, {"key0": "key0", "sqlCode": -610004, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -610905, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604174}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604177}]}'::jsonb, '1', '0', -1, '2023-09-28 13:12:37.521', CURRENT_TIMESTAMP, 'CSI');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-6030002, 'C_hosp', 'rst_dial', '', 'S', 'upd', 'xml', 'CSI透析実績', 'MIRAIs', '実績送信', '1', '<coop_info>
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
        <DOCTOR_CD1>dataset:-607001.staff_cd1</DOCTOR_CD1>
        <!-- 医師2 -->
        <DOCTOR_CD2>dataset:-607001.staff_cd2</DOCTOR_CD2>
        <MST_PAT_GROUP>
          <!--患者基本情報・患者グループの院内コード-->
          <IN_HOSPITAL_CD>dataset:-610905.in_hospital_cd_1</IN_HOSPITAL_CD>
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
          <IN_HOSPITAL_CD>dataset:-444.in_hospital_cd_1</IN_HOSPITAL_CD>
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
          <KUR_NAME>dataset:-444.kur_name</KUR_NAME>
        </MST_KUR>
        <!--透析実績履歴・透析時間-->
        <!--DIALYSIS_TIME>dataset:-444.rst_running_time</DIALYSIS_TIME-->
        <DIALYSIS_TIME>240</DIALYSIS_TIME>
        <!--透析実績履歴・病棟コード-->
        <WARD_CD>dataset:-444.in_hospital_cd_1</WARD_CD>
        <MST_WARD>
          <!--透析実績履歴・病棟マスタ・院内コード-->
          <IN_HOSPITAL_CD>dataset:-444.in_hospital_cd_1</IN_HOSPITAL_CD>
        </MST_WARD>
      </RST_DIALYSIS_HST>
      <!-- 3.透析実績版番管理 -->
      <RST_DIALYSIS_EDITION>
        <!--透析実績版番管理.版確定者-->
        <DECIDER>dataset:-607001.up_ind_user_id</DECIDER>
        <!--スタッフマスタ:版確定者-->
        <!--MST_STAFF STAFF_CD="D100"-->
        <MST_STAFF>
          <STAFF_CD>dataset:-607001.up_ind_user_id</STAFF_CD>
          <!-- スタッフマスタ.職種コード-->
          <JOB_CLASS_CD>dataset:-607003.is_doctor</JOB_CLASS_CD>
        </MST_STAFF>
      </RST_DIALYSIS_EDITION>
      <RST_RECEIPT_MEMO_HST _sqlCode="-448" NAME="dataset:-448.detail_id" DIVISION="0" ADD_FLG="0" MAIN_DIAL_DIFF="dataset:-448.is_main">
        <!-- 4.透析困難コメント:主たる透析困難コメントフラグ-->
        <!-- 透析困難コメント -->
        <ITEM_NAME>dataset:-448.dialysis_difficulty_name</ITEM_NAME>
      </RST_RECEIPT_MEMO_HST>
      <RST_DIALYSIS_COND_HST _sqlCode="-604166" CTL_NO="dataset:-604166.item_cd" NAME="dataset:-604166.item_name">
        <!-- 5.透析条件履歴:透析条件項目コード -->
        <!-- 項目コード -->
        <CTL_NO>dataset:-604166.item_cd</CTL_NO>
        <!-- 設定値 -->
        <VALUE>dataset:-604166.item_value</VALUE>
        <!-- 治療方法マスタ -->
        <MST_TREAT_ITEM>
          <!-- 治療項目マスタ・院内コード:複数データの場合，カンマ[,]区切り -->
          <IN_HOSPITAL_CD>dataset:-604166.mtt_in_hospital_cd</IN_HOSPITAL_CD>
          <!-- 治療方法名称 -->
          <TREAT_ITEM_NAME>dataset:-604166.mtt_treatment_name</TREAT_ITEM_NAME>
        </MST_TREAT_ITEM>
        <!-- 薬剤マスタ -->
        <MST_MEDICINE>
          <!-- 薬剤マスタ・注射フラグ -->
          <SHOT>dataset:-604166.med_is_shot</SHOT>
          <!-- 院内コード -->
          <IN_HOSPITAL_CD>dataset:-604166.med_in_hospital_cd</IN_HOSPITAL_CD>
        </MST_MEDICINE>
        <MST_SET_MEDI_NAME>
          <!-- ※NTSSに薬剤セットが無し -->
          <!-- 薬剤セットマスタ -->
          <MST_SET_MEDICINE>
            <!-- 薬剤マスタ -->
            <MST_MEDICINE>
              <!-- 薬剤マスタ・注射フラグ -->
              <SHOT/>
              <!-- 院内コード -->
              <IN_HOSPITAL_CD/>
            </MST_MEDICINE>
            <!-- 使用薬剤数 -->
            <MEDI_USE_NUM/>
          </MST_SET_MEDICINE>
        </MST_SET_MEDI_NAME>
        <!-- ダイアライザマスタ -->
        <MST_DIALYZER>
          <!-- 院内コード -->
          <IN_HOSPITAL_CD>dataset:-604166.mdr_in_hospital_cd</IN_HOSPITAL_CD>
        </MST_DIALYZER>
        <!-- 医療材料マスタ -->
        <MST_EQUIPMENT>
          <!-- 院内コード -->
          <IN_HOSPITAL_CD>dataset:-604166.meqa_in_hospital_cd</IN_HOSPITAL_CD>
        </MST_EQUIPMENT>
      </RST_DIALYSIS_COND_HST>
      <RST_DIALYSIS_COND_HST CTL_NO="dataset:-604170.item_cd" NAME="dataset:-604170.item_name">
        <!-- 5.透析条件履歴:透析条件項目コード -->
        <!-- 項目コード -->
        <CTL_NO>dataset:-604170.item_cd</CTL_NO>
        <!-- 設定値 -->
        <VALUE>dataset:-604170.item_value</VALUE>
        <!-- 治療方法マスタ -->
        <MST_TREAT_ITEM>
          <!-- 治療項目マスタ・院内コード:複数データの場合，カンマ[,]区切り -->
          <IN_HOSPITAL_CD>dataset:-604170.mtt_in_hospital_cd</IN_HOSPITAL_CD>
          <!-- 治療方法名称 -->
          <TREAT_ITEM_NAME>dataset:-604170.mtt_treatment_name</TREAT_ITEM_NAME>
        </MST_TREAT_ITEM>
        <!-- 薬剤マスタ -->
        <MST_MEDICINE>
          <!-- 薬剤マスタ・注射フラグ -->
          <SHOT>dataset:-604170.med_is_shot</SHOT>
          <!-- 院内コード -->
          <IN_HOSPITAL_CD>dataset:-604170.med_in_hospital_cd</IN_HOSPITAL_CD>
        </MST_MEDICINE>
        <MST_SET_MEDI_NAME _sqlCode="-604171">
          <!-- ※NTSSに薬剤セットが無し -->
          <!-- 薬剤セットマスタ -->
          <MST_SET_MEDICINE>
            <!-- 薬剤マスタ -->
            <MST_MEDICINE>
              <!-- 薬剤マスタ・注射フラグ -->
              <SHOT/>
              <!-- 院内コード -->
              <IN_HOSPITAL_CD>dataset:-604171.mix_med_in_hospital_cd</IN_HOSPITAL_CD>
            </MST_MEDICINE>
            <!-- 使用薬剤数 -->
            <MEDI_USE_NUM>dataset:-604171.mix_amout</MEDI_USE_NUM>
          </MST_SET_MEDICINE>
        </MST_SET_MEDI_NAME>
        <!-- ダイアライザマスタ -->
        <MST_DIALYZER>
          <!-- 院内コード -->
          <IN_HOSPITAL_CD>dataset:-604170.mdr_in_hospital_cd</IN_HOSPITAL_CD>
        </MST_DIALYZER>
        <!-- 医療材料マスタ -->
        <MST_EQUIPMENT>
          <!-- 院内コード -->
          <IN_HOSPITAL_CD>dataset:-604170.meqa_in_hospital_cd</IN_HOSPITAL_CD>
        </MST_EQUIPMENT>
      </RST_DIALYSIS_COND_HST>
      <RST_DIALYSIS_EQUIP_HST _sqlCode="-604173">
        <AMOUNT>dataset:-604173.amount</AMOUNT>
        <MST_EQUIPMENT>
          <IN_HOSPITAL_CD>dataset:-604173.in_hospital_cd_1</IN_HOSPITAL_CD>
        </MST_EQUIPMENT>
      </RST_DIALYSIS_EQUIP_HST>
      <RST_DIALYSIS_MEDICATION_HST _sqlCode="-604174" CTL_NO="dataset:-604174.ctl_no" _detail="medicine">
      </RST_DIALYSIS_MEDICATION_HST>
      <RST_DIALYSIS_TREATMENT_HST _sqlCode="-604177" CTL_NO="dataset:-604177.disp_no" NAME="dataset:-604177.disp_name"  _detail="medicine">
      </RST_DIALYSIS_TREATMENT_HST>
      <SYS_COOP_EXEC_DATA>
        <A00001>
          <SYS_STAFF_AUTH>
            <ACL>dataset:-604901.acl</ACL>
          </SYS_STAFF_AUTH>
        </A00001>
        <A00002>
          <MST_BED>
            <BED_NO _sqlCode="-610903">dataset:-610903.in_hospital_cd_1</BED_NO>
          </MST_BED>
        </A00002>
        <A10001/>
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
      <SYS_COOP_INI_DATA>
        <row _sqlCode="-610004">
          <INI_SECTION>dataset:-610004.ini_section</INI_SECTION>
          <INI_KEY>dataset:-610004.ini_key</INI_KEY>
          <INI_VALUE>dataset:-610004.ini_value</INI_VALUE>
        </row>
      </SYS_COOP_INI_DATA>
    </rootNode>
  </dump>
</coop_info>
', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -444}, {"patId": "patId", "sqlCode": -445}, {"ordNo": "ordNo", "sqlCode": -447}, {"patId": "patId", "sqlCode": -448}, {"ordNo": "ordNo", "sqlCode": -450}, {"ordNo": "ordNo", "sqlCode": -451}, {"ordNo": "ordNo", "sqlCode": -604901}, {"sqlCode": -610903, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -607001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -607003}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604166}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604168}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604170}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604171}, {"ordNo": "ordNo", "sqlCode": -604173}, {"key0": "key0", "sqlCode": -610004, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -610905, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604174}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604177}]}'::jsonb, '1', '0', -1, '2023-09-28 13:12:37.521', CURRENT_TIMESTAMP, 'CSI');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-6030003, 'C_hosp', 'rst_dial', '', 'S', 'del', 'xml', 'CSI透析実績', 'MIRAIs', '実績送信', '1', '<coop_info>
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
        <DOCTOR_CD1>dataset:-607001.staff_cd1</DOCTOR_CD1>
        <!-- 医師2 -->
        <DOCTOR_CD2>dataset:-607001.staff_cd2</DOCTOR_CD2>
        <MST_PAT_GROUP>
          <!--患者基本情報・患者グループの院内コード-->
          <IN_HOSPITAL_CD>dataset:-610905.in_hospital_cd_1</IN_HOSPITAL_CD>
        </MST_PAT_GROUP>
        <!--患者基本情報・透析導入日-->
        <DIAL_START_DATE>dataset:-604169.dialysis_start_date</DIAL_START_DATE>
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
          <IN_HOSPITAL_CD>dataset:-604169.in_hospital_cd_1</IN_HOSPITAL_CD>
        </MST_WARD>
      </PAT_BASIC_INFO>
      <!-- 2.透析実績履歴 -->
      <RST_DIALYSIS_HST>
        <!--透析実績履歴・透析番号-->
        <DIALYSIS_NO>dataset:-604169.rst_fn_dialysis_no</DIALYSIS_NO>
        <!--透析実績履歴・版番号-->
        <EDITION>dataset:-604169.rst_edition</EDITION>
        <!--透析実績履歴・透析開始日時-->
        <START_DATE>dataset:-604169.rst_start_date</START_DATE>
        <!--透析実績履歴・透析終了日時-->
        <END_DATE>dataset:-604169.rst_end_date</END_DATE>
        <!-- ベッドコード -->
        <BED_NO>dataset:-604169.bed_cd1</BED_NO>
        <MST_KUR>
          <!--透析実績履歴・クールマスタ・クール名-->
          <KUR_NAME>dataset:-604169.kur_name</KUR_NAME>
        </MST_KUR>
        <!--透析実績履歴・透析時間-->
        <!--DIALYSIS_TIME>dataset:-444.rst_running_time</DIALYSIS_TIME-->
        <DIALYSIS_TIME>240</DIALYSIS_TIME>
        <!--透析実績履歴・病棟コード-->
        <WARD_CD>dataset:-604169.in_hospital_cd_1</WARD_CD>
        <MST_WARD>
          <!--透析実績履歴・病棟マスタ・院内コード-->
          <IN_HOSPITAL_CD>dataset:-604169.in_hospital_cd_1</IN_HOSPITAL_CD>
        </MST_WARD>
      </RST_DIALYSIS_HST>
      <!-- 3.透析実績版番管理 -->
      <RST_DIALYSIS_EDITION>
        <!--透析実績版番管理.版確定者-->
        <DECIDER>dataset:-607001.up_ind_user_id</DECIDER>
        <!--スタッフマスタ:版確定者-->
        <!--MST_STAFF STAFF_CD="D100"-->
        <MST_STAFF>
          <STAFF_CD>dataset:-607001.up_ind_user_id</STAFF_CD>
          <!-- スタッフマスタ.職種コード-->
          <JOB_CLASS_CD>dataset:-607003.is_doctor</JOB_CLASS_CD>
        </MST_STAFF>
      </RST_DIALYSIS_EDITION>
      <RST_RECEIPT_MEMO_HST _sqlCode="-448" NAME="dataset:-448.detail_id" DIVISION="0" ADD_FLG="0" MAIN_DIAL_DIFF="dataset:-448.is_main">
        <!-- 4.透析困難コメント:主たる透析困難コメントフラグ-->
        <!-- 透析困難コメント -->
        <ITEM_NAME>dataset:-448.dialysis_difficulty_name</ITEM_NAME>
      </RST_RECEIPT_MEMO_HST>
      <RST_DIALYSIS_COND_HST _sqlCode="-604172" CTL_NO="dataset:-604172.item_cd" NAME="dataset:-604172.item_name">
        <!-- 5.透析条件履歴:透析条件項目コード -->
        <!-- 項目コード -->
        <CTL_NO>dataset:-604172.item_cd</CTL_NO>
        <!-- 設定値 -->
        <VALUE>dataset:-604172.item_value</VALUE>
        <!-- 治療方法マスタ -->
        <MST_TREAT_ITEM>
          <!-- 治療項目マスタ・院内コード:複数データの場合，カンマ[,]区切り -->
          <IN_HOSPITAL_CD>dataset:-604172.mtt_in_hospital_cd</IN_HOSPITAL_CD>
          <!-- 治療方法名称 -->
          <TREAT_ITEM_NAME>dataset:-604172.mtt_treatment_name</TREAT_ITEM_NAME>
        </MST_TREAT_ITEM>
        <!-- 薬剤マスタ -->
        <MST_MEDICINE>
          <!-- 薬剤マスタ・注射フラグ -->
          <SHOT>dataset:-604172.med_is_shot</SHOT>
          <!-- 院内コード -->
          <IN_HOSPITAL_CD>dataset:-604172.med_in_hospital_cd</IN_HOSPITAL_CD>
        </MST_MEDICINE>
        <MST_SET_MEDI_NAME>
          <!-- ※NTSSに薬剤セットが無し -->
          <!-- 薬剤セットマスタ -->
          <MST_SET_MEDICINE>
            <!-- 薬剤マスタ -->
            <MST_MEDICINE>
              <!-- 薬剤マスタ・注射フラグ -->
              <SHOT/>
              <!-- 院内コード -->
              <IN_HOSPITAL_CD/>
            </MST_MEDICINE>
            <!-- 使用薬剤数 -->
            <MEDI_USE_NUM/>
          </MST_SET_MEDICINE>
        </MST_SET_MEDI_NAME>
        <!-- ダイアライザマスタ -->
        <MST_DIALYZER>
          <!-- 院内コード -->
          <IN_HOSPITAL_CD>dataset:-604172.mdr_in_hospital_cd</IN_HOSPITAL_CD>
        </MST_DIALYZER>
        <!-- 医療材料マスタ -->
        <MST_EQUIPMENT>
          <!-- 院内コード -->
          <IN_HOSPITAL_CD>dataset:-604172.meqa_in_hospital_cd</IN_HOSPITAL_CD>
        </MST_EQUIPMENT>
      </RST_DIALYSIS_COND_HST>
      <RST_DIALYSIS_EQUIP_HST _sqlCode="-604173">
        <AMOUNT>dataset:-604173.amount</AMOUNT>
        <MST_EQUIPMENT>
          <IN_HOSPITAL_CD>dataset:-604173.in_hospital_cd_1</IN_HOSPITAL_CD>
        </MST_EQUIPMENT>
      </RST_DIALYSIS_EQUIP_HST>
      <RST_DIALYSIS_MEDICATION_HST _sqlCode="-604174" CTL_NO="dataset:-604174.ctl_no" _detail="medicine">
      </RST_DIALYSIS_MEDICATION_HST>
      <RST_DIALYSIS_TREATMENT_HST _sqlCode="-604177" CTL_NO="dataset:-604177.disp_no" NAME="dataset:-604177.disp_name"  _detail="medicine">
      </RST_DIALYSIS_TREATMENT_HST>
      <SYS_COOP_EXEC_DATA>
        <A00001>
          <SYS_STAFF_AUTH>
            <ACL>dataset:-604901.acl</ACL>
          </SYS_STAFF_AUTH>
        </A00001>
        <A00002>
          <MST_BED>
            <BED_NO _sqlCode="-610903">dataset:-610903.in_hospital_cd_1</BED_NO>
          </MST_BED>
        </A00002>
        <A10001/>
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
      <SYS_COOP_INI_DATA>
        <row _sqlCode="-610004">
          <INI_SECTION>dataset:-610004.ini_section</INI_SECTION>
          <INI_KEY>dataset:-610004.ini_key</INI_KEY>
          <INI_VALUE>dataset:-610004.ini_value</INI_VALUE>
        </row>
      </SYS_COOP_INI_DATA>
    </rootNode>
  </dump>
</coop_info>
', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -444}, {"patId": "patId", "sqlCode": -445}, {"ordNo": "ordNo", "sqlCode": -447}, {"patId": "patId", "sqlCode": -448}, {"ordNo": "ordNo", "sqlCode": -450}, {"ordNo": "ordNo", "sqlCode": -451}, {"ordNo": "ordNo", "sqlCode": -604901}, {"sqlCode": -610903, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -607001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -607003}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604166}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604168}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -604169}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -604172}, {"ordNo": "ordNo", "sqlCode": -604173}, {"key0": "key0", "sqlCode": -610004, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -610905, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604174}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604177}]}'::jsonb, '1', '0', -1, '2023-09-28 13:12:37.521', CURRENT_TIMESTAMP, 'CSI');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-6050001, 'C_hosp', 'exam_ord', '', 'S', 'cre', 'xml', 'CSI検査オーダ', 'MIRAIs', '検査オーダ', '1', '<coop_info>
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
        <DOCTOR_CD1>dataset:-610001.staff_cd1</DOCTOR_CD1>
        <!-- 医師2 -->
        <DOCTOR_CD2>dataset:-610001.staff_cd2</DOCTOR_CD2>
        <MST_PAT_GROUP>
          <!-- 科コード -->
          <IN_HOSPITAL_CD>dataset:-610905.in_hospital_cd_1</IN_HOSPITAL_CD>
        </MST_PAT_GROUP>
      </PAT_BASIC_INFO>
      <!-- 検査スケジュール -->
      <PAT_EXAMIN_SCHEDULE>
        <!-- 指示者 -->
        <DOCTOR_CODE>dataset:-610001.ind_user_id</DOCTOR_CODE>
        <!-- スタッフマスタ：指示者の値 -->
        <MST_STAFF>
          <STAFF_CD>dataset:-610001.ind_user_id</STAFF_CD>
          <!-- 職種コード -->
          <JOB_CLASS_CD>dataset:-610003.is_doctor</JOB_CLASS_CD>
        </MST_STAFF>
        <!-- 検査区分 -->
        <EXAM_DIVISION>dataset:-442.reg_order_class</EXAM_DIVISION>
        <!-- オーダ日時 -->
        <UP_DATE>dataset:-442.up_date</UP_DATE>
        <!-- オーダ入力者 -->
        <ORDER_STAFF>dataset:-610001.reg_staff</ORDER_STAFF>
        <!-- 更新者 -->
        <UPDATE_CODE>dataset:-610001.up_staff</UPDATE_CODE>
        <!-- 検査予定日 -->
        <EXAM_DATE>dataset:-442.reg_exam_date</EXAM_DATE>
        <!-- 検査セット -->
        <MST_EXAM_SET>
          <MST_EXAM_SET_DETAIL ID="$COUNT" _sqlCode="-443">
            <MST_EXAM_ITEM>
              <!-- 検査項目 -->
              <IN_HOSPITAL_CD2 NAME="CSI_検査1">dataset:-443.in_hospital_cd1</IN_HOSPITAL_CD2>
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
      <IND_DIALYSIS_COND>
        <CTL_NO>002</CTL_NO>
        <!-- 予定透析時間 -->
        <VALUE>dataset:-442.ind_dialysis_time</VALUE>
        <!--VALUE>240</VALUE-->
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
            <UPDATE_CODE>dataset:-610902.disp_user_id</UPDATE_CODE>
          </PAT_EXAMIN_SCHEDULE>
        </A00001>
        <A00002>
          <PAT_EXAMIN_SCHEDULE>
            <UPDATE_CODE>dataset:-610902.disp_user_id</UPDATE_CODE>
          </PAT_EXAMIN_SCHEDULE>
        </A00002>
        <A00003>
          <SYS_STAFF_AUTH>
            <ACL>dataset:-610904.acl</ACL>
          </SYS_STAFF_AUTH>
        </A00003>
        <A00004>
          <MST_BED>
            <BED_NO _sqlCode="-610903">dataset:-610903.in_hospital_cd_1</BED_NO>
          </MST_BED>
        </A00004>
        <A10001/>
        <A10002>
          <USER_TABLES>
            <TABLE_NAME>IF_EVENT_LOG</TABLE_NAME>
          </USER_TABLES>
        </A10002>
      </SYS_COOP_EXEC_DATA>
      <SYS_COOP_INI_DATA>
        <row _sqlCode="-610004">
          <INI_SECTION>dataset:-610004.ini_section</INI_SECTION>
          <INI_KEY>dataset:-610004.ini_key</INI_KEY>
          <INI_VALUE>dataset:-610004.ini_value</INI_VALUE>
        </row>
      </SYS_COOP_INI_DATA>
    </rootNode>
  </dump>
</coop_info>
', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -442}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -443}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -610001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -610003}, {"ctlNo": "ctlNo", "sqlCode": -610902}, {"sqlCode": -610903, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -610904}, {"key0": "key0", "sqlCode": -610004, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -610905, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', -1, '2023-09-28 13:12:37.521', CURRENT_TIMESTAMP, 'CSI');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-6050002, 'C_hosp', 'exam_ord', '', 'S', 'upd', 'xml', 'CSI検査オーダ', 'MIRAIs', '検査オーダ', '1', '<coop_info>
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
        <DOCTOR_CD1>dataset:-610001.staff_cd1</DOCTOR_CD1>
        <!-- 医師2 -->
        <DOCTOR_CD2>dataset:-610001.staff_cd2</DOCTOR_CD2>
        <MST_PAT_GROUP>
          <!-- 科コード -->
          <IN_HOSPITAL_CD>dataset:-610905.in_hospital_cd_1</IN_HOSPITAL_CD>
        </MST_PAT_GROUP>
      </PAT_BASIC_INFO>
      <!-- 検査スケジュール -->
      <PAT_EXAMIN_SCHEDULE>
        <!-- 指示者 -->
        <DOCTOR_CODE>dataset:-610001.ind_user_id</DOCTOR_CODE>
        <!-- スタッフマスタ：指示者の値 -->
        <MST_STAFF>
          <STAFF_CD>dataset:-610001.ind_user_id</STAFF_CD>
          <!-- 職種コード -->
          <JOB_CLASS_CD>dataset:-610003.is_doctor</JOB_CLASS_CD>
        </MST_STAFF>
        <!-- 検査区分 -->
        <EXAM_DIVISION>dataset:-442.reg_order_class</EXAM_DIVISION>
        <!-- オーダ日時 -->
        <UP_DATE>dataset:-442.up_date</UP_DATE>
        <!-- オーダ入力者 -->
        <ORDER_STAFF>dataset:-610001.reg_staff</ORDER_STAFF>
        <!-- 更新者 -->
        <UPDATE_CODE>dataset:-610001.up_staff</UPDATE_CODE>
        <!-- 検査予定日 -->
        <EXAM_DATE>dataset:-442.reg_exam_date</EXAM_DATE>
        <!-- 検査セット -->
        <MST_EXAM_SET>
          <MST_EXAM_SET_DETAIL ID="$COUNT" _sqlCode="-443">
            <MST_EXAM_ITEM>
              <!-- 検査項目 -->
              <IN_HOSPITAL_CD2 NAME="CSI_検査1">dataset:-443.in_hospital_cd1</IN_HOSPITAL_CD2>
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
      <IND_DIALYSIS_COND>
        <CTL_NO>002</CTL_NO>
        <!-- 予定透析時間 -->
        <VALUE>dataset:-442.ind_dialysis_time</VALUE>
        <!--VALUE>240</VALUE-->
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
        <A10001/>
        <A10002>
          <USER_TABLES>
            <TABLE_NAME>IF_EVENT_LOG</TABLE_NAME>
          </USER_TABLES>
        </A10002>
      </SYS_COOP_EXEC_DATA>
      <SYS_COOP_INI_DATA>
        <row _sqlCode="-610004">
          <INI_SECTION>dataset:-610004.ini_section</INI_SECTION>
          <INI_KEY>dataset:-610004.ini_key</INI_KEY>
          <INI_VALUE>dataset:-610004.ini_value</INI_VALUE>
        </row>
      </SYS_COOP_INI_DATA>
    </rootNode>
  </dump>
</coop_info>
', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -442}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -443}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -610001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -610003}, {"key0": "key0", "sqlCode": -610004, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -610905, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', -1, '2023-09-28 13:12:37.521', CURRENT_TIMESTAMP, 'CSI');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-6050003, 'C_hosp', 'exam_ord', '', 'S', 'del', 'xml', 'CSI検査オーダ', 'MIRAIs', '検査オーダ', '1', '<coop_info>
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
        <DOCTOR_CD1>dataset:-610001.staff_cd1</DOCTOR_CD1>
        <!-- 医師2 -->
        <DOCTOR_CD2>dataset:-610001.staff_cd2</DOCTOR_CD2>
        <MST_PAT_GROUP>
          <!-- 科コード -->
          <IN_HOSPITAL_CD>dataset:-610905.in_hospital_cd_1</IN_HOSPITAL_CD>
        </MST_PAT_GROUP>
      </PAT_BASIC_INFO>
      <!-- 検査スケジュール -->
      <PAT_EXAMIN_SCHEDULE>
        <!-- 指示者 -->
        <DOCTOR_CODE>dataset:-610001.ind_user_id</DOCTOR_CODE>
        <!-- スタッフマスタ：指示者の値 -->
        <MST_STAFF>
          <STAFF_CD>dataset:-610001.ind_user_id</STAFF_CD>
          <!-- 職種コード -->
          <JOB_CLASS_CD>dataset:-610003.is_doctor</JOB_CLASS_CD>
        </MST_STAFF>
        <!-- 検査区分 -->
        <EXAM_DIVISION>dataset:-442.reg_order_class</EXAM_DIVISION>
        <!-- オーダ日時 -->
        <UP_DATE>dataset:-442.up_date</UP_DATE>
        <!-- オーダ入力者 -->
        <ORDER_STAFF>dataset:-610001.reg_staff</ORDER_STAFF>
        <!-- 更新者 -->
        <UPDATE_CODE>dataset:-610902.disp_user_id</UPDATE_CODE>
        <!--UPDATE_CODE>D100</UPDATE_CODE-->
        <!-- 検査予定日 -->
        <EXAM_DATE>dataset:-442.reg_exam_date</EXAM_DATE>
        <!-- 検査セット -->
        <MST_EXAM_SET>
          <MST_EXAM_SET_DETAIL ID="$COUNT" _sqlCode="-443">
            <MST_EXAM_ITEM>
              <!-- 検査項目 -->
              <IN_HOSPITAL_CD2 NAME="CSI_検査1">dataset:-443.in_hospital_cd1</IN_HOSPITAL_CD2>
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
      <IND_DIALYSIS_COND>
        <CTL_NO>002</CTL_NO>
        <!-- 予定透析時間 -->
        <VALUE>dataset:-442.ind_dialysis_time</VALUE>
        <!--VALUE>240</VALUE-->
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
        <EXAM_DATE>dataset:-610901.base_date</EXAM_DATE>
        <!-- 検査区分 -->
        <EXAM_DIVISION>dataset:-442.reg_order_class</EXAM_DIVISION>
        <!-- 検査セットコード -->
        <EXAM_SET_CD>dataset:-442.exam_set_cd</EXAM_SET_CD>
      </血液検査送信>
      <SYS_COOP_EXEC_DATA>
        <A00001>
          <PAT_EXAMIN_SCHEDULE>
            <UPDATE_CODE>dataset:-610902.disp_user_id</UPDATE_CODE>
          </PAT_EXAMIN_SCHEDULE>
        </A00001>
        <A00002>
          <PAT_EXAMIN_SCHEDULE>
            <UPDATE_CODE>dataset:-610902.disp_user_id</UPDATE_CODE>
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
        <A10001/>
        <A10002>
          <USER_TABLES>
            <TABLE_NAME>IF_EVENT_LOG</TABLE_NAME>
          </USER_TABLES>
        </A10002>
      </SYS_COOP_EXEC_DATA>
      <SYS_COOP_INI_DATA>
        <row _sqlCode="-610004">
          <INI_SECTION>dataset:-610004.ini_section</INI_SECTION>
          <INI_KEY>dataset:-610004.ini_key</INI_KEY>
          <INI_VALUE>dataset:-610004.ini_value</INI_VALUE>
        </row>
      </SYS_COOP_INI_DATA>
    </rootNode>
  </dump>
</coop_info>
', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -442}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -443}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -610001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -610003}, {"ctlNo": "ctlNo", "sqlCode": -610901}, {"ctlNo": "ctlNo", "sqlCode": -610902}, {"key0": "key0", "sqlCode": -610004, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -610905, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', -1, '2023-09-28 13:12:37.521', CURRENT_TIMESTAMP, 'CSI');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-6060003, 'C_hosp', 'exam_rst', '', 'R', 'all', 'xml', 'CSI検査結果', 'MIRAIs', 'テスト用', '1', '<rootNode>

    <CRUD>col:$journal.const.crud,json:{&quot;1&quot;:&quot;&quot;,&quot;2&quot;:&quot;&quot;,&quot;3&quot;:&quot;&quot;}</CRUD>

    <RST_EXAMIN_HST>

        <DISP_PATID>col:$journal.pat_personal_main.hosp_pat_id</DISP_PATID><!-- 患者番号 -->

        <REG_EXAM_DATE>col:$journal.pat_exam_main.reg_exam_date</REG_EXAM_DATE><!-- 登録時検査日時 -->

        <REG_ORDER_CLASS>col:$journal.pat_exam_main.reg_order_class</REG_ORDER_CLASS><!-- 登録時検査区分 -->

    </RST_EXAMIN_HST>

    <RST_EXAMIN_HST_DETAIL detail="検体検査結果,ID">

    </RST_EXAMIN_HST_DETAIL>

</rootNode>', '{"key": {"検体検査結果": {"_DEFAULT": "all"}}, "dataset": {"sqlGroup1": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}], "sqlGroup2": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "pat_exam_main", "ctl_no": "1", "sqlCode": 5101, "insertResult": "{@examMainCd:'''', @patId:'''', @facilityCd:'''', @ordNo:'''', @fnPatId:'''', @regExamDate_Date:'''', @regOrderClass:'''', @examStatus:''1'', @orderComment:'''', @orderExamSetInfoValue:''[]'', @examOrderInfoValue:''[]'', @orderLabelInfoValue:''[]'', @dataGenClass:''2'', @resultExamDate_Date:'''', @resultComment:'''', @examResultInfoValue:''[]'', @copOrderNo1:'''', @copOrderNo2:'''', @isLock:''1'', @indUserId:'''', @isDel:'''', @regDate:'''', @regStaff:'''', @upDate:'''', @upStaff:'''', @isOrder:'''', @examWeek:'''', @examFrom:'''', @examTo:'''', @examPattern:''''}", "updateResult": "{@examMainCd:''exam_main_cd'', @patId:''pat_id'', @facilityCd:''facility_cd'', @ordNo:''ord_no'', @fnPatId:''fn_pat_id'', @regExamDate_Date:''reg_exam_date'', @regOrderClass:''reg_order_class'', @examStatus:''exam_status'', @orderComment:''order_comment'', @orderExamSetInfoValue:''order_exam_set_info'', @examOrderInfoValue:''exam_order_info'', @orderLabelInfoValue:''order_label_info'', @dataGenClass:''data_gen_class'', @resultExamDate_Date:''result_exam_date'', @resultComment:''result_comment'', @examResultInfoValue:''exam_result_info'', @copOrderNo1:''cop_order_no1'', @copOrderNo2:''cop_order_no2'', @isLock:''is_lock'', @indUserId:''ind_user_id'', @isDel:''is_del'', @regDate:''reg_date'', @regStaff:''reg_staff'', @upDate:''up_date'', @upStaff:''up_staff'', @isOrder:''is_order'', @examWeek:''exam_week'', @examFrom:''exam_from'', @examTo:''exam_to'', @examPattern:''exam_pattern'', }", "@regOrderClass": "$journal.pat_exam_main.reg_order_class", "@regExamDate_Date": "$journal.pat_exam_main.reg_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.reg_exam_date"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "pat_exam_main", "ctl_no": "2", "sqlCode": 5102, "@regOrderClass": "$journal.pat_exam_main.reg_order_class", "@regExamDate_Date": "$journal.pat_exam_main.reg_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.reg_exam_date"}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "pat_exam_main", "ctl_no": "3", "sqlCode": 5103, "@regOrderClass": "$journal.pat_exam_main.reg_order_class", "@regExamDate_Date": "$journal.pat_exam_main.reg_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.reg_exam_date"}], "sqlGroup3": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#=#D", "table": "pat_exam_main", "ctl_no": "1", "sqlCode": 5101, "updateResult": "{@examMainCd:''exam_main_cd'', @patId:''pat_id'', @facilityCd:''facility_cd'', @ordNo:''ord_no'', @fnPatId:''fn_pat_id'', @regExamDate:''reg_exam_date'', @regOrderClass:''reg_order_class'', @examStatus:''exam_status'', @orderComment:''order_comment'', @orderExamSetInfoValue:''order_exam_set_info'', @examOrderInfoValue:''exam_order_info'', @orderLabelInfoValue:''order_label_info'', @dataGenClass:''data_gen_class'', @resultExamDate:''result_exam_date'', @resultComment:''result_comment'', @examResultInfoValue:''exam_result_info'', @copOrderNo1:''cop_order_no1'', @copOrderNo2:''cop_order_no2'', @isLock:''is_lock'', @indUserId:''ind_user_id'', @isDel:''is_del'', @regDate:''reg_date'', @regStaff:''reg_staff'', @upDate:''up_date'', @upStaff:''up_staff'', @isOrder:''is_order'', @examWeek:''exam_week'', @examFrom:''exam_from'', @examTo:''exam_to'', @examPattern:''exam_pattern'', }", "@regOrderClass": "$journal.pat_exam_main.reg_order_class", "@regExamDate_Date": "$journal.pat_exam_main.reg_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.reg_exam_date"}, {"crud": "U", "kind": "1", "note": "倫理削除処理", "judge": "$journal.const.crud#=#D", "table": "pat_exam_main", "ctl_no": "2", "sqlCode": 5201}], "sqlGroup4": [{"crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.crud#<>#D", "table": "pat_exam_main", "ctl_no": "1", "sqlCode": 5101, "updateResult": "{@nextDispOrder:''next_disp_order'', @examMainCd:''exam_main_cd'', @examResultInfoFlg:'''',@examResultInfoValue:''exam_result_info'',@examResultInfo.comCd:'''', @examResultInfo.dispOrder:'''', @examResultInfo.examClass:'''', @examResultInfo.freememo:'''', @examResultInfo.hl:'''', @examResultInfo.itemCd:'''', @examResultInfo.itemName:'''', @examResultInfo.jlac10Cd:'''', @examResultInfo.lower:'''', @examResultInfo.result:'''', @examResultInfo.resultDate:'''', @examResultInfo.type:'''', @examResultInfo.unit:'''', @examResultInfo.upper:''''}", "@regOrderClass": "$journal.pat_exam_main.reg_order_class", "@regExamDate_Date": "$journal.pat_exam_main.reg_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.reg_exam_date"}, {"Note": "json場合、[D]の設定が必要です。しかし、CSIの検査結果をクリアしません。judgeに[crud#=#NG]woを設定する。", "crud": "D", "kind": "1", "judge": "$journal.const.crud#=#NG", "table": "pat_exam_main", "ctl_no": "2", "sqlCode": 5301}, {"crud": "U", "key0": "key0", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "pat_exam_main", "ctl_no": "3", "sqlCode": -609201, "@examResultInfo.itemCd": "$journal.detail.pat_exam_main.exam_result_info.item_cd", "@examResultInfo.result": "$journal.detail.pat_exam_main.exam_result_info.result", "@examResultInfo.freememo": "$journal.detail.pat_exam_main.exam_result_info.freememo", "@examResultInfo.resultDate": "$journal.detail.pat_exam_main.exam_result_info.result_date"}]}, "json-key": {"{\"1\":\"\",\"2\":\"\",\"3\":\"\"}": {"1": "C", "2": "U", "3": "D"}}}'::jsonb, '1', '0', -1, '2023-12-21 19:53:52.561', CURRENT_TIMESTAMP, 'CSI');
