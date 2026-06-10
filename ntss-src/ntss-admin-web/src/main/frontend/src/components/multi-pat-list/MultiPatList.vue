<template>
  <div id="multi-pat-list" class="multi-pat-list" style="height: 100%">
    <div class='multi-pat-list-header-switch'>
      <v-ons-row v-show="isMobileDevice" style="margin-left: 5px; width: 6em;" class="edit-mode">
        <v-ons-col width="45%" vertical-align="center">
          <label>編集</label>
        </v-ons-col>
        <v-ons-col width="55%" vertical-align="center">
          <v-ons-switch modifier="outline" class="custom-switch" style="float: left; margin-left: 2px;" v-model="allowEdit" />
        </v-ons-col>
      </v-ons-row>
    </div>
    <!-- 初期表示時にcolumnsの定義が存在していないと正常に表示できないのでレイアウト選択まで表示させない -->
    <kendo-grid
      v-if="isSelectedLayout"
      id="kendo"
      class="pat-num"
      ref="grid"
      :data-source="kendoDataSource"
      :editable="itemAuthorized"
      :reorderable="true"
      :resizable="true"
      :sortable="{ compare: compareByField }"
      :scrollable="true"
      :data-bound="kgridDataBound"
      :beforeEdit=onBeforeEdit
      height="100%"
      @save="editCell"
      :sort="sortHandler"
    >
      <!-- width属性を付与する場合は全カラムに存在しないと正しく表示されないので注意 -->
      <kendo-grid-column
        v-for="(column, index) in columns"
        :key="index"
        :title="column.title"
        :field="column.field"
        :locked="isLockedColumn"
        :editable="column.editable"
        :width="column.width"
        :attributes="{ class: column.attributes }"
      ></kendo-grid-column>
      <template v-for="(category, i) in kendoGridColumns">
        <!-- mod #10359_NG対応 編集権限の動作不正 dengshen start -->
        <!-- <kendo-grid-column -->
        <!--   v-if="category.key === 'card_creation'" -->
        <!--   :attributes="{ class: 'btn3-kendo-normal' }" -->
        <!--   :command="isCardDeviceConnected ? { text: 'カード作成', click: createCard } : null" -->
        <!--   width="130px" -->
        <!--   :key="`column_${i}`" -->
        <!--   :title="category.title" -->
        <!-- /> -->
        <kendo-grid-column
          v-if="category.key === 'card_creation' && getItemAuthorized('MultiPatList', 'default_authority')"
          :attributes="{ class: 'btn3-kendo-normal' }"
          :command="isCardDeviceConnected ? { text: 'カード作成', click: createCard } : null"
          width="130px"
          :key="`column_${i}`"
          :title="category.title"
        />
        <kendo-grid-column
          v-else-if="category.key === 'card_creation' && !getItemAuthorized('MultiPatList', 'default_authority')"
          :template='isCardDeviceConnected ? "<button disabled=true>カード作成</button>" : null'
          width="130px"
          :key="`column_${i}`"
          :title="category.title"
        />
        <!-- mod #10359_NG対応 編集権限の動作不正 dengshen end -->

        <kendo-grid-column
          v-else-if="isSingleColumnCategory(category.key)"
          :key="`column_${i}`"
          v-bind="category.columns[0]"
        />

        <kendo-grid-column
          v-else
          :key="`column_${i}`"
          :title="category.title"
          :columns="category.columns"
        />
      </template>
    </kendo-grid>
    <div class="multi-pat-list-footer-btn">
      <v-ons-button
        class="btn2-cancel-right btn2-cancel common-style-cancel-button"
        @click="cancelEdit"
      >
        キャンセル
      </v-ons-button>
      <v-ons-button
        class="btn1-execute common-style-ok-button"
        @click="updatePatRecords"
        :disabled="!getItemAuthorized('MultiPatList', 'default_authority') || !this.isEdited"
      >
        保存
      </v-ons-button>
    </div>

    <!-- <v-ons-modal :visible="isLoading">
      <p class="loading-modal">
        患者情報を取得しています
        <v-ons-icon icon="fa-spinner" spin />
      </p>
    </v-ons-modal>

    <v-ons-modal :visible="isUpdating">
      <p class="loading-modal">
        患者情報を更新しています
        <v-ons-icon icon="fa-spinner" spin />
      </p>
    </v-ons-modal> -->

    <v-ons-popover
      v-if="isPopoverVisible"
      :visible.sync="isPopoverVisible"
      :target="popoverTarget"
      cancelable
      :class="fontSizeSet"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <div class="transition-popover">
        <v-ons-button :disabled="!this.hasPatInfoAuthority" class="transition-button btn3-normal" @click="moveTo('pat-info')">
          <img class="icon" :src="imagePatInfo"/>
          患者情報
        </v-ons-button>
        <v-ons-button :disabled="!this.hasPatViewerAuthority" class="transition-button btn3-normal" @click="moveTo('pat-viewer')">
          <img class="icon" :src="imagePatViewer"/>
          患者経過総合ビューア
        </v-ons-button>
        <v-ons-button
          :disabled="!this.hasTreatmentRecordAuthority"
          class="transition-button btn3-normal"
          @click="moveTo('treatment-record')"
        >
          <img class="icon" :src="imageTreatmentRecord"/>
          治療記録
        </v-ons-button>
      </div>
    </v-ons-popover>

    <message-dialog
      :visible.sync="isNoEditDialogVisible"
      :message-cd="20010003"
      type="1"
    />
    <message-dialog
      :visible.sync="isCancelEditDialogVisible"
      :message-cd="20010001"
      type="2"
      @confirm="confirmCancelEdit"
    />
    <message-dialog
      :visible.sync="isSomeStaffDialogVisible"
      :message-cd="73000001"
      :string-params="[stringParams]"
      type="1"
    />
    <message-dialog
      :visible.sync="isValidateVisible"
      :message-cd="20010002"
      :string-params="[validateStringParams]"
      type="1"
    />
  </div>
</template>

<script>
import $$ from "jquery";
import _ from "underscore";
import cloneDeep from "lodash/cloneDeep";
// add FNSI-改修内容 パンくずリスト押下時に最新の情報を取得する。表示条件の変更はしない dou start
import { EventBus } from '@/eventBus.js'
// import { mstCdToName } from "@/functions/common/CommonFunctions.js";
// add FNSI-改修内容 パンくずリスト押下時に最新の情報を取得する。表示条件の変更はしない dou end
// import { saveExcel } from "@progress/kendo-vue-excel-export";
var workbook_1 = require("@progress/kendo-vue-excel-export");
var kendo_file_saver_1 = require("@progress/kendo-file-saver");
import moment from "moment";
import {mapGetters, mapActions, mapMutations} from "vuex";
import encoding from "encoding-japanese";
import { ApiHelper } from "@/apis/AxiosHelper";
// add FNSI-改修内容 権限関連 dou start
import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
// add FNSI-改修内容 権限関連 dou end
// mod #10359 編集権限の動作不正 dengshen start
// import { deepCopy } from "@/functions/common/CommonFunctions.js";
import { deepCopy, getAuthorized } from "@/functions/common/CommonFunctions.js";
// mod #10359 編集権限の動作不正 dengshen end
import {
  getRequiredMst,
  createKendoColumns,
  mapPatInfoToKendoDataSource,
  mapKendoDisplayProperty,
  mapKendoDisplayPropertyIndUser,
  isNoUpdateField,
  convertToUpdateValue,
  getPatRecords,
  updatePatRecords,
  isSingleColumnCategory,
  isIndUserColumn,
  requiredList,
  columnInfoRequiredList
} from "./Functions.js";
import { getWeightByTreatDateAndOrdClass } from "@/apis/send-condition";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
import IndUserSelectMixin from "@/components/common/IndUserSelectMixin";
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import PopoverMixin from "@/components/PopoverMixin";
// add データリストの患者情報修正 陳 start
import { LAYOUT_ITEM_KEY_SUFFIX_DATEOBJECT, LAYOUT_ITEM_KEY_SUFFIX_MSTNAME, PSEUDO_MST_LIST } from "@/components/multi-pat-list/Definitions";
import { sendRequestGetMstTreatment } from "@/apis/treatment-record";
// add データリストの患者情報修正 陳 end
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
//add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
import { getCurrentFunctionCd } from "@/router/routing-helper";
//add 5984 機能帳票でパラメータが正しく渡されていない 吉 end
// add 2020-09-25 FNSI-4200ポートを使用している 孫 start
const uriGetCardAppPort = `/card_state/get_card_app_ports`;
// add 2020-09-25 FNSI-4200ポートを使用している 孫 end
// add FNSI-7123 データリストで非表示状態の患者メモも値が表示される 劉全航 start
import { sendRequestFindRecordListByFacilityCd } from "@/apis/master-maintenance";
// add FNSI-7123 データリストで非表示状態の患者メモも値が表示される 劉全航 end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
import DateInput from "@/components/common/DateInput";
import TimeInput from "@/components/common/TimeInput";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import { DATE_FORMAT, dateFormat } from "@/functions/common/DateTimeUtils";
import { sortableCompare } from "@/functions/SortFunctions";
import Vue from "vue";
import PrintMixin from "@/components/PrintMixin";

const JSON_ARRAY_ITEM = {
  other_contact_info: {
    ctl_no: 0,
    disp_order: 0,
    is_key_person: "0",
    pat_id: null,
    last_name: null,
    first_name: null,
    last_name_kana: null,
    first_name_kana: null,
    relation_cd: null,
    relation_name: null,
    zip_cd: null,
    address: null,
    tel1: null,
    tel2: null,
    fax: null,
    e_mail: null,
    work_name: null,
    work_address: null,
    work_tel: null,
    memo1: null,
    memo2: null
  },

  vendor_contact_info: {
    ctl_no: 0,
    disp_order: 0,
    company_name: null,
    zip_cd: null,
    address: null,
    company_tel: null,
    fax: null,
    worker_last_name: null,
    worker_first_name: null,
    worker_tel: null,
    worker_e_mail: null,
    memo1: null,
    memo2: null
  },

  charge_staff_info: {
    ctl_no: 0,
    is_main: "0",
    staff_cd: null,
    is_charge: "0",
    disp_order: 0,
    is_puncture: "0"
  },

  medical_hst_info: {
    ctl_no: 1,
    facility_cd: null,
    disp_order: 0,
    disease_date: null,
    diagnosis_year: null,
    diagnosis_month: null,
    diagnosis_day: null,
    diagnosis_facility_cd: null,
    course_cd: null,
    diagnostician_cd: null,
    disease_cd: null,
    is_main_disease: "0",
    is_notice: "0",
    is_dialysis_underlying_disease: "-1",
    is_confirmation_biopsy: "",
    // 死亡
    out_come: "-10",
    is_diagnosed: "0",
    out_come_date: null,
    memo: null
  },

  physical_info: {
    ctl_no: 0,
    exam_date: null,
    order_class: null,
    height: null,
    ctr_weight: null,
    breast_dia: null,
    chest_dia: null,
    ctr: null,
    dw: null,
    pre_scale_upper: null,
    pre_scale_lower: null,
    target_weight: null,
    indicator_cd: null,
    indicator_start_date: null,
    memo: null,
    facility_cd: null,
// add データリストの患者情報修正 陳 start
    target_weight_chkbox : null
// add データリストの患者情報修正 陳 end
  },
  card_creation: {
    card_creation: null
  }
};

const CLASS_EDITED_CELL = "grid-edited-cell";
const CLASS_REQUIRED_CELL = "grid-required-cell";
const CLASS_AFTERSENDCONDITION_CELL = "grid-after-send-condition-cell";
const CLASS_DIALYSIS_CELL = "grid-dialysis-cell";
const CLASS_AFTERDIALYSIS_CELL = "grid-after-dialysis-cell";

