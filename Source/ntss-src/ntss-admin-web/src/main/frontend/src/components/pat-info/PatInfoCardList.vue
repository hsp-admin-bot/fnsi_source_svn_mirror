<!--
  患者情報・新規患者登録の患者情報カード一覧
-->
<template>
  <div :class="[className, { 'pat-info-header-area': headerClick }]" style="box-shadow: 5px 5px 10px grey;">
    <!-- カードメニューバー -->
    <menu-bar :card-components="cardComponents" :history-key="historyKey" :is-creation-pat="isCreationPat" :header-click="headerClick"
      @all-card-show="onChangeAllCardShowing"
    />
    <!-- add FNSI-共有された患者情報作成を見直し 江 end -->
    <div ref="masonryContainer" class="card-infos" :class="infoSize">
      <!-- 本人情報カード -->
      <basic-info-card
        id="basic-info-card-content"
        ref="basicInfoCard"
        class="item"
        :pat-record="basicInfoCardData"
        :is-creation-pat="isCreationPat"
        @trigger-show="updateMasonry"
        @card-show="onChangeCardShowing"
      />
      <!-- 連絡先カード -->
      <other-contact-card
        id="other-contact-card-content"
        ref="otherContactCard"
        class="item"
        :pat-record="otherContactCardData"
        :is-creation-pat="isCreationPat"
        @trigger-show="updateMasonry"
        @card-show="onChangeCardShowing"
      />
      <!-- 連絡先(業者)カード -->
      <vendor-contact-card
        id="vendor-contact-card-contents"
        ref="vendorContactCard"
        class="item"
        :pat-record="vendorContactCardData"
        :is-creation-pat="isCreationPat"
        @trigger-show="updateMasonry"
        @card-show="onChangeCardShowing"
      />
      <!-- 患者メモカード -->
      <pat-memo-card
        id="pat-memo-card-contents"
        ref="patMemoCard"
        class="item"
        :pat-record="patMemoCardData"
        :is-creation-pat="isCreationPat"
        @trigger-show="updateMasonry"
        @card-show="onChangeCardShowing"
      />
      <!-- 保険情報カード -->
      <insurance-info-card
        id="insurance-info-card"
        v-show="!isCreationPat && isShowInsurance"
        ref="insuranceInfoCard"
        class="item"
        :pat-record="insuranceInfoCardData"
        :is-creation-pat="isCreationPat"
        @trigger-show="updateMasonry"
        @card-show="onChangeCardShowing"
      />
      <!-- 透析困難・重症度・搬送区分カード -->
      <difficulty-severity-transport-card
        id="difficulty-severity-transport-card-content"
        ref="difficultySeverityTransportCard"
        class="item"
        :pat-id="patRecord.pat_main.pat_id"
        :pat-record="difficultySeverityTransportCardData"
        :is-creation-pat="isCreationPat"
        @trigger-show="updateMasonry"
        @card-show="onChangeCardShowing"
      />
      <!-- 診療情報カード -->
      <medical-care-info-card
        id="medical-care-info-card-content"
        ref="medicalCareInfoCard"
        class="item"
        :pat-record="medicalCareInfoCardData"
        :is-creation-pat="isCreationPat"
        @trigger-show="updateMasonry"
        @card-show="onChangeCardShowing"
      />
      <!-- 担当者カード -->
      <charge-staff-card
        id="charge-staff-card-content"
        ref="chargeStaffCard"
        class="item"
        :pat-record="chargeStaffCardData"
        :is-creation-pat="isCreationPat"
        @trigger-show="updateMasonry"
        @card-show="onChangeCardShowing"
      />
      <!-- 禁忌・アレルギーカード -->
      <taboo-allergy-card
        id="taboo-allergy-card-content"
        ref="tabooAllergyCard"
        class="item"
        :pat-record="tabooAllergyCardData"
        :is-creation-pat="isCreationPat"
        @trigger-show="updateMasonry"
        @card-show="onChangeCardShowing"
      />
      <!-- 感染症カード -->
      <infection-card
        id="infection-card-contents"
        ref="infectionCard"
        class="item"
        :pat-record="infectionCardData"
        :is-creation-pat="isCreationPat"
        @trigger-show="updateMasonry"
        @card-show="onChangeCardShowing"
      />
      <!-- インプラントカード -->
      <implant-card
        id="implant-card-content"
        ref="implantCard"
        class="item"
        :pat-record="implantCardData"
        :is-creation-pat="isCreationPat"
        @trigger-show="updateMasonry"
        @card-show="onChangeCardShowing"
      />
      <!-- 既往歴カード -->
      <medical-hst-card
        id="medical-hst-card-content"
        ref="medicalHstCard"
        class="item"
        :pat-record="medicalHstCardData"
        :is-creation-pat="isCreationPat"
        @trigger-show="updateMasonry"
        @card-show="onChangeCardShowing"
      />
      <!-- 入外・転入出カード -->
      <visit-hst-card
        id="visit-hst-card-content"
        ref="visitHstCard"
        class="item"
        :pat-record="visitHstCardData"
        :is-creation-pat="isCreationPat"
        @trigger-show="updateMasonry"
        @card-show="onChangeCardShowing"
      />
      <!-- 身体情報カード -->
      <physical-info-card
        id="physical-info-card-contents"
        v-show="!isCreationPat"
        ref="physicalInfoCard"
        class="item"
        :pat-record="physicalInfoCardData"
        :is-creation-pat="isCreationPat"
        @trigger-show="updateMasonry"
        @card-show="onChangeCardShowing"
      />
      <pat-group-card
        id="pat-group-card-content"
        v-show="isShowPatGroup"
        ref="patGroupCard"
        class="item"
        :pat-record="patGroupInfoCardData"
        :is-creation-pat="isCreationPat"
        @trigger-show="updateMasonry"
        @card-show="onChangeCardShowing"
      />
      <!-- 利用遠隔モニタリングサービスカード -->
      <remote-monitor-card
        id="remote-monitor-card-content"
        v-show="!isCreationPat && isHomeDialysisPat && enableHemoDialysis"
        ref="remoteMonitorCard"
        class="item"
        :pat-record="remoteMonitorCardData"
        :is-creation-pat="isCreationPat"
        @trigger-show="updateMasonry"
        @card-show="onChangeCardShowing"
      />
      <!-- 加算設定算定部カード -->
      <addition-setting
        id="addition-setting-card-content"
        v-show="isShowAdditionInfo"
        ref="additionSettingCard"
        class="item"
        :pat-record="additionSettingData"
        :is-creation-pat="isCreationPat"
        @trigger-show="updateMasonry"
        @card-show="onChangeCardShowing"
      />
    </div>
    <span :class="['btn-group', 'right-exe-btn', { 'footer-menu-hidden-adjust': !headerClick && !isDispMenu }]">
      <!-- 保存ボタン -->
      <v-ons-button
        class="common-style-ok-button btn1-execute pat-btn-margin-bottom"
        @click="save()"
        :disabled="this.editFlag || !hasEditedComponent || !getItemAuthorized('PatInfo', 'default_authority')"
      >
        保存
      </v-ons-button>
    </span>
    <span :class="['btn-group', { 'footer-menu-hidden-adjust': !headerClick && !isDispMenu }]">
      <v-ons-button
        class="common-style-cancel-button btn2-cancel pat-btn-margin-right pat-btn-margin-bottom"
        @click="checkEditCard"
      >
        キャンセル
      </v-ons-button>
    </span>
    <!-- 患者ID重複ダイアログ -->
    <message-dialog
      v-model:visible="isDuplicateHospPatIdDialogVisible"
      :message-cd="30000002"
      type="1"
    />
    <!-- キャンセル確認ダイアログ -->
    <message-dialog
      v-model:visible="isCancelDialogVisible"
      :message-cd="20010001"
      title="内容破棄"
      type="2"
      @confirm="confirmCancel"
    />
    <!-- データ不正ダイアログ -->
    <message-dialog
      v-model:visible="isInvalidFormDialogVisble"
      v-bind="invalidFormDialogProps"
      type="1"
    />
    <!-- データを編集しています -->
    <message-dialog
      v-model:visible="isDataNotEditDialogVisible"
      :message-cd="20010003"
      type="1"
    />
    <!-- 治療予定削除確認ダイアログ -->
    <message-dialog
      v-model:visible="isDeleteOrdPlanDialogVisible"
      :message-cd="20010004"
      title="治療予定中止確認"
      type="3"
      :string-params="[ordStringParams]"
      @confirm="confirmDeleteOrdPlan"
    />
    <!-- 禁忌・アレルギー重複確認ダイアログ -->
    <message-dialog
      v-model:visible="isTabooAllergySameDialogVisible"
      :message-cd="20010006"
      type="2"
      @confirm="confirmRegTabooAllergy"
    />
    <!-- 透析困難リセット確認ダイアログ -->
    <message-dialog
      v-model:visible="isResetDifficultyDialogVisible"
      :message-cd="20010007"
      type="3"
      @confirm="confirmResetDifficulty"
    />
    <!-- 指示者設定モーダル -->
    <v-ons-modal v-if="isModalVisible" :visible="isModalVisible" :class="modalFontSize">
      <ind-user-setting @hide-modal="isModalVisible = false" :title="title" />
    </v-ons-modal>
    <div v-show="isSaving">
      <v-ons-modal :visible="isSaving">
        <p class="saving-modal">
          患者情報を保存しています...
          <v-ons-icon icon="fa-spinner" spin />
        </p>
      </v-ons-modal>
    </div>
  </div>
</template>

<script>
  // add #10359 編集権限の動作不正 dengshen start
  import { getAuthorized } from "@/functions/common/CommonFunctions.js";
  // add #10359 編集権限の動作不正 dengshen end
  // ライブラリ
  import _ from "@/compat/collections/lodash";
  import { cloneDeep } from '@/compat/collections/lodash'
  import axios from "@/compat/http/axios";
  import { ApiHelper } from "@/apis/AxiosHelper";
  import dayjs from "@/compat/date/dayjs";
  import { mapActions, mapGetters, mapMutations, mapState } from "@/compat/vue/vuex";
  // 共通関数
  import { deserializeJsonColumn, serializeJsonColumn } from "@/functions/common/CommonFunctions";
  import { decodeEditableRecord, encodeEditableRecord, extractChangesRecord, getPatById } from "@/functions/PatInfoFunctions";
  import { getRouterItem } from "@/router/routing-helper";
  import { FUNC_PAT_GROUP, FUNC_PAT_INFO, FUNC_PAT_INFO_CREATE } from "@/constants/function-code";
  // コンポーネント
  import messageDialog from "@/components/common/message-dialog/MessageDialog";
  import menuBar from "@/components/pat-info/MenuBar.vue";
  import basicInfoCard from "@/components/pat-info/basic-info-card/BasicInfoCard.vue";
  import otherContactCard from "@/components/pat-info/other-contact-card/OtherContactCard";
  import vendorContactCard from "@/components/pat-info/vendor-contact-card/VendorContactCard";
  import patMemoCard from "@/components/pat-info/pat-memo-card/PatMemoCard";
  import difficultySeverityTransportCard from "@/components/pat-info/difficulty-severity-transport-card/DifficultySeverityTransportCard";
  import medicalCareInfoCard from "@/components/pat-info/medical-care-info-card/MedicalCareInfoCard";
  import chargeStaffCard from "@/components/pat-info/charge-staff-card/ChargeStaffCard";
  import tabooAllergyCard from "@/components/pat-info/taboo-allergy-card/TabooAllergyCard";
  import infectionCard from "@/components/pat-info/infection-card/InfectionCard";
  import implantCard from "@/components/pat-info/implant-card/ImplantCard";
  import medicalHstCard from "@/components/pat-info/medical-hst-card/MedicalHstCard";
  import visitHstCard from "@/components/pat-info/visit-hst-card/VisitHstCard";
  import physicalInfoCard from "@/components/pat-info/physical-info-card/PhysicalInfoCard";
  import patGroupCard from "@/components/pat-info/pat-group-card/PatGroupCard";
  import insuranceInfoCard from "@/components/pat-info/insurance-info-card/InsuranceInfoCard";
  import remoteMonitorCard from "@/components/pat-info/remote-monitor-card/RemoteMonitorCard";
  import additionSettingCard from "@/components/pat-info/addition-setting-card/AdditionSettingCard";
  import Masonry from "@/compat/layout/masonry";

  import indUserSetting from "@/components/pat-info/ind-user-setting/IndUserSettingModal.vue";
  import { EventBus } from "@/compat/vue/event-bus.js";
  import { ADVANCED_SETTINGS } from "@/constants/advancedSettings";
  import { KEY_NAME_PAT_INFO } from "@/constants/defaultSettingConstants";
  import { AUTHORITY_CODES } from "@/constants/userAuthority.js";
  import { createJournal } from "@/apis/journal";
  import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
  import { PAT_CARD_LIST } from "@/components/pat-info/PatInfoConfig.js"
  // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { getHeaderHeight, getFooterMenuClientHeight, getScopedElementsByClassName } from "@/functions/common/LayoutMeasureHelper";
import { messageFormat } from "@/functions/common/MessageFormat";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { getLatestHeaderElement } from "@/functions/common/LayoutMeasureHelper";
import { DIALYSIS_DIFFICULTY_RESET } from "@/constants/facilitySetting";

  // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end

/**
 * @description 患者情報カード一覧
 * @summary
 *   [処理概要]
 *   ・渡された患者情報レコードのカラムからデータを取り出し各カードに渡す
 *      カード内のカスタムタグコンポーネント(CustomInput.vueなど)で編集できる形にして渡す
 *   ・保存時は各カードが編集中のデータを全て集めて更新用APIに投げる
 */
