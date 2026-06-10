delete from mst_coop_layout where ctl_no in ('-6030001','-6030002','-6030003')
;
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
', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -444}, {"patId": "patId", "sqlCode": -445}, {"ordNo": "ordNo", "sqlCode": -447}, {"patId": "patId", "sqlCode": -448}, {"ordNo": "ordNo", "sqlCode": -450}, {"ordNo": "ordNo", "sqlCode": -451}, {"ordNo": "ordNo", "sqlCode": -604901}, {"sqlCode": -610903, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -607001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -607003}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604166}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604168}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -604169}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -604170}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604171}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -604172}, {"ordNo": "ordNo", "sqlCode": -604173}, {"key0": "key0", "sqlCode": -610004, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -610905, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604174}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604177}]}'::jsonb, '1', '0', -1, '2023-09-28 13:12:37.521', CURRENT_TIMESTAMP, 'CSI');
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
', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -444}, {"patId": "patId", "sqlCode": -445}, {"ordNo": "ordNo", "sqlCode": -447}, {"patId": "patId", "sqlCode": -448}, {"ordNo": "ordNo", "sqlCode": -450}, {"ordNo": "ordNo", "sqlCode": -451}, {"ordNo": "ordNo", "sqlCode": -604901}, {"sqlCode": -610903, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -607001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -607003}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604166}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604168}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -604170}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604171}, {"ordNo": "ordNo", "sqlCode": -604173}, {"key0": "key0", "sqlCode": -610004, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -610905, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604174}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604177}]}'::jsonb, '1', '0', -1, '2023-09-28 13:12:37.521', CURRENT_TIMESTAMP, 'CSI');
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
      <RST_DIALYSIS_TREATMENT_HST _sqlCode="-604177" CTL_NO="dataset:-604177.disp_no" NAME="dataset:-604177.disp_name" _detail="medicine">
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
', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -444}, {"patId": "patId", "sqlCode": -445}, {"ordNo": "ordNo", "sqlCode": -447}, {"patId": "patId", "sqlCode": -448}, {"ordNo": "ordNo", "sqlCode": -450}, {"ordNo": "ordNo", "sqlCode": -451}, {"ordNo": "ordNo", "sqlCode": -604901}, {"sqlCode": -610903, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -607001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -607003}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604166}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604168}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -604169}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -604172}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -604170}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604171}, {"ordNo": "ordNo", "sqlCode": -604173}, {"key0": "key0", "sqlCode": -610004, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -610905, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604174}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604177}]}'::jsonb, '1', '0', -1, '2023-09-28 13:12:37.521', CURRENT_TIMESTAMP, 'CSI');