export default {
  components: {
    "message-dialog": messageDialog
  },
// mod FNSI-改修内容 権限関連 dou start
  // mixins: [IndUserSelectMixin, PopoverMixin],
  mixins: [IndUserSelectMixin, PopoverMixin, ComponentGuardMixin, PrintMixin],
// mod FNSI-改修内容 権限関連 dou end
  data() {
    return {
      // add #10359 編集権限の動作不正 dengshen start
      itemAuthorized: true,
      // add #10359 編集権限の動作不正 dengshen end
      sameList: [],
      inOutList: [],
      imagePatInfo: require("@/../public/img/pat-info/pat-info.png"),
      imagePatViewer: require("@/../public/img/pat-viewer/pat-viewer.png"),
      imageTreatmentRecord: require("@/../public/img/treatment-record/treatment-record.png"),
      //患者経過総合ビューア
      hasPatViewerAuthority: false,
      //治療記録
      hasTreatmentRecordAuthority: false,
      // 患者情報
      hasPatInfoAuthority: false,
      items: [],
      layoutMst: null,
      mstList: {},
      kendoDataSource: null,
      kendoDataSourceClone: null,
      // 初期患者レコード
      initialPatRecords: null,
      // 更新用患者レコード
      patRecordsForUpdating: [],
      // 編集した患者IDとカラム名の対応 { id: [field, ...] }
      editedPatIdFieldList: {},
      selectedPatId: null,
      isPopoverVisible: false,
      popoverTarget: null,
      isNoEditDialogVisible: false,
      isCancelEditDialogVisible: false,
      isSomeStaffDialogVisible: false,
      stringParams: null,
      validateObject: {},
      isValidateVisible: false,
      validateStringParams: "",
      isCardDeviceConnected: false,
      socketInterval: null,
      getWriteCardResponse: null,
      mstTreatment: [],
      columns: [
        {
          field: "pat_personal_main$hosp_pat_id",
          title: "患者ID",
          width:'150px',
          hidden: false,
          editable: () => false,
          attributes: "cell-hosppatid hosp-pat-id-body"
        },
        {
          field: "pat_personal_main$pat_name",
          title: "患者名",
          width:'150px',
          hidden: false,
          editable: () => false,
          attributes: "cell-patname"
        }
      ],
      unSavedInfo: [],
      selfScreenName: "",
      androidFlg: false,
      iosFlg: false,
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
      scrollQuerySelector: ".k-grid-content", // スクロールコンテナ
      addClassTargetQuerySelector: [".k-grid-header-wrap table, .k-grid-content table"], // scroll-rightmostクラスを付与する対象のクエリセレクタ
    };
  },
  props: {
    patArr: { type: Array, default: () => [] },
    ordArr: {
      type: Object, 
      default: () => ({
        afterSendConditionArr: [],
        dialysisArr: [],
        afterDialysisArr: []
      }) 
    },
    patIdListToDisplay: {
      type: Array,
      default: () => []
    },
    patRecords: {
      type: Array,
      default: () => []
    }
  },
  computed: {
    ...mapGetters("pat-info", ["searchedPatList"]),
    ...mapGetters("user", { facilityCd: "getFacilityCd", userId: "getUserId"  }),
    ...mapGetters("account-edit", { fontSize: "getFontSize" }),
    ...mapGetters("data-list", { initflg: "getInitflg"}),
    ...mapGetters("data-list", {
      reqExportExcel: "getRequestExportExcel",
      reqExportCSV: "getRequestExportCSV",
      getSelectedLayout: "getSelectedLayout"
    }),
    ...mapGetters("websocket-card", ["getSocketIsConnected", "getSocketMessages", "getCardDeviceStatus"]),
    ...mapGetters("multi-pat-list", [
      "getDoctorList",
      "getDoctorId",
      "getDoctorName"
    ]),
    ...mapGetters("window-size", {
      windowWidth: "getSplittedWidth",
      windowHeight: "getWindowHeight"
    }),
    /* add EOL対応内部 #6921 by ztc 2023-07-08 --end */
// add FNSI-改修内容 入外区分が入院の場合、患者名は紫色にする。同姓同名患者の場合はそれが判断可能にする。 dou start
    isSameList() {
      return this.searchedPatList
        .filter(el => el.is_same == '1')
        .map(el => el.pat_id);
    },

    isInOutList() {
      return this.searchedPatList
        .filter(el => el.in_out_class == 1)
        .map(el => el.pat_id);
    },

    kendoGridColumns() {
      if (this.getSelectedLayout == null) {
        // this.getSelectedLayout が null の場合は処理を実施しない
        return [];
      }
      return createKendoColumns(this.getSelectedLayout);
    },

    isEdited() {
      return Object.keys(this.editedPatIdFieldList).length > 0;
    },

    isSelectedLayout() {
      return this.getSelectedLayout !== null;
    },

    isLockedColumn() {
      if (this.getSelectedLayout.length === 1)
        return this.getSelectedLayout[0].items.length > 4 && screen.width > 700;
      else return this.getSelectedLayout.length > 1 && screen.width > 700;
    },

    /**
     * @description 関係情報変更関数
     */
    changeInfo() {
      const info = {
        other_contact_info: this.changeInfoToOtherContact,
        other_contact_key_person_info: this.changeInfoToOtherContact,
        charge_staff_info: this.changeInfoToChargeStaffInfo,
        medical_hst_info: this.changeInfoToMedicalHstInfo,
        physical_info: this.changeInfoToPhysicalInfo
      };
      return info;
    },

    /**
     * @description 新規追加要素の初期値変更
     */
    settingColumnsFuc() {
      return {
        other_contact_info: this.setKeyPerson,
        charge_staff_info: this.setchargeStaffInfo,
        medical_hst_info: this.setFacilityCd,
        physical_info: this.setFacilityCd
      };
    },
    isMobileDevice() {
      return this.iosFlg || this.androidFlg;
    }
  },
  watch: {
    ordArr: {
      handler(newVal, oldVal) {
        const isChanged = !_.isEqual(newVal, oldVal);
        if (this.isEdited && isChanged) {
          this.$ons.notification.confirm({
            title: DIALOG_MESSAGES[13000004].title,
            message: messageFormat(DIALOG_MESSAGES[13000004].message),
            callback: answer => {
              if (answer === 1) {
                this.getInitData();
              }
            }
          });
        } else {
          this.getInitData();
        }
      },
      deep: true,
      immediate: true
    },
    /**
     * @description テンプレート切り替え時
     */

    getSelectedLayout(value) {
      if (value) {
        this.setGridHeight();
      }
    },
    reqExportCSV() {
      this.onCreateTemplateToCSV();
    },
    reqExportExcel() {
      this.onCreateTemplateToExcel();
    },
    /**
     * @description 患者検索結果切り替え時
     */
    kendoDataSource() {
      this.setGridHeight();
      if (this.getSelectedLayout !== null) {
        this.$nextTick(() => {
          // this.findRequiredCell();
          // add FNSI6256-背景色が変わらない 周 start
          this.findPatInDialysis();
          // add FNSI6256-背景色が変わらない 周 end
        });
      }
    },

    /**
     * @description フォントサイズ切り替え時
     */
    fontSize() {
      this.setGridHeight();
    },
    windowWidth() {
      this.setGridHeight();
    },
    windowHeight() {
      this.setGridHeight();
    },
    getSocketIsConnected(value) {
      this.isCardDeviceConnected = false;
      if (!value === true) {
        // 再接続
        this.reconnectSocket();
      } else {
        clearInterval(this.socketInterval);
      }
    },
    getSocketMessages(value) {
      if (value == null) return;
      const splitMsg = value.split("\t");
      if (splitMsg.length > 1) {
        if (splitMsg[0] == "CARD_CLIENT") {
          switch(splitMsg[1]) {
            case "CARD_READER_STATUS":
              this.isCardDeviceConnected = JSON.parse(splitMsg[2].toLowerCase());
              this.clearSocketMessage();
              break;
            case "CARD_WRITE_STATUS":
              this.finishLoadingScreen();
              if (JSON.parse(splitMsg[2].toLowerCase()) == true) {
                this.$ons.notification.alert({
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                  // title: "保存成功",
                  // message: "カード情報が</br>保存されました。"
                  title: DIALOG_MESSAGES[12000291].title,
                  message: messageFormat(DIALOG_MESSAGES[12000291].message)
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                });
              } else {
                this.$ons.notification.alert({
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                  // title: "保存失敗",
                  // message: "カードの書き込みに失敗しました。"
                  title: DIALOG_MESSAGES["00200103"].title,
                  message: messageFormat(DIALOG_MESSAGES['00200103'].message)
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                });
              }
              this.clearSocketMessage();
              break;
          }
        }
      }
    },
    getCardDeviceStatus(value) {
      this.isCardDeviceConnected = value;
    },
    isEdited() {
      this.setIsDataChanged(this.isEdited);
    },
  },

  async created() {
    // 端末判別
    const ua = navigator.userAgent.toLowerCase();
    if (/android/.test(ua)) {
      this.androidFlg = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.iosFlg = true;
    }
    // 画面名称取得
    this.selfScreenName = this.$router.currentRoute.name;
    EventBus.$off("requestReportParams", this.requestrReportParams);
    EventBus.$on("requestReportParams", this.requestrReportParams);
    EventBus.$off("resizeToFitTextArea", this.resizeToFitTextArea);
    EventBus.$on("resizeToFitTextArea", this.resizeToFitTextArea);
    // データリスト変更後保存ボタンが不活性になります
    this.setAuthority()
  },

  methods: {
    ...mapGetters("account-edit", ["getUserId", "getUserName"]),
    ...mapActions("data-list", [
      "setInitflg",
      "setIsDataChanged",
    ]),
    ...mapMutations("multi-pat-list", [
      "setDoctorList",
      "setDoctorId",
      "setDoctorName",
    ]),
    ...mapActions("pat-info", ["selectPat"]),
    ...mapActions("websocket-card", ["init", "connect", "sendSocketMessage", "close", "clearSocketMessage"]),
    ...mapActions("loading-screen", ["startLoadingScreen", "finishLoadingScreen"]),
    isSingleColumnCategory,
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,

    /**
     * 列ヘッダクリック時にソート順を設定
     * @param {*} e 
     */
    sortHandler(e) {
      this.currentSort = e.sort;
    },
    /**
     * 列ヘッダクリック時のソート処理
     * @param {*} a 
     * @param {*} b 
     */
    compareByField(a, b) {
      // ソートなしはreturn
      if (!this.currentSort || !this.currentSort.field) return;
      
      // 共通関数でソート      
      return sortableCompare(a, b, this.currentSort.field, true);
    },
    
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end

    changechk() {
      this.parent.click();
    },
    requestrReportParams(param) {
      if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {
        const param = {
          // del #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
          //patId: this.selectedPatId,
          // del #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
          patIds: this.searchedPatList.map(({ pat_id }) => pat_id),
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
          // facilityCd: this.getFacilityCd,
          // date:moment(this.indStartDate).format('YYYY/MM/DD'),
          // fromDate: moment(this.indStartDate).format('YYYY/MM/DD'),
          // toDate: moment(this.indEndDate).format('YYYY/MM/DD'),
          facilityCd: this.facilityCd,
          date: moment(Date.now()).format("YYYYMMDD"),
          fromDate: moment(Date.now()).format("YYYYMMDD"),
          toDate: moment(Date.now()).format("YYYYMMDD"),
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
          //dialysisDate: moment(Date.now()).format("YYYYMMDD"),
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
          functionCd:"00801",
        };
        EventBus.$emit("sendReportParams", param);
      }
    },
// add FNSI-改修内容 入外区分が入院の場合、患者名は紫色にする。同姓同名患者の場合はそれが判断可能にする。 dou start
    setSameName(){
      if (this.inOutList.length > 0) {
        this.inOutList.forEach(x => {
          $$("td.cell-hosppatid").filter(function () {
            return $$(this).text().trim() === x;
          }).each(function () {
            // このtdの論理的な行インデックスを取得
            const rowIndex = $$(this).closest("tr").index();
            // rowIndexに対応する全てのtr（固定列 + 可変列）を取得
            const matchedRows = $$(`.k-grid-content-locked tr:eq(${rowIndex}), .k-grid-content tr:eq(${rowIndex})`);
            matchedRows.each(function () {
              // 対象行から patname セルを探して色変更
              $$(this).find("td.cell-patname").css("color", "#A356A3");
            });
          });
        });
      }
      if (this.sameList.length > 0) {
        this.sameList = _.uniq(this.sameList);
        let img = `<img class="same-icon" src="${require('../../assets/name_duplication.png')}"/>`;
        this.sameList.forEach(x => {
          // mod #11321 【たくしん会】データリストレイアウトマスタ＞身体情報(追加登録)とデータリスト表示バグ zkm start
          // let el2 = $$(`td.cell-patname:contains(${x})`);
          let el = $$(`td.cell-patname:contains(${x})`).filter(function() {
            return $$(this).text().trim() === x;
          });
          // mod #11321 【たくしん会】データリストレイアウトマスタ＞身体情報(追加登録)とデータリスト表示バグ zkm end
          if (el.html()) {
            el.html(el.html() + img);
          }
        });
      }
    },
// add FNSI-改修内容 入外区分が入院の場合、患者名は紫色にする。同姓同名患者の場合はそれが判断可能にする。 dou end
// add FNSI-改修内容 権限関連 dou start
    setAuthority(){
      // mod #10359、#10331 編集権限について、対応する。 dengshen start
      // //患者経過総合ビューア
      // this.hasPatViewerAuthority = this.hasAuthorityByCd(AUTHORITY_CODES.IND_PEDIT) || this.hasAuthorityByCd(AUTHORITY_CODES.IND_EDIT);
      // //治療記録
      // this.hasTreatmentRecordAuthority = this.hasAuthorityByCd(AUTHORITY_CODES.RST_PEDIT) || this.hasAuthorityByCd(AUTHORITY_CODES.RST_EDIT);
      // // 患者情報
      // this.hasPatInfoAuthority = this.hasAuthorityByCd(AUTHORITY_CODES.PAT_PEDIT) || this.hasAuthorityByCd(AUTHORITY_CODES.PAT_EDIT);
      //患者経過総合ビューア
      this.hasPatViewerAuthority = true;
      //治療記録
      this.hasTreatmentRecordAuthority = true;
      // 患者情報
      this.hasPatInfoAuthority = true;
      // mod #10359、#10331 編集権限について、対応する。 dengshen end
      // add #10359 編集権限の動作不正 dengshen start
      this.itemAuthorized =  this.getItemAuthorized('MultiPatList', 'default_authority');
      // add #10359 編集権限の動作不正 dengshen end
    },
// add FNSI-改修内容 権限関連 dou end
// add FNSI-改修内容 パンくずリスト押下時に最新の情報を取得する。表示条件の変更はしない dou start
    async getInitData() {
      if (this.selfScreenName !== this.$router.currentRoute.name) {
        return;
      }
      this.setAuthority()
      this.getMstTreatment();
      if (!this.getSocketIsConnected || null === this.getCardDeviceStatus) {
        // card appのwebsokcet以外場合、接続したサービスを閉じました
        if (this.getSocketIsConnected) {
          this.close();
        }

        // localStorageのportを利用する
        let defaultPort = localStorage.getItem("CARD_APP_PORT");
        if(!/^\d+$/.test(defaultPort)){
          localStorage.removeItem("CARD_APP_PORT");
          defaultPort = null;
        }
        if (null !== defaultPort) {
          // localStorageがあり場合、接続を実施する
          this.init({ port: defaultPort, facilityCd: "" });
          this.connect();
        }

        // 接続確認実施
        // APP接続しません、または、カードリーダーが無し
        if (!this.getSocketIsConnected || null === this.getCardDeviceStatus) {
          // 「カードアプリポート管理」からportを取得する
          let facilityCd = this.facilityCd;
          let cardPorts = await ApiHelper.get(`${uriGetCardAppPort}/${facilityCd}`).catch(() => {
            //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
            getErrorMessage('MultiPatList.vue', 'getInitData', 'カードアプリポート管理から、ポートを取得しません。');
            //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
            throw new Error("カードアプリポート管理から、ポートを取得しません。");
          });

          // portsをループする
          let portList = new Array();
          if (cardPorts.data.toString().indexOf(",") == -1) {
            portList[0] = cardPorts.data.toString();
          } else {
            portList = cardPorts.data.toString().split(",");
          }
          for(let i = 0; i < portList.length; i++) {
            // APP接続しません、または、カードリーダーが無し
            if (!this.getSocketIsConnected || null === this.getCardDeviceStatus) {
              // card appのwebsokcet以外場合、接続したサービスを閉じました
              if (this.getSocketIsConnected) {
                this.close();
              }

              // 接続を実施する
              this.init({ port: portList[i], facilityCd: "" });
              this.connect();

            }
          }
        }
      // mod FNSI-4200ポートを使用している 孫 end
      } else {
        this.isCardDeviceConnected = this.getCardDeviceStatus
      }
      // Windowリサイズ検知(ズーム等の操作)
      window.addEventListener("resize", this.setGridHeight, false);
      this.startLoadingScreen();
      // 指示者ドロップダウンの設定
      const response = await this.getIndUserList(AUTHORITY_CODES.IND_EDIT, AUTHORITY_CODES.IND_PEDIT);
      let lstIndUser = [];
      this.setDoctorId(response.iniSelectId);
      response.doctorList.forEach(doctor => {
        if (doctor.user_id) {
          let doc = {};
          doc.userId = doctor.user_id;
          doc.userName = doctor.fullName;
          lstIndUser.push(doc);
        }
        if (doctor.user_id === this.getDoctorId) {
          this.setDoctorName(doctor.fullName);
        }
      });
      this.setDoctorList(lstIndUser)

      await this.changeDisplayPat();

      // Rootページのサイドバーボタン要素のイベントリスナー解除・登録
      // ※「サイドバーイベント発火用※サイドバー表示非表示のスタイル崩れ防止」のリファクタ
      const rootSideBarBtn = document.querySelector('#showPatientSearchSidebarBtn');
      rootSideBarBtn?.removeEventListener('click', this.setGridHeight);
      rootSideBarBtn?.addEventListener('click', this.setGridHeight);

      this.finishLoadingScreen();
    },
    async onCreateTemplateToCSV() {
      if (this.isEdited) {
        this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "更新確認",
          title: DIALOG_MESSAGES[13000104].title,
          // message: "編集中の項目があります。保存しますか？",
          message: messageFormat(DIALOG_MESSAGES[13000104].message),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          buttonLabels: ["いいえ", "はい"],
          callback: async answer => {
            if (answer === 1) {
              await this.updatePatRecords();
              await this.exportToCSV();
            }
          }
        });
      } else await this.exportToCSV();
    },
    async exportToCSV() {
      await this.changeDisplayPat();
      let physicalNames = "";
      const arrayFields = [];
      this.columns.forEach(field => {
        if (field.width !== "0px") {
          physicalNames += field.title;
          arrayFields.push(field.field);
          physicalNames += ",";
        }
      });

      if (this.kendoGridColumns.length > 0) {
        this.kendoGridColumns.forEach(field => {
          field.columns.forEach(f => {
            physicalNames += f.title;
            arrayFields.push(f.field);
            physicalNames += ",";
          });
        });
      }
      physicalNames = physicalNames.substring(0, physicalNames.length - 1);
      physicalNames += "\n";

      if (this.kendoDataSource !== null) {
        const addNewData = [];
        // ソート後のdataSourceをファイル出力
        const grid = this.$refs.grid.kendoWidget();
        const viewData = grid.dataSource.view();
        const dataArray = Array.from(viewData)
        
        Array(dataArray).forEach(data => {
          Object.values(data).forEach(e => {
            const tempData = [];
            // Object.keys(e).forEach(key => {
            //   if (!arrayFields.includes(key)) {
            //     return;
            //   } else {
            //     tempData.push(e[key]);
            //   }
            // });
            arrayFields.forEach(field => {
              if (e[field]) {
                tempData.push(e[field]);
              } else {
                tempData.push("");
              }
            });
            addNewData.push(tempData);
          });
        });

        Array(addNewData).forEach(t => {
          Object.values(t).forEach(k => {
            Object.values(k).forEach(r => {
              let temp = String(r);
              if (temp.indexOf(",") > -1)
                r = temp.replace(temp, '"' + temp + '"');
              else {
                if (r !== null) r = temp.replace(temp, '"' + temp + '"');
                else r = temp.replace(temp, '""');
              }
              physicalNames += `${r},`;
            });
            physicalNames += `\n`;
          });
        });
      }

      const charCodes = [];
      for (let i = 0; i < physicalNames.length; i++) {
        charCodes.push(physicalNames.charCodeAt(i));
      }

      const sjisCodes = encoding.convert(charCodes, "sjis", "unicode");
      const uint8s = new Uint8Array(sjisCodes);
      const blob = new Blob([uint8s], { type: "test/csv" });

      let link = document.createElement("a");
      link.href = window.URL.createObjectURL(blob);
      link.download = `データリスト_${moment().format("YYYYMMDDHHmmss")}.csv`;
      link.click();
    },
    async onCreateTemplateToExcel() {
      // ソート後のdataSourceをファイル出力
      const grid = this.$refs.grid.kendoWidget();
      const viewData = grid.dataSource.view();
      const dataArray = Array.from(viewData)
      
      if (this.isEdited) {
        this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "更新確認",
          title: DIALOG_MESSAGES[13000105].title,
          // message: "編集内容がありますので、保存しますか。？",
          message: messageFormat(DIALOG_MESSAGES[13000105].message),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          buttonLabels: ["いいえ", "はい"],
          callback: async answer => {
            if (answer === 1) {
              await this.updatePatRecords();
              await this.changeDisplayPat();
              this.saveExcel({
                data: dataArray,
                fileName: `データリスト_${moment().format("YYYYMMDDHHmmss")}`,
                columns: this.getData()
              });
            }
          }
        });
      } else {
        await this.changeDisplayPat();
        this.saveExcel({
          data:
            this.kendoDataSource !== null ? dataArray : null,
          fileName: `データリスト_${moment().format("YYYYMMDDHHmmss")}`,
          columns: this.getData()
        });
      }
    },
    saveExcel(exportOptions) {
      let saveFn = function (dataURL) {
        kendo_file_saver_1.saveAs(dataURL, exportOptions.fileName, {
          forceProxy: exportOptions.forceProxy,
          proxyURL: exportOptions.proxyURL
        });
      };
      let options = workbook_1.workbookOptions(exportOptions);
      options.sheets.forEach(item => {
        item.rows.forEach(row => {
          if (row.type === 'data') {
            let height = 15;
            row.cells.forEach(cell => {
              let vals = 1;
              if (cell.value) {
                vals = (cell.value + "").split('\n').length;
              }
              if (vals * 15 > height){
                height = vals * 15;
              }
              if (height > 15) {
                cell.wrap = true;
                row.height = height;
              } else {
                cell.wrap = false;
              }
            });
          }
        });
      });
      workbook_1.toDataURL(options).then(saveFn);
    },
    getData() {
      let physicalNames = [];

      this.columns.forEach(field => {
        physicalNames.push(field);
      });

      this.kendoGridColumns.forEach(field => {
        field.columns.forEach(column => {
          let columnTmp = deepCopy(column);
          columnTmp.title = field.title + ":" + columnTmp.title;
          physicalNames.push(columnTmp);
        });
      });

      physicalNames = physicalNames.map(obj => {
        return {
          ...obj,
          cellOptions: { wrap: true, format: "@" },
        };
      });
      return physicalNames;
    },
    createCard(e) {
      e.preventDefault();
      const row = this.$refs.grid.kendoWidget();
      const dataItem = row.dataItem(e.currentTarget.closest("tr"));
      const patId = dataItem.pat_id;
      if (this.getSocketIsConnected) {
        this.startLoadingScreen("処理中・・・");
        this.sendSocketMessage(`WRITE_PAT_CARD-${this.facilityCd}-${patId}`);
      } else {
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "保存失敗",
          // message: "カードの書き込みに失敗しました。"
          title: DIALOG_MESSAGES["00200103"].title,
          message: messageFormat(DIALOG_MESSAGES['00200103'].message)
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        });
      }
    },
    reconnectSocket() {
      const param = this;
      this.socketInterval = setInterval(function(){
        param.connect();
        clearInterval(this.socketInterval);
      }, 10000);
    },
    async initializeDataSource(patRecords) {
      this.startLoadingScreen();
      this.sameList = [];
      this.inOutList = [];
      let [mapPatInfoData, sameList, inOutList] = mapPatInfoToKendoDataSource(patRecords, this.mstList, this.isInOutList, this.isSameList, this.unSavedInfo);
      const hasPatMemoInfoLayout = this.getSelectedLayout.some(layout => layout.category === "pat_memo_info");
      if (hasPatMemoInfoLayout) {
        await sendRequestFindRecordListByFacilityCd('mst_pat_memo', this.facilityCd).then(response => {
          const mstPatMemoInfo = response.data.localDataSource.data;
          const displayMap = mstPatMemoInfo.reduce((acc, m) => {
            acc[m.code] = m.isDisp == '0';
            return acc;
          }, {});

          mapPatInfoData.forEach(o => {
            Object.keys(displayMap).forEach(code => {
              if (displayMap[code]) {
                const index = code - 1;
                o[`pat_main$pat_memo_info$content$${index}`] = "";
                o[`pat_main$pat_memo_info$title$${index}`] = "";
              }
            });
          });
        });
      }
      const patIds = [];
      patRecords.forEach(item => {
        let mapPatInfoDataTmp = mapPatInfoData.find(info => info.pat_id === item.pat_personal_main.pat_id);
        let in_hospital_state = "";
        switch (item.pat_main.in_out_current_state + "") {
          case "0":
            in_hospital_state = "在院";
            break;
          case "1":
            in_hospital_state = "導入予定";
            break;
          case "2":
            in_hospital_state = "転入予定";
            break;
          case "3":
            in_hospital_state = "転出";
            break;
          case "7":
            in_hospital_state = "離脱";
            break;
          case "8":
            in_hospital_state = "移植";
            break;
          case "9":
            in_hospital_state = "一時転出";
            break;
          case "10":
            in_hospital_state = "不明";
            break;
          case "11":
            in_hospital_state = "死亡";
            break;
          default:
            in_hospital_state = "不明";
            break;
        }
        mapPatInfoDataTmp["pat_personal_main$in_hospital_state"] = in_hospital_state;
        patIds.push(item.pat_personal_main.pat_id);
      });
      let weightByPatId = {};
      await ApiHelper.get(`/weight/getWeightByPatIds/${this.facilityCd}/${patIds.join(',')}`).then((res) => {
        if (res.status === 200) {
          weightByPatId = res.data;
        }
      }).catch(() => {
        getErrorMessage('MultiPatList.vue', 'initializeDataSource', '');
        throw new Error("カードアプリポート管理から、ポートを取得しません。");
      }).finally(() => {
        this.finishLoadingScreen();
      });
      this.sameList = sameList;
      this.inOutList = inOutList;
      this.refreshKendoColumn();
      if (patRecords.length) {
        this.kendoDataSource = {
          data: mapPatInfoData,
          schema: {
            model: {
              id: "pat_id",
              fields: {}
            }
          },
          sort: this.currentSort ? this.currentSort : null // データリスト側のソート状態を保持
        };
        this.$nextTick(() => {
          let div = document.getElementById("kendo");
          let clientHeight2 = div.clientHeight - div.children[0].clientHeight;
          let clientHeight1 = clientHeight2 - 17;
          if (div.children[1]) {
            div.children[1].style.height = clientHeight1 + "px";
          }
          if (div.children[2]) {
            div.children[2].style.height = clientHeight2 + "px";
          }
          // add start 馬 #10626、10710、10185
          const dataSource = this.$refs.grid?.kendoWidget().dataSource;
          const originalData = cloneDeep(dataSource.data());
          // ヘッダ列 検査タイミング、指示者 ドロップダウンリストを初期化
          this.initializeDropDown(originalData);
          $$("#target-weight-check-all").change((e) => {
            this.handleCheckAllChange(e, this.$refs.grid?.kendoWidget().dataSource?.data());
          });
          // ヘッダ列 検査日、検査時刻に共通日付/時刻IFを追加
          this.initializeDateTimeInput(originalData);
          this.setSameName();
          // add end 馬 #10626、10710、10185
        });
        // 一覧セル デフォルト値 設定
        let date = new Date();
        let strdateymd = moment(date).format("YYYY/MM/DD");
        let dateymd = new Date(strdateymd);
        this.kendoDataSource.data.forEach((gridPat) => {
          gridPat["pat_unique$physical_info$exam_date"] = strdateymd;
          gridPat["pat_unique$physical_info$exam_date_DateObject"] = dateymd;
          gridPat["pat_unique$physical_info$indicator_start_date"] = null;
          // gridPat["pat_unique$physical_info$indicator_start_date_DateObject"] = null;
          gridPat["pat_unique$physical_info$order_class"] = 2; // 身体情報(追加登録).検査タイミング「2：透析後」
          gridPat["pat_unique$physical_info$order_class_MstName"] = "透析後";
          // setTrWeight()の形式に合わせる
          const weight = weightByPatId[gridPat.pat_id + ''];
          gridPat["pat_unique$physical_info$ctr_weight"] = weight != null ? Number(weight).toFixed(2) : null;
          gridPat["pat_unique$physical_info$indicator_cd"] = null;
          gridPat["pat_unique$physical_info$indicator_cd_MstName"] = null;
        });
      } else {
        this.kendoDataSource = null;
      }
      this.kendoDataSourceClone = cloneDeep(this.kendoDataSource);
      this.initialPatRecords = deepCopy(patRecords);
      this.initializeUpdateRecords();
      this.bindShowPopoverEvent();
      this.$nextTick(() => {
        const sortGrid = $$("#kendo").data("kendoGrid");
        if (sortGrid != null) {
          sortGrid.bind("sort", () => {
            // ソートイベント発生時にも bindShowPopoverEvent を再度実行
            // ソートで行の並びが変わると、対象位置も変わるので再バインドが必要
            this.bindShowPopoverEvent();
            this.$nextTick(() => {
              this.setSameName();
              this.findPatInDialysis();
              this.setGridHeight();
            })
          });
        }
      });
      // 保存ボタンをクリックした後、ページを更新し、保存ボタンをアクティブにします。 林峻峰 start
      this.editedPatIdFieldList = {};
      // 保存ボタンをクリックした後、ページを更新し、保存ボタンをアクティブにします。 林峻峰 end
    },

    /**
     * 指定された項目の汚れたフィールドの状態を更新するメソッド
     * @param {*} item 項目
     * @param {*} fieldNames フィールド名のリスト
     * @param {*} isDirty 汚れた状態かどうか
     */
    updateDirtyFields(item, fieldNames, isDirty) {
      // フィールドリストを更新する
      const updateFieldList = (fields) => {
        // 現在の項目のIDに対応する編集済みフィールドリストが存在するかどうかをチェック
        if (this.editedPatIdFieldList[item.pat_id]) {
          // 現在のフィールドリストを取得
          const currentFields = this.editedPatIdFieldList[item.pat_id];
          // 汚れたフィールドの状態に応じて、現在のフィールドリストにフィールドを追加または削除
          this.$set(this.editedPatIdFieldList, item.pat_id, isDirty? currentFields.concat(fields) : currentFields.filter(f =>!fields.includes(f)));
        } else if (isDirty) {
          // 編集済みフィールドリストが存在しない場合は、新しいフィールドリストを作成
          this.$set(this.editedPatIdFieldList, item.pat_id, fields);
        }
        // 編集済みフィールドリストが空の場合は、オブジェクトからそのキーを削除
        if (this.editedPatIdFieldList[item.pat_id] && this.editedPatIdFieldList[item.pat_id].length === 0) {
          this.$delete(this.editedPatIdFieldList, item.pat_id);
        }
      };

      // 各フィールド名に対して
      fieldNames.forEach(fieldName => {
        // 汚れたフィールドの状態に応じて、項目の汚れたフィールドオブジェクト内の状態と、実際のデータ項目内の状態を更新
        if (isDirty) {
          // フィールドを汚す
          item.dirtyFields[fieldName] = true;
        } else {
          // フィールドの汚れを除去
          delete item.dirtyFields[fieldName];
        }
      });

      // 項目の汚れた状態全体を更新
      item.dirty = Object.keys(item.dirtyFields).length > 0;

      // フィールドリストを更新
      updateFieldList(fieldNames);
    },

    /**
     * ヘッダ列 検査タイミング、指示者 ドロップダウンリストを初期化
     * @param {*} originalData 元データ配列
     */
    initializeDropDown(originalData) {
      const grid = this.$refs.grid.kendoWidget();
      const dataSource = grid.dataSource;

      // 共通のドロップダウンリスト作成関数
      const createDropDownList = (element, options) => {
        element.kendoDropDownList({
          dataTextField: options.dataTextField,
          dataValueField: options.dataValueField,
          dataSource: options.dataSource,
          filter: "contains",
          valuePrimitive: true,
          value: options.value || null, // デフォルト値を設定
          select: (e) => {
            const data = dataSource?.data();
            data.forEach((item, index) => {
              // 編集されたかを判定
              const isDirty = options.isDirty(item, index, e.dataItem);
              // 更新処理
              options.updateFields(item, e.dataItem);
              // 編集状態を更新
              this.updateDirtyFields(item, options.fieldsToUpdate, isDirty);
              // 検査タイミングドロップダウンの場合、kendogridのsaveイベントを手動で発火
              if (options.triggerSave) {
                this.triggerSave(item, options.fieldsToUpdate[0], item[options.fieldsToUpdate[0]]);
              }
            });
            // データソースを更新
            dataSource.data(data);
            this.$nextTick(() => {
              this.bindShowPopoverEvent();
              this.setSameName();
              this.findPatInDialysis();
              this.setGridHeight();
            });
          },
        });
      };

      // 検査タイミング ドロップダウンリスト設定
      createDropDownList(
        grid.element.find("#header-order-classname"),
        {
          dataTextField: "name",
          dataValueField: "code",
          dataSource: PSEUDO_MST_LIST.orderClass,
          fieldsToUpdate: ["pat_unique$physical_info$order_class", "pat_unique$physical_info$order_class_MstName"],
          isDirty: (_, index, dataItem) => dataItem.code !== originalData[index].pat_unique$physical_info$order_class,
          updateFields: (item, dataItem) => {
            item.pat_unique$physical_info$order_class = dataItem.code;
            item.pat_unique$physical_info$order_class_MstName = dataItem.name;
          },
          triggerSave: true, // saveイベントを発火するよう指定
          value: 2 // デフォルト値：身体情報(追加登録).検査タイミング「2：透析後」
        }
      );

      // 指示者 ドロップダウンリスト設定
      createDropDownList(
        grid.element.find("#user-category"),
        {
          dataTextField: "userName",
          dataValueField: "userId",
          dataSource: [{ userName: "未登録", userId: null }, ...this.getDoctorList],
          fieldsToUpdate: ["pat_unique$physical_info$indicator_cd", "pat_unique$physical_info$indicator_cd_MstName"],
          isDirty: (item, index, dataItem) =>
            item.pat_unique$physical_info$target_weight_chkbox &&
            item.pat_unique$physical_info$target_weight &&
            dataItem.userId !== originalData[index].pat_unique$physical_info$indicator_cd,
          updateFields: (item, dataItem) => {
            if (item.pat_unique$physical_info$target_weight_chkbox && item.pat_unique$physical_info$target_weight) {
              item.pat_unique$physical_info$indicator_cd = dataItem.userId;
              item.pat_unique$physical_info$indicator_cd_MstName = dataItem.userName;
            }
          },
          triggerSave: false,
        }
      );
    },

    /**
     * ヘッダ列 検査日、検査時刻に共通日付/時刻IFを追加
     * @param {*} originalData 元データ配列
     */
    initializeDateTimeInput(originalData) {

      // 共通日付IF/時刻IF 作成関数
      const createInputWrapper = (inputType, originalData, handleDateTimeInput, targetId, field) => {
        const InputWrapper = Vue.extend({
          template: `
            <component
              :is="dynamicComponent"
              :id="'header-exam-' + inputType"
              :classes="'custom-header'"
              v-model="inputValue"
              style="margin-left: 5px;"
              @handleClearInput="handleClearInput"
              @blur="handleBlur"
            />`,
          props: {
            originalData: Object,
            handleDateTimeInput: Function
          },
          data() {
            return {
              inputValue: "",
              inputType // createInputWrapperで受取る引数をそのまま設定
            };
          },
          computed: {
            dynamicComponent() {
              // コンポーネントを切り替える
              return this.inputType === "date" ? "date-input" : "time-input";
            },
          },
          components: {
            "date-input": DateInput,
            "time-input": TimeInput,
          },
          methods: {
            handleBlur(event) {
              const value = event.target.value;
              this.inputValue = value;
              const formattedValue = inputType === "date" && value
                ? moment(value).format("YYYY/MM/DD")
                : value;
              this.handleDateTimeInput(this.originalData, field, formattedValue);
              this.$emit("input-changed", value, this.inputType); // カレンダーに値変更イベントを通知
            },
            handleClearInput() {
              this.inputValue = null;
              this.$emit("input-changed", null, this.inputType);
            },
            updateInputValue(newValue) {
              this.inputValue = newValue;
            }
          },
        });
        const wrapperInstance = new InputWrapper({
          propsData: { originalData, handleDateTimeInput }
        });
        wrapperInstance.$mount(targetId);
        return wrapperInstance;
      };

      // 検査日 共通日付IFのwrapper作成
      const dateInputWrapperInstance = createInputWrapper(
        "date",
        originalData,
        this.handleDateTimeInput.bind(this),
        "#header-exam-date-wrapper",
        "pat_unique$physical_info$exam_date"
      );

      // 検査日 共通カレンダーIFのwrapper作成
      const commonCalenderPicker = new (Vue.extend(commonCalender))();
      commonCalenderPicker.$on("input", value => {
        // カレンダーで日付を選択した場合、日付入力フィールドに反映
        dateInputWrapperInstance.updateInputValue(value);
        this.handleDateTimeInput(originalData, "pat_unique$physical_info$exam_date", dateFormat.normalDate(value));
      });
      dateInputWrapperInstance.$on("input-changed", (value, inputType) => {
        // 共通日付IFの変更を監視しカレンダーに反映
        if (inputType === "date") {
          const dateValue = !value ? dateFormat.format(new Date(), DATE_FORMAT) : value;
          commonCalenderPicker.setSilently(dateValue);
        }
      });
      commonCalenderPicker.$mount("#header-exam-calendar-wrapper");

      // 検査時刻 共通時刻IFのwrapper作成
      createInputWrapper(
        "time",
        originalData,
        this.handleDateTimeInput.bind(this),
        "#header-exam-time-wrapper",
        "pat_unique$physical_info$exam_time"
      );

      // 検査日、検査時刻 ヘッダにイベントリスナー追加
      this.addEventListenersToHeaders();
    },

    /**
     * ヘッダ列 共通日付/時刻IF フォーカスアウト時の処理
     * @param {*} originalData 元データ配列
     * @param {String} field 更新項目
     * @param {String} value ヘッダ列の入力値
     */
    handleDateTimeInput(originalData, field, value) {
      // 入力値が空の場合は処理しない
      if (!value) return;

      const grid = this.$refs.grid.kendoWidget();
      // 一覧表示している配下セルにvalueを反映する
      const data = grid.dataSource.data();
      data.forEach((item, index) => {
        // 編集されたかを判定
        const newValue = value || null;
        const isDirty = newValue != originalData[index][field];
        // セルの値を更新
        item[field] = newValue;
        if (field === "pat_unique$physical_info$exam_date") {
          item["pat_unique$physical_info$exam_date_DateObject"] = newValue;
        }
        // 編集状態を更新
        const fieldsToUpdate = [field];
        this.updateDirtyFields(item, fieldsToUpdate, isDirty);
        // kendogridのsaveイベントを手動で発火
        this.triggerSave(item, fieldsToUpdate[0], item[fieldsToUpdate[0]]);
      });
      // データソースを更新
      grid.dataSource.data(data);
      this.$nextTick(() => {
        this.bindShowPopoverEvent();
        this.setSameName();
        this.findPatInDialysis();
        this.setGridHeight();
      });
    },

    /**
     * ヘッダ列にイベントリスナー追加
     */
    addEventListenersToHeaders() {
      const toggleHeaderClassClick = (event) => {
        this.toggleHeaderClass(true, event.target.id);
        event.target.focus();
      };
      const toggleHeaderClassBlur = (event) => {
        this.toggleHeaderClass(false, event.target.id);
      };
      const headerFields = document.querySelectorAll(".custom-header");
      headerFields.forEach(headerField => {
        headerField.removeEventListener("click", toggleHeaderClassClick);
        headerField.removeEventListener("blur", toggleHeaderClassBlur);
        headerField.addEventListener("click", toggleHeaderClassClick);
        headerField.addEventListener("blur", toggleHeaderClassBlur);
      });
    },

    /**
     * ヘッダ列 class制御
     * - kendogridで列移動可能ONのためclickでフォーカスできないため一時的にフォーカスの妨げになっているk-headerを除去して元に戻す
     * @param {Boolean} isDummy ダミークラス使用フラグ
     * @param {String} id 入力フィールドのid
     */
    toggleHeaderClass(isDummy, id) {
      const fields = {
        "header-exam-date": "pat_unique$physical_info$exam_date",
        "header-exam-time": "pat_unique$physical_info$exam_time"
      };
      const field = fields[id];

      const headerField = document.querySelector(`[data-field="${field}"]`);
      if (isDummy) {
        headerField.classList.add("k-header-dummy");
        headerField.classList.remove("k-header");
      } else {
        headerField.classList.remove("k-header-dummy");
        headerField.classList.add("k-header");
      }
    },

    /**
     * gridの特定セルを保存対象としてsaveイベントを発火するメソッド
     * @param {Object} model - 保存対象のデータモデル
     * @param {String} field - 保存対象のフィールド名 (data-field に対応)
     * @param {Any} value - 保存する値
     */
    triggerSave(model, field, value) {
      const grid = this.$refs.grid.kendoWidget();
      const container = grid.table.find(`tr[data-uid="${model.uid}"] td[data-field="${field}"]`);
      // saveイベントを発火
      grid.trigger("save", {
        container, // 保存対象のセル
        model, // 保存対象のモデル
        values: { [field]: value }, // 保存する値
      });
    },

    /**
     * すべてチェックボックスの状態変化を処理するイベントハンドラ
     * @param {Event} e イベントオブジェクト
     * @param {Array} data データ配列
     */
    handleCheckAllChange(e, data) {
      const dataSource = this.$refs.grid.kendoWidget().dataSource;

      // データ配列内の各項目について
      data.forEach((item) => {
        const isChecked = e.target.checked;

        if (item.pat_unique$physical_info$target_weight_chkbox!== isChecked) {
          // チェック状態を更新
          item["pat_unique$physical_info$target_weight_chkbox"] = isChecked;
          // チェックされている場合は「DWと同じ」、チェックされていない場合はnullにする
          item["pat_unique$physical_info$target_weight"] = isChecked ? "DWと同じ" : null;
          item["pat_unique$physical_info$indicator_start_date"] = isChecked ? moment().format("YYYY/MM/DD") : null;
          // item["pat_unique$physical_info$pat_unique$physical_info$indicator_start_date_DateObject"] = isChecked ? new Date() : null;
          item["pat_unique$physical_info$indicator_cd"] = isChecked ? this.getDoctorId : null;
          item["pat_unique$physical_info$indicator_cd_MstName"] = isChecked ? this.getDoctorName : null;
          // 更新するフィールドのリスト
          const fieldsToUpdate = ["pat_unique$physical_info$target_weight_chkbox", "pat_unique$physical_info$target_weight", "pat_unique$physical_info$indicator_start_date", "pat_unique$physical_info$indicator_start_date_DateObject", "pat_unique$physical_info$indicator_cd", "pat_unique$physical_info$indicator_cd_MstName"];
          // 汚れた状態を更新
          this.updateDirtyFields(item, fieldsToUpdate, isChecked);
        }
      });

      // データソースのデータ更新
      dataSource.data(data);
      this.$nextTick(() => {
        this.setSameName();
        this.findPatInDialysis();
      });
    },


    async setTrWeight(exam_date, exam_time, order_class, patId) {
      let trWeight = null;
      if (exam_date === null || order_class === null || patId === null) {
        return trWeight;
      }
      const treatDate = moment(exam_date).format("YYYYMMDD");
      const treatTime = exam_time ? moment(exam_time, "HH:mm").format("HHmm") : null;
      await getWeightByTreatDateAndOrdClass({
        facilityCd: this.facilityCd,
        patId,
        ordClass: order_class,
        treatDate,
        treatTime
      }).then((res) => {
        if (res.status === 200) {
          trWeight = res.data ? res.data?.toFixed(2) : null;
        }
      });
      return trWeight;
    },

    /**
     * 治療方法マスタ取得
     * 取得した治療方法マスタはmstTreatmentに格納する.
     */
    async getMstTreatment() {
      const response = await sendRequestGetMstTreatment();
      this.mstTreatment = response.data;
    },

    initializeUpdateRecords() {
      this.patRecordsForUpdating = cloneDeep(this.initialPatRecords);
      let date = new Date();
      let strdateymd = moment(date).format("YYYY-MM-DD");
      if (this.initialPatRecords) {
        this.patRecordsForUpdating.forEach((gridPat) => {
          let jsonArray = gridPat["pat_unique"]["physical_info"];
          let index = gridPat["pat_unique"]["physical_info"].length;
          // コントロール番号設定
          const addJson = { ...JSON_ARRAY_ITEM["physical_info"] };
          const maxCtlNo = _.max(jsonArray, json => json.ctl_no).ctl_no;
          addJson.ctl_no = maxCtlNo >= 0 ? maxCtlNo + 1 : 0;

          // 特定のjsonKey初期値設定
          if (this.settingColumnsFuc["physical_info"]) {
            const setjsonKey = this.getSettingjsonKey("physical_info", "exam_date");
            if (setjsonKey) {
              this.settingColumnsFuc["physical_info"](addJson, setjsonKey);
            }
          }
          jsonArray.push(addJson);
          jsonArray[index]["order_class"] = 2; // 身体情報(追加登録).検査タイミング「2：透析後」
          jsonArray[index]["exam_date"] = strdateymd;
          jsonArray[index]["ctr_weight"] = null;
          if(this.unSavedInfo.length > 0){
            let patInfo = this.unSavedInfo.find(o => o.patId === gridPat.pat_unique.pat_id);
            if(patInfo){
              let physicalInfo =  jsonArray.find(o => o.ctl_no === patInfo.data.ctl_no);
              physicalInfo.dw = patInfo.data.dw;
            }
          }
          if(gridPat.ord_mains.length === 0){
            if(this.editedPatIdFieldList[gridPat.pat_personal_main.pat_id]){
              Reflect.deleteProperty(this.editedPatIdFieldList, gridPat.pat_personal_main.pat_id);
            }
          }
        });
      }
    },

    refreshKendoColumn() {
      // kendo gridの表示に必要なプロパティをレイアウト情報にマップしていく
      this.kendoDataSource = null;
      this.kendoGridColumns.forEach((category, categoryIndex) => {
        category.columns = category.columns.map((column, columnIndex) => {
          const categoryKey = this.getSelectedLayout[categoryIndex].category;
          const itemKey = this.getSelectedLayout[categoryIndex].items[columnIndex];
          if (isIndUserColumn(itemKey)) {
            // 指示者項目の場合は指示者共通IFを使用
            return mapKendoDisplayPropertyIndUser(
                column,
                categoryKey,
                itemKey,
                /* upd EOL対応内部 #6921 by ztc 2023-07-08 --start */
                this.getDoctorList
                // this.doctorList
                /* upd EOL対応内部 #6921 by ztc 2023-07-08 --end */
            );
          } else {
            return mapKendoDisplayProperty(
                column,
                categoryKey,
                itemKey,
                this.mstList,
                EventBus
            );
          }
        });
      });
      this.bindShowPopoverEvent();

      this.$nextTick(() => {
        // this.findRequiredCell();
        // add #6256 背景色が変わらない 徐博 start
        this.findPatInDialysis();
        // add #6256 背景色が変わらない 徐博 end
      });
    },

    async changeDisplayPat() {
      this.startLoadingScreen();
      this.mstList = await getRequiredMst(this.facilityCd).catch(error => {
        getErrorMessage('MultiPatList.vue', 'changeDisplayPat', error);
        throw new Error(error);
      }).finally(() => {
        this.finishLoadingScreen();
      });
      this.initializeDataSource(this.patRecords);
    },

    async editCell(e) {
      // 編集field取得
      const editedField = Object.keys(e.values)[0];
      if (isNoUpdateField(editedField)) {
        return;
      }
      // 編集値取得
      let editedValue = e.values[editedField];
      if (editedValue === "") {
        editedValue = null;
      }
      /* 対象患者の更新用レコードに編集値を反映 */
      const editedPatId = e.model.pat_id;
      const targetPatIndex = this.kendoDataSource.data.findIndex(
        el => el.pat_id === editedPatId
      );
      // field 'table$column($jsonKey($jsonArrayIndex))'から更新カラムを特定
      let [table, column, jsonKey, jsonArrayIndex] = editedField.split("$");
      // JSON配列カラム系の情報を変更
      if (this.changeInfo[column]) {
        [table, column, jsonKey, jsonArrayIndex, editedValue] = this.changeInfo[
          column
        ](
          targetPatIndex,
          table,
          column,
          jsonArrayIndex,
          jsonKey,
          editedField,
          editedValue
        );
        // 数字0の時、下記単一カラム(!jsonKey)をスルーさせるため
        jsonArrayIndex = String(jsonArrayIndex);
      }
      if (editedField === "pat_unique$physical_info$dw") {
        this.$nextTick(() => {
          this.patRecordsForUpdating[targetPatIndex][table][column][jsonArrayIndex]["indicator_cd"] = editedValue ? this.getDoctorId : null;
          e.model.set("pat_unique$physical_info$indicator_cd", editedValue ? (e.model["pat_unique$physical_info$indicator_cd"] || this.getDoctorId) : null);
          e.model.set("pat_unique$physical_info$indicator_cd_MstName", editedValue ? (e.model["pat_unique$physical_info$indicator_cd_MstName"] || this.getDoctorName) : null);
          if (editedValue) {
            e.model.dirtyFields["pat_unique$physical_info$indicator_cd"] = true;
          } else {
            delete e.model.dirtyFields["pat_unique$physical_info$dw"];
            delete e.model.dirtyFields["pat_unique$physical_info$indicator_cd"];
          }
        });
      }
      if (editedField === "pat_unique$physical_info$target_weight_chkbox") {
        this.$nextTick(() => {
          this.patRecordsForUpdating[targetPatIndex][table][column][jsonArrayIndex]["indicator_cd"] = editedValue ? this.getDoctorId : null;
          this.patRecordsForUpdating[targetPatIndex][table][column][jsonArrayIndex]["indicator_start_date"] = editedValue ? moment().format("YYYY/MM/DD") : null;
          e.model.set("pat_unique$physical_info$indicator_start_date", editedValue ? moment().format("YYYY/MM/DD") : null);
          // e.model.set("pat_unique$physical_info$indicator_start_date_DateObject", editedValue ? new Date() : null);
          e.model.set("pat_unique$physical_info$indicator_cd", editedValue ? this.getDoctorId : null);
          e.model.set("pat_unique$physical_info$indicator_cd_MstName", editedValue ? this.getDoctorName : null);
          if (editedValue) {
            e.model.dirtyFields["pat_unique$physical_info$indicator_start_date"] = true;
            e.model.dirtyFields["pat_unique$physical_info$indicator_cd"] = true;
          } else {
            delete e.model.dirtyFields["pat_unique$physical_info$indicator_start_date"];
            delete e.model.dirtyFields["pat_unique$physical_info$indicator_cd"];
            delete e.model.dirtyFields["pat_unique$physical_info$indicator_cd_MstName"];
            // delete e.model.dirtyFields["pat_unique$physical_info$indicator_start_date_DateObject"];
            delete e.model.dirtyFields["pat_unique$physical_info$target_weight_chkbox"];
            delete e.model.dirtyFields["pat_unique$physical_info$target_weight"];
          }
        });
        return;
      }
      // 更新用に値を変換
      let convertedValue = editedValue;
      if (editedValue !== null) {
        convertedValue = convertToUpdateValue(
          table,
          column,
          jsonKey,
          editedValue
        );
      }
      if (!jsonKey) {
        // 単一カラム
        this.patRecordsForUpdating[targetPatIndex][table][
          column
        ] = convertedValue;
      } else if (!jsonArrayIndex) {
        // 単一JSONカラム
        this.patRecordsForUpdating[targetPatIndex][table][column][
          jsonKey
        ] = convertedValue;
      } else {
        // JSON配列カラム
        const jsonArray = this.patRecordsForUpdating[targetPatIndex][table][
          column
        ];
        if (!jsonArray[jsonArrayIndex]) {
          // 要素なし
          while (!jsonArray[jsonArrayIndex]) {
            // 指定の要素数になるまで項目追加
            // コントロール番号設定
            const addJson = { ...JSON_ARRAY_ITEM[column] };
            const maxCtlNo = _.max(jsonArray, json => json.ctl_no).ctl_no;
            addJson.ctl_no = maxCtlNo >= 0 ? maxCtlNo + 1 : 0;

            // 特定のjsonKey初期値設定
            if (this.settingColumnsFuc[column]) {
              const setjsonKey = this.getSettingjsonKey(column, editedField);
              if (setjsonKey) {
                this.settingColumnsFuc[column](addJson, setjsonKey);
              }
            }
            if (column === "medical_hst_info") {
              if (jsonKey === "is_diagnosed" || jsonKey === "cause_death") {
                addJson.out_come = "10";
                addJson.is_dialysis_underlying_disease = "";
              }
              if (jsonKey === "disease_cd" || jsonKey === "is_confirmation_biopsy" || jsonKey === "disease_date") {
                addJson.out_come = "";
                addJson.is_dialysis_underlying_disease = "1";
              }
            }
            jsonArray.push(addJson);
          }
        }
        this.patRecordsForUpdating[targetPatIndex][table][column][
          jsonArrayIndex
        ][jsonKey] = convertedValue;
      }

      // 変更セル特定情報
      let columnList = ["患者ID", "患者名"];
      this.kendoGridColumns.forEach(item => {
        const fields = item.columns.map(column => column.field);
        columnList = [...columnList, ...fields];
      });
      const grid = $$("#kendo").data("kendoGrid");
      const dataItem = grid.dataSource.at(targetPatIndex);
      const rowCells = grid.element.find(`tr[data-uid=${dataItem.uid}] td`);

      /* 編集色設定 */
      // kendo data sourceから初期値を取得
      const initialValue = this.kendoDataSourceClone.data[targetPatIndex][
        editedField
      ];
      const encodeInitialValue =
        initialValue === undefined ? null : initialValue;
      const editedElement = e.container[0];
      // 編集されたかどうか初期値と比較 ※更新用変換値ではなく編集直後の値を比較
      if (editedValue !== encodeInitialValue) {
        if (editedField === "pat_unique$physical_info$ctr" ||
          editedField === "pat_unique$physical_info$target_weight"||
          editedField === "pat_unique$physical_info$exam_date"||
          editedField === "pat_unique$physical_info$exam_time"||
          editedField === "pat_unique$physical_info$order_class"||
          editedField === "pat_unique$physical_info$breast_dia"||
          editedField === "pat_unique$physical_info$chest_dia"||
          editedField === "pat_unique$physical_info$dw"||
          editedField === "pat_unique$physical_info$memo"||
          editedField === "pat_unique$physical_info$height"||
          editedField === "pat_unique$physical_info$ctr_weight" ||
          editedField === "pat_unique$physical_info$indicator_start_date" ||
          editedField === "pat_unique$physical_info$indicator_cd") {
          let cellIndex = columnList.indexOf(editedField);
          if (cellIndex === -1) {
            cellIndex = columnList.indexOf(editedField + LAYOUT_ITEM_KEY_SUFFIX_MSTNAME);
          }
          if (cellIndex === -1) {
            cellIndex = columnList.indexOf(editedField + LAYOUT_ITEM_KEY_SUFFIX_DATEOBJECT);
          }
          const cell = $$(rowCells[cellIndex]);
          cell[0]?.classList?.add(CLASS_EDITED_CELL);
        } else {
          editedElement?.classList?.add(CLASS_EDITED_CELL);
        }
        // 患者ID・カラム名を更新対象として保持
        if (!this.editedPatIdFieldList[editedPatId]) {
          this.$set(this.editedPatIdFieldList, editedPatId, []);
        }
        if(!this.editedPatIdFieldList[editedPatId].includes(editedField)){
          this.editedPatIdFieldList[editedPatId].push(editedField);
        }
      } else {
        delete e.model.dirtyFields[Object.keys(e.values)[0]];
        if (editedField === "pat_unique$physical_info$ctr" ||
          editedField === "pat_unique$physical_info$target_weight"||
          editedField === "pat_unique$physical_info$exam_date"||
          editedField === "pat_unique$physical_info$exam_time"||
          editedField === "pat_unique$physical_info$order_class"||
          editedField === "pat_unique$physical_info$breast_dia"||
          editedField === "pat_unique$physical_info$chest_dia"||
          editedField === "pat_unique$physical_info$dw"||
          editedField === "pat_unique$physical_info$memo"||
          editedField === "pat_unique$physical_info$height"||
          editedField === "pat_unique$physical_info$ctr_weight" ||
          editedField === "pat_unique$physical_info$indicator_start_date" ||
          editedField === "pat_unique$physical_info$indicator_cd") {
          let cellIndex = columnList.indexOf(editedField);
          if (cellIndex === -1) {
            cellIndex = columnList.indexOf(editedField + LAYOUT_ITEM_KEY_SUFFIX_MSTNAME);
          }
          if (cellIndex === -1) {
            cellIndex = columnList.indexOf(editedField + LAYOUT_ITEM_KEY_SUFFIX_DATEOBJECT);
          }
          const cell = $$(rowCells[cellIndex]);
          this.$nextTick(() => {
            cell[0].classList.remove(CLASS_EDITED_CELL);
            cell[0].classList.remove("k-dirty-cell");
          });
        } else {
          editedElement.classList.remove(CLASS_EDITED_CELL);
          editedElement.classList.remove("k-dirty-cell");
        }
        if (this.editedPatIdFieldList[editedPatId]) {
          // カラム名を更新対象から除外
          this.$set(
            this.editedPatIdFieldList,
            editedPatId,
            this.editedPatIdFieldList[editedPatId].filter(
              columnString => columnString !== editedField
            )
          );
          if (!this.editedPatIdFieldList[editedPatId].length) {
            this.$delete(this.editedPatIdFieldList, editedPatId);
          }
        }
      }
      /* 必須色設定 */
      const keys = Object.keys(this.validateObject);
      if (keys.includes(editedField)) {
        if (editedValue && editedValue !== "") {
          editedElement.classList.remove(CLASS_REQUIRED_CELL);
          const patIndex = this.validateObject[editedField].findIndex(
            item => item === editedPatId
          );
          this.validateObject[editedField].splice(patIndex, 1);
        } else if (!editedValue || editedValue === "") {
          editedElement?.classList?.add(CLASS_REQUIRED_CELL);
          this.validateObject[editedField].push(editedPatId);
        }
      }

      // 各カラム関数処理(メッセージ表示等)
      // 重複警告
      if (column === "charge_staff_info") {
        const recordList = this.patRecordsForUpdating[targetPatIndex][table][
          column
        ];
        this.isSomeStaffDialogVisible = this.hasSameRecord(
          recordList,
          editedField,
          convertedValue
        );
      }

      // ctr自動計算&ソート
      if (column === "physical_info") {
        const editPhysicalInfo = this.patRecordsForUpdating[targetPatIndex][
          table
        ][column][jsonArrayIndex];
        const breastDia = editedField.match(/breast_dia/);
        const chestDia = editedField.match(/chest_dia/);
        if (breastDia || chestDia) {
          const ctrValue = this.getCtr(editPhysicalInfo);
          if (ctrValue !== null) {
            editPhysicalInfo.ctr = ctrValue;
            this.$nextTick(() => {
              // nextTick内でgrid値を変更させ、再度editCell関数を呼び出す※セル編集色設定のため
              e.model.set("pat_unique$physical_info$ctr", ctrValue.toFixed(2));
            });
          }
        }
        // 検査日、検査時刻、検査タイミングが変わった際には、検査日時＋検査タイミングで検査時体重が変わる仕様があるのでそれを発火
        const examDate = editedField.match(/exam_date/);
        const orderClass = editedField.match(/order_class/);
        const examTime = editedField.match(/exam_time/);
        if (examDate || orderClass || examTime) {
          const trWeight = await this.setTrWeight(editPhysicalInfo.exam_date, editPhysicalInfo.exam_time,
          editPhysicalInfo.order_class, this.patRecordsForUpdating[targetPatIndex]["pat_personal_main"].pat_id);
          editPhysicalInfo.ctr_weight = trWeight;
          this.$nextTick(() => {
            // nextTick内でgrid値を変更させ、再度editCell関数を呼び出す※セル編集色設定のため
            e.model.set("pat_unique$physical_info$ctr_weight", trWeight);
            // 検査時体重を更新するとgridが更新されて透析中患者行の色が消えるので色を設定する
            this.$nextTick(() => {
              this.findPatInDialysis();
            });
            // ヘッダで検査日、検査タイミングを一括変更したり、検査日セルを変更しても検査時体重のsaveイベントが発火しないため手動で発火する
            this.triggerSave(e.model, "pat_unique$physical_info$ctr_weight", trWeight);
          });
        }
        const physicalInfo = this.patRecordsForUpdating[targetPatIndex][table][
          column
         ];
        this.sortColumnInfo(physicalInfo);
      }
    },
    formatUpdatePhysicalInfoData() {
      const filterAndRenameKeys = (dataItem) => {
        const physicalInfoItem = {
          "dw": null, // dw
          "ctr": null,
          "memo": null,
          "ctl_no": null,
          "height": null,
          "chest_dia": null,
          "exam_date": null,
          "breast_dia": null,
          "changer_cd": null,
          "ctr_weight": null, // 检查时体重
          "facility_cd": null,
          "order_class": null,
          "indicator_cd": null,
          "inspect_date": null,
          "target_weight": null,
          "pre_scale_lower": null,
          "pre_scale_upper": null,
          "indicator_start_date": null
        };
        // add 11101【総合検証NG】データリストの患者情報１にて患者情報を編集/保存すると共通ローダが終わらない 房 start
        const patPersonalMain = {
          "pat_birthday": null,
          "pat_sex": null,
          "pat_blood_type_abo": null,
          "pat_blood_type_rh": null,
          "pat_blood_type_serovar": null,
          "nationality": null,
          "zip_cd": null,
          "address": null,
          "tel1": null,
          "tel2": null,
          "fax": null,
          "e_mail": null,
          "memo1": null,
          "memo2": null,
          "transport_cd": null,
          "severity_cd": null
        };
        // add 11101【総合検証NG】データリストの患者情報１にて患者情報を編集/保存すると共通ローダが終わらない 房 end
        const originalObject = dataItem.toJSON();
        const newObject = {};
        // add 11101【総合検証NG】データリストの患者情報１にて患者情報を編集/保存すると共通ローダが終わらない 房 start
        const patPersonNewObject = {};
        const patMemoInfoObject = {};
        const medicalHstInfoObject = {};
        const patMainInfoObject = {};
        const medicalCareInfoObject = {};
        // add 11101【総合検証NG】データリストの患者情報１にて患者情報を編集/保存すると共通ローダが終わらない 房 end
        Object.keys(originalObject).forEach(key => {
          if (key.includes('pat_unique$physical_info$')) {
            const newKey = key.replace('pat_unique$physical_info$', '');
            newObject[newKey] = originalObject[key];
          }
          // add 11101【総合検証NG】データリストの患者情報１にて患者情報を編集/保存すると共通ローダが終わらない 房 start
          if(key.includes("pat_personal_main$pat_contact_info$")) {
            const newKey = key.replace('pat_personal_main$pat_contact_info$', '');
            patPersonNewObject[newKey] = originalObject[key];
          }
          if(key.includes("pat_personal_main$") && key.split("$").length == 2) {
            const newKey = key.replace('pat_personal_main$', '');
            patPersonNewObject[newKey] = originalObject[key];
          }
          if(key.includes("pat_main$pat_memo_info$")) {
            const newKey = key.replace('pat_main$pat_memo_info$', '');
            patMemoInfoObject[newKey] = originalObject[key];
          }
          if(key.includes("pat_unique$medical_hst_info$")) {
            const newKey = key.replace('pat_unique$medical_hst_info$', '');
            medicalHstInfoObject[newKey] = originalObject[key];
          }
          if(key.includes("pat_main$") && key.split("$").length == 2) {
            const newKey = key.replace('pat_main$', '');
            patMainInfoObject[newKey] = originalObject[key];
          }
          if(key.includes("pat_main$medical_care_info$")) {
            const newKey = key.replace('pat_main$medical_care_info$', '');
            medicalCareInfoObject[newKey] = originalObject[key];
          }
          // add 11101【総合検証NG】データリストの患者情報１にて患者情報を編集/保存すると共通ローダが終わらない 房 end
        });
        Object.keys(newObject).forEach(key => {
          if (Object.keys(physicalInfoItem).includes(key)) {
            physicalInfoItem[key] = newObject[key];
          }
        });
        // add 11101【総合検証NG】データリストの患者情報１にて患者情報を編集/保存すると共通ローダが終わらない 房 start
        Object.keys(patPersonNewObject).forEach(key => {
          if (Object.keys(patPersonalMain).includes(key)) {
            patPersonalMain[key] = patPersonNewObject[key];
          }
        });
        // add 11101【総合検証NG】データリストの患者情報１にて患者情報を編集/保存すると共通ローダが終わらない 房 end
        const exam_date = physicalInfoItem.exam_date + (newObject.exam_time ? ' ' + newObject.exam_time : '');
        physicalInfoItem.changer_cd = this.userId;
        physicalInfoItem.facility_cd = this.facilityCd;
        physicalInfoItem.inspect_date = newObject.exam_date?.replaceAll('/', '');
        physicalInfoItem.indicator_start_date = physicalInfoItem.indicator_start_date ?.replaceAll('/', '');
        physicalInfoItem.exam_date = newObject.exam_time ? moment(exam_date, "YYYY-MM-DD HH:mm").format("YYYY-MM-DDTHH:mm:ss.SSSZ"): exam_date.replaceAll("/", "-");
        physicalInfoItem.exam_time = newObject.exam_time;
        if (newObject.target_weight === "DWと同じ") {
          physicalInfoItem.target_weight = "-1";
        }
        // mod 11101【総合検証NG】データリストの患者情報１にて患者情報を編集/保存すると共通ローダが終わらない 房 start
        return {
          "physicalInfoItem": physicalInfoItem,
          "patPersonalMain": patPersonalMain,
          "patMemoInfo": patMemoInfoObject,
          "medicalHstInfo": medicalHstInfoObject,
          "patMainInfo": patMainInfoObject,
          "medicalCareInfo": medicalCareInfoObject
        };
        // mod 11101【総合検証NG】データリストの患者情報１にて患者情報を編集/保存すると共通ローダが終わらない 房 end
      };

      const dataSources = this.$refs.grid.kendoWidget().dataSource;
      const physicalInfoNewItems = new Map();
      // add 11101【総合検証NG】データリストの患者情報１にて患者情報を編集/保存すると共通ローダが終わらない 房 start
      const patPersonalMain = new Map();
      const patMemoInfo = new Map();
      const medicalHstInfo = new Map();
      const patMainInfo = new Map();
      const medicalCareInfo = new Map();
      // add 11101【総合検証NG】データリストの患者情報１にて患者情報を編集/保存すると共通ローダが終わらない 房 end
      const updateTargetPatIdList = Object.keys(
        this.editedPatIdFieldList
      ).map(keyPatId => Number(keyPatId));
      const updateItems = JSON.parse(JSON.stringify(this.initialPatRecords)).filter(record =>
        updateTargetPatIdList.includes(record.pat_personal_main.pat_id)
      );
      updateTargetPatIdList.forEach(item => {
        const dataItem = dataSources.get(item);
        // mod 11101【総合検証NG】データリストの患者情報１にて患者情報を編集/保存すると共通ローダが終わらない 房 start
        physicalInfoNewItems.set(item, filterAndRenameKeys(dataItem).physicalInfoItem)
        patPersonalMain.set(item, filterAndRenameKeys(dataItem).patPersonalMain);
        patMemoInfo.set(item, filterAndRenameKeys(dataItem).patMemoInfo);
        medicalHstInfo.set(item, filterAndRenameKeys(dataItem).medicalHstInfo);
        patMainInfo.set(item, filterAndRenameKeys(dataItem).patMainInfo);
        medicalCareInfo.set(item, filterAndRenameKeys(dataItem).medicalCareInfo);
        // mod 11101【総合検証NG】データリストの患者情報１にて患者情報を編集/保存すると共通ローダが終わらない 房 end
      });
      updateItems.forEach(item => {
        if(this.kendoGridColumns.some(item => item.key === "severity")) {
          let newPersonalMainInfoItem = patPersonalMain.get(item.pat_personal_main.pat_id);
          item.pat_personal_main.severity_cd = newPersonalMainInfoItem.severity_cd;
        }
        if(this.kendoGridColumns.some(item => item.key === "medical_care_info")) {
          let newMedicalCareInfoItem = medicalCareInfo.get(item.pat_personal_main.pat_id);
          item.pat_main.medical_care_info.main_course_cd = newMedicalCareInfoItem.main_course_cd;
          item.pat_main.medical_care_info.dialysis_course_cd = newMedicalCareInfoItem.dialysis_course_cd;
          item.pat_main.medical_care_info.ward_cd = newMedicalCareInfoItem.ward_cd;
          item.pat_main.medical_care_info.dialysis_count = newMedicalCareInfoItem.dialysis_count;
          item.pat_main.medical_care_info.pat_dialysis_count = newMedicalCareInfoItem.pat_dialysis_count;
          item.pat_main.medical_care_info.purification_count = newMedicalCareInfoItem.purification_count;
          item.pat_main.medical_care_info.dialysis_start_date = newMedicalCareInfoItem.dialysis_start_date ? newMedicalCareInfoItem.dialysis_start_date : null;
          item.pat_main.medical_care_info.dyalysis_hst = newMedicalCareInfoItem.dyalysis_hst;
        }
        if(this.kendoGridColumns.some(item => item.key === "transport")) {
          let newTransportInfoItem = patPersonalMain.get(item.pat_personal_main.pat_id);
          item.pat_personal_main.transport_cd = newTransportInfoItem.transport_cd;
        }
        if(this.kendoGridColumns.some(item => item.key === "medical_hst_info")) {
          let newMedicalHstInfoItem = medicalHstInfo.get(item.pat_personal_main.pat_id);
          if(item.pat_unique.medical_hst_info && item.pat_unique.medical_hst_info.length > 0) {
            let tempPrimaryDisease = item.pat_unique.medical_hst_info.find(record => record.is_dialysis_underlying_disease == "1");
            if(tempPrimaryDisease) {
              tempPrimaryDisease.disease_cd = newMedicalHstInfoItem.disease_cd;
              tempPrimaryDisease.is_confirmation_biopsy = newMedicalHstInfoItem.is_confirmation_biopsy;
              tempPrimaryDisease.disease_date = newMedicalHstInfoItem.disease_date ? newMedicalHstInfoItem.disease_date : null;
            }
            let tempDieRecord = item.pat_unique.medical_hst_info.find(record => record.out_come === "10");
            if(tempDieRecord) {
              tempDieRecord.cause_death = newMedicalHstInfoItem.cause_death;
              tempDieRecord.is_diagnosed = newMedicalHstInfoItem.is_diagnosed;
            }
          }
          let newPatInfoItem = patMainInfo.get(item.pat_personal_main.pat_id);
          item.pat_main.is_blood_suger_exam = newPatInfoItem.is_blood_suger_exam;
          item.pat_main.is_diabetes = newPatInfoItem.is_diabetes;
        }
        if(this.kendoGridColumns.some(item => item.key === "pat_memo_info")) {
          let newPatMemoInfoItem = patMemoInfo.get(item.pat_personal_main.pat_id);
          for(let index = 0; index < 20; index++) {
            if(item.pat_main.pat_memo_info[index]) {
              item.pat_main.pat_memo_info[index].title = newPatMemoInfoItem["title$" + index];
              item.pat_main.pat_memo_info[index].content = newPatMemoInfoItem["content$" + index];
            } else {
              item.pat_main.pat_memo_info[index] = {
                "title": newPatMemoInfoItem["title$" + index],
                "content": newPatMemoInfoItem["content$" + index],
                "ctl_no": index + 1
              }
            }
          }
        }
        if(this.kendoGridColumns.some(item => item.key === "basic_info")) {
          let newBasicInfoItem = patPersonalMain.get(item.pat_personal_main.pat_id);
          if(newBasicInfoItem["pat_birthday"]) {
            item.pat_personal_main.pat_birthday = newBasicInfoItem["pat_birthday"].replaceAll("/", "");
          }
          item.pat_personal_main.pat_sex = newBasicInfoItem["pat_sex"];
          item.pat_personal_main.pat_blood_type_abo = newBasicInfoItem["pat_blood_type_abo"];
          item.pat_personal_main.pat_blood_type_rh = newBasicInfoItem["pat_blood_type_rh"];
          item.pat_personal_main.pat_blood_type_serovar = newBasicInfoItem["pat_blood_type_serovar"];
          item.pat_personal_main.nationality = newBasicInfoItem["nationality"];
          item.pat_personal_main.pat_contact_info.zip_cd = newBasicInfoItem["zip_cd"];
          item.pat_personal_main.pat_contact_info.address = newBasicInfoItem["address"];
          item.pat_personal_main.pat_contact_info.tel1 = newBasicInfoItem["tel1"];
          item.pat_personal_main.pat_contact_info.tel2 = newBasicInfoItem["tel2"];
          item.pat_personal_main.pat_contact_info.fax = newBasicInfoItem["fax"];
          item.pat_personal_main.pat_contact_info.e_mail = newBasicInfoItem["e_mail"];
          item.pat_personal_main.pat_contact_info.memo1 = newBasicInfoItem["memo1"];
          item.pat_personal_main.pat_contact_info.memo2 = newBasicInfoItem["memo2"];
        }
      });
      let isSameExamDateItems = [];
      const addPhysicalInfoFlag = Object.values(this.editedPatIdFieldList)?.some(item => item?.some(key => key.includes("physical_info")));
      if(this.kendoGridColumns.some(item => item.key === "physical_info") && addPhysicalInfoFlag) {
        updateItems.forEach(item => {
          // add #11400 by kangjie 20241213 start
          item.pat_unique.up_date = moment(new Date()).format("YYYY-MM-DD HH:mm:ss");
          // add #11400 by kangjie 20241213 end
          if (!this.editedPatIdFieldList[item.pat_personal_main.pat_id].some(i => i.includes('physical_info'))) {
            return;
          }
          const physicalInfo = item.pat_unique.physical_info;
          let newInfoItem = physicalInfoNewItems.get(item.pat_personal_main.pat_id);
          item.save_physical_item = newInfoItem;
          // item.dw_edit_mod = "I";
          item.dw_log_info = {
            is_delete : false,
            is_change : false,
            examTime_pre : null,
            examTime_aft : newInfoItem.exam_time ? moment(newInfoItem.exam_date).format("YYYY-MM-DD HH:mm:ss.SSS") : newInfoItem.exam_date.replaceAll("/", "-"),
            dw_pre : "未登録",
            dw_aft : newInfoItem.dw || "未登録",
            operation_order : null,
            creater : newInfoItem.indicator_cd || null,
            is_add : 1
          };
          delete newInfoItem.exam_time;
          if (physicalInfo.length === 0) {
            physicalInfo.push(newInfoItem);
            physicalInfo[0].ctl_no = 0;
          } else {
            if (physicalInfo.some(info => info.exam_date === newInfoItem.exam_date) &&
              Object.keys(this.editedPatIdFieldList).length && addPhysicalInfoFlag
            ) {
              isSameExamDateItems.push(item.pat_personal_main.pat_id);
              return;
            }
            const maxCtlNo = _.max(physicalInfo, json => json.ctl_no).ctl_no;
            newInfoItem.ctl_no = maxCtlNo >= 0 ? maxCtlNo + 1 : 0;
            physicalInfo.push(newInfoItem);
            const parseDate = dateStr => new Date(dateStr);
            physicalInfo.sort((a, b) => {
              if (b.exam_date !== a.exam_date) {
                return parseDate(b.exam_date) - parseDate(a.exam_date);
              } else if (b.ctl_no !== a.ctl_no) {
                return b.ctl_no - a.ctl_no;
              }
            });
          }
        });
      }
      return isSameExamDateItems.length ? false : updateItems;
    },
    async updatePatRecords() {
      this.startLoadingScreen("患者情報を更新しています");
      setTimeout(async() => {
        if (!this.isEdited) {
          this.isNoEditDialogVisible = true;
          this.finishLoadingScreen();
          return;
        }
        let updatePatList = this.formatUpdatePhysicalInfoData();
        if (this.kendoGridColumns.some(item => item.key === "physical_info") &&
          Object.keys(this.editedPatIdFieldList).length &&
          Object.values(this.editedPatIdFieldList)?.some(item => item?.some(key => key.includes("physical_info")))
        ) {
          if (!updatePatList) {
            this.$ons.notification.alert({
              title: "検査日時重複エラー",
              message: "既に登録済みの身体情報と検査日時が重複しています。"
            });
            this.finishLoadingScreen();
            return;
          }
          const updatePhysicalInfoIdList = Object.keys(this.editedPatIdFieldList)?.filter((key) => {
            return this.editedPatIdFieldList[key]?.some((item) => {
              return item?.includes("physical_info");
            })
          });
          const dataSources = this.$refs.grid.kendoWidget().dataSource;
          const questionPatId = [];
          const dwQuestionPatId = [];
          let messages = [];
          let DWMessages = [];
          updatePhysicalInfoIdList.forEach((item) => {
            const dataItem = dataSources.get(item);
            const dirtyKeys = Object.keys(dataItem.dirtyFields);
            const requiredKeys = [
              "pat_unique$physical_info$height", // 身長
              "pat_unique$physical_info$dw", // DW
              "pat_unique$physical_info$chest_dia", // 胸郭横径
              "pat_unique$physical_info$breast_dia", // 心横径
              "pat_unique$physical_info$ctr", // CTR
              "pat_unique$physical_info$pre_scale_upper", // 前体重許容上限
              "pat_unique$physical_info$pre_scale_lower", // 前体重許容下限
              "pat_unique$physical_info$memo" // メモ
            ];
            if (!dirtyKeys.some(key => requiredKeys.includes(key))) {
              messages = ["身長", "心横径", "胸郭横径", "CTR", "前体重許容上限", "前体重許容下限", "メモ", "DW"];
              questionPatId.push(item);
            }
            if (!dataItem["pat_unique$physical_info$exam_date"]) {
              DWMessages.push("検査日");
              dwQuestionPatId.push(item);
            }
            if (dataItem["pat_unique$physical_info$target_weight_chkbox"]) {
              let flag = false;
              if (!dataItem["pat_unique$physical_info$dw"]) {
                DWMessages.push("DW");
                flag = true;
              }
              if (!dataItem["pat_unique$physical_info$indicator_cd"]) {
                DWMessages.push("指示者");
                flag = true;
              }
              if (!dataItem["pat_unique$physical_info$indicator_start_date"]) {
                DWMessages.push("目標体重指示開始日");
                flag = true;
              }
              flag && dwQuestionPatId.push(item);
            }
            if(dataItem["pat_unique$physical_info$dw"] && !dataItem["pat_unique$physical_info$indicator_cd"]) {
              DWMessages.push("指示者");
              dwQuestionPatId.push(item);
            }
          });

          if (questionPatId.length || dwQuestionPatId.length) {
            if (questionPatId.length === 0 && dwQuestionPatId.length) {
              messages = [...new Set(DWMessages)];
              this.$ons.notification.alert({
                title: DIALOG_MESSAGES['21010002'].title,
                message: messageFormat(DIALOG_MESSAGES[21010002].message, messages.join('、')),
              });
            } else {
              this.$ons.notification.alert({
                title: DIALOG_MESSAGES['23030006'].title,
                message: messageFormat(DIALOG_MESSAGES[23030006].message, messages.join('、')),
              });
            }
            this.finishLoadingScreen();
            return;
          }
        }
        updatePatList.forEach(updatePat => {
          let medicalHsts = updatePat.pat_unique.medical_hst_info;
          medicalHsts.forEach(medicalHst => {
            if (medicalHst.is_dialysis_underlying_disease === "1" && medicalHst.out_come === "10") {
              if (medicalHst.disease_cd !== medicalHst.cause_death) {
                medicalHst.is_dialysis_underlying_disease = "0";
                let is_confirmation_biopsy = medicalHst.is_confirmation_biopsy;
                let disease_cd = medicalHst.disease_cd;
                let disease_date = medicalHst.disease_date;
                medicalHst.is_confirmation_biopsy = "";
                medicalHst.disease_cd = medicalHst.cause_death;
                const addJson = { ...JSON_ARRAY_ITEM["medical_hst_info"] };
                const maxCtlNo = _.max(medicalHsts, json => json.ctl_no).ctl_no;
                addJson.ctl_no = maxCtlNo >= 0 ? maxCtlNo + 1 : 0;
                addJson.disease_cd = disease_cd;
                addJson.is_confirmation_biopsy = is_confirmation_biopsy;
                addJson.is_dialysis_underlying_disease = "1";
                addJson.out_come = "";
                addJson.disease_date = disease_date;
                medicalHsts.push(addJson);
              }
              updatePat.pat_personal_main.in_out_class = 2;
            } else if (medicalHst.out_come === "10") {
              medicalHst.disease_cd = medicalHst.cause_death;
              updatePat.pat_personal_main.in_out_class = 2;
            }
          });
        });
        await updatePatRecords(updatePatList).then(() => {
          this.$emit("refresh");
        }).catch(error => {
          getErrorMessage('MultiPatList.vue', 'updatePatRecords', error);
          this.finishLoadingScreen();
          throw new Error(error);
        }).finally(() => {
          this.setSameName();
          this.finishLoadingScreen();
        });
      }, 0);
    },

    cancelEdit() {
      if (this.isEdited) {
        this.isCancelEditDialogVisible = true;
      }
    },

    confirmCancelEdit(answer) {
      if (answer === "OK") {
        //mod FNSI-6478 劉全航 start
        this.unSavedInfo = [];
        this.editedPatIdFieldList = {};
        //mod FNSI-6478 劉全航 end
        this.initializeDataSource(cloneDeep(this.initialPatRecords));
      }
    },

    bindShowPopoverEvent() {
      const sortGrid = $$("#kendo").data("kendoGrid");
      if (sortGrid == null) {
        return;
      }
      const sortedData = sortGrid.dataSource;
      this.$nextTick(() => {
        const vue = this;
        const clickHandler = $$ => {
          return function(e) {
            const selectedIndex = $$.index(this);
            if (sortedData && sortedData._view.length > 0) {
              vue.selectedPatId = sortedData._view[selectedIndex].pat_id
            } else {
              vue.selectedPatId = vue.kendoDataSource.data[selectedIndex].pat_id;
            }
            vue.popoverTarget = e.target;
            vue.isPopoverVisible = true;
          };
        };

        const $$hospPatId = $$(".cell-hosppatid");
        $$hospPatId.on("click", clickHandler($$hospPatId));
        const $$patName = $$(".cell-patname");
        $$patName.on("click", clickHandler($$patName));
      });
    },

    async moveTo(routeName) {
      // add #10359、#10331 編集権限について、対応する。 dengshen start
      //表示フラグ反転
      this.isPopoverVisible = false;
      // add #10359、#10331 編集権限について、対応する。 dengshen end
      await this.selectPat(this.selectedPatId);
      this.$router.push({ name: routeName });
    },
    /**
     * 固定列、スクロール列の高さが倍率変更時にズレる為
     * 二つを合わせる処理を行う
     */
    setLockedContentHeight() {
      // 固定列、スクロール列の要素の高さを合わせる
      const scrollHeight = parseFloat(getComputedStyle(document.getElementsByClassName("k-auto-scrollable")[1]).height);

      // mod #11321 【たくしん会】データリストレイアウトマスタ＞身体情報(追加登録)とデータリスト表示バグ zkm start
      // document.getElementsByClassName("k-grid-content-locked")[0].style.height = `${scrollHeight}px`;
      if (document.getElementsByClassName("k-grid-content-locked").length > 0) {
        document.getElementsByClassName("k-grid-content-locked")[0].style.height = `${scrollHeight}px`;
      }
      // mod #11321 【たくしん会】データリストレイアウトマスタ＞身体情報(追加登録)とデータリスト表示バグ zkm end
    },
    /**
     * @description スタイル調整(グリッドサイズ)
     */
    setGridHeight() {
      if (this.isSelectedLayout) {
        const editMode = $$(".edit-mode").get(0).clientHeight;
        const mainArea = $$("#main-id").get(0).clientHeight;
        const cancelArea = $$(".btn2-cancel").get(0).clientHeight;
        const saveArea = $$(".btn1-execute").get(0).clientHeight;
        let buttonArea = cancelArea > saveArea ? cancelArea : saveArea;
        // ボタン高さを認識しない場合がある
        // buttonArea = buttonArea >= 30 ? buttonArea : 30;
        // ボタンに重ならない高さを取得
        // mod FNSI-改修内容 初回初期表示時、横スクロールは表示不正 dou start
        // const height = mainArea - selectArea - buttonArea;
        const height = mainArea - editMode - buttonArea - 5;
        // mod FNSI-改修内容 初回初期表示時、横スクロールは表示不正 dou end
        this.$nextTick(() => {
          const gridWidget = $$("#kendo").data("kendoGrid");
          // グリッドに高さを設定
          gridWidget.wrapper.height(height);
          // 画面へ適応
          gridWidget.resize($$(".multi-pat-list-header-switch"));
          gridWidget.resize($$(".multi-pat-list-footer-btn"));
          // 固定列、スクロール列の高さの調整
          this.setLockedContentHeight();
        });
      }
    },

    /**
     * kendo-gridのdata-bound時にcallされる関数
     * 一覧部の調整を行う
     */
    kgridDataBound() {
      this.$nextTick(() => {
        // 固定列、スクロール列の高さの調整
        this.setLockedContentHeight();
        this.enableLockedColumnScroll();
      });
    },
    /**
     * @description 連絡先配列要素番号変更
     */
    changeInfoToOtherContact(
      targetPatIndex,
      table,
      column,
      jsonArrayIndex,
      jsonKey,
      editedField,
      editedValue
    ) {
      const isKeyPerson =
        column === "other_contact_key_person_info" ? "1" : "0";

      column = "other_contact_info";
      const jsonArray = this.patRecordsForUpdating[targetPatIndex][table][
        column
      ];

      const otherContactInfo = jsonArray;
      jsonArrayIndex = this.getOtherContactInfoIndex(
        otherContactInfo,
        jsonArrayIndex,
        isKeyPerson
      );
      return [table, column, jsonKey, jsonArrayIndex, editedValue];
    },

    /**
     * @description 連絡先配列(キーパーソンのみ配列＋それ以外配列)要素番号取得
     */
    getOtherContactInfoIndex(otherContactInfo, jsonArrayIndex, isKeyPerson) {
      const hasKeyJsonArray = otherContactInfo.filter(
        el => el.is_key_person === isKeyPerson
      );
      const hasKeyJsonIndex = hasKeyJsonArray.length;

      const index = otherContactInfo.findIndex(json => {
        const ctlNo = hasKeyJsonArray[jsonArrayIndex]
          ? hasKeyJsonArray[jsonArrayIndex].ctl_no
          : undefined;
        return json.ctl_no === ctlNo;
      });

      return index >= 0
        ? index
        : // 最大要素番号 = 全体配列 - 取得した配列 + 選択したグリッド(配列要素)番号
          otherContactInfo.length - hasKeyJsonIndex + Number(jsonArrayIndex);
    },

    /**
     * @description 無限ループ配列要素番号変更
     */
    changeIndexToInfinity(jsonArray, jsonArrayIndex) {
      let index = jsonArrayIndex;
      // 無限ループ対策
      if (jsonArrayIndex < 0) {
        index = jsonArray.length;
      }
      return index;
    },

    /**
     * @description 変更するjsonKeyを取得
     */
    getSettingjsonKey(columnName, editedField) {
      let jsonKey = null;
      switch (columnName) {
        case "other_contact_info":
          if (editedField.match("other_contact_key_person_info")) {
            jsonKey = "is_key_person";
          }
          break;

        case "charge_staff_info":
          jsonKey = editedField.split("$")[3];
          break;

        case "medical_hst_info":
        case "physical_info":
          jsonKey = "facility_cd";
          break;
      }
      return jsonKey;
    },

    setKeyPerson(addJson, key) {
      addJson[key] = "1";
    },

    setchargeStaffInfo(addJson, key) {
      addJson[key] = "1";
    },

    setFacilityCd(addJson, key) {
      addJson[key] = this.facilityCd;
    },

    /**
     * @description 担当重複フラグ
     */
    hasSameRecord(recordList, editedField, selectedStaffCd) {
      const staffRecordList = recordList.filter(
        record => record.staff_cd === selectedStaffCd
      );

      const jsonKey = editedField.split("$")[3];
      const jsonKeyList = staffRecordList
        .filter(record => record[jsonKey] === "1")
        .map(item => item[jsonKey]);

      // 施設コードリストをSetオブジェクトに(重複排除)
      const set = new Set(jsonKeyList);
      if (jsonKeyList.length !== set.size) {
        // 元のリストと重複排除リストの長さが違うなら重複あり
        let param = "主治医";
        switch (jsonKey) {
          case "is_charge":
            param = "担当";
            break;
          case "is_puncture":
            param = "穿刺";
            break;
        }
        this.stringParams = param;
        return true;
      }
      return false;
    },

    findRequiredCell() {
      // バリデーションリセット
      this.validateObject = {};
      if (
        this.kendoDataSource === null ||
        !this.kendoDataSource.data ||
        this.kendoDataSource.data.length === 0
      ) {
        // 患者がいないなら
        return;
      }

      let columnList = ["患者ID", "患者名"];
      this.kendoGridColumns.forEach(item => {
        const fields = item.columns.map(column => column.field);
        columnList = [...columnList, ...fields];
      });
      const hasRequiredList = requiredList.filter(required =>
        columnList.includes(required)
      );
      if (hasRequiredList.length === 0) {
        // 必須項目がないなら
        return;
      }

      const grid = $$("#kendo").data("kendoGrid");
      hasRequiredList.forEach(required => {
        // 患者数ループ
        this.kendoDataSource.data.forEach((gridPat, gridIndex) => {
          const patInfo = this.patRecordsForUpdating.find(
            updItem => updItem.pat_personal_main.pat_id === gridPat.pat_id
          );
          const patId = patInfo.pat_personal_main.pat_id;
          // 患者行指定
          const dataItem = grid.dataSource.at(gridIndex);
          // 患者行取得
          const rowCells = grid.element.find(`tr[data-uid=${dataItem.uid}] td`);

          const requiredValue = this.getRequiredValue(patInfo, required);

          // 背景色を必須色へ
          if (!requiredValue || requiredValue === "") {
            // 未入力なら
            // 必須項目列取得
            const cellIndex = columnList.indexOf(required);

            const cell = $$(rowCells[cellIndex]);
            cell[0]?.classList?.add(CLASS_REQUIRED_CELL);

            if (!this.validateObject[required]) {
              this.validateObject[required] = [];
            }
            if (!this.validateObject[required].includes(patId)) {
              this.validateObject[required].push(patId);
            }
          }
        });
      });
      // TODO: sort(グリッドヘッダ押下)後クラス再設定必要
      // const sortGrid = $$("#kendo").data("kendoGrid");
      // sortGrid.bind("sort", function(e) {
      // });
    },

    // ※※※※※※
    // MultiPatList.vueから、色をかわりたいのhosp_pat_idのリストを取る、もしhosp_pat_idは一緒なら、色が変わる
    // ※※※※※※
    // mod 6478 6256 徐博 start
    findPatInDialysis() {
      // 患者がいないなら
      if (this.kendoDataSource === null || !this.kendoDataSource.data || this.kendoDataSource.data.length === 0) {
        return;
      }
      const grid = $$("#kendo").data("kendoGrid");
      if (null === grid) {
        return;
      } else {
        // 患者数ループ
        this.kendoDataSource.data.forEach((patient, index) => {
          const ordMains = patient.ordMains;
          if (ordMains.length > 0) {
            const ordNoList = ordMains.map(ord => ord.ordNo);
            const conditions = [
              { arr: this.ordArr.afterDialysisArr, className: CLASS_AFTERDIALYSIS_CELL },
              { arr: this.ordArr.dialysisArr, className: CLASS_DIALYSIS_CELL },
              { arr: this.ordArr.afterSendConditionArr, className: CLASS_AFTERSENDCONDITION_CELL }
            ];

            conditions.forEach(condition => {
              this.processCondition(grid, index, ordNoList, condition);
            });
          }
        });
      }
    },
    /* 条件に基づいてセルにクラスを追加する処理 */
    processCondition(grid, i, ordNoList, condition) {
      if (condition.arr.length > 0) {
        ordNoList.forEach(ordNo => {
          if (condition.arr.includes(ordNo)) {
            const row = grid.element.find(`tr[data-uid=${grid.dataSource.at(i)?.uid}]`);
            row.each((_, cell) => {
              for (const element of cell.getElementsByClassName("cell-hosppatid")) {
                element.classList.add(condition.className);
              }
            });
          }
        });
      }
    },
    // mod 6478 6256 徐博 end

    getRequiredValue(patInfo, editedField) {
      let [table, column, jsonKey, jsonArrayIndex] = editedField.split("$");
      if (column === "charge_staff_info") {
        let staffClass, itemIndex;
        [table, column, jsonKey, staffClass, itemIndex] = editedField.split(
          "$"
        );
        itemIndex = Number(itemIndex);
        let counter = 0;
        jsonArrayIndex = `${patInfo[table][column].findIndex(
          staff => staff[staffClass] === "1" && ++counter === itemIndex
        )}`;
      }

      if (!jsonKey) {
        // 単一カラム
        return patInfo[table][column];
      } else if (!jsonArrayIndex) {
        // 単一JSONカラム
        return patInfo[table][column][jsonKey];
      } else {
        // JSON配列カラム
        return patInfo[table][column][jsonArrayIndex][jsonKey];
      }
    },

    /**
     * @description バリデーションチェック
     * @returns true: 保存, false: 保存失敗
     */
    isValidate() {
      const kendoValidator = $$("#kendo")
      .kendoValidator()
      .data("kendoValidator");
      const keys = Object.keys(this.validateObject);
      const requiredList = keys.filter(
        key => this.validateObject[key].length > 0
      );
      if (requiredList.length > 0) {
        let columns = [];
        this.kendoGridColumns.forEach(
          item => (columns = [...columns, ...item.columns])
        );

        const strList = requiredList.map(
          required => columns.find(item => item.field === required).title
        );

        this.validateStringParams = `「${strList.join("・")}」`;
      } else {
        this.validateStringParams = "";
      }
      return requiredList.length === 0 && kendoValidator.validate();
    },

    sortColumnInfo(array) {
      return array.sort((a, b) => {
        const dateA = this.formatterDay(a);
        const timeA =
          this.formatterTime(a) === null ? "0000" : this.formatterTime(a);
        const dateB = this.formatterDay(b);
        const timeB =
          this.formatterTime(b) === null ? "0000" : this.formatterTime(b);

        return `${dateB}${timeB}` - `${dateA}${timeA}`;
      });
    },
    /**
     * @description 日付フォーマット
     * @param {Object} json
     * @returns {String}
     */
    formatterDay(json) {
      return moment(json.exam_date, "YYYY-MM-DDTHH:mm:ss.SSSZ").format(
        "YYYYMMDD"
      );
    },

    /**
     * @description 時間フォーマット
     * @param {Object} json
     * @returns {String}
     */
    formatterTime(json) {
      const date = json.exam_date;

      if (date && date.match(/T/)) {
        return moment(date, "YYYY-MM-DDTHH:mm:ss.SSSZ").format("HHmm");
      }
      return null;
    },

    setPhysicalExamDate(physicalInfo, editedValue, isDay) {
      let initDate = null;
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_データリスト（患者情報） 20231221 ztc start
      // let editDay = "0000-01-01";
      let editDay = "0000/01/01";
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_データリスト（患者情報） 20231221 ztc end
      let editTime = null;
      if (physicalInfo) {
        initDate = physicalInfo.exam_date;
      }

      if (initDate) {
        editDay = initDate;
        if (editDay.match(/T/)) {
          const encodeInitDate = moment(
            `${initDate}:00+09:00`,
          // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_データリスト（患者情報） 20231221 ztc start
          //   "YYYY-MM-DDTHH:mm:ss.SSSZ"
          // ).format("YYYY-MM-DDTHH:mm");
            "YYYY/MM/DDTHH:mm:ss.SSSZ"
          ).format("YYYY/MM/DDTHH:mm");
          // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_データリスト（患者情報） 20231221 ztc end
          const dateList = encodeInitDate.split(/T/);
          editDay = dateList[0];
          editTime = dateList[1];
        }
      }

      if (isDay) {
        // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_データリスト（患者情報） 20231221 ztc start
        // editDay = editedValue ? editedValue : "0000-01-01";
        editDay = editedValue ? editedValue : "0000/01/01";
        // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_データリスト（患者情報） 20231221 ztc end
      } else {
        editTime = editedValue;
      }
      if (editTime === "" || !editTime) {
        // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_データリスト（患者情報） 20231221 ztc start
        // return editDay === "0000-01-01"
        return editDay === "0000/01/01"
          ? null
          // : moment(`${editDay}`, "YYYY-MM-DD").format("YYYY-MM-DD");
          : moment(`${editDay}`, "YYYY/MM/DD").format("YYYY/MM/DD");
        // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_データリスト（患者情報） 20231221 ztc end
      }

      const editDate = moment(
        `${editDay}T${editTime}`,
        "YYYY/MM/DDTHH:mm"
      ).format("YYYY/MM/DDTHH:mm:ss.SSSZ");
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_データリスト（患者情報） 20231221 ztc end
      return editDate;
    },

    setExamDate(value) {
      if (value && value.match(/T/)) {
        const encodeInitDate = moment(
          `${value}:00+09:00`,
          "YYYY-MM-DDTHH:mm:ss.SSSZ"
        // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_データリスト（患者情報） 20231221 ztc start
        // ).format("YYYY-MM-DDTHH:mm");
        //   "YYYY/MM/DDTHH:mm:ss.SSSZ"
        ).format("YYYY/MM/DDTHH:mm");
        const dateList = encodeInitDate.split(/T/);
        // return dateList[0] !== "0000-01-01";
        return dateList[0] !== "0000/01/01";
        // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_データリスト（患者情報） 20231221 ztc end
      } else {
        return value;
      }
    },

    getCtr(physicalInfo) {
      const breastDia = physicalInfo.breast_dia;
      const chestDia = physicalInfo.chest_dia;
      if (breastDia === null || chestDia === null || chestDia === 0) {
        // ゼロ除算は計算を行わない
        return null;
      }

      const ctrValue = (breastDia / chestDia) * 100;
      // 100%を超える場合は100%を設定
      if (ctrValue >= 100) {
        return 100;
      } else {
        // 四捨五入
        return Math.round(ctrValue * 100) / 100;
      }
    },

    changeInfoToChargeStaffInfo(
      targetPatIndex,
      table,
      column,
      jsonArrayIndex,
      jsonKey,
      editedField,
      editedValue
    ) {
      let staffClass, itemIndex;
      [table, column, jsonKey, staffClass, itemIndex] = editedField.split("$");
      itemIndex = Number(itemIndex);
      const jsonArray = this.patRecordsForUpdating[targetPatIndex][table][
        column
      ];

      let counter = 0;
      jsonArrayIndex = `${jsonArray.findIndex(
        staff => staff[staffClass] === "1" && ++counter === itemIndex
      )}`;

      if (jsonArrayIndex < 0) {
        const maxIndex = this.changeIndexToInfinity(jsonArray, jsonArrayIndex);
        const addStaffClassIndex = itemIndex - counter;
        jsonArrayIndex = maxIndex - 1 + addStaffClassIndex;
      }
      return [table, column, jsonKey, jsonArrayIndex, editedValue];
    },

    changeInfoToMedicalHstInfo(
      targetPatIndex,
      table,
      column,
      jsonArrayIndex,
      jsonKey,
      editedField,
      editedValue
    ) {
      if (jsonKey === "is_diagnosed" || jsonKey === "cause_death") {
        const medicalHstInfo = this.patRecordsForUpdating[targetPatIndex][
          table
        ][column];
        // 死亡時
        jsonArrayIndex = medicalHstInfo.findIndex(
          record => record.out_come === "10"
        );

        jsonArrayIndex = this.changeIndexToInfinity(
          medicalHstInfo,
          jsonArrayIndex
        );
        return [table, column, jsonKey, jsonArrayIndex, editedValue];
      }
      if (jsonKey === "disease_cd" || jsonKey === "is_confirmation_biopsy" || jsonKey === "disease_date") {
        const medicalHstInfo = this.patRecordsForUpdating[targetPatIndex][
          table
          ][column];
        jsonArrayIndex = medicalHstInfo.findIndex(
          record => record.is_dialysis_underlying_disease === "1"
        );

        jsonArrayIndex = this.changeIndexToInfinity(
          medicalHstInfo,
          jsonArrayIndex
        );
        return [table, column, jsonKey, jsonArrayIndex, editedValue];
      }
      return [table, column, jsonKey, 0, editedValue];
    },

    changeInfoToPhysicalInfo(
      targetPatIndex,
      table,
      column,
      jsonArrayIndex,
      jsonKey,
      editedField,
      editedValue
    ) {
      const initPhysical = this.initialPatRecords[targetPatIndex][table][
        column
      ];
      const initCtlNoList = initPhysical.map(item => item.ctl_no);
      const editPhysical = this.patRecordsForUpdating[targetPatIndex][table][
        column
      ];
      const addIndex = -1;
      jsonArrayIndex =
      initPhysical.length < editPhysical.length
      ? editPhysical.findIndex(item => !initCtlNoList.includes(item.ctl_no))
      : addIndex;
      jsonArrayIndex = this.changeIndexToInfinity(editPhysical, jsonArrayIndex);

      // 測定日時設定
      const isDay = editedField.match(/exam_date/);
      if (isDay) {
        editedValue = this.setPhysicalExamDate(
          editPhysical[jsonArrayIndex],
          editedValue,
          isDay
        );
        jsonKey = "exam_date";
      }
      return [table, column, jsonKey, jsonArrayIndex, editedValue];
    },

    /**
     * @description 指示更新
     * @param {Object} record 更新用身体情報レコード
     * @param {String} targetWeight 更新前目標体重
     */
    async updateOrdMain(recordList) {
      const sendJsonList = recordList.map(record => {
        const patId = record.pat_personal_main.pat_id;
        //add #10185 DW一括登録時に連携イベントが発生しない zhaoqi 20240105 start
        let physicalInfo = record.pat_unique.physical_info;
        physicalInfo.sort((a, b) => b.ctl_no - a.ctl_no);
        let biggestCtlNosExamDate = physicalInfo[0].exam_date;
        const parseDate = dateStr => new Date(dateStr);
        physicalInfo.sort((a, b) => parseDate(b.exam_date) - parseDate(a.exam_date));
        let biggestExamDate = physicalInfo[0].exam_date;
        if (biggestCtlNosExamDate === biggestExamDate) {
          physicalInfo.sort((a, b) => b.ctl_no - a.ctl_no);

          const indStartDate = physicalInfo.indicator_start_date;
          // 一年後
          const indEndDate = moment(indStartDate, "YYYYMMDD")
            .add(1, "y")
            .subtract(1, "days")
            .format("YYYYMMDD");
        if (physicalInfo.target_weight === "DWと同じ") {
          physicalInfo.target_weight = physicalInfo.dw;
        }

        return {
          // 施設コード
          facility_cd: this.facilityCd,
          // 患者ID
          pat_id: patId,
          // 治療開始日
          ind_start_date: indStartDate,
          // 治療終了日
          ind_end_date: indEndDate,
          // 曜日パターン
          week_pattern: "[{'text': '全','done': false,'value': 0}]",
          // 変更対象クールコード
          ind_kur_cd: JSON.stringify([]),
          // 変更対象治療方法コード
          ind_treatment_cd: JSON.stringify([]),
          // 終了日存在フラグ
          is_deadline: false,

          dw: physicalInfo.dw,
          ctr: physicalInfo.ctr,
          target_weight: physicalInfo.target_weight,
          indicator_cd: physicalInfo.indicator_cd,
          upd_user_cd: this.getUserId(),
          target_dialysis_state:0
        };
        }
      });

      await ApiHelper.post("/mainData/updateOrdMainList", sendJsonList).catch(
        error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('MultiPatList.vue', 'updateOrdMain', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
          throw error;
        }
      );
    },

    /**
     * @description テキストエリアの幅変更に応じてグリッドをリサイズ
     */
    resizeToFitTextArea() {
      if (this.$refs.grid != null) {
        const setWidth = parseInt(this.$refs.grid.kendoWidget().columns[0].width);
        this.$refs.grid.kendoWidget().resizeColumn(this.$refs.grid.kendoWidget().columns[0], setWidth);
        this.$nextTick(() => {
          this.setGridHeight();
        });
      }
    },
    enableLockedColumnScroll() {
      const lockedContent = document.querySelector('.k-grid-content-locked');
      const scrollableContent = document.querySelector('.k-grid-content'); // 可動列

      if (lockedContent) {
        lockedContent.addEventListener('wheel', (e) => {
          e.preventDefault();
          lockedContent.scrollTop += e.deltaY;
        });

        let startY = 0;
        lockedContent.addEventListener('touchstart', (e) => {
          startY = e.touches[0].clientY;
        }, { passive: false });

        lockedContent.addEventListener('touchmove', (e) => {
          const deltaY = startY - e.touches[0].clientY;
          lockedContent.scrollTop += deltaY;
          startY = e.touches[0].clientY;
          e.preventDefault();
        }, { passive: false });
      }

      if (lockedContent && scrollableContent) {
        // 固定列のスクロールに応じて可動列を同期
        lockedContent.addEventListener('scroll', () => {
          scrollableContent.scrollTop = lockedContent.scrollTop;
        });

        // 可動列のスクロールに応じて固定列を同期（双方向同期）
        scrollableContent.addEventListener('scroll', () => {
          lockedContent.scrollTop = scrollableContent.scrollTop;
        });
      }
    },
    onBeforeEdit(e) {
      if (this.isMobileDevice && !this.allowEdit) {
        /* NOTE:
         * モバイル系は、スワイプ・フリック操作で入力パッドが表示される。
         * そのため、スクロール操作が損なわれるので、閲覧モードのときは
         * 後続のイベントを発火させないように制御する。
         */
        e.preventDefault();
        return;
      }
      // this.editStart(e);
    },
  },