export default {
  components: {
    "basic-info-card": basicInfoCard,
    "other-contact-card": otherContactCard,
    "vendor-contact-card": vendorContactCard,
    "pat-memo-card": patMemoCard,
    "difficulty-severity-transport-card": difficultySeverityTransportCard,
    "medical-care-info-card": medicalCareInfoCard,
    "charge-staff-card": chargeStaffCard,
    "taboo-allergy-card": tabooAllergyCard,
    "infection-card": infectionCard,
    "implant-card": implantCard,
    "medical-hst-card": medicalHstCard,
    "visit-hst-card": visitHstCard,
    "physical-info-card": physicalInfoCard,
    "pat-group-card": patGroupCard,
    "remote-monitor-card": remoteMonitorCard,
    "menu-bar": menuBar,
    "message-dialog": messageDialog,
    "ind-user-setting": indUserSetting,
    "insurance-info-card": insuranceInfoCard,
    "addition-setting": additionSettingCard
  },
  props: {
    // 選択患者、または新規患者オブジェクト
    patRecord: { type: Object, required: true },
    // 新規登録フラグ
    isCreationPat: { type: Boolean, default: false },
    headerClick: { type: Boolean, default: false },
    historyKey: null
  },
  data() {
    return {
      title:"治療予定を削除します。",
      isCheckEditedCard: false,
      masonry: {},
      pendingMasonryLayoutFrame: null,
      pendingMasonryLayoutNeedReload: false,
      patPersonalMainColumns: null,
      patMainColumns: null,
      patUniqueColumns: null,
      patInsuranceInfoColumns: null,

      isSaveBtnDisabled: true,

      isSaving: false,
      isCancelDialogVisible: false,
      isDuplicateHospPatIdDialogVisible: false,
      isInvalidFormDialogVisble: false,
      isDeleteOrdPlanDialogVisible: false,
      isDeleteOrdPlan: false,
      isTabooAllergySameDialogVisible: false,
      TabooAllergyCompFlg: false,
      isResetDifficultyDialogVisible: false,
      isDataNotEditDialogVisible: false,
      resetDifficultyCompFlg: false,
      isresetDifficulty: false,
      isModalVisible: false,
      moveOutDate: null,
      modalVisible: false,
      cardComponents: null,
      invalidFormDialogProps: null,
      patRecordCopy: null,
      isHaitaErrDialogVisible:false,
      isPatViewAuthorized: null,
      isPatEditAuthorized: null,
      isCreatePatViewAuthorized: null,
      editFlag: false,
      // TODO: 現状カードで編集しないデータはコメントアウトしている
      jsonColumns: [
        // pat_personal_mainテーブル
        "dial_diff_com_info",
        "pat_contact_info",
        "other_contact_info",
        "vendor_contact_info",

        // pat_mainテーブル
        "pat_memo_info",
        "addition_info",
        "charge_staff_info",
        'pat_group_list',
        "taboo_allergy_info",
        "infect_info",
        "implant_info",
        "medical_care_info",
        // 'tare_info',
        // 'off_water_info',
        // 'device_set_info',
        // 'acceptance_status_info',

        // pat_uniqueテーブル
        "medical_hst_info",
        "in_out_visit_history_info",
        "physical_info",
      ],

      codeList: [],

      // ctl_noの処理が必要なJSON配列カラム名
      ctlNoColumns: [
        "other_contact_info",
        "vendor_contact_info",
        "charge_staff_info",
        "taboo_allergy_info",
        "implant_info",
        "medical_hst_info",
        "in_out_visit_history_info"
      ],
      ordStringParams: [],
      selfScreenName: "" ,
      // 11729 患者情報・新規患者登録画面のカード展開/折畳状態の保持不正 start
      // 患者情報・新規患者登録のカード開閉状態
      cardShowing: null,
      cardShowingKeyNameData: [
        {cardName: "本人情報", keyName: KEY_NAME_PAT_INFO.KEY_NAME_BASIC_INFO},
        {cardName: "連絡先", keyName: KEY_NAME_PAT_INFO.KEY_NAME_OTHER_CONTACT},
        {cardName: "連絡先(サービス業者)", keyName: KEY_NAME_PAT_INFO.KEY_NAME_VENDOR_CONTACT},
        {cardName: "患者メモ", keyName: KEY_NAME_PAT_INFO.KEY_NAME_PAT_MEMO},
        {cardName: "保険情報", keyName: KEY_NAME_PAT_INFO.KEY_NAME_INSURANCE_INFO},
        {cardName: "透析困難・重症度・搬送区分", keyName: KEY_NAME_PAT_INFO.KEY_NAME_DIFFICULTY_SERVERITY_TRANSPORT},
        {cardName: "診療情報", keyName: KEY_NAME_PAT_INFO.KEY_NAME_MEDICAL_INFO},
        {cardName: "担当者", keyName: KEY_NAME_PAT_INFO.KEY_NAME_CHARGE_STAFF},
        {cardName: "禁忌・アレルギー", keyName: KEY_NAME_PAT_INFO.KEY_NAME_TABOO_ALLERGY},
        {cardName: "感染症", keyName: KEY_NAME_PAT_INFO.KEY_NAME_INFECTION},
        {cardName: "インプラント", keyName: KEY_NAME_PAT_INFO.KEY_NAME_IMPLANT},
        {cardName: "既往歴", keyName: KEY_NAME_PAT_INFO.KEY_NAME_MEDICAL_HST},
        {cardName: "入外・転入出", keyName: KEY_NAME_PAT_INFO.KEY_NAME_VISIT_HST},
        {cardName: "身体情報", keyName: KEY_NAME_PAT_INFO.KEY_NAME_PHYSCAL_INFO},
        {cardName: "患者グループ", keyName: KEY_NAME_PAT_INFO.KEY_NAME_PAT_GROUP},
        {cardName: "利用遠隔モニタリングサービス", keyName: KEY_NAME_PAT_INFO.KEY_NAME_REMOTE_MONITOR},
        {cardName: "加算・管理料", keyName: KEY_NAME_PAT_INFO.KEY_NAME_ADDITION_SETTING},
      ],
      // 11729 患者情報・新規患者登録画面のカード展開/折畳状態の保持不正 end
    };
  },

  computed: {
    ...mapState("pat-info", ["selectedPat", "physicalInfoUpDate"]),
    ...mapGetters("pat-info", [
      "selectedPatId",
      "isIndUserSetting",
      "isPatInfoVisible",
      "isHomeDialysisPat",
      "isOwnFacility"
      ,"defaultSelectedPatId"
      ,"searchedPatList",
      "indUserId",
      "getSearchedPatInfo",
      "getSortPatInfo",
      "hasEditedComponent",
      "getCardShowing",
      "getIsOtherFacility",
      "getOtherFacilityCd"
    ]),
    ...mapGetters("account-edit", [
      "getStateUserAccountInfo",
      "getDefaultSetting",
      "getAuthorizedFunctions",
      "isDispMenu",
      "getPatientShareMode",
      "getPatientShareFacilityCdMode"
    ]),
    ...mapGetters("user", {
      facilityCd: "getFacilityCd",
      advancedSettings: "getAdvancedSettings"
    }),
    ...mapGetters("window-size", {
      windowWidth: "getSplittedWidth"
    }),
    ...mapGetters("facility", ["useFunction"]),

    ...mapGetters("account-edit", ["getFontSize"]),

    infoSize() {
      const names = ["small", "medium", "large", "x-large"];
      return "info-size-set-" + names[this.getFontSize];
    },

    // v-ons-modal は App.vue の範囲外に生成される為、個別にフォント設定が必要
    modalFontSize() {
      const names = ["small", "medium", "large", "x-large"];
      return "font-size-set-" + names[this.getFontSize];
    },

    /**
     * @description 患者情報3テーブルの内容を1つに展開
     */
    patInfoRaw() {
      // TODO: reg_dateとup_dateがマージされてしまう
      // ⇒ select時に列名変える?
      // ⇒ 全て同じはずなので問題ない?
      return {
        // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 start
        ...this.patRecordCopy?.pat_insurance_info,
        // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 end
        ...this.patRecordCopy?.pat_personal_main,
        ...this.patRecordCopy?.pat_main,
        ...this.patRecordCopy?.pat_unique,
        ...this.patRecordCopy?.pat_group_info
      };
    },

    /**
     * @description 患者情報の編集用データ
     */
    patInfoEditable() {
      if (!Object.keys(this.patInfoRaw).length) {
        return {};
      }
      const deserializedRecord = deserializeJsonColumn(
        this.patInfoRaw,
        this.jsonColumns
      );
      const editableRecord = encodeEditableRecord(deserializedRecord);
      try {
        const patGrouList = deserializedRecord.pat_group_list;
        const patGroupEditable = patGrouList.map(item => {
          return encodeEditableRecord(item);
        });
        editableRecord.pat_group_list = patGroupEditable;
      } catch (error) {
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
        getErrorMessage('PatInfoCardList.vue', 'patInfoEditable', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
      }
      return editableRecord;
    },

    /**
     * @description 本人情報カード用データ
     */
    basicInfoCardData() {
      const pickKeys = [
        "hosp_pat_id",
        "pat_last_name",
        "pat_first_name",
        "pat_sex",
        "pat_last_name_kana",
        "pat_first_name_kana",
        "pat_last_name_alpha",
        "pat_first_name_alpha",
        "pat_birthday",
        "pat_sex",
        "pat_blood_type_abo",
        "pat_blood_type_rh",
        "pat_blood_type_serovar",
        "nationality",
        "pat_contact_info",
        "in_out_class",
        "in_out_current_state"
      ];
      return _.pick(this.patInfoEditable, pickKeys);
    },

    /**
     * @description 連絡先カード用データ
     */
    otherContactCardData() {
      return _.pick(this.patInfoEditable, "other_contact_info");
    },

    /**
     * @description 連絡先(業者)カード用データ
     */
    vendorContactCardData() {
      return _.pick(this.patInfoEditable, "vendor_contact_info");
    },

    /**
     * @description 患者メモカード用データ
     */
    patMemoCardData() {
      return _.pick(this.patInfoEditable, "pat_memo_info");
    },

    /**
     * @description 保険情報カード用データ
     */
    insuranceInfoCardData() {
      return _.pick(this.patInfoEditable, "insurance_list");
    },

    /**
     * @description 透析困難カード用データ
     */
    difficultySeverityTransportCardData() {
      const pickKeys = [
        "dial_diff_com_info",
        "severity_cd",
        "transport_cd",
        "is_wheel_chair",
        "wheel_chair_cd",
      ];
      return _.pick(this.patInfoEditable, pickKeys);
    },

    /**
     * @description 診療情報カード用データ
     */
    medicalCareInfoCardData() {
      return _.pick(this.patInfoEditable, "medical_care_info");
    },

    /**
     * @description 担当スタッフカード用データ
     */
    chargeStaffCardData() {
      return _.pick(this.patInfoEditable, "charge_staff_info");
    },

    /**
     * @description 禁忌・アレルギーカード用データ
     */
    tabooAllergyCardData() {
      return _.pick(this.patInfoEditable, "taboo_allergy_info");
    },

    /**
     * @description 感染症カード用データ
     */
    infectionCardData() {
      const pickKeys = ["infect_info", "is_infect"];
      return _.pick(this.patInfoEditable, pickKeys);
    },

    /**
     * @description インプラントカード用データ
     */
    implantCardData() {
      return _.pick(this.patInfoEditable, ["implant_info", "is_implant"]);
    },

    /**
     * @description 既往歴カード用データ
     */
    medicalHstCardData() {
      // TODO: die_dateが使われてない?
      // ⇒ 既往歴カード見直し
      const pickKeys = [
        "is_die",
        "die_cd",
        "die_date",
        "is_diabetes",
        "is_blood_suger_exam",
        "primary_disease_cd",
        "medical_hst_info"
      ];
      const medicalHst = _.pick(this.patInfoEditable, pickKeys);
      medicalHst['medical_hst_info'] = medicalHst['medical_hst_info']?.map((item) => {
        return {
          ...item,
          disease_start_input_free: {
            editValue: item.disease_start_input_free?.editValue || "0",
            initValue: item.disease_start_input_free?.initValue || "0"
          },
          diagnosis_start_input_free: {
            editValue: item.diagnosis_start_input_free?.editValue || "0",
            initValue: item.diagnosis_start_input_free?.initValue || "0"
          }
        }
      });
      return medicalHst
    },

    /**
     * @description 入外・転入出カード用データ
     */
    visitHstCardData() {
      const visit = _.pick(this.patInfoEditable, "in_out_visit_history_info");
      visit['in_out_visit_history_info'] = visit['in_out_visit_history_info']?.map((item) => {
        return {
          ...item,
          period_start_input_free: {
            editValue: item.period_start_input_free?.editValue || "0",
            initValue: item.period_start_input_free?.initValue || "0"
          },
          period_end_input_free: {
            editValue: item.period_end_input_free?.editValue || "0",
            initValue: item.period_end_input_free?.initValue || "0"
          }
        }
      });
      return visit;
    },

    /**
     * @description 身体情報カード用データ
     */
    physicalInfoCardData() {
      return _.pick(this.patInfoEditable, "physical_info");
    },

    /**
     * @description 利用遠隔モニタリングサービス用データ
     */
    remoteMonitorCardData() {
      const pickKeys = [
        "remote_monitor_service",
        "remote_monitor_user_id",
        "remote_monitor_user_pw"
      ];
      return _.pick(this.patInfoEditable, pickKeys);
    },

    /**
     * @description 加算設定算定部カード用データ
     */
    additionSettingData() {
      let additon = _.pick(this.patInfoEditable, "addition_info");
      additon["addition_info"] = additon["addition_info"]?.map((item) => {
        if (!Object.prototype.hasOwnProperty.call(item, "start_date")) {
          return {
            ...item,
            start_date: {
              editValue: null,
              initValue: null
            }
          }
        }
        return item;
      })
      return additon;
    },

    className() {
      return this.headerClick ? "pat-info-area-margin" : "pat-info-area";
    },
    /**
     * @description マスタ取得後の透析困難カード情報
     */
    dialDiffInfo() {
      const encodeDialDiffInfo = this.$refs.difficultySeverityTransportCard
        .$refs.cardContent.dialDiffInfo;
      const mapFunc = obj => obj.initValue;
      const dialDiffInfo = encodeDialDiffInfo.map(record =>
        _.mapValues(record, mapFunc)
      );
      return JSON.stringify(dialDiffInfo);
    },

    /**
     * @description マスタ取得後の感染症カード情報
     */
    infectInfo() {
      const encodeInfectInfo = this.$refs.infectionCard.$refs.cardContent
        .infectInfo;
      const mapFunc = obj => obj.initValue;
      const infectInfo = encodeInfectInfo.map(record =>
        _.mapValues(record, mapFunc)
      );
      return JSON.stringify(infectInfo);
    },

    isShowPatGroup() {
      // mod #10371 使用許可機能権限OFF時に動作不正 20240528 ztc start
      // return this.useFunction.includes(FUNC_PAT_GROUP);
      return this.useFunction.includes(FUNC_PAT_GROUP) && this.getAuthorizedFunctions.includes(FUNC_PAT_GROUP);
      // mod #10371 使用許可機能権限OFF時に動作不正 20240528 ztc end
    },

    /**
     * @description 次患者更新実行フラグ
     * @summary 対象項目
     * 患者ID hosp_pat_id
     * 患者名 pat_last_name, pat_first_name, pat_last_name_kana, pat_first_name_kana
     * 性別 pat_sex
     * 年齢 pat_birthday
     * 確定転入出状態 in_out_current_state
     * 病棟名 medical_care_info
     * 所属科名 medical_care_info
     * 担当医名 charge_staff_info
     * DW physical_info
     */
    isChangedNextPatInfo() {
      let allCardData = {};
      let changedFlag = false;
      for (const card of Object.values(this.cardComponents)) {
        allCardData = { ...allCardData, ...card.getEditedData() };
      }
      const changeNextPatColumnInfo = [
        { columnName: "hosp_pat_id", keyName: null },
        { columnName: "pat_last_name", keyName: null },
        { columnName: "pat_first_name", keyName: null },
        { columnName: "pat_last_name_kana", keyName: null },
        { columnName: "pat_first_name_kana", keyName: null },
        { columnName: "pat_sex", keyName: null },
        { columnName: "pat_birthday", keyName: null },
        // 入外区分はサーバー側で対応
        // mod  FNSI 次患者情報（コメントデータ）が更新されない 6590修正 関 start
        { columnName: "in_out_class", keyName: null },
        // mod  FNSI 次患者情報（コメントデータ）が更新されない 6590修正 関 end
        {
          columnName: "medical_care_info",
          keyName: ["ward_cd", "main_course_cd"]
        },
        {
          columnName: "charge_staff_info",
          keyName: "staff_cd",
          targetKeyName: "is_main",
          targetValue: "1"
        },
        // add #7188 治療条件，装置設定を変更すると次患者が再送される 鄭 start
        { columnName: "infect_info", keyName: "infect"}
        // add #7188 治療条件，装置設定を変更すると次患者が再送される 鄭 end
        // 身体情報は個別画面で対応
        // { columnName: "physical_info", keyName: null }
      ];
      const columnNameList = changeNextPatColumnInfo.map(
        info => info.columnName
      );

      const changeNextPatInfo = _.pick(allCardData, columnNameList);

      const isEditedList = changeNextPatColumnInfo.filter(info => {
        const columnName = info.columnName;
        const keyName = info.keyName;
        let vaFlag = false;
        if (Array.isArray(keyName)) {
          return keyName.find(keyName =>
            this.isEditedColumn(changeNextPatInfo[columnName], keyName)
          );
        } else {
          let targetKeyName = null;
          let targetValue = null;
          if (Object.prototype.hasOwnProperty.call(info, "targetKeyName") && Object.prototype.hasOwnProperty.call(info, "targetValue")) {
            targetKeyName = info.targetKeyName;
            targetValue = info.targetValue;
          }
          const isEditFlag =  this.isEditedColumn(
            changeNextPatInfo[columnName],
            keyName,
            targetKeyName,
            targetValue
          );
          // mod #7188 治療条件，装置設定を変更すると次患者が再送される 鄭 start
          // if("hosp_pat_id" === columnName && this.codeList.includes(1) || "pat_last_name" === columnName && this.codeList.includes(2)
          // || "pat_first_name" === columnName && this.codeList.includes(2) || "pat_last_name_kana" === columnName && this.codeList.includes(2)
          // || "pat_first_name_kana" === columnName && this.codeList.includes(2) || "pat_sex" === columnName && this.codeList.includes(3)
          // || "pat_birthday" === columnName && this.codeList.includes(3) || "ward_cd" === columnName && this.codeList.includes(5)
          // || "main_course_cd" === columnName && this.codeList.includes(6) || "charge_staff_info" === columnName && this.codeList.includes(7)) {
          if("hosp_pat_id" === columnName && this.codeList.includes(1) || "pat_last_name" === columnName && this.codeList.includes(2)
          || "pat_first_name" === columnName && this.codeList.includes(2) || "pat_last_name_kana" === columnName && this.codeList.includes(2)
          || "pat_first_name_kana" === columnName && this.codeList.includes(2) || "pat_sex" === columnName && this.codeList.includes(3)
          || "pat_birthday" === columnName && this.codeList.includes(3) || "ward_cd" === columnName && this.codeList.includes(5)
          || "main_course_cd" === columnName && this.codeList.includes(6) || "charge_staff_info" === columnName && this.codeList.includes(7)
          || "infect_info" === columnName && this.codeList.includes(8)) {
            // mod #7188 治療条件，装置設定を変更すると次患者が再送される 鄭 end
            vaFlag = true;
          }

          return isEditFlag && vaFlag;
        }
      });

      if(isEditedList.length > 0){
        changedFlag = true;
      }
      return changedFlag;
    },

    /**
     * @description
     */
    patGroupInfoCardData() {
      return _.pick(this.patInfoEditable, "pat_group_list");
    },

    isShowInsurance() {
      if (!this.advancedSettings && this.advancedSettings.func_advcds) return false;
      return this.advancedSettings.func_advcds && this.advancedSettings.func_advcds.some(
        setting => setting.func_advcd === ADVANCED_SETTINGS.INSURANCE_INFO
      );
    },

    isShowAdditionInfo() {
      if (!this.advancedSettings.func_advcds) return false;
      return this.advancedSettings.func_advcds.some(
        setting => setting.func_advcd === ADVANCED_SETTINGS.ADDITION_INFO
      );
    },

    enableHemoDialysis() {
      return this.advancedSettings.func_advcds.some(
        setting => setting.func_advcd === ADVANCED_SETTINGS.HOME_DIALYSIS
      );
    },
    // 11729 患者情報・新規患者登録画面のカード展開/折畳状態の保持不正 start
    cardListName() {
      return this.isCreationPat ? "patInfoCreate":"patInfo";
    },
    // 11729 患者情報・新規患者登録画面のカード展開/折畳状態の保持不正 end
  },

  watch: {
    getFontSize() {
      this.scheduleAllCardTextareaHeightsAfterLayout();
      this.$nextTick(() => this.updateMasonry(true));
      setTimeout(() => this.updateMasonry(true), 300);
    },
    isIndUserSetting() {
      if (this.isIndUserSetting) {
        // 指示者が設定された場合登録処理を実行
        this.saveMain();
      }
    },
    windowWidth() {
      this.correctBtnPosition();
    },
    // 患者情報ヘッダからの表示処理時に、ボタン位置を補正
    isPatInfoVisible() {
      if (this.isPatInfoVisible) {
        this.correctBtnPosition();
      }
    },
    patRecord: {
      handler(val) {
        if(val) {
          this.patRecordCopy = cloneDeep(val);
          this.resetEditedComponent();
        }
      },
      deep: true,
      immediate: true
    }
  },
  created() {
    // 画面名称取得
    this.selfScreenName = this.$route.name;
    if (this.isCreationPat) {
      // mod #10359、#10331 編集権限について、対応する。 dengshen start
      // this.isCreatePatViewAuthorized = this.getUseFunctions.includes(FUNC_PAT_INFO_CREATE);
      this.isCreatePatViewAuthorized = this.getAuthorizedFunctions.includes(FUNC_PAT_INFO_CREATE);
      // mod #10359、#10331 編集権限について、対応する。 dengshen end
      this.isPatEditAuthorized = this.getStateUserAccountInfo.userSettings.authorized_authorities.includes(AUTHORITY_CODES.PAT_EDIT);
      this.editFlag = !(this.isOwnFacility && this.isCreatePatViewAuthorized && this.isPatEditAuthorized);
    } else {
      // mod #10359、#10331 編集権限について、対応する。 dengshen start
      // this.isPatViewAuthorized = this.getUseFunctions.includes(FUNC_PAT_INFO);
      this.isPatViewAuthorized = this.getAuthorizedFunctions.includes(FUNC_PAT_INFO);
      // mod #10359、#10331 編集権限について、対応する。 dengshen end
      this.isPatEditAuthorized = this.getStateUserAccountInfo.userSettings.authorized_authorities.includes(AUTHORITY_CODES.PAT_EDIT);
      this.editFlag = !(this.isOwnFacility && this.isPatViewAuthorized && this.isPatEditAuthorized);
    }
    if ("" === this.selectedPatId || null === this.selectedPatId) {
      // 新規登録用、顧客未選択時は何もしない
      this.getNewPatFacility();
    } else {
      if (this.patRecord.pat_personal_main.pat_id !== undefined) {
        this.setIsNewPatPage(false);
        if (this.patRecord.pat_personal_main.facility_cd === this.facilityCd) {
          this.setDefaultSelectedPatId(this.patRecord.pat_personal_main.pat_id);
        }
        this.getFacilityList();
      } else {
        // 新規登録の場合
        this.setIsNewPatPage(true);
        this.getNewPatFacility();
      }
      this.checkHomeDialysisPat();
      // 拡張設定
      this.setAdvancedSettings();
    }
    // 11729 患者情報・新規患者登録画面のカード展開/折畳状態の保持不正 start
    // 患者情報・新規患者登録のカード開閉状態をストアから取得する
    this.cardShowing = this.getCardShowing(this.cardListName);
    // 11729 患者情報・新規患者登録画面のカード展開/折畳状態の保持不正 end

    EventBus.$on("searchAlert",this.searchAlert)
  },
  mounted() {
    this.masonry = new Masonry(this.$refs.masonryContainer, {});
    // カードコンポーネントのrefだけを集める
    this.cardComponents = _.omit(this.$refs, "masonryContainer");
    // メニューバーボタンの位置補正
    this.correctBtnPosition();
    // 11729 患者情報・新規患者登録画面のカード展開/折畳状態の保持不正 start
    // // デフォルト設定適用(初期値は開いた状態なので、閉じた状態のみ適用)
    // const defaultCondition = this.getDefaultSetting[KEY_NAME_PAT_INFO.KEY_NAME];
    // if (!(!defaultCondition || Object.keys(defaultCondition).length === 0)) {
    //   // 本人情報
    //   if (defaultCondition[KEY_NAME_PAT_INFO.KEY_NAME_BASIC_INFO] === false) {
    //     this.cardComponents["basicInfoCard"].closeCard();
    //   }
    //   // 連絡先
    //   if (defaultCondition[KEY_NAME_PAT_INFO.KEY_NAME_OTHER_CONTACT] === false) {
    //     this.cardComponents["otherContactCard"].closeCard();
    //   }
    //   // 業者連絡先
    //   if (defaultCondition[KEY_NAME_PAT_INFO.KEY_NAME_VENDOR_CONTACT] === false) {
    //     this.cardComponents["vendorContactCard"].closeCard();
    //   }
    //   // 患者メモ
    //   if (defaultCondition[KEY_NAME_PAT_INFO.KEY_NAME_PAT_MEMO] === false) {
    //     this.cardComponents["patMemoCard"].closeCard();
    //   }
    //   // 保険情報
    //   if (defaultCondition[KEY_NAME_PAT_INFO.KEY_NAME_INSURANCE_INFO] === false) {
    //     this.cardComponents["insuranceInfoCard"].closeCard();
    //   }
    //   // 困難・搬送
    //   if (defaultCondition[KEY_NAME_PAT_INFO.KEY_NAME_DIFFICULTY_SERVERITY_TRANSPORT] === false) {
    //     this.cardComponents["difficultySeverityTransportCard"].closeCard();
    //   }
    //   // 診療
    //   if (defaultCondition[KEY_NAME_PAT_INFO.KEY_NAME_MEDICAL_INFO] === false) {
    //     this.cardComponents["medicalCareInfoCard"].closeCard();
    //   }
    //   // 担当情報
    //   if (defaultCondition[KEY_NAME_PAT_INFO.KEY_NAME_CHARGE_STAFF] === false) {
    //     this.cardComponents["chargeStaffCard"].closeCard();
    //   }
    //   // 禁忌ｱﾚﾙｷﾞｰ
    //   if (defaultCondition[KEY_NAME_PAT_INFO.KEY_NAME_TABOO_ALLERGY] === false) {
    //     this.cardComponents["tabooAllergyCard"].closeCard();
    //   }
    //   // 感染症
    //   if (defaultCondition[KEY_NAME_PAT_INFO.KEY_NAME_INFECTION] === false) {
    //     this.cardComponents["infectionCard"].closeCard();
    //   }
    //   // ｲﾝﾌﾟﾗﾝﾄ
    //   if (defaultCondition[KEY_NAME_PAT_INFO.KEY_NAME_IMPLANT] === false) {
    //     this.cardComponents["implantCard"].closeCard();
    //   }
    //   // 既往歴
    //   if (defaultCondition[KEY_NAME_PAT_INFO.KEY_NAME_MEDICAL_HST] === false) {
    //     this.cardComponents["medicalHstCard"].closeCard();
    //   }
    //   // 入外転入出
    //   if (defaultCondition[KEY_NAME_PAT_INFO.KEY_NAME_VISIT_HST] === false) {
    //     this.cardComponents["visitHstCard"].closeCard();
    //   }
    //   // 身体情報
    //   if (defaultCondition[KEY_NAME_PAT_INFO.KEY_NAME_PHYSCAL_INFO] === false) {
    //     this.cardComponents["physicalInfoCard"].closeCard();
    //   }
    //   // 患者ｸﾞﾙｰﾌﾟ
    //   if (defaultCondition[KEY_NAME_PAT_INFO.KEY_NAME_PAT_GROUP] === false) {
    //     this.cardComponents["patGroupCard"].closeCard();
    //   }
    //   // 遠隔
    //   if (defaultCondition[KEY_NAME_PAT_INFO.KEY_NAME_REMOTE_MONITOR] === false) {
    //     this.cardComponents["remoteMonitorCard"].closeCard();
    //   }
    //   // 加算設定
    //   if (defaultCondition[KEY_NAME_PAT_INFO.KEY_NAME_ADDITION_SETTING] === false) {
    //     this.cardComponents["additionSettingCard"].closeCard();
    //   }
    // }

    this.layoutCardShowing();
    this.updateMasonry(true);
    this.updateCardShowingDefaultSettingLoaded(true);
    // 患者情報カード一覧の表示完了通知
    // masonry-layout が患者情報カード一覧を再描画するまで患者情報カード一覧の要素の高さが確定しないため表示完了通知を遅延させる
    setTimeout(() => {
      this.$emit('card-list-mounted');
    }, 1000);
    // 11729 患者情報・新規患者登録画面のカード展開/折畳状態の保持不正 end
    // 患者共通ヘッダー印刷時は不要な親要素を消し、印刷後に元に戻す
    if (this.headerClick) {
      // ハンドラをインスタンスに保持（remove用）
      // window.onbeforeprint、window.onafterprintはModalBaseの処理を上書きしてしまうので使用しない
      this.mainEl = document.getElementsByClassName("main")[0];
      this.breadCrumbsEl = document.getElementsByClassName("bread-crumbs")[0];
      this.handleBeforePrint = () => {
        // 親画面要素、パンくずリスト非表示
        this.mainEl.style.display = "none";
        this.breadCrumbsEl.style.display = "none";
      };
      this.handleAfterPrint = () => {
        // 印刷後に元に戻す
        this.mainEl.style.display = "";
        this.breadCrumbsEl.style.display = "";
      };
      window.addEventListener("beforeprint", this.handleBeforePrint);
      window.addEventListener("afterprint", this.handleAfterPrint);
    }
  },
  //
  beforeUnmount() {
    EventBus.$off("searchAlert", this.searchAlert)
    if (this.pendingMasonryLayoutFrame) {
      cancelAnimationFrame(this.pendingMasonryLayoutFrame);
      this.pendingMasonryLayoutFrame = null;
    }
    this.masonry.destroy()
    this.masonry = null
    this.cardComponents = null
    this.patRecordCopy = null
    this.selectPat({
      selectedPatId: this.selectedPatId,
      selectedFacility: this.facilityCd
    });
    this.resetEditedComponent();

    window.removeEventListener("beforeprint", this.handleBeforePrint);
    window.removeEventListener("afterprint", this.handleAfterPrint);
  },
  methods: {
    getCardListElementsByClassName(className) {
      return getScopedElementsByClassName(className, this.$el || this);
    },
    ...mapActions("loading-screen", ["setLoadingScreenMessage", "setLoadingScreenVisible"]),
    ...mapActions("pat-info", ["setSearchedPatList", "clearSelectedPat", "createPat", "updatePat", "checkHomeDialysisPat",
      "setAdvancedSettings", "setMstFacility", "setIsNewPatPage", "setDefaultSelectedPatId", "selectPat","sortPatList"]),
    // 治療記録のアクション
    ...mapActions("treatment-record/common", ["setOrdNo"]),
    ...mapActions("pat-insurance", ["updatePatInsurance"]),
    ...mapMutations("pat-info", ["setSelectedPat", "setIsPatInfoVisible", "setIndUserList", "setIsIndUserSetting",
      "setIndUserId",  "resetEditedComponent", "setCardShowingDefaultSettingLoaded", "setCardShowingCondition", "setOtherFacilityInfo"]),
    ...mapGetters("account-edit", ["getUserId"]),
    ...mapActions("bread-crumb", ["resetKeepHistory"]),
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    resetOtherFacilityInfoIfOwnShare() {
      if (this.getPatientShareFacilityCdMode == null || this.getPatientShareMode == 1) {
        this.setOtherFacilityInfo({
          isOtherFacility: false,
          otherFacilityCd: null
        });
      }
    },
    calculateGridSize() {
      const ww = this.windowWidth;
      const contentWidth = ww - 5;
      const sbWidth = this.sidebarWidth;
      if (sbWidth) {
        const contWidth = contentWidth - sbWidth;
        this.$refs.masonryContainer && (this.$refs.masonryContainer.style.width = contWidth + 'px');
      } else {
        this.$refs.masonryContainer && (this.$refs.masonryContainer.style.width = contentWidth + 'px');
      }
      const wh = this.windowHeight;
      const hh = getHeaderHeight(getLatestHeaderElement(this.$el || document), 0);
      const fh = getFooterMenuClientHeight(this.$el || null);
      const contHeight = wh - hh - fh - 5;
      this.contentHeight = contHeight;
    },
    async searchAlert(selectedPatId) {
      const nowSelectPatId = this.selectedPatId;
      let patInfoViewFlg = this.$route.name === "pat-info" || this.$route.name === "pat-prescription" ? true : false;
      if (this.beforeSelectPatId === null) {
        this.beforeSelectPatId = nowSelectPatId;
        this.tempPatId = nowSelectPatId;
      } else {
        this.beforeSelectPatId = this.tempPatId;
        this.tempPatId = nowSelectPatId;
      }
      if (selectedPatId !== this.selectedPatId) {
        if (this.selectedPatId == null) {
          this.selectPat(selectedPatId).catch(() => {
            getErrorMessage('PatList.vue', 'setSelectedPat', "[PatList.vue]setSelectedPat(): 患者選択失敗");
            throw new Error("[PatList.vue]setSelectedPat(): 患者選択失敗");
          }).finally(() => {
            this.resetOtherFacilityInfoIfOwnShare();
            if (patInfoViewFlg) {
              this.setLoadingScreenVisible(false);
            }
          });
        } else {
          if (this.hasEditedComponent) {
            await this.$ons.notification.confirm({
              // title: "内容破棄",
              title: DIALOG_MESSAGES[13000004].title,
              // message: "編集内容が破棄されます。</br>よろしいですか？",
              message: messageFormat(DIALOG_MESSAGES[13000004].message),
              callback: answer => {
                if (answer !== 0) {
                  this.beforeSelectPatId = nowSelectPatId;
                  this.selectPat(selectedPatId).catch(() => {
                    getErrorMessage('PatList.vue', 'setSelectedPat', "[PatList.vue]setSelectedPat(): 患者選択失敗");
                    throw new Error("[PatList.vue]setSelectedPat(): 患者選択失敗");
                  }).finally(() => {
                    this.resetOtherFacilityInfoIfOwnShare();
                    if (patInfoViewFlg) {
                      this.setLoadingScreenVisible(false);
                    }
                  });
                  // 6512 何も編集していないが、保存ボタンが押せてしまう 関
                } else {
                  this.tempPatId = this.beforeSelectPatId;
                }
              }
            });
          } else {
            this.selectPat(selectedPatId).catch(() => {
              getErrorMessage('PatList.vue', 'setSelectedPat', "[PatList.vue]setSelectedPat(): 患者選択失敗");
              throw new Error("[PatList.vue]setSelectedPat(): 患者選択失敗");
            }).finally(() => {
              this.resetOtherFacilityInfoIfOwnShare();
              if (patInfoViewFlg) {
                this.setLoadingScreenVisible(false);
              }
            });
          }
        }
      }
      this.$nextTick(() => {
        setTimeout( () => {
          this.editFlag = false;
        }, 500 );
      });
    },
    async refreshData() {
      if (this.selfScreenName !== this.$route.name) {
        return;
      }
      if (this.hasEditedComponent) {
        await new Promise(resolve => {
          this.$ons.notification.confirm({
            title: DIALOG_MESSAGES[13000004].title,
            message: messageFormat(DIALOG_MESSAGES[13000004].message),
            callback: async answer => {
              if (answer == 1) {
                this.resetEditedComponent();
                await this.initPatInfo();
              }
              resolve();
            }
          });
        });
      } else {
        await this.initPatInfo();
      }
    },
    async initPatInfo() {
      // 患者未選択の場合
      if (this.patInfoRaw.pat_id == "" || this.patInfoRaw.pat_id == null) {
        // 新規患者登録画面
        this.setLoadingScreenMessage("処理中・・・");
        this.setLoadingScreenVisible(true);
        this.cancelEdit();
        this.$refs.otherContactCard.cardContent.refreshData();
        this.$refs.difficultySeverityTransportCard.cardContent.refreshData();
        this.$refs.tabooAllergyCard.cardContent.refreshData();
        this.$refs.infectionCard.cardContent.refreshData();
        this.$refs.implantCard.cardContent.refreshData();
        this.$refs.additionSettingCard.cardContent.patAdditionsAdd();
        this.$refs.medicalHstCard.cardContent.refreshData();
        this.$refs.medicalCareInfoCard.cardContent.refreshData();
        this.$refs.visitHstCard.cardContent.refreshData();
        // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
        // this.isDatePicker = false;
        // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
        this.setLoadingScreenVisible(false);
      } else {
        // 患者情報画面
        this.setLoadingScreenMessage("処理中・・・");
        this.setLoadingScreenVisible(true);
        this.clearSelectedPat();
        // ★ selectPat の完了を待つ
        try {
          const selectedPatId = this.patInfoRaw.pat_id;
          const selectedFacility = this.getPatientShareMode === 1 ? this.facilityCd : this.getOtherFacilityCd;
          await this.selectPat({ selectedPatId, selectedFacility });
        } finally {
          this.setLoadingScreenVisible(false);
        }
      }
    },
    // 施設一覧のデータを取得
    getFacilityList() {
      ApiHelper.get(`${PAT_CARD_LIST.urigetFacilityList}/${this.facilityCd}/${this.defaultSelectedPatId}`).then((response) => {
        this.setMstFacility(response.data);
      }).catch(()=> {
        getErrorMessage('PatInfoCardList.vue', 'getFacilityList', '施設一覧のデータを取得失敗');
        throw new Error("施設一覧のデータを取得失敗");
      });
    },
    // 新患施設一覧のデータを取得
    getNewPatFacility() {
      ApiHelper.get(`${PAT_CARD_LIST.urigetNewPatFacility}/${this.facilityCd}`, { selectedPatId: this.selectedPatId }).then((response) => {
        this.setMstFacility(response.data);
      }).catch(()=> {
        getErrorMessage('PatInfoCardList.vue', 'getNewPatFacility', '施設一覧のデータを取得失敗');
        throw new Error("施設一覧のデータを取得失敗");
      });
    },
    // 入力データチェック
    async save() {
      if (!this.validateAllCard()) {
        return;
      }
      // add bug 7392 修正 chen end
      let patInOut = this.cardComponents.basicInfoCard.getPatInOutClass();
      let flag = this.cardComponents.visitHstCard.getInOutStauts();
      let patInOutInitValue = this.cardComponents.basicInfoCard.getPatInOutClassInitValue();
      let flagAdd = false;
      if (patInOut === patInOutInitValue) {
        flagAdd = true;
      }
      if (flag == false) {
        await this.cardComponents.visitHstCard.setInOutVal(patInOut);
      } else {
        await this.cardComponents.visitHstCard.setInOutEditVal(patInOut, flag, flagAdd).catch(error => {
          getErrorMessage('VisitHstCardContent.vue.vue', 'setInOutEditVal', error);
          throw error;
        });
      }
      // 治療予定削除確認
      let checkResult = false;
      if (!this.isCreationPat) {
        checkResult = await this.checkDeleteOrdPlan().catch(error => {
          getErrorMessage('PatInfoCardList.vue', 'save', error);
          throw error;
        });
      }
      // ダイアログ表示済みならダイアログを表示しない
      if (!this.TabooAllergyCompFlg) {
        // 禁忌・アレルギー重複チェック
        let checkTabooAllergy = false;
        checkTabooAllergy = this.tabooAllergySameChk(this.cardComponents.tabooAllergyCard.getEditedData().taboo_allergy_info);
        if (checkTabooAllergy) {
          this.isTabooAllergySameDialogVisible = true;
          return;
        }
      }
      if (!this.isCreationPat && !this.resetDifficultyCompFlg) {
        // 透析困難情報リセットチェック
        let isCheckReset = false;
        isCheckReset = await this.checkReset().catch(error => {
          getErrorMessage('PatInfoCardList.vue', 'save', error);
          throw error;
        });
        if (isCheckReset) {
          this.isResetDifficultyDialogVisible = true;
          return;
        }
      }
      // ID重複チェック
      const isDuplicateHospPatId = await this.isHospPatIdDuplicated().catch(error => {
        getErrorMessage('PatInfoCardList.vue', 'saveProc', error);
        throw error;
      });
      if (isDuplicateHospPatId) {
        this.isDuplicateHospPatIdDialogVisible = true;
        return;
      }
      if (checkResult) {
        // 対象の治療予定があれば削除確認を行う
        this.isDeleteOrdPlanDialogVisible = true;
      } else {
        // 対象の治療予定がなければ保存処理へ進む
        await this.saveMain();
      }
      // 6471 患者グループの編集した記録がログに残らない 関
      if (this.checkPatGroupCardEdit) {
        if(this.cardComponents && this.cardComponents["patGroupCard"] && this.cardComponents["patGroupCard"].$refs.cardContent
         && this.cardComponents["patGroupCard"].$refs.cardContent)
         {
          const editRecord = this.cardComponents["patGroupCard"].$refs.cardContent.editRecord;
          const orgRecord = this.cardComponents["patGroupCard"].$refs.cardContent.patRecord;
          let arredit = editRecord["pat_group_list"].filter(item => orgRecord["pat_group_list"].every(temp => temp.patGroupName.initValue !== item.patGroupName.initValue));
          let arrorg = orgRecord["pat_group_list"].filter(item => editRecord["pat_group_list"].every(temp => temp.patGroupName.initValue !== item.patGroupName.initValue));
          if (arredit.length === 0 && arrorg.length !== 0) {
            let patid = this.selectedPatId;
            let arrTemp = [];
            arrorg.forEach(item => {
              arrTemp.push(item.patGroupName.initValue)
            })
            let paramObj = { 'message': arrTemp, 'functionName': '患者情報', 'pat_id': patid };
            ApiHelper.put("/patInfo/delpatGrouplog", paramObj).catch(error => {
              getErrorMessage('PatInfoCardList.vue', 'save', error);
            });
          } else if (arredit.length > 0 && arrorg.length !== 0) {
            let arrorgmod = orgRecord["pat_group_list"].filter(item => editRecord["pat_group_list"].every(temp => temp.patGroupName.initValue !== item.patGroupName.initValue));
            let arreditmod = editRecord["pat_group_list"].filter(item => orgRecord["pat_group_list"].every(temp => temp.patGroupName.initValue !== item.patGroupName.initValue));
            let arrTemp = [];
            let arrTempEdit = [];
            arrorgmod.forEach(item => {
              arrTemp.push(item.patGroupName.initValue)
            })
            arreditmod.forEach(temmp => {
              arrTempEdit.push(temmp.patGroupName.initValue)
            })
            let patid = this.selectedPatId;
            let paramObj = { 'arrTemp': arrTemp, 'arrTempEdit': arrTempEdit, 'functionName': '患者情報', 'pat_id': patid };
            ApiHelper.put("/patInfo/modpatGrouplog", paramObj).catch(error => {
              getErrorMessage('PatInfoCardList.vue', 'save', error);
            });
          } else if (orgRecord.length > 0) {
            let patid = this.selectedPatId;
            let arrTemp = [];
            arredit.forEach(item => {
              arrTemp.push(item.patGroupName.initValue)
            })
            let paramObj = { 'message': arrTemp, 'functionName': '患者情報', 'pat_id': patid };
            ApiHelper.put("/patInfo/addpatGrouplog", paramObj).catch(error => {
              getErrorMessage('PatInfoCardList.vue', 'save', error);
            });
          }
        }
      }
      // mod #10368 新規患者登録後の動作不正 宮崎 start
      // mod #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc start
      // if (this.headerClick) {
      if (!this.isDeleteOrdPlanDialogVisible && this.headerClick) {
        // mod #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc end
        // this.setIsPatInfoVisible(!this.isPatInfoVisible); // mod #10234 スケジュール表のヘッダーから表示される患者情報画面の動作不正修正 宮崎
      }
      // mod #10368 新規患者登録後の動作不正 宮崎 end
    },
    async saveMain() {
      // 保存
      this.isSaving = true;
      this.TabooAllergyCompFlg = false;
      this.resetDifficultyCompFlg = false;
      this.resetActionMode();
      try {
        await this.saveProc();
      } catch (error) {
        getErrorMessage('PatInfoCardList.vue', 'saveMain', error);
        // 排他制御エラー
        if (this.isHaitaErrDialogVisible) {
          this.$ons.notification.alert({
            title: DIALOG_MESSAGES["22020006"].title,
            message: messageFormat(DIALOG_MESSAGES["22020006"].message)
          });
          this.isHaitaErrDialogVisible = false;
        } else {
          // 排他制御エラー以外はエラーアラート表示
          this.$ons.notification.alert({
            title: DIALOG_MESSAGES["00200167"].title,
            message: messageFormat(DIALOG_MESSAGES["00200167"].message)
          });
        }
        throw error;
      } finally {
        this.isSaving = false;
        this.setIsPatInfoVisible(false);
        this.resetEditedComponent();

        // refreshData の完了を待つ
        // 選択済患者IDをクリア→再設定しているので再設定完了まで待ってからイベント発火する
        await this.refreshData();

        EventBus.$emit("isRefresh");
        EventBus.$emit("savePatInfoSuccess");
        // 11729 患者情報・新規患者登録画面のカード展開/折畳状態の保持不正 start
        this.$emit('card-list-refresh');
        // 11729 患者情報・新規患者登録画面のカード展開/折畳状態の保持不正 end
      }
    },
    // 全カードのバリデーション
    // true: 成功, false: 失敗
    validateAllCard() {
      for (const cardElement of Object.values(this.cardComponents)) {
        // 必須項目チェック
        const emptyFormName = cardElement.checkAllRequiredForm();
        if (emptyFormName !== "") {
          this.isInvalidFormDialogVisble = true;
          // ダイアログに与えるprops作成
          this.invalidFormDialogProps = {
            title: "必須項目未入力",
            messageCd: 20010002,
            stringParams: [emptyFormName]
          };
          return false;
        }
        const invalidReason = cardElement.validateAllForm();
        if (invalidReason !== "") {
          this.isInvalidFormDialogVisble = true;
          // ダイアログに与えるprops作成
          this.invalidFormDialogProps = {
            messageCd: 30000004,
            stringParams: [invalidReason]
          };
          return false;
        }
      }
      return true;
    },
    validatePatGroupInfo(patGroupInfo) {
      const patGrouplList = JSON.parse(patGroupInfo.pat_group_list);
      const result = {
        pat_group_list: JSON.stringify(patGrouplList)
      };
      return result;
    },
    filterOtherHospitalData(allCardData) {
      const targetKeys = [
        "in_out_visit_history_info",
        "medical_hst_info",
        "physical_info"
      ];

      targetKeys.forEach(key => {
        if (!Array.isArray(allCardData[key])) return;

        allCardData[key] = allCardData[key].filter(row => {
          const rowFacility = row.facility_cd?.editValue;
          const isReadonly = row.readonly?.editValue === true;

          return rowFacility === this.facilityCd && !isReadonly;
        });
      });
    },
    // 保存処理
    async saveProc() {
      // データが編集されていない場合、メッセージを表示
      // 保険選択の変更
      let isInsurChange = this.cardComponents.insuranceInfoCard.getIsInsuranceChange();
      if (isInsurChange) {
        let selectInsurCd = this.cardComponents.insuranceInfoCard.getIsInsuranceSelectCd();
        let postJson = new Object();
        postJson.insuranceCd = selectInsurCd;
        postJson.isSelected = 1;
        ApiHelper.put(`/patInfo/updateInsuranceSelectById/`+this.patInfoRaw.pat_id, postJson);
      }
      // 同姓同名チェック
      await this.checkSameName().catch(error => {
        getErrorMessage('PatInfoCardList.vue', 'saveProc', error);
        throw error;
      });
      // 各カードの保存前データセット処理
      await this.setCardDataBeforeSaving();
      // 各カードが編集したデータを集める
      let allCardData = {};
      for (const card of Object.values(this.cardComponents)) {
        allCardData = { ...allCardData, ...card.getEditedData() };
      }
      this.filterOtherHospitalData(allCardData);
      // 更新用に加工
      const decodedRecord = decodeEditableRecord(allCardData);
      try {
        const patGroupList =  allCardData.pat_group_list;
        const patGroupEditable = patGroupList.map(item => {
          return decodeEditableRecord(item);
        });
        decodedRecord.pat_group_list = patGroupEditable;
      } catch (error) {
        getErrorMessage('PatInfoCardList.vue', 'saveProc', error);
      }
      // 変更箇所の抽出
      const changedRecord = extractChangesRecord(allCardData);
      const numberedRecord = this.numberingCtlNo(
        decodedRecord,
        this.ctlNoColumns
      );
      const colName = ["dial_diff_com_info", "other_contact_info", "charge_staff_info", "implant_info", "medical_hst_info", "in_out_visit_history_info", "physical_info", "taboo_allergy_info"];
      colName.forEach(sub => {
        if (numberedRecord[sub].length > 0) {
          if (Object.prototype.hasOwnProperty.call(numberedRecord[sub][0], "readonly")) {
            numberedRecord[sub] = numberedRecord[sub].filter(info => info.readonly === null);
            numberedRecord[sub].forEach(info => {
              delete info.readonly;
              delete info.dialysis_difficulty_name;
              delete info.infection_name;
            })
          }
        }
      })
      const serializedRecord = serializeJsonColumn(
        numberedRecord,
        this.jsonColumns
      );
      const updatableRecord = { ...this.patInfoRaw, ...serializedRecord };
      // 各テーブルのカラムに対応するデータを取り出す
      const pat_personal_main = _.pick(updatableRecord, Object.keys(this.patRecord.pat_personal_main));
      const pat_main = _.pick(updatableRecord, Object.keys(this.patRecord.pat_main));
      // 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉
      const pat_insurance_info = _.pick(updatableRecord, Object.keys(this.patRecord.pat_insurance_info));
      let taboo = pat_main.taboo_allergy_info;
      let tabooJson = JSON.parse(taboo);
      for (let i = 0; i < tabooJson.length; i++) {
        tabooJson[i].disp_order = i + 1;
        // add 9987 by kangjie 20231229 start
        if (tabooJson[i].taboo_allergy_cd == null) {
          tabooJson[i].category_class = "5";
        }
        // add 9987 by kangjie 20231229 end
      }
      taboo = JSON.stringify(tabooJson);
      pat_main.taboo_allergy_info = taboo;
      const pat_unique = _.pick(updatableRecord, Object.keys(this.patRecord.pat_unique));
      // 更新日時を追加
      const nowDate = dayjs().format("YYYY-MM-DD HH:mm:ss");
      pat_personal_main.up_date = nowDate;
      pat_main.up_date = nowDate;
      // 加算・管理料
      pat_unique.up_date = nowDate;
      if (this.physicalInfoUpDate) {
        pat_unique.old_up_date_unique = this.physicalInfoUpDate;
      }
      // 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉
      pat_insurance_info.up_date = nowDate;
      if (this.isCreationPat) {
        // 患者新規登録の場合は登録日時を追加
        pat_personal_main.reg_date = nowDate;
        pat_main.reg_date = nowDate;
        pat_unique.reg_date = nowDate;
      }
      if (this.isCreationPat && !this.isShowAdditionInfo) {
        pat_main.addition_info = '[]';
      }
      // del 9538 患者情報の感染症の感染症患者として扱うの保存を行っても感染症結果に(+)がないとONの表示がされない zhou start
      // add 患者情報：検査結果一括登録感染症後、ページ上部患者名横の感染症アイコンに色がない 関　start
      // let patInfectInfo= JSON.parse(pat_main.infect_info)
      // patInfectInfo.forEach(item => {
      //   if (item.infect == '2') {
      //     pat_main.is_infect = "1";
      //     this.positiveInfectionFlg = true;
      //   }
      // })
      // if (!this.positiveInfectionFlg) {
      //     pat_main.is_infect = "0";
      // }
      // add 患者情報：検査結果一括登録感染症後、ページ上部患者名横の感染症アイコンに色がない 関  end
      // del 9538 患者情報の感染症の感染症患者として扱うの保存を行っても感染症結果に(+)がないとONの表示がされない zhou end
      const pre_pat_group_info = _.pick(updatableRecord, Object.keys(this.patRecord.pat_group_info));
      const pat_group_info = this.validatePatGroupInfo(pre_pat_group_info);
      const patInfo = {
        pat_personal_main,
        pat_insurance_info,
        pat_main,
        pat_unique,
        pat_group_info
      };
      if (this.isCreationPat) {
        await this.createPat({...patInfo, changed_record: changedRecord}).catch(error => {
          getErrorMessage('PatInfoCardList.vue', 'saveProc', error);
          throw error;
        });
        // add 9266 患者情報を編集して保存すると患者検索の並び順が変化する 関 start
        EventBus.$emit("scrollBottom", false);
        // add 9266 患者情報を編集して保存すると患者検索の並び順が変化する 関 end
      } else {
        const mstComsvSetting = await ApiHelper.get(`/master_maintenance/mst_comsv_setting/data/${this.facilityCd}`, {
          selectedPatId: this.selectedPatId
        });
        // 6590 次患者情報（コメントデータ）が更新されない 周
        let diviceEgeList = mstComsvSetting.data.localDataSource.data;
        diviceEgeList.forEach(de => {
          JSON.parse(de.lcdNpat).npat_item.forEach(ni => {
            this.codeList.push(ni.code);
          });
        });
        // mod #7188 2023/01/14 治療条件，装置設定を変更すると次患者が再送される dou start
        // await this.updatePat({...patInfo, is_changed_next_pat_info: this.isChangedNextPatInfo, changed_record: changedRecord}).catch(error => {
        await this.updatePat({...patInfo, is_changed_next_pat_info: this.isChangedNextPatInfo, changed_record: changedRecord, facilityCd: this.facilityCd}).catch(error => {
        // mod #7188 2023/01/14 治療条件，装置設定を変更すると次患者が再送される dou end
          getErrorMessage('PatInfoCardList.vue', 'saveProc', '患者更新失敗');
          // 排他処理
          /* mod #6300 by zhangruixue 2023-06-09 --start */
          if (error.response.data == '22020006' ) {
            /* mod #6300 by zhangruixue 2023-06-09 --end */
            this.isHaitaErrDialogVisible = true;
            throw new Error("患者更新失敗");
          }
          throw error;
        });
        // add 9266 患者情報を編集して保存すると患者検索の並び順が変化する 関 start
        if (null !== this.getSortPatInfo && this.getSortPatInfo.length >0) {
          if (null !== this.getSortPatInfo[0].key) {
            await this.sortPatList({
              sortConditions: this.getSortPatInfo,
              selectedPatId: this.selectedPatId
            });
          }
        }
        EventBus.$emit("scrollBottom", true);
        // add 9266 患者情報を編集して保存すると患者検索の並び順が変化する 関 end
        // 保険情報について
        await this.updatePatInsurance().catch(error => {
          getErrorMessage('PatInfoCardList.vue', 'saveProc', error);
          // 排他処理
          if (error.response.data == '22020006') {
            this.isHaitaErrDialogVisible = true;
            throw error;
          }
          throw error;
        });
        EventBus.$emit('reloadListInsurance');
      }
      // 確定・予定転入出状態、日時更新
      const pat_id = patInfo.pat_personal_main.pat_id;
      // add 6625【ST試験】【S12_患者の既往・転入履歴】患者情報：患者状態が変更された場合、ページ頭部状態は変更されない zhou　start
      let patInOut = this.cardComponents.basicInfoCard.getPatInOutClass();
      let patInOutInitValue = this.cardComponents.basicInfoCard.getPatInOutClassInitValue();
      let flag = "true" ;
      if (patInOut == '3' && patInOut != patInOutInitValue) {
        flag = "false" ;
      }
      // add 6625【ST試験】【S12_患者の既往・転入履歴】患者情報：患者状態が変更された場合、ページ頭部状態は変更されない zhou　end
      const uri = "/ntss-admin-web/api/patInfo/updateInOutState";
      const up_date = JSON.stringify({ up_date: nowDate });
      const params = {
        pat_personal_main: up_date,
        pat_main: up_date,
        facility_cd: this.facilityCd,
        // add 6625【ST試験】【S12_患者の既往・転入履歴】患者情報：患者状態が変更された場合、ページ頭部状態は変更されない zhou　start
        in_out_class: flag
        // add 6625【ST試験】【S12_患者の既往・転入履歴】患者情報：患者状態が変更された場合、ページ頭部状態は変更されない zhou　end
      }
      const in_out_info = await axios.post(`${uri}/${pat_id}`, params).catch((err) => {
        getErrorMessage('PatInfoCardList.vue', 'saveProc', '確定転入出状態更新失敗');
        throw new Error("確定転入出状態更新失敗");
      });
      patInfo.pat_main.in_out_current_state = in_out_info.data.in_out_current_state;
      patInfo.pat_personal_main.in_out_class = in_out_info.data.in_out_class;
      // 治療予定削除
      if (this.isDeleteOrdPlan) {
        await this.deleteOrdPlan().catch(error => {
          getErrorMessage('PatInfoCardList.vue', 'saveProc', error);
          throw error;
        });
        let Params = {};
        Params.patId = this.selectedPatId;
        Params.facilityCd = this.facilityCd;
        Params.indUserId = this.indUserId;
        // mod #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc start
        // Params.deleteDate = this.moveOutDate;
        Params.move_out_date = this.moveOutDate;
        // mod #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc end
        // 死亡 / 転出、離脱、移植、通院拒否・不明日の判定
        Params.type = this.cardComponents.medicalHstCard.isDie === true ? 'death' : 'moveInOut';
        const radResutl = await ApiHelper.post("/rad/deletePatRadRequest", Params);
        const examResutl = await ApiHelper.post("/exam/deletePatExamRequest", Params);
        let overDeadlineCount = 0;
        if (radResutl.data && !isNaN(radResutl.data)) {
          overDeadlineCount = Number(overDeadlineCount) + Number(radResutl.data);
        }
        if (examResutl.data && !isNaN(examResutl.data)) {
          overDeadlineCount = Number(overDeadlineCount) + Number(examResutl.data);
        }
        if (overDeadlineCount > 0) {
          this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "締め切り予定あり",
            // message: "検査予定または一般撮影検査予定に締め切り済の予定があります。</br>締め切り済の予定は中止しません。</br>内容を確認し対応をお願いします。"
            title: DIALOG_MESSAGES[12000190].title,
            message: messageFormat(DIALOG_MESSAGES[12000190].message)
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
        }
      }
      const getPatInfo = await getPatById(pat_id).catch(error => {
        getErrorMessage('PatInfoCardList.vue', 'saveProc', error);
        throw error();
      });
      // add 8669 【デグレ】患者情報画面内の感染症リストがマスタと一致していない 関 start
      const requestParam = {
        facilityCd: getPatInfo.pat_main.facility_cd,
        selectedPatId: this.selectedPatId
      };
      const response = await ApiHelper.get(
        "/mstInfo/mstInfection",
        requestParam
      ).catch(() => {
        getErrorMessage('InfectionCardContent.vue', 'created', "感染症マスタ取得失敗");
        throw new Error(
          "[InfectionCardContent.vue]created(): 感染症マスタ取得失敗"
        );
      });
      let infectInfoJson = JSON.parse(patInfo.pat_main.infect_info);
      let mstInfect = response.data;
      let infectinfoList = [];
      for (const mst of mstInfect) {
        const targetInfection = infectInfoJson.find(infection => {
          return infection.infection_cd == mst.infectionCd;
        });
        let infection_cd;
        let infect;
        let exam_date;
        let up_date;
        if (targetInfection === undefined) {
          // infectInfoにないコード(患者新規登録時、または新規追加されたマスタ)の場合は結果不明で追加
          infection_cd = mst.infectionCd;
          infect = "0";
          exam_date = null;
          up_date = null;
        } else {
          // 存在するコードはそのまま追加
          infection_cd = targetInfection.infection_cd;
          infect = targetInfection.infect;
          exam_date = targetInfection.exam_date;
          up_date = targetInfection.up_date;
        }
        const infection = {
          infection_cd,
          infect,
          exam_date,
          up_date
        };
        infectinfoList.push(infection);
      }
      getPatInfo.pat_main.infect_info = JSON.stringify(infectinfoList);
      // add 8669 【デグレ】患者情報画面内の感染症リストがマスタと一致していない 関 end
      this.setSelectedPat(getPatInfo);
      if (this.isCreationPat) {
        this.resetEditedComponent();
        // オーダ番号をクリア
        this.setOrdNo(null);
        // パンくずリストをクリア
        this.resetKeepHistory(); // add #10368 新規患者登録後の動作不正 宮崎
        // 新規登録後は患者情報画面に移動
        this.$router.push({ name: getRouterItem(FUNC_PAT_INFO).router_name });
      } else {
        // 編集用レコードを更新内容で初期化 ※編集状態解除用
        this.patRecordCopy = cloneDeep(patInfo);
        // del #10234 スケジュール表のヘッダーから表示される患者情報画面の動作不正修正 宮崎 start
        // if (this.headerClick) {
        //   // ヘッダから編集されている場合はカード一覧を閉じる
        //   this.setIsPatInfoVisible(false);
        // }
        // del #10234 スケジュール表のヘッダーから表示される患者情報画面の動作不正修正 宮崎 end
      }
      if (this.isCreationPat) {
        const params = {
          ope_cd:"017002",
          crud: "C",
          facility_cd: this.facilityCd,
          hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
          ord_no: "",
          base_date:dayjs().format("YYYYMMDD"),
          user_id: this.getUserId()
        };
        createJournal(params);
      } else {
        const params = {
          ope_cd:"007007",
          crud: "U",
          facility_cd: this.facilityCd,
          pat_id:this.selectedPat.pat_personal_main.pat_id,
          hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
          ord_no: "",
          base_date:dayjs().format("YYYYMMDD"),
          user_id: this.getUserId()
        };
        createJournal(params);
      }
      const savedPatId = this.patInfoRaw.pat_id;
      const patIndex = this.searchedPatList.findIndex(pat => pat.pat_id == savedPatId);
      if (patIndex !== -1) {
        const updatedPatList = [...this.searchedPatList];
        updatedPatList[patIndex] = {
          ...updatedPatList[patIndex],
          in_out_class: getPatInfo.pat_personal_main.in_out_class
        };
        this.setSearchedPatList(updatedPatList);
      }
    },
    // 院内ID重複チェック
    // true: 院内IDが重複 false: 重複していない
    async isHospPatIdDuplicated() {
      const hospPatId = this.cardComponents.basicInfoCard.getHospPatId();
      const params = {
        pat_id: this.isCreationPat ? null : this.selectedPatId,
        hosp_pat_id: hospPatId,
        facility_cd: this.facilityCd
      }
      const response = await ApiHelper.post(`${PAT_CARD_LIST.uriSameHospId}`, params).catch(() => {
        getErrorMessage('PatInfoCardList.vue', 'isHospPatIdDuplicated', '院内ID重複チェック失敗');
        throw new Error("院内ID重複チェック失敗");
      });
      return response.data > 0;
    },
    async checkSameName() {
      // 更新対象患者の変更前後の名前を取得
      const oldNewNames = this.cardComponents.basicInfoCard.getOldNewPatName();
      if (this.patInfoRaw.is_same === "1") {
        // 既に同姓同名の場合は、名前変更によって他の人がこの人と同姓同名でなくなるかもしれないのでチェック
        const params = {
          pat_last_name: oldNewNames.oldLastName,
          pat_first_name: oldNewNames.oldFirstName,
          pat_last_name_kana: oldNewNames.oldLastNameKana,
          pat_first_name_kana: oldNewNames.oldFirstNameKana,
          pat_last_name_alpha: oldNewNames.oldLastNameAlpha,
          pat_first_name_alpha: oldNewNames.oldFirstNameAlpha
        }
        const sameOldNamePatList = await this.getSameNamePat(params).catch(error => {
          getErrorMessage('PatInfoCardList.vue', 'checkSameName', error);
          throw error;
        });
        // 同姓同名ではなくなる人のフラグを折る
        const notSameNamePatList = sameOldNamePatList.filter(pat => {
          return (
            // 漢字姓名のいずれかが不一致で、
            (pat.pat_last_name !== oldNewNames.newLastName || pat.pat_first_name !== oldNewNames.newFirstName) ||
            // かつ、カナ姓名のいずれかが空、または全て空でないときいずれかが不一致で、
            (pat.pat_last_name_kana === null || oldNewNames.newLastNameKana === null || pat.pat_first_name_kana === null ||
              oldNewNames.newFirstNameKana === null || pat.pat_last_name_kana !== oldNewNames.newLastNameKana ||
              pat.pat_first_name_kana !== oldNewNames.newFirstNameKana) ||
            // かつ、アルファベット姓名のいずれかが空、または全て空でないときいずれかが不一致なら同姓同名ではない
            (pat.pat_last_name_alpha === null || oldNewNames.newLastNameAlpha === null ||
              pat.pat_first_name_alpha === null || oldNewNames.newFirstNameAlpha === null ||
              pat.pat_last_name_alpha !== oldNewNames.newLastNameAlpha ||
              pat.pat_first_name_alpha !== oldNewNames.newFirstNameAlpha)
          );
        });
        // 同姓同名ではなくなる人がいる場合
        if (notSameNamePatList.length > 0) {
          // パラメータの作成
          const otherSameNameParams = {
            pat_last_name: notSameNamePatList[0].pat_last_name,
            pat_first_name: notSameNamePatList[0].pat_first_name,
            pat_last_name_kana: notSameNamePatList[0].pat_last_name_kana,
            pat_first_name_kana: notSameNamePatList[0].pat_first_name_kana,
            pat_last_name_alpha: notSameNamePatList[0].pat_last_name_alpha,
            pat_first_name_alpha: notSameNamePatList[0].pat_first_name_alpha
          }
          // 同姓同名ではなくなる人に他の同姓同名の人がいるか確認する
          const otherSameNamePatList = await this.getSameNamePat(otherSameNameParams).catch(error => {
            getErrorMessage('PatInfoCardList.vue', 'checkSameName', error);
            throw error;
          });
          // 同姓同名ではなくなる人に他の同姓同名の人がいない場合
          if (otherSameNamePatList.length === 1) {
            const notSameNameIdList = notSameNamePatList.map(pat => pat.pat_id);
            await this.toggleSameNameFlg(notSameNameIdList, false).catch(error => {
              getErrorMessage('PatInfoCardList.vue', 'checkSameName', error);
              throw error;
            });
          }
        }
      }
      // 変更後の名前が同姓同名かチェック
      const sameNameParams = {
        pat_last_name: oldNewNames.newLastName,
        pat_first_name: oldNewNames.newFirstName,
        pat_last_name_kana: oldNewNames.newLastNameKana,
        pat_first_name_kana: oldNewNames.newFirstNameKana,
        pat_last_name_alpha: oldNewNames.newLastNameAlpha,
        pat_first_name_alpha: oldNewNames.newFirstNameAlpha
      }
      const sameNewNamePatList = await this.getSameNamePat(sameNameParams).catch(error => {
        getErrorMessage('PatInfoCardList.vue', 'checkSameName', error);
        throw error;
      });
      if (sameNewNamePatList.length === 0) {
        // 同姓同名患者なし
        this.patInfoRaw.is_same = "0";
      } else {
        this.patInfoRaw.is_same = "1";
        // この人と同姓同名になる人のフラグを立てる
        const sameNameIdList = sameNewNamePatList.filter(pat => {
          return (
            (pat.pat_last_name === oldNewNames.newLastName && pat.pat_first_name === oldNewNames.newFirstName) ||
            (pat.pat_last_name_kana === oldNewNames.newLastNameKana && pat.pat_first_name_kana === oldNewNames.newFirstNameKana) ||
            (pat.pat_last_name_alpha === oldNewNames.newLastNameAlpha && pat.pat_first_name_alpha === oldNewNames.newFirstNameAlpha)
          );
        }).map(pat => pat.pat_id);
        await this.toggleSameNameFlg(sameNameIdList, true).catch(error => {
          getErrorMessage('PatInfoCardList.vue', 'checkSameName', error);
          throw error;
        });
      }
    },
    async toggleSameNameFlg(patIdList, isSame) {
      const is_same = isSame ? "1" : "0";
      return ApiHelper.post(PAT_CARD_LIST.uriUpdateIsSame, {patIdList: JSON.stringify(patIdList), is_same}).catch(() => {
        getErrorMessage('PatInfoCardList.vue', 'toggleSameNameFlg', '同姓同名フラグ変更失敗');
        throw new Error("同姓同名フラグ変更失敗");
      });
    },
    async getSameNamePat(nameObj) {
      const params = {
        pat_id: this.isCreationPat ? null : this.selectedPatId,
        facility_cd: this.facilityCd,
        ...nameObj
      }
      const response = await ApiHelper.post(`${PAT_CARD_LIST.uriSameName}`, params).catch(() => {
        getErrorMessage('PatInfoCardList.vue', 'getSameNamePat', '同姓同名チェック失敗');
        throw new Error("同姓同名チェック失敗");
      });
      return response.data;
    },
    // 禁忌・アレルギーの重複チェック
    tabooAllergySameChk(tabooAllergyInfo) {
      // 削除対象を除外し登録対象を抽出
      const regChkTabooAllergyInfo = tabooAllergyInfo.filter(
        regTarget => regTarget.ctl_no.editValue >= 0
      );
      // 登録対象の重複チェック
      const sameChkTabooAllergyInfo = regChkTabooAllergyInfo.filter(
        (comSource, index, calcArray) =>
          calcArray.findIndex(
            comDest =>
              // 区分とコードの同一チェック
              (comSource.taboo_allergy_class.editValue ===
                comDest.taboo_allergy_class.editValue &&
                comSource.taboo_allergy_cd.editValue ===
                  comDest.taboo_allergy_cd.editValue &&
                comSource.content.editValue === comDest.content.editValue &&
                comSource.category_class.editValue ===
                  comDest.category_class.editValue) ||
              // 手入力データと選択データとで内容が同一の場合をチェック
              (comSource.content.editValue === comDest.content.editValue &&
                (comSource.taboo_allergy_cd.editValue === null ||
                  comDest.taboo_allergy_cd.editValue === null))
            // 重複データのみ抽出
          ) !== index
      );
      return sameChkTabooAllergyInfo.length > 0;
    },

    /**
     * @description 透析困難情報リセットチェック
     */

    async checkReset() {
      this.isresetDifficulty = false;
      // 透析困難情報を取得
      const dialDiffEdit = this.cardComponents.difficultySeverityTransportCard.getHasDialDiffEdit();
      if (!dialDiffEdit) {
        // 透析困難が未登録の場合処理を終了
        return false;
      }
      // 施設設定マスタから透析困難リセット機能の設定値を取得
      const response = await ApiHelper.get(
        // mod 徐博 start
        // `${urigetFacilitySettingValue}/${this.facilityCd}/${DIALYSIS_DIFFICULTY_RESET}`
        `${PAT_CARD_LIST.urigetFacilitySettingValue}/${this.facilityCd}/${DIALYSIS_DIFFICULTY_RESET}`,
        { selectedPatId: this.selectedPatId }
        // add 徐博 end
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
        getErrorMessage('PatInfoCardList.vue', 'checkReset', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
        throw error;
      });
      if (response.data != "1") {
        // 設定が「1：ON」以外の場合処理を終了
        return false;
      }
      // 透析困難情報リセット有無を取得する
      // const value = this.cardComponents.visitHstCard.getIsCheckResetDifficulty();
      // bug:4612 入外区分が変更されたため、透析困難をリセットします maxueqiang
      let inOutFlg = false;
      let inOutObj = this.cardComponents.basicInfoCard.getInOutClass();
      if (null != inOutObj && undefined != inOutObj){
        let initValue = inOutObj.initValue;
        let editValue = inOutObj.editValue;
        if ('1' == initValue && '0' == editValue){
          inOutFlg = true;
        }
      }
      // bug:4612 入外区分が変更されたため、透析困難をリセットします maxueqiang
      return inOutFlg;
    },

    async setCardDataBeforeSaving() {
      // 透析困難をリセットする
      if (this.isresetDifficulty) {
        this.cardComponents.difficultySeverityTransportCard.setClearDialDiffInfo();
      }
      // 透析困難カードの登録日時を設定
      this.cardComponents.difficultySeverityTransportCard.setRegDate();
      // 感染症カードの更新日を設定
      this.cardComponents.infectionCard.setRegDate();
      // add redmine 8302 透析歴が0年0ヶ月になる guanhao start
      // 日付
      this.cardComponents.visitHstCard.setOldestDialysis();
      // add redmine 8302 透析歴が0年0ヶ月になる guanhao end
      // 自施設を登録
      this.cardComponents.visitHstCard.setFacilityOwnData();
      // 診療情報の透析実施科を取得
      this.cardComponents.visitHstCard.setCourseOwnData(
        this.cardComponents.medicalCareInfoCard.getDialysisCourseCd()
      );
      // 担当者の主治医を取得
      this.cardComponents.visitHstCard.setDoctorOwnData(
        this.cardComponents.chargeStaffCard.getMainStaff()
      );

      // 既往歴が死亡を削除したら入外・転入出も死亡を削除へ
      const medicalHstDeleteItem = this.cardComponents.medicalHstCard.deathItem();
      if (medicalHstDeleteItem) {
        this.cardComponents.visitHstCard.deleteDeathItem(medicalHstDeleteItem);
        //add FNSI-画面部品デザイン じょはく start
        this.cardComponents.basicInfoCard.changeFlag();
        //add FNSI-画面部品デザイン じょはく end
      }

      // 入外・転入出が死亡を削除したら既往歴も死亡を削除へ
      const visitHstDeleteItem = this.cardComponents.visitHstCard.deathItem();
      if (visitHstDeleteItem) {
        this.cardComponents.medicalHstCard.deleteDeathItem(visitHstDeleteItem);
        //add FNSI-画面部品デザイン じょはく start
        this.cardComponents.basicInfoCard.changeFlag();
        //add FNSI-画面部品デザイン じょはく end
      }

      // 既往歴カードの転帰項目の死亡要素を入外・転入出に追加
      if (this.cardComponents.medicalHstCard.hasDeathItem()) {
        //add FNSI-画面部品デザイン じょはく start
        this.cardComponents.basicInfoCard.addDeathItem();
        //add FNSI-画面部品デザイン じょはく end
        await this.cardComponents.visitHstCard.addDeathItem(
          this.cardComponents.medicalHstCard.getDeathDate(),
          this.cardComponents.medicalHstCard.getDeathFacility(),
          this.cardComponents.medicalHstCard.getDeathCourse(),
          this.cardComponents.medicalHstCard.getDeathDiagnostician()
        );
      }

      // 診療情報カードに入外カードから透析導入日を設定
      const oldestDialysis = this.cardComponents.visitHstCard.getOldestDialysis();
      this.cardComponents.medicalCareInfoCard.setOldestDialysis(oldestDialysis);
    },

    numberingCtlNo(record, columnNames) {
      const workObj = cloneDeep(record);
      // ctl_no採番対象のJSON配列カラムをループ
      for (const columnName of columnNames) {
        if (!Object.prototype.hasOwnProperty.call(workObj, columnName)) {
          throw new Error(
            `ctl_no採番対象カラム[${columnName}]が患者情報レコードに存在しません。`
          );
        }

        const targetJsonAry = workObj[columnName];
        // 配列要素全てにctl_noキーがあるかチェック
        if (!targetJsonAry.every(json => Object.prototype.hasOwnProperty.call(json, "ctl_no"))) {
          throw new Error(
            `ctl_no採番対象カラム[${columnName}]の要素にctl_noが存在しません。`
          );
        }
        // 負数のctl_noを削除
        const deletedAry = targetJsonAry.filter(json => json.ctl_no >= 0);
        if (deletedAry.length === 0) {
          // 全削除された場合は次のカラムへ
          workObj[columnName] = [];
          continue;
        }
        // 最大のctl_noを取得
        // TODO: 排他チェックが必要になるならこれだとctl_noが被る可能性があるので要修正
        let maxCtlNo = _.maxBy(deletedAry, el => el.ctl_no)?.ctl_no || 0;
        // ctl_no:0 に対して採番
        const numberedAry = deletedAry.map(el => {
          if (el.ctl_no === 0) {
            el.ctl_no = ++maxCtlNo;
          }
          return el;
        });
        workObj[columnName] = numberedAry;
      }
      return workObj;
    },

    /**
     * @description カードサイズが変わる場合のコールバック関数
     */
    updateMasonry(needReload = false) {
      this.pendingMasonryLayoutNeedReload = this.pendingMasonryLayoutNeedReload || needReload;
      this.$nextTick(() => {
        if (this.pendingMasonryLayoutFrame) {
          cancelAnimationFrame(this.pendingMasonryLayoutFrame);
          this.pendingMasonryLayoutFrame = null;
        }
        this.pendingMasonryLayoutFrame = requestAnimationFrame(() => {
          this.pendingMasonryLayoutFrame = requestAnimationFrame(() => {
            this.pendingMasonryLayoutFrame = null;
            if (!this.masonry) {
              this.pendingMasonryLayoutNeedReload = false;
              return;
            }
            if (this.pendingMasonryLayoutNeedReload) {
              this.masonry.reloadItems();
            }
            this.masonry.layout();
            this.pendingMasonryLayoutNeedReload = false;
          });
        });
      });
    },

    // 11729 患者情報・新規患者登録画面のカード展開/折畳状態の保持不正 start
    layoutCardShowing() {
      // デフォルト設定適用(初期値は開いた状態なので、閉じた状態のみ適用)
      const defaultCondition = this.getDefaultSetting[KEY_NAME_PAT_INFO.KEY_NAME];
      if (!this.cardShowing.defaultSettingLoaded) {
        if (!(!defaultCondition || Object.keys(defaultCondition).length === 0)) {
          // 患者情報・新規患者登録のカード開閉状態を復元する
          this.cardShowingKeyNameData.map(data => data.keyName).forEach(keyName => {
            this.cardShowing.condition[keyName] = defaultCondition[keyName];
            // カード開閉状態が閉じている場合、カードを閉じる
            if (!defaultCondition[keyName]) {
              this.cardComponents[keyName].closeCard();
            }
          });
          this.updateCardShowingCondition();
        }
      } else {
        // サインイン中の患者情報・新規患者登録のカード開閉状態を復元する
        // 患者情報・新規患者登録のカード開閉状態を復元する
        this.cardShowingKeyNameData.map(data => data.keyName).forEach(keyName => {
          // カード開閉状態が閉じている場合、カードを閉じる
          if (!this.cardShowing.condition[keyName]) {
            this.cardComponents[keyName].closeCard();
          }
        });
      }
    },
    /**
     * カード開閉イベントハンドラ
     * @param cardName
     * @param isCardShowing
     */
    onChangeCardShowing(cardName, isCardShowing) {
      const data = this.cardShowingKeyNameData.find(data => data.cardName === cardName);
      if (data && data.keyName) {
        // カード開閉状態をストアに更新する
        this.cardShowing.condition[data.keyName] = isCardShowing;
        this.updateCardShowingCondition();
      }
      this.updateMasonry();
      if (isCardShowing) {
        this.scheduleAllCardTextareaHeightsAfterLayout();
      }
    },
    scheduleAllCardTextareaHeightsAfterLayout() {
      [0, 100, 300, 800].forEach(ms => {
        setTimeout(() => {
          this.$nextTick(() => this.adjustAllCardTextareaHeights());
        }, ms);
      });
    },
    adjustAllCardTextareaHeights() {
      Object.values(this.cardComponents || {}).forEach(card => {
        card?.adjustCardTextareaHeights?.();
      });
    },
    /**
     * 全カード開閉イベントハンドラ
     * @param isCardShowing
     */
    onChangeAllCardShowing(isCardShowing) {
      // 患者情報・新規患者登録の全てのカード開閉状態を変更してストアに保存する
      this.cardShowingKeyNameData.map(data => data.keyName).forEach(keyName => {
        this.cardShowing.condition[keyName] = isCardShowing;
      });
      this.updateCardShowingCondition();
      this.updateMasonry(true);
    },
    /**
     * 患者情報・新規患者登録毎のカード開閉状態の設定
     */
    updateCardShowingCondition() {
      this.setCardShowingCondition({
        cardListName: this.cardListName,
        cardShowingCondition: this.cardShowing.condition
      });
    },
    /**
     * 患者情報・新規患者登録毎のデフォルト設定の取得済みフラグの設定
     * @param isLoaded 取得済み: true
     */
    updateCardShowingDefaultSettingLoaded(isLoaded) {
      this.setCardShowingDefaultSettingLoaded({
        cardListName: this.cardListName,
        defaultSettingLoaded: isLoaded
      });
    },
    // 11729 患者情報・新規患者登録画面のカード展開/折畳状態の保持不正 end

    confirmCancel(answer) {
      if (answer === "OK") {
        this.cancelEdit();
        this.refreshData();
        if (this.headerClick) {
          // ヘッダから編集されている場合はカード一覧を閉じる
          this.setIsPatInfoVisible(!this.isPatInfoVisible); // mod #10234 スケジュール表のヘッダーから表示される患者情報画面の動作不正修正 宮崎
        }
        // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
        // this.isDatePicker = false;
        // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
        // 11729 患者情報・新規患者登録画面のカード展開/折畳状態の保持不正 start
        this.$emit('card-list-refresh');
        // 11729 患者情報・新規患者登録画面のカード展開/折畳状態の保持不正 end
      }
    },

    /**
     * @description 編集キャンセル
     */
    cancelEdit() {
      // 編集用レコードを初期化
      const recordCopy = cloneDeep(this.patRecord);

      // 保険情報の初期化
      EventBus.$emit("refreshCardContent");

      // 初期化情報にマスタデータを設定
      recordCopy.pat_personal_main.dial_diff_com_info = this.dialDiffInfo;

      // add by maxueqiang bug:5313  begin
      recordCopy.pat_personal_main.in_out_class = 3;
      recordCopy.pat_personal_main.nationality = "JPN";
      // add by maxueqiang bug:5313  end

      recordCopy.pat_main.infect_info = this.infectInfo;
      this.patRecordCopy = recordCopy;
      this.resetEditedComponent();
    },

    async confirmDeleteOrdPlan(answer) {
      this.TabooAllergyCompFlg = false;
      this.resetDifficultyCompFlg = false;
      if (answer === "Yes") {
        this.isDeleteOrdPlan = true;
        const checkResult = await this.checkIndUserSetting().catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('PatInfoCardList.vue', 'confirmDeleteOrdPlan', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
          throw error;
        });
        if (checkResult) {
          // 指示者設定モーダルを表示
          this.isModalVisible = true;
        } else {
          // 指示者リストが取得できない場合は保存処理を続行
          this.saveMain();
        }
      } else if (answer === "No") {
        // 保存処理
        this.saveMain();
      }
    },

    /**
     * @description 治療予定削除確認処理
     */
    async checkDeleteOrdPlan() {
      let type = "moveInOut";
      // add #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc start
      const moveOutDateAnt = [];
      // add #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc end
      this.isDeleteOrdPlan = false;
      // 転出日を取得
      // del #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc start
      // let date = null;
      // let dateObj = this.cardComponents.visitHstCard.getMoveOutDate();
      // if (dateObj != null) {
      //   date = dateObj.date;
      //   this.ordStringParams = dateObj.paramName;
      // }
      // del #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc end
      // 死亡日を取得
      const isDie = this.cardComponents.medicalHstCard.isDie;
      const dieDate = this.cardComponents.medicalHstCard.dieDate;
      // del #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc start
      // const medicalHstJsonArray = this.cardComponents.medicalHstCard.jsonArray;
      // const visitHstJsonArray = this.cardComponents.visitHstCard.jsonArray;
      // del #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc end

      if (isDie && dieDate !== null) {
        // mod #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc start
        // this.ordStringParams = "死亡日";
        if (!this.ordStringParams.includes("死亡日")) {
          this.ordStringParams.push("死亡日");
        }
        // mod #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc end
        // del #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc start
        // date = dayjs(dieDate, "YYYY-MM-DD HH:mm:ss");
        // del #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc end
        type = "death";
        // mod #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc start
        // moveOutDateAnt.push({'ind_start_date': date, 'ind_end_date': '99991231'});
        moveOutDateAnt.push({'ind_start_date': dayjs(dieDate).format("YYYYMMDD"), 'ind_end_date': '99991231'});
        // mod #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc end

      }
      // add #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc start
      //入外・転入出 転出日を取得
      const visitHstCardArray = this.cardComponents.visitHstCard.cardContent.jsonArray;
      if (!!visitHstCardArray && visitHstCardArray.length > 0) {
        const moveInOutTypes = {
          '3': '転出日',
          '7': '離脱日',
          '8': '移植日',
          '10': '通院拒否・不明'
        };
        visitHstCardArray.forEach(item => {
          // if (item.ctl_no.editValue >= 0){}
          if (item.ctl_no.editValue >= 0 && (item.move_in_out.initValue === null
              || item.move_in_out.initValue !== item.move_in_out.editValue
              || item.period_start.initValue !== item.period_start.editValue
              || item.period_end.initValue !== item.period_end.editValue
          )) {
            if (moveInOutTypes[item.move_in_out.editValue]) {
              const ordStringParams = moveInOutTypes[item.move_in_out.editValue];
              if (!this.ordStringParams.includes(ordStringParams)) {
                this.ordStringParams.push(ordStringParams);
              }
              if (item.period_start_date.editValue) {
                moveOutDateAnt.push({
                  'ind_start_date': dayjs(item.period_start_date.editValue).format("YYYYMMDD"),
                  'ind_end_date': '99991231'
                });
              }
            } else if (item.move_in_out.editValue == '9') {
              //一時転出
              if (!this.ordStringParams.includes('一時転出')) {
                this.ordStringParams.push('一時転出');
              }
              moveOutDateAnt.push({
                'ind_start_date': item.period_start_date.editValue ?
                    dayjs(item.period_start_date.editValue).format("YYYYMMDD") : dayjs(new Date()).format("YYYYMMDD"),
                'ind_end_date': item.period_end_date.editValue ?
                    dayjs(item.period_end_date.editValue).format("YYYYMMDD") : '99991231'
              });
            }
          }
        })

      }
      if(moveOutDateAnt.length === 0){
        return false;
      }
      this.moveOutDate = moveOutDateAnt;
      // add #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc end
      // del #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc start
      // if (date === null) {
        // 転出が選択されていなければ処理終了
        // return false;
      // }
      // this.moveOutDate = dayjs(date).format("YYYY-MM-DD");
      // del #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc end

      const selectParamJson = {};
      // 患者ID
      selectParamJson.pat_id = this.selectedPatId;
      // 施設コード
      selectParamJson.facility_cd = this.facilityCd;
      // mod #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc start
      //治療日のコレクション
      selectParamJson.move_out_date = this.moveOutDate;
      // 治療開始日
      // selectParamJson.ind_start_date = this.moveOutDate;
      // 治療終了日
      // selectParamJson.ind_end_date = "9999-12-31";
      // mod #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc end
      // 曜日パターン
      selectParamJson.week_pattern =
        "[{'text': '全','done': false,'value': 0}]";
      // 検査依頼/一般撮影検査依頼の確認用
      selectParamJson.type = type;
      // RestAPI実行
      const response = await ApiHelper.post(
        "/mainData/patInfo/deleteTargetCount",
        selectParamJson
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
        getErrorMessage('PatInfoCardList.vue', 'checkDeleteOrdPlan', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
        throw error;
      });

      let rstFlg = false;
      if (response.data != null && 0 === response.data) {
        return false;
      } else {
        rstFlg = true;
      }
      // del #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc start
      // add by maxueqiang bug:4269
      // if(Array.isArray(medicalHstJsonArray) && medicalHstJsonArray.length > 0){
      //   for(let i = 0; i<medicalHstJsonArray.length; i++){
      //     let inOutState = medicalHstJsonArray[i].out_come;
      //     if(null != inOutState && undefined != inOutState && inOutState.initValue == inOutState.editValue && inOutState.editValue == "10"){
      //       return false;
      //     }
      //
      //   }
      // }
      // 治療予定が存在した場合は予定削除確認ダイアログ表示
      // -----入外・転入出-----
      // 区分 = 3：転出、7：離脱、8：移植、10：通院拒否・不明
      // if(Array.isArray(visitHstJsonArray) && visitHstJsonArray.length > 0){
      //   for(let i = 0; i < visitHstJsonArray.length; i++){
      //     let inOutState = visitHstJsonArray[i].move_in_out;
      //     if(inOutState != undefined && inOutState != null){
      //       // mod #IES_6772 zs start
      //       // if((inOutState.initValue == inOutState.editValue) && (inOutState.editValue == "3" || inOutState.editValue == "7" || inOutState.editValue == "8" || inOutState.editValue == "10")){
      //       if((inOutState.initValue == inOutState.editValue) && (inOutState.editValue == "3" || inOutState.editValue == "7" || inOutState.editValue == "8" || inOutState.editValue == "9" || inOutState.editValue == "10")){
      //         // mod #IES_6772 zs end
      //         let inOutDate = visitHstJsonArray[i].period_start;
      //         if(inOutDate != undefined && inOutDate != null){
      //           if(inOutDate.initValue != null && inOutDate.editValue != null){
      //             return false;
      //           }
      //         }
      //       }
      //     }
      //   }
      // }
      // mod #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc end
      return rstFlg;
    },

    /**
     * @description 治療予定削除処理
     */
    async deleteOrdPlan() {
      // 指示履歴登録処理の仕様確定後実装
      let indUserId = this.getStateUserAccountInfo.userId;
      if (this.indUserId !== null) {
        // Storeに指示者が設定されている場合は対象のユーザIDを設定
        indUserId = this.indUserId;
      }
      const deleteParamJson = {};
      // 患者ID
      deleteParamJson.pat_id = this.selectedPatId;
      // 施設コード
      deleteParamJson.facility_cd = this.facilityCd;
      // mod #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc start
      // 治療開始日
      // deleteParamJson.start_date = this.moveOutDate;
      // 治療終了日
      // deleteParamJson.end_date = "9999-12-31";
      //治療日のコレクション
      deleteParamJson.move_out_date = this.moveOutDate;
      // mod #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc end
      // 登録者コード
      // 指示履歴登録処理の仕様確定後実装
      deleteParamJson.ind_user_id = indUserId
      // 更新者コード
      deleteParamJson.upd_user_id = this.getStateUserAccountInfo.userId;
      // 治療方法コード
      deleteParamJson.treatment_cd = null;
      // クール方法コード
      deleteParamJson.kur_cd = null;
      // 治療終了日設定フラグ
      deleteParamJson.is_deadline = "true";
      // 死亡登録の場合
      deleteParamJson.is_die_flg = this.cardComponents.medicalHstCard.isDie;

      //データの送信
      await ApiHelper.post("/mainData/deleteIndPlanPatInfo", deleteParamJson).catch(
        error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('PatInfoCardList.vue', 'deleteOrdPlan', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
          throw error;
        }
      );
    },
    /**
     * @description 指示者設定確認
     */
    async checkIndUserSetting() {
      this.setIsIndUserSetting(false);
      this.setIndUserId(null);
      // 指示者情報を取得
      const response = await ApiHelper.get(
        `/facilities/${this.getStateUserAccountInfo.facilityCd}/personal-user/job/doctor`,
        { selectedPatId: this.selectedPatId }
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
        getErrorMessage('PatInfoCardList.vue', 'checkIndUserSetting', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
        throw error;
      });
      if (0 !== response.data.length) {
        // 指示者リストを作成
        const indUserList = [];
        response.data.forEach(user => {
          indUserList.push({
            name: `${user.user_last_name} ${user.user_first_name}`,
            userId: user.user_id
          });
        });
        this.setIndUserList(indUserList);
        return true;
      } else {
        return false;
      }
    },
    // 禁忌・アレルギーダイアログ
    confirmRegTabooAllergy(answer) {
      if (answer === "OK") {
        // 保存処理
        this.TabooAllergyCompFlg = true;
        this.save();
      }
    },
    // 透析困難リセット確認ダイアログ
    confirmResetDifficulty(answer) {
      if (answer === "Yes") {
        this.isresetDifficulty = true;
      }
      if (answer !== "Cancel") {
        this.resetDifficultyCompFlg = true;
        this.save();
      } else {
        this.TabooAllergyCompFlg = false;
      }
    },
    // 並び替えモードリセット
    resetActionMode() {
      // 並び替えモード機能所持カード一覧
      const resetCardList = [
        "otherContactCard",
        "vendorContactCard",
        "insuranceInfoCard",
        "chargeStaffCard",
        "tabooAllergyCard",
        "infectionCard",
        "implantCard",
        "medicalHstCard",
        "visitHstCard",
        "patGroupCard"
      ];
      resetCardList.forEach(
        card => {
          if (this.cardComponents[card]) {
            this.cardComponents[card].$refs.cardContent.actionMode = false
          }
        }
      );
    },
    // 編集有無確認
    checkEditCard() {
      if (this.hasEditedComponent) {
        this.isCancelDialogVisible = true;
      } else {
        if (this.headerClick) {
          // 患者情報画面ページが表示中でない場合に切り替え
          this.setIsPatInfoVisible(!this.isPatInfoVisible);
        }
      }
    },
    // menu-barボタンの位置補正
    correctBtnPosition() {
      const sidebarSwitchObj = this.getCardListElementsByClassName("card-list");
      if (sidebarSwitchObj.length !== 0) {
        this.$nextTick(() => {
          const leftPos = sidebarSwitchObj[0].getBoundingClientRect().left;
          const menuBar = this.getCardListElementsByClassName("menu-bar")[0];
          if (!menuBar) {
            return;
          }
          if (leftPos !== 0) {
            menuBar.style.left = `${leftPos}px`;
          } else {
            menuBar.style.left = "";
          }
        });
      }
    },
    /**
     * @description カラムまたはキー値編集有無
     * @param { Object } columnList
     * @param { String } keyName
     */
    isEditedColumn(
      columnInfo,
      keyName = null,
      targetKeyName = null,
      targetValue = null
    ) {
      if (Object.prototype.hasOwnProperty.call(columnInfo, "initValue")) {
        // 単一カラム
        if (columnInfo.initValue !== columnInfo.editValue) {
          return true;
        }
      } else if (Array.isArray(columnInfo)) {
        // JSON配列カラム
        for (const column of columnInfo) {
          if (keyName === null) {
            // キー指定なし
            const keyList = Object.keys(column);
            const isEdited = keyList.find(
              key => column[key].initValue !== column[key].editValue
            );
            return isEdited;
          } else {
            let isTargetValue = true;
            if (targetKeyName !== null && targetValue !== null) {
              isTargetValue = column[targetKeyName].editValue === targetValue;
            }
            if (
              isTargetValue &&
              column[keyName].initValue !== column[keyName].editValue
            ) {
              return true;
            }
          }
        }
      } else {
        // 単一JSONカラム
        if (keyName === null) {
          // キー指定なし
          const keyList = Object.keys(columnInfo);
          const isEdited = keyList.find(
            key => columnInfo[key].initValue !== columnInfo[key].editValue
          );
          return isEdited;
        } else {
          if (columnInfo[keyName].initValue !== columnInfo[keyName].editValue) {
            return true;
          }
        }
      }
      return false;
    },

    /**
     * 判断patGroupCard内容是否修改
     * 原判断中只可判断编辑前后数量是否一致，无法判断在团体数量相同场景是否修改
     * add by maxueqiang
     */
    checkPatGroupCardEdit() {
      let result = false;
      if(undefined === this.cardComponents["patGroupCard"].$refs.cardContent
         || null === this.cardComponents["patGroupCard"].$refs.cardContent) {return result;}
      const editRecord = this.cardComponents["patGroupCard"].$refs.cardContent.editRecord;
      const orgRecord = this.cardComponents["patGroupCard"].$refs.cardContent.patRecord;
      if (null !== editRecord && null !== orgRecord) {
        let editList = editRecord["pat_group_list"];
        let orgList = orgRecord["pat_group_list"];
        if (Array.isArray(editList) && Array.isArray(orgList)) {
          let editListSort = editList.sort();
          let orgListSort = orgList.sort();
          let editString = JSON.stringify(editListSort);
          let orgString = JSON.stringify(orgListSort);
          if (editString !== orgString) {
            result = true;
          }
        }
      }
      return result;
    },
    // add 7519 profile連携（XML）で受信した詳細情報（患者フリーコメント） 関春麗 start
    /**
     * @description 受信XMLエスケープ文字の置換
     */
    patMemoInfo() {
      //add #7885 20220906 P_Ca９分割グラフで検査結果修正後、グラフ画面に戻れない（共通ローダが終わらない）gaoey start
      if (this.cardComponents["patMemoCard"].$refs.cardContent) {
      //add #7885 20220906 P_Ca９分割グラフで検査結果修正後、グラフ画面に戻れない（共通ローダが終わらない）gaoey end
        for (let index = 0; index <  this.cardComponents["patMemoCard"].$refs.cardContent.editRecord.pat_memo_info.length; index++) {
          let  content =  this.cardComponents["patMemoCard"].$refs.cardContent.editRecord.pat_memo_info[index].content.initValue ? this.cardComponents["patMemoCard"].$refs.cardContent.editRecord.pat_memo_info[index].content.initValue.replace("@#@",'"').replace("&apos;","'").replace("&lt;","<").replace("&gt;",">"):null;
          this.cardComponents["patMemoCard"].$refs.cardContent.editRecord.pat_memo_info[index].content.initValue = content;
          this.cardComponents["patMemoCard"].$refs.cardContent.editRecord.pat_memo_info[index].content.editValue = content;
          let  title = this.cardComponents["patMemoCard"].$refs.cardContent.editRecord.pat_memo_info[index].title.initValue ? this.cardComponents["patMemoCard"].$refs.cardContent.editRecord.pat_memo_info[index].title.initValue.replace("@#@",'"').replace("&apos;","'").replace("&lt;","<").replace("&gt;",">"):null;
          this.cardComponents["patMemoCard"].$refs.cardContent.editRecord.pat_memo_info[index].title.initValue = title;
          this.cardComponents["patMemoCard"].$refs.cardContent.editRecord.pat_memo_info[index].title.editValue = title;
        }
      //add #7885 20220906 P_Ca９分割グラフで検査結果修正後、グラフ画面に戻れない（共通ローダが終わらない）gaoey start
      }
      //add #7885 20220906 P_Ca９分割グラフで検査結果修正後、グラフ画面に戻れない（共通ローダが終わらない）gaoey end
    },
    // add 7519 profile連携（XML）で受信した詳細情報（患者フリーコメント） 関春麗 end
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
    checkCardInfoChanged(){
      let sortChanged = 0;
      const cardComponents = ['vendorContactCard', 'tabooAllergyCard', 'implantCard', 'otherContactCard', 'chargeStaffCard'];
      const cardComponentInfos = ['vendor_contact_info', 'taboo_allergy_info', 'implant_info', 'other_contact_info', 'charge_staff_info'];
      for (let i = 0; i < cardComponents.length; i++) {
        const cardName = cardComponents[i];
        const infoKey = cardComponentInfos[i];
        if (
            undefined === this.cardComponents[cardName].$refs.cardContent ||
            null === this.cardComponents[cardName].$refs.cardContent
        ) {
          continue;
        }
        const cardContent = this.cardComponents[cardName].$refs.cardContent;
        const editRecord = cardContent.editRecord;
        const orgRecord = cardContent.patRecord;
        if (null !== editRecord && null !== orgRecord) {
          let editList = editRecord[infoKey];
          let orgList = orgRecord[infoKey];
          if (Array.isArray(editList) && Array.isArray(orgList)) {
            let editListSort = JSON.parse(JSON.stringify(editList.sort()));
            let orgListSort = JSON.parse(JSON.stringify(orgList.sort()));
            cardName === 'tabooAllergyCard' && editListSort && editListSort.forEach(item => {
              delete item.readonly
            })
            cardName === 'implantCard' && editListSort && editListSort.forEach(item => {
              delete item.readonly
            })
            cardName === 'otherContactCard' && editListSort && editListSort.forEach(item => {
              delete item.readonly
            })
            cardName === 'chargeStaffCard' && editListSort && editListSort.forEach(item => {
              delete item.readonly
            })
            let editString = JSON.stringify(editListSort);
            let orgString = JSON.stringify(orgListSort);
            if (editString !== orgString) {
              sortChanged = sortChanged + 1;
            }
          }
        }
      }
      return sortChanged
    }
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
  },
};
</script>

