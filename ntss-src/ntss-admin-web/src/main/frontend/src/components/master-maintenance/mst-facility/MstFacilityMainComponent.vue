<template>
  <div class="main-content-area master-maintenance-page">
    <div class="ntss-list" :style="ntssListStyles">
      <div class="k-grid-toolbar k-header kendo-grid-toolbar-style mst-facility-direct-jq-toolbar" :style="heightStyles">
        <!-- mod redmine 4485 施設マスタの並び順が変更 宋qy start -->
        <div id="grid-header" :class="['header-btn-area', 'right', isMobileDevice ? 'mobile-header' : '']">
        <!-- mod redmine 4485 施設マスタの並び順が変更 宋qy end -->

          <v-ons-button
            v-if="isAdminUser"
            v-show="!isSortMode && isAllowAddRecord"
            class="btn3-normal toolbar-btn"
            style="float: left"
            @click="addRow()"
          >
            追加
          </v-ons-button>
          <v-ons-button
            v-else
            style="visibility:hidden"
            class="btn3-normal toolbar-btn"
          >
            &nbsp;
          </v-ons-button>
          <v-ons-row v-show="isMobileDevice" style="float: left; width: 6em; height: 1em;">
            <v-ons-col width="45%" vertical-align="center">
              <label class="fab-font-color">編集</label>
            </v-ons-col>
            <v-ons-col width="55%" vertical-align="center">
              <v-ons-switch modifier="outline" style="float: left; margin-left: 2px;" v-model="allowEdit" />
            </v-ons-col>
          </v-ons-row>
          <!-- add redmine 4485 施設マスタの並び順が変更 宋qy start -->
          <v-ons-button
            v-show="!isSortMode && isAllowSort"
            modifier="outline"
            class="btn3-normal toolbar-btn"
            @click="toRankEditBtnClick()"
          >
            並び順表示
          </v-ons-button>
          <v-ons-button
            v-show="isSortMode && isAllowSort"
            modifier="outline"
            class="btn3-normal toolbar-btn"
            @click="sortBtnClick()"
          >
            反映
          </v-ons-button>
          <!-- add redmine 4485 施設マスタの並び順が変更 宋qy end -->

        </div>
        <!-- ソート後グリッド表示 -->
        <div
          v-show="isSortChacked"
          id="grid-font-size"
          ref="grid"
          :class="[
            fontSizeSet,
            'ntss-kendo-grid-legacy',
            'mst-facility-direct-jq-grid'
          ]"
        ></div>
      </div>
      <div id="grid-footer">
        <v-ons-row v-show="!isSortMode" width="100%">
          <v-ons-col width="50%">
            <v-ons-button
              class="button btn2-cancel denial-btn"
              style="width: auto;"
              @click="cancel"
            >
              キャンセル
            </v-ons-button>
          </v-ons-col>
          <v-ons-col width="50%" class="right">
            <v-ons-button
              class="button btn1-execute registration-btn"
              style="width: auto;"
              :disabled="!isChanged"
              @click="saveRecord"
            >
              保存
            </v-ons-button>
          </v-ons-col>
        </v-ons-row>
      </div>
    </div>

    <message-dialog
      v-if="isDialogVisible"
      v-model:visible="isDialogVisible"
      :message-cd="messageCd"
      :string-params="stringParams"
      type="1"
    />
  </div>
</template>

<script>
import { createApp, markRaw } from "@/compat/vue/runtime";

import _ from "@/compat/collections/lodash";
import dayjs from "@/compat/date/dayjs";
import { ApiHelper } from "@/apis/AxiosHelper";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";
import messageDialog from "@/components/common/message-dialog/MessageDialog";

import { SYS_USE_TYPE } from "@/constants/sysUseConstants";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
// add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen start
import { MSG_SETTING_REFLECTION } from "@/constants/masterMaintenanceConstants";
import { deepCopy } from "@/functions/common/CommonFunctions";
import { sendRequestGetMstFacilitySettingValue } from "@/apis/facility-setting";
import { PERMISSION_CHANGE_SIGNOUT } from "@/constants/facilitySetting";
// add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen end
//#10715:日付IF修正Start
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import { getScopedAlertDialogs, getScopedElementsByClassName, triggerScopedDownload } from "@/functions/common/LayoutMeasureHelper";
import { syncKendoGridLockedRowHeights } from "@/utils/kendoGridLockedSync";
import $ from "jquery";
import kendo from "@progress/kendo-ui";
import CancelActionTemplate from "./MstFacilityCancelActionTemplate.vue";
import {
  bindGridEditorEnterToCloseCell,
  bindGridEditorDropDownListToCloseCell,
  bindGridEditorNumericWheelSpinAssist,
  getGridEditFieldFromEvent,
  readGridEditorNumericValue,
} from "@/compat/kendo/grid-edit";

//#10715:日付IF修正End



function installComponentJQuery() {
  if (typeof window !== "undefined") {
    window.$ = window.$ || $;
    window.jQuery = window.jQuery || $;
  }
  if (typeof globalThis !== "undefined") {
    globalThis.$ = globalThis.$ || $;
    globalThis.jQuery = globalThis.jQuery || $;
  }
}

