DELETE FROM ntss.mst_coop_layout WHERE ctl_no=-6030003;

INSERT INTO ntss.mst_coop_layout (ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-6030003, 'C_hosp', 'rst_dial', '', 'S', 'del', 'xml', 'CSI透析実績', 'MIRAIs', '実績送信', '1', '<coop_info>
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
        <DISP_PATID>dataset:-604182.disp_pat_id</DISP_PATID>
        <!-- 患者ID -->
        <PATID>dataset:-604182.pat_id</PATID>
        <!-- 患者名 -->
        <NAME>dataset:-604182.pat_name</NAME>
        <!-- 医師1 -->
        <DOCTOR_CD1>dataset:-604182.doctor_cd1</DOCTOR_CD1>
        <!-- 医師2 -->
        <DOCTOR_CD2>dataset:-604182.doctor_cd2</DOCTOR_CD2>
        <MST_PAT_GROUP>
          <!--患者基本情報・患者グループの院内コード-->
          <IN_HOSPITAL_CD>dataset:-604182.pat_group_in_hospital_cd</IN_HOSPITAL_CD>
        </MST_PAT_GROUP>
        <!--患者基本情報・透析導入日-->
        <DIAL_START_DATE>dataset:-604182.dial_start_date</DIAL_START_DATE>
        <!--患者基本情報・透析困難有無-->
        <DIAL_DIFF>dataset:-604182.dial_diff</DIAL_DIFF>
        <MST_DIAL_DIFF_COMENT>
          <!--患者基本情報・マスタ透析困難コメント・透析困難コメント-->
          <DIAL_DIFF_COMMENT>dataset:-604182.dial_diff_comment</DIAL_DIFF_COMMENT>
        </MST_DIAL_DIFF_COMENT>
        <!--患者基本情報・入外区分-->
        <INOUT_FLG>dataset:-604182.in_out_class</INOUT_FLG>
        <MST_WARD>
          <!--患者情報基本情報・病棟コード-->
          <IN_HOSPITAL_CD>dataset:-604182.ward_in_hospital_cd_1</IN_HOSPITAL_CD>
        </MST_WARD>
      </PAT_BASIC_INFO>
      <!-- 2.透析実績履歴 -->
      <RST_DIALYSIS_HST>
        <!--透析実績履歴・透析番号-->
        <DIALYSIS_NO>dataset:-604183.rst_dialysis_no</DIALYSIS_NO>
        <!--透析実績履歴・版番号-->
        <EDITION>dataset:-604183.rst_edition</EDITION>
        <!--透析実績履歴・透析開始日時-->
        <START_DATE>dataset:-604183.rst_start_date</START_DATE>
        <!--透析実績履歴・透析終了日時-->
        <END_DATE>dataset:-604183.rst_end_date</END_DATE>
        <!-- ベッドコード -->
        <BED_NO>dataset:-604183.bed_no</BED_NO>
        <MST_KUR>
          <!--透析実績履歴・クールマスタ・クール名-->
          <KUR_NAME>dataset:-604183.kur_name</KUR_NAME>
        </MST_KUR>
        <!--透析実績履歴・透析時間-->
        <DIALYSIS_TIME>dataset:-604183.rst_dialysis_time</DIALYSIS_TIME>
        <!--透析実績履歴・病棟コード-->
        <WARD_CD>dataset:-604183.ward_cd</WARD_CD>
        <MST_WARD>
          <!--透析実績履歴・病棟マスタ・院内コード-->
          <IN_HOSPITAL_CD>dataset:-604183.ward_in_hospital_cd_1</IN_HOSPITAL_CD>
        </MST_WARD>
      </RST_DIALYSIS_HST>
      <!-- 3.透析実績版番管理 -->
      <RST_DIALYSIS_EDITION>
        <!--透析実績版番管理.版確定者-->
        <DECIDER>dataset:-604184.decider</DECIDER>
        <!--スタッフマスタ:版確定者-->
        <MST_STAFF>
          <STAFF_CD>dataset:-604184.staff_cd</STAFF_CD>
          <!-- スタッフマスタ.職種コード-->
          <JOB_CLASS_CD>dataset:-604184.job_class_cd</JOB_CLASS_CD>
        </MST_STAFF>
      </RST_DIALYSIS_EDITION>
      <RST_RECEIPT_MEMO_HST _sqlCode="-604185" NAME="dataset:-604185.detail_id" >
        <!-- 4.透析困難コメント:主たる透析困難コメントフラグ-->
        <!-- 透析困難コメント -->
        <DIVISION>dataset:-604185.division</DIVISION>
        <ADD_FLG>dataset:-604185.is_dial_diff</ADD_FLG>
        <MAIN_DIAL_DIFF>dataset:-604185.is_main</MAIN_DIAL_DIFF>
        <ITEM_NAME>dataset:-604185.dialysis_difficulty_name</ITEM_NAME>
      </RST_RECEIPT_MEMO_HST>
      <RST_DIALYSIS_COND_HST _sqlCode="-604186" CTL_NO="dataset:-604186.item_cd" NAME="dataset:-604186.item_name">
        <!-- 5.透析条件履歴:透析条件項目コード -->
        <!-- 項目コード -->
        <CTL_NO>dataset:-604186.item_cd</CTL_NO>
        <!-- 設定値 -->
        <VALUE>dataset:-604186.item_value</VALUE>
        <!-- 治療方法マスタ -->
        <MST_TREAT_ITEM>
          <!-- 治療項目マスタ・院内コード:複数データの場合，カンマ[,]区切り -->
          <IN_HOSPITAL_CD>dataset:-604186.mtt_in_hospital_cd</IN_HOSPITAL_CD>
          <!-- 治療方法名称 -->
          <TREAT_ITEM_NAME>dataset:-604186.mtt_treatment_name</TREAT_ITEM_NAME>
        </MST_TREAT_ITEM>
        <!-- 薬剤マスタ -->
        <MST_MEDICINE>
          <!-- 薬剤マスタ・注射フラグ -->
          <SHOT>dataset:-604186.med_is_shot</SHOT>
          <!-- 院内コード -->
          <IN_HOSPITAL_CD>dataset:-604186.med_in_hospital_cd</IN_HOSPITAL_CD>
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
          <IN_HOSPITAL_CD>dataset:-604186.mdr_in_hospital_cd</IN_HOSPITAL_CD>
        </MST_DIALYZER>
        <!-- 医療材料マスタ -->
        <MST_EQUIPMENT>
          <!-- 院内コード -->
          <IN_HOSPITAL_CD>dataset:-604186.meqa_in_hospital_cd</IN_HOSPITAL_CD>
        </MST_EQUIPMENT>
      </RST_DIALYSIS_COND_HST>
      <RST_DIALYSIS_COND_HST CTL_NO="dataset:-604196.item_cd" NAME="dataset:-604196.item_name">
        <!-- 5.透析条件履歴:透析条件項目コード -->
        <!-- 項目コード -->
        <CTL_NO>dataset:-604196.item_cd</CTL_NO>
        <!-- 設定値 -->
        <VALUE>dataset:-604196.item_value</VALUE>
        <!-- 治療方法マスタ -->
        <MST_TREAT_ITEM>
          <!-- 治療項目マスタ・院内コード:複数データの場合，カンマ[,]区切り -->
          <IN_HOSPITAL_CD>dataset:-604196.mtt_in_hospital_cd</IN_HOSPITAL_CD>
          <!-- 治療方法名称 -->
          <TREAT_ITEM_NAME>dataset:-604196.mtt_treatment_name</TREAT_ITEM_NAME>
        </MST_TREAT_ITEM>
        <!-- 薬剤マスタ -->
        <MST_MEDICINE>
          <!-- 薬剤マスタ・注射フラグ -->
          <SHOT>dataset:-604196.med_is_shot</SHOT>
          <!-- 院内コード -->
          <IN_HOSPITAL_CD>dataset:-604196.med_in_hospital_cd</IN_HOSPITAL_CD>
        </MST_MEDICINE>
        <MST_SET_MEDI_NAME _sqlCode="-604197">
          <!-- ※NTSSに薬剤セットが無し -->
          <!-- 薬剤セットマスタ -->
          <MST_SET_MEDICINE>
            <!-- 薬剤マスタ -->
            <MST_MEDICINE>
              <!-- 薬剤マスタ・注射フラグ -->
              <SHOT/>
              <!-- 院内コード -->
              <IN_HOSPITAL_CD>dataset:-604197.mix_med_in_hospital_cd</IN_HOSPITAL_CD>
            </MST_MEDICINE>
            <!-- 使用薬剤数 -->
            <MEDI_USE_NUM>dataset:-604197.mix_amout</MEDI_USE_NUM>
          </MST_SET_MEDICINE>
        </MST_SET_MEDI_NAME>
        <!-- ダイアライザマスタ -->
        <MST_DIALYZER>
          <!-- 院内コード -->
          <IN_HOSPITAL_CD>dataset:-604196.mdr_in_hospital_cd</IN_HOSPITAL_CD>
        </MST_DIALYZER>
        <!-- 医療材料マスタ -->
        <MST_EQUIPMENT>
          <!-- 院内コード -->
          <IN_HOSPITAL_CD>dataset:-604196.meqa_in_hospital_cd</IN_HOSPITAL_CD>
        </MST_EQUIPMENT>
      </RST_DIALYSIS_COND_HST>
      <RST_DIALYSIS_EQUIP_HST _sqlCode="-604187">
        <AMOUNT>dataset:-604187.amount</AMOUNT>
        <MST_EQUIPMENT>
          <IN_HOSPITAL_CD>dataset:-604187.in_hospital_cd_1</IN_HOSPITAL_CD>
        </MST_EQUIPMENT>
      </RST_DIALYSIS_EQUIP_HST>
      <RST_DIALYSIS_MEDICATION_HST _sqlCode="-604188" CTL_NO="dataset:-604188.ctl_no" _detail="medicine">
      </RST_DIALYSIS_MEDICATION_HST>
      <RST_DIALYSIS_TREATMENT_HST _sqlCode="-604189" CTL_NO="dataset:-604189.disp_no" NAME="dataset:-604189.disp_name" _detail="medicine">
      </RST_DIALYSIS_TREATMENT_HST>
      <EXAM_FREE_DATA_DETAIL>dataset:-604190.exam_free_data</EXAM_FREE_DATA_DETAIL>
      <SYS_COOP_EXEC_DATA>
        <A00001>
          <SYS_STAFF_AUTH>
            <ACL>dataset:-604190.acl</ACL>
          </SYS_STAFF_AUTH>
        </A00001>
        <A00002>
          <MST_BED>
            <BED_NO _sqlCode="-604191">dataset:-604191.in_hospital_cd_1</BED_NO>
          </MST_BED>
        </A00002>
        <A10001/>
        <A10002>
          <USER_TABLES>
            <TABLE_NAME>dataset:-604190.if_event_log</TABLE_NAME>
          </USER_TABLES>
        </A10002>
        <A20001>
          <SYS_SYSTEM_DEFINE>
            <VALUE>dataset:-604190.sys_system_value</VALUE>
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
', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"key0": "key0", "sqlCode": -610004, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -604182, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -604183, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -604184, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -604185, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -604186, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -604187, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -604188, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -604189, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -604190, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -604191, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -604192, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -604196, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -604197, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', -1, current_timestamp, current_timestamp, 'CSI');