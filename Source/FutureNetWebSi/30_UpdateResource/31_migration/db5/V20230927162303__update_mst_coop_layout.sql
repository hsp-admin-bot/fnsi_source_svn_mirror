DELETE FROM ntss.mst_coop_layout
WHERE ctl_no IN (-6010001,-6010002,-6010003,-6020001,-6020002,-6020003,-6030001,-6030002,-6030003,-6050001,-6050002,-6050003,-6060001,-6060002,-6060003)
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
        <!--INOUT_FLG>dataset:-200001.in_out_class</INOUT_FLG-->
        <INOUT_FLG>0</INOUT_FLG>
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
      <RST_DIALYSIS_MEDICATION_HST _sqlCode="-604167" CTL_NO="dataset:-604167.ctl_no">
        <!-- 6.投薬履歴 -->
        <!-- 指示実施フラグ -->
        <EFFECT_FLG>dataset:-604167.effect_flg</EFFECT_FLG>
        <!-- 薬剤コード -->
        <SET_MEDICINE_CD>dataset:-604167.medicine_cd</SET_MEDICINE_CD>
        <!-- 手技コード -->
        <PROCEDURE_CD>dataset:-604167.procedure_cd</PROCEDURE_CD>
        <!-- 実施日 -->
        <EFFECT_DATE>dataset:-604167.effect_date</EFFECT_DATE>
        <!-- セット薬剤使用フラグ -->
        <SET_MEDICINE_FLG>dataset:-604167.set_medicine_flg</SET_MEDICINE_FLG>
        <!-- 使用量 -->
        <AMOUNT>dataset:-604167.amount</AMOUNT>
        <!-- 薬剤マスタ -->
        <MST_MEDICINE>
          <!-- 注射フラグ -->
          <SHOT>dataset:-604167.mmd_is_shot</SHOT>
          <!-- 薬剤コード(院内コード) -->
          <IN_HOSPITAL_CD>dataset:-604167.mmd_in_hospital_cd_1</IN_HOSPITAL_CD>
          <!-- 薬剤コード(院内コード2) -->
          <IN_HOSPITAL_CD2>dataset:-604167.mmd_in_hospital_cd_2</IN_HOSPITAL_CD2>
          <!-- 薬剤コード -->
          <MEDICINE_CD>dataset:-604167.mmd_medicine_cd</MEDICINE_CD>
          <!-- 薬剤グループコード -->
          <MEDICINE_GROUP_CD>dataset:-604167.class_cd</MEDICINE_GROUP_CD>
        </MST_MEDICINE>
        <!-- 手技マスタ -->
        <MST_PROCEDURE>
          <!-- ルート項目コード(院内コード) -->
          <IN_HOSPITAL_CD1>dataset:-604167.mp_in_hospital_cd_1</IN_HOSPITAL_CD1>
          <!-- 投与方法項目コード(院内コード) -->
          <IN_HOSPITAL_CD2>dataset:-604167.mp_in_hospital_cd_2</IN_HOSPITAL_CD2>
        </MST_PROCEDURE>
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
              <!-- 薬剤グループコード -->
              <MEDICINE_GROUP_CD/>
            </MST_MEDICINE>
            <!-- 手技コード -->
            <PROCEDURE_CD/>
            <!-- 手技マスタ -->
            <MST_PROCEDURE>
              <!-- ルート項目コード(院内コード) -->
              <IN_HOSPITAL_CD1/>
              <!-- 投与方法項目コード(院内コード) -->
              <IN_HOSPITAL_CD2/>
            </MST_PROCEDURE>
            <!-- 使用薬剤数 -->
            <MEDI_USE_NUM/>
          </MST_SET_MEDICINE>
          <!-- 院内コード２ -->
          <IN_HOSPITAL_CD2/>
        </MST_SET_MEDI_NAME>
      </RST_DIALYSIS_MEDICATION_HST>
      <RST_DIALYSIS_TREATMENT_HST _sqlCode="-604168" CTL_NO="dataset:-604168.disp_no" NAME="dataset:-604168.disp_name">
        <!-- 7.愁訴処置 -->
        <!-- 薬剤コード -->
        <TREAT_MEDICINE_CD>dataset:-604168.medicine_cd</TREAT_MEDICINE_CD>
        <!-- 手技コード -->
        <PROCEDURE_CD>dataset:-604168.procedure_cd</PROCEDURE_CD>
        <!-- 入力数 -->
        <AMOUNT>dataset:-604168.amount</AMOUNT>
        <!-- 酸素吸入量(処置区分) -->
        <TREAT_CLASS>dataset:-604168.treat_class</TREAT_CLASS>
        <!-- 酸素吸入量(実績番号) -->
        <RESULT_NO>dataset:-604168.result_no</RESULT_NO>
        <!-- 酸素吸入量(発生日時) -->
        <OCCUR_DATE>dataset:-604168.occur_date_start</OCCUR_DATE>
        <!-- 酸素吸入量(使用量) -->
        <OXYGEN_AMOUNT>dataset:-604168.oxygen_amount</OXYGEN_AMOUNT>
        <!-- 酸素吸入量(酸素吸入開始日時) -->
        <OXYGEN_START>dataset:-604168.oxygen_start_new</OXYGEN_START>
        <!-- 酸素吸入量(酸素吸入時間) -->
        <OXYGEN_TIME>dataset:-604168.oxygen_time_new</OXYGEN_TIME>
        <!-- 薬剤マスタ -->
        <MST_MEDICINE>
          <!-- 注射フラグ -->
          <SHOT>dataset:-604168.mmd_is_shot</SHOT>
          <!-- 薬剤コード(院内コード) -->
          <IN_HOSPITAL_CD>dataset:-604168.mmd_in_hospital_cd_1</IN_HOSPITAL_CD>
          <!-- 薬剤コード(院内コード2) -->
          <IN_HOSPITAL_CD2>dataset:-604168.mmd_in_hospital_cd_2</IN_HOSPITAL_CD2>
          <!-- 薬剤コード -->
          <MEDICINE_CD>dataset:-604168.mmd_medicine_cd</MEDICINE_CD>
          <!-- 薬剤グループコード -->
          <MEDICINE_GROUP_CD>dataset:-604168.mmd_class_cd</MEDICINE_GROUP_CD>
        </MST_MEDICINE>
        <MST_PROCEDURE>
          <!-- ルート項目コード(院内コード) -->
          <IN_HOSPITAL_CD1>dataset:-604168.mp_in_hospital_cd_1</IN_HOSPITAL_CD1>
          <!-- 投与方法項目コード(院内コード) -->
          <IN_HOSPITAL_CD2>dataset:-604168.mp_in_hospital_cd_2</IN_HOSPITAL_CD2>
        </MST_PROCEDURE>
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
              <!-- 薬剤グループコード -->
              <MEDICINE_GROUP_CD/>
            </MST_MEDICINE>
            <!-- 手技コード -->
            <PROCEDURE_CD/>
            <!-- 手技マスタ -->
            <MST_PROCEDURE>
              <!-- ルート項目コード(院内コード) -->
              <IN_HOSPITAL_CD1>dataset:-604168.mp_in_hospital_cd_1</IN_HOSPITAL_CD1>
              <!-- 投与方法項目コード(院内コード) -->
              <IN_HOSPITAL_CD2>dataset:-604168.mp_in_hospital_cd_2</IN_HOSPITAL_CD2>
            </MST_PROCEDURE>
            <!-- 使用薬剤数 -->
            <MEDI_USE_NUM/>
          </MST_SET_MEDICINE>
          <!-- 院内コード２ -->
          <IN_HOSPITAL_CD2>dataset:-604168.mp_in_hospital_cd_2</IN_HOSPITAL_CD2>
        </MST_SET_MEDI_NAME>
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
', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -444}, {"patId": "patId", "sqlCode": -445}, {"ordNo": "ordNo", "sqlCode": -447}, {"patId": "patId", "sqlCode": -448}, {"ordNo": "ordNo", "sqlCode": -450}, {"ordNo": "ordNo", "sqlCode": -451}, {"ordNo": "ordNo", "sqlCode": -604901}, {"sqlCode": -610903, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -607001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -607003}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604166}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604167}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604168}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604170}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604171}, {"sqlCode": -610004, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', 5843, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP ,'');
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
      <RST_DIALYSIS_MEDICATION_HST _sqlCode="-604167" CTL_NO="dataset:-604167.ctl_no">
        <!-- 6.投薬履歴 -->
        <!-- 指示実施フラグ -->
        <EFFECT_FLG>dataset:-604167.effect_flg</EFFECT_FLG>
        <!-- 薬剤コード -->
        <SET_MEDICINE_CD>dataset:-604167.medicine_cd</SET_MEDICINE_CD>
        <!-- 手技コード -->
        <PROCEDURE_CD>dataset:-604167.procedure_cd</PROCEDURE_CD>
        <!-- 実施日 -->
        <EFFECT_DATE>dataset:-604167.effect_date</EFFECT_DATE>
        <!-- セット薬剤使用フラグ -->
        <SET_MEDICINE_FLG>dataset:-604167.set_medicine_flg</SET_MEDICINE_FLG>
        <!-- 使用量 -->
        <AMOUNT>dataset:-604167.amount</AMOUNT>
        <!-- 薬剤マスタ -->
        <MST_MEDICINE>
          <!-- 注射フラグ -->
          <SHOT>dataset:-604167.mmd_is_shot</SHOT>
          <!-- 薬剤コード(院内コード) -->
          <IN_HOSPITAL_CD>dataset:-604167.mmd_in_hospital_cd_1</IN_HOSPITAL_CD>
          <!-- 薬剤コード(院内コード2) -->
          <IN_HOSPITAL_CD2>dataset:-604167.mmd_in_hospital_cd_2</IN_HOSPITAL_CD2>
          <!-- 薬剤コード -->
          <MEDICINE_CD>dataset:-604167.mmd_medicine_cd</MEDICINE_CD>
          <!-- 薬剤グループコード -->
          <MEDICINE_GROUP_CD>dataset:-604167.class_cd</MEDICINE_GROUP_CD>
        </MST_MEDICINE>
        <!-- 手技マスタ -->
        <MST_PROCEDURE>
          <!-- ルート項目コード(院内コード) -->
          <IN_HOSPITAL_CD1>dataset:-604167.mp_in_hospital_cd_1</IN_HOSPITAL_CD1>
          <!-- 投与方法項目コード(院内コード) -->
          <IN_HOSPITAL_CD2>dataset:-604167.mp_in_hospital_cd_2</IN_HOSPITAL_CD2>
        </MST_PROCEDURE>
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
              <!-- 薬剤グループコード -->
              <MEDICINE_GROUP_CD/>
            </MST_MEDICINE>
            <!-- 手技コード -->
            <PROCEDURE_CD/>
            <!-- 手技マスタ -->
            <MST_PROCEDURE>
              <!-- ルート項目コード(院内コード) -->
              <IN_HOSPITAL_CD1/>
              <!-- 投与方法項目コード(院内コード) -->
              <IN_HOSPITAL_CD2/>
            </MST_PROCEDURE>
            <!-- 使用薬剤数 -->
            <MEDI_USE_NUM/>
          </MST_SET_MEDICINE>
          <!-- 院内コード２ -->
          <IN_HOSPITAL_CD2/>
        </MST_SET_MEDI_NAME>
      </RST_DIALYSIS_MEDICATION_HST>
      <RST_DIALYSIS_TREATMENT_HST _sqlCode="-604168" CTL_NO="dataset:-604168.disp_no" NAME="dataset:-604168.disp_name">
        <!-- 7.愁訴処置 -->
        <!-- 薬剤コード -->
        <TREAT_MEDICINE_CD>dataset:-604168.medicine_cd</TREAT_MEDICINE_CD>
        <!-- 手技コード -->
        <PROCEDURE_CD>dataset:-604168.procedure_cd</PROCEDURE_CD>
        <!-- 入力数 -->
        <AMOUNT>dataset:-604168.amount</AMOUNT>
        <!-- 酸素吸入量(処置区分) -->
        <TREAT_CLASS>dataset:-604168.treat_class</TREAT_CLASS>
        <!-- 酸素吸入量(実績番号) -->
        <RESULT_NO>dataset:-604168.result_no</RESULT_NO>
        <!-- 酸素吸入量(発生日時) -->
        <OCCUR_DATE>dataset:-604168.occur_date_start</OCCUR_DATE>
        <!-- 酸素吸入量(使用量) -->
        <OXYGEN_AMOUNT>dataset:-604168.oxygen_amount</OXYGEN_AMOUNT>
        <!-- 酸素吸入量(酸素吸入開始日時) -->
        <OXYGEN_START>dataset:-604168.oxygen_start_new</OXYGEN_START>
        <!-- 酸素吸入量(酸素吸入時間) -->
        <OXYGEN_TIME>dataset:-604168.oxygen_time_new</OXYGEN_TIME>
        <!-- 薬剤マスタ -->
        <MST_MEDICINE>
          <!-- 注射フラグ -->
          <SHOT>dataset:-604168.mmd_is_shot</SHOT>
          <!-- 薬剤コード(院内コード) -->
          <IN_HOSPITAL_CD>dataset:-604168.mmd_in_hospital_cd_1</IN_HOSPITAL_CD>
          <!-- 薬剤コード(院内コード2) -->
          <IN_HOSPITAL_CD2>dataset:-604168.mmd_in_hospital_cd_2</IN_HOSPITAL_CD2>
          <!-- 薬剤コード -->
          <MEDICINE_CD>dataset:-604168.mmd_medicine_cd</MEDICINE_CD>
          <!-- 薬剤グループコード -->
          <MEDICINE_GROUP_CD>dataset:-604168.mmd_class_cd</MEDICINE_GROUP_CD>
        </MST_MEDICINE>
        <MST_PROCEDURE>
          <!-- ルート項目コード(院内コード) -->
          <IN_HOSPITAL_CD1>dataset:-604168.mp_in_hospital_cd_1</IN_HOSPITAL_CD1>
          <!-- 投与方法項目コード(院内コード) -->
          <IN_HOSPITAL_CD2>dataset:-604168.mp_in_hospital_cd_2</IN_HOSPITAL_CD2>
        </MST_PROCEDURE>
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
              <!-- 薬剤グループコード -->
              <MEDICINE_GROUP_CD/>
            </MST_MEDICINE>
            <!-- 手技コード -->
            <PROCEDURE_CD/>
            <!-- 手技マスタ -->
            <MST_PROCEDURE>
              <!-- ルート項目コード(院内コード) -->
              <IN_HOSPITAL_CD1/>
              <!-- 投与方法項目コード(院内コード) -->
              <IN_HOSPITAL_CD2/>
            </MST_PROCEDURE>
            <!-- 使用薬剤数 -->
            <MEDI_USE_NUM/>
          </MST_SET_MEDICINE>
          <!-- 院内コード２ -->
          <IN_HOSPITAL_CD2/>
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
', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -444}, {"patId": "patId", "sqlCode": -445}, {"ordNo": "ordNo", "sqlCode": -447}, {"patId": "patId", "sqlCode": -448}, {"ordNo": "ordNo", "sqlCode": -450}, {"ordNo": "ordNo", "sqlCode": -451}, {"ordNo": "ordNo", "sqlCode": -604901}, {"sqlCode": -610903, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -607001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -607003}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604166}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604167}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604168}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604170}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604171}, {"sqlCode": -610004, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', 5843, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
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
          <IN_HOSPITAL_CD>dataset:-604169.kur_cd1</IN_HOSPITAL_CD>
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
      <RST_DIALYSIS_MEDICATION_HST _sqlCode="-604167" CTL_NO="dataset:-604167.ctl_no">
        <!-- 6.投薬履歴 -->
        <!-- 指示実施フラグ -->
        <EFFECT_FLG>dataset:-604167.effect_flg</EFFECT_FLG>
        <!-- 薬剤コード -->
        <SET_MEDICINE_CD>dataset:-604167.medicine_cd</SET_MEDICINE_CD>
        <!-- 手技コード -->
        <PROCEDURE_CD>dataset:-604167.procedure_cd</PROCEDURE_CD>
        <!-- 実施日 -->
        <EFFECT_DATE>dataset:-604167.effect_date</EFFECT_DATE>
        <!-- セット薬剤使用フラグ -->
        <SET_MEDICINE_FLG>dataset:-604167.set_medicine_flg</SET_MEDICINE_FLG>
        <!-- 使用量 -->
        <AMOUNT>dataset:-604167.amount</AMOUNT>
        <!-- 薬剤マスタ -->
        <MST_MEDICINE>
          <!-- 注射フラグ -->
          <SHOT>dataset:-604167.mmd_is_shot</SHOT>
          <!-- 薬剤コード(院内コード) -->
          <IN_HOSPITAL_CD>dataset:-604167.mmd_in_hospital_cd_1</IN_HOSPITAL_CD>
          <!-- 薬剤コード(院内コード2) -->
          <IN_HOSPITAL_CD2>dataset:-604167.mmd_in_hospital_cd_2</IN_HOSPITAL_CD2>
          <!-- 薬剤コード -->
          <MEDICINE_CD>dataset:-604167.mmd_medicine_cd</MEDICINE_CD>
          <!-- 薬剤グループコード -->
          <MEDICINE_GROUP_CD>dataset:-604167.class_cd</MEDICINE_GROUP_CD>
        </MST_MEDICINE>
        <!-- 手技マスタ -->
        <MST_PROCEDURE>
          <!-- ルート項目コード(院内コード) -->
          <IN_HOSPITAL_CD1>dataset:-604167.mp_in_hospital_cd_1</IN_HOSPITAL_CD1>
          <!-- 投与方法項目コード(院内コード) -->
          <IN_HOSPITAL_CD2>dataset:-604167.mp_in_hospital_cd_2</IN_HOSPITAL_CD2>
        </MST_PROCEDURE>
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
              <!-- 薬剤グループコード -->
              <MEDICINE_GROUP_CD/>
            </MST_MEDICINE>
            <!-- 手技コード -->
            <PROCEDURE_CD/>
            <!-- 手技マスタ -->
            <MST_PROCEDURE>
              <!-- ルート項目コード(院内コード) -->
              <IN_HOSPITAL_CD1/>
              <!-- 投与方法項目コード(院内コード) -->
              <IN_HOSPITAL_CD2/>
            </MST_PROCEDURE>
            <!-- 使用薬剤数 -->
            <MEDI_USE_NUM/>
          </MST_SET_MEDICINE>
          <!-- 院内コード２ -->
          <IN_HOSPITAL_CD2/>
        </MST_SET_MEDI_NAME>
      </RST_DIALYSIS_MEDICATION_HST>
      <RST_DIALYSIS_TREATMENT_HST _sqlCode="-604168" CTL_NO="dataset:-604168.disp_no" NAME="dataset:-604168.disp_name">
        <!-- 7.愁訴処置 -->
        <!-- 薬剤コード -->
        <TREAT_MEDICINE_CD>dataset:-604168.medicine_cd</TREAT_MEDICINE_CD>
        <!-- 手技コード -->
        <PROCEDURE_CD>dataset:-604168.procedure_cd</PROCEDURE_CD>
        <!-- 入力数 -->
        <AMOUNT>dataset:-604168.amount</AMOUNT>
        <!-- 酸素吸入量(処置区分) -->
        <TREAT_CLASS>dataset:-604168.treat_class</TREAT_CLASS>
        <!-- 酸素吸入量(実績番号) -->
        <RESULT_NO>dataset:-604168.result_no</RESULT_NO>
        <!-- 酸素吸入量(発生日時) -->
        <OCCUR_DATE>dataset:-604168.occur_date_start</OCCUR_DATE>
        <!-- 酸素吸入量(使用量) -->
        <OXYGEN_AMOUNT>dataset:-604168.oxygen_amount</OXYGEN_AMOUNT>
        <!-- 酸素吸入量(酸素吸入開始日時) -->
        <OXYGEN_START>dataset:-604168.oxygen_start_new</OXYGEN_START>
        <!-- 酸素吸入量(酸素吸入時間) -->
        <OXYGEN_TIME>dataset:-604168.oxygen_time_new</OXYGEN_TIME>
        <!-- 薬剤マスタ -->
        <MST_MEDICINE>
          <!-- 注射フラグ -->
          <SHOT>dataset:-604168.mmd_is_shot</SHOT>
          <!-- 薬剤コード(院内コード) -->
          <IN_HOSPITAL_CD>dataset:-604168.mmd_in_hospital_cd_1</IN_HOSPITAL_CD>
          <!-- 薬剤コード(院内コード2) -->
          <IN_HOSPITAL_CD2>dataset:-604168.mmd_in_hospital_cd_2</IN_HOSPITAL_CD2>
          <!-- 薬剤コード -->
          <MEDICINE_CD>dataset:-604168.mmd_medicine_cd</MEDICINE_CD>
          <!-- 薬剤グループコード -->
          <MEDICINE_GROUP_CD>dataset:-604168.mmd_class_cd</MEDICINE_GROUP_CD>
        </MST_MEDICINE>
        <MST_PROCEDURE>
          <!-- ルート項目コード(院内コード) -->
          <IN_HOSPITAL_CD1>dataset:-604168.mp_in_hospital_cd_1</IN_HOSPITAL_CD1>
          <!-- 投与方法項目コード(院内コード) -->
          <IN_HOSPITAL_CD2>dataset:-604168.mp_in_hospital_cd_2</IN_HOSPITAL_CD2>
        </MST_PROCEDURE>
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
              <!-- 薬剤グループコード -->
              <MEDICINE_GROUP_CD/>
            </MST_MEDICINE>
            <!-- 手技コード -->
            <PROCEDURE_CD/>
            <!-- 手技マスタ -->
            <MST_PROCEDURE>
              <!-- ルート項目コード(院内コード) -->
              <IN_HOSPITAL_CD1/>
              <!-- 投与方法項目コード(院内コード) -->
              <IN_HOSPITAL_CD2/>
            </MST_PROCEDURE>
            <!-- 使用薬剤数 -->
            <MEDI_USE_NUM/>
          </MST_SET_MEDICINE>
          <!-- 院内コード２ -->
          <IN_HOSPITAL_CD2/>
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
', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -444}, {"patId": "patId", "sqlCode": -445}, {"ordNo": "ordNo", "sqlCode": -447}, {"patId": "patId", "sqlCode": -448}, {"ordNo": "ordNo", "sqlCode": -450}, {"ordNo": "ordNo", "sqlCode": -451}, {"ordNo": "ordNo", "sqlCode": -604901}, {"sqlCode": -610903, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -607001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -607003}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604166}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604167}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604168}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -604169}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -604172}, {"sqlCode": -610004, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', 5843, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-6010002, 'C_hosp', 'profile', 'send_time', 'S', 'cre', 'xml', '定時一括送信機能（CSI患者プロファイル用）', 'MIRAIs', '患者プロファイル(定時)', '1', NULL, '{"dataset": [{"sqlCode": -2400, "facilityCd": "facilityCd", "PreSqlInfoItem": ["@ord_no", "@pat_id"]}]}'::jsonb, '1', '0', 5843, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-6010003, 'C_hosp', 'profile', '', 'R', 'all', 'xml', 'CSI患者プロファイル', 'MIRAIs', 'テスト用', '1', '<rootNode>
  <CRUD>col:$journal.const.crud,json:{"1":"","2":"","3":""}</CRUD>
  <PAT_BASIC_INFO>
    <DISP_PATID>col:$journal.pat_personal_main.hosp_pat_id</DISP_PATID>
    <!-- 患者番号 -->
    <NAME>col:$journal.pat_personal_main.pat_last_name</NAME>
    <!-- 患者氏名 -->
    <NAME_KANA>col:$journal.pat_personal_main.pat_last_name_kana</NAME_KANA>
    <!-- 患者カナ氏名 -->
    <BIRTHDAY>col:$journal.pat_personal_main.pat_birthday</BIRTHDAY>
    <!-- 生年月日 -->
    <SEX_CD>col:$journal.pat_personal_main.pat_sex</SEX_CD>
    <!-- 性別 -->
    <BLOOD_TYPE_ABO>col:$journal.pat_personal_main.pat_blood_type_abo</BLOOD_TYPE_ABO>
    <!-- ABO式コード -->
    <BLOOD_TYPE_RH>col:$journal.pat_personal_main.pat_blood_type_rh</BLOOD_TYPE_RH>
    <!-- RH式コード -->
    <INOUT_FLG>col:$journal.pat_personal_main.in_out_class</INOUT_FLG>
    <!-- 入外区分 -->
    <COURSE_CD>col:$journal.pat_main.medical_care_info.main_course_cd</COURSE_CD>
    <!-- 診療科コード -->
    <WARD_CD>col:$journal.pat_main.medical_care_info.ward_cd</WARD_CD>
    <!-- 病棟コード -->
    <DIE_DATE>col:$journal.pat_personal_main.die_date</DIE_DATE>
    <!-- 死亡日 -->
    <DIE_FLG>col:$journal.pat_personal_main.is_die</DIE_FLG>
    <!-- 死亡フラグ -->
  </PAT_BASIC_INFO>
  <PAT_CONTACT detail="患者連絡先情報,ID"/>
  <PAT_INFECT detail="患者感染症情報,ID"/>