// add FNSI-改修内容 パンくずリスト押下時に最新の情報を取得する。表示条件の変更はしない dou start
  beforeDestroy() {
    window.removeEventListener("resize", this.setGridHeight, false);
    // Rootページのサイドバーボタン要素のイベントリスナー解除
    const rootSideBarBtn = document.querySelector('#showPatientSearchSidebarBtn');
    rootSideBarBtn?.removeEventListener('click', this.setGridHeight);
    //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
    EventBus.$off("requestReportParams", this.requestrReportParams);
    //add 5984 機能帳票でパラメータが正しく渡されていない 吉 end
    // del #10054 破棄確認・保存活性(複数変更含む)・削除対応_データリスト（患者情報） 20231221 ztc start
    // EventBus.$off("refresh", this.getInitData);
    // del #10054 破棄確認・保存活性(複数変更含む)・削除対応_データリスト（患者情報） 20231221 ztc end
    clearInterval(this.socketInterval);

    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  }
// add FNSI-改修内容 パンくずリスト押下時に最新の情報を取得する。表示条件の変更はしない dou end
};
</script>

<style>
@media print {
  /** 患者情報1 tableレイアウト崩れ回避 */
  body:has(#multi-pat-list) #main-id {
    display: inline-block;
  }
}
</style>

