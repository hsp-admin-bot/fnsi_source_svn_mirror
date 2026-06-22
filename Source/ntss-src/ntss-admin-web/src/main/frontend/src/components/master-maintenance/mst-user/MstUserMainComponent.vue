/**
 * 利用者マスタメンテナンスデータページ  MainContent
 */
<template>
  <div class="main-content-area master-maintenance-page">
    <div class="ntss-list" :style="ntssListStyles">
      <div class="k-grid-toolbar k-header kendo-grid-toolbar-style" :style="heightStyles">
        <div id="grid-header" :class="['header-btn-area', isMobileDevice ? 'mobile-header' : '']" style="display: flex; align-items: center; gap: 1em;">
          <v-ons-button class="btn3-normal toolbar-btn" @click="dispModalAddUser()">追加</v-ons-button>
          <div v-show="isMobileDevice" style="display: flex; align-items: center; min-width: 7em; height: 2em;">
            <label class="fab-font-color" style="margin-right: 0.5em;">編集</label>
            <v-ons-switch modifier="outline" v-model="allowEdit" />
          </div>
        </div>
        <div
          v-show="columns.length > 1"
          id="grid-font-size"
          ref="gridRoot"
          :class="[fontSizeSet, 'ntss-kendo-grid-legacy', 'mst-user-direct-jq-grid']"
          style="clear: both;"
        ></div>
      </div>
      <!-- 高さ調整 -->
      <div id="grid-footer"></div>
      <div v-if="messageDialogInfo.isDialogVisible">
        <message-dialog
          v-model:visible="messageDialogInfo.isDialogVisible"
          :message-cd="messageDialogInfo.messageCd"
          :type="messageDialogInfo.type"
          :string-params="messageDialogInfo.stringParams"
          @confirm="confirm"
        />
      </div>
    </div>
  </div>
</template>

<script>
import $$ from "@/compat/jquery";
import $ from "jquery";
import kendo from "@progress/kendo-ui";
import { markRaw, toRaw } from "@/compat/vue/runtime";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
import { EventBus } from "@/compat/vue/event-bus.js";
import { sendRequestGetMstFacilityHashByFacilityCd } from "@/apis/mst-facility-hash";
// add 2020-09-25 FNSI-4200ポートを使用している 孫 start
import { ApiHelper } from "@/apis/AxiosHelper";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// add 2020-09-25 FNSI-4200ポートを使用している 孫 end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
// add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen start
import { getMstJob } from "@/functions/mst/MstGetters.js";
import { MSG_SETTING_REFLECTION } from "@/constants/masterMaintenanceConstants";
import { sendRequestGetMstFacilitySettingValue } from "@/apis/facility-setting";
import { PERMISSION_CHANGE_SIGNOUT } from "@/constants/facilitySetting";
import { getUserMenuElement, getNotificationUnreadCountElement } from "@/functions/common/LayoutMeasureHelper";
// add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen end

// add 2020-09-25 FNSI-4200ポートを使用している 孫 start
const uriGetCardAppPort = `/card_state/get_card_app_ports`;
// add 2020-09-25 FNSI-4200ポートを使用している 孫 end

const MST_USER_GRID_CELL_INDEX = Object.freeze({
  ADMIN: 4,
  USE_FUNCTION: 5,
  EDIT_AUTHORITY: 6,
  ID_PW_RESET: 7,
  PATIENT_SHARED: 8,
  LOCK_RELEASE: 9,
  JOB: 10,
  SECRET_KEY: 32,
  CARD_DISABLE: 33,
  DELETE: 35
});

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

function getDirectGridDataItem(grid, row) {
  return grid?.dataItem?.(row) || null;
}

function getDirectGridCellIndex(grid, container) {
  const cell = container?.[0] || container;
  if (!cell) {
    return -1;
  }
  if (typeof cell.cellIndex === "number") {
    return cell.cellIndex;
  }
  const ariaIndex = Number(cell.getAttribute?.("aria-colindex"));
  if (Number.isFinite(ariaIndex) && ariaIndex > 0) {
    return ariaIndex - 1;
  }
  const cells = Array.from(cell.parentElement?.children || []);
  return cells.indexOf(cell);
}

const DIRECT_GRID_REMS_ONLY_RUNTIME_HIDDEN_TITLES = new Set([
  "利用者カナ名_姓",
  "利用者カナ名_名",
  "利用者英字名_姓",
  "利用者英字名_名",
  "メールアドレス1",
  "メールアドレス2",
  "内線番号",
  "自宅番号",
  "携帯番号",
  "FAX番号",
  "郵便番号7",
  "自宅住所"
]);