function escapeAttr(value) {
  return String(value ?? "")
    .replace(/&/g, "&amp;")
    .replace(/"/g, "&quot;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;");
}

//URI
const uriFunctionAll = "/mstInfo/sysFunction";
const uriFunctionAdvancedAll = "/mstInfo/sysFunctionAdvanced";

/** 全解約に使用する定数定義 */
// 契約中：0
const CONTRACTING = "0";
const CONTRACTING_LABEL = "";
// 全解約：1
const CANCEL = "1";
const CANCEL_LABEL = "全解約";
// 解約予約済：2
const RESERVE_CANCEL = "2";
const RESERVE_CANCEL_LABEL = "解約済み：データ削除予約済み";
// 解約データ削除中：3
const CANCELING = "3";
const CANCELING_LABEL = "解約済み：データ削除中...";
// 解約データ削除完了：4
const CANCELED = "4";
const CANCELED_LABEL = "解約済み：データ削除完了";
// 解約予約キャンセル：5
const CANCEL_STOP = "5";
const CANCEL_STOP_LABEL = "解約予約キャンセル";

/** ReMSのみ解約に使用する定数定義
 *  (契約中・解約予約キャンセルは全解約と共通)
*/
// ReMSのみ解約：R1
const REMS_CANCEL = "R1";
const REMS_CANCEL_LABEL = "ReMSのみ解約";
// ReMSのみ解約予約済：R2
const RESERVE_REMS_CANCEL = "R2";
const RESERVE_REMS_CANCEL_LABEL = "ReMSのみ解約済み：データ削除予約済み";
// ReMSのみ解約データ削除中：R3
const REMS_CANCELING = "R3";
const REMS_CANCELING_LABEL = "ReMSのみ解約済み：データ削除中...";
// ReMSのみ解約データ削除完了：4
const REMS_CANCELED = "R4";
const REMS_CANCELED_LABEL = "ReMSのみ解約済み：データ削除完了";

/** FNSiのみ解約に使用する定数定義
 *  (契約中・解約予約キャンセルは全解約と共通)
*/
// FNSiのみ解約：F1
const FNSI_CANCEL = "F1";
const FNSI_CANCEL_LABEL = "FNSiのみ解約";
// FNSiのみ解約予約済：F2
const RESERVE_FNSI_CANCEL = "F2";
const RESERVE_FNSI_CANCEL_LABEL = "FNSiのみ解約済み：データ削除予約済み";
// FNSiのみ解約データ削除中：F3
const FNSI_CANCELING = "F3";
const FNSI_CANCELING_LABEL = "FNSiのみ解約済み：データ削除中...";
// FNSiのみ解約データ削除完了：F4
const FNSI_CANCELED = "F4";
const FNSI_CANCELED_LABEL = "FNSiのみ解約済み：データ削除完了";

// 施設解約管理：処理ステータス定数
/** ステータス: 処理待機 */
const PROC_STATUS_WAITING = "0";

/** ステータス: バックアップ作成中 */
const PROC_STATUS_BACKUP_IN_PROGRESS = "1";

/** ステータス: バックアップ作成済 */
const PROC_STATUS_BACKUP_COMPLETED = "2";

/** ステータス: 処理中（delete） */
const PROC_STATUS_DELETING = "3";

/** ステータス: 完了 */
const PROC_STATUS_COMPLETED = "9";

// 施設解約管理：処理区分定数
/** 処理区分: 全解約 */
const PROC_CLASS_CANCEL = "1";

/** 処理区分: ReMSのみ解約 */
const PROC_CLASS_REMS_CANCEL = "3";

/** 処理区分: FNSiのみ解約 */
const PROC_CLASS_FNSI_CANCEL = "4";

/**
 * TODO
 * more: モーダルで編集した項目が、一覧上で「編集済み（三角マーク）」をつけたい。
 */
export default {
  components: {
    "message-dialog": messageDialog
  },
  data() {
    return {
      recordList: [],
      // 初期状態で1列がないとその後の表示が行われないため初期列を定義
      columns: [
        {
          field: "code",
          title: "code",
          hidden: false,
          editable: () => true,
          values: null
        }
      ],
      condition: {
        recordName: "",
        includeDeleted: false
      },
      updateResponse: {
        isSuccess: false,
        errorMessage: ""
      },
      isSortMode: false,
      isSorted: false,
      kendoGridToolbarHeight: 500,
      kendoGridHeight: 300,
      columnWidth: 14,
      kendoValidatorSetup: {
        rules: {},
        messages: {}
      },
      // 編集失敗時のマスタ/列/スキーマ情報のバックアップ
      backupMasterRecordList: [],
      isDialogVisible: false,
      stringParams: null,
      messageCd: null,
      isSortChacked: false,
      // システム設定から取得したメールテンプレートの値を保持
      defaultMailTemplate: "",
      //Android端末で編集中であることを示すフラグ
      editingFlg: false,
      androidFlg: false,
      iosFlg: false,
      scrollPosition: {
        top: 0,
        left: 0
      },
      lastScrollTop: 0,
      lastScrollLeft: 0,
      preserveGridScrollAfterSave: false,
      // 自画面の名称
      selfScreenName: "",
      mntFacilityCancelManageList: [],
      isEditGrid: false,
      // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen start
      signoutFlg: false,
      // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen end
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード,
      directGridDataSource: null,
      directGridWidget: null,
      directGridMounted: false,
      directGridLayoutRafId: null,
      directGridFilterRefreshRafId: null,
      directGridScrollSyncRafId: null,
      directGridRowVisualRafIds: markRaw(new Map()),
      facilityRowSnapshots: markRaw(new Map()),
      directGridTemplateApps: markRaw([]),
      directGridColumnSignature: "",
      kendoValidator: null,
    };
  },
  computed: {
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    ...mapGetters("master-maintenance", {
      getMasterRecordList: "getMasterRecordList",
      getFilteredMasterRecordList: "getFilteredMasterRecordList",
      getUpdateRecordList: "getUpdateRecordList",
      masterPhysicalName: "getMasterName",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord",
      isEdited: "isEdited",
      hasValueColumn: "hasValueColumn",
      getCancelFacilityCd: "getCancelFacilityCd",
      getFacilitySwitch: "getFacilitySwitch",
      getComparisonRecordModel: "getComparisonRecordModel",
      masterRecordListRevision: "getMasterRecordListRevision",
      // add redmine 4485 施設マスタの並び順が変更 宋qy start
      isRecordModified: "isRecordModified"
      // add redmine 4485 施設マスタの並び順が変更 宋qy end

    }),
    ...mapGetters("mst-facility", {
      getMasterHashRecordList: "getMasterHashRecordList",
    }),

    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },
    ntssListStyles() {
      const display = this.columns.length === 1 ? "none" : "inherit";
      const height = `${this.kendoGridToolbarHeight}px`;
      return {
        display,
        height,
        maxHeight: height,
        position: "relative",
        overflow: "hidden"
      };
    },
    masterConditionSignature() {
      const condition = this.$store?.state?.["master-maintenance"]?.condition || this.condition || {};
      return `${condition.recordName || ""}|${condition.includeDeleted ? 1 : 0}`;
    },
    masterRecords() {
      // mod redmine 4485 computed内のsortRank呼び出しを廃止（表示順初期化はload時のみ。未編集時の破棄確認誤表示を防止）
      return this.getFilteredMasterRecordList;
    },
    isAllowAddRecord() {
      // allowAddRecordが定義されていない場合は追加ボタンは使用不可
      return !(this.getColumnIndex("allowAddRecord") < 0);
    },
    isAllowSort() {
      // allowSortが定義されていない場合は並び替えボタンは使用不可
      return !(this.getColumnIndex("allowSort") < 0);
    },
    isChanged() {
      void this.masterRecordListRevision;
      const data = this.getMasterRecordList.data;
      if (this.kendoValidator && !this.kendoValidator.validate()) {
        return true;
      }
      return (
        this.getStateUserAccountInfo !== null &&
        data !== undefined &&
        (this.isSorted || data.some(row => this.isMstFacilityRowEdited(row)))
      );
    },
    isAdminUser() {
      //管理者ならtrue/それ以外はfalse
      return 1 === this.getStateUserAccountInfo.administrator;
    },
    isCancelValue () {
      return [
          {
            "text": CONTRACTING_LABEL,
            "value": CONTRACTING
          },
          {
            "text": CANCEL_LABEL,
            "value": CANCEL
          },
          {
            "text": RESERVE_CANCEL_LABEL ,
            "value": RESERVE_CANCEL
          },
          {
            "text": CANCELING_LABEL,
            "value": CANCELING
          },
          {
            "text": CANCELED_LABEL,
            "value": CANCELED
          },
          {
            "text": CANCEL_STOP_LABEL,
            "value": CANCEL_STOP
          },
          {
            "text": REMS_CANCEL_LABEL,
            "value": REMS_CANCEL
          },
          {
            "text": RESERVE_REMS_CANCEL_LABEL,
            "value": RESERVE_REMS_CANCEL
          },
          {
            "text": REMS_CANCELING_LABEL,
            "value": REMS_CANCELING
          },
          {
            "text": REMS_CANCELED_LABEL,
            "value": REMS_CANCELED
          },
          {
            "text": FNSI_CANCEL_LABEL,
            "value": FNSI_CANCEL
          },
          {
            "text": RESERVE_FNSI_CANCEL_LABEL,
            "value": RESERVE_FNSI_CANCEL
          },
          {
            "text": FNSI_CANCELING_LABEL,
            "value": FNSI_CANCELING
          },
          {
            "text": FNSI_CANCELED_LABEL,
            "value": FNSI_CANCELED
          },
        ]
    },
    isExistsCanselingFacilities() {
      // add bug 8003 修正 chen start
      if (!this.masterRecords || !this.masterRecords.data) {
        return true;
      }
      // add bug 8003 修正 chen end
      // 削除中データが存在する場合、解約進捗列を表示
      return !this.masterRecords.data.some(item =>
        item.isCancel === CANCELING ||
        item.isCancel === REMS_CANCELING ||
        item.isCancel === FNSI_CANCELING
      )
    },
    isExistsCanseledFacilities() {
      // add bug 8003 修正 chen start
      if (!this.masterRecords || !this.masterRecords.data) {
        return true;
      }
      // add bug 8003 修正 chen end
      // 削除完了データが存在する場合、バックアップダウンロード、完全削除ボタン列を表示
      return !this.masterRecords.data.some(item =>
        item.isCancel === CANCELED ||
        item.isCancel === REMS_CANCELED ||
        item.isCancel === FNSI_CANCELED
      )
    },
    getCancelWidth() {
      // add bug 8003 修正 chen start
      if (!this.masterRecords || !this.masterRecords.data) {
        return "15em";
      }
      // add bug 8003 修正 chen end
      if (this.masterRecords.data.some(item =>
            item.isCancel === RESERVE_REMS_CANCEL ||
            item.isCancel === RESERVE_FNSI_CANCEL)) {
        return "20.5em";
      }
      else if (this.masterRecords.data.some(item =>
            item.isCancel === REMS_CANCELING ||
            item.isCancel === REMS_CANCELED ||
            item.isCancel === FNSI_CANCELING ||
            item.isCancel === FNSI_CANCELED)) {
        return "19em";
      }
      else if (this.masterRecords.data.some(item => item.isCancel === RESERVE_CANCEL)) {
        return "16em";
      }
      else if (this.masterRecords.data.some(item => item.isCancel === CANCELING)) {
        return "14em";
      } else {
        return "15em";
      }
    },
    getCancelledActionsWidth() {
      // add bug 8003 修正 chen start
      if (!this.masterRecords || !this.masterRecords.data) {
        return "3em";
      }
      // add bug 8003 修正 chen end
      if (this.masterRecords.data.some(item =>
            item.isCancel === CANCELED ||
            item.isCancel === REMS_CANCELED ||
            item.isCancel === FNSI_CANCELED)) {
        return "12em";
      }
      else {
        return "3em";
      }
    },
    isMobileDevice() {
      return this.iosFlg || this.androidFlg;
    }
  },
  watch: {
    // del #10438 施設マスタのシステム利用設定がすべてReMSへ勝手に変わる linjunfeng start
    // getMasterHashRecordList() {
    //   // #9863 Error in callback for watcher "getMasterHashRecordList": "TypeError: Cannot read properties of undefined (reading 'length')" 横展開2 linjunfeng start
    //   if (this.getMasterHashRecordList && this.getMasterHashRecordList.length !== 0) {
    //     // #9863 Error in callback for watcher "getMasterHashRecordList": "TypeError: Cannot read properties of undefined (reading 'length')" 横展開2 linjunfeng end
    //     this.addSystemUseSetting();
    //   }
    // },
    // del #10438 施設マスタのシステム利用設定がすべてReMSへ勝手に変わる linjunfeng end
    windowHeight() {
      this.scheduleDirectGridFontSizeRefresh();
    },
    windowWidth() {
      this.scheduleDirectGridFontSizeRefresh();
    },
    isDispMenu() {
      this.scheduleDirectGridFontSizeRefresh();
    },
    getFontSize() {
      this.scheduleDirectGridFontSizeRefresh();
    },
    masterConditionSignature() {
      this.scheduleDirectGridFilterRefresh();
    },
    columns(val) {
      this.$nextTick(() => {
        if (val && val.length > 1) {
          this.initDirectGridIfReady();
          this.applyDirectGridDataSourceContract();
          this.scheduleDirectGridLayoutContract();
          this.setLoadingScreenVisible(false);
        }
      });
    }
  },

  created() {
    this.setLoadingScreenVisible(true);
    // システム設定からメールテンプレートを取得
    ApiHelper.get("/mstInfo/sysSystemDefine/1")
      .then(response => {
        this.defaultMailTemplate = JSON.parse(response.data[0].value);
      })
      .catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('MstFacilityMainComponent.vue', 'created', error);
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        throw error;
      });

    this.calculateColumnsWidth();
    this.loadGridData();

    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    // 端末判別
    const ua = ((this?.$el?.ownerDocument?.defaultView?.navigator?.userAgent) || globalThis?.navigator?.userAgent || "").toLowerCase();
    if (/android/.test(ua)) {
      this.androidFlg = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.iosFlg = true;
    }
    this.selfScreenName = this.$route.name;
    EventBus.$on("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$on("refresh", this.refresh);
    this.clearCancelFacilityCd();
  },
  beforeUnmount() {
    EventBus.$off("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$off("refresh", this.refresh);
    EventBus.$off("clearScrollPosition", this.clearScrollPosition);
    this.destroyDirectGrid();
    [
      this.directGridLayoutRafId,
      this.directGridFilterRefreshRafId,
      this.directGridScrollSyncRafId
    ].forEach(id => {
      if (id != null) {
        cancelAnimationFrame(id);
      }
    });
    this.directGridRowVisualRafIds?.forEach?.(id => cancelAnimationFrame(id));
    this.directGridRowVisualRafIds?.clear?.();
    this.facilityRowSnapshots?.clear?.();
    this.cleanupDirectGridTemplateApps();
  },
  mounted() {
    this.directGridMounted = true;
    this.kendoValidator = { validate: () => this.validateDirectKendoGrid() };
    this.$nextTick(() => {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
      this.initDirectGridIfReady();
      this.scheduleDirectGridLayoutContract();
    });
    EventBus.$on("clearScrollPosition", this.clearScrollPosition);
  },
  updated() {
    if (this.isEditGrid) {
      this.restoreDirectGridScrollPosition();
      this.$nextTick(() => {
        this.restoreDirectGridScrollPosition();
        this.isEditGrid = false;
      });
    }
  },

  methods: {
    ...mapActions("multi-modal", [
      "showMasterEdit",
      "showFacilityMasterAuthFunction",
      "showFacilityMasterAdvancedSettings"
    ]),
    ...mapActions("master-maintenance", [
      "findRecordList",
      "setMasterRecordList",
      "edit",
      "setCondition",
      "setEditRecord",
      "editRecordBeEmpty",
      "clearCancelFacilityCd",
      "setComparisonRecordModel",
    ]),
    ...mapActions("mst-facility", [
      "findHashRecordList",
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      //add #10438 施設マスタのシステム利用設定がすべてReMSへ勝手に変わる 張玲 start
      startLoadingScreen:"startLoadingScreen",
      finishLoadingScreen:"finishLoadingScreen",
      //add #10438 施設マスタのシステム利用設定がすべてReMSへ勝手に変わる 張玲 end
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    ...mapActions("facility", ["setUseFunction"]),
    ...mapActions("account-edit", ["getUserAccountInfo"]),

    cancel() {
      this.$router.go(-1);
    },
    loadGridData() {
      this.findList();
    },
    getColumnIndex(fieldName) {
      return this.columns.findIndex(column => column.field === fieldName);
    },
    getGridHeaderEl() {
      return this.getDirectGridRoot()?.querySelector?.(".k-grid-header") || null;
    },
    getGridTableEl() {
      return this.directGridWidget?.table?.[0] || this.getDirectGridRoot()?.querySelector?.(".k-grid-content table") || null;
    },
    getGridTbodyEl() {
      return this.directGridWidget?.tbody?.[0] || this.getDirectGridRoot()?.querySelector?.(".k-grid-content tbody") || null;
    },
    getGridLockedBodyRows() {
      return Array.from(this.getDirectGridRoot()?.querySelectorAll?.(".k-grid-content-locked tbody tr") || []);
    },
    getGridDataSource() {
      return this.directGridWidget?.dataSource || this.directGridDataSource || { data: [] };
    },
    getGridScrollHostEl() {
      return this.getDirectGridScrollContent();
    },
    cacheGridScrollPosition(target = null) {
      const position = this.getGridScrollPosition();
      if (target && typeof target === "object") {
        target.top = position.top;
        target.left = position.left;
      }
      this.lastScrollTop = position.top;
      this.lastScrollLeft = position.left;
      return position;
    },
    storeDirectGridScrollPosition() {
      const position = this.getGridScrollPosition();
      this.scrollPosition.top = position.top;
      this.scrollPosition.left = position.left;
      this.lastScrollTop = position.top;
      this.lastScrollLeft = position.left;
    },
    restoreDirectGridScrollPosition() {
      const top = this.scrollPosition.top ?? this.lastScrollTop ?? 0;
      const left = this.scrollPosition.left ?? this.lastScrollLeft ?? 0;
      this.setGridScrollPosition({ top, left });
    },
    abortSaveScrollPreserve() {
      this.preserveGridScrollAfterSave = false;
      this.restoreDirectGridScrollPosition();
    },
    restoreSavedGridScrollAfterSave(clearFlag = false) {
      const savedScrollTop = this.scrollPosition.top ?? this.lastScrollTop ?? 0;
      const savedScrollLeft = this.scrollPosition.left ?? this.lastScrollLeft ?? 0;
      const restore = () => {
        this.setGridScrollPosition({ top: savedScrollTop, left: savedScrollLeft });
      };
      restore();
      this.$nextTick(() => {
        restore();
        requestAnimationFrame(() => {
          restore();
          this.scheduleDirectGridPostColumnScrollSync();
          if (clearFlag) {
            this.preserveGridScrollAfterSave = false;
          }
        });
      });
      [32, 80, 180].forEach(ms => setTimeout(restore, ms));
    },
    scheduleDirectGridPostColumnScrollSync() {
      if (this.directGridScrollSyncRafId != null) {
        cancelAnimationFrame(this.directGridScrollSyncRafId);
      }
      this.directGridScrollSyncRafId = requestAnimationFrame(() => {
        this.restoreDirectGridScrollPosition();
        this.directGridScrollSyncRafId = requestAnimationFrame(() => {
          this.directGridScrollSyncRafId = null;
          this.restoreDirectGridScrollPosition();
        });
      });
    },
    scheduleMasterGridScrollToAddedRow() {
      const apply = () => {
        const content = this.getDirectGridScrollContent();
        if (!content) {
          return;
        }
        const top = Math.max(Number(this.lastScrollTop || 0), Number(content.scrollHeight || 0));
        this.scrollPosition.left = 0;
        this.lastScrollLeft = 0;
        this.setGridScrollPosition({ top, left: 0 });
      };
      apply();
      this.$nextTick(() => {
        apply();
        requestAnimationFrame(apply);
        [0, 32, 80, 180].forEach(ms => setTimeout(apply, ms));
      });
    },
    calculateColumnsWidth() {
      const widthMap = [12, 14, 16, 18];
      this.columnWidth = widthMap[Number(this.getFontSize)] || 14;
    },
    calculateGridHeight() {
      if (this.editingFlg) {
        return;
      }
      const ownerDocument = this.$el?.ownerDocument || document;
      const ownerWindow = ownerDocument.defaultView || window;
      const headers = Array.from(ownerDocument.getElementsByClassName("header") || []);
      const header = headers.length ? headers[headers.length - 1] : null;
      const footerMenu = ownerDocument.getElementById("footer-menu");
      const headerHeight = header?.clientHeight || 0;
      const footerMenuHeight = (this.isDispMenu === 1 && footerMenu ? footerMenu.clientHeight : 0) + 5;
      const windowHeight = Number(this.windowHeight) || ownerWindow.innerHeight || 0;
      let toolbarHeight = windowHeight - headerHeight - footerMenuHeight;
      const list = this.$el?.querySelector?.(".ntss-list");
      const listTop = list?.getBoundingClientRect?.().top;
      const footerTop = this.isDispMenu === 1
        ? footerMenu?.getBoundingClientRect?.().top
        : ownerWindow.innerHeight;
      const actualListHeight = (Number.isFinite(listTop) && Number.isFinite(footerTop))
        ? footerTop - listTop - 5
        : Number.NaN;
      if (Number.isFinite(actualListHeight) && actualListHeight > 100) {
        toolbarHeight = Math.min(toolbarHeight, actualListHeight);
      }
      this.kendoGridToolbarHeight = Math.max(100, toolbarHeight);
      const gridHeader = this.$el?.querySelector?.(".header-btn-area");
      const gridFooter = this.$el?.querySelector?.("#grid-footer");
      const gridHeaderHeight = gridHeader?.clientHeight || 0;
      const gridFooterHeight = gridFooter?.clientHeight || 0;
      this.kendoGridHeight = Math.max(
        160,
        this.kendoGridToolbarHeight - gridHeaderHeight - gridFooterHeight - 2
      );
      const root = this.getDirectGridRoot?.();
      if (root) {
        root.style.height = `${this.kendoGridHeight}px`;
        root.style.maxHeight = `${this.kendoGridHeight}px`;
      }
    },
    editableColumns() {
      this.columns.forEach(column => {
        column.editable = column.field === "sortRank"
          ? () => false
          : column.originalEditable
            ? () => true
            : () => false;
      });
    },
    disableColumns() {
      this.columns.forEach(column => {
        column.editable = column.field === "sortRank"
          ? this.isAllowSort
            ? () => true
            : () => false
          : () => false;
      });
    },
    showSortColumn() {
      const sortRankIndex = this.columns.findIndex(column => column.field === "sortRank");
      if (sortRankIndex >= 0) {
        this.columns[sortRankIndex].hidden = !(this.isAllowSort && this.isSortMode);
        const dummyIndex = this.columns.findIndex(column => column.field === "dummy");
        if (dummyIndex >= 0) {
          this.columns[dummyIndex].hidden = !this.columns[sortRankIndex].hidden;
        }
      }
    },
    sort() {
      const compare = (a, b) => a.sortRank - b.sortRank || a.sortInputTime - b.sortInputTime;
      this.getMasterRecordList.data.sort(compare);
      for (let i = 0; i < this.getMasterRecordList.data.length; i++) {
        if (this.getMasterRecordList.data[i].isDisp === "1") {
          this.getMasterRecordList.data[i].sortRank = i + 1;
        }
      }
    },
    sortChange(tempData) {
      let flag = false;
      this.getMasterRecordList.data.forEach(item => {
        tempData.forEach(tempItem => {
          if (item.code === tempItem.code && item.sortRank !== tempItem.sortRank) {
            flag = true;
          }
        });
      });
      return flag;
    },
    normalization(items) {
      const columnNames = (this.columnDefinition || this.columns || []).map(column => column.field);
      return Object.keys(items || {})
        .filter(key => columnNames.includes(key) || key === "isAddRow")
        .reduce((acc, key) => {
          acc[key] = items[key];
          return acc;
        }, {});
    },
    getisChanged() {
      return this.isChanged;
    },
    editEnd() {
      this.editingFlg = false;
    },
    applyKendoSaveValuesToModel(ev) {
      const values = ev?.values && typeof ev.values === "object" && !Array.isArray(ev.values) ? ev.values : null;
      const model = ev?.model;
      if (!values || !model) {
        return false;
      }
      let applied = false;
      Object.keys(values).forEach(field => {
        if (model[field] == values[field]) {
          return;
        }
        try {
          if (typeof model.set === "function") {
            model.set(field, values[field]);
          } else {
            model[field] = values[field];
          }
          applied = true;
        } catch (_error) {
          model[field] = values[field];
          applied = true;
        }
      });
      return applied;
    },
    showMasterEditModal(e) {
      this.cacheGridScrollPosition(this.scrollPosition);
      this.showMasterEdit();
      e.preventDefault();
      const selectedRowItem = this.getDirectGridDataItemFromEvent(e);
      if (!selectedRowItem) {
        return;
      }
      const { code } = selectedRowItem;
      if (!code) {
        this.edit({ editRecord: selectedRowItem, isSortMode: this.isSortMode });
      }
      const normalizedItem = this.normalization(selectedRowItem);
      this.setEditRecord(normalizedItem);
    },
    onCloseMasterEditModal() {
      this.$nextTick(() => {
        this.setScrollPosition(this.scrollPosition);
      });
      setTimeout(() => {
        this.setScrollPosition(this.scrollPosition);
      }, 1000);
    },
    editBackgroundColor() {
      const grid = this.directGridWidget;
      if (!grid?.tbody) {
        return;
      }
      Array.from(grid.tbody.children() || []).forEach(row => {
        const dataItem = grid.dataItem(row);
        if (dataItem) {
          row.classList.toggle("master-edited-row", this.isMstFacilityRowEdited(dataItem));
        }
      });
    },
    getDirectGridRecordKey(record) {
      return record?.code != null ? String(record.code) : (record?.facilityCd ? `facility:${record.facilityCd}` : null);
    },
    stripMstFacilityCompareFields(record) {
      const plain = typeof record?.toJSON === "function" ? record.toJSON() : { ...(record || {}) };
      ["operation", "edited", "dirty", "dirtyFields", "uid", "skipSearch", "sortInputTime", "upDate", "dummy"].forEach(key => {
        delete plain[key];
      });
      Object.keys(plain).forEach(key => {
        if (plain[key] === "") {
          plain[key] = null;
        }
      });
      return plain;
    },
    findMstFacilityOriginalRecord(record) {
      const key = this.getDirectGridRecordKey(record);
      if (key && this.facilityRowSnapshots.has(key)) {
        return this.facilityRowSnapshots.get(key);
      }
      try {
        return JSON.parse(this.getComparisonRecordModel || "[]")
          .find(row => String(row.code) === String(record?.code)) || null;
      } catch {
        return null;
      }
    },
    isMstFacilityRowEdited(record) {
      if (!record) {
        return false;
      }
      const hasEditMark = Number(record?.operation || 0) > 0 || record?.edited === true;
      if (!hasEditMark) {
        return false;
      }
      if (Number(record?.operation) === 1) {
        return record?.edited === true;
      }
      const original = this.findMstFacilityOriginalRecord(record);
      if (!original) {
        return hasEditMark;
      }
      const current = this.stripMstFacilityCompareFields(record);
      const orig = this.stripMstFacilityCompareFields(original);
      const keys = new Set([...Object.keys(current), ...Object.keys(orig)]);
      for (const key of keys) {
        const a = current[key] == null || current[key] === "" ? null : current[key];
        const b = orig[key] == null || orig[key] === "" ? null : orig[key];
        if (a != b) {
          return true;
        }
      }
      return false;
    },
    clearMstFacilityRowIfMatchesOriginal(model) {
      if (!model || this.isMstFacilityRowEdited(model)) {
        return;
      }
      delete model.operation;
      model.edited = false;
      model.dirty = false;
      if (model.dirtyFields) {
        Object.keys(model.dirtyFields).forEach(key => delete model.dirtyFields[key]);
      }
      const data = this.getMasterRecordList?.data;
      if (Array.isArray(data)) {
        const target = data.find(row => String(row.code) === String(model.code));
        if (target) {
          delete target.operation;
          target.edited = false;
          target.dirty = false;
          if (target.dirtyFields) {
            Object.keys(target.dirtyFields).forEach(key => delete target.dirtyFields[key]);
          }
        }
      }
      this.$store.commit("master-maintenance/bumpMasterRecordListRevision");
    },

    validateDirectKendoGrid() {
      return true;
    },
    getDirectGridRoot() {
      return this.$refs.grid || null;
    },
    getGridWidget() {
      return this.directGridWidget || null;
    },
    getDirectGridScrollContent() {
      return this.getDirectGridRoot()?.querySelector?.(".k-grid-content") || null;
    },
    getDirectGridLockedScrollContent() {
      return this.getDirectGridRoot()?.querySelector?.(".k-grid-content-locked") || null;
    },
    getGridScrollPosition() {
      const content = this.getDirectGridScrollContent();
      return { top: content?.scrollTop || 0, left: content?.scrollLeft || 0 };
    },
    setGridScrollPosition(position = {}) {
      const content = this.getDirectGridScrollContent();
      if (!content) {
        return;
      }
      let appliedLeft;
      if (Number.isFinite(position.left)) {
        appliedLeft = position.left;
        content.scrollLeft = appliedLeft;
      }
      if (Number.isFinite(position.top)) {
        content.scrollTop = position.top;
        this.syncDirectGridLockedScrollPosition(position.top);
      }
      if (Number.isFinite(appliedLeft)) {
        const grid = this.getGridWidget();
        if (grid?.content?.[0]) {
          grid.content[0].scrollLeft = appliedLeft;
        }
        const headerWrap = this.getDirectGridRoot()?.querySelector?.(".k-grid-header-wrap");
        if (headerWrap) {
          headerWrap.scrollLeft = appliedLeft;
        }
        if (grid && typeof grid._scrollLeft !== "undefined") {
          grid._scrollLeft = appliedLeft;
        }
      }
      try {
        content.dispatchEvent(new Event("scroll", { bubbles: true }));
      } catch (_error) {
        // noop
      }
    },
    setScrollPosition(position = {}) {
      this.setGridScrollPosition(position);
    },
    calculateGridWidth() {
      this.resizeDirectGrid();
    },
    resizeDirectGrid() {
      const grid = this.directGridWidget;
      if (!grid) {
        return;
      }
      try {
        if (!this.preserveGridScrollAfterSave) {
          this.storeDirectGridScrollPosition();
        }
        grid.setOptions({ height: this.kendoGridHeight });
        grid.resize(true);
        this.applyDirectGridLockedWidthContract();
        this.applyDirectGridLockedHeightContract();
        // resize で Kendo が scrollLeft を 0 に戻すため、同一フレーム内で復元する。
        this.restoreDirectGridScrollPosition();
      } catch (_error) {
        // direct jq では resize 失敗時に追加 rebuild しない。
      }
    },
    getDirectGridDisplayDataSourceOption() {
      const source = this.masterRecords || this.getFilteredMasterRecordList || {};
      return {
        ...source,
        data: Array.isArray(source.data) ? source.data : []
      };
    },
    createDirectGridDataSource() {
      const sourceOption = this.getDirectGridDisplayDataSourceOption();
      this.directGridDataSource = markRaw(new kendo.data.DataSource(sourceOption));
      return this.directGridDataSource;
    },
    getDirectGridColumnSignature() {
      return (this.columns || []).map(column => [
        column.field,
        column.hidden === true ? 1 : 0,
        column.locked === true ? 1 : 0,
        column.width || "",
        column.title || ""
      ].join(":"))
        .join("|");
    },
    buildDirectGridColumns() {
      return (this.columns || []).map(column => {
        const gridColumn = { ...column };
        if (column.title === "緊急発報テンプレート") {
          gridColumn.attributes = { class: "btn3-kendo-normal" };
          gridColumn.command = { text: "編集", click: event => this.showMasterEditModal(event) };
          delete gridColumn.values;
        } else if (column.title === "拡張機能") {
          gridColumn.attributes = { class: "btn3-kendo-normal" };
          gridColumn.command = { text: "拡張機能", click: event => this.showMasterEditModalAdvancedSettings(event) };
          delete gridColumn.values;
        } else if (column.title === "許可機能設定") {
          gridColumn.attributes = { class: "btn3-kendo-normal" };
          gridColumn.command = { text: "設定", click: event => this.showMasterEditModalAuthFunctions(event) };
          delete gridColumn.values;
        } else if (column.field === "facilityCd") {
          gridColumn.editor = (container, options) => this.facilityCdEditor(container, options);
        } else if (column.field === "isDel") {
          gridColumn.editor = (container, options) => this.isDelEditor(container, options);
        } else if (column.field === "isCancel") {
          gridColumn.editor = (container, options) => this.isCancelEditor(container, options);
          gridColumn.width = this.getCancelWidth;
          gridColumn.values = this.isCancelValue;
        } else if (column.field === "cancelProgress") {
          gridColumn.title = "&nbsp";
          gridColumn.hidden = this.isExistsCanselingFacilities;
          gridColumn.width = "4em";
        } else if (column.field === "cancelledActions") {
          gridColumn.hidden = this.isExistsCanseledFacilities;
          gridColumn.width = this.getCancelledActionsWidth;
          gridColumn.template = dataItem => `<div class="mst-facility-cancel-action-host" data-uid="${escapeAttr(dataItem?.uid)}"></div>`;
          delete gridColumn.values;
        } else if (column.field === "cancelDate") {
          gridColumn.editor = (container, options) => this.cancelldateinp(container, options);
        }
        return gridColumn;
      });
    },
    initDirectGridIfReady() {
      const root = this.getDirectGridRoot();
      if (!this.directGridMounted || !root || !this.isSortChacked || this.columns.length <= 1) {
        return;
      }
      if (this.directGridWidget) {
        this.applyDirectGridColumnsContract();
        this.applyDirectGridDataSourceContract();
        this.scheduleDirectGridLayoutContract();
        return;
      }
      installComponentJQuery();
      $(root).empty();
      $(root).kendoGrid({
        dataSource: this.createDirectGridDataSource(),
        editable: true,
        selectable: true,
        reorderable: false,
        height: this.kendoGridHeight,
        scrollable: true,
        beforeEdit: event => this.facilityEditStart(event),
        edit: event => this.onDirectGridEdit(event),
        cellClose: event => this.editEnd(event),
        save: event => this.onDirectGridSave(event),
        dataBound: event => this.onDataBoundKendoGrid(event),
        columns: this.buildDirectGridColumns()
      });
      this.directGridWidget = markRaw($(root).data("kendoGrid"));
      this.directGridColumnSignature = this.getDirectGridColumnSignature();
      this.installDirectGridFacade();
      this.applyDirectGridLegacyStyleContract();
      this.scheduleDirectGridLayoutContract();
    },
    destroyDirectGrid() {
      this.cleanupDirectGridTemplateApps();
      if (this.directGridWidget) {
        try {
          this.directGridWidget.destroy();
        } catch (_error) {
          // noop
        }
      }
      const root = this.getDirectGridRoot();
      if (root) {
        $(root).empty();
      }
      this.directGridWidget = null;
      this.directGridDataSource = null;
      this.directGridColumnSignature = "";
    },
    installDirectGridFacade() {
      const root = this.getDirectGridRoot();
      if (!root) {
        return;
      }
      root.kendoWidget = () => this.directGridWidget;
      root.gridWidget = () => this.directGridWidget;
      root.gridRootEl = () => root;
      root.gridContentEl = () => this.getDirectGridScrollContent();
      root.gridAutoScrollableEl = () => this.getDirectGridScrollContent();
      root.gridScrollHostEl = () => this.getDirectGridScrollContent();
      root.gridLockedContentEl = () => this.getDirectGridLockedScrollContent();
      root.gridHeaderEl = () => root.querySelector(".k-grid-header") || null;
      root.gridHeaderWrapEl = () => root.querySelector(".k-grid-header-wrap") || null;
      root.gridTableEl = () => this.directGridWidget?.table?.[0] || root.querySelector(".k-grid-content table") || null;
      root.gridLockedTableEl = () => root.querySelector(".k-grid-content-locked table") || null;
      root.gridTbodyEl = () => this.directGridWidget?.tbody?.[0] || root.querySelector(".k-grid-content tbody") || null;
      root.gridLockedTbodyEl = () => root.querySelector(".k-grid-content-locked tbody") || null;
      root.gridSelectableTables = () => Array.from(root.querySelectorAll(".k-grid-content-locked table, .k-grid-content table"));
      root.gridDataItem = row => this.directGridWidget?.dataItem?.(row);
      root.gridDataSource = () => this.directGridWidget?.dataSource || this.directGridDataSource;
      root.gridColumns = () => this.directGridWidget?.columns || [];
      root.gridScrollPosition = () => this.getGridScrollPosition();
      root.scrollGridTo = position => this.setGridScrollPosition(position);
      root.setGridDataSource = dataSource => this.setDirectGridDataSource(dataSource);
    },
    setDirectGridDataSource(dataSource) {
      const grid = this.directGridWidget;
      const source = dataSource || this.masterRecords || this.getFilteredMasterRecordList || {};
      const option = {
        ...source,
        data: Array.isArray(source.data) ? source.data : []
      };
      if (!grid) {
        this.directGridDataSource = markRaw(new kendo.data.DataSource(option));
        return this.directGridDataSource;
      }
      try {
        grid.dataSource.data(option.data);
        this.directGridDataSource = markRaw(grid.dataSource);
      } catch (_error) {
        const nextDataSource = markRaw(new kendo.data.DataSource(option));
        grid.setDataSource(nextDataSource);
        this.directGridDataSource = nextDataSource;
      }
      this.$nextTick(() => {
        this.applyDirectGridLegacyStyleContract();
        this.mountFacilityCancelActionTemplates();
      });
      return this.directGridDataSource;
    },
    applyDirectGridColumnsContract() {
      const grid = this.directGridWidget;
      if (!grid) {
        return;
      }
      const nextSignature = this.getDirectGridColumnSignature();
      if (this.directGridColumnSignature === nextSignature) {
        return;
      }
      const position = this.getGridScrollPosition();
      this.cleanupDirectGridTemplateApps();
      grid.setOptions({ columns: this.buildDirectGridColumns() });
      this.directGridColumnSignature = nextSignature;
      this.$nextTick(() => {
        this.setGridScrollPosition(position);
        this.applyDirectGridLegacyStyleContract();
        this.mountFacilityCancelActionTemplates();
      });
    },
    scheduleDirectGridFilterRefresh() {
      if (!this.directGridWidget?.dataSource) {
        return;
      }
      if (this.directGridFilterRefreshRafId != null) {
        cancelAnimationFrame(this.directGridFilterRefreshRafId);
      }
      this.directGridFilterRefreshRafId = requestAnimationFrame(() => {
        this.directGridFilterRefreshRafId = null;
        this.applyDirectGridDataSourceContract(true);
      });
    },
    applyDirectGridDataSourceContract(resetScroll = false) {
      const grid = this.directGridWidget;
      if (!grid?.dataSource) {
        return;
      }
      const preservedScroll = !resetScroll ? {
        top: this.scrollPosition.top ?? this.lastScrollTop ?? 0,
        left: this.scrollPosition.left ?? this.lastScrollLeft ?? 0
      } : null;
      if (!resetScroll && !this.preserveGridScrollAfterSave) {
        this.storeDirectGridScrollPosition();
      }
      const sourceOption = this.getDirectGridDisplayDataSourceOption();
      try {
        grid.dataSource.data(sourceOption.data || []);
      } catch (_error) {
        return;
      }
      if (resetScroll) {
        this.setGridScrollPosition({ top: 0, left: 0 });
        this.lastScrollTop = 0;
        this.lastScrollLeft = 0;
        this.preserveGridScrollAfterSave = false;
      }
      this.$nextTick(() => {
        this.applyDirectGridLegacyStyleContract();
        this.mountFacilityCancelActionTemplates();
        this.editBackgroundColor();
        if (!resetScroll) {
          const scroll = preservedScroll || {
            top: this.scrollPosition.top ?? this.lastScrollTop ?? 0,
            left: this.scrollPosition.left ?? this.lastScrollLeft ?? 0
          };
          this.setGridScrollPosition(scroll);
          this.scheduleDirectGridPostColumnScrollSync();
        }
      });
    },
    gridDataRefresh() {
      this.applyDirectGridDataSourceContract();
    },
    applyDirectGridLockedWidthContract() {
      const root = this.getDirectGridRoot();
      if (!root || !this.directGridWidget) {
        return;
      }
      const lockedWidth = (this.columns || []).reduce((sum, column) => {
        if (!column.locked || column.hidden) {
          return sum;
        }
        const width = `${column.width || ""}`.trim();
        if (width.endsWith("em")) {
          const fontSize = parseFloat(getComputedStyle(root).fontSize || "16") || 16;
          return sum + parseFloat(width) * fontSize;
        }
        if (width.endsWith("px")) {
          return sum + parseFloat(width);
        }
        const numeric = parseFloat(width);
        return sum + (Number.isFinite(numeric) ? numeric : 0);
      }, 0);
      if (!lockedWidth) {
        return;
      }
      const px = `${Math.ceil(lockedWidth)}px`;
      root.querySelectorAll(".k-grid-header-locked,.k-grid-content-locked,.k-grid-header-locked table,.k-grid-content-locked table").forEach(element => {
        element.style.width = px;
        element.style.minWidth = px;
      });
      root.querySelectorAll(".k-grid-header-wrap,.k-grid-content").forEach(element => {
        element.style.marginLeft = "";
      });
    },
    applyDirectGridLockedHeightContract() {
      const content = this.getDirectGridScrollContent();
      const lockedContent = this.getDirectGridLockedScrollContent();
      if (!content || !lockedContent) {
        return;
      }
      lockedContent.style.height = `${content.clientHeight}px`;
      lockedContent.style.maxHeight = `${content.clientHeight}px`;
    },
    runLockedRowSync() {
      const root = this.getDirectGridRoot?.();
      if (!root) {
        return;
      }
      syncKendoGridLockedRowHeights(root);
    },
    applyDirectGridLegacyStyleContract() {
      const root = this.getDirectGridRoot();
      if (!root) {
        return;
      }
      root.classList.add("ntss-kendo-grid-legacy", "k-widget", "k-grid", "k-editable", "k-display-block");
      root.querySelectorAll("th").forEach(th => th.classList.add("k-header"));
      [
        ".k-grid-content tbody tr",
        ".k-grid-content-locked tbody tr"
      ].forEach(selector => {
        root.querySelectorAll(selector).forEach((tr, index) => {
          tr.classList.add("k-master-row");
          tr.classList.toggle("k-alt", index % 2 === 1);
        });
      });
      root.querySelectorAll(".k-grid-content tbody td, .k-grid-content-locked tbody td").forEach(td => td.classList.add("k-td", "k-table-td"));
      this.applyDirectGridLockedWidthContract();
      this.applyDirectGridLockedHeightContract();
      this.syncDirectGridLockedScrollPosition();
    },
    scheduleDirectGridLayoutContract() {
      if (!this.preserveGridScrollAfterSave) {
        this.storeDirectGridScrollPosition();
      }
      if (this.directGridLayoutRafId != null) {
        cancelAnimationFrame(this.directGridLayoutRafId);
      }
      this.directGridLayoutRafId = requestAnimationFrame(() => {
        this.resizeDirectGrid();
        this.applyDirectGridLegacyStyleContract();
        this.restoreDirectGridScrollPosition();
        this.directGridLayoutRafId = requestAnimationFrame(() => {
          this.directGridLayoutRafId = null;
          this.resizeDirectGrid();
          this.applyDirectGridLegacyStyleContract();
          this.restoreDirectGridScrollPosition();
          this.scheduleDirectGridPostColumnScrollSync();
        });
      });
    },
    scheduleDirectGridFontSizeRefresh() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
      this.applyDirectGridColumnsContract();
      this.scheduleDirectGridLayoutContract();
    },
    syncDirectGridLockedScrollPosition(scrollTop = null) {
      const lockedContent = this.getDirectGridLockedScrollContent();
      if (!lockedContent) {
        return;
      }
      const content = this.getDirectGridScrollContent();
      lockedContent.scrollTop = scrollTop !== null && scrollTop !== undefined ? scrollTop : (content?.scrollTop || 0);
    },
    scheduleDirectGridLockedScrollSync() {
      if (this.directGridScrollSyncRafId != null) {
        cancelAnimationFrame(this.directGridScrollSyncRafId);
      }
      this.directGridScrollSyncRafId = requestAnimationFrame(() => {
        this.directGridScrollSyncRafId = null;
        this.syncDirectGridLockedScrollPosition();
      });
    },
    cleanupDirectGridTemplateApps() {
      (this.directGridTemplateApps || []).forEach(app => {
        try {
          app.unmount?.();
        } catch (_error) {
          // noop
        }
      });
      this.directGridTemplateApps = markRaw([]);
    },
    mountFacilityCancelActionTemplates() {
      const root = this.getDirectGridRoot();
      const grid = this.directGridWidget;
      if (!root || !grid) {
        return;
      }
      this.cleanupDirectGridTemplateApps();
      root.querySelectorAll(".mst-facility-cancel-action-host").forEach(host => {
        const row = host.closest("tr");
        const rowData = grid.dataItem(row);
        if (!rowData) {
          return;
        }
        const isActionTemplate = rowData.isCancel && !(rowData.isCancel == CANCELED || rowData.isCancel === REMS_CANCELED || rowData.isCancel === FNSI_CANCELED);
        const app = createApp(CancelActionTemplate, {
          templateArgs: {
            parentComponent: this,
            rowData,
            isActionTemplate: !rowData.facilityCd ? true : isActionTemplate,
          }
        });
        this.directGridTemplateApps.push(markRaw(app));
        app.mount(host);
      });
    },
    onDirectGridSave(event) {
      this.storeDirectGridScrollPosition();
      this.editingFlg = false;
      this.applyKendoSaveValuesToModel?.(event);
      const model = event?.model;
      if (!model) {
        return;
      }
      if (model.operation === 1) {
        model.edited = true;
      }
      this.edit({ editRecord: model, isSortMode: this.isSortMode });
      this.clearMstFacilityRowIfMatchesOriginal(model);
      this.$nextTick(() => {
        this.mountFacilityCancelActionTemplates();
        this.editFacilityCancel();
        this.restoreDirectGridScrollPosition();
      });
      this.scheduleDirectGridCurrentRowVisual(model);
    },
    scheduleDirectGridCurrentRowVisual(record) {
      const rowKey = record?.uid || record?.code || record?.facilityCd;
      if (!rowKey) {
        return;
      }
      const oldId = this.directGridRowVisualRafIds.get(rowKey);
      if (oldId != null) {
        cancelAnimationFrame(oldId);
      }
      const rafId = requestAnimationFrame(() => {
        this.directGridRowVisualRafIds.delete(rowKey);
        this.applyDirectGridRowVisual(record);
      });
      this.directGridRowVisualRafIds.set(rowKey, rafId);
    },
    applyDirectGridRowVisual(record) {
      const root = this.getDirectGridRoot();
      if (!root || !record?.uid) {
        return;
      }
      root.querySelectorAll(`tr[data-uid="${record.uid}"]`).forEach(row => {
        const edited = this.isMstFacilityRowEdited(record);
        row.classList.toggle("master-edited-row", edited);
        if (!edited) {
          row.classList.remove("k-dirty-row");
          Array.from(row.children || []).forEach(cell => {
            cell.classList.remove("k-dirty-cell", "master-edited-cell");
            cell.querySelectorAll(".k-dirty").forEach(marker => marker.remove());
          });
        }
      });
    },
    getDirectGridDataItemFromEvent(event) {
      const row = event?.currentTarget?.closest?.("tr");
      return this.directGridWidget?.dataItem?.(row) || null;
    },
    syncDirectGridSortRankToMasterRecords() {
      const gridData = this.directGridWidget?.dataSource?.data?.() || [];
      const masterData = this.getMasterRecordList?.data || [];
      gridData.forEach(item => {
        const target = masterData.find(record =>
          (item.code != null && record.code === item.code) ||
          (item.facilityCd != null && record.facilityCd === item.facilityCd)
        );
        if (target) {
          target.sortRank = Number(item.sortRank);
          if (item.sortInputTime != null) {
            target.sortInputTime = item.sortInputTime;
          }
        }
      });
    },
    toRankEditBtnClick() {
      this.cacheGridScrollPosition(this.scrollPosition);
      EventBus.$emit('onCloseMasterEditModal', this.onCloseMasterEditModal);
      if (!this.kendoValidator.validate()) {
        return;
      }
      this.isSortMode = true;
      this.disableColumns();
      this.showSortColumn();
      EventBus.$emit('setSortMode', this.isSortMode);
      this.$nextTick(() => {
        this.applyDirectGridColumnsContract();
        this.scheduleDirectGridLayoutContract();
        this.scheduleDirectGridLockedScrollSync();
        this.calculateGridWidth();
      });
    },
    sortBtnClick() {
      this.cacheGridScrollPosition(this.scrollPosition);
      EventBus.$emit('onCloseMasterEditModal', this.onCloseMasterEditModal);
      const tempData = deepCopy(this.getMasterRecordList.data);
      this.syncDirectGridSortRankToMasterRecords();
      this.isSortMode = false;
      this.editableColumns();
      this.showSortColumn();
      this.sort();
      this.isSorted = this.sortChange(tempData);
      EventBus.$emit('setSortMode', this.isSortMode);
      this.$nextTick(() => {
        this.applyDirectGridColumnsContract();
        this.applyDirectGridDataSourceContract();
        this.scheduleDirectGridLayoutContract();
        this.scheduleDirectGridLockedScrollSync();
        this.calculateGridWidth();
      });
    },

    // add redmine 4485 施設マスタの並び順が変更 宋qy start
    /**
     * @description 施設マスタの並び順が変更
     */
    sortRank(){
      const rows = this.getMasterRecordList?.data;
      if (!rows?.length) {
        return;
      }
      for (let i = 0; i < rows.length; i++) {
        if (rows[i].sortRank === null) {
          rows[i].sortRank = i + 1;
        }
      }
    },
    // add redmine 4485 施設マスタの並び順が変更 宋qy end

    /**
     * @description 施設コード列のkendo editor
     */
    facilityCdEditor(container, data) {
      // add 追加時に編集可能、他の状態は編集できません 宋qy start
      if (data.model.operation === 1) {
      // add 追加時に編集可能、他の状態は編集できません 宋qy end

        // 新規レコードは編集可なのでinput
        $(
          `<input class="k-textbox" name="${data.field}" maxlength="6" />`
        ).appendTo(container);
      } else {
        // 編集不可時でもeditStart()が発火するため、ここでフラグをoffにする
        this.editingFlg = false;
        // 既存レコードはlabelにして編集させない
        $(`<label>${data.model.facilityCd}</label>`).appendTo(container);
      }
    },
    //#10715:日付IF修正Start
    cancelldateinp(container, data) {
      if (this.androidFlg === true) {
        $(`<input type="date" name="${data.field}" />`).appendTo(container);
      } else {
        let moveOutFlg = false;
        container.mouseenter(() => (moveOutFlg = false));
        container.mouseleave(() => (moveOutFlg = true));
        let nowData;
        let hasInitValue = true;
        const editedData = data.model[data.field];
        let nowDtatString;
        if (editedData) {
          nowData = new Date(editedData);
        } else {
          nowData = new Date();
          hasInitValue = false;
        }
        nowDtatString =
          nowData.getFullYear() +
          "-" +
          ("0" + (nowData.getMonth() + 1)).slice(-2) +
          "-" +
          ("0" + nowData.getDate()).slice(-2);
        if (!editedData) {
          nowDtatString = "";
        }
        //#10715：日付IF修正20240910検証NG対応：村上Start
        $(
        `<span style="position:relative"><input type="date" style="width:8em" id="displayedDummyEditor" class="ntss-input-date" min="1880-01-01" max="2099-12-31" value="${nowDtatString}"/><input type="date" id="hiddenDateInputEditor" name="${data.field}" style="display: none;" /><span id="clear" class="k-icon k-i-close close-btn" title="clear" style="position:absolute;left:75%;top:-1px;color: #212529;z-index:9999999" ></span></span>`).appendTo(container);
        const editorRoot = container?.[0] || container?.get?.(0) || null;
        const editorDocument = editorRoot?.ownerDocument || this.$el?.ownerDocument || document;
        const getEditorElement = (selector) => editorRoot?.querySelector?.(selector) || editorDocument.querySelector(selector);
        const displayedDummyEditor = getEditorElement("#displayedDummyEditor");
        const hiddenDateInputEditor = getEditorElement("#hiddenDateInputEditor");
        const clearButton = getEditorElement("#clear");
        const gridWidget = this.directGridWidget;
        //#10715：日付IF修正20240910検証NG対応：村上End
        // フォーカスアウトで編集データを反映するイベントを発火
        displayedDummyEditor?.addEventListener("blur", function (ev) {
            if (!moveOutFlg) {
              return;
            }

            let resultData;
            const dayData = new Date(ev.target.value);

            // 初期と編集後の値が空欄の場合、更新レコードとして判断しない
            if (ev.target.value === "" && !hasInitValue) {
              resultData = "";
              nowDtatString = "";
              hasInitValue = true;
            } else {
              resultData =
                dayData.getFullYear() +
                "-" +
                ("0" + (dayData.getMonth() + 1)).slice(-2) +
                "-" +
                ("0" + dayData.getDate()).slice(-2);
            }

            // 変更前の値と比較し、同じ値の場合は処理しない。又は、初期値がない場合、必ず処理する。
            if (!hasInitValue || nowDtatString != resultData) {
              hiddenDateInputEditor.value = resultData;
              // name="${data.field}" で割り当てた箇所に付与されているchangeメソッドを発火します。次いで@saveの処理が発生します。
              $(hiddenDateInputEditor).trigger(
                "change");
              gridWidget?.closeCell?.();
            }
          });

        const commonCalenderMountNode = editorDocument.createElement("span");
        container.append(commonCalenderMountNode);
        const commonCalenderApp = createApp(commonCalender, {
          onInput: value => {
            hiddenDateInputEditor.value = value;
            $(hiddenDateInputEditor).trigger("change");
            gridWidget?.closeCell?.();
          }
        });
        let commonCalenderPicker = commonCalenderApp.mount(commonCalenderMountNode);
        commonCalenderPicker.setSilently(nowDtatString);
        const userAgent = ((this?.$el?.ownerDocument?.defaultView?.navigator?.userAgent) || globalThis?.navigator?.userAgent || "");
        if (userAgent.indexOf("Intel Mac OS") > -1) {
           displayedDummyEditor?.addEventListener("change", (ev) => {
           hiddenDateInputEditor.value = ev.target.value;
           $(hiddenDateInputEditor).trigger('change');
           gridWidget?.closeCell?.();
        });
        }else{
          displayedDummyEditor?.addEventListener("change", (ev) => {
              commonCalenderPicker.setSilently(ev.target.value);
        });
        }
        clearButton?.addEventListener("mousedown", function(ev) {
          hiddenDateInputEditor.value = null;
          $(hiddenDateInputEditor).trigger('change');
          gridWidget?.closeCell?.();
        });
        clearButton?.addEventListener("touchstart", function(ev) {
          hiddenDateInputEditor.value = null;
          $(hiddenDateInputEditor).trigger('change');
          gridWidget?.closeCell?.();
        });
      }
    },
    //#10715:日付IF修正End
    /**
     * @description 削除列のkendo editor
     */
    isDelEditor(container, data) {
      if (data.model.operation === 1) {
        // 編集不可時でもeditStart()が発火するため、ここでフラグをoffにする
        this.editingFlg = false;
        // 新規レコードはlabelにして編集させない
        $(`<label></label>`).appendTo(container);
      } else {
        // 既存レコードは編集可
        $(`<input name="${data.field}" />`).appendTo(container).kendoDropDownList({
          className: "k-textbox",
          dataSource: [
            { text: "", value: "0" },
            { text: "削除", value: "1" }
          ],
          dataTextField: "text",
          dataValueField: "value",
          value: data.model[data.field]
        });
      }
    },
    /**
     * @description 解約列のkendo editor
     */
    isCancelEditor(container, data) {
      if (data.model.operation === 1) {
        // 編集不可時でもeditStart()が発火するため、ここでフラグをoffにする
        this.editingFlg = false;
        // 新規レコードはlabelにして編集させない
        $(`<label></label>`).appendTo(container);
      } else {
        // 既存レコードは編集可
        switch(data.model.isCancel){
          case CONTRACTING :
          case CANCEL:
          case REMS_CANCEL:
          case FNSI_CANCEL: {
            let dataSource = [
              { text: CONTRACTING_LABEL, value: CONTRACTING },
              { text: CANCEL_LABEL, value: CANCEL }
            ]
            // ハッシュ情報から該当施設のレコードを取得(data.modelから取得すると編集されている場合がある為)
            const facilityHash = this.getMasterHashRecordList.find(hash => hash.facilityCd === data.model.facilityCd)

            // FNSi+ReMSの場合、ReMSのみ解約・FNSiのみ解約を選択肢に追加する
            if (facilityHash && facilityHash.systemUseSetting === SYS_USE_TYPE.REMS_AND_FNSI) {
              dataSource.push(
                { text: REMS_CANCEL_LABEL, value: REMS_CANCEL },
                { text: FNSI_CANCEL_LABEL, value: FNSI_CANCEL })
            }

            const cancelManage = this.mntFacilityCancelManageList.find(item => {
              return item.facilityCd === data.model.facilityCd
            })

            // ReMSのみ解約・FNSiのみ解約が削除完了している場合のみ、全解約を選択可能とする
            if (cancelManage && cancelManage.procStatus === PROC_STATUS_COMPLETED &&
                (cancelManage.procClass === PROC_CLASS_REMS_CANCEL || cancelManage.procClass === PROC_CLASS_FNSI_CANCEL))
            {
              // 施設解約管理：処理区分に応じて選択肢を変更する
              switch(cancelManage.procClass) {
                case PROC_CLASS_REMS_CANCEL :
                  dataSource = [
                    { text: REMS_CANCELED_LABEL, value: REMS_CANCELED },
                    { text: CANCEL_LABEL, value: CANCEL }
                  ]
                  break;
                case PROC_CLASS_FNSI_CANCEL :
                  dataSource = [
                    { text: FNSI_CANCELED_LABEL, value: FNSI_CANCELED },
                    { text: CANCEL_LABEL, value: CANCEL }
                  ]
                  break;
              }
            }

            $(`<input name="${data.field}" />`).appendTo(container).kendoDropDownList({
              className: "k-textbox",
              dataSource: dataSource,
              dataTextField: "text",
              dataValueField: "value",
              value: data.model[data.field]
            });
            break;
          }
          case RESERVE_CANCEL :
          case RESERVE_REMS_CANCEL :
          case RESERVE_FNSI_CANCEL :
          case CANCEL_STOP: {

            let dataSource = [
              { text: CANCEL_STOP_LABEL, value: CANCEL_STOP }
            ]
            const cancelManage = this.mntFacilityCancelManageList.find(item => {
              return item.facilityCd === data.model.facilityCd
            })
            // 施設解約管理：処理区分に応じて選択肢を変更する
            switch(cancelManage.procClass) {
              case PROC_CLASS_CANCEL :
                dataSource.unshift({ text: RESERVE_CANCEL_LABEL, value: RESERVE_CANCEL })
                break;
              case PROC_CLASS_REMS_CANCEL :
                dataSource.unshift({ text: RESERVE_REMS_CANCEL_LABEL, value: RESERVE_REMS_CANCEL })
                break;
              case PROC_CLASS_FNSI_CANCEL :
                dataSource.unshift({ text: RESERVE_FNSI_CANCEL_LABEL, value: RESERVE_FNSI_CANCEL })
                break;
            }

            $(`<input name="${data.field}" />`).appendTo(container).kendoDropDownList({
              className: "k-textbox",
              dataSource: dataSource,
              dataTextField: "text",
              dataValueField: "value",
              value: data.model[data.field]
            });
            break;
          }
          case CANCELING :
            $(`<label>` + CANCELING_LABEL + `</label>`).appendTo(container);
            break;
          case CANCELED :
            $(`<label>` + CANCELED_LABEL + `</label>`).appendTo(container);
            break;
          case REMS_CANCELING :
            $(`<label>` + REMS_CANCELING_LABEL + `</label>`).appendTo(container);
            break;
          case FNSI_CANCELING :
            $(`<label>` + FNSI_CANCELING_LABEL + `</label>`).appendTo(container);
            break;
          case REMS_CANCELED :
            $(`<input name="${data.field}" />`).appendTo(container).kendoDropDownList({
              className: "k-textbox",
              dataSource: [
                { text: REMS_CANCELED_LABEL, value: REMS_CANCELED },
                { text: CANCEL_LABEL, value: CANCEL }
              ],
              dataTextField: "text",
              dataValueField: "value",
              value: data.model[data.field]
            });
            break;
          case FNSI_CANCELED :
            $(`<input name="${data.field}" />`).appendTo(container).kendoDropDownList({
              className: "k-textbox",
              dataSource: [
                { text: FNSI_CANCELED_LABEL, value: FNSI_CANCELED },
                { text: CANCEL_LABEL, value: CANCEL }
              ],
              dataTextField: "text",
              dataValueField: "value",
              value: data.model[data.field]
            });
            break;
          default :
            $(`<label></label>`).appendTo(container);
            break;
        }
      }
    },

    // 解約：データ削除中の進捗率を計算
    getCancelProgress(stats) {
      try {
        if (stats) {
          const arrStats = JSON.parse(stats);
          if (arrStats) {
            let allTables = 0;
            let allProgress = 0;

            arrStats.forEach(table => {
              allTables += 1;
              const isBackup = table.end || table.backup_end ? 1 : 0;
              let amount = table.amount !== undefined  ? table.amount : 1;
              let deleted = table.deleted !== undefined ? table.deleted : 0;

              if (amount === 0 && deleted === 0) {
                amount = 1;
                deleted = 1;
              }
              // テーブルごとの進捗率を計算する(バックアップ及び、全レコード削除で1がプラスされる)
              allProgress += (isBackup + (deleted / amount)) / 2;
            })
            // 全進捗率/全テーブル×100
            const progress = Math.floor(allProgress / allTables * 100)
            return progress + "%";
          }
        }
        // 統計情報が登録されていない場合、0%を返す
        return "0%";
      } catch (error) {
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('MstFacilityMainComponent.vue', 'getCancelProgress', error);
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        return "0%";
      }

    },
    editFacilityCancel() {
      this.$nextTick(() => {
        // グリッドが表示されていない、またはダミーデータの場合は処理終了
        const gridHeader = this.getGridHeaderEl();
        if (
          !gridHeader ||
          gridHeader.textContent === " " ||
          gridHeader.textContent === "code"
        ) {
          return;
        }
        gridHeader?.classList?.add("master-grid-header");

        // 列が存在しない場合は処理しない
        if (this.getGridTableEl()?.tBodies != null) {
          const tbodyc = this.getGridTbodyEl()
            .children;
          const lockTbodyc = this.getGridLockedBodyRows();
          const dataSource = this.getGridDataSource();
          const gridData = typeof dataSource?.data === "function"
            ? Array.from(dataSource.data() || [])
            : (Array.isArray(dataSource?.data) ? dataSource.data : []);
          const cancelActionColumnIndex = (this.columns || []).findIndex(column => column.field === "cancelledActions");
          const cancelDateColumnIndex = (this.columns || []).findIndex(column => column.field === "cancelDate");
          const cancelProgressColumnIndex = (this.columns || []).findIndex(column => column.field === "cancelProgress");
          // add #9590 start
          if (!gridData.length) {
            return;
          }
          // add #9590 ends
          // 施設が解約中であるか
          const isCancelingFacility = gridData.some((dataRow) => {
            return dataRow.isCancel === CANCELING ||
                   dataRow.isCancel === REMS_CANCELING ||
                   dataRow.isCancel === FNSI_CANCELING
          });

          gridData.forEach((dataRow, index) => {
            const rowCells = tbodyc?.[index]?.children;
            const actionCell = cancelActionColumnIndex >= 0 ? rowCells?.[cancelActionColumnIndex] : null;
            const dateCell = cancelDateColumnIndex >= 0 ? rowCells?.[cancelDateColumnIndex] : null;
            const progressCell = cancelProgressColumnIndex >= 0 ? rowCells?.[cancelProgressColumnIndex] : null;
            const nextCell = cancelProgressColumnIndex >= 0 ? rowCells?.[cancelProgressColumnIndex + 1] : null;
            const actionRoot = actionCell?.children?.[0] || null;
            // 解約が選択されたとき、及び予約済のみ解約日の編集を可能にする
            if (
              dataRow.isCancel === CANCELING || dataRow.isCancel === CANCELED ||
              dataRow.isCancel === REMS_CANCELING || dataRow.isCancel === REMS_CANCELED ||
              dataRow.isCancel === FNSI_CANCELING || dataRow.isCancel === FNSI_CANCELED
            ) {
              if (dateCell) {
                dateCell.style.pointerEvents = "none";
              }
            }

            // 全解約の場合は赤背景にする
            if (dataRow.isCancel === CANCEL || dataRow.isCancel === RESERVE_CANCEL || dataRow.isCancel === CANCELING || dataRow.isCancel === CANCELED) {
              tbodyc[index].style.backgroundColor = "#ff6666";
              lockTbodyc[index].style.backgroundColor = "#ff6666";
            }
            // 解約済：データ削除完了以外のダウンロードボタン・完全削除ボタンを非表示にする
            if (dataRow.isCancel !== null && dataRow.isCancel !== CANCELED && dataRow.isCancel !== REMS_CANCELED && dataRow.isCancel !== FNSI_CANCELED) {
              // redmine 施設マスタF12エラー 宋qy start
              if (actionRoot !== null &&
                  actionRoot !== "" &&
                  actionRoot !== undefined) {
              // redmine 施設マスタF12エラー 宋qy end
                actionRoot.style.display = "none";
              }
            }

            // 全解約済み：データ削除完了のデータ削除ボタンを非表示にする
            if (dataRow.isCancel === CANCELED) {
              // redmine 施設マスタF12エラー 宋qy start
              if (actionRoot !== null &&
                  actionRoot !== "" &&
                  actionRoot !== undefined) {
              // redmine 施設マスタF12エラー 宋qy end
                if (actionRoot.children?.[2]) {
                  actionRoot.children[2].style.display = "none";
                }
              }
            }

            // ReMSのみ解約済・FNSiのみ解約：データ削除完了の完全削除ボタンを非表示にする
            if (dataRow.isCancel === REMS_CANCELED || dataRow.isCancel === FNSI_CANCELED) {
              // redmine 施設マスタF12エラー 宋qy start
              if (actionRoot !== null &&
                  actionRoot !== "" &&
                  actionRoot !== undefined) {
              // redmine 施設マスタF12エラー 宋qy end
                if (actionRoot.children?.[1]) {
                  actionRoot.children[1].style.display = "none";
                }
              }
            }
            // 解約進捗率列のスタイルを設定（結合）
            if (isCancelingFacility) {
              if (progressCell) {
                progressCell.style.cssText += "padding-right: 0 !important;";
              }
              if (nextCell) {
                nextCell.style.cssText += "border-left: 0 !important;padding-left: 0 !important; font-weight:bold;";
              }
              const headerProgressCell = cancelProgressColumnIndex >= 0 ? gridHeader.lastChild.firstChild.lastChild.firstChild.children[cancelProgressColumnIndex] : null;
              const headerNextCell = cancelProgressColumnIndex >= 0 ? gridHeader.lastChild.firstChild.lastChild.firstChild.children[cancelProgressColumnIndex + 1] : null;
              if (headerProgressCell) {
                headerProgressCell.style.cssText += "border-right: 0 !important;";
              }
              if (headerNextCell) {
                headerNextCell.style.cssText += "border-left: 0 !important;";
              }
            }
          });
        }
      });
    },
    refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      if (this.selfScreenName === this.$route.name
        && getScopedAlertDialogs(this.$el || this).length === 0) {
        if (this.getisChanged()) {
          this.$ons.notification.confirm({
            // title: "内容破棄",
            title: DIALOG_MESSAGES[13000004].title,
            // message: "編集内容が破棄されます。</br>よろしいですか？",
            message: messageFormat(DIALOG_MESSAGES[13000004].message),
            callback: answer => {
              if (answer === 1) {
                //スクロールバーの位置をクリア
                this.clearScrollPosition();
                this.findList();
              }
            },
          });
        }
        else {
          //スクロールバーの位置をクリア
          this.clearScrollPosition();
          this.findList();
        }
      }
    },
    /**
     * @description スクロールバーの位置をクリアする
    */
    clearScrollPosition() {
      this.scrollPosition.top = 0;
      this.scrollPosition.left = 0;
    },
    // マスタ一覧のデータを取得
    async findList() {
      // #10438 施設マスタのシステム利用設定がすべてReMSへ勝手に変わる linjunfeng start
      this.startLoadingScreen();
      this.columns =  [
        {
          field: "code",
          title: "code",
          hidden: false,
          editable: () => true,
          values: null
        }
      ];
      // apiをコールして値を取得
      // this.findRecordList()
      return Promise.all([
        ApiHelper.get("/facilities/MntFacilityCancelManage/SelectAll"),
        this.findHashRecordList(),
        this.findRecordList(),
      ])
      // #10438 施設マスタのシステム利用設定がすべてReMSへ勝手に変わる linjunfeng end
        .then(response => {
          // カラム情報のJSONが未定義の場合には、ダイアログを出して画面を閉じる
          // #10438 施設マスタのシステム利用設定がすべてReMSへ勝手に変わる linjunfeng start
          // if (response.data.columns.length === 0) {
          if (response[2].data.columns.length === 0) {
            // #10438 施設マスタのシステム利用設定がすべてReMSへ勝手に変わる linjunfeng end
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message:
              //   "マスタ定義にカラム情報が登録されていません。<BR>カラム情報を登録してください。",
              title: DIALOG_MESSAGES[12000001].title,
              message: messageFormat(DIALOG_MESSAGES[12000001].message),
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              callback: () => {
                this.cancel();
              }
            });
          }
          // editableをKendoUI用にfunctionオブジェクトに変換
          // #10438 施設マスタのシステム利用設定がすべてReMSへ勝手に変わる linjunfeng start
          // const toFunction = response.data.columns;
          const toFunction = response[2].data.columns;
          // #10438 施設マスタのシステム利用設定がすべてReMSへ勝手に変わる linjunfeng end
          toFunction.forEach(column => {
            // 初期表示時の編集可否を退避
            column.originalEditable = column.editable;
            // 編集可否を関数化
            column.editable = column.editable ? () => true : () => false;
            // 列幅初期化
            column.width = column.width ? column.width : "0";
            if(!this.isAdminUser){
              //一般ユーザーの場合：都道府県／部署符号／緊急発報テンプレート／データ収集開始時刻のみ操作可
              column.editable = () => false;
              if(column.field == "prefecturesCd" || column.field == "departmentCd"|| column.field == "autoGatheringStartTime"){
                column.editable = () => true;
              }
            }
          });
          this.columns = toFunction;

          // 横スクロールバーを表示するために列幅を指定
          this.columns.forEach(column => {
            // 「削除」のプルダウンが改行しない幅に調整
            // mod #7289-マスタの削除ボタンが縦表示になる 徐博 start
            // column.width = column.field === "isDisp" ? "8em" : (this.columnWidth + "em");
            column.width = column.field === "isDisp" ? "9em" : (this.columnWidth + "em");
            // mod #7289-マスタの削除ボタンが縦表示になる 徐博 end
            // #9185 最小フォント、mst画面編集文字、テキストボックス幅を超えます linjunfeng start
            // #8612 ウィンドウサイズの変更で、マスタレイアウトが崩れる。林峻峰 start
            // if (column.locked && column.dataType === "string" && column.field === "name") {
            //   column.width = typeof column.width == 'string' ? Number(column.width.slice(0,-2)) * 15 : column.width * 15
            // }
            // #8612 ウィンドウサイズの変更で、マスタレイアウトが崩れる。林峻峰 end
            // #9185 最小フォント、mst画面編集文字、テキストボックス幅を超えます linjunfeng end
          });

          // 先頭列ダミー要素追加（並び順列の変更内容が"かぶって"表示されてしまう事象の対応のため）
          this.columns.unshift({
            title: " ",
            field: "dummy",
            hidden: false,
            locked: true,
            editable: () => false,
            width: "10px",
            format: "",
            values: null
          });
          // システム利用設定の列追加
          const listIndex = this.columns.findIndex(({field}) => field === "mNoticeMailTemplate");
          this.columns.splice(listIndex, 0, {
            dataType: "combo1",
            title: "システム利用設定",
            field: "systemUseSetting",
            hidden: false,
            editable: this.isAdminUser ? () => true : () => false,
           // add #10438 施設マスタのシステム利用設定がすべてReMSへ勝手に変わる linjunfeng start
            originalEditable: true,
            // add #10438 施設マスタのシステム利用設定がすべてReMSへ勝手に変わる linjunfeng end
            width: "14em",
            format: "",
            values: [
              {
                "text": "ReMS",
                "value": "1"
              },
              {
                "text": "FNSi",
                "value": "2"
              },
              {
                "text": "FNSi+ReMS",
                "value": "3"
              }
            ]
          });
          // 一般ユーザーの場合：削除機能を削除
          if(!this.isAdminUser){
            const checkField = this.columns.findIndex(({field}) => field === "isDel");
            this.columns.splice(checkField,1);
          }
          // カラム幅等初期調整
          this.showSortColumn();
          this.$nextTick(() => {
            this.calculateGridHeight();
            this.calculateGridWidth();
            if (this.preserveGridScrollAfterSave) {
              this.restoreSavedGridScrollAfterSave();
            }
          });
          // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen start
          this.backupMasterRecordList = deepCopy(this.getMasterRecordList);
          // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen end
          // #10438 施設マスタのシステム利用設定がすべてReMSへ勝手に変わる linjunfeng start
          this.mntFacilityCancelManageList = response[0].data;
          this.setIsCancel();
          this.addSystemUseSetting();
          this.finishLoadingScreen();
          // #10438 施設マスタのシステム利用設定がすべてReMSへ勝手に変わる linjunfeng end
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstFacilityMainComponent.vue', 'findList', error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        });

    },
    // add #10438 施設マスタのシステム利用設定がすべてReMSへ勝手に変わる linjunfeng start
    setIsCancel() {
      let editData = this.getFilteredMasterRecordList.data;

      // 表示用にシステム利用設定をマスターデータに追加
      for (let idx = 0; idx < editData.length; idx++) {
        // editData[idx].systemUseSetting = "1";

        const cancelManage = this.mntFacilityCancelManageList.find(item => {
          return item.facilityCd === editData[idx].facilityCd
        })

        if (cancelManage) {
          editData[idx].cancelDate = dayjs(cancelManage.stDate).format("YYYY-MM-DD")
        }

        if (!cancelManage) {
          // 契約中
          editData[idx].isCancel = CONTRACTING;
        }
        else if (cancelManage.procStatus === PROC_STATUS_WAITING) {
          // 処理待機中：処理区分に応じてフラグを変更する
          switch(cancelManage.procClass) {
            case PROC_CLASS_CANCEL :
              editData[idx].isCancel = RESERVE_CANCEL;
              break;
            case PROC_CLASS_REMS_CANCEL :
              editData[idx].isCancel = RESERVE_REMS_CANCEL;
              break;
            case PROC_CLASS_FNSI_CANCEL :
              editData[idx].isCancel = RESERVE_FNSI_CANCEL;
              break;
          }
        }
        else if (
          cancelManage.procStatus === PROC_STATUS_BACKUP_IN_PROGRESS || cancelManage.procStatus === PROC_STATUS_BACKUP_COMPLETED || cancelManage.procStatus === PROC_STATUS_DELETING
        ) {
          // データ削除中：処理区分に応じてフラグを変更する
          switch(cancelManage.procClass) {
            case PROC_CLASS_CANCEL :
              editData[idx].isCancel = CANCELING;
              break;
            case PROC_CLASS_REMS_CANCEL :
              editData[idx].isCancel = REMS_CANCELING;
              break;
            case PROC_CLASS_FNSI_CANCEL :
              editData[idx].isCancel = FNSI_CANCELING;
              break;
          }
          // 施設解約の進捗率を取得
          editData[idx].cancelProgress = this.getCancelProgress(cancelManage.stats);
        }
        else if (cancelManage.procStatus === PROC_STATUS_COMPLETED) {
          // データ削除完了：処理区分に応じてフラグを変更する
          switch(cancelManage.procClass) {
            case PROC_CLASS_CANCEL :
              editData[idx].isCancel = CANCELED;
              break;
            case PROC_CLASS_REMS_CANCEL :
              editData[idx].isCancel = REMS_CANCELED;
              break;
            case PROC_CLASS_FNSI_CANCEL :
              editData[idx].isCancel = FNSI_CANCELED;
              break;
          }
        }
      }
    },
    // add #10438 施設マスタのシステム利用設定がすべてReMSへ勝手に変わる linjunfeng end
    async saveRecord() {

      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      //イベント発生前のスクロールバーの位置を保持
      this.storeDirectGridScrollPosition();
      this.preserveGridScrollAfterSave = true;
      // 必須チェック
      if (!this.isFilledRequired()) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        this.abortSaveScrollPreserve();
        return;
      }

      // 施設コードチェック
      if (!this.validateFacilityCd()) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        this.abortSaveScrollPreserve();
        return;
      }

      // 部署符号チェック
      if (!this.validateDepartmentCd()) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        this.abortSaveScrollPreserve();
        return;
      }

      // データ収集開始時刻チェック
      if (!this.validateTime()) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        this.abortSaveScrollPreserve();
        return;
      }

      // メール形式チェック
      if (!this.validateEmail()) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        this.abortSaveScrollPreserve();
        return;
      }

      // 施設解約チェック
      const isValidCancel = await this.validateCancel()
      if (!isValidCancel) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        this.abortSaveScrollPreserve();
        return;
      }

      // 患者共有解除チェック
      if (this.getCancelFacilityCd.length > 0) {
        const isValidCancelSharePatient = await this.validateCancelSharePatient();
        if (!isValidCancelSharePatient) {
          //共通ローダー：表示終了
          this.setLoadingScreenVisible(false);
          this.abortSaveScrollPreserve();
          return;
        }
      }

      // 機能一覧を取得
      const sysFunctions = (
        await ApiHelper.get(uriFunctionAll)).data;
      // 日機装のみ表示機能
      const sysFunctionsNkk = sysFunctions.filter(func =>
        func.isNkk === "1").map(func2 =>
        func2.functionCd);
      // ReMSのみ表示機能
      const sysFunctionsReMS = sysFunctions.filter(func =>
        func.systemUseDisp === "1").map(func2 =>
        func2.functionCd);
      // FNSiのみ表示機能
      const sysFunctionsFNSi = sysFunctions.filter(func =>
        func.systemUseDisp === "2").map(func2 =>
        func2.functionCd);

      // 拡張機能一覧を取得
      const sysAdvancedSettings = (
        await ApiHelper.get(uriFunctionAdvancedAll)).data;
      // 日機装のみ表示拡張機能
      const sysAdvancedSettingsNkk = sysAdvancedSettings.filter(func =>
        func.isNkk === "1").map(func2 =>
        func2.functionAdvCd);
      // ReMSのみ表示拡張機能
      const sysAdvancedSettingsReMS = sysAdvancedSettings.filter(func =>
        func.systemUseDisp === "1").map(func2 =>
        func2.functionAdvCd);
      // FNSiのみ表示拡張機能
      const sysAdvancedSettingsFNSi = sysAdvancedSettings.filter(func =>
        func.systemUseDisp === "2").map(func2 =>
        func2.functionAdvCd);

      const keys = [
        "facilityCd",
        "facilityName",
        "facilityNameKana",
        "prefecturesCd",
        "departmentCd",
        "salesEmailAddress",
        "autoGatheringStartTime",
        "aliveMoniInterval",
        "useFunction",
        "advancedSettings",
        // add 施設マスタ クライアント証明書チェックを施設毎とアクセス元から判断する start
        "vpnSet",
        // add 施設マスタ クライアント証明書チェックを施設毎とアクセス元から判断する end
        // add 10378 by kangjie 20240522 start
        "isSchextException",
        // add 10378 by kangjie 20240522 end

      ];

      // 編集中のレコードを新規/更新/削除に分類
      const insertRecords = [];
      const updateRecords = [];
      const deleteCdList = [];
      for (let record of this.getUpdateRecordList) {
        if (record.operation === 2 && record.isDel === "1") {
          // 削除レコード
          deleteCdList.push(record.facilityCd);
        } else if (record.operation === 1 || record.operation === 2) {
          // システム利用区分・日機装施設判別により使用機能・拡張機能のを行う
          if (record.useFunction) {
            // 使用機能の制御
            let arrUseFunction = JSON.parse(record.useFunction).func_cds;
            if (record.facilityCd !== "nkknkk") {
              // 日機装施設以外の場合
              arrUseFunction = arrUseFunction.filter(func =>
                !sysFunctionsNkk.includes(func.func_cd)
              );
            }
            if (record.systemUseSetting === "1") {
              // ReMS施設の場合
              arrUseFunction = arrUseFunction.filter(func =>
                !sysFunctionsFNSi.includes(func.func_cd)
              );
            } else if (record.systemUseSetting === "2") {
              // FNSi施設の場合
              arrUseFunction = arrUseFunction.filter(func =>
                !sysFunctionsReMS.includes(func.func_cd)
              );
            }
            let updUseFunction = JSON.parse(record.useFunction);
            updUseFunction.func_cds = arrUseFunction;
            record.useFunction = JSON.stringify(updUseFunction);
          }
          if (record.advancedSettings) {
            // 拡張機能の制御
            let arrAdvancedSettings = JSON.parse(record.advancedSettings).func_advcds
            if (record.facilityCd !== "nkknkk") {
              // 日機装施設以外の場合
              arrAdvancedSettings = arrAdvancedSettings.filter(func =>
                !sysAdvancedSettingsNkk.includes(func.func_advcd)
              );
            }
            if (record.systemUseSetting === "1") {
              // ReMS施設の場合
              arrAdvancedSettings = arrAdvancedSettings.filter(func =>
                !sysAdvancedSettingsFNSi.includes(func.func_advcd)
              );
            } else if (record.systemUseSetting === "2") {
              // FNSi施設の場合
              arrAdvancedSettings = arrAdvancedSettings.filter(func =>
                !sysAdvancedSettingsReMS.includes(func.func_advcd)
              );
            }
            let updAdvancedSettings = JSON.parse(record.advancedSettings);
            updAdvancedSettings.func_advcds = arrAdvancedSettings;
            record.advancedSettings = JSON.stringify(updAdvancedSettings);
          }

          if (record.operation === 1) {
            // 新規レコード
            insertRecords.push(record);
          } else if (record.operation === 2) {
            // 更新レコード
            updateRecords.push(record);
          }
        }
      }

      // 登録日時・更新日時用の現在日時
      const now = dayjs().format("YYYY-MM-DDTHH:mm:ss.SSSZ");

      const serializedInsertRecords = insertRecords.map(record =>
        JSON.stringify({
          ..._.pick(record, keys),
          // なぜか'mNoticeMailTemplate'ではAPIに送信できないのでキー名変更
          mnoticeMailTemplate: record.mNoticeMailTemplate,
          // kendoのドロップダウンにnullが設定できないため擬似的に設定している未登録コード'00'をnullに変換
          prefecturesCd:
            record.prefecturesCd === "00" ? null : record.prefecturesCd,
          // 使用機能
          useFunction: record.useFunction,
          regDate: now,
          upDate: now
        })
      );

      // insertデータ(システム利用設定用)
      const serializedInsertHashRecords = insertRecords.map(record =>
        JSON.stringify({
          facilityCd: record.facilityCd,
          systemUseSetting: record.systemUseSetting,
          regDate: now,
          upDate: now
        })
      );

      const serializedUpdateRecords = updateRecords.map(record =>
        JSON.stringify({
          ..._.pick(record, keys),
          mNoticeMailTemplate: record.mNoticeMailTemplate,
          prefecturesCd:
            record.prefecturesCd === "00" ? null : record.prefecturesCd,
          useFunction: record.useFunction,
          upDate: now
        })
      );

      // updateデータ(システム利用設定用)
      const serializedUpdateHashRecords = updateRecords.map(record =>
        JSON.stringify({
          facilityCd: record.facilityCd,
          systemUseSetting: record.systemUseSetting,
          regDate: now,
          upDate: record.hashUpDate
        })
      );

      // 施設解約登録データ
      const cancelFacilityList = this.getUpdateRecordList
        .filter(
          record => record.isCancel === CANCEL || record.isCancel === REMS_CANCEL || record.isCancel === FNSI_CANCEL
        )
        .map(record => {
          let procClass = ""
          switch(record.isCancel) {
            case CANCEL:
              procClass = PROC_CLASS_CANCEL;
              break;
            case REMS_CANCEL:
              procClass = PROC_CLASS_REMS_CANCEL;
              break;
            case FNSI_CANCEL:
              procClass = PROC_CLASS_FNSI_CANCEL;
              break;
          }

          return JSON.stringify({
            facility_cd : record.facilityCd,
            base_date : dayjs(record.cancelDate).format("YYYY/MM/DD"),
            proc_class : procClass
          });
        })

      // 施設解約キャンセルデータ
      const cancelStopFacilityList = this.getUpdateRecordList
        .filter(
          record => record.isCancel === CANCEL_STOP
        )
        .map(record => {
          const cancelManage = this.mntFacilityCancelManageList.find(item => {
            return item.facilityCd === record.facilityCd
          })

          return JSON.stringify({
            facility_cd : record.facilityCd,
            proc_class : cancelManage ? cancelManage.procClass : ""
          });
        })

      // 解約日変更データ
      const changeCancelDateList = this.getUpdateRecordList
        .filter(record => {
          if (record.isCancel === RESERVE_CANCEL || record.isCancel === RESERVE_REMS_CANCEL || record.isCancel === RESERVE_FNSI_CANCEL) {
            const mfcm = this.mntFacilityCancelManageList.find(item => item.facilityCd === record.facilityCd);
            if (mfcm && record.cancelDate && !dayjs(record.cancelDate).isSame(dayjs(mfcm.stDate), "day")) {
              // 解約日が変更されているデータのみを抽出
              return true;
            }
          }
          return false;
        })
        .map(record => {
          const mfcm = this.mntFacilityCancelManageList.find(item => item.facilityCd === record.facilityCd);
          return JSON.stringify({
            ctl_no: mfcm ? mfcm.ctlNo : null,
            facility_cd : record.facilityCd,
            st_date : dayjs(record.cancelDate).format("YYYY/MM/DD")
          })
        })

      // add redmine 4485 施設マスタの並び順が変更 宋qy start
      const getMasterRecordList = this.getMasterRecordList.data.map(record => {
          return JSON.stringify({
            facilityCd : record.facilityCd,
            facilityName : record.facilityName
          })
        });

      const getFacility = [this.getFacilitySwitch,this.masterPhysicalName];
      // add redmine 4485 施設マスタの並び順が変更 宋qy end

      const editRecord = {
        insertRecord: serializedInsertRecords,
        insertHashRecord: serializedInsertHashRecords,
        updateRecord: serializedUpdateRecords,
        updateHashRecord: serializedUpdateHashRecords,
        cancelFacilityList,
        cancelStopFacilityList,
        changeCancelDateList,
        deleteCdList,
        // add redmine 4485 施設マスタの並び順が変更 宋qy start
        getMasterRecordList:getMasterRecordList,
        getFacility : getFacility
        // add redmine 4485 施設マスタの並び順が変更 宋qy end
      };

      // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen start
      let changeFlg = this.backupMasterRecordList.data.every(element => {
        for (let index = 0; index < serializedUpdateRecords.length; index++) {

          if (element.facilityCd != JSON.parse(serializedUpdateRecords[index]).facilityCd) {
            return true;
          }

          const beforChanges = JSON.parse(element.useFunction).func_cds;
          const afterChanges = JSON.parse(JSON.parse(serializedUpdateRecords[index]).useFunction).func_cds;

          let beforeCDMap = beforChanges.map(item => item.func_cd);
          let afterCDMap = afterChanges.map(item => item.func_cd);
          JSON.parse(element.advancedSettings) &&
            JSON.parse(element.advancedSettings).func_advcds.forEach(item => beforeCDMap.push(item.func_advcd));
          JSON.parse(JSON.parse(serializedUpdateRecords[index]).advancedSettings) &&
            JSON.parse(JSON.parse(serializedUpdateRecords[index]).advancedSettings).func_advcds.forEach(item => afterCDMap.push(item.func_advcd));

          return beforeCDMap.every(item => afterCDMap.includes(item));
        }
      });

      // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen start
      await this.getSignoutFlg(serializedUpdateRecords);
      // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen end

      let returnFlg = false;
      if (this.signoutFlg && !changeFlg) {
        await this.$ons.notification.confirm({
          // title: "変更確認",
          title: DIALOG_MESSAGES[13000157].title,
          message: MSG_SETTING_REFLECTION,
          callback: answer => {
            if (answer !== 1) {
              // キャンセル
              returnFlg = true;
            }
          }
        });
      }

      if (returnFlg) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        this.abortSaveScrollPreserve();
        return;
      }
      // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen end

      // apiをコールして値を保存
      try {
        await ApiHelper.put("/mstInfo/saveMstFacility", editRecord);
        this.getUserAccountInfo(); // 更新されたアカウント情報取得
      } catch (error) {
        getErrorMessage('MstFacilityMainComponent.vue', 'saveRecord', error);
        this.setLoadingScreenVisible(false);
        this.abortSaveScrollPreserve();
        if (error.response.status === 400) {
          const message = error.response.data.errorMessage;
          if (message.includes("デフォルト帳票展開処理")) {
            // "施設追加時のデフォルト帳票展開処理でエラーが発生しました。"
            this.$ons.notification.alert({
              title: DIALOG_MESSAGES["00200164"].title,
              message: messageFormat(DIALOG_MESSAGES["00200164"].message)
            });
          } else {
            // "システムエラーが発生しました。"
            this.$ons.notification.alert({
              title: DIALOG_MESSAGES["00200002"].title,
              message: messageFormat(DIALOG_MESSAGES["00200002"].message)
            });
          }
        }       
        throw new Error(String(error), { cause: error });
      }      

      // 患者情報共有機能をON→OFFにした場合、共有患者を解除する
      if (this.getCancelFacilityCd.length > 0) {
        await ApiHelper.post("/pat_name_identification/sharePatientInfo/cancelSharePatientInfo", this.getCancelFacilityCd).catch(
          error => {
            //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
            getErrorMessage('MstFacilityMainComponent.vue', 'saveRecord', error);
            //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
            //共通ローダー：表示終了
            this.setLoadingScreenVisible(false);
            this.abortSaveScrollPreserve();
            throw new Error(error);
          }
        );
      }

      this.$ons.notification.alert({
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        // title: "更新完了",
        // message: "マスタ更新が完了しました。"
        title: DIALOG_MESSAGES[12000004].title,
        message: messageFormat(DIALOG_MESSAGES[12000004].message),
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      });
      // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen start
      this.backupMasterRecordList = deepCopy(this.getMasterRecordList);
      // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen end

      this.isSorted = false;
      // del #10438 施設マスタのシステム利用設定がすべてReMSへ勝手に変わる linjunfeng start
      // await this.getFacilityCancelManage();
      // del #10438 施設マスタのシステム利用設定がすべてReMSへ勝手に変わる linjunfeng end
      await this.findList();

      //共通ローダー：表示終了
      this.setLoadingScreenVisible(false);

      // グリッドのデータ再表示（findList 内の showDisplay で isSortChacked は true）
      this.gridDataRefresh();
      this.restoreSavedGridScrollAfterSave(true);
      // 患者情報共有解除の施設コードをクリア
      this.clearCancelFacilityCd();

      if (editRecord && editRecord.updateRecord && editRecord.updateRecord.length > 0) {
        const updateRecordObj =  JSON.parse(editRecord.updateRecord);
        this.setUseFunction(updateRecordObj.useFunction);
      }
    },

    // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen start
    /**
     * @description 施設設定を取得
     * @summary 更新される施設の施設設定：権限変更時サインアウトさせるかの設定を取得
     * @param serializedUpdateRecords 更新される施設リスト
     */
    async getSignoutFlg(serializedUpdateRecords) {
      this.signoutFlg = false;

      for (let index = 0; index < serializedUpdateRecords.length; index++) {
        let updateFacilityCd = JSON.parse(serializedUpdateRecords[index]).facilityCd;
        // 施設設定：権限変更時サインアウトさせるかの設定を取得
        await sendRequestGetMstFacilitySettingValue(updateFacilityCd, PERMISSION_CHANGE_SIGNOUT).then(response => {
          this.signoutFlg = (this.signoutFlg || response.data == 1);
        });

        if (this.signoutFlg) {
          break;
        }
      }
    },
    // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen end

    /**
     * @description 必須項目チェック
     * @summary 未入力の必須項目があったらダイアログを表示する
     * @returns {Boolean} true: 未入力なし, false: 未入力あり
     */
    isFilledRequired() {
      if (
        this.getUpdateRecordList.some(
          item => item.facilityCd === null || item.facilityCd === "")) {
        this.isDialogVisible = true;
        this.messageCd = 20010002;
        this.stringParams = ["施設コード"];
        return false;
      }
      if (
        this.getUpdateRecordList.some(
          item => item.facilityName === null || item.facilityName === "")) {
        this.isDialogVisible = true;
        this.messageCd = 20010002;
        this.stringParams = ["施設名"];
        return false;
      }
      return true;
    },

    /**
     * @description 施設コードチェック
     * @summary 重複または半角英数字以外があったらダイアログを表示する
     * @returns {Boolean} true: 正, false: 不正
     */
    validateFacilityCd() {
      const facilityCdList = this.getUpdateRecordList.map(
        record => record.facilityCd
      );
      // 施設コードリストをSetオブジェクトに(重複排除)
      const set = new Set(facilityCdList);
      if (facilityCdList.length !== set.size) {
        // 元のリストと重複排除リストの長さが違うなら重複あり
        this.isDialogVisible = true;
        this.messageCd = 60000001;
        this.stringParams = ["施設コード"];
        return false;
      }

      // 半角英数字の正規表現パターン
      const regexp = /^[0-9a-zA-Z]*$/;
      if (facilityCdList.some(cd => !regexp.test(cd))) {
        this.isDialogVisible = true;
        this.messageCd = 60000002;
        this.stringParams = ["施設コード"];
        return false;
      }

      return true;
    },

    /**
     * @description 部署符号チェック
     * @summary 半角英数字でない部署符号があったらダイアログを表示する
     * @returns {Boolean} true: 部署符号が全て正しい, false: 半角英数字でない部署符号あり
     */
    validateDepartmentCd() {
      // 部署符号リスト
      const departmentCdList = this.getUpdateRecordList.map(
        record => record.departmentCd
      );
      // 半角英数字の正規表現パターン
      const regexp = /^[0-9a-zA-Z]*$/;
      if (departmentCdList.some(cd => !regexp.test(cd))) {
        this.isDialogVisible = true;
        this.messageCd = 60000002;
        this.stringParams = ["部署符号"];
        return false;
      }
      return true;
    },

    /**
     * @description データ収集開始時刻チェック
     * @summary HHmm形式でないデータ収集開始時刻があったらダイアログを表示する
     * @returns {Boolean} true: データ収集開始時刻が全て正しい, false: HHmm形式でないデータ収集開始時刻あり
     */
    validateTime() {
      const timeList = this.getUpdateRecordList.map(
        record => record.autoGatheringStartTime
      );
      // HHmmの正規表現パターン
      const regexp = /^([0-1][0-9]|[2][0-3])[0-5][0-9]$/;
      if (
        timeList.some(
          time => time !== null && time !== "" && !regexp.test(time))) {
        this.isDialogVisible = true;
        this.messageCd = 60000003;
        this.stringParams = ["データ収集開始時刻"];
        return false;
      }
      return true;
    },

    /**
     * @description メール形式チェック
     * @summary メール形式ではないメール形式チェックがある場合にダイアログを表示する
     * @returns {Boolean} true: メール形式チェックが全て正しい, false: メール形式ではないデータ収集メール
     */
    validateEmail() {
      const mailList = this.getUpdateRecordList.map(
        record => record.salesEmailAddress
      );
      const emailReg = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/;
      if (
        mailList.some(
          mail => mail !== null && mail !== "" && !emailReg.test(mail))) {
        this.isDialogVisible = true;
        this.messageCd = 60000005;
        this.stringParams = [];
        return false;
      }
      return true;
    },

    /**
     * @description 施設解約チェック
     * @summary HHmm形式でないデータ収集開始時刻があったらダイアログを表示する
     * @returns {Boolean} true: データ収集開始時刻が全て正しい, false: HHmm形式でないデータ収集開始時刻あり
     */
    async validateCancel() {
      let isValid = true;

      // 解約選択施設のバリテーションチェック
      const cancelRecords = this.getUpdateRecordList.filter(
        record => record.isCancel === CANCEL
      );
      for (const record of cancelRecords) {

        // 解約日必須チェック
        if (!record.cancelDate) {
          this.isDialogVisible = true;
          this.messageCd = 60000006;
          this.stringParams = [record.facilityName];
          isValid = false;
          break;
        }

        // 解約日形式チェック
        if (!dayjs(record.cancelDate).isValid) {
          this.isDialogVisible = true;
          this.messageCd = 60000007;
          this.stringParams = [record.facilityName];
          isValid = false;
          break;
        }

        // 解約日が当日以降に指定されているかチェック
        if (dayjs(record.cancelDate).isSameOrBefore(dayjs(), "day")) {
          this.isDialogVisible = true;
          this.messageCd = 60000008;
          this.stringParams = [record.facilityName];
          isValid = false;
          break;
        }

        // 確認メッセージ1段階目
        const res1 = await this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "解約処理警告",
          title: DIALOG_MESSAGES[13000073].title,
          // message:
            // `${dayjs(record.cancelDate).format("YYYY/MM/DD")}より${record.facilityName}様の解約処理を行います。</br>
            //  ${record.facilityName}様に関連するデータ全てが削除されます。</br>
            //  解約日以降は以下の操作が行えません。</br>
            //  ・ログインができなくなります。</br>
            //  ・デバイスエッジが停止し透析装置との通信ができなくなります。</br>
            //  登録してもよろしいですか？`
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
            message: messageFormat(DIALOG_MESSAGES[13000073].message,dayjs(record.cancelDate).format("YYYY/MM/DD"),record.facilityName,record.facilityName),
        });
        if (res1 ==! 1) {
          isValid = false;
          break;
        }

        // 確認メッセージ2段階目
        const res2 = await this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "解約処理確認",
          title: DIALOG_MESSAGES[13000074].title,
          // message:
          //   `${dayjs(record.cancelDate).format("YYYY/MM/DD")}より解約処理を行います。</br>
          //   ${record.facilityName}様に関連するデータ全てが削除されます。</br>よろしいですか？`
          message: messageFormat(DIALOG_MESSAGES[13000074].message,dayjs(record.cancelDate).format("YYYY/MM/DD"),record.facilityName),
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        });
        if (res2 ==! 1) {
          isValid = false;
          break;
        }

        // 確認メッセージ3段階目
        const res3 = await this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "解約処理最終確認",
          title: DIALOG_MESSAGES[13000075].title,
          // message:
          // `${dayjs(record.cancelDate).format("YYYY/MM/DD")}より${record.facilityName}様全データの削除を開始します。</br>
          // 本当によろしいですか？`
          message: messageFormat(DIALOG_MESSAGES[13000075].message,dayjs(record.cancelDate).format("YYYY/MM/DD"),record.facilityName),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        });
        if (res3 ==! 1) {
          isValid = false;
          break;
        }
      }

      // 解約キャンセル施設のバリテーションチェック
      const cancelStopRecords = this.getUpdateRecordList.filter(
        record => record.isCancel === CANCEL_STOP
      );
      for (const record of cancelStopRecords) {

        // 確認メッセージ1段階目
        const res1 = await this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "解約予約キャンセル確認",
          title: DIALOG_MESSAGES[13000076].title,
          // message:
          //   `${record.facilityName}様の解約予約をキャンセルします。</br>
          //    よろしいですか？`
          message: messageFormat(DIALOG_MESSAGES[13000076].message,record.facilityName),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        });
        if (res1 ==! 1) {
          isValid = false;
          break;
        }

        // 確認メッセージ2段階目
        const res2 = await this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "解約予約キャンセル最終確認",
          title: DIALOG_MESSAGES[13000077].title,
          // message:
          //   `${record.facilityName}様の解約予約のキャンセル処理を開始します。</br>
          //    本当によろしいですか？`
          message: messageFormat(DIALOG_MESSAGES[13000077].message,record.facilityName),
             // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        });
        if (res2 ==! 1) {
          isValid = false;
          break;
        }
      }

      // 解約日変更施設のバリテーションチェック
      const changeCancelDateRecords = this.getUpdateRecordList.filter(record => {
        if (record.isCancel === RESERVE_CANCEL) {
          const mfcm = this.mntFacilityCancelManageList.find(item => item.facilityCd === record.facilityCd);
          if (mfcm && !dayjs(record.cancelDate).isSame(dayjs(mfcm.stDate), "day")) {
            // 解約日が変更されているデータのみを抽出
            return true;
          }
        }
        return false;
      });

      if (changeCancelDateRecords.length > 0) {

        // 最新の施設解約管理情報を取得
        const response = await ApiHelper.get("/facilities/MntFacilityCancelManage/SelectAll")
          .catch(error => {
            //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
            getErrorMessage('MstFacilityMainComponent.vue', 'validateCancel', error);
            //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
            throw error;
          });

        const latestFacilityCancelManage = response.data;

        for (const record of changeCancelDateRecords) {
          // 解約日必須チェック
          if (!record.cancelDate) {
            this.isDialogVisible = true;
            this.messageCd = 60000006;
            this.stringParams = [record.facilityName];
            isValid = false;
            break;
          }

          // 解約日形式チェック
          if (!dayjs(record.cancelDate).isValid) {
            this.isDialogVisible = true;
            this.messageCd = 60000007;
            this.stringParams = [record.facilityName];
            isValid = false;
            break;
          }

          // 解約日が明日以降に指定されているかチェック
          if (dayjs(record.cancelDate).isSameOrBefore(dayjs(), "day")) {
            this.isDialogVisible = true;
            this.messageCd = 60000008;
            this.stringParams = [record.facilityName];
            isValid = false;
            break;
          }

          const target = latestFacilityCancelManage.find(item => item.facilityCd === record.facilityCd);
          if (!target || target.procStatus > 0) {
            // 解約管理が存在しない、または削除が開始されている場合は解約日変更を不可にする
            this.isDialogVisible = true;
            this.messageCd = 60000009;
            this.stringParams = [record.facilityName];
            isValid = false;
            break;
          }

          // 確認メッセージ
          const res = await this.$ons.notification.confirm({
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
            // title: "解約日変更確認",
            title: DIALOG_MESSAGES[13000078].title,
            // message:
            //   `${record.facilityName}様の解約日を変更します。</br>
            //   本当によろしいですか？`
            message: messageFormat(DIALOG_MESSAGES[13000078].message,record.facilityName),
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          });
          if (res ==! 1) {
            isValid = false;
            break;
          }
        }
      }

      // ReMSのみ解約選択施設のバリテーションチェック
      const remsCancelRecords = this.getUpdateRecordList.filter(
        record => record.isCancel === REMS_CANCEL
      );
      for (const record of remsCancelRecords) {

        // 解約日必須チェック
        if (!record.cancelDate) {
          this.isDialogVisible = true;
          this.messageCd = 60000006;
          this.stringParams = [record.facilityName];
          isValid = false;
          break;
        }

        // 解約日形式チェック
        if (!dayjs(record.cancelDate).isValid) {
          this.isDialogVisible = true;
          this.messageCd = 60000007;
          this.stringParams = [record.facilityName];
          isValid = false;
          break;
        }

        // 解約日が当日以降に指定されているかチェック
        if (dayjs(record.cancelDate).isSameOrBefore(dayjs(), "day")) {
          this.isDialogVisible = true;
          this.messageCd = 60000008;
          this.stringParams = [record.facilityName];
          isValid = false;
          break;
        }

        // 確認メッセージ1段階目
        const res1 = await this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "ReMS解約処理警告",
          title: DIALOG_MESSAGES[13000079].title,
          // message:
          //   `${dayjs(record.cancelDate).format("YYYY/MM/DD")}より${record.facilityName}様のReMS解約処理を行います。</br>
          //    ${record.facilityName}様のReMSに関連するデータ全てが削除されます。</br>
          //    解約日以降は以下の操作が行えません。</br>
          //    ・デバイスエッジが停止し透析装置との通信ができなくなります。</br>
          //    登録してもよろしいですか？`
          message: messageFormat(DIALOG_MESSAGES[13000079].message,dayjs(record.cancelDate).format("YYYY/MM/DD"),record.facilityName,record.facilityName),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        });
        if (res1 ==! 1) {
          isValid = false;
          break;
        }

        // 確認メッセージ2段階目
        const res2 = await this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "ReMS解約処理確認",
          title: DIALOG_MESSAGES[13000080].title,
          // message:
          //   `${dayjs(record.cancelDate).format("YYYY/MM/DD")}よりReMS解約処理を行います。</br>
          //   ${record.facilityName}様のReMSに関連するデータ全てが削除されます。</br>よろしいですか？`
          message: messageFormat(DIALOG_MESSAGES[13000080].message,dayjs(record.cancelDate).format("YYYY/MM/DD"),record.facilityName),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        });
        if (res2 ==! 1) {
          isValid = false;
          break;
        }

        // 確認メッセージ3段階目
        const res3 = await this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "ReMS解約処理最終確認",
          title: DIALOG_MESSAGES[13000081].title,
          // message:
          // `${dayjs(record.cancelDate).format("YYYY/MM/DD")}より${record.facilityName}様のReMSのデータの削除を開始します。</br>
          // 本当によろしいですか？`
          message: messageFormat(DIALOG_MESSAGES[13000081].message,dayjs(record.cancelDate).format("YYYY/MM/DD"),record.facilityName),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        });
        if (res3 ==! 1) {
          isValid = false;
          break;
        }
      }

      // FNSiのみ解約選択施設のバリテーションチェック
      const fnsiCancelRecords = this.getUpdateRecordList.filter(
        record => record.isCancel === FNSI_CANCEL
      );
      for (const record of fnsiCancelRecords) {

        // 解約日必須チェック
        if (!record.cancelDate) {
          this.isDialogVisible = true;
          this.messageCd = 60000006;
          this.stringParams = [record.facilityName];
          isValid = false;
          break;
        }

        // 解約日形式チェック
        if (!dayjs(record.cancelDate).isValid) {
          this.isDialogVisible = true;
          this.messageCd = 60000007;
          this.stringParams = [record.facilityName];
          isValid = false;
          break;
        }

        // 解約日が当日以降に指定されているかチェック
        if (dayjs(record.cancelDate).isSameOrBefore(dayjs(), "day")) {
          this.isDialogVisible = true;
          this.messageCd = 60000008;
          this.stringParams = [record.facilityName];
          isValid = false;
          break;
        }

        // 確認メッセージ1段階目
        const res1 = await this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "FNSi解約処理警告",
          title: DIALOG_MESSAGES[13000082].title,
          // message:
          //   `${dayjs(record.cancelDate).format("YYYY/MM/DD")}より${record.facilityName}様のFNSi解約処理を行います。</br>
          //    ${record.facilityName}様のFNSiに関連するデータ全てが削除されます。</br>
          //    登録してもよろしいですか？`
          message: messageFormat(DIALOG_MESSAGES[13000082].message,dayjs(record.cancelDate).format("YYYY/MM/DD"),record.facilityName,record.facilityName),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        });
        if (res1 ==! 1) {
          isValid = false;
          break;
        }

        // 確認メッセージ2段階目
        const res2 = await this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "FNSi解約処理確認",
          title: DIALOG_MESSAGES[13000083].title,
          // message:
          //   `${dayjs(record.cancelDate).format("YYYY/MM/DD")}よりFNSi解約処理を行います。</br>
          //   ${record.facilityName}様のFNSiに関連するデータ全てが削除されます。</br>よろしいですか？`
          message: messageFormat(DIALOG_MESSAGES[13000083].message,dayjs(record.cancelDate).format("YYYY/MM/DD"),record.facilityName),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        });
        if (res2 ==! 1) {
          isValid = false;
          break;
        }

        // 確認メッセージ3段階目
        const res3 = await this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "FNSi解約処理最終確認",
          title: DIALOG_MESSAGES[13000084].title,
          // message:
          // `${dayjs(record.cancelDate).format("YYYY/MM/DD")}より${record.facilityName}様のFNSiのデータの削除を開始します。</br>
          // 本当によろしいですか？`
          message: messageFormat(DIALOG_MESSAGES[13000084].message,dayjs(record.cancelDate).format("YYYY/MM/DD"),record.facilityName),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        });
        if (res3 ==! 1) {
          isValid = false;
          break;
        }
      }

      return isValid;
    },

    /**
     * @description 患者情報共有解除チェック
     * @summary 患者情報共有機能をOFFした時確認ダイアログを表示する
     * @returns {Boolean}
     */
    async validateCancelSharePatient() {
      let isValid = true;

      //OFFにされた施設コードを検索して2重警告メッセージを表示する
      for (const cd of this.getCancelFacilityCd) {
        const cancelRecords = this.getUpdateRecordList.filter(
          record => record.facilityCd === cd
        );

        // 確認メッセージ2段階目
        const res2 = await this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "患者情報共有解除処理確認",
          title: DIALOG_MESSAGES[13000086].title,
          // message:
          //   `${cancelRecords[0].facilityName}様の患者情報共有機能を本当にOFFにしてもよろしいですか？`
          message: messageFormat(DIALOG_MESSAGES[13000086].message,cancelRecords[0].facilityName),
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        });
        if (res2 ==! 1) {
          isValid = false;
          break;
        }
      }
      return isValid;
    },

    showMasterEditModalAdvancedSettings(e) {
      // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      const gridScrollPosition = this.getGridScrollPosition();
      this.scrollPosition.top = gridScrollPosition.top;
      this.scrollPosition.left = gridScrollPosition.left;

      /**
       * 「設定」ボタンを押下したレコードのデータを取得する。
       * see: https://www.telerik.com/forums/selected-row-at-wrappers-for-vue
       */
      e.preventDefault();
      const selectedRowItem = this.getDirectGridDataItemFromEvent(e);
      let code = selectedRowItem.code;

      // codeがない場合はcodeを付番
      if (!code) {
        this.edit({ editRecord: selectedRowItem, isSortMode: this.isSortMode });
      }

      // プロパティを正規化する。
      const normalizedItem = this.normalization(selectedRowItem);

      // ストアに保存する。
      this.setEditRecord(normalizedItem);

      this.showFacilityMasterAdvancedSettings();
    },
    showMasterEditModalAuthFunctions(e) {
      // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      const gridScrollPosition = this.getGridScrollPosition();
      this.scrollPosition.top = gridScrollPosition.top;
      this.scrollPosition.left = gridScrollPosition.left;

      // モーダルを表示
      this.showFacilityMasterAuthFunction();

      /**
       * 「設定」ボタンを押下したレコードのデータを取得する。
       * see: https://www.telerik.com/forums/selected-row-at-wrappers-for-vue
       */
      e.preventDefault();
      const selectedRowItem = this.getDirectGridDataItemFromEvent(e);
      let code = selectedRowItem.code;

      // codeがない場合はcodeを付番
      if (!code) {
        this.edit({ editRecord: selectedRowItem, isSortMode: this.isSortMode });
      }

      // プロパティを正規化する。
      const normalizedItem = this.normalization(selectedRowItem);

      // ストアに保存する。
      this.setEditRecord(normalizedItem);
    },
    addRow() {
      // グリッドでエラーが発生している場合／一般ユーザーの場合は処理を中断
      if (!this.kendoValidator.validate() || !this.isAdminUser) {
        return;
      }

      // 空レコードをストアに登録
      let newRecord = {};
      const fields = this.getMasterRecordList.schema.model.fields;

      // 初期値を設定
      Object.keys(fields).forEach(colName => {
        switch (colName) {
          case "mNoticeMailTemplate":
            newRecord[colName] = this.defaultMailTemplate.mail_alive_template;
            break;

          case "autoGatheringStartTime":
            newRecord[colName] = "0230";
            break;

          case "prefecturesCd":
            newRecord[colName] = "00";
            break;

          case "name":
            newRecord[colName] = "";
            break;

          case "useFunction":
            // 初期設定機能としてマスタメンテナンスを登録
            var defaultFunctions = {};
            var arrEditFuncCds = [];
            var funcCdMaster = {};
            funcCdMaster.func_cd = "005";
            arrEditFuncCds.push(funcCdMaster);
            defaultFunctions.func_cds = arrEditFuncCds;
            newRecord[colName] = JSON.stringify(defaultFunctions);
            break;

          // add 施設マスタ クライアント証明書チェックを施設毎とアクセス元から判断する start
          case "vpnSet":
            newRecord[colName] = "0";
            break;
          // add 施設マスタ クライアント証明書チェックを施設毎とアクセス元から判断する end

          default:
            newRecord[colName] = null;
            break;
        }
      });

      // 空レコードにシステム利用設定を追加
      newRecord.systemUseSetting = "1";
      newRecord.hashUpDate = null;
      // 追加行: 縦スクロール最下部・横スクロール先頭へ（MasterRecordComponent.addRow と同様）
      this.scrollPosition.left = 0;
      this.lastScrollLeft = 0;
      this.lastScrollTop = this.getGridScrollHostEl()?.scrollHeight;
      this.scheduleMasterGridScrollToAddedRow?.();
      // 画面編集内容をstoreに反映 ※新規レコード追加
      this.edit({ editRecord: newRecord, isSortMode: this.isSortMode });
      this.$nextTick(() => {
        this.applyDirectGridDataSourceContract();
        this.scheduleMasterGridScrollToAddedRow?.();
        this.editBackgroundColor();
      });
    },
    /**
     * @description 表示順設定
     * @param {Array}
     */
    sortRecords(records) {
      const strCompare = (a, b) => (a || "").trim().localeCompare((b || "").trim());
      records.sort((a, b) => {
        let compare = strCompare(a.prefecturesCd, b.prefecturesCd);
        if (compare !== 0) {
          return compare;
        }

        compare = strCompare(a.departmentCd, b.departmentCd);
        if (compare !== 0) {
          return compare;
        }

        return strCompare(a.facilityCd, b.facilityCd);
      })
    },

    /**
     * @description 画面表示関数
     */
    showDisplay() {
      // 画面表示フラグ
      this.isSortChacked = true;
      this.$nextTick(() => {
        this.initDirectGridIfReady();
        this.applyDirectGridDataSourceContract();
        this.scheduleDirectGridLayoutContract();
        this.restoreDirectGridScrollPosition();
        requestAnimationFrame(() => {
          this.restoreDirectGridScrollPosition();
        });
      });
    },

    async loadGridData(){
      // 施設解約管理を取得
      // del #10438 施設マスタのシステム利用設定がすべてReMSへ勝手に変わる linjunfeng start
      // await this.getFacilityCancelManage();
      // del #10438 施設マスタのシステム利用設定がすべてReMSへ勝手に変わる linjunfeng end
      // this.setCondition(this.condition);
      this.isSortChacked = false;
      this.findList();
    },
    // システム利用設定を追加する
    addSystemUseSetting(){
      const systemUseSettingList = this.getMasterHashRecordList;

      let editData = this.getFilteredMasterRecordList.data;
      // #10438 施設マスタのシステム利用設定がすべてReMSへ勝手に変わる linjunfeng start
          // #9863 TypeError: Cannot read properties of undefined (reading 'length') 横展開2 linjunfeng start
      // if (editData) {
          // #9863 TypeError: Cannot read properties of undefined (reading 'length') 横展開2 linjunfeng end
      // #10438 施設マスタのシステム利用設定がすべてReMSへ勝手に変わる linjunfeng end
      // 取得したシステム利用設定をマスターデータに追加
      for (let idx = 0; idx < editData.length; idx++) {
        const targetFacilityCd = editData[idx].facilityCd;
        const listIndex = systemUseSettingList.findIndex(({facilityCd}) => facilityCd === targetFacilityCd);

        if (listIndex >= 0) {
          const sysUseSetting = systemUseSettingList[listIndex].systemUseSetting;
          const hashUpDate = systemUseSettingList[listIndex].upDate;
          if (!sysUseSetting && !editData[idx].systemUseSetting) {
            editData[idx].systemUseSetting = "1";
          } else if (sysUseSetting) {
            editData[idx].systemUseSetting = sysUseSetting;
          }
          editData[idx].hashUpDate = hashUpDate;
        }else {
          if (!editData[idx].systemUseSetting)
          editData[idx].systemUseSetting = "1";
        }
      }

      // 表示順を更新するため、storeに設定
      this.setMasterRecordList(this.getFilteredMasterRecordList);
      // 表示順(sortRank)の初期値を設定してから比較用スナップショットを保存する
      this.sortRank();
      this.setComparisonRecordModel();
      // ソート後グリッドを表示
      this.showDisplay();
    },
    onDirectGridEdit(event) {
      if (this.isMobileDevice && !this.allowEdit) {
        return;
      }
      bindGridEditorEnterToCloseCell(event?.sender || this.directGridWidget, event?.container);
      bindGridEditorDropDownListToCloseCell(event?.sender || this.directGridWidget, event?.container);
      const cell = event?.container?.[0] || event?.container;
      const field = getGridEditFieldFromEvent(event, this.columns);
      if (!cell || !field) {
        return;
      }
      if (this.isSortMode && field === "sortRank") {
        const model = event.model;
        bindGridEditorNumericWheelSpinAssist({
          cell,
          gridRoot: this.getDirectGridRoot(),
          onEditorValueChange: () => {
            const value = readGridEditorNumericValue(cell);
            if (model?.set) {
              model.set("sortRank", value);
              model.set("sortInputTime", Date.now());
            } else if (model) {
              model.sortRank = value;
              model.sortInputTime = Date.now();
            }
            this.scheduleDirectGridCurrentRowVisual(model);
          },
        });
      }
    },
    facilityEditStart(e) {
      if (this.isMobileDevice && !this.allowEdit) {
        /* NOTE:
         * モバイル系は、スワイプ・フリック操作で入力パッドが表示される。
         * そのため、スクロール操作が損なわれるので、閲覧モードのときは
         * 後続のイベントを発火させないように制御する。
         */
        e.preventDefault();
        return;
      }

      const classnm = getScopedElementsByClassName("k-icon k-i-calendar", this.$el || this);
      const selectnm = getScopedElementsByClassName("k-select", this.$el || this);
      
      this.storeDirectGridScrollPosition();
      this.isEditGrid = true;
      if (this.androidFlg) {
        this.editingFlg = true;
      }
    },

    // 施設解約管理の取得
    async getFacilityCancelManage() {
      const response = await ApiHelper.get("/facilities/MntFacilityCancelManage/SelectAll").catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('MstFacilityMainComponent.vue', 'getFacilityCancelManage', error);
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        throw error;});
      this.mntFacilityCancelManageList = response.data;
    },

    // 解約後アクションボタンのテンプレート作成
    cancelActionTemplate:function(e) {
      let isActionTemplate = e.isCancel && !(e.isCancel== CANCELED || e.isCancel === REMS_CANCELED || e.isCancel === FNSI_CANCELED);
      if(!e.facilityCd) isActionTemplate = true;
      return {
        template: CancelActionTemplate,
        templateArgs: Object.assign({}, {
          parentComponent: this,
          rowData: e,
          isActionTemplate: isActionTemplate,
        })
      };
    },

    // 完全削除ボタンが押下されたときの処理（子コンポーネントからの呼出し）
    async onClickCompleteDelete(rowData) {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);

      if (rowData.isCancel === CANCELED) {
        // 確認メッセージ1段階目
        const res1 = await this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "完全削除警告",
          title: DIALOG_MESSAGES[13000087].title,
          // message:
          //   `${rowData.facilityName}様の完全削除処理を行います。</br>
          //    完全削除を行うと以下の処理が実行されます</br>
          //    ・施設マスタから${rowData.facilityName}様のデータが削除されます。</br>
          //    ・${rowData.facilityName}様に関連するバックアップファイル全てが削除されます。</br>
          //    完全削除を実行してもよろしいですか？`
          message: messageFormat(DIALOG_MESSAGES[13000087].message,rowData.facilityName,rowData.facilityName,rowData.facilityName),
             // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        });
        if (res1 ==! 1) {
          //共通ローダー：表示終了
          this.setLoadingScreenVisible(false);
          return;
        }

        // 確認メッセージ2段階目
        const res2 = await this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "完全削除確認",
          title: DIALOG_MESSAGES[13000088].title,
          // message:
          //   `${rowData.facilityName}様の完全削除処理を行います。</br>
          //   ${rowData.facilityName}様に関連するデータ、バックアップファイルが完全に削除されます。</br>よろしいですか？`
          message: messageFormat(DIALOG_MESSAGES[13000088].message,rowData.facilityName,rowData.facilityName),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        });
        if (res2 ==! 1) {
          //共通ローダー：表示終了
          this.setLoadingScreenVisible(false);
          return;
        }

        // 確認メッセージ3段階目
        const res3 = await this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "完全削除最終確認",
          title: DIALOG_MESSAGES[13000089].title,
          // message:
          // `${rowData.facilityName}様の全データ、バックアップファイルの削除を開始します。</br>
          // 本当によろしいですか？`
          message: messageFormat(DIALOG_MESSAGES[13000089].message,rowData.facilityName),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        });
        if (res3 ==! 1) {
          //共通ローダー：表示終了
          this.setLoadingScreenVisible(false);
          return;
        }

        const payload = {
          facilityCd: rowData.facilityCd
        };

        // 完全削除APIをコール
        const response = await ApiHelper.post("/facilities/completeDelete", payload)
          .catch(async error => {
            //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
            getErrorMessage('MstFacilityMainComponent.vue', 'onClickCompleteDelete', '${rowData.facilityName}様の完全削除に失敗しました。');
            //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
            await this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "完全削除失敗",
              // message: `${rowData.facilityName}様の完全削除に失敗しました。`
              title: DIALOG_MESSAGES['00200056'].title,
              message: messageFormat(DIALOG_MESSAGES['00200056'].message, rowData.facilityName),
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            });
            //共通ローダー：表示終了
            this.setLoadingScreenVisible(false);
            throw new Error(error);
          });

        if (response.status === 200) {
          this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "完全削除完了",
            // message: `${rowData.facilityName}様の完全削除が完了しました。`
            title: DIALOG_MESSAGES['00100010'].title,
            message: messageFormat(DIALOG_MESSAGES['00100010'].message, rowData.facilityName),
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          });
        }

        this.isSorted = false;
        // del #10438 施設マスタのシステム利用設定がすべてReMSへ勝手に変わる linjunfeng start
        // await this.getFacilityCancelManage();
        // del #10438 施設マスタのシステム利用設定がすべてReMSへ勝手に変わる linjunfeng start
        await this.findList();

        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);

        // グリッドのデータ再表示
        this.gridDataRefresh();
      } else {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
      }
    },

    // データ削除ボタンが押下されたときの処理（子コンポーネントからの呼出し）
    async onClickDataDelete(rowData) {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);

      if (rowData.isCancel === REMS_CANCELED || rowData.isCancel === FNSI_CANCELED) {
        // 確認メッセージ1段階目
        const res1 = await this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "データ削除警告",
          title: DIALOG_MESSAGES[13000090].title,
          // message:
          //   `${rowData.facilityName}様のバックアップファイル削除処理を行います。</br>
          //    データ削除を行うと以下の処理が実行されます</br>
          //    ・${rowData.facilityName}様に関連するバックアップファイルが削除されます。</br>
          //    データ削除を実行してもよろしいですか？`
          message: messageFormat(DIALOG_MESSAGES[13000090].message,rowData.facilityName,rowData.facilityName),
             // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        });
        if (res1 ==! 1) {
          //共通ローダー：表示終了
          this.setLoadingScreenVisible(false);
          return;
        }

        // 確認メッセージ2段階目
        const res2 = await this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "完全削除確認",
          title: DIALOG_MESSAGES[13000091].title,
          // message:
          //   `${rowData.facilityName}様のデータ削除処理を行います。</br>
          //   ${rowData.facilityName}様に関連するバックアップファイルが削除されます。</br>よろしいですか？`
            message: messageFormat(DIALOG_MESSAGES[13000091].message,rowData.facilityName,rowData.facilityName),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        });
        if (res2 ==! 1) {
          //共通ローダー：表示終了
          this.setLoadingScreenVisible(false);
          return;
        }

        // 確認メッセージ3段階目
        const res3 = await this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "完全削除最終確認",
          title: DIALOG_MESSAGES[13000092].title,
          // message:
          // `${rowData.facilityName}様のバックアップファイルの削除を開始します。</br>
          // 本当によろしいですか？`
          message: messageFormat(DIALOG_MESSAGES[13000092].message,rowData.facilityName),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        });
        if (res3 ==! 1) {
          //共通ローダー：表示終了
          this.setLoadingScreenVisible(false);
          return;
        }

        const payload = {
          facilityCd: rowData.facilityCd
        };

        // 完全削除APIをコール
        const response = await ApiHelper.post("/facilities/dataDelete", payload)
          .catch(async error => {
            //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
            getErrorMessage('MstFacilityMainComponent.vue', 'onClickCompleteDelete', '${rowData.facilityName}様のバックアップファイル削除に失敗しました。');
            //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
            await this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "データ削除失敗",
              // message: `${rowData.facilityName}様のバックアップファイル削除に失敗しました。`
              title: DIALOG_MESSAGES['00200057'].title,
              message: messageFormat(DIALOG_MESSAGES['00200057'].message, rowData.facilityName),
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            });
            //共通ローダー：表示終了
            this.setLoadingScreenVisible(false);
            throw new Error(error);
          });

        if (response.status === 200) {
          this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "データ削除完了",
            // message: `${rowData.facilityName}様のバックアップファイル削除が完了しました。`
            title: DIALOG_MESSAGES['00100011'].title,
            message: messageFormat(DIALOG_MESSAGES['00100011'].message, rowData.facilityName),
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          });
        }

        this.isSorted = false;
        // del #10438 施設マスタのシステム利用設定がすべてReMSへ勝手に変わる linjunfeng start
        // await this.getFacilityCancelManage();
        // del #10438 施設マスタのシステム利用設定がすべてReMSへ勝手に変わる linjunfeng start
        await this.findList();

        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);

        // グリッドのデータ再表示
        this.gridDataRefresh();
      } else {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
      }
    },

    // ダウンロードボタンが押下されたときの処理（子コンポーネントからの呼出し）
    async onClickDownloadBackup(rowData) {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);

      if (rowData.isCancel === CANCELED || rowData.isCancel === REMS_CANCELED || rowData.isCancel === FNSI_CANCELED) {
        // 確認メッセージ
        const res = await this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "ダウンロード確認",
          title: DIALOG_MESSAGES[13000093].title,
          // message:
          //   `${rowData.facilityName}様のバックアップファイルをすべてダウンロードします。</br>
          //   よろしいですか？`
          message: messageFormat(DIALOG_MESSAGES[13000093].message,rowData.facilityName),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        });
        if (res ==! 1) {
          //共通ローダー：表示終了
          this.setLoadingScreenVisible(false);
          return;
        }

        // 処理区分に変換(解約："1"、ReMSのみ解約:"3"、FNSiのみ解約："4")
        const pClass = rowData.isCancel === CANCELED ? "1" : (rowData.isCancel === REMS_CANCELED ? "3" : "4");
        const payload = {
          facilityCd: rowData.facilityCd,
          baseDate: dayjs(rowData.cancelDate).format("YYYY-MM-DD"),
          procClass: pClass
        };

        // ダウンロードAPIをコール
        const response = await ApiHelper.configPost("/facilities/downloadBackup", payload, {
            responseType: "blob"
          })
          .catch(async error => {
            //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
            getErrorMessage('MstFacilityMainComponent.vue', 'onClickDownloadBackup', '${rowData.facilityName}様のバックアップファイルのダウンロードに失敗しました。');
            //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
            await this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "ダウンロード失敗",
              // message: `${rowData.facilityName}様のバックアップファイルのダウンロードに失敗しました。`
              title: DIALOG_MESSAGES['00200058'].title,
              message: messageFormat(DIALOG_MESSAGES['00200058'].message, rowData.facilityName),
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            });
            //共通ローダー：表示終了
            this.setLoadingScreenVisible(false);
            throw new Error(error);
          });

        if (response.status === 200) {
          const backupBlob = new Blob([response.data], {
            type: "application/zip"
          });
          triggerScopedDownload({
            blob: backupBlob,
            filename: rowData.facilityName + "様_backup.zip",
            root: this.$el
          });
        }

        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
      } else {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
      }
    },
    onDataBoundKendoGrid(ev) {
      if (this.scrollPosition.top > 0 || this.scrollPosition.left > 0) {
        this.restoreDirectGridScrollPosition();
      }
      this.$nextTick(() => {
        if (this.scrollPosition.top > 0 || this.scrollPosition.left > 0) {
          this.restoreDirectGridScrollPosition();
        }
        this.applyDirectGridLegacyStyleContract();
        this.mountFacilityCancelActionTemplates();
        this.runLockedRowSync();
        requestAnimationFrame(() => {
          this.applyDirectGridLegacyStyleContract();
          this.mountFacilityCancelActionTemplates();
          this.runLockedRowSync();
          requestAnimationFrame(() => {
            this.runLockedRowSync();
          });
          if (this.getGridHeaderEl()?.classList != null) {
            this.editBackgroundColor();
            this.editFacilityCancel();
          }
        });
      });
    },
  }
};
</script>