<style scoped>
::v-deep .k-dirty{
  display: none;
}
::v-deep .k-dirty-cell .k-dirty{
  display: block;
}

::v-deep .k-dirty-cell{
  background-color: #ccffcc;
  font-weight: bold;
}

::v-deep .userCategory {
  margin-left: 10px;
}
::v-deep .userCategory>.k-widget.k-dropdown{
  width: 120px;
  margin-left: 10px;
}
.multi-pat-list {
  background-color: var(--main-background-color);
  color: var(--ntss-list-body-color);
}

.btn1-execute {
  position: fixed;
  bottom: 45px;
  right: 17px;
  text-align: center;
  box-sizing: border-box;
  outline: 0;
}

.btn2-cancel-right {
  position: fixed;
  bottom: 45px;
  text-align: center;
  box-sizing: border-box;
  outline: 0;
  right: 130px;
}

.loading-modal {
  text-align: center;
  font-size: 30px;
}

.transition-popover {
  padding: 10px;
  float: left;
  width: 140px;
}

.transition-button {
  margin-bottom: 2px;
  justify-content: left;
  padding: 0;
  margin-right: 5px;
  width: 12.5em;
}

.transition-button:last-child {
  margin-bottom: 0;
}

/* kendo-grid用style */
/* 全体の色 */
.multi-pat-list >>> .k-grid {
  background-color: var(--ntss-list-background-color) !important;
  color: var(--ntss-list-body-color) !important;
}