<style scoped>
@import "../../assets/styles/modal.css";
.modal-container {
  width: 300px !important;
  height: auto !important;
}
.pat-info-area {
  color: var(--ntss-list-body-color);
}
.pat-info-area-margin {
  margin: 0;
}
.btn-group {
  position: fixed;
  bottom: 44px;
}
.btn-group.footer-menu-hidden-adjust {
  bottom: 0px;
}
.right-exe-btn {
  right: 0px;
}
.saving-modal {
  text-align: center;
  font-size: 30px;
}
@media print {
  .pat-info-area,
  .pat-info-area-margin {
    box-shadow: none !important;
  }
  /* 見出しボタン */
  .menu-bar {
    left: auto !important;
    position: absolute;
    height: auto !important;
  }
  /* コンテナ */
  .card-infos {
    column-count: 2;
    column-gap: 0;
    width: 85vw;
    min-height: 85vh !important;
    max-height: none !important;
    display: inline-block;
  }
  /* 見出しボタン非表示の場合は横幅いっぱい */
  body:has(.menu-bar-contents.none) .card-infos {
    width: 100vw;
  }
  /* カード */
  .item {
    /* 印刷プレビューではMasonry使用できないのでMasonryでの設定値を解除 */
    position: static !important;
    top: auto !important;
    left: auto !important;
    transform: none !important;

    width: 100%;

    /* 改ページ時のcolumn分割制御 */
    break-inside: avoid;
    page-break-inside: avoid;
    -webkit-column-break-inside: avoid;

    /* 高さ計算安定 */
    box-sizing: border-box;
  }
  /** 保存、キャンセルボタン非表示 */
  .btn-group {
    display: none;
  }
}
/* 横印刷時は3列 */
@media print and (orientation: landscape) {
  .card-infos {
    column-count: 3;
  }
}
@media screen and (max-width: 768px) {
  .item {
    width: 100%;
    overflow-y: hidden;
    overflow-x: hidden;
  }
}
@media screen and (min-width: 769px) {
  .item {
    width: 50%;
    overflow-y: hidden;
    overflow-x: hidden;
  }
}
@media screen and (min-width: 1600px) {
  .item {
    width: 33.33%;
    overflow-y: hidden;
    overflow-x: hidden;
  }
}
.item {
  display: inline-block;
  overflow-y: hidden;
  overflow-x: hidden;
}
.pat-info-header-area {
  overflow-y: hidden;
  height: calc(100% - 50px);
  color: var(--ntss-list-body-color);
  background-color: var(--main-background-color);
  box-shadow: none !important;
}
.pat-info-header-area .menu-bar {
  bottom: 0;
}
.pat-info-header-area .btn-group {
  bottom: 20px;
  z-index: 2;
}
.pat-info-header-area .right-exe-btn {
  right: 20px;
}

.info-size-set-x-large :deep(#infection-card-contents .card-contents .item-cell){
  white-space: normal;
  word-break: break-word;
  overflow-wrap: anywhere;
}


@media (min-width: 768px) and (max-width: 1280px) {
  .info-size-set-x-large :deep(#physical-info-card-contents .card-contents .edit-area .ntss-custom-button-table) {
    padding: 0.2em 0.2em 0em 0.2em !important;
  }
}




</style>