<!-- 個別スタイル定義 -->
<style scoped>
.right {
  text-align: right;
}
.header-btn-area {
  height: auto;
  padding: 0.1em 0.1em 0.1em 0.1em;
}
/* main-content-area の外側縦スクロールを抑え、Grid 内のみスクロールさせる */
.main-content-area.master-maintenance-page {
  overflow: hidden;
}
.ntss-list {
  position: relative;
  overflow: hidden;
}
#grid-footer {
  margin: 0;
  padding: 5px;
  bottom: 0;
  position: absolute;
  width: inherit;
}
.kendo-grid-toolbar-style {
  --height: 200px;
  height: var(--height);
  border-bottom: none;
}
.toolbar-btn {
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  width: auto;
}
.cancelled-action {
  padding-left: 0 !important;
  border-left: 0 !important;
}
.kendo-grid-toolbar-style {
  padding: 0.1em 0.3em;
}
.kendo-grid-toolbar-style span {
  margin: 0;
}
.kendo-grid-toolbar-style :deep(.k-grid-header-locked > table) {
  border-right-width: 0px;
}
.kendo-grid-toolbar-style :deep(.k-grid-header-locked) {
  border-right: 1px solid var(--ntss-list-border-color) !important;
}
.kendo-grid-toolbar-style :deep(.k-grid-content-locked) {
  z-index: 1;
  box-shadow: 1px 0px 0px 0px var(--ntss-border-color) !important;
}
input[type="time"]::-webkit-calendar-picker-indicator {
  display: none;
}
input[type="date"]::-webkit-calendar-picker-indicator {
  display: none;
}
.k-icon.k-i-calendar {
    display: none;
}
.custom-switch {
  transform: scale(0.85);
  transform-origin: center;
  touch-action: manipulation;
}
.kendo-grid-toolbar-style :deep(.k-grid-content-locked) {
  overflow-y: hidden !important;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: none;
  -ms-overflow-style: none;
}
.kendo-grid-toolbar-style :deep(.k-grid-content),
.kendo-grid-toolbar-style :deep(.k-grid-content-locked) {
  overflow-anchor: none;
}
.kendo-grid-toolbar-style :deep(.k-grid-content-locked::-webkit-scrollbar) {
  display: none;
}
/* 解約アクション列: 2.4em ボタン表示を保ちつつ行高への影響を抑える */
.kendo-grid-toolbar-style :deep(.mst-facility-cancel-action-host) {
  display: inline-block;
  line-height: 0;
  vertical-align: middle;
}
.mobile-header {
  min-height: 30px; /* モバイル用の高さ */
}