.multi-pat-list >>> .k-widget {
  font-size: 1em;
}

.multi-pat-list >>> .k-button {
  font-size: 1em;
}

/* セルの枠線(なぜか縦線にしか色がつかない) */
.multi-pat-list >>> .k-grid tr,
.multi-pat-list >>> .k-grid td {
  border-color: var(--master-maintenance-kgrid-border-color) !important;
}

/* 行マウスオーバー */
.multi-pat-list >>> .k-grid tr:hover {
  background-color: var(--ntss-list-body-background-color) !important;
  color: var(--ntss-list-body-color) !important;
}

/* 列ヘッダ */
.multi-pat-list >>> .k-header-dummy {
  vertical-align: middle !important;
  background-color: var(--ntss-list-header-background-color);
  color: #ffffff;
  position: relative;
  cursor: default;
}
.multi-pat-list >>> .k-header {
  vertical-align: middle !important;
  background-color: var(--ntss-list-header-background-color);
  color: #ffffff;
}
.multi-pat-list >>> .k-header[data-role="columnsorter"] {
  vertical-align: middle !important;
  background-color: #333333;
  background-image: none;
}
.multi-pat-list >>> .k-header[data-field="pat_personal_main$hosp_pat_id"] {
  /* width: 125px; */
  vertical-align: middle !important;
  background-color: #333333;
  background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%);
}
.multi-pat-list >>> .k-header[data-field="pat_personal_main$pat_name"] {
  /* width: 125px; */
  vertical-align: middle !important;
  background-color: #333333;
  background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%) !important;
}