</rootNode>
', '{"key": {"患者感染症情報": {"_DEFAULT": "all"}, "患者連絡先情報": {"1": "本人", "2": "勤務先", "3": "その他", "_DEFAULT": "その他"}}, "dataset": {"sqlGroup1": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "insertResult": "{@fnPatId:'''',@hospPatId:'''',@nkkPatId:'''',@facilityCd:'''',@patLastName:'''',@patFirstName:'''',@patLastNmKana:'''',@patFirstNmKana:'''',@patLastNmAlpha:'''',@patFirstNmAlpha:'''',@patBirthName:'''',@patBirthNmKana:'''',@patBirthNmAlpha:'''',@patBirthday:'''',@patSex:'''',@nationality:'''',@patBloodTypeAbo:'''',@patBloodTypeRh:'''',@patBloodTypeSerovar:'''',@inOutClass:'''',@isDie:'''',@dieCd:'''',@dieDate_Date:'''',@dialDiffComInfoValue:''[]'',@severityCd:'''',@transportCd:'''',@patContactInfoFlg:'''',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''[]'',@vendorContactInfoValue:''[]'',@insuranceInfoValue:''[]'',@primaryDiseaseCd:'''',@remoteMonitorService:'''',@remoteMonitorUserId:'''',@remoteMonitorUserPw:''''}", "updateResult": "{@fnPatId:''fn_pat_id'',@hospPatId:''hosp_pat_id'',@nkkPatId:''nkk_pat_id'',@facilityCd:''facility_cd'',@patLastName:''pat_last_name'',@patFirstName:''pat_first_name'',@patLastNmKana:''pat_last_name_kana'',@patFirstNmKana:''pat_first_name_kana'',@patLastNmAlpha:''pat_last_name_alpha'',@patFirstNmAlpha:''pat_first_name_alpha'',@patBirthName:''pat_birth_name'',@patBirthNmKana:''pat_birth_name_kana'',@patBirthNmAlpha:''pat_birth_name_alpha'',@patBirthday:''pat_birthday'',@patSex:''pat_sex'',@nationality:''nationality'',@patBloodTypeAbo:''pat_blood_type_abo'',@patBloodTypeRh:''pat_blood_type_rh'',@patBloodTypeSerovar:''pat_blood_type_serovar'',@inOutClass:''in_out_class'',@isDie:''is_die'',@dieCd:''die_cd'',@dieDate_Date:''die_date'',@dialDiffComInfoValue:''dial_diff_com_info'',@severityCd:''severity_cd'',@transportCd:''transport_cd'',@patContactInfoFlg:'''',@patContactInfoValue:''pat_contact_info'',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''other_contact_info'',@vendorContactInfoValue:''vendor_contact_info'',@insuranceInfoValue:''insurance_info'',@regDate:''reg_date'',@primaryDiseaseCd:''primary_disease_cd'',@remoteMonitorService:''remote_monitor_service'',@remoteMonitorUserId:''remote_monitor_user_id'',@remoteMonitorUserPw:''remote_monitor_user_pw''}", "ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"crud": "C", "kind": "0", "judge": "", "table": "pat_personal_main", "@isDie": "$journal.pat_personal_main.is_die", "ctl_no": "2", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": -603101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "$journal.pat_personal_main.in_out_class", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_last_name", "@dieDate_Date": "$journal.pat_personal_main.die_date", "@patFirstName": "$journal.pat_personal_main.pat_last_name", "@patLastNmKana": "$journal.pat_personal_main.pat_last_name_kana", "@patBloodTypeRh": "$journal.pat_personal_main.pat_blood_type_rh", "@patFirstNmKana": "$journal.pat_personal_main.pat_last_name_kana", "@patBloodTypeAbo": "$journal.pat_personal_main.pat_blood_type_abo", "@patContactInfo.tel1": "$journal.pat_personal_main.pat_contact_info.tel1", "@patContactInfo.ctlNo": "$journal.pat_personal_main.pat_contact_info.ctl_no", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address"}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_personal_main", "@isDie": "$journal.pat_personal_main.is_die", "ctl_no": "3", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": -603201, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "$journal.pat_personal_main.in_out_class", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_last_name", "@dieDate_Date": "$journal.pat_personal_main.die_date", "@patFirstName": "$journal.pat_personal_main.pat_last_name", "@patLastNmKana": "$journal.pat_personal_main.pat_last_name_kana", "@patBloodTypeRh": "$journal.pat_personal_main.pat_blood_type_rh", "@patFirstNmKana": "$journal.pat_personal_main.pat_last_name_kana", "@patBloodTypeAbo": "$journal.pat_personal_main.pat_blood_type_abo", "@patContactInfo.tel1": "$journal.pat_personal_main.pat_contact_info.tel1", "@patContactInfo.ctlNo": "$journal.pat_personal_main.pat_contact_info.ctl_no", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address"}], "sqlGroup2": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_main", "ctl_no": "1", "sqlCode": 1201, "insertResult": "{@patId:'''',@facilityCd:'''',@isSame:'''',@isImplant:'''',@isInfect:'''',@isDiabetes:'''',@isBloodSugerExam:'''',@inOutCurrentState:'''',@inOutPlanState:'''',@inOutPlanDate_Date:'''',@patMemoInfoValue:''[]'',@additionInfoValue:''[]'',@chargeStaffInfoValue:''[]'',@patGroupInfoValue:''[]'',@tabooAllergyInfoValue:''[]'',@infectInfoValue:''[]'',@implantInfoValue:''[]'',@tareInfoValue:''{}'',@offWaterInfoValue:''{}'',@deviceSetInfoValue:''{}'',@acceptanceStatusInfoValue:''[]'',@isWheelChair:'''',@medicalCareInfoFlg:'''',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.patDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:'''',@schExtStatus:'''',@cardIdm:'''',@oldUpDate_Date:''''}", "updateResult": "{@patId:''pat_id'',@facilityCd:''facility_cd'',@isSame:''is_same'',@isImplant:''is_implant'',@isInfect:''is_infect'',@isDiabetes:''is_diabetes'',@isBloodSugerExam:''is_blood_suger_exam'',@inOutCurrentState:''in_out_current_state'',@inOutPlanState:''in_out_plan_state'',@inOutPlanDate_Date:''in_out_plan_date'',@patMemoInfoValue:''pat_memo_info'',@additionInfoValue:''addition_info'',@chargeStaffInfoValue:''charge_staff_info'',@patGroupInfoValue:''pat_group_info'',@tabooAllergyInfoValue:''taboo_allergy_info'',@infectInfoValue:''infect_info'',@implantInfoValue:''implant_info'',@tareInfoValue:''tare_info'',@offWaterInfoValue:''off_water_info'',@deviceSetInfoValue:''device_set_info'',@acceptanceStatusInfoValue:''acceptance_status_info'',@isWheelChair:''is_wheel_chair'',@medicalCareInfoFlg:'''',@medicalCareInfoValue:''medical_care_info'',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.patDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:''sch_ext_end_date'',@schExtStatus:''sch_ext_status'',@cardIdm:''card_idm'',@oldUpDate_Date:''old_up_date''}"}, {"crud": "C", "kind": "0", "judge": "", "table": "pat_main", "ctl_no": "2", "sqlCode": -603102, "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd"}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_main", "@isDie": "$journal.pat_personal_main.is_die", "ctl_no": "3", "sqlCode": -603202, "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd"}], "sqlGroup3": [{"crud": "S", "kind": "0", "type": "json", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": -603001, "@lastName": "$journal.pat_personal_main.pat_contact_info.name", "@relationCd": "$journal.pat_personal_main.pat_contact_info.relation_cd", "updateResult": "{@otherContactInfoFlg:'''', @otherContactInfoValue:''other_contact_info'', @otherContactInfo.ctlNo:'''', @otherContactInfo.dispOrder:'''', @otherContactInfo.isKeyPerson:'''', @otherContactInfo.patId:'''', @otherContactInfo.lastName:'''', @otherContactInfo.firstName:'''', @otherContactInfo.lastNmKana:'''', @otherContactInfo.firstNmKana:'''', @otherContactInfo.relationCd:'''', @otherContactInfo.relationName:'''', @otherContactInfo.zipCd:'''', @otherContactInfo.address:'''', @otherContactInfo.eMail:'''', @otherContactInfo.workName:'''', @otherContactInfo.workTel:'''', @otherContactInfo.tel1:'''', @otherContactInfo.tel2:'''', @otherContactInfo.fax:'''', @otherContactInfo.memo1:'''', @otherContactInfo.memo2:'''', @vendorContactInfoFlg:'''', @vendorContactInfoValue:''vendor_contact_info'', @vendorContactInfo.ctlNo:'''', @vendorContactInfo.dispOrder:'''', @vendorContactInfo.companyName:'''', @vendorContactInfo.zipCd:'''', @vendorContactInfo.address:'''', @vendorContactInfo.companyTel:'''', @vendorContactInfo.fax:'''', @vendorContactInfo.workerLastName:'''', @vendorContactInfo.workerFirstName:'''', @vendorContactInfo.workerTel:'''', @vendorContactInfo.workerEMail:'''', @vendorContactInfo.memo1:'''', @vendorContactInfo.memo2:''''}", "@contactCtlNo": "$journal.pat_personal_main.pat_contact_info.ctl_no"}, {"crud": "U", "kind": "0", "@tel1": "$journal.pat_personal_main.pat_contact_info.tel1", "judge": "", "table": "pat_personal_main", "@zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "ctl_no": "2", "sqlCode": -603204, "@address": "$journal.pat_personal_main.pat_contact_info.address", "@lastName": "$journal.pat_personal_main.pat_contact_info.name", "@relationCd": "$journal.pat_personal_main.pat_contact_info.relation_cd"}], "sqlGroup4": [{"crud": "S", "kind": "0", "type": "json", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": -603001, "@lastName": "$journal.detail.pat_personal_main.other_contact_info.name", "@relationCd": "$journal.detail.pat_personal_main.other_contact_info.relation_cd", "updateResult": "{@otherContactInfoFlg:'''', @otherContactInfoValue:''other_contact_info'', @otherContactInfo.ctlNo:'''', @otherContactInfo.dispOrder:'''', @otherContactInfo.isKeyPerson:'''', @otherContactInfo.patId:'''', @otherContactInfo.lastName:'''', @otherContactInfo.firstName:'''', @otherContactInfo.lastNmKana:'''', @otherContactInfo.firstNmKana:'''', @otherContactInfo.relationCd:'''', @otherContactInfo.relationName:'''', @otherContactInfo.zipCd:'''', @otherContactInfo.address:'''', @otherContactInfo.eMail:'''', @otherContactInfo.workName:'''', @otherContactInfo.workTel:'''', @otherContactInfo.tel1:'''', @otherContactInfo.tel2:'''', @otherContactInfo.fax:'''', @otherContactInfo.memo1:'''', @otherContactInfo.memo2:'''', @vendorContactInfoFlg:'''', @vendorContactInfoValue:''vendor_contact_info'', @vendorContactInfo.ctlNo:'''', @vendorContactInfo.dispOrder:'''', @vendorContactInfo.companyName:'''', @vendorContactInfo.zipCd:'''', @vendorContactInfo.address:'''', @vendorContactInfo.companyTel:'''', @vendorContactInfo.fax:'''', @vendorContactInfo.workerLastName:'''', @vendorContactInfo.workerFirstName:'''', @vendorContactInfo.workerTel:'''', @vendorContactInfo.workerEMail:'''', @vendorContactInfo.memo1:'''', @vendorContactInfo.memo2:''''}", "@contactCtlNo": "$journal.detail.pat_personal_main.other_contact_info.ctl_no"}, {"crud": "U", "kind": "0", "@tel1": "$journal.detail.pat_personal_main.other_contact_info.tel1", "judge": "", "table": "pat_personal_main", "@zipCd": "$journal.detail.pat_personal_main.other_contact_info.zip_cd", "ctl_no": "2", "sqlCode": -603204, "@address": "$journal.detail.pat_personal_main.other_contact_info.address", "@lastName": "$journal.detail.pat_personal_main.other_contact_info.name", "@relationCd": "$journal.detail.pat_personal_main.other_contact_info.relation_cd"}], "sqlGroup5": [{"crud": "S", "kind": "0", "type": "json", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": -603001, "@lastName": "$journal.detail.pat_personal_main.vendor_contact_info.name", "@relationCd": "$journal.detail.pat_personal_main.vendor_contact_info.relation_cd", "updateResult": "{@otherContactInfoFlg:'''', @otherContactInfoValue:''other_contact_info'', @otherContactInfo.ctlNo:'''', @otherContactInfo.dispOrder:'''', @otherContactInfo.isKeyPerson:'''', @otherContactInfo.patId:'''', @otherContactInfo.lastName:'''', @otherContactInfo.firstName:'''', @otherContactInfo.lastNmKana:'''', @otherContactInfo.firstNmKana:'''', @otherContactInfo.relationCd:'''', @otherContactInfo.relationName:'''', @otherContactInfo.zipCd:'''', @otherContactInfo.address:'''', @otherContactInfo.eMail:'''', @otherContactInfo.workName:'''', @otherContactInfo.workTel:'''', @otherContactInfo.tel1:'''', @otherContactInfo.tel2:'''', @otherContactInfo.fax:'''', @otherContactInfo.memo1:'''', @otherContactInfo.memo2:'''', @vendorContactInfoFlg:'''', @vendorContactInfoValue:''vendor_contact_info'', @vendorContactInfo.ctlNo:'''', @vendorContactInfo.dispOrder:'''', @vendorContactInfo.companyName:'''', @vendorContactInfo.zipCd:'''', @vendorContactInfo.address:'''', @vendorContactInfo.companyTel:'''', @vendorContactInfo.fax:'''', @vendorContactInfo.workerLastName:'''', @vendorContactInfo.workerFirstName:'''', @vendorContactInfo.workerTel:'''', @vendorContactInfo.workerEMail:'''', @vendorContactInfo.memo1:'''', @vendorContactInfo.memo2:''''}", "@contactCtlNo": "$journal.detail.pat_personal_main.vendor_contact_info.ctl_no"}, {"crud": "U", "kind": "0", "@tel1": "$journal.detail.pat_personal_main.vendor_contact_info.tel1", "judge": "", "table": "pat_personal_main", "@zipCd": "$journal.detail.pat_personal_main.vendor_contact_info.zip_cd", "ctl_no": "2", "sqlCode": -603204, "@address": "$journal.detail.pat_personal_main.vendor_contact_info.address", "@lastName": "$journal.detail.pat_personal_main.vendor_contact_info.name", "@relationCd": "$journal.detail.pat_personal_main.vendor_contact_info.relation_cd"}], "sqlGroup6": [{"crud": "S", "kind": "0", "type": "json", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": -603002, "@lastName": "$journal.pat_personal_main.pat_contact_info.name", "@relationCd": "$journal.pat_personal_main.pat_contact_info.relation_cd", "updateResult": "{@otherContactInfoFlg:'''', @otherContactInfoValue:''other_contact_info'', @otherContactInfo.ctlNo:'''', @otherContactInfo.dispOrder:'''', @otherContactInfo.isKeyPerson:'''', @otherContactInfo.patId:'''', @otherContactInfo.lastName:'''', @otherContactInfo.firstName:'''', @otherContactInfo.lastNmKana:'''', @otherContactInfo.firstNmKana:'''', @otherContactInfo.relationCd:'''', @otherContactInfo.relationName:'''', @otherContactInfo.zipCd:'''', @otherContactInfo.address:'''', @otherContactInfo.eMail:'''', @otherContactInfo.workName:'''', @otherContactInfo.workTel:'''', @otherContactInfo.tel1:'''', @otherContactInfo.tel2:'''', @otherContactInfo.fax:'''', @otherContactInfo.memo1:'''', @otherContactInfo.memo2:'''', @vendorContactInfoFlg:'''', @vendorContactInfoValue:''vendor_contact_info'', @vendorContactInfo.ctlNo:'''', @vendorContactInfo.dispOrder:'''', @vendorContactInfo.companyName:'''', @vendorContactInfo.zipCd:'''', @vendorContactInfo.address:'''', @vendorContactInfo.companyTel:'''', @vendorContactInfo.fax:'''', @vendorContactInfo.workerLastName:'''', @vendorContactInfo.workerFirstName:'''', @vendorContactInfo.workerTel:'''', @vendorContactInfo.workerEMail:'''', @vendorContactInfo.memo1:'''', @vendorContactInfo.memo2:''''}", "@contactCtlNo": "$journal.pat_personal_main.pat_contact_info.ctl_no"}, {"crud": "U", "kind": "0", "@tel1": "$journal.pat_personal_main.pat_contact_info.tel1", "judge": "", "table": "pat_personal_main", "@zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "ctl_no": "2", "sqlCode": -603205, "@address": "$journal.pat_personal_main.pat_contact_info.address", "@lastName": "$journal.pat_personal_main.pat_contact_info.name", "@relationCd": "$journal.pat_personal_main.pat_contact_info.relation_cd"}], "sqlGroup7": [{"crud": "S", "kind": "0", "type": "json", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": -603002, "@lastName": "$journal.detail.pat_personal_main.other_contact_info.name", "@relationCd": "$journal.detail.pat_personal_main.other_contact_info.relation_cd", "updateResult": "{@otherContactInfoFlg:'''', @otherContactInfoValue:''other_contact_info'', @otherContactInfo.ctlNo:'''', @otherContactInfo.dispOrder:'''', @otherContactInfo.isKeyPerson:'''', @otherContactInfo.patId:'''', @otherContactInfo.lastName:'''', @otherContactInfo.firstName:'''', @otherContactInfo.lastNmKana:'''', @otherContactInfo.firstNmKana:'''', @otherContactInfo.relationCd:'''', @otherContactInfo.relationName:'''', @otherContactInfo.zipCd:'''', @otherContactInfo.address:'''', @otherContactInfo.eMail:'''', @otherContactInfo.workName:'''', @otherContactInfo.workTel:'''', @otherContactInfo.tel1:'''', @otherContactInfo.tel2:'''', @otherContactInfo.fax:'''', @otherContactInfo.memo1:'''', @otherContactInfo.memo2:'''', @vendorContactInfoFlg:'''', @vendorContactInfoValue:''vendor_contact_info'', @vendorContactInfo.ctlNo:'''', @vendorContactInfo.dispOrder:'''', @vendorContactInfo.companyName:'''', @vendorContactInfo.zipCd:'''', @vendorContactInfo.address:'''', @vendorContactInfo.companyTel:'''', @vendorContactInfo.fax:'''', @vendorContactInfo.workerLastName:'''', @vendorContactInfo.workerFirstName:'''', @vendorContactInfo.workerTel:'''', @vendorContactInfo.workerEMail:'''', @vendorContactInfo.memo1:'''', @vendorContactInfo.memo2:''''}", "@contactCtlNo": "$journal.detail.pat_personal_main.other_contact_info.ctl_no"}, {"crud": "U", "kind": "0", "@tel1": "$journal.detail.pat_personal_main.other_contact_info.tel1", "judge": "", "table": "pat_personal_main", "@zipCd": "$journal.detail.pat_personal_main.other_contact_info.zip_cd", "ctl_no": "2", "sqlCode": -603205, "@address": "$journal.detail.pat_personal_main.other_contact_info.address", "@lastName": "$journal.detail.pat_personal_main.other_contact_info.name", "@relationCd": "$journal.detail.pat_personal_main.other_contact_info.relation_cd"}], "sqlGroup8": [{"crud": "S", "kind": "0", "type": "json", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": -603002, "@lastName": "$journal.detail.pat_personal_main.vendor_contact_info.name", "@relationCd": "$journal.detail.pat_personal_main.vendor_contact_info.relation_cd", "updateResult": "{@otherContactInfoFlg:'''', @otherContactInfoValue:''other_contact_info'', @otherContactInfo.ctlNo:'''', @otherContactInfo.dispOrder:'''', @otherContactInfo.isKeyPerson:'''', @otherContactInfo.patId:'''', @otherContactInfo.lastName:'''', @otherContactInfo.firstName:'''', @otherContactInfo.lastNmKana:'''', @otherContactInfo.firstNmKana:'''', @otherContactInfo.relationCd:'''', @otherContactInfo.relationName:'''', @otherContactInfo.zipCd:'''', @otherContactInfo.address:'''', @otherContactInfo.eMail:'''', @otherContactInfo.workName:'''', @otherContactInfo.workTel:'''', @otherContactInfo.tel1:'''', @otherContactInfo.tel2:'''', @otherContactInfo.fax:'''', @otherContactInfo.memo1:'''', @otherContactInfo.memo2:'''', @vendorContactInfoFlg:'''', @vendorContactInfoValue:''vendor_contact_info'', @vendorContactInfo.ctlNo:'''', @vendorContactInfo.dispOrder:'''', @vendorContactInfo.companyName:'''', @vendorContactInfo.zipCd:'''', @vendorContactInfo.address:'''', @vendorContactInfo.companyTel:'''', @vendorContactInfo.fax:'''', @vendorContactInfo.workerLastName:'''', @vendorContactInfo.workerFirstName:'''', @vendorContactInfo.workerTel:'''', @vendorContactInfo.workerEMail:'''', @vendorContactInfo.memo1:'''', @vendorContactInfo.memo2:''''}", "@contactCtlNo": "$journal.detail.pat_personal_main.vendor_contact_info.ctl_no"}, {"crud": "U", "kind": "0", "@tel1": "$journal.detail.pat_personal_main.vendor_contact_info.tel1", "judge": "", "table": "pat_personal_main", "@zipCd": "$journal.detail.pat_personal_main.vendor_contact_info.zip_cd", "ctl_no": "2", "sqlCode": -603205, "@address": "$journal.detail.pat_personal_main.vendor_contact_info.address", "@lastName": "$journal.detail.pat_personal_main.vendor_contact_info.name", "@relationCd": "$journal.detail.pat_personal_main.vendor_contact_info.relation_cd"}], "sqlGroup9": [{"crud": "S", "kind": "0", "type": "json", "judge": "", "table": "pat_main", "ctl_no": "1", "sqlCode": 1201, "updateResult": "{@nextCtlNo4:''next_ctl_no_4'', @infectInfoFlg:'''', @infectInfoValue:''infect_info'', @infectInfo.ctlNo:'''', @infectInfo.infectionCd:'''', @infectInfo.infect:'''', @infectInfo.examDate:'''', @infectInfo.upDate:''''}"}, {"Note": "json場合、[D]の設定が必要です。しかし、感染症情報をクリアしません。judgeに[crud#=#NG]を設定する。", "crud": "D", "kind": "1", "judge": "$journal.const.crud#=#NG", "table": "pat_main", "ctl_no": "2", "sqlCode": 0}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_main", "ctl_no": "3", "sqlCode": 4202, "@infectInfo.infect": "$journal.detail.pat_main.infect_info.infect", "@infectInfo.infectionCd": "$journal.detail.pat_main.infect_info.infection_cd"}]}, "json-key": {"{\"1\":\"\",\"2\":\"\",\"3\":\"\"}": {"1": "C", "2": "U", "3": "D"}}, "CoopIniConvUtil": {"$journal.detail.pat_main.infect_info.infect": "CONV_INFECTION_TO_FNW", "$journal.pat_personal_main.pat_blood_type_rh": "CONV_BLOOD_RH_TO_FNW", "$journal.pat_personal_main.pat_blood_type_abo": "CONV_BLOOD_ABO_TO_FNW"}}'::jsonb, '1', '0', 5843, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
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
        </rootNode>
   </dump>
</coop_info>', '{}'::jsonb, '1', '0', 5843, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
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
', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -436}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -437}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -438}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -439}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -440}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -441}, {"ordNo": "ordNo", "sqlCode": -604104}, {"ordNo": "ordNo", "sqlCode": -604108}, {"ctlNo": "ctlNo", "sqlCode": -604165}, {"sqlCode": -610004, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', 5843, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
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
', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -436}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -437}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -438}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -439}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -440}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -441}, {"ordNo": "ordNo", "sqlCode": -604104}, {"ordNo": "ordNo", "sqlCode": -604108}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604153}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604157}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604161}, {"ordNo": "ordNo", "sqlCode": -604901}, {"sqlCode": -610903, "facilityCd": "facilityCd"}, {"sqlCode": -610004, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', 5843, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
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
', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -436}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -437}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -438}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -439}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -440}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -441}, {"ordNo": "ordNo", "sqlCode": -604104}, {"ordNo": "ordNo", "sqlCode": -604108}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604153}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604157}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -604161}, {"ordNo": "ordNo", "sqlCode": -604901}, {"sqlCode": -610903, "facilityCd": "facilityCd"}, {"sqlCode": -610004, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', 5843, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
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

</rootNode>', '{"key": {"検体検査結果": {"_DEFAULT": "all"}}, "dataset": {"sqlGroup1": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}], "sqlGroup2": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "pat_exam_main", "ctl_no": "1", "sqlCode": 5101, "insertResult": "{@examMainCd:'''', @patId:'''', @facilityCd:'''', @ordNo:'''', @fnPatId:'''', @regExamDate_Date:'''', @regOrderClass:'''', @examStatus:''1'', @orderComment:'''', @orderExamSetInfoValue:''[]'', @examOrderInfoValue:''[]'', @orderLabelInfoValue:''[]'', @dataGenClass:''2'', @resultExamDate_Date:'''', @resultComment:'''', @examResultInfoValue:''[]'', @copOrderNo1:'''', @copOrderNo2:'''', @isLock:''1'', @indUserId:'''', @isDel:'''', @regDate:'''', @regStaff:'''', @upDate:'''', @upStaff:'''', @isOrder:'''', @examWeek:'''', @examFrom:'''', @examTo:'''', @examPattern:''''}", "updateResult": "{@examMainCd:''exam_main_cd'', @patId:''pat_id'', @facilityCd:''facility_cd'', @ordNo:''ord_no'', @fnPatId:''fn_pat_id'', @regExamDate_Date:''reg_exam_date'', @regOrderClass:''reg_order_class'', @examStatus:''exam_status'', @orderComment:''order_comment'', @orderExamSetInfoValue:''order_exam_set_info'', @examOrderInfoValue:''exam_order_info'', @orderLabelInfoValue:''order_label_info'', @dataGenClass:''data_gen_class'', @resultExamDate_Date:''result_exam_date'', @resultComment:''result_comment'', @examResultInfoValue:''exam_result_info'', @copOrderNo1:''cop_order_no1'', @copOrderNo2:''cop_order_no2'', @isLock:''is_lock'', @indUserId:''ind_user_id'', @isDel:''is_del'', @regDate:''reg_date'', @regStaff:''reg_staff'', @upDate:''up_date'', @upStaff:''up_staff'', @isOrder:''is_order'', @examWeek:''exam_week'', @examFrom:''exam_from'', @examTo:''exam_to'', @examPattern:''exam_pattern'', }", "@regOrderClass": "$journal.pat_exam_main.reg_order_class", "@regExamDate_Date": "$journal.pat_exam_main.reg_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.reg_exam_date"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "pat_exam_main", "ctl_no": "2", "sqlCode": 5102, "@regOrderClass": "$journal.pat_exam_main.reg_order_class", "@regExamDate_Date": "$journal.pat_exam_main.reg_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.reg_exam_date"}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "pat_exam_main", "ctl_no": "3", "sqlCode": 5103, "@regOrderClass": "$journal.pat_exam_main.reg_order_class", "@regExamDate_Date": "$journal.pat_exam_main.reg_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.reg_exam_date"}], "sqlGroup3": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#=#D", "table": "pat_exam_main", "ctl_no": "1", "sqlCode": 5101, "updateResult": "{@examMainCd:''exam_main_cd'', @patId:''pat_id'', @facilityCd:''facility_cd'', @ordNo:''ord_no'', @fnPatId:''fn_pat_id'', @regExamDate:''reg_exam_date'', @regOrderClass:''reg_order_class'', @examStatus:''exam_status'', @orderComment:''order_comment'', @orderExamSetInfoValue:''order_exam_set_info'', @examOrderInfoValue:''exam_order_info'', @orderLabelInfoValue:''order_label_info'', @dataGenClass:''data_gen_class'', @resultExamDate:''result_exam_date'', @resultComment:''result_comment'', @examResultInfoValue:''exam_result_info'', @copOrderNo1:''cop_order_no1'', @copOrderNo2:''cop_order_no2'', @isLock:''is_lock'', @indUserId:''ind_user_id'', @isDel:''is_del'', @regDate:''reg_date'', @regStaff:''reg_staff'', @upDate:''up_date'', @upStaff:''up_staff'', @isOrder:''is_order'', @examWeek:''exam_week'', @examFrom:''exam_from'', @examTo:''exam_to'', @examPattern:''exam_pattern'', }", "@regOrderClass": "$journal.pat_exam_main.reg_order_class", "@regExamDate_Date": "$journal.pat_exam_main.reg_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.reg_exam_date"}, {"crud": "U", "kind": "1", "note": "倫理削除処理", "judge": "$journal.const.crud#=#D", "table": "pat_exam_main", "ctl_no": "2", "sqlCode": 5201}], "sqlGroup4": [{"crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.crud#<>#D", "table": "pat_exam_main", "ctl_no": "1", "sqlCode": 5101, "updateResult": "{@nextDispOrder:''next_disp_order'', @examMainCd:''exam_main_cd'', @examResultInfoFlg:'''',@examResultInfoValue:''exam_result_info'',@examResultInfo.comCd:'''', @examResultInfo.dispOrder:'''', @examResultInfo.examClass:'''', @examResultInfo.freememo:'''', @examResultInfo.hl:'''', @examResultInfo.itemCd:'''', @examResultInfo.itemName:'''', @examResultInfo.jlac10Cd:'''', @examResultInfo.lower:'''', @examResultInfo.result:'''', @examResultInfo.resultDate:'''', @examResultInfo.type:'''', @examResultInfo.unit:'''', @examResultInfo.upper:''''}", "@regOrderClass": "$journal.pat_exam_main.reg_order_class", "@regExamDate_Date": "$journal.pat_exam_main.reg_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.reg_exam_date"}, {"Note": "json場合、[D]の設定が必要です。しかし、CSIの検査結果をクリアしません。judgeに[crud#=#NG]woを設定する。", "crud": "D", "kind": "1", "judge": "$journal.const.crud#=#NG", "table": "pat_exam_main", "ctl_no": "2", "sqlCode": 5301}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "pat_exam_main", "ctl_no": "3", "sqlCode": -609201, "@examResultInfo.itemCd": "$journal.detail.pat_exam_main.exam_result_info.item_cd", "@examResultInfo.result": "$journal.detail.pat_exam_main.exam_result_info.result", "@examResultInfo.freememo": "$journal.detail.pat_exam_main.exam_result_info.freememo", "@examResultInfo.resultDate": "$journal.detail.pat_exam_main.exam_result_info.result_date"}]}, "json-key": {"{\"1\":\"\",\"2\":\"\",\"3\":\"\"}": {"1": "C", "2": "U", "3": "D"}}}'::jsonb, '1', '0', 5843, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-6060001, 'C_hosp', 'exam_rst', '', 'S', 'cre', 'xml', 'CSI検査結果', 'MIRAIs', '検査結果', '1', '<coop_info>
  <facility_cd>$JOURNAL.facility_cd</facility_cd>
  <coop_cd>exam_rst</coop_cd>
  <crud>C</crud>
  <direction>S</direction>
  <coop_ord_no>$JOURNAL.coop_ord_no</coop_ord_no>
  <dump>
    <rootNode>
    </rootNode>
  </dump>
</coop_info>
', '{}'::jsonb, '1', '0', 5843, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-6060002, 'C_hosp', 'exam_rst', 'send_time', 'S', 'cre', 'xml', '定時一括送信機能(CSI検査結果)', 'MIRAIs', '検査結果(定時)', '1', NULL, '{}'::jsonb, '1', '0', 5843, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
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
          <IN_HOSPITAL_CD>dataset:-442.course_cd1</IN_HOSPITAL_CD>
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
', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -442}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -443}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -610001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -610003}, {"ctlNo": "ctlNo", "sqlCode": -610901}, {"ctlNo": "ctlNo", "sqlCode": -610902}, {"sqlCode": -610004, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', 5843, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
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
          <IN_HOSPITAL_CD>dataset:-442.course_cd1</IN_HOSPITAL_CD>
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
', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -442}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -443}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -610001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -610003}, {"sqlCode": -610004, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', 5843, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
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
          <IN_HOSPITAL_CD>dataset:-442.course_cd1</IN_HOSPITAL_CD>
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
', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -442}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -443}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -610001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -610003}, {"ctlNo": "ctlNo", "sqlCode": -610902}, {"sqlCode": -610903, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -610904}, {"sqlCode": -610004, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', 5843, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');