export default {
  components: {
    "message-dialog": messageDialog
  },  data() {
    return {
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
        recordName: ""
      },
      kendoGridToolbarHeight: 500,
      kendoGridHeight: 300,
      columnWidth: 14,
      kendoValidatorSetup: {
        rules: {},
        messages: {}
      },
      facilitylistValue: "",
      messageDialogInfo: {
        isDialogVisible: false,
        messageCd: "",
        type: "1",
        stringParams: [""]
      },
      delUserId: -1,
      //Android端末で編集中であることを示すフラグ
      editingFlg: false,
      androidFlg: false,
      iosFlg: false,
      //自画面の名称
      selfScreenName: "",
      isCardDeviceConnected: false,
      socketInterval: null,
      // 選択施設のシステム利用設定
      facilitySysUseSetting: "",
      // add #9764  by zhangruixue 2023-09-04 --start
      failureCnt: 5,
      accountLockSetting: 1,
      // add #9764  by zhangruixue 2023-09-04 --end
      // 追加フラグ
      addFlg: false,
      tmpAddFlg: false,
      __pendingScrollToAddedRow: false,
      // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen start
      allMstJob: [],
      mstJobBeforeChange: [],
      signoutFlg: false,
      // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen end
      // スクロール位置
      scrollPosition: {
        top: 0,
        left: 0
      },
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
      directGridWidget: null,
      directGridMounted: false,
      directGridDataSource: null,
      directGridMasterDataRef: null,
      directGridMasterDataSignature: "",
      directGridLayoutRafId: null,
      directGridFilterRefreshRafId: null,
      directGridColumnVisibilityRafId: null,
      directGridDestroyTimerId: null,
      directGridRowVisualRafIds: markRaw(new Map()),
      directGridStructuralColumnsSignature: "",
      directGridDomClassKey: null,
      directGridLastHeight: null,
      kendoValidator: null
    };
  },
  computed: {
    // #8745 【デグレ】マスタにて追加をし行が増えると縦横のスクロールが発生する。テキストボックスが切れる。 林峻峰 start
    // ...mapGetters("master-maintenance", ["getFacilitySwitch"]),
    ...mapGetters("master-maintenance", {
      getFacilitySwitch: "getFacilitySwitch",
      masterPhysicalName: "getMasterName",
    }),
    // #8745 【デグレ】マスタにて追加をし行が増えると縦横のスクロールが発生する。テキストボックスが切れる。 林峻峰 end
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    ...mapGetters("user", {
      getSystemUseSetting: "getSystemUseSetting",
      facilityCd: "getFacilityCd",
      getAccountLockSetting: "getAccountLockSetting",
      getFailureCnt: "getFailureCnt"
    }),
    ...mapGetters("websocket-card", ["getSocketIsConnected", "getSocketMessages", "getCardDeviceStatus"]),
    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },
    ntssListStyles() {
      return { display: this.columns.length === 1 ? "none" : "inherit" };
    },
    fontSizeSet() {
      const names = ["small", "medium", "large", "x-large"];
      return `font-size-set-${names[this.getFontSize] || "medium"}`;
    },
    masterConditionSignature() {
      const condition = this.$store?.state?.["mst-user"]?.condition || this.condition || {};
      return `${condition.recordName || ""}|${this.facilitylistValue || ""}`;
    },
    ...mapGetters("mst-user", {
      getFilteredMasterRecordList: "getFilteredMasterRecordList",
      getIsDispCreateCard: "getIsDispCreateCard"
    }),
    ...mapGetters("mst-facility-setting",{ getValueSignIn: "getValueSignIn" }),
    ...mapGetters("mst-user", { getUserOTP: "getUserOTP" }),
    masterRecords() {
      // storeからデータを取得
      return this.getFilteredMasterRecordList;
    },
    hiddenDispCreateCard() {
      return this.getIsDispCreateCard ? false : true;
    },
    isOwnFacility() {
      return this.facilitylistValue === this.getStateUserAccountInfo.facilityCd;
    },
    isRemsOnly() {
      return this.getSystemUseSetting === "1";
    },
    //バリューサインインを取得
    valueSignIn(){
      return this.getValueSignIn;
    },
    //ユーザーOTPの取得
    userOTP(){
      return this.getUserOTP;
    },
    isMobileDevice() {
      return this.iosFlg || this.androidFlg;
    },
  },
  watch: {
    windowHeight() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
      this.scheduleDirectGridLayoutContract();
    },
    windowWidth() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
      this.scheduleDirectGridLayoutContract();
    },
    isDispMenu() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
      this.scheduleDirectGridLayoutContract();
    },
    getFontSize() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
      this.scheduleDirectGridLayoutContract();
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
              this.setLoadingScreenVisible(false);
              if (JSON.parse(splitMsg[2].toLowerCase()) == true) {
                this.$ons.notification.alert({
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                  // title: "保存成功",
                  // message: "カード情報が</br>保存されました。"
                  title: DIALOG_MESSAGES[12000291].title,
                  message: messageFormat(DIALOG_MESSAGES[12000291].message)
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                });
                this.findList();
              } else {
                this.$ons.notification.alert({
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                  // title: "保存失敗",
                  // message: "カードの書き込みに失敗しました。"
                  title: DIALOG_MESSAGES["00200103"].title,
                  message: messageFormat(DIALOG_MESSAGES["00200103"])
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                });
              }
              this.clearSocketMessage();
              break;
          }
        }
      }
    },
    columns(val) {
      this.$nextTick(() => {
        if (val.length > 1) {
          this.setLoadingScreenVisible(false);
          if (!this.directGridWidget) {
            this.initDirectGridIfReady();
          } else {
            this.applyDirectGridColumnsContract();
          }
          this.scheduleDirectGridLayoutContract();
        }
      });
    },
    masterConditionSignature() {
      this.scheduleDirectGridFilterRefresh();
    },
    isCardDeviceConnected() {
      this.scheduleDirectGridColumnVisibilitySync();
    },
    hiddenDispCreateCard() {
      this.scheduleDirectGridColumnVisibilitySync();
    },
    isRemsOnly() {
      this.scheduleDirectGridColumnVisibilitySync();
    },
    isOwnFacility() {
      // Vue2 wrapper と同じく editable は関数評価に寄せるため、列再構築はしない。
    }
  },
  methods: {
    ...mapActions("multi-modal", [
      "showUserMasterIdReset",
      "showUserMasterAuthFunction",
      "showUserMasterEditAuthority"
    ]),
    ...mapActions("mst-user", [
      "getUserDataList",
      "facilityList",
      "setCondition",
      "sendRequestAddNewUser",
      "sendRequestUpdateAdministratorFlg",
      "sendRequestUpdatePatientSharedFlg",
      "sendRequestUpdatePassword",
      "sendRequestUpdateFailureCnt",
      "sendRequestDeleteUser",
      "setUserData",
      "mstJobList",
      "sendRequestUpdateJobCd",
      "getDispCreateCard",
      "sendRequestUpdateUserPersonalInfo",
      "sendRequestDisableAccessCard",
      "sendRequestDeleteSecretKey"
    ]),
    ...mapActions("account-edit", [
      "clearCard",
      "setCard",
      "getUserAccountInfo"
    ]),
    // mod FNSI-4200ポートを使用している 孫 start
    //...mapActions("websocket-card", ["connect", "sendSocketMessage", "close", "clearSocketMessage"]),
    ...mapActions("websocket-card", ["init", "connect", "sendSocketMessage", "close", "clearSocketMessage"]),
    // mod FNSI-4200ポートを使用している 孫 end
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    ...mapActions("mst-facility-setting", ["sendRequestGetValueSignInByFacilityCd"]),
    ...mapActions("mst-user",["sendRequestCreateMstUserOTP",
                              "sendRequestUpdateSecretKey",
                              "sendRequestUpdateIsSetQrCode"]),
    getMasterOwnerWindow(element = null) {
      return element?.ownerDocument?.defaultView || this.$el?.ownerDocument?.defaultView || window;
    },
    getGridRootEl() {
      return this.$refs.gridRoot || null;
    },
    getGridWidget() {
      return this.directGridWidget || null;
    },
    getGridHeaderEl() {
      return this.getGridRootEl()?.querySelector?.(".k-grid-header") || null;
    },
    getGridTableEl() {
      return this.directGridWidget?.table?.[0] || this.getGridRootEl()?.querySelector?.(".k-grid-content table") || null;
    },
    getGridTbodyEl() {
      return this.directGridWidget?.tbody?.[0] || this.getGridRootEl()?.querySelector?.(".k-grid-content tbody") || null;
    },
    getGridLockedBodyRows() {
      return Array.from(this.getGridRootEl()?.querySelectorAll?.(".k-grid-content-locked tbody tr") || []);
    },
    getGridScrollContainer() {
      return this.getGridRootEl()?.querySelector?.(".k-grid-content") || null;
    },
    getGridScrollPosition() {
      const content = this.getGridScrollContainer();
      return { top: content?.scrollTop || 0, left: content?.scrollLeft || 0 };
    },
    getGridDataSource() {
      return this.directGridWidget?.dataSource || this.directGridDataSource || null;
    },
    dispatchDirectGridContentScroll() {
      const content = this.getGridScrollContainer();
      if (!content) {
        return;
      }
      try {
        content.dispatchEvent(new Event("scroll", { bubbles: true }));
      } catch (_error) {
        // noop
      }
      try {
        $(content).trigger("scroll");
      } catch (_error) {
        // noop
      }
    },
    setGridScrollPosition(position = {}) {
      const content = this.getGridScrollContainer();
      if (!content) {
        return;
      }
      const top = position.top ?? 0;
      const left = position.left ?? 0;
      content.scrollTop = top;
      content.scrollLeft = left;
      const headerWrap = this.getGridRootEl()?.querySelector?.(".k-grid-header-wrap");
      if (headerWrap) {
        headerWrap.scrollLeft = left;
      }
      const grid = this.directGridWidget;
      if (typeof grid?._scrollLeft !== "undefined") {
        grid._scrollLeft = left;
      }
      this.syncDirectGridLockedScrollPosition(top);
      this.dispatchDirectGridContentScroll();
    },
    scrollGridToAddedRow() {
      const content = this.getGridScrollContainer();
      if (!content) {
        return;
      }
      const top = Math.max(0, content.scrollHeight - content.clientHeight);
      this.setGridScrollPosition({ top, left: 0 });
      this.scrollPosition.top = top;
      this.scrollPosition.left = 0;
    },
    scheduleGridScrollToAddedRow() {
      const apply = () => this.scrollGridToAddedRow();
      apply();
      this.$nextTick(() => {
        apply();
        requestAnimationFrame(apply);
        [32, 80, 180].forEach((ms) => setTimeout(apply, ms));
      });
    },
    isMasterGridEditInteractionActive() {
      return !!this.getGridRootEl()?.querySelector?.(".k-grid-edit-row,.k-edit-cell,input:focus,textarea:focus");
    },
    measureMasterElementHeight(element, defaultValue = 0) {
      if (!element) {
        return defaultValue;
      }
      const clientHeight = element.clientHeight;
      if (Number.isFinite(clientHeight) && clientHeight > 0) {
        return clientHeight;
      }
      const rectHeight = element.getBoundingClientRect?.().height;
      if (Number.isFinite(rectHeight) && rectHeight > 0) {
        return rectHeight;
      }
      const rectTop = element.getBoundingClientRect?.().top;
      const childBottoms = Array.from(element.children || [])
        .map(child => child.getBoundingClientRect?.())
        .filter(Boolean)
        .map(rect => rect.bottom)
        .filter(value => Number.isFinite(value));
      if (Number.isFinite(rectTop) && childBottoms.length) {
        const visualHeight = Math.max(...childBottoms) - rectTop;
        if (Number.isFinite(visualHeight) && visualHeight > 0) {
          return visualHeight;
        }
      }
      return defaultValue;
    },
    getMasterLayoutElements() {
      const root = this.$el || null;
      const ownerDocument = root?.ownerDocument || document;
      const headers = Array.from(ownerDocument.getElementsByClassName?.("header") || []);
      return {
        header: headers.length ? headers[headers.length - 1] : ownerDocument.querySelector?.(".header") || null,
        footerMenu: ownerDocument.getElementById?.("footer-menu") || null,
        gridHeader: root?.querySelector?.("#grid-header") || null,
        gridFooter: root?.querySelector?.("#grid-footer") || null,
        headerButtonArea: root?.querySelector?.(".header-btn-area") || null,
        mainContentArea: root?.querySelector?.(".main-content-area") || root || null,
        mainId: root?.closest?.("#main-id") || ownerDocument.getElementById?.("main-id") || null
      };
    },
    getMasterCssPixelValue(element, propertyName) {
      if (!element || !propertyName) {
        return NaN;
      }
      const ownerWindow = element.ownerDocument?.defaultView || window;
      const inlineValue = element.style?.getPropertyValue?.(propertyName);
      const computedValue = ownerWindow.getComputedStyle?.(element)?.getPropertyValue?.(propertyName);
      const parsed = parseFloat(String(inlineValue || computedValue || "").replace("px", ""));
      return Number.isFinite(parsed) ? parsed : NaN;
    },
    getMasterMainContentBaseHeight() {
      const elements = this.getMasterLayoutElements();
      const cssHeight = this.getMasterCssPixelValue(elements.mainId, "--height");
      if (Number.isFinite(cssHeight) && cssHeight > 0) {
        return cssHeight - 5;
      }
      const measuredHeight = this.measureMasterElementHeight(elements.mainContentArea, NaN);
      return Number.isFinite(measuredHeight) && measuredHeight > 0 ? measuredHeight : NaN;
    },
    getMasterHeaderButtonAreaHeight(defaultValue = 0) {
      const elements = this.getMasterLayoutElements();
      const measuredHeight = this.measureMasterElementHeight(elements.headerButtonArea, NaN);
      if (Number.isFinite(measuredHeight) && measuredHeight > 0) {
        return measuredHeight;
      }
      const root = this.getGridRootEl();
      const toolbar = root?.closest?.(".k-grid-toolbar");
      if (root && toolbar) {
        const toolbarTop = toolbar.getBoundingClientRect?.().top;
        const gridTop = root.getBoundingClientRect?.().top;
        const diff = gridTop - toolbarTop;
        if (Number.isFinite(diff) && diff > 0) {
          return diff;
        }
      }
      return defaultValue;
    },
    calculateColumnsWidth() {
      const appWidth = this.$el?.ownerDocument?.defaultView?.innerWidth || window.innerWidth || 0;
      this.columnWidth = appWidth > 1000 ? 14 : 9;
      this.columnWidth = this.columnWidth > 11 ? this.columnWidth : 11;
    },
    calculateGridHeight() {
      if (this.editingFlg || this.isMasterGridEditInteractionActive()) {
        return false;
      }
      const elements = this.getMasterLayoutElements();
      const ownerWindow = this.getMasterOwnerWindow?.(this.getGridRootEl?.()) || window;
      const wh = Number(this.windowHeight) || ownerWindow.innerHeight || 0;
      const hh = this.measureMasterElementHeight(elements.header, 0);
      const fmh = (this.isDispMenu === 1 ? this.measureMasterElementHeight(elements.footerMenu, 0) : 0) + 5;
      let kendoToolbarHeight = wh - hh - fmh;
      const mainContentBaseHeight = this.getMasterMainContentBaseHeight();
      if (Number.isFinite(mainContentBaseHeight) && mainContentBaseHeight > 0) {
        kendoToolbarHeight = Math.min(kendoToolbarHeight, mainContentBaseHeight);
      }
      const root = this.getGridRootEl();
      const toolbarElement = root?.closest?.(".k-grid-toolbar") || elements.headerButtonArea?.closest?.(".k-grid-toolbar") || null;
      const toolbarTop = toolbarElement?.getBoundingClientRect?.().top;
      const footerTop = this.isDispMenu === 1
        ? elements.footerMenu?.getBoundingClientRect?.().top
        : ownerWindow.innerHeight;
      const availableByActualTop = (Number.isFinite(toolbarTop) && Number.isFinite(footerTop))
        ? footerTop - toolbarTop - 5
        : NaN;
      if (Number.isFinite(availableByActualTop) && availableByActualTop > 100) {
        kendoToolbarHeight = Math.min(kendoToolbarHeight, availableByActualTop);
      }
      this.kendoGridToolbarHeight = Math.max(100, kendoToolbarHeight);
      const toolbarHeight = this.getMasterHeaderButtonAreaHeight(0);
      const gridFooter = this.measureMasterElementHeight(elements.gridFooter, 0);
      this.kendoGridHeight = Math.max(120, this.kendoGridToolbarHeight - toolbarHeight - gridFooter);
      if (root) {
        root.style.height = `${this.kendoGridHeight}px`;
      }
      return true;
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
        const nextHeight = Number(this.kendoGridHeight) || 0;
        if (nextHeight > 0 && this.directGridLastHeight !== nextHeight) {
          this.directGridLastHeight = nextHeight;
          grid.wrapper?.height?.(nextHeight);
          grid.element?.height?.(nextHeight);
          if (typeof grid.setOptions === "function") {
            grid.setOptions({ height: nextHeight });
          }
        }
        grid.resize?.(true);
        this.applyDirectGridLockedWidthContract();
        this.applyDirectGridLockedHeightContract();
      } catch (_error) {
        // direct jq では resize 失敗時に rebuild しない。
      }
    },
    getDirectGridDataSourceOption() {
      const source = toRaw(this.masterRecords || {}) || {};
      const sourceData = toRaw(source.data);
      return markRaw({
        ...source,
        data: Array.isArray(sourceData) ? sourceData : [],
        schema: toRaw(source.schema),
        model: toRaw(source.model)
      });
    },
    getDirectGridDataSignature(data = null) {
      const rows = Array.isArray(data) ? data : [];
      if (rows.length === 0) {
        return "0";
      }
      const first = rows[0]?.userId || rows[0]?.uid || "";
      const last = rows[rows.length - 1]?.userId || rows[rows.length - 1]?.uid || "";
      const authorityDigest = rows
        .map(row => `${row.userId || row.uid || ""}:${(row.authorities || []).join(",")}`)
        .join("|");
      return `${rows.length}:${first}:${last}:${authorityDigest}`;
    },
    refreshGridDataFromStore() {
      this.refreshDirectGridDataFromMasterRecords(false);
    },
    createDirectGridDataSource() {
      const options = this.getDirectGridDataSourceOption();
      this.directGridMasterDataRef = options.data;
      this.directGridMasterDataSignature = this.getDirectGridDataSignature(options.data);
      this.directGridDataSource = markRaw(new kendo.data.DataSource(options));
      return this.directGridDataSource;
    },
    resolveDirectGridColumn(column) {
      const gridColumn = { ...column };
      const title = column.title;
      if (title === "管理者") {
        gridColumn.attributes = { class: "btn1-kendo-execute" };
        gridColumn.command = { text: "管理者", click: event => this.changeAdmin(event) };
      } else if (title === "使用許可機能") {
        gridColumn.attributes = { class: "btn3-kendo-normal" };
        gridColumn.command = { text: "設定", click: event => this.dispModalUseFunction(event) };
      } else if (title === "編集権限") {
        gridColumn.attributes = { class: "btn3-kendo-normal" };
        gridColumn.command = { text: "編集権限", click: event => this.dispModalEditAuthority(event) };
      } else if (title === "ID/PWリセット") {
        gridColumn.attributes = { class: "btn4-kendo-alert" };
        gridColumn.command = { text: "リセット", click: event => this.dispModalIdReset(event) };
      } else if (title === "患者共有") {
        gridColumn.hidden = true;
        gridColumn.attributes = { class: "btn3-kendo-normal" };
        gridColumn.command = { text: "表示", click: event => this.changePatientSharedReset(event) };
      } else if (title === "ロック解除") {
        gridColumn.attributes = { class: "btn3-kendo-normal" };
        gridColumn.command = { text: "解除", click: event => this.resetLoginFailCnt(event) };
      } else if (title === "削除") {
        gridColumn.attributes = { class: "btn4-kendo-alert" };
        gridColumn.command = { text: "削除", click: event => this.delUser(event) };
      } else if (title === "カード作成") {
        gridColumn.hidden = this.getDirectGridRuntimeHiddenState(gridColumn);
        gridColumn.attributes = { class: "btn3-kendo-normal" };
        gridColumn.command = { text: "カード作成", click: event => this.createCard(event) };
      } else if (title === "カード無効化") {
        gridColumn.attributes = { class: "btn4-kendo-alert" };
        gridColumn.editable = column.values;
        gridColumn.command = { text: "無効化", click: event => this.disableCard(event) };
      } else if (["利用者カナ名_姓", "利用者カナ名_名", "利用者英字名_姓", "利用者英字名_名", "内線番号"].includes(title) || title.indexOf("連携コード") > -1) {
        gridColumn.hidden = this.getDirectGridRuntimeHiddenState(gridColumn);
        gridColumn.editable = () => this.isOwnFacility;
      } else if (["メールアドレス1", "メールアドレス2", "自宅番号", "携帯番号", "FAX番号", "郵便番号7", "自宅住所"].includes(title)) {
        gridColumn.hidden = this.getDirectGridRuntimeHiddenState(gridColumn);
      } else if (title === "秘密鍵") {
        gridColumn.attributes = { class: "btn4-kendo-alert" };
        gridColumn.command = { text: "廃棄", click: event => this.deleteKey(event) };
      }
      return gridColumn;
    },
    buildDirectGridColumns() {
      return (toRaw(this.columns) || []).map(column => this.resolveDirectGridColumn(toRaw(column)));
    },
    getDirectGridRuntimeHiddenState(column) {
      const title = column?.title || "";
      if (title === "カード作成") {
        return this.hiddenDispCreateCard ? true : !this.isCardDeviceConnected;
      }
      if (DIRECT_GRID_REMS_ONLY_RUNTIME_HIDDEN_TITLES.has(title) || title.indexOf("連携コード") > -1) {
        return this.isRemsOnly;
      }
      return null;
    },
    getDirectGridStructuralColumnsSignature(columns = this.columns) {
      return (toRaw(columns) || []).map(rawColumn => {
        const column = toRaw(rawColumn) || {};
        const runtimeHidden = this.getDirectGridRuntimeHiddenState(column);
        const hidden = runtimeHidden === null ? !!column.hidden : "runtime";
        const values = Array.isArray(column.values)
          ? column.values.map(value => `${value?.value ?? ""}:${value?.text ?? ""}`).join(",")
          : "";
        return [
          column.field || "",
          column.title || "",
          hidden,
          column.locked ? 1 : 0,
          column.width || "",
          column.format || "",
          values
        ].join(":");
      }).join("|");
    },
    initDirectGridIfReady() {
      const root = this.getGridRootEl();
      if (!this.directGridMounted || !root || this.columns.length <= 1) {
        return false;
      }
      if (this.directGridWidget) {
        this.scheduleDirectGridColumnVisibilitySync();
        this.scheduleDirectGridFilterRefresh();
        this.scheduleDirectGridLayoutContract();
        return false;
      }
      installComponentJQuery();
      $(root).empty();
      this.directGridDomClassKey = null;
      this.directGridLastHeight = null;
      $(root).kendoGrid({
        dataSource: this.createDirectGridDataSource(),
        editable: true,
        selectable: true,
        reorderable: false,
        height: this.kendoGridHeight,
        scrollable: true,
        beforeEdit: event => this.onBeforeEdit(event),
        cellClose: event => this.editEnd(event),
        save: event => this.onDirectGridSave(event),
        dataBound: event => this.onDataBoundKendoGrid(event),
        columns: this.buildDirectGridColumns()
      });
      this.directGridWidget = markRaw($(root).data("kendoGrid"));
      this.directGridStructuralColumnsSignature = this.getDirectGridStructuralColumnsSignature();
      this.installDirectGridFacade();
      this.scheduleDirectGridColumnVisibilitySync();
      this.applyDirectGridLegacyStyleContract();
      this.scheduleDirectGridLayoutContract();
      return true;
    },
    installDirectGridFacade() {
      const root = this.getGridRootEl();
      if (!root) {
        return;
      }
      root.kendoWidget = () => this.directGridWidget;
      root.gridWidget = () => this.directGridWidget;
      root.gridRootEl = () => root;
      root.gridContentEl = () => this.getGridScrollContainer();
      root.gridAutoScrollableEl = () => this.getGridScrollContainer();
      root.gridDataItem = row => this.directGridWidget?.dataItem?.(row);
      root.scrollGridTo = position => this.setGridScrollPosition(position);
    },
    destroyDirectGrid(options = {}) {
      const defer = !!options.defer;
      const grid = this.directGridWidget;
      const root = this.getGridRootEl();
      const destroyWidget = () => {
        if (grid) {
          try {
            grid.destroy();
          } catch (_error) {
            // noop
          }
        }
        if (root?.isConnected) {
          try {
            $(root).empty();
          } catch (_error) {
            // noop
          }
        }
      };
      this.directGridWidget = null;
      this.directGridDataSource = null;
      this.directGridMasterDataRef = null;
      this.directGridMasterDataSignature = "";
      this.directGridStructuralColumnsSignature = "";
      this.directGridDomClassKey = null;
      this.directGridLastHeight = null;
      if (!grid && !root) {
        return;
      }
      if (defer) {
        const ownerWindow = root?.ownerDocument?.defaultView || window;
        this.directGridDestroyTimerId = ownerWindow.setTimeout(() => {
          this.directGridDestroyTimerId = null;
          destroyWidget();
        }, 0);
        return;
      }
      destroyWidget();
    },
    applyDirectGridColumnsContract() {
      const grid = this.directGridWidget;
      if (!grid) {
        return;
      }
      const nextSignature = this.getDirectGridStructuralColumnsSignature();
      if (this.directGridStructuralColumnsSignature !== nextSignature) {
        const nextColumns = this.buildDirectGridColumns();
        grid.setOptions({ columns: nextColumns });
        this.directGridStructuralColumnsSignature = nextSignature;
        this.directGridDomClassKey = null;
        this.installDirectGridFacade();
        this.scheduleDirectGridColumnVisibilitySync();
        this.scheduleDirectGridLayoutContract();
        return;
      }
      const nextColumns = this.buildDirectGridColumns();
      nextColumns.forEach(nextColumn => {
        const target = (grid.columns || []).find(column => column.field === nextColumn.field && column.title === nextColumn.title);
        if (!target) {
          return;
        }
        target.editable = nextColumn.editable;
        target.attributes = nextColumn.attributes;
        target.command = nextColumn.command;
      });
      this.scheduleDirectGridColumnVisibilitySync();
      this.applyDirectGridLockedWidthContract();
      this.applyDirectGridLockedHeightContract();
    },
    scheduleDirectGridColumnVisibilitySync() {
      if (!this.directGridWidget) {
        return;
      }
      if (this.directGridColumnVisibilityRafId != null) {
        cancelAnimationFrame(this.directGridColumnVisibilityRafId);
      }
      this.directGridColumnVisibilityRafId = requestAnimationFrame(() => {
        this.directGridColumnVisibilityRafId = null;
        this.syncDirectGridColumnVisibilityContract();
      });
    },
    syncDirectGridColumnVisibilityContract() {
      const grid = this.directGridWidget;
      if (!grid) {
        return;
      }
      let changed = false;
      (grid.columns || []).forEach((column, index) => {
        const runtimeHidden = this.getDirectGridRuntimeHiddenState(column);
        if (runtimeHidden === null || column.hidden === runtimeHidden) {
          return;
        }
        if (runtimeHidden) {
          grid.hideColumn(index);
        } else {
          grid.showColumn(index);
        }
        column.hidden = runtimeHidden;
        changed = true;
      });
      if (changed) {
        this.directGridDomClassKey = null;
        this.applyDirectGridLockedWidthContract();
        this.applyDirectGridLockedHeightContract();
        this.scheduleDirectGridLayoutContract();
      }
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
        this.refreshDirectGridDataFromMasterRecords(true);
      });
    },
    refreshDirectGridDataFromMasterRecords(resetScroll = false) {
      const grid = this.directGridWidget;
      if (!grid?.dataSource) {
        return;
      }
      const source = this.getDirectGridDataSourceOption();
      const nextData = source.data || [];
      const nextSignature = this.getDirectGridDataSignature(nextData);
      const isSameMasterData = this.directGridMasterDataRef === nextData
        && this.directGridMasterDataSignature === nextSignature;
      if (!isSameMasterData) {
        this.directGridDomClassKey = null;
        this.directGridMasterDataRef = nextData;
        this.directGridMasterDataSignature = nextSignature;
        grid.dataSource.data(nextData);
      }
      if (resetScroll) {
        this.setGridScrollPosition({ top: 0, left: 0 });
      }
      this.$nextTick(() => this.applyDirectGridLegacyStyleContract());
    },
    applyDirectGridLockedWidthContract() {
      const root = this.getGridRootEl();
      if (!root) {
        return;
      }
      const lockedWidth = (this.columns || []).reduce((sum, column) => {
        if (!column.locked || column.hidden) {
          return sum;
        }
        const width = `${column.width || ""}`.trim();
        const fontSize = parseFloat(getComputedStyle(root).fontSize || "16") || 16;
        if (width.endsWith("em")) {
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
    },
    applyDirectGridLockedHeightContract() {
      const content = this.getGridScrollContainer();
      const lockedContent = this.getGridRootEl()?.querySelector?.(".k-grid-content-locked");
      if (!content || !lockedContent) {
        return;
      }
      lockedContent.style.height = `${content.clientHeight}px`;
      lockedContent.style.maxHeight = `${content.clientHeight}px`;
    },
    syncDirectGridLockedScrollPosition(scrollTop = null) {
      const lockedContent = this.getGridRootEl()?.querySelector?.(".k-grid-content-locked");
      const content = this.getGridScrollContainer();
      if (lockedContent) {
        lockedContent.scrollTop = scrollTop !== null && scrollTop !== undefined ? scrollTop : (content?.scrollTop || 0);
      }
    },
    getDirectGridDomClassKey() {
      const data = this.getGridDataSource()?.view?.() || this.getGridDataSource()?.data?.() || [];
      const rows = typeof data.toJSON === "function" ? data.toJSON() : Array.from(data || []);
      const first = rows[0]?.uid || rows[0]?.userId || "";
      const last = rows[rows.length - 1]?.uid || rows[rows.length - 1]?.userId || "";
      const columnsKey = (this.directGridWidget?.columns || this.columns || [])
        .map(column => `${column.field || ""}:${column.hidden ? 1 : 0}:${column.locked ? 1 : 0}`)
        .join("|");
      return `${columnsKey}::${rows.length}:${first}:${last}`;
    },
    applyDirectGridLegacyStyleContract() {
      const root = this.getGridRootEl();
      if (!root) {
        return;
      }
      root.classList.add("ntss-kendo-grid-legacy", "k-widget", "k-grid", "k-editable", "k-display-block");
      const domClassKey = this.getDirectGridDomClassKey();
      if (this.directGridDomClassKey !== domClassKey) {
        root.querySelectorAll("th").forEach(th => th.classList.add("k-header"));
        root.querySelectorAll(".k-grid-content tbody tr, .k-grid-content-locked tbody tr").forEach((tr, index) => {
          tr.classList.add("k-master-row");
          tr.classList.toggle("k-alt", index % 2 === 1);
        });
        root.querySelectorAll(".k-grid-content td, .k-grid-content-locked td").forEach(td => td.classList.add("k-td", "k-table-td"));
        this.directGridDomClassKey = domClassKey;
      }
      this.applyDirectGridLockedWidthContract();
      this.applyDirectGridLockedHeightContract();
      this.syncDirectGridLockedScrollPosition();
    },
    scheduleDirectGridLayoutContract() {
      if (this.directGridLayoutRafId != null) {
        cancelAnimationFrame(this.directGridLayoutRafId);
      }
      const savedScroll = { ...this.scrollPosition };
      this.directGridLayoutRafId = requestAnimationFrame(() => {
        this.directGridLayoutRafId = null;
        this.resizeDirectGrid();
        this.applyDirectGridLegacyStyleContract();
        this.syncDirectGridLockedScrollPosition();
        if (savedScroll.top > 0 || savedScroll.left > 0) {
          this.scheduleGridScrollRestore(savedScroll);
        }
      });
    },
    scheduleGridScrollRestore(position = null) {
      const saved = {
        top: position?.top ?? this.scrollPosition.top ?? 0,
        left: position?.left ?? this.scrollPosition.left ?? 0
      };
      if (saved.top <= 0 && saved.left <= 0) {
        return;
      }
      const restore = () => this.setGridScrollPosition(saved);
      restore();
      this.$nextTick(() => {
        restore();
        requestAnimationFrame(restore);
      });
    },
    cancelDirectGridPendingWork() {
      [this.directGridLayoutRafId, this.directGridFilterRefreshRafId, this.directGridColumnVisibilityRafId].forEach(id => {
        if (id != null) {
          cancelAnimationFrame(id);
        }
      });
      this.directGridLayoutRafId = null;
      this.directGridFilterRefreshRafId = null;
      this.directGridColumnVisibilityRafId = null;
      this.directGridRowVisualRafIds?.forEach?.(id => cancelAnimationFrame(id));
      this.directGridRowVisualRafIds?.clear?.();
      if (this.directGridDestroyTimerId != null) {
        const ownerWindow = this.getGridRootEl()?.ownerDocument?.defaultView || window;
        ownerWindow.clearTimeout(this.directGridDestroyTimerId);
        this.directGridDestroyTimerId = null;
      }
    },
    editStart() {
      this.editingFlg = true;
    },
    editEnd() {
      this.editingFlg = false;
      this.$nextTick(() => {
        this.setGridScrollPosition(this.scrollPosition);
      });
    },
    async onDirectGridSave(event) {
      Object.keys(event.values || {}).forEach(field => {
        if (typeof event.model?.set === "function") {
          event.model.set(field, event.values[field]);
        } else if (event.model) {
          event.model[field] = event.values[field];
        }
      });
      await this.onSave(event);
      this.scheduleDirectGridCurrentRowVisual(event.model);
    },
    scheduleDirectGridCurrentRowVisual(record) {
      const rowKey = record?.uid || record?.userId;
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
      const uid = record?.uid;
      if (!uid) {
        return;
      }
      this.getGridRootEl()?.querySelectorAll?.(`tr[data-uid="${uid}"]`)?.forEach?.(row => {
        row.classList.toggle("master-edited-row", !!record.dirty || !!record.edited || !!record.operation);
      });
    },
    reconnectSocket() {
      const param = this;
      this.socketInterval = setInterval(function(){
        param.connect();
        clearInterval(this.socketInterval);
      }, 10000);
    },
    async systemUseSetting() {
      if (this.facilitylistValue) {
        // 施設のシステム利用設定を取得する
        const mstFacilityHash = await sendRequestGetMstFacilityHashByFacilityCd(this.facilitylistValue);
        this.facilitySysUseSetting = mstFacilityHash.data.systemUseSetting ? mstFacilityHash.data.systemUseSetting : "";
        /* add #9764  by zhangruixue 2023-09-04 --start */
        this.failureCnt = mstFacilityHash.data.failureCnt ? mstFacilityHash.data.failureCnt : 5;
        this.accountLockSetting = mstFacilityHash.data.accountLockSetting ? mstFacilityHash.data.accountLockSetting : 1;
        /* add #9764  by zhangruixue 2023-09-04 --end */
      } else {
        this.facilitySysUseSetting = ""
      }
    },
    // マスタ一覧のデータを取得
    findList() {
      // 選択施設のシステム利用設定を設定
      this.systemUseSetting();

      // apiをコールして利用者マスタの値を取得
      return this.getUserDataList(this.facilitylistValue)
        // mod #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen end
        // .then(response => {
        .then(async response => {
        // mod #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen end
          // editableをKendoUI用にfunctionオブジェクトに変換
          const toFunction = markRaw(response.data.columns || []);
          toFunction.forEach(column => {
            markRaw(column);
            // 編集可否を関数化
            column.editable = column.editable ? () => true : () => false;
            // 列幅初期化
            column["width"] = column.width ? column.width : "0";
          });
          this.columns = toFunction;

          // 横スクロールバーを表示するために列幅を指定
          this.columns.forEach(column => {
            // 「削除」のプルダウンが改行しない幅に調整
            // add 削除の欄が広い 王 start
            column.width = this.columnWidth + "em";
            // mod #7289-マスタの削除ボタンが縦表示になる 徐博 start
            // if (column.field === "isDisp")column.width = "8em";
            if (column.field === "isDisp")column.width = "9em";
            // mod #7289-マスタの削除ボタンが縦表示になる 徐博 end
            // column.width = column.field === "isDisp" ? "8em" : (this.columnWidth + "em");
            // add 削除の欄が広い 王 end
            // #9185 最小フォント、mst画面編集文字、テキストボックス幅を超えます linjunfeng start
            // #8612 ウィンドウサイズの変更で、マスタレイアウトが崩れる。林峻峰 start
            // if (column.locked && column.field === "userName") {
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

          // カラム幅等初期調整
          // 編集・並び順設定モードによって並び順項目の表示・非表示を切り替える
          // （先頭ダミー要素列と並び順列を交互に表示・非表示する）
          const sortRankIndex = this.columns.findIndex(
            col => col.field === "sortRank"
          );
          if (sortRankIndex >= 0) {
            this.columns[sortRankIndex].hidden = true;
            const dummyIndex = this.columns.findIndex(
              col => col.field === "dummy"
            );
            if (dummyIndex >= 0) {
              this.columns[dummyIndex].hidden = false;
            }
          }
          // 編集権限列のインデックス取得
          const editAuthorityIndex = this.columns.findIndex(
            col => col.field === "editAuthority"
          );
          // add 9522 by kangjie 20231012 start
          this.columns.forEach(item => {
            if (item.title === '職種') {
              item.values.unshift({
                text: " ",
                value: 0
              })
            }
          })
          // add 9522 by kangjie 20231012 end
          // 職種列のインデックス取得
          const jobCdIndex = this.columns.findIndex(
            col => col.field === "jobCd"
          );
          // カード無効化列のインデックス取得
          const cardIdmIndex = this.columns.findIndex(
            col => col.field === "cardIdm"
          )
          // システム利用設定がReMSのみの施設の場合
          if(this.facilitySysUseSetting === "1") {
            // 編集権限列／職種列を非表示
            this.columns[editAuthorityIndex].hidden = true;
            this.columns[jobCdIndex].hidden = true;
            this.columns[cardIdmIndex].hidden = true;
          }

          this.$nextTick(() => {
            this.calculateGridHeight();
            this.calculateGridWidth();
            // 追加ボタン押下した場合（dataBound より前にフラグを立てる）
            if (this.addFlg) {
              this.tmpAddFlg = true;
              this.__pendingScrollToAddedRow = true;
              this.scrollPosition.left = 0;
              this.addFlg = false;
            }
            const createdGrid = this.initDirectGridIfReady();
            if (!createdGrid) {
              this.refreshDirectGridDataFromMasterRecords();
            }
            this.scheduleDirectGridLayoutContract();
            if (!this.tmpAddFlg && !this.__pendingScrollToAddedRow) {
              this.scheduleGridScrollRestore();
            }
          });
          // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen start
          this.scheduleMstJobBeforeChangeLoad(response.data.localDataSource);
          // 職種マスタを取得する
          this.allMstJob = await getMstJob(this.facilitylistValue);
          // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen end
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstUserMainComponent.vue', 'findList', '指定されたマスタが見つかりません。');
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message: "指定されたマスタが見つかりません。"
              title: DIALOG_MESSAGES[12000003].title,
              message: messageFormat(DIALOG_MESSAGES[12000003].message),
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          }
        });
    },
    // 施設一覧のデータを取得
    findFacilityList() {
      // 日機装ユーザ以外の場合
      if (this.getStateUserAccountInfo.userType !== 1) {
        // ログイン者の担当施設を選択（初期値は自分の所属する施設）
        this.setFacilitylistValue();
        // 選択した施設を元に利用者一覧の取得
        this.findList();
        // 職種一覧を取得
        this.setJobList();
        return;
      }
      // apiをコールして施設一覧を取得
      this.facilityList()
        .then(() => {
          // ログイン者の担当施設を選択
          this.setFacilitylistValue();
          // 選択した施設を元に利用者一覧の取得
          this.findList();
          // 職種一覧を取得
          this.setJobList();
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstUserMainComponent.vue', 'findFacilityList', '指定されたマスタが見つかりません。');
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message: "指定されたマスタが見つかりません。"
              title: DIALOG_MESSAGES[12000003].title,
              message: messageFormat(DIALOG_MESSAGES[12000003].message),
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          }
        });
    },
    setJobList() {
      this.mstJobList(this.facilitylistValue);
    },
    scheduleMstJobBeforeChangeLoad(localDataSource) {
      this.mstJobBeforeChange = [];
      const rows = Array.isArray(localDataSource?.data) ? localDataSource.data.slice() : [];
      if (rows.length === 0) {
        return;
      }
      const ownerWindow = this.getMasterOwnerWindow?.(this.getGridRootEl?.())
        || this.$el?.ownerDocument?.defaultView
        || globalThis;
      const setTimeoutFn = ownerWindow?.setTimeout
        ? ownerWindow.setTimeout.bind(ownerWindow)
        : setTimeout;
      const requestAnimationFrameFn = ownerWindow?.requestAnimationFrame
        ? ownerWindow.requestAnimationFrame.bind(ownerWindow)
        : null;
      const load = async () => {
        try {
          const userIdList = rows.map(item => item.userId);
          const res = await ApiHelper.post("/user/get_by_ids", userIdList);
          const userMap = new Map();
          (res.data || []).forEach(r => {
            const userId = r.userAccountInfo.userId;
            userMap.set(userId, {
              useAuthFuncs: r.userAccountInfo.userSettings.authorized_functions,
              jobCdBak: r.userAccountInfo.jobCd
            });
          });
          rows.forEach(item => {
            const extra = userMap.get(item.userId) || {};
            this.mstJobBeforeChange.push({
              userId: item.userId,
              authorities: item.authorities,
              useAuthFuncs: extra.useAuthFuncs,
              jobCdBak: extra.jobCdBak
            });
          });
        } catch (error) {
          getErrorMessage('MstUserMainComponent.vue', 'scheduleMstJobBeforeChangeLoad', error?.message || '利用者情報を取得しません。');
        }
      };
      const scheduleAfterPaint = () => {
        if (requestAnimationFrameFn) {
          requestAnimationFrameFn(() => setTimeoutFn(load, 0));
          return;
        }
        setTimeoutFn(load, 0);
      };
      this.$nextTick(scheduleAfterPaint);
    },
    // fix 2026/06/03 職種変更時の権限差分判定を共通化 start
    getMstJobInfoByCd(jobCd) {
      return (this.allMstJob || []).find(item => item.jobCd == jobCd) || null;
    },
    getMstJobBeforeChangeByUserId(userId) {
      return (this.mstJobBeforeChange || []).find(item => item.userId == userId) || null;
    },
    isJobChangeWithinDefaultAuthority(beforeChangeInfo, afterJobInfo) {
      const defaultAuthorities = afterJobInfo?.defaultAuthorizedAuthorities;
      if (!defaultAuthorities || !beforeChangeInfo) {
        return false;
      }
      const defaultAuthoritySet = new Set(
        String(defaultAuthorities).split(",").map(value => String(value).trim()).filter(Boolean)
      );
      const defaultMenuFunctions = afterJobInfo?.defaultMenuSettings?.default_menu_functions;
      if (!Array.isArray(defaultMenuFunctions)) {
        return false;
      }
      const defaultMenuFunctionSet = new Set(defaultMenuFunctions);
      const authorities = Array.isArray(beforeChangeInfo.authorities) ? beforeChangeInfo.authorities : [];
      const useAuthFuncs = Array.isArray(beforeChangeInfo.useAuthFuncs) ? beforeChangeInfo.useAuthFuncs : [];
      return authorities.every(authority => defaultAuthoritySet.has(String(authority)))
        && useAuthFuncs.every(funcNo => defaultMenuFunctionSet.has(funcNo));
    },
    // fix 2026/06/03 職種変更時の権限差分判定を共通化 end
    blurGridActiveEditor() {
      const gridRoot = this.getGridRootEl?.();
      const activeElement = gridRoot?.ownerDocument?.activeElement || null;
      if (activeElement && gridRoot?.contains?.(activeElement) && typeof activeElement.blur === "function") {
        activeElement.blur();
      }
    },
    waitForGridEditorClose(retries = 8) {
      const ownerWindow = this.getMasterOwnerWindow?.(this.getGridRootEl?.()) || globalThis;
      const scheduleFrame = ownerWindow?.requestAnimationFrame
        ? callback => ownerWindow.requestAnimationFrame(callback)
        : callback => (ownerWindow?.setTimeout || setTimeout)(callback, 16);

      return new Promise(resolve => {
        const wait = remaining => {
          this.$nextTick(() => {
            if (!this.isMasterGridEditInteractionActive?.() || remaining <= 0) {
              resolve();
              return;
            }
            scheduleFrame(() => wait(remaining - 1));
          });
        };
        wait(retries);
      });
    },
    async refreshListAfterGridSave() {
      this.blurGridActiveEditor();
      await this.waitForGridEditorClose();
      await this.findList();
    },
    setFacilitylistValue() {
      this.facilitylistValue = this.getStateUserAccountInfo.facilityCd;
    },
    getDirectGridColumns() {
      const flattenColumns = columns => (columns || []).flatMap(column => {
        const rawColumn = toRaw(column);
        return rawColumn?.columns ? flattenColumns(rawColumn.columns) : [rawColumn];
      });
      return flattenColumns(this.getGridWidget()?.columns || this.buildDirectGridColumns());
    },
    getDirectGridCellByColumn(row, title, fallbackIndex, locked = false) {
      if (!row) {
        return null;
      }
      const columns = this.getDirectGridColumns();
      const isLockedColumn = column => column.locked === true || column.locked === "true";
      const columnIndex = columns.findIndex(column => column.title === title || column.field === title);
      if (columnIndex >= 0) {
        if (locked) {
          const lockedIndex = columns.slice(0, columnIndex + 1).filter(isLockedColumn).length - 1;
          return row.children?.[lockedIndex] || null;
        }
        const unlockedIndex = columnIndex - columns.slice(0, columnIndex).filter(isLockedColumn).length;
        return row.children?.[unlockedIndex] || null;
      }
      return Number.isInteger(fallbackIndex) ? row.children?.[fallbackIndex] || null : null;
    },
    getKendoCommandCellButton(cell) {
      return cell?.querySelector?.("button, .k-button, [role='button'], a") || null;
    },
    syncKendoCommandCellButtonClass(cell) {
      const control = this.getKendoCommandCellButton(cell);
      if (!cell || !control) {
        return control;
      }
      if (cell.classList?.contains("btn1-kendo-execute")) {
        control.classList?.add("btn1-execute");
      } else if (cell.classList?.contains("btn3-kendo-normal")) {
        control.classList?.add("btn3-normal");
      } else if (cell.classList?.contains("btn4-kendo-alert")) {
        control.classList?.add("btn4-alert");
      }
      return control;
    },
    setKendoCommandCellVisible(cell, visible) {
      const control = this.syncKendoCommandCellButtonClass(cell);
      if (control) {
        control.style.display = visible ? "" : "none";
        return;
      }
      if (cell) {
        cell.style.display = visible ? "" : "none";
      }
    },
    setKendoCommandCellText(cell, text) {
      const control = this.syncKendoCommandCellButtonClass(cell);
      const textNode = control?.querySelector?.(".k-button-text") || control;
      if (textNode) {
        textNode.textContent = text;
      }
    },
    isLoginUserRecord(record) {
      return record?.userId != null && record.userId == this.getStateUserAccountInfo?.userId;
    },
    getRenderedGridDataRows() {
      const dataSource = this.getGridDataSource();
      const rows = dataSource?.view?.() || dataSource?.data?.() || dataSource?.options?.data || [];
      if (typeof rows.toJSON === "function") {
        return rows.toJSON();
      }
      return Array.from(rows || []);
    },
    setKendoCommandCellDisabled(cell, disabled) {
      if (!cell) {
        return;
      }
      const controls = Array.from(cell.querySelectorAll?.("button, .k-button, [role='button'], a") || []);
      this.syncKendoCommandCellButtonClass(cell);
      if (disabled) {
        cell.setAttribute("disabled", "disabled");
        cell.setAttribute("aria-disabled", "true");
        cell.classList?.add("ntss-command-cell-disabled");
        cell.style.pointerEvents = "none";
      } else {
        cell.removeAttribute("disabled");
        cell.removeAttribute("aria-disabled");
        cell.classList?.remove("ntss-command-cell-disabled");
        cell.style.pointerEvents = "";
      }
      controls.forEach(control => {
        control.removeAttribute("disabled");
        control.classList?.remove("k-disabled", "k-state-disabled");
        if (disabled) {
          control.setAttribute("aria-disabled", "true");
          control.setAttribute("tabindex", "-1");
          control.style.opacity = "0.6";
          control.style.pointerEvents = "none";
        } else {
          control.removeAttribute("aria-disabled");
          control.removeAttribute("tabindex");
          control.style.opacity = "";
          control.style.pointerEvents = "";
        }
        if ("disabled" in control) {
          control.disabled = false;
        }
      });
    },
    editBackgroundColor() {
      this.$nextTick(() => {
        // グリッドが表示されていない、またはダミーデータの場合は処理終了
        const gridHeader = this.getGridHeaderEl();
        if (gridHeader && (gridHeader.textContent === " " ||gridHeader.textContent === "code")) {
          return;
        }
        gridHeader?.classList?.add("master-grid-header");

        // 列が存在しない場合は処理しない
        if (this.getGridTableEl()?.tBodies != null) {
          const tbodyc = this.getGridTbodyEl()
            .children;
          const lockTbodyc = this.getGridLockedBodyRows();
          const gridData = this.getRenderedGridDataRows();
          gridData.forEach((dataRow, index) => {
            const row = tbodyc[index];
            if (!row) {
              return;
            }
            const cellAt = cellIndex => row?.children?.[cellIndex] || null;
            const loginUserCommandCells = [
              cellAt(MST_USER_GRID_CELL_INDEX.ADMIN),
              cellAt(MST_USER_GRID_CELL_INDEX.ID_PW_RESET),
              cellAt(MST_USER_GRID_CELL_INDEX.LOCK_RELEASE),
              cellAt(MST_USER_GRID_CELL_INDEX.DELETE)
            ];
            loginUserCommandCells.forEach(cell => this.setKendoCommandCellDisabled(cell, false));
            // 仮登録ユーザは黄色背景にする
            if (dataRow.isProvisional == 1) {
              row.style.backgroundColor = "yellow";
              if (lockTbodyc[index]) {
                lockTbodyc[index].style.backgroundColor = "yellow";
              }
            }
            // ログインユーザの行を無効化
            if (this.isLoginUserRecord(dataRow)) {
              // ログインユーザの管理者／ID/PWリセット/ロック解除/削除機能を無効化
              this.setKendoCommandCellDisabled(cellAt(MST_USER_GRID_CELL_INDEX.ADMIN), true);
              this.setKendoCommandCellDisabled(cellAt(MST_USER_GRID_CELL_INDEX.ID_PW_RESET), true);
              /* mod 追加患者共有 楊zc start */
              /* tbodyc[index].children[8].setAttribute("disabled", "disabled"); */
              /* tbodyc[index].children[32].setAttribute("disabled", "disabled"); */
              this.setKendoCommandCellDisabled(cellAt(MST_USER_GRID_CELL_INDEX.LOCK_RELEASE), true);
              // mod #9804 #9807対応、#9584追加メールアドレス1 メールアドレス2のエラーの再修正  lmf start
              // tbodyc[index].children[33].setAttribute("disabled", "disabled");
              this.setKendoCommandCellDisabled(cellAt(MST_USER_GRID_CELL_INDEX.DELETE), true);
              // mod #9804 #9807対応、#9584追加メールアドレス1 メールアドレス2のエラーの再修正  lmf end
              /* mod 追加患者共有 楊zc end */
            }
            // ロックユーザ以外のロック解除ボタンを非表示にする
            // アカウントロックする設定でない場合、または、サインイン失敗回数が上限を達してない場合
            /* mod #9764  by zhangruixue 2023-09-04 --start */
            if (this.accountLockSetting != "1" || dataRow.failure_cnt < this.failureCnt) {
              /* mod #9764  by zhangruixue 2023-09-04 --end */
              /* mod 追加患者共有 楊zc start */
              /* tbodyc[index].children[8].children[0].style.display = "none"; */
              this.setKendoCommandCellVisible(cellAt(MST_USER_GRID_CELL_INDEX.LOCK_RELEASE), false);
              /* mod 追加患者共有 楊zc end */
            } else {
              this.setKendoCommandCellVisible(cellAt(MST_USER_GRID_CELL_INDEX.LOCK_RELEASE), true);
            }
            // 管理者変更ボタン名称切替
            if (dataRow.administrator == 0) {
              this.setKendoCommandCellText(cellAt(MST_USER_GRID_CELL_INDEX.ADMIN), "ユーザー");
            }
            /* add 追加患者共有 楊zc start */
            // 患者共有変更ボタン名称切替
            if (dataRow.patientShared == 0) {
              this.setKendoCommandCellText(cellAt(MST_USER_GRID_CELL_INDEX.PATIENT_SHARED), "非表示");
            }
            /* add 追加患者共有 楊zc end */
            // 利用者が患者の場合、管理者／使用機能設定／編集権限／職種設定の機能を抑制
            if (dataRow.patFlg) {
              this.setKendoCommandCellVisible(cellAt(MST_USER_GRID_CELL_INDEX.ADMIN), false);
              this.setKendoCommandCellVisible(cellAt(MST_USER_GRID_CELL_INDEX.USE_FUNCTION), false);
              this.setKendoCommandCellVisible(cellAt(MST_USER_GRID_CELL_INDEX.EDIT_AUTHORITY), false);
              /* mod 追加患者共有 楊zc start */
              /* tbodyc[index].children[9].textContent = ""; */
              /* tbodyc[index].children[9].style.pointerEvents = "none"; */
              const jobCell = cellAt(MST_USER_GRID_CELL_INDEX.JOB);
              if (jobCell) {
                jobCell.textContent = "";
                jobCell.style.pointerEvents = "none";
              }
              /* mod 追加患者共有 楊zc end */
            }
            // アクセスカード番号を削除
            if (String(dataRow.cardIdm) !== "1") {
              /* mod 追加患者共有 楊zc start */
              /* tbodyc[index].children[30].children[0].style.display = "none"; */
              // mod #9804 #9807対応、#9584追加メールアドレス1 メールアドレス2のエラーの再修正  lmf start
              // tbodyc[index].children[31].children[0].style.display = "none";
              this.setKendoCommandCellVisible(cellAt(MST_USER_GRID_CELL_INDEX.CARD_DISABLE), false);
              // mod #9804 #9807対応、#9584追加メールアドレス1 メールアドレス2のエラーの再修正  lmf end
              /* mod 追加患者共有 楊zc end */
            } else {
              this.setKendoCommandCellVisible(cellAt(MST_USER_GRID_CELL_INDEX.CARD_DISABLE), true);
            }
            //ユーザーが秘密鍵を持っていない場合、ユーザーは秘密鍵を削除できません
            if(dataRow.secretKey == "未設定"){
              /* mod 追加患者共有 楊zc start */
              /* tbodyc[index].children[29].setAttribute("disabled", "disabled"); */
              // mod #9804 #9807対応、#9584追加メールアドレス1 メールアドレス2のエラーの再修正  lmf start
              // tbodyc[index].children[30].setAttribute("disabled", "disabled");
              this.setKendoCommandCellDisabled(cellAt(MST_USER_GRID_CELL_INDEX.SECRET_KEY), true);
              // mod #9804 #9807対応、#9584追加メールアドレス1 メールアドレス2のエラーの再修正  lmf end
              /* mod 追加患者共有 楊zc end */
            } else {
              this.setKendoCommandCellDisabled(cellAt(MST_USER_GRID_CELL_INDEX.SECRET_KEY), false);
            }
          });
        }
      })
      
    },
    // ユーザ追加/モーダル表示
    async dispModalAddUser() {
      this.addFlg = true;
      this.scrollPosition.left = 0;
      // モーダル画面表示用のユーザデータを設定
      const userData = {
        userId: "",
        facilityCd: this.facilitylistValue,
        facilityName: "",
        administrator: 0,
        patientShared: 0,
        userName: "新規　ユーザー",
        isProvisional: 1,
        failure_cnt: 0,
        dispUserId: "",
        userType: this.facilitylistValue === "nkknkk" ? 1 : 0,
        userLastName: "新規",
        userFirstName: "ユーザー",
        userPassword: "",
        loginUrl: "",
        systemUseSetting: ""
      };
      this.setUserData(userData);
      // 新規ユーザ登録
      const response = await this.sendRequestAddNewUser(userData);
      if (response === 0) {
        // ID/PWリセット頂部に置く
        getUserMenuElement(this.$el || this)?.style?.setProperty("z-index", "100");
        getNotificationUnreadCountElement(this.$el || this)?.style?.setProperty("z-index", "101");
        // モーダルを表示
        await this.showUserMasterIdReset();
        // 利用者の再取得
        this.findList();
      }
    },
    // ユーザID/PW変更・モーダル表示
    async dispModalIdReset(e) {
      // スクロールの位置を維持
      this.setScrollLocation();

      /**
       * 「リセット」ボタンを押下したレコードのデータを取得する。
       * see: https://www.telerik.com/forums/selected-row-at-wrappers-for-vue
       */
      e.preventDefault();
      const row = this.getGridWidget();
      const selectedRowItem = getDirectGridDataItem(row, e.currentTarget.closest("tr"));
      if (this.isLoginUserRecord(selectedRowItem)) {
        return;
      }
      const userId = selectedRowItem.userId;
      // モーダル画面表示用のユーザデータを設定
      const userData = {
        userId: userId,
        facilityName: "",
        facilityCd: this.facilitylistValue,
        userName: selectedRowItem.userName,
        dispUserId: selectedRowItem.dispUserId,
        userPassword: "",
        loginUrl: "",
        patFlg: selectedRowItem.patFlg
      };
      // パスワードリセット
      const response = await this.sendRequestUpdatePassword(userData);
      if(this.valueSignIn == 2){
          let dispUserId = this.getStateUserAccountInfo.dispUserId;
          let facilityValue = this.getStateUserAccountInfo.facilityCd
          const data1 = {
            dispUserId : dispUserId,
            facilityCd : facilityValue
          }
          await this.sendRequestCreateMstUserOTP(data1)
          const data2 = {
            userId : userId,
            secretKey : this.userOTP.secretKey
          }
          await this.sendRequestUpdateSecretKey(data2)
      }
      if (response === 0) {
        // ID/PWリセット頂部に置く
        getUserMenuElement(this.$el || this)?.style?.setProperty("z-index", "100");
        getNotificationUnreadCountElement(this.$el || this)?.style?.setProperty("z-index", "101");
        // モーダルを表示
        await this.showUserMasterIdReset();
        await this.findList();
      }
    },
    // 使用許可機能
    async dispModalUseFunction(e) {
      // スクロールの位置を維持
      this.setScrollLocation();

      /**
       * 「使用機能」ボタンを押下したレコードのデータを取得する。
       * see: https://www.telerik.com/forums/selected-row-at-wrappers-for-vue
       */
      e.preventDefault();
      const row = this.getGridWidget();
      const selectedRowItem = getDirectGridDataItem(row, e.currentTarget.closest("tr"));

      // モーダル画面表示用のユーザデータを設定
      const userData = {
        userId: selectedRowItem.userId,
        facilityCd: this.facilitylistValue
      };
      this.setUserData(userData);
      // モーダル画面表示
      await this.showUserMasterAuthFunction();
    },
    // 権限設定
    async dispModalEditAuthority(e) {
      // スクロールの位置を維持
      this.setScrollLocation();

      /**
       * 「使用機能」ボタンを押下したレコードのデータを取得する。
       * see: https://www.telerik.com/forums/selected-row-at-wrappers-for-vue
       */
      e.preventDefault();
      const row = this.getGridWidget();
      const selectedRowItem = getDirectGridDataItem(row, e.currentTarget.closest("tr"));

      // store 上の最新データを優先（direct grid は Kendo wrapper と違い自動同期されない）
      const masterRow = (this.masterRecords?.data || []).find(
        row => row.userId === selectedRowItem.userId
      ) || selectedRowItem;
      // モーダル画面表示用のユーザデータを設定
      const userData = {
        userId: selectedRowItem.userId,
        authorities: masterRow.authorities || [],
        facilityCd: this.facilitylistValue
      };
      this.setUserData(userData);
      // モーダル画面表示
      await this.showUserMasterEditAuthority();
    },
    // 管理者チェック
    async changeAdmin(e) {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);

      // スクロールの位置を維持
      this.setScrollLocation();

      e.preventDefault();
      const row = this.getGridWidget();
      const selectedRowItem = getDirectGridDataItem(row, e.currentTarget.closest("tr"));
      if (this.isLoginUserRecord(selectedRowItem)) {
        this.setLoadingScreenVisible(false);
        return;
      }

      const userData = {
        userId: selectedRowItem.userId,
        administrator: selectedRowItem.administrator === 1 ? 0 : 1
      };

      // 管理者フラグ更新
      const response = await this.sendRequestUpdateAdministratorFlg(userData);
      if (response === 0) {
        // 利用者の再取得
        this.findList();
      }
      // 共通ローダー:表示終了
      this.setLoadingScreenVisible(false);
    },
    /* add 追加患者共有 楊zc start */
    // 患者共有・モーダル表示
    async changePatientSharedReset(e) {

      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      e.preventDefault();

      const row = this.getGridWidget();
      const selectedRowItem = getDirectGridDataItem(row, e.currentTarget.closest("tr"));

      const userData = {
        userId: selectedRowItem.userId,
        patientShared: selectedRowItem.patientShared === 1 ? 0 : 1
      };

      // 患者共有フラグ更新
      const response = await this.sendRequestUpdatePatientSharedFlg(userData);
      if (response === 0) {
        // 利用者の再取得
        this.findList();
      }

      // 共通ローダー:表示終了
      this.setLoadingScreenVisible(false);

    },
    /* add 追加患者共有 楊zc end */
    // ユーザのログイン失敗回数をリセット
    async resetLoginFailCnt(e) {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);

      // スクロールの位置を維持
      this.setScrollLocation();

      /**
       * 「リセット」ボタンを押下したレコードのデータを取得する。
       * see: https://www.telerik.com/forums/selected-row-at-wrappers-for-vue
       */
      e.preventDefault();
      const row = this.getGridWidget();
      const selectedRowItem = getDirectGridDataItem(row, e.currentTarget.closest("tr"));
      if (this.isLoginUserRecord(selectedRowItem)) {
        this.setLoadingScreenVisible(false);
        return;
      }

      const response = await this.sendRequestUpdateFailureCnt(
        selectedRowItem.userId
      );
      if (response === 0) {
        // 利用者の再取得
        this.findList();
      }
      // 共通ローダー:表示終了
      this.setLoadingScreenVisible(false);
    },
    // ユーザ削除
    async delUser(e) {
      // スクロールの位置を維持
      this.setScrollLocation();

      /**
       * 「削除」ボタンを押下したレコードのデータを取得する。
       * see: https://www.telerik.com/forums/selected-row-at-wrappers-for-vue
       */
      e.preventDefault();
      this.scheduleGridScrollRestore();
      const row = this.getGridWidget();
      const selectedRowItem = getDirectGridDataItem(row, e.currentTarget.closest("tr"));
      if (this.isLoginUserRecord(selectedRowItem)) {
        return;
      }
      this.delUserId = selectedRowItem.userId;

      let mes = "";
      // 確認ダイアログ表示
      if (selectedRowItem.patFlg) {
        // 削除対象の利用者が患者の場合、再登録の注意を表示する
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // mes = "!!注意!!</br>在宅患者を削除しようとしています。再登録する場合は在宅透析指示書の登録ボタンを押してください。";
        mes = messageFormat(DIALOG_MESSAGES[13000100].message);
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
      } else {
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // mes = "!!注意!!</br>アカウントを削除すると二度と戻すことはできません。</br>削除すると対象アカウントをサインアウトします。";
        mes = messageFormat(DIALOG_MESSAGES[13000101].message);
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
      }
      // 確認ダイアログ表示
      const resOk = await this.$ons.notification.confirm({
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // title: "アカウント削除確認",
        title: DIALOG_MESSAGES[13000100].title,
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        message: mes
      });

      if (resOk === 1) {
        this.confirm();
      }
    },

    // 削除処理実行
    async confirm() {
      this.setScrollLocation();
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
        const response = await this.sendRequestDeleteUser(this.delUserId);
        if (response === 0) {
          // 利用者の再取得
          this.findList();
        }
      // 共通ローダー:表示終了
      this.setLoadingScreenVisible(false);
    },

    // カード作成
    async createCard(e) {
      // スクロールの位置を維持
      this.setScrollLocation();

      e.preventDefault();
      const row = this.getGridWidget();
      const selectedRowItem = getDirectGridDataItem(row, e.currentTarget.closest("tr"));

      // TODO 保存する内容は未確定
      const card = {
        type: "1",
        id: selectedRowItem.userId,
        name: selectedRowItem.userName
      };
      this.setCard(card);
      if (this.getSocketIsConnected) {
        this.setLoadingScreenVisible(true);
        this.sendSocketMessage(`WRITE_STAFF_CARD-${this.facilityCd}-${card.id}`);
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
    async onSave(e){
      // スクロールの位置を維持
      this.setScrollLocation();
      const saveCell = e?.container?.[0] || e?.container;
      const saveCellIndex = typeof saveCell?.cellIndex === "number"
        ? saveCell.cellIndex
        : getDirectGridCellIndex(e?.sender, e?.container);

      /* mod 追加患者共有 楊zc start */
      // if (e.container[0].cellIndex === 9){
      if (saveCellIndex === 10){
      /* mod 追加患者共有 楊zc end */
        // 職種を更新

        let strJobCd = "";
        // mod #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen start
        // if (e.values.jobCd.value === undefined){
        if (e.values.dirty == false || e.values.jobCd.value === undefined){
        // mod #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen end
          strJobCd = e.values.jobCd;
        } else {
          strJobCd = e.values.jobCd.value;
        }
        const userData = {
          userId: e.model.userId,
          jobCd: strJobCd
        }
        // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen start
        const afterChangesMstJobInfo = this.getMstJobInfoByCd(strJobCd);
        const beforeChangeInfo = this.getMstJobBeforeChangeByUserId(e.model.userId);
        const changeFlg = this.isJobChangeWithinDefaultAuthority(beforeChangeInfo, afterChangesMstJobInfo);

        // fix 2026/06/03 職種変更確認をローダー表示前に行い、キャンセル時はセル編集を確実に終了 start
        if (this.signoutFlg && !changeFlg) {
          const answer = await this.$ons.notification.confirm({
            title: DIALOG_MESSAGES[13000157].title,
            message: MSG_SETTING_REFLECTION
          });
          if (answer !== 1) {
            // fix 2026/06/03 キャンセル後の重い resize を避け、ダイアログ閉鎖後にセルだけ復帰 start
            const revertModel = e.model;
            requestAnimationFrame(() => {
              if (beforeChangeInfo) {
                revertModel.set("jobCd", beforeChangeInfo.jobCdBak);
                delete revertModel.dirtyFields?.["jobCd"];
                if (Object.keys(revertModel.dirtyFields || {}).length === 0) {
                  revertModel.set("dirty", false);
                }
              }
              this.calculateColumnsWidth();
              this.calculateGridWidth();
              this.scheduleDirectGridCurrentRowVisual(revertModel);
              this.scheduleDirectGridLayoutContract();
            });
            // fix 2026/06/03 キャンセル後の重い resize を避け、ダイアログ閉鎖後にセルだけ復帰 end
            return;
          }
        }
        // fix 2026/06/03 職種変更確認をローダー表示前に行い、キャンセル時はセル編集を確実に終了 end
        // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen end
        // 共通ローダー:表示開始
        this.setLoadingScreenVisible(true);
        try {
          const response = await this.sendRequestUpdateJobCd(userData);
          if (response === 0) {
            // 利用者の再取得
            await this.refreshListAfterGridSave();
            await this.getUserAccountInfo();
          }
        } finally {
          // 共通ローダー:表示終了
          this.setLoadingScreenVisible(false);
        }
      /* mod 追加患者共有 楊zc start */
      // } else if ([10, 11, 12, 13, 14, 22, 23].includes(e.container[0].cellIndex)) {
        // mod #9804 #9807対応、#9584追加メールアドレス1 メールアドレス2のエラーの再修正  lmf start
        // } else if ([11, 12, 13, 14, 15, 22, 23, 24].includes(e.container[0].cellIndex)) {
      } else if ([11, 12, 13, 14, 17, 24, 25, 26].includes(saveCellIndex)) {
        // mod #9804 #9807対応、#9584追加メールアドレス1 メールアドレス2のエラーの再修正  lmf end
      /* mod 追加患者共有 楊zc end */
        // 利用者個人情報を更新
        // 共通ローダー:表示開始
        this.setLoadingScreenVisible(true);

        // 更新用データを作成
        const userData = {
          userId: e.model.userId,
          userLastNameKana: e.model.userLastNameKana,
          userFirstNameKana: e.model.userFirstNameKana,
          userLastNameAlpha: e.model.userLastNameAlpha,
          userFirstNameAlpha: e.model.userFirstNameAlpha,
          extensionNo: e.model.extensionNo,
          inHospitalCd_1: e.model.inHospitalCd_1,
          inHospitalCd_2: e.model.inHospitalCd_2
        }

        $$.extend(userData, e.values);
        /* add  楊zc start */
        userData.userLastNameKana = this.transform(userData.userLastNameKana);
        userData.userFirstNameKana = this.transform(userData.userFirstNameKana);
        userData.userLastNameAlpha = this.transform(userData.userLastNameAlpha);
        userData.userFirstNameAlpha = this.transform(userData.userFirstNameAlpha);
        userData.extensionNo = this.transform(userData.extensionNo);
        /* add  楊zc end */
        const response = await this.sendRequestUpdateUserPersonalInfo(userData);
        if (response === 0) {
          // 利用者の再取得
          this.findList();
        }
        // 共通ローダー:表示終了
        this.setLoadingScreenVisible(false);
      }
    },
    // -----------------------------------------
    // 変換 \
    // -----------------------------------------
    transform(obj){
      let array = [];
      if(obj !== undefined && obj !== null){
          [...obj].forEach((str)=>{array.push(str.replace("\\","\\\\"));});
          return array.join("");
        }
    },
    // -----------------------------------------
    // 抽出UI表示イベント
    // -----------------------------------------
    showPopover(event) {
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
    // パンくずリストをクリックされた場合に呼び出される関数
    refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      if (this.selfScreenName === this.$route.name) {
        // スクロールの位置を初期化する
        this.scrollPosition.top = 0;
        this.scrollPosition.left = 0;
        this.findList();
      }
    },
    /**
     * @description スクロールバーの位置をクリアする
     */
    clearScrollPosition() {
      this.scrollPosition.top = 0;
      this.scrollPosition.left = 0;
    },
    //秘密鍵を削除する
    async deleteKey(e){
      // スクロールの位置を維持
      this.setScrollLocation();

      e.preventDefault();
      const row = this.getGridWidget();
      const selectedRowItem = getDirectGridDataItem(row, e.currentTarget.closest("tr"));
      const userId = selectedRowItem.userId;
      this.$ons.notification.confirm({
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // title: "!!注意!!",
        title: DIALOG_MESSAGES[13000102].title,
        // message: "秘密鍵を削除すると二度と戻すことはできません。削除しますか？",
        message: messageFormat(DIALOG_MESSAGES[13000102].message),
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        callback: async answer => {
          if (answer === 1) {
            const user = {
                userId,
                isSetQrCode : 0
              }
              await this.sendRequestUpdateIsSetQrCode(user);
              const response = await this.sendRequestDeleteSecretKey(userId);
              if(this.valueSignIn == 2){
                  let dispUserId = this.getStateUserAccountInfo.dispUserId;
                  let facilityValue = this.getStateUserAccountInfo.facilityCd
                  const data1 = {
                    dispUserId : dispUserId,
                    facilityCd : facilityValue
                  }
                  await this.sendRequestCreateMstUserOTP(data1)
                  const data2 = {
                    userId : userId,
                    secretKey : this.userOTP.secretKey
                  }
                  await this.sendRequestUpdateSecretKey(data2)
              }
              if (response === 0) {
                this.findList();
            }
          }
        }
      });

    },

    //アクセスカードを無効にする
    async disableCard(e) {
      // スクロールの位置を維持
      this.setScrollLocation();

      e.preventDefault();
      const row = this.getGridWidget();
      const selectedRowItem = getDirectGridDataItem(row, e.currentTarget.closest("tr"));
      const userId = selectedRowItem.userId;
      this.$ons.notification.confirm({
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // title: "!!注意!!",
        title: DIALOG_MESSAGES[13000103].title,
        // message: "アクセスカードを無効にすると、元に戻すことはできません。 無効にしますか？",
        message: messageFormat(DIALOG_MESSAGES[13000103].message),
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        callback: async answer => {
          if (answer === 1) {
            const response = await this.sendRequestDisableAccessCard(userId);
              if (response === 0) {
                this.findList();
            }
          }
        }
      });
    },

    // スクロールの位置の設定
    setScrollLocation() {
      if (!this.getGridRootEl()) {
        return;
      }
      // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      const { top: scrollTop, left: scrollLeft } = this.getGridScrollPosition();
      this.scrollPosition.top = scrollTop;
      this.scrollPosition.left = scrollLeft;
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
      const { top, left } = this.getGridScrollPosition();
      this.scrollPosition.top = top;
      this.scrollPosition.left = left;
      this.editStart(e);
    },
    onDataBoundKendoGrid(e) {
      this.directGridWidget = markRaw(e?.sender || this.directGridWidget);
      this.directGridDomClassKey = null;
      this.applyDirectGridLegacyStyleContract();
      this.editBackgroundColor();
      if (this.tmpAddFlg || this.__pendingScrollToAddedRow) {
        this.tmpAddFlg = false;
        this.__pendingScrollToAddedRow = false;
        this.scrollPosition.left = 0;
        this.scheduleGridScrollToAddedRow();
        return;
      }
      if (this.scrollPosition.top > 0 || this.scrollPosition.left > 0) {
        //スクロールバーの位置をイベント発生前の位置に戻す
        this.$nextTick(() => {
          this.setGridScrollPosition(this.scrollPosition);
        });
      }
    },
  },
  // mod FNSI-4200ポートを使用している 孫 start
  //created() {
  //  if (!this.getSocketIsConnected) {
  //    this.connect();
  async created() {
    this.setLoadingScreenVisible(true);

    if (!this.getSocketIsConnected || null === this.getCardDeviceStatus) {
      // card appのwebsokcet以外場合、接続したサービスを閉じました
      if (this.getSocketIsConnected) {
        this.close();
        await SleepNSeconds(100);
      }

      // 遅延のミリ秒(millisecond)
      let delayMillisecond = 1000;

      // localStorageのportを利用する
      let defaultPort = (this.$el?.ownerDocument?.defaultView?.localStorage || globalThis?.localStorage)?.getItem("CARD_APP_PORT");
      // add 9511 FNSiカードアプリが一方のブラウザとしかつながらない。　吉 start
      if(!/^\d+$/.test(defaultPort)){
        (this.$el?.ownerDocument?.defaultView?.localStorage || globalThis?.localStorage)?.removeItem("CARD_APP_PORT");
        defaultPort = null;
      }
      // add 9511 FNSiカードアプリが一方のブラウザとしかつながらない。　吉 end
      if (null !== defaultPort) {
        // localStorageがあり場合、接続を実施する
        this.init({ port: defaultPort, facilityCd: "" });
        this.connect();

        // Nミリ秒を待つ
        await SleepNSeconds(delayMillisecond);
      }

      // 接続確認実施
      // APP接続しません、または、カードリーダーが無し
      if (!this.getSocketIsConnected || null === this.getCardDeviceStatus) {
        // 「カードアプリポート管理」からportを取得する
        let facilityCd = this.facilityCd;
        let cardPorts = await ApiHelper.get(`${uriGetCardAppPort}/${facilityCd}`).catch(() => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstUserMainComponent.vue', 'created', 'カードアプリポート管理から、ポートを取得しません。');
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
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
              await SleepNSeconds(100);
            }

            // 接続を実施する
            this.init({ port: portList[i], facilityCd: "" });
            this.connect();

            // Nミリ秒を待つ
            await SleepNSeconds(delayMillisecond);
          }
        }
      }
    // mod FNSI-4200ポートを使用している 孫 end
    } else {
      this.isCardDeviceConnected = this.getCardDeviceStatus
    }
    // mod マスタ一覧 1･施設切替を可能とする 孔 start
    // this.findFacilityList();
    this.facilitylistValue = this.getFacilitySwitch;
    this.findList();
    this.setJobList();
    // mod マスタ一覧 1･施設切替を可能とする 孔 end
    this.setCondition(this.condition);
    this.getDispCreateCard(this.getStateUserAccountInfo.facilityCd);

    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    // 端末判別
    const ua = ((this?.$el?.ownerDocument?.defaultView?.navigator?.userAgent) || globalThis?.navigator?.userAgent || "").toLowerCase();
    if (/android/.test(ua)) {
      this.androidFlg = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.iosFlg = true;
    }
    this.selfScreenName = this.$route.name
    EventBus.$on("refresh", this.refresh);
    EventBus.$on("mst-user-grid-refresh", this.refreshGridDataFromStore);

    // カード情報クリア
    this.clearCard();
    //値の取得ログイン
    this.sendRequestGetValueSignInByFacilityCd(this.getStateUserAccountInfo.facilityCd)
    // add FNSI-4200ポートを使用している 孫 start
    function SleepNSeconds(num) {
        return new Promise((resolve) => {
            setTimeout(() => {
              resolve(1*num);
            }, num);
        });
    }
    // add FNSI-4200ポートを使用している 孫 end
    // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen start
    // 職種マスタを取得する
    this.allMstJob = await getMstJob(this.facilitylistValue);
    // 施設設定：権限変更時サインアウトさせるかの設定を取得
    sendRequestGetMstFacilitySettingValue(this.getFacilitySwitch, PERMISSION_CHANGE_SIGNOUT).then(response => {
      this.signoutFlg = (response.data == 1);
    });
    // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen end
  },
  mounted() {
    this.directGridMounted = true;
    this.$nextTick(() => {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
      this.initDirectGridIfReady();
      this.scheduleDirectGridLayoutContract();
    });
    EventBus.$on("clearScrollPosition", this.clearScrollPosition);
  },
  // add 性能改善メモリ不足 shan start
  beforeUnmount() {
    EventBus.$off("refresh", this.refresh);
    EventBus.$off("mst-user-grid-refresh", this.refreshGridDataFromStore);
    clearInterval(this.socketInterval);
    EventBus.$off("clearScrollPosition", this.clearScrollPosition);
    this.cancelDirectGridPendingWork();
    this.destroyDirectGrid({ defer: true });
  },
  // add 性能改善メモリ不足 shan end
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
#grid-footer {
  margin: 0;
  padding: 5px 5px 5px 5px;
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
  font-size: 1.0em;
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  width: auto;
}
.kendo-grid-toolbar-style {
  padding: 0.1em 0.3em;
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
.custom-switch {
  transform: scale(0.85);
  transform-origin: center;
  touch-action: manipulation;
}
.kendo-grid-toolbar-style :deep(.k-grid-content-locked) {
  overflow-y: scroll !important;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: none;
  -ms-overflow-style: none;
}
.kendo-grid-toolbar-style :deep(.k-grid-content-locked::-webkit-scrollbar) {
  display: none;
}
.no-scroll {
  overflow-x: hidden;
}
.mst-user-direct-jq-grid {
  width: 100%;
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