/* 入力不可列のヘッダ */
.multi-pat-list >>> .k-header-disabled {
  background-color: #808080 !important;
  background-image: none;
}

.multi-pat-list >>> .k-grid-header {
  background: var(--ntss-list-header-background-color);
  background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,0.1) 100%);
}

/* 偶数行 */
.multi-pat-list >>> .k-alt {
  background-color: var(--ntss-list-content-2nd-background-color) !important;
  color: var(--ntss-list-body-color) !important;
}

/* 入力UI */
.multi-pat-list >>> .k-textbox,
.multi-pat-list >>> .k-dropdown-wrap,
.multi-pat-list >>> .k-numeric,
.multi-pat-list >>> .k-select,
.multi-pat-list >>> .k-popup {
  background-color: var(--main-background-color) !important;
  color: var(--ntss-list-body-color) !important;
}

/* kendoDropDownListの選択肢 */
.multi-pat-list >>> .k-popup {
  border-color: var(--ntss-list-body-background-color) !important;
}

/* kendoDropDownListの選択肢のマウスオーバー */
.multi-pat-list >>> .k-popup li:hover {
  background-color: var(--ntss-list-body-background-color) !important;
  color: var(--ntss-list-body-color) !important;
}

#kendo >>> .grid-required-cell {
  background-color: #ff6358 !important;
}