/* Vue2 kendo-grid wrapper style contract for this direct jq screen. */
.kendo-grid-toolbar-style :deep(.toolbar-btn),
.kendo-grid-toolbar-style :deep(.toolbar-btn *) {
  font-family: inherit;
}
.kendo-grid-toolbar-style :deep(.k-grid-header th),
.kendo-grid-toolbar-style :deep(.k-grid-header .k-table-th),
.kendo-grid-toolbar-style :deep(.k-grid-header .k-link),
.kendo-grid-toolbar-style :deep(.k-grid-header-locked th),
.kendo-grid-toolbar-style :deep(.k-grid-header-locked .k-table-th),
.kendo-grid-toolbar-style :deep(.k-grid-header-locked .k-link) {
  border-right-color: currentColor;
  cursor: default;
}



/* Vue2 Kendo locked layout contract.
   Kendo 2026 renders locked content inside flex containers; keep the locked area
   at the width Kendo/column definitions already calculated, as Kendo 2019 did. */
:deep(.k-grid-lockedcolumns .k-grid-header-locked),
:deep(.k-grid-lockedcolumns .k-grid-content-locked),
:deep(.k-grid-lockedcolumns .k-grid-footer-locked) {
  flex: 0 0 auto;
  flex-shrink: 0;
}
</style>