/* 前体重測定済 */
#kendo >>> .grid-after-send-condition-cell {
  background-color: #42cb92 !important;
}
/* 治療中 */
#kendo >>> .grid-dialysis-cell {
  background-color: #2ca06f !important;
}
/* 治療終了 */
#kendo >>> .grid-after-dialysis-cell {
  background-color: #557769 !important;
}

#kendo >>> .grid-edited-cell {
  text-overflow: ellipsis !important;
  overflow: hidden !important;
}

.multi-pat-list >>>.k-grid td{
  white-space: pre-line !important;
}
.multi-pat-list >>> .k-i-sort-asc-sm::before {
  content: "▲" !important;
  color: #ffffff;
}
.multi-pat-list >>> .k-i-sort-desc-sm::before {
  content: "▼" !important;
  color: #ffffff;
}

ons-popover >>> .popover__content {
  /*min-width: 235px;*/
  width: 14em;
}
/* add FNSI-改修内容 入外区分が入院の場合、患者名は紫色にする。同姓同名患者の場合はそれが判断可能にする。 dou start */
#kendo >>> .same-icon {
  height: 1em;
  display: inline-block;
  margin-left: 0.5em;
}
.transition-button .icon {
  height: 1.5em;
  width: 1.5em;
  margin: 0 5px 0 5px;
}
/* add FNSI-改修内容 入外区分が入院の場合、患者名は紫色にする。同姓同名患者の場合はそれが判断可能にする。 dou end */

/* 携帯が似合う shan start */

/* ::v-deep .k-grid-header-locked{
   width: 300px !important;
 }
::v-deep .k-grid-content-locked{
   width: 300px !important;
 } */
::v-deep .multi-pat-list .k-grid td{
   width: 150px !important;
 }

 @media screen and (max-width: 600px){
/* ::v-deep   .k-grid-header-locked {
     width: 180px !important;
   }
::v-deep .k-header[data-field="pat_personal_main$hosp_pat_id"] {
    width: 65px !important;
  }
::v-deep .k-header[data-field="pat_personal_main$pat_name"] {
    width: 65px !important;
  }
::v-deep .k-grid-content-locked{
   width: 180px !important;
 }
::v-deep .multi-pat-list .k-grid td{
   width: 100px !important;
 } */
}
::v-deep .k-grid td{
  word-wrap:break-word;
}
/* 携帯が似合う shan end */

.kendo-grid-toolbar-style >>> .k-grid-content-locked {
  overflow-y: scroll !important;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: none;
  -ms-overflow-style: none;
}
.kendo-grid-toolbar-style >>> .k-grid-content-locked::-webkit-scrollbar {
  display: none;
}
@media print {
  .multi-pat-list {
    position: absolute;
  }
  /** スクロールコンテナ */
  .multi-pat-list >>> .k-grid-header-wrap,
  .multi-pat-list >>> .k-grid-content {
    overflow: hidden !important;
    height: auto !important;
  }
  /** 固定列調整 */
  .multi-pat-list >>> .k-grid-content-locked {
    height: auto !important;
  }
  /** 固定列枠線 */
  .multi-pat-list >>> .k-grid-header-locked::after {
    content: "";
    position: absolute;
    top: 0;
    right: 0;
    width: 1px;
    height: 100%;
    background: var(--master-maintenance-kgrid-header-background-color);
    pointer-events: none;
  }
  .multi-pat-list >>> .k-grid-content-locked::after {
    content: "";
    position: absolute;
    top: 0;
    right: 0;
    width: 1px;
    height: 100%;
    background: var(--master-maintenance-kgrid-border-color);
    pointer-events: none;
  }
  /** ヘッダのズレ原因を除去 */
  .multi-pat-list >>> .k-grid-header {
    padding-right: 0 !important;
  }
  /** gridの幅 */
  .multi-pat-list >>> .k-grid {
    width: 100vw;
    height: auto !important;
  }
  /** 印刷時に横スクロール右端時に強制的にスクロール位置を調整 */
  /* 右端時固定列最前面表示*/
  .multi-pat-list:has(table.scroll-rightmost) >>> .k-grid-content-locked,
  .multi-pat-list:has(table.scroll-rightmost) >>> .k-grid-header-locked {
    z-index: 1;
    background-color: inherit;
  }
  .multi-pat-list:has(table.scroll-rightmost) {
    margin-left: -1px !important;
  }
  .multi-pat-list >>> .k-grid-header-wrap:has(table.scroll-rightmost),
  .multi-pat-list >>> .k-grid-content:has(table.scroll-rightmost) {
    position: static;
  }
  /* フッターボタン非表示 */
  .multi-pat-list >>> .multi-pat-list-footer-btn {
    display: none;
  }
}
</style>
