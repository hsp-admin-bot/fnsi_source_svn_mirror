/**
 * ベッドマスタメンテナンスデータページ  MainContent
 */
<template>
  <div class="main-content-area master-maintenance-page">
    <div class="ntss-list" :style="ntssListStyles">
      <div class="k-grid-toolbar k-header kendo-grid-toolbar-style mst-bed-direct-jq-toolbar" :style="heightStyles">
        <div id="grid-header" :class="['header-btn-area', 'right', isMobileDevice ? 'mobile-header' : '']">
          <v-ons-button v-show="!isSortMode && isAllowAddRecord" style="float: left;" class="btn3-normal toolbar-btn" @click="addRow()">追加</v-ons-button>
          <v-ons-row v-show="isMobileDevice" style="float: left; width: 6em; height: 1em;">
            <v-ons-col width="45%" vertical-align="center">
              <label class="fab-font-color">編集</label>
            </v-ons-col>
            <v-ons-col width="55%" vertical-align="center">
              <v-ons-switch modifier="outline" style="float: left; margin-left: 2px;" v-model="allowEdit" />
            </v-ons-col>
          </v-ons-row>
          <!-- del マスタ一覧 1･施設切替を可能とする 孔 start -->
          <!--<kendo-dropdownlist ref="dropDownList" v-if="isMasterUser"
                    v-model="facilitylistValue"
                    :data-source="facilities"
                    :data-text-field="'facilityName'"
                    :data-value-field="'facilityCd'"
                    :filter="'contains'"
                    @open="onOpenFacility"
                    @change="onChangeFacility"
                    style="width: 13em;">
          </kendo-dropdownlist>-->
          <!-- del マスタ一覧 1･施設切替を可能とする 孔 end -->
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn csv-btn" style="margin-right: 10px;" v-show="!isSortMode && isAllowSort" @click="importCsv($event)">CSV取込</v-ons-button>
          <v-ons-button v-show="!isSortMode && isAllowSort" class="btn3-normal toolbar-btn" @click="toRankEditBtnClick()">並び順表示</v-ons-button>
          <v-ons-button v-show="isSortMode && isAllowSort" class="btn3-normal toolbar-btn" @click="sortBtnClick()">反映</v-ons-button>
        </div>
        <!-- 第1批：Vue2 wrapper/compat を使わず、jQuery Kendo Grid を直接初期化する -->
        <div
          v-show="columns.length > 1"
          id="grid-font-size"
          ref="gridRoot"
          :class="[fontSizeSet, 'ntss-kendo-grid-legacy', 'mst-bed-direct-jq-grid']"
        ></div>
      </div>
      <div id="grid-footer">
        <v-ons-row v-show="!isSortMode" width="100%">
          <v-ons-col width="50%">
            <v-ons-button class="btn2-cancel denial-btn" style="width: auto;" @click="cancel">キャンセル</v-ons-button>
          </v-ons-col>
          <v-ons-col width="50%" class="right">
            <v-ons-button class="btn1-execute registration-btn" style="width: auto;" :disabled="!isChanged" @click="saveRecord">保存</v-ons-button>
          </v-ons-col>
        </v-ons-row>
      </div>
    </div>
    <master-csv
      :popoverVisible="masterCsvVisible"
      :popoverTarget="masterCsvTarget"
      @popover-close="prehideCsvPopover"
    />
  </div>
</template>


<script>
import { markRaw } from "vue";
import { mapActions, mapGetters } from "vuex";
import $ from "jquery";
import kendo from "@progress/kendo-ui";
import { EventBus } from "@/compat/vue/event-bus.js";

import { ApiHelper } from "@/apis/AxiosHelper";
import { sendRequestGetMstFacilityHashByFacilityCd } from "@/apis/mst-facility-hash";
import MasterCsvComponent from "@/components/master-maintenance/MasterCsvComponent";
import { bindGridEditorEnterToCloseCell } from "@/compat/kendo/grid-edit";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import { messageFormat } from "@/functions/common/MessageFormat";
import { sendRequestFindRecordList, sendRequestUpdateRecordListByFacilityCd } from "@/apis/master-maintenance";
import { sendRequestGetMachineType } from "@/apis/mst-bedLayout";

function clonePlain(value) {
  return JSON.parse(JSON.stringify(value || {}));
}

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

export default {
  name: "MstBedMainComponent",
  components: {
    "master-csv": MasterCsvComponent
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
      backupMasterRecordList: [],
      masterCsvVisible: false,
      masterCsvTarget: null,
      editingFlg: false,
      androidFlg: false,
      iosFlg: false,
      scrollPosition: {
        top: 0,
        left: 0
      },
      mstMachine: [],
      exclusionListNo: [],
      facilitylistValue: "",
      prevFacilityCd: "",
      selfScreenName: "",
      facilitySysUseSetting: "",
      lastScrollTop: 0,
      lastScrollLeft: 0,
      directGridScrollAtBottom: false,
      lockbedList: null,
      allowEdit: true,
      dbBeforeData: [],
      directGridDataSource: null,
      directGridReady: false,
      directGridMounted: false,
      directGridResizeHandler: null,
      directGridWidget: null,
      directGridFontResizeRafId: null,
      directGridLayoutRefreshRafId: null,
      directGridFilterRefreshRafId: null,
      directGridScrollSyncRafId: null,
      directGridScrollHandler: null,
      directGridEditVisualRafId: null,
      directGridRowVisualRafIds: markRaw(new Map()),
      directGridSortEditedCodes: markRaw(new Set()),
      directGridEditedFieldsByCode: markRaw(new Map()),
      __pendingScrollLeftReset: false,
      validationTooltipPlacementIntervalId: null,
      validationTooltipPlacementTimers: [],
      validationTooltipPlacementRafId: null
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
      comparisonRecordModel: "getComparisonRecordModel",
      editRecord: "getEditRecord",
      isEdited: "isEdited",
      hasValueColumn: "hasValueColumn",
      getFacilitySwitch: "getFacilitySwitch"
    }),
    ...mapGetters("mst-bed", {
      getFacilityList: "getFacilityList"
    }),
    ...mapGetters("user", ["getAdvancedSettings"]),

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
    masterRecords() {
      // storeからデータを取得
      return this.getFilteredMasterRecordList;
    },
    masterConditionSignature() {
      // Vue2 wrapper は master-maintenance store の検索条件変更に追従して
      // :data-source="masterRecords" を再評価する。direct jq では検索条件だけを監視し、
      // セル blur/通常編集では dataSource を全再投入しない。
      const condition = this.$store?.state?.["master-maintenance"]?.condition || {};
      return `${condition.recordName || ""}|${condition.includeDeleted ? 1 : 0}`;
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
      const records = this.getMasterRecordList?.data || [];
      const originalRecords = this.dbBeforeData || [];
      const hasChanged = this.hasBedChanges(records, originalRecords);
      return (
        this.isSorted ||
        hasChanged ||
        records.some(record => record?.operation || record?.edited || record?.dirty)
      );
    },
    facilities() {
      // storeからデータを取得
      return this.getFacilityList;
    },
    isMasterUser: {
      get() {
        return this.getStateUserAccountInfo?.userType === 1 ? true : false;
      },
      set() {}
    },
    isMobileDevice() {
      return this.iosFlg || this.androidFlg;
    }
  },
  async created() {
    installComponentJQuery();
    this.setLoadingScreenVisible(true);
    this.calculateColumnsWidth();
    this.setCondition(this.condition);
    // mod マスタ一覧 1･施設切替を可能とする 孔 start
    // this.findFacilityList();
    this.facilitylistValue = this.getFacilitySwitch;
    this.findList();
    // mod マスタ一覧 1･施設切替を可能とする 孔 end

    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    // 端末判別
    const ua = navigator.userAgent.toLowerCase();
    if (/android/.test(ua)) {
      this.androidFlg = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.iosFlg = true;
    }

    const [mstMachine] = await Promise.all([
      // mod マスタ一覧 1･施設切替を可能とする 孔s start
      // ApiHelper.get(`/bed_layout/mst_machine/${this.facilityCd}`),
      // Mst.mstPrinterSelector(this.facilityCd)
      ApiHelper.get(`/bed_layout/mst_machine/${this.getFacilitySwitch}`)
      // mod マスタ一覧 1･施設切替を可能とする 孔s end
    ]).catch(error => {
      //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
      getErrorMessage("MstBedModal.vue", "created", error);
      //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
      return [];
    });
    this.mstMachine = mstMachine?.data || [];
    // 除外リスト取得
    if (this.mstMachine) {
      this.exclusionListNo = this.mstMachine
        .filter(mst => {
          const formatCd = mst.comFormatCd;
          const formatCdType = mst.comType;
          return formatCdType == "2" && (formatCd === "A" || formatCd === "D" || formatCd === "R" || formatCd === "I" || formatCd === "J");
        })
        .map(mst => String(mst.machineNo));
    }
    // ベッドマスタ タイトルはハイパーリンクではありません start
    this.selfScreenName = this.$router.currentRoute?.value?.name || this.$router.currentRoute?.name || "";
    EventBus.$on("refresh", this.refresh);
    EventBus.$on("onCloseMasterEditModal", this.onCloseMasterEditModal);
    // ベッドマスタ タイトルはハイパーリンクではありません end
    //add #9009 ベッドマスタにおいて治療中のベッドに対して編集可能 張 start
    ApiHelper.get(`/mstInfo/selectBedListByFacilityCd/${this.getFacilitySwitch}`)
      .then(res => {
        this.lockbedList = res.data;
      })
      .catch(error => {
        getErrorMessage("MstBedMainComponent.vue", "selectBedListByFacilityCd", error);
      });
    //add #9009 ベッドマスタにおいて治療中のベッドに対して編集可能 張 end
  },
  watch: {
    getFontSize() {
      this.scheduleDirectGridFontSizeRefresh();
    },
    masterConditionSignature() {
      this.scheduleDirectGridFilterRefresh();
    }
  },
  mounted() {
    this.directGridMounted = true;
    this.$nextTick(() => {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.resizeDirectGrid();
      this.initDirectGridIfReady();
      this.scheduleDirectGridPostLayoutRefresh();
    });
    this.directGridResizeHandler = () => {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.resizeDirectGrid();
      this.scheduleDirectGridPostLayoutRefresh();
    };
    window.addEventListener("resize", this.directGridResizeHandler);
    EventBus.$on("clearScrollPosition", this.clearScrollPosition);
  },
  beforeUnmount() {
    if (this.directGridFontResizeRafId != null) {
      cancelAnimationFrame(this.directGridFontResizeRafId);
      this.directGridFontResizeRafId = null;
    }
    if (this.directGridLayoutRefreshRafId != null) {
      cancelAnimationFrame(this.directGridLayoutRefreshRafId);
      this.directGridLayoutRefreshRafId = null;
    }
    if (this.directGridFilterRefreshRafId != null) {
      cancelAnimationFrame(this.directGridFilterRefreshRafId);
      this.directGridFilterRefreshRafId = null;
    }
    if (this.directGridScrollSyncRafId != null) {
      cancelAnimationFrame(this.directGridScrollSyncRafId);
      this.directGridScrollSyncRafId = null;
    }
    if (this.directGridEditVisualRafId != null) {
      cancelAnimationFrame(this.directGridEditVisualRafId);
      this.directGridEditVisualRafId = null;
    }
    if (this.directGridRowVisualRafIds) {
      this.directGridRowVisualRafIds.forEach(rafId => cancelAnimationFrame(rafId));
      this.directGridRowVisualRafIds.clear();
      this.directGridRowVisualRafIds = null;
    }
    this.clearValidationTooltipPlacementTimers();
    this.stopValidationTooltipPlacementWatch();
    EventBus.$off("refresh", this.refresh);
    EventBus.$off("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$off("clearScrollPosition", this.clearScrollPosition);
    this.destroyDirectGrid();
    if (this.directGridResizeHandler) {
      window.removeEventListener("resize", this.directGridResizeHandler);
      this.directGridResizeHandler = null;
    }
  },
  methods: {
    ...mapActions("multi-modal", [
      "showMasterEdit"
    ]),
    ...mapActions("master-maintenance", [
      "findRecordListByFacilityCd",
      "setMasterRecordList",
      "edit",
      "setComparisonRecordModel",
      "findColumnInfo",
      "setCondition",
      "updateRecordListByFacilityCd",
      "setEditRecord",
      "editRecordBeEmpty"
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount: "resetLoadingScreenVisibleCount"
    }),
    ...mapActions("mst-bed", {
      facilityList: "facilityList"
    }),
    ...mapActions("mst-bed", ["setFacilitySysUseSetting"]),

    getMaxSortRank() {
      const data = this.getFilteredMasterRecordList?.data || [];
      if (data.length > 0) {
        return data.reduce((a, b) => Math.max(a, +b.sortRank || 0), 0);
      }
      return 0;
    },
    getCurrentRouteName() {
      return this.$router?.currentRoute?.value?.name || this.$router?.currentRoute?.name || "";
    },
    loadGridData() {
      this.findList();
    },
    refresh() {
      if (this.selfScreenName === this.getCurrentRouteName() && document.getElementsByTagName("ons-alert-dialog").length === 0) {
        if (this.isChanged) {
          this.$ons.notification.confirm({
            title: DIALOG_MESSAGES[12000014].title,
            message: DIALOG_MESSAGES[12000014].message,
            callback: answer => {
              if (answer === 1) {
                this.loadGridData();
              }
            }
          });
        } else {
          this.loadGridData();
        }
      }
    },
    onCloseMasterEditModal() {
      // Vue2 では詳細モーダル閉鎖後に scroll を戻してから配色する。
      // direct jq では grid.refresh せず、現在の DataSource だけを再同期する。
      this.$nextTick(() => {
        this.restoreDirectGridMachineNoColumnValues();
        this.syncDirectGridDataFromStore();
        this.refreshDirectGridDataFromMasterRecords(false);
        this.$nextTick(() => {
          this.restoreDirectGridScrollPosition();
        });
      });
    },
    restoreDirectGridMachineNoColumnValues() {
      const masterValues = this.getBedMachineNoMasterValues();
      if (!masterValues.length) {
        return;
      }
      const widgetColumn = this.directGridWidget?.columns?.find(column => column.field === "machineNo");
      if (widgetColumn) {
        widgetColumn.values = clonePlain(masterValues);
      }
    },
    clearScrollPosition() {
      this.scrollPosition.top = 0;
      this.scrollPosition.left = 0;
    },
    gridDataRefresh() {
      this.refreshDirectGridDataFromMasterRecords(false);
    },
    scheduleDirectGridFilterRefresh() {
      // Vue2 の <kendo-grid :data-source="masterRecords"> は検索条件変更で表示データだけが差し替わる。
      // direct jq では検索条件変更時だけ dataSource を更新する。blur/通常編集では呼ばない。
      if (!this.directGridWidget?.dataSource) {
        return;
      }
      if (this.directGridFilterRefreshRafId != null) {
        cancelAnimationFrame(this.directGridFilterRefreshRafId);
      }
      this.directGridFilterRefreshRafId = requestAnimationFrame(() => {
        this.directGridFilterRefreshRafId = null;
        const content = this.getDirectGridScrollContent();
        if (content) {
          content.scrollTop = 0;
          content.scrollLeft = 0;
        }
        try {
          this.directGridWidget.dataSource.data(this.getDirectGridDisplayData());
        } catch (_error) {
          return;
        }
        this.$nextTick(() => {
          this.applyDirectGridLegacyStyleContract();
          this.refreshDirectGridDirtyVisualState();
        });
      });
    },
    importCsv(event) {
      if (!this.validateBeforeSortMode()) {
        return;
      }
      this.masterCsvTarget = event?.target || null;
      this.masterCsvVisible = true;
    },
    prehideCsvPopover() {
      this.masterCsvVisible = false;
      this.refreshDirectGridDirtyVisualState();
    },
    convertToStr(messageArr) {
      if (!messageArr || messageArr.length === 0) {
        return "";
      }
      const unique = messageArr.reduce((acc, cur) => {
        if (acc.indexOf(cur) === -1) {
          acc.push(cur);
        }
        return acc;
      }, []);
      const prefix = "</br>&nbsp&nbsp・";
      return prefix + unique.join(prefix);
    },
    validateRequired() {
      const validateMessageArr = [];
      const gridData = this.getMasterRecordList;
      const rows = (gridData?.data || []).filter(row => row.isDisp !== "0");
      const fields = gridData?.schema?.model?.fields || {};
      rows.forEach(row => {
        Object.keys(fields).forEach(key => {
          const validation = fields[key]?.validation;
          if (validation?.required && row[key] !== null && row[key] === "") {
            const columnInfo = this.columns.find(column => column.field == key);
            if (columnInfo?.title) {
              validateMessageArr.push(columnInfo.title);
            }
          }
        });
      });
      return this.convertToStr(validateMessageArr);
    },
    validateComboValue() {
      const comboFields = this.columns
        .filter(column => column.values != null)
        .map(column => ({ field: column.field, title: column.title, values: column.values }));
      let rows = (this.getMasterRecordList?.data || []).filter(row => row.isDisp !== "0" && row.isDel === "0");
      const validateMessageArr = [];
      rows.forEach(row => {
        comboFields.forEach(combo => {
          const columnValue = row[combo.field];
          const isEmpty = columnValue === null || columnValue === undefined || columnValue === "" || columnValue === "null";
          if (isEmpty) {
            return;
          }
          const exists = (combo.values || []).some(value => String(value?.value) === String(columnValue));
          if (!exists) {
            validateMessageArr.push(combo.title);
          }
        });
      });
      return this.convertToStr(validateMessageArr);
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

    getColumnIndex(fieldName) {
      // 指定された項目がない場合はマイナスが返る
      return this.columns.findIndex(e => e.field === fieldName);
    },
    calculateColumnsWidth() {
      const fontSize = Number(this.getFontSize || 1);
      const widthMap = [12, 14, 16, 18];
      this.columnWidth = widthMap[fontSize] || 14;
    },
    calculateGridHeight() {
      if (this.editingFlg) {
        return;
      }
      // Vue2 MasterMaintenanceMixin.calculateGridHeight() の高さ契約を direct jq grid でも使う。
      // #grid-footer は absolute で .ntss-list 下端に配置されるため、toolbar 高さからは引かず、
      // grid 本体の高さだけから grid-header / grid-footer を引く。
      const wh = Number(this.windowHeight) || window.innerHeight || 0;
      const headerElements = Array.prototype.slice.call(document.getElementsByClassName("header"));
      const hh = headerElements.length ? headerElements.pop().clientHeight : 0;
      const footerMenu = document.getElementById("footer-menu");
      const fmh = (this.isDispMenu === 1 && footerMenu ? footerMenu.clientHeight : 0) + 5;
      const kendoToolbarHeight = wh - hh - fmh;
      this.kendoGridToolbarHeight = kendoToolbarHeight > 100 ? kendoToolbarHeight : 100;

      let gridFooterHeight = 0;
      const gridFooter = document.getElementById("grid-footer");
      if (gridFooter) {
        gridFooterHeight = gridFooter.clientHeight;
      }
      let tableToolbarHeight = 0;
      const toolbarElements = document.getElementsByClassName("header-btn-area");
      if (toolbarElements && toolbarElements.length) {
        tableToolbarHeight = toolbarElements[0].clientHeight;
      }
      this.kendoGridHeight = Math.max(160, this.kendoGridToolbarHeight - (gridFooterHeight + tableToolbarHeight));
    },
    resizeDirectGrid() {
      const grid = this.directGridWidget;
      if (!grid) {
        return;
      }
      try {
        this.storeDirectGridScrollPosition();
        try {
          grid.closeCell?.();
        } catch (_closeError) {
          // 編集中でなくても closeCell は失敗し得る。resize は継続する。
        }
        grid.setOptions({ height: this.kendoGridHeight });
        grid.resize(true);
        this.applyDirectGridLockedWidthContract();
        this.applyDirectGridLockedHeightContract();
        // resize で tbody が再描画されると master-edited-row 等の手動配色が消える。
        // 同時に Kendo が scrollTop を 0 に戻すため、resize 前の位置を復元する。
        this.$nextTick(() => {
          this.restoreDirectGridScrollPosition();
          this.refreshDirectGridDirtyVisualState();
          this.scheduleValidationTooltipPlacement();
          requestAnimationFrame(() => {
            this.restoreDirectGridScrollPosition();
          });
        });
      } catch (_error) {
        // 初期表示第1批では resize 失敗時に追加補正をしない。
      }
    },
    scheduleDirectGridPostLayoutRefresh() {
      if (this.directGridLayoutRefreshRafId != null) {
        cancelAnimationFrame(this.directGridLayoutRefreshRafId);
      }
      this.directGridLayoutRefreshRafId = requestAnimationFrame(() => {
        this.applyDirectGridLockedWidthContract();
        this.applyDirectGridLockedHeightContract();
        this.directGridLayoutRefreshRafId = requestAnimationFrame(() => {
          this.directGridLayoutRefreshRafId = null;
          this.applyDirectGridLockedWidthContract();
          this.applyDirectGridLockedHeightContract();
          this.restoreDirectGridScrollPosition();
          this.refreshDirectGridDirtyVisualState();
        });
      });
    },
    scheduleDirectGridFontSizeRefresh() {
      if (!this.directGridWidget) {
        return;
      }
      if (this.directGridFontResizeRafId != null) {
        cancelAnimationFrame(this.directGridFontResizeRafId);
      }
      this.directGridFontResizeRafId = requestAnimationFrame(() => {
        this.directGridFontResizeRafId = null;
        this.calculateColumnsWidth();
        this.calculateGridHeight();
        this.applyDirectGridLegacyStyleContract();
        this.resizeDirectGrid();
        this.applyDirectGridLegacyStyleContract();
        this.scheduleDirectGridPostLayoutRefresh();
      });
    },
    applyInitialSortColumnVisibility() {
      // Vue2 MasterMaintenanceMixin.showSortColumn() の初期表示時点だけを移植する。
      // 初期表示では並び順列を非表示、先頭ダミー列を表示する。
      const sortRankIndex = this.columns.findIndex(col => col.field === "sortRank");
      if (sortRankIndex < 0) {
        return;
      }
      this.columns[sortRankIndex].hidden = !(this.isAllowSort && this.isSortMode);
      const dummyIndex = this.columns.findIndex(col => col.field === "dummy");
      if (dummyIndex >= 0) {
        this.columns[dummyIndex].hidden = !this.columns[sortRankIndex].hidden;
      }
    },
    validateBeforeSortMode() {
      // 第2批では v-kendo-validator をまだ戻さない。
      // Vue2 の kendoValidator.validate() と同じ分岐位置だけ残し、validator 接続時にここへ差し替える。
      const validator = this.kendoValidator || this.$refs?.kendoValidator;
      if (validator && typeof validator.validate === "function") {
        return validator.validate();
      }
      return true;
    },
    getDirectGridScrollContent() {
      const root = this.$refs.gridRoot;
      return root?.querySelector?.(".k-grid-content") || null;
    },
    getDirectGridLockedScrollContent() {
      const root = this.$refs.gridRoot;
      return root?.querySelector?.(".k-grid-content-locked") || null;
    },
    isDirectGridScrollAtBottom(gridContent = null) {
      const content = gridContent || this.getDirectGridScrollContent();
      if (!content) {
        return false;
      }
      const threshold = 2;
      return content.scrollTop + content.clientHeight >= content.scrollHeight - threshold;
    },
    scrollDirectGridToBottom(preserveScrollLeft = null) {
      const gridContent = this.getDirectGridScrollContent();
      if (!gridContent) {
        return;
      }
      const top = Math.max(0, gridContent.scrollHeight - gridContent.clientHeight);
      const left = preserveScrollLeft ?? this.scrollPosition.left ?? this.lastScrollLeft ?? gridContent.scrollLeft ?? 0;
      gridContent.scrollTop = top;
      gridContent.scrollLeft = left;
      this.directGridScrollAtBottom = true;
      this.scrollPosition.top = top;
      this.scrollPosition.left = left;
      this.lastScrollTop = top;
      this.lastScrollLeft = left;
      this.syncDirectGridLockedScrollPosition(top);
      this.dispatchDirectGridContentScroll();
    },
    storeDirectGridScrollPosition() {
      const gridContent = this.getDirectGridScrollContent();
      if (!gridContent) {
        this.scrollPosition.top = 0;
        this.scrollPosition.left = 0;
        this.directGridScrollAtBottom = false;
        return;
      }
      this.scrollPosition.top = gridContent.scrollTop;
      this.scrollPosition.left = gridContent.scrollLeft;
      this.lastScrollTop = this.scrollPosition.top;
      this.lastScrollLeft = this.scrollPosition.left;
      this.directGridScrollAtBottom = this.isDirectGridScrollAtBottom(gridContent);
    },
    bindDirectGridScrollPositionTracking() {
      this.unbindDirectGridScrollPositionTracking();
      const onScroll = () => {
        this.storeDirectGridScrollPosition();
      };
      this.directGridScrollHandler = onScroll;
      const content = this.getDirectGridScrollContent();
      if (content) {
        content.addEventListener("scroll", onScroll, { passive: true });
      }
      const lockedContent = this.getDirectGridLockedScrollContent();
      if (lockedContent) {
        lockedContent.addEventListener("scroll", onScroll, { passive: true });
      }
    },
    unbindDirectGridScrollPositionTracking() {
      const handler = this.directGridScrollHandler;
      if (!handler) {
        return;
      }
      const content = this.getDirectGridScrollContent();
      if (content) {
        content.removeEventListener("scroll", handler);
      }
      const lockedContent = this.getDirectGridLockedScrollContent();
      if (lockedContent) {
        lockedContent.removeEventListener("scroll", handler);
      }
      this.directGridScrollHandler = null;
    },
    restoreDirectGridScrollPosition() {
      const gridContent = this.getDirectGridScrollContent();
      if (!gridContent) {
        return;
      }
      if (this.directGridScrollAtBottom) {
        this.scrollDirectGridToBottom(this.scrollPosition.left ?? this.lastScrollLeft ?? 0);
        return;
      }
      const top = this.scrollPosition.top ?? this.lastScrollTop ?? 0;
      const left = this.scrollPosition.left ?? this.lastScrollLeft ?? 0;
      this.syncDirectGridScrollToDom(top, left);
    },
    syncDirectGridScrollToDom(top, left) {
      const grid = this.directGridWidget;
      const gridContent = this.getDirectGridScrollContent();
      if (gridContent) {
        gridContent.scrollTop = top;
        gridContent.scrollLeft = left;
      }
      if (grid?.content?.[0] && grid.content[0] !== gridContent) {
        grid.content[0].scrollTop = top;
        grid.content[0].scrollLeft = left;
      }
      const headerWrap = this.$refs.gridRoot?.querySelector?.(".k-grid-header-wrap");
      if (headerWrap) {
        headerWrap.scrollLeft = left;
      }
      if (typeof grid?._scrollLeft !== "undefined") {
        grid._scrollLeft = left;
      }
      this.syncDirectGridLockedScrollPosition(top);
      this.dispatchDirectGridContentScroll();
    },
    resetDirectGridHorizontalScroll() {
      const top = this.scrollPosition.top ?? this.lastScrollTop ?? this.getDirectGridScrollContent()?.scrollTop ?? 0;
      this.syncDirectGridScrollToDom(top, 0);
      this.scrollPosition.left = 0;
      this.lastScrollLeft = 0;
    },
    syncDirectGridScrollToAddedRow() {
      const gridContent = this.getDirectGridScrollContent();
      if (!gridContent) {
        return;
      }
      const top = Math.max(0, gridContent.scrollHeight - gridContent.clientHeight);
      this.directGridScrollAtBottom = true;
      this.syncDirectGridScrollToDom(top, 0);
      this.scrollPosition.top = top;
      this.scrollPosition.left = 0;
      this.lastScrollTop = top;
      this.lastScrollLeft = 0;
    },
    scheduleDirectGridAddRowScroll() {
      const apply = () => this.syncDirectGridScrollToAddedRow();
      apply();
      this.$nextTick(() => {
        apply();
        requestAnimationFrame(apply);
        [32, 80, 180].forEach((ms) => setTimeout(apply, ms));
      });
    },
    syncDirectGridLockedScrollPosition(scrollTop = null) {
      const lockedContent = this.getDirectGridLockedScrollContent();
      if (!lockedContent) {
        return;
      }
      const gridContent = this.getDirectGridScrollContent();
      const top = scrollTop !== null && scrollTop !== undefined ? scrollTop : (gridContent?.scrollTop || 0);
      // Vue2 wrapper は列表示切替後も locked / non-locked の縦スクロールを即時同期する。
      // direct jq では Kendo の scroll handler が次のユーザー scroll まで走らないことがあるため、
      // scrollTop と scroll event だけを補う。行 DOM の再計測や grid-scroll helper は使わない。
      lockedContent.scrollTop = top;
    },
    dispatchDirectGridContentScroll() {
      const gridContent = this.getDirectGridScrollContent();
      if (!gridContent) {
        return;
      }
      try {
        gridContent.dispatchEvent(new Event("scroll", { bubbles: true }));
      } catch (_error) {
        // IE 相当の古いイベント生成差異は無視する。
      }
      try {
        $(gridContent).trigger("scroll");
      } catch (_error) {
        // jQuery scroll trigger 失敗時も手動 scrollTop 同期済みなので継続する。
      }
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
    syncDirectGridColumnStateToWidget() {
      const grid = this.directGridWidget;
      if (!grid || !Array.isArray(grid.columns)) {
        return;
      }
      this.columns.forEach(column => {
        const gridColumn = grid.columns.find(col => col.field === column.field);
        if (gridColumn) {
          gridColumn.editable = column.editable;
        }
      });
    },
    setDirectGridColumnHidden(fieldName, hidden) {
      const grid = this.directGridWidget;
      if (!grid) {
        return;
      }
      const gridColumn = Array.isArray(grid.columns) ? grid.columns.find(col => col.field === fieldName) : null;
      if (!gridColumn || !!gridColumn.hidden === !!hidden) {
        return;
      }
      try {
        if (hidden) {
          grid.hideColumn(fieldName);
        } else {
          grid.showColumn(fieldName);
        }
      } catch (_error) {
        // Vue2 wrapper は列表示切替で画面を壊さない。direct jq でも第2批では追加補正しない。
      }
    },
    syncDirectGridSortColumnsToWidget() {
      // Vue2 showSortColumn() は dummy と sortRank の hidden を交互に切り替えるだけ。
      // direct jq では全列 rebuild せず、この2列だけを Kendo widget に同期する。
      const sortRankColumn = this.columns.find(col => col.field === "sortRank");
      const dummyColumn = this.columns.find(col => col.field === "dummy");
      if (sortRankColumn) {
        this.setDirectGridColumnHidden("sortRank", !!sortRankColumn.hidden);
      }
      if (dummyColumn) {
        this.setDirectGridColumnHidden("dummy", !!dummyColumn.hidden);
      }
      this.syncDirectGridColumnStateToWidget();
      this.applyDirectGridLegacyStyleContract();
      this.restoreDirectGridScrollPosition();
      this.scheduleDirectGridPostColumnScrollSync();
    },
    editableColumns() {
      this.columns.forEach(column => {
        // Vue2 MasterMaintenanceMixin.editableColumns() と同じく、
        // sortRank は通常モードでは編集不可、それ以外は初期 editable に戻す。
        column.editable = column.field === "sortRank"
          ? () => false
          : column.originalEditable
            ? () => true
            : () => false;
      });
      this.syncDirectGridColumnStateToWidget();
    },
    disableColumns() {
      this.columns.forEach(column => {
        // Vue2 MasterMaintenanceMixin.disableColumns() と同じく、
        // 並び順列だけ編集可、その他は編集不可にする。
        column.editable = column.field === "sortRank"
          ? this.isAllowSort
            ? () => true
            : () => false
          : () => false;
      });
      this.syncDirectGridColumnStateToWidget();
    },
    showSortColumn() {
      const sortRankIndex = this.columns.findIndex(col => col.field === "sortRank");
      if (sortRankIndex >= 0) {
        this.columns[sortRankIndex].hidden = !(this.isAllowSort && this.isSortMode);
        const dummyIndex = this.columns.findIndex(col => col.field === "dummy");
        if (dummyIndex >= 0) {
          this.columns[dummyIndex].hidden = !this.columns[sortRankIndex].hidden;
        }
      }
      this.syncDirectGridSortColumnsToWidget();
    },
    syncDirectGridSortValuesToMasterRecords() {
      const grid = this.directGridWidget;
      const dataSourceData = grid?.dataSource?.data?.();
      if (!dataSourceData || !Array.isArray(this.getMasterRecordList?.data)) {
        return;
      }
      const gridRows = typeof dataSourceData.toJSON === "function" ? dataSourceData.toJSON() : Array.from(dataSourceData);
      const byCode = new Map();
      gridRows.forEach((row, index) => {
        if (row && row.code !== undefined && row.code !== null) {
          byCode.set(String(row.code), row);
        } else {
          byCode.set(`__index_${index}`, row);
        }
      });
      this.getMasterRecordList.data.forEach((record, index) => {
        const gridRow = byCode.get(String(record.code)) || byCode.get(`__index_${index}`);
        if (!gridRow) {
          return;
        }
        if (gridRow.sortRank !== undefined) {
          record.sortRank = gridRow.sortRank;
        }
        if (gridRow.sortInputTime !== undefined) {
          record.sortInputTime = gridRow.sortInputTime;
        }
      });
    },
    isDirectGridDisplayRecord(record) {
      // Vue2 の <kendo-grid :data-source="masterRecords"> は getFilteredMasterRecordList を表示元にする。
      // direct jq でも、保存用の全件リストとは別に、isDisp=0 の削除済み行は表示しない。
      if (!record) {
        return false;
      }
      return String(record.isDisp) !== "0";
    },
    getDirectGridDisplayRecords() {
      const filtered = this.getFilteredMasterRecordList?.data;
      const source = Array.isArray(filtered) ? filtered : (this.getMasterRecordList?.data || []);
      return source.filter(record => this.isDirectGridDisplayRecord(record));
    },
    getDirectGridDisplayData() {
      return clonePlain(this.getDirectGridDisplayRecords());
    },
    refreshDirectGridDataFromMasterRecords() {
      const grid = this.directGridWidget;
      if (!grid?.dataSource || !Array.isArray(this.getMasterRecordList?.data)) {
        return;
      }
      try {
        grid.dataSource.data(this.getDirectGridDisplayData());
      } catch (_error) {
        return;
      }
      this.$nextTick(() => {
        this.applyDirectGridLegacyStyleContract();
        requestAnimationFrame(() => {
          requestAnimationFrame(() => {
            this.refreshDirectGridDirtyVisualState();
            if (this.__pendingScrollLeftReset) {
              this.__pendingScrollLeftReset = false;
              this.scheduleDirectGridAddRowScroll();
            } else {
              this.restoreDirectGridScrollPosition();
            }
          });
        });
      });
    },
    sort() {
      const list = this.getMasterRecordList?.data;
      if (!Array.isArray(list)) {
        return;
      }
      const compare = (a, b) => a.sortRank - b.sortRank || a.sortInputTime - b.sortInputTime;
      list.sort(compare);
      for (let i = 0; i < list.length; i++) {
        if (list[i].isDisp === "1") {
          list[i].sortRank = i + 1;
        }
      }
    },
    sortChange(tempData) {
      let flag = false;
      const list = this.getMasterRecordList?.data || [];
      list.forEach(item => {
        tempData.forEach(tempItem => {
          if (item.code === tempItem.code && item.sortRank !== tempItem.sortRank) {
            flag = true;
          }
        });
      });
      return flag;
    },
    toRankEditBtnClick() {
      this.storeDirectGridScrollPosition();
      if (!this.validateBeforeSortMode()) {
        return;
      }
      this.isSortMode = true;
      this.disableColumns();
      this.showSortColumn();
    },
    sortBtnClick() {
      this.storeDirectGridScrollPosition();
      try {
        this.directGridWidget?.closeCell?.();
      } catch (_error) {
        // Vue2 wrapper と同じく、セル確定に失敗しても反映処理自体は継続する。
      }
      this.syncDirectGridSortValuesToMasterRecords();
      // 反映ボタン押下時は blur/save が走らないケースがあるため、
      // 同期後の sortRank と初期値の差分から手動並び替えフラグを再評価する。
      (this.getMasterRecordList?.data || []).forEach(record => {
        this.setDirectGridSortManuallyEdited(record, this.isBedSortRankChangedFromSnapshot(record));
      });
      const tempData = clonePlain(this.getMasterRecordList?.data || []);
      this.isSortMode = false;
      this.editableColumns();
      this.showSortColumn();
      this.sort();
      this.isSorted = this.sortChange(tempData);
      this.refreshDirectGridDataFromMasterRecords();
    },
    resolveDirectGridFontPixel() {
      const root = this.$refs.gridRoot || this.$el;
      const ownerWindow = root?.ownerDocument?.defaultView || window;
      const fontSize = Number.parseFloat(ownerWindow.getComputedStyle?.(root)?.fontSize || "");
      return Number.isFinite(fontSize) && fontSize > 0 ? fontSize : 14;
    },
    normalizeDirectGridColumnWidth(width) {
      // Vue2 wrapper は column.width の "14em" / "9em" をそのまま Kendo に渡す。
      // direct jq でも Kendo options へは em を渡し、共通字号変更時にブラウザの em 再計算へ追従させる。
      // Kendo 2026 の locked wrapper 幅だけは applyDirectGridLockedWidthContract() で Vue2 相当の外枠幅に補正する。
      return typeof width === "string" ? width.trim() : width;
    },
    parseDirectGridColumnWidthPx(width) {
      if (width === null || width === undefined || width === "") {
        return 0;
      }
      if (typeof width === "number") {
        return Number.isFinite(width) ? width : 0;
      }
      const value = String(width).trim().toLowerCase();
      const numeric = Number.parseFloat(value);
      if (!Number.isFinite(numeric)) {
        return 0;
      }
      if (value.endsWith("em")) {
        return numeric * this.resolveDirectGridFontPixel();
      }
      if (value.endsWith("px") || /^[0-9.]+$/.test(value)) {
        return numeric;
      }
      return 0;
    },
    getDirectGridVisibleLockedWidthPx() {
      return this.columns.reduce((total, column) => {
        if (!column?.locked || column.hidden) {
          return total;
        }
        return total + this.parseDirectGridColumnWidthPx(column.width);
      }, 0);
    },
    resetRunawayDirectGridWidths() {
      const root = this.$refs.gridRoot;
      if (!root) {
        return;
      }
      const baseWidth = root.parentElement?.clientWidth
        || root.closest?.(".kendo-grid-toolbar-style")?.clientWidth
        || root.clientWidth
        || 0;
      if (!baseWidth) {
        return;
      }
      // 編集後 resize で以前付与した scroll 側 width が残ると locked（ベッド名）が消える。
      root.querySelectorAll(".k-grid-header-wrap, .k-grid-content, .k-grid-header, .k-grid-footer").forEach(element => {
        const width = Number.parseFloat(String(element.style?.width || "").replace(/px$/i, ""));
        if (Number.isFinite(width) && width > baseWidth * 2) {
          element.style.removeProperty("width");
          element.style.removeProperty("min-width");
          element.style.removeProperty("max-width");
        }
      });
      root.querySelectorAll(".k-grid-header-wrap, .k-grid-content").forEach(element => {
        element.style.removeProperty("width");
        element.style.removeProperty("min-width");
        element.style.removeProperty("max-width");
      });
    },
    applyDirectGridLockedWidthContract() {
      const root = this.$refs.gridRoot;
      const lockedWidth = this.getDirectGridVisibleLockedWidthPx();
      if (!root || !lockedWidth) {
        return;
      }
      this.resetRunawayDirectGridWidths();
      // locked 外枠と table だけ補正。scroll 側 (.k-grid-content) へ手動 width を入れない。
      const widthPx = `${Math.ceil(lockedWidth)}px`;
      [
        ".k-grid-header-locked",
        ".k-grid-content-locked",
        ".k-grid-header-locked > table",
        ".k-grid-content-locked > table"
      ].forEach(selector => {
        root.querySelectorAll(selector).forEach(element => {
          element.style.width = widthPx;
          element.style.minWidth = widthPx;
        });
      });
    },
    applyDirectGridLockedHeightContract() {
      const content = this.getDirectGridScrollContent();
      const lockedContent = this.getDirectGridLockedScrollContent();
      if (!content || !lockedContent) {
        return;
      }
      const heightPx = `${Math.max(0, content.clientHeight)}px`;
      lockedContent.style.height = heightPx;
      lockedContent.style.maxHeight = heightPx;
      this.syncDirectGridLockedScrollPosition();
    },
    applyDirectGridLegacyShellClasses() {
      const root = this.$refs.gridRoot;
      if (!root) {
        return;
      }
      root.classList.add(
        "ntss-kendo-grid-legacy",
        "mst-bed-direct-jq-grid",
        "k-widget",
        "k-grid",
        "k-editable",
        "k-display-block"
      );
      const wrapper = root.closest?.(".kendo-grid-toolbar-style");
      wrapper?.classList?.add("k-grid-toolbar", "k-header", "mst-bed-direct-jq-toolbar");
    },
    applyDirectGridLegacyContentClasses() {
      const root = this.$refs.gridRoot;
      if (!root) {
        return;
      }
      // Vue2 wrapper / Kendo 2019 selector contract only.
      // Do not measure layout, repair locked columns, restore scroll, or call shared Kendo helpers here.
      root.querySelectorAll(".k-grid-header th, .k-grid-header .k-table-th").forEach(cell => {
        cell.classList.add("k-header");
      });
      root.querySelectorAll(".k-grid-content tr, .k-grid-content-locked tr").forEach(row => {
        row.classList.add("k-master-row");
      });
      root.querySelectorAll(".k-grid-content tr:nth-child(even), .k-grid-content-locked tr:nth-child(even)").forEach(row => {
        row.classList.add("k-alt");
      });
      root.querySelectorAll(".k-grid-content td, .k-grid-content-locked td").forEach(cell => {
        cell.classList.add("k-td", "k-table-td");
      });
    },
    applyDirectGridLegacyStyleContract() {
      this.applyDirectGridLegacyShellClasses();
      this.applyDirectGridLegacyContentClasses();
      this.applyDirectGridLockedWidthContract();
      this.applyDirectGridLockedHeightContract();
      this.syncDirectGridLockedScrollPosition();
    },
    getDirectGridColumnIndex(fieldName) {
      return this.columns.findIndex(column => column.field === fieldName);
    },
    getDirectGridRowsByRecord(record, preferredUid = null) {
      const root = this.$refs.gridRoot;
      if (!root || !record) {
        return [];
      }
      const uid = preferredUid || record.uid;
      if (uid) {
        return Array.from(root.querySelectorAll(`tbody tr[data-uid="${CSS.escape(String(uid))}"]`));
      }
      // Vue2 は編集終了時に対象行だけを処理する。
      // uid が取れない場合だけ code で絞るが、全行 dataItem 解決は高負荷なので最後の手段にする。
      if (record.code === undefined || record.code === null) {
        return [];
      }
      const rows = Array.from(root.querySelectorAll("tbody tr[data-uid]"));
      return rows.filter(row => {
        try {
          const item = this.directGridWidget?.dataItem?.(row);
          return item && String(item.code) === String(record.code);
        } catch (_error) {
          return false;
        }
      });
    },
    getDirectGridCellsByField(rows, fieldName) {
      return rows
        .map(row => this.findDirectGridCellForField(row, fieldName))
        .filter(Boolean);
    },
    resolveDirectGridCellByColumnField(row, fieldName) {
      const grid = this.directGridWidget;
      if (!row || !fieldName || !Array.isArray(grid?.columns)) {
        return null;
      }
      const isLockedRow = !!row.closest?.(".k-grid-content-locked");
      let visibleCellIndex = 0;
      for (let columnIndex = 0; columnIndex < grid.columns.length; columnIndex++) {
        const column = grid.columns[columnIndex];
        if (column.hidden) {
          continue;
        }
        const inThisRow = !!column.locked === isLockedRow;
        if (!inThisRow) {
          continue;
        }
        if (column.field === fieldName) {
          const cells = Array.from(row.children || []);
          const ariaColIndex = String(columnIndex + 1);
          const byAria = cells.find(cell => cell.getAttribute("aria-colindex") === ariaColIndex);
          if (byAria) {
            return byAria;
          }
          return cells[visibleCellIndex] || null;
        }
        visibleCellIndex += 1;
      }
      return null;
    },
    findDirectGridCellForField(row, fieldName) {
      if (!row || !fieldName) {
        return null;
      }
      const escapedField = CSS.escape(String(fieldName));
      const dataFieldCell = row.querySelector(
        `td[data-field="${escapedField}"], .k-table-td[data-field="${escapedField}"]`
      );
      if (dataFieldCell) {
        return dataFieldCell;
      }
      return this.resolveDirectGridCellByColumnField(row, fieldName);
    },
    findDirectGridCellsForRecordField(record, fieldName, preferredUid = null, resolvedRows = null) {
      const root = this.$refs.gridRoot;
      if (!fieldName) {
        return [];
      }
      const rows = resolvedRows || this.getDirectGridRowsByRecord(record, preferredUid);
      const uid = preferredUid || rows[0]?.getAttribute?.("data-uid");
      if (root && uid) {
        const escapedUid = CSS.escape(String(uid));
        const escapedField = CSS.escape(String(fieldName));
        const cells = Array.from(
          root.querySelectorAll(
            `tr[data-uid="${escapedUid}"] td[data-field="${escapedField}"], tr[data-uid="${escapedUid}"] .k-table-td[data-field="${escapedField}"]`
          )
        );
        if (cells.length) {
          return cells;
        }
      }
      const cellsFromRows = rows
        .map(row => this.findDirectGridCellForField(row, fieldName))
        .filter(Boolean);
      if (cellsFromRows.length) {
        return cellsFromRows;
      }
      if (!root || record?.code === undefined || record?.code === null) {
        return [];
      }
      return Array.from(root.querySelectorAll("tbody tr[data-uid]"))
        .filter(row => {
          try {
            const item = this.directGridWidget?.dataItem?.(row);
            return item && String(item.code) === String(record.code);
          } catch (_error) {
            return false;
          }
        })
        .map(row => this.findDirectGridCellForField(row, fieldName))
        .filter(Boolean);
    },
    markDirectGridDirtyCell(cell) {
      if (!cell?.classList) {
        return;
      }
      cell.classList.add("k-dirty-cell", "master-edited-cell");
      if (cell.querySelector(".k-dirty")) {
        return;
      }
      const marker = cell.ownerDocument?.createElement("span");
      if (!marker) {
        return;
      }
      marker.className = "k-dirty";
      cell.insertBefore(marker, cell.firstChild || null);
    },
    getBedChangedFieldsFromSnapshot(record) {
      if (!record || this.isBedAddedRecord(record)) {
        return [];
      }
      const original = this.findBedOriginalRecord(record);
      if (!original) {
        return [];
      }
      const skipFields = new Set(["sortRank", "sortInputTime", "dummy", "uid"]);
      const keys = this.getBedSchemaFieldKeys() || Object.keys(original);
      return keys.filter(key => {
        if (skipFields.has(key)) {
          return false;
        }
        return !this.bedCompareValuesEqual(record[key], original[key]);
      });
    },
    getDirectGridDirtyFieldNames(record) {
      if (!record) {
        return [];
      }
      const skipFields = new Set(["sortRank", "sortInputTime", "dummy", "uid"]);
      const fromSnapshot = this.getBedChangedFieldsFromSnapshot(record);
      const fromSession = this.getDirectGridEditedFields(record).filter(fieldName => !skipFields.has(fieldName));
      return [...new Set([...fromSnapshot, ...fromSession])];
    },
    clearDirectGridDirtyCellMarkersForRows(rows) {
      rows.forEach(row => {
        Array.from(row.children || []).forEach(cell => {
          if (cell.classList.contains("master-sort-edited")) {
            return;
          }
          cell.classList.remove("k-dirty-cell", "master-edited-cell");
          cell.querySelectorAll(".k-dirty").forEach(span => span.remove());
        });
      });
    },
    syncDirectGridDirtyCellMarkersForRecord(record, preferredUid = null, resolvedRows = null) {
      if (!record) {
        return;
      }
      const rows = resolvedRows || this.getDirectGridRowsByRecord(record, preferredUid);
      if (!rows.length) {
        return;
      }
      this.clearDirectGridDirtyCellMarkersForRows(rows);
      this.getDirectGridDirtyFieldNames(record).forEach(fieldName => {
        this.findDirectGridCellsForRecordField(record, fieldName, preferredUid, rows).forEach(cell => {
          this.markDirectGridDirtyCell(cell);
        });
      });
    },
    pruneDirectGridStrayDirtyMarkers() {
      const root = this.$refs.gridRoot;
      if (!root) {
        return;
      }
      root.querySelectorAll("tbody tr[data-uid]").forEach(row => {
        let item = null;
        try {
          item = this.directGridWidget?.dataItem?.(row);
        } catch (_error) {
          item = null;
        }
        const storeRecord = item?.code != null ? this.findMasterRecordByCode(item.code) : null;
        const shouldKeepDirty = !!storeRecord && (
          this.isBedNonSortRecordChangedFromSnapshot(storeRecord)
          || this.isDirectGridSortManuallyEdited(storeRecord)
          || this.getDirectGridEditedFields(storeRecord).length > 0
        );
        if (shouldKeepDirty) {
          return;
        }
        Array.from(row.children || []).forEach(cell => {
          if (cell.classList.contains("master-sort-edited")) {
            return;
          }
          cell.classList.remove("k-dirty-cell", "master-edited-cell");
          cell.querySelectorAll(".k-dirty").forEach(span => span.remove());
        });
      });
      root.querySelectorAll(".k-dirty").forEach(marker => {
        const cell = marker.closest("td, .k-table-td");
        if (!cell || (!cell.classList.contains("k-dirty-cell") && !cell.classList.contains("master-edited-cell"))) {
          marker.remove();
        }
      });
    },
    clearDirectGridRowVisualState(rows) {
      rows.forEach(row => {
        row.classList.remove("k-dirty-row");
        Array.from(row.children || []).forEach(cell => {
          cell.classList.remove(
            "k-dirty-cell",
            "master-edited-cell",
            "master-edited-row",
            "master-sort-edited",
            "master-deleted-row",
            "master-deleted-combo"
          );
          cell.querySelectorAll?.("span.k-dirty").forEach(span => span.remove());
        });
      });
    },
    isBedAddedRecord(record) {
      return !!record && (record.operation === 1 || String(record.operation) === "1" || record.isAddRow === true);
    },
    applyDirectGridRowVisualState(record, preferredUid = null, resolvedRows = null) {
      if (!record) {
        return;
      }
      const rows = resolvedRows || this.getDirectGridRowsByRecord(record, preferredUid);
      if (!rows.length) {
        return;
      }
      this.clearDirectGridRowVisualState(rows);
      // Vue2 の changeSortColor() は「sortRank セルに k-dirty-cell が付いた行」だけを黄色にする。
      // sort()/反映で順位が押し出された行は sortRank 値が初期値と違っても、ユーザーが直接編集していないため黄色にしない。
      const added = this.isBedAddedRecord(record);
      const changed = added
        || this.isBedNonSortRecordChangedFromSnapshot(record)
        || this.getDirectGridEditedFields(record).length > 0;
      const sortChanged = this.isDirectGridSortManuallyEdited(record);
      if (!changed && !sortChanged) {
        return;
      }
      const sortRankIndex = this.getDirectGridColumnIndex("sortRank");
      const dummyIndex = this.getDirectGridColumnIndex("dummy");
      rows.forEach(row => {
        if (changed) {
          row.classList.add("k-dirty-row");
          const cells = Array.from(row.children || []);
          cells.forEach(cell => {
            const colIndex = Number(cell.getAttribute("aria-colindex")) - 1;
            const effectiveIndex = Number.isFinite(colIndex) ? colIndex : cells.indexOf(cell);
            const isDummy = effectiveIndex === dummyIndex;
            const isSortRank = effectiveIndex === sortRankIndex;
            if (!isDummy && !isSortRank) {
              cell.classList.add("master-edited-row");
            }
          });
        }
      });
      if (changed) {
        this.syncDirectGridDirtyCellMarkersForRecord(record, preferredUid, rows);
      }
      if (sortChanged) {
        this.getDirectGridCellsByField(rows, "sortRank").forEach(cell => {
          cell.classList.add("k-dirty-cell", "master-sort-edited");
        });
        this.getDirectGridCellsByField(rows, "dummy").forEach(cell => {
          cell.classList.add("master-sort-edited");
        });
      }
      this.pruneDirectGridStrayDirtyMarkers();
    },
    buildDirectGridRowsByCodeMap() {
      const root = this.$refs.gridRoot;
      const grid = this.directGridWidget;
      const result = new Map();
      if (!root || !grid) {
        return result;
      }
      Array.from(root.querySelectorAll("tbody tr[data-uid]")).forEach(row => {
        let item = null;
        try {
          item = grid.dataItem?.(row);
        } catch (_error) {
          item = null;
        }
        const code = item?.code;
        if (code === undefined || code === null) {
          return;
        }
        const key = String(code);
        if (!result.has(key)) {
          result.set(key, []);
        }
        result.get(key).push(row);
      });
      return result;
    },
    refreshDirectGridDirtyVisualState() {
      // Vue2 の blur 時は対象行のみ。全体再配色は、反映後など dataSource を更新した直後だけ使う。
      // row -> dataItem の対応を先に Map 化し、行数分だけで終わらせる（行ごとの全 DOM 逆引きは禁止）。
      const rowsByCode = this.buildDirectGridRowsByCodeMap();
      (this.getMasterRecordList?.data || []).forEach(record => {
        const rows = rowsByCode.get(String(record.code));
        if (rows?.length) {
          this.applyDirectGridRowVisualState(record, null, rows);
        }
      });
    },
    scheduleDirectGridDirtyVisualRefresh() {
      // Vue2 の編集終了は対象行の dirty/class 更新が中心で、
      // 全 DOM 再走査は行わない。ここでは既存契約 class の軽量補正だけに留める。
      if (this.directGridEditVisualRafId != null) {
        cancelAnimationFrame(this.directGridEditVisualRafId);
      }
      this.directGridEditVisualRafId = requestAnimationFrame(() => {
        this.directGridEditVisualRafId = null;
        this.applyDirectGridLegacyStyleContract();
      });
    },
    readDirectGridEditorValue(container) {
      const root = this.resolveBedGridEditorContainerElement(container);
      const numericElement = root?.matches?.("input, .k-numerictextbox, .k-input")
        ? root
        : root?.querySelector?.("input, .k-numerictextbox, .k-input");
      const numericWidget = numericElement
        ? (
          $(numericElement).data("kendoNumericTextBox")
          || $(numericElement).closest(".k-numerictextbox").data("kendoNumericTextBox")
        )
        : null;
      if (numericWidget && typeof numericWidget.value === "function") {
        const widgetValue = numericWidget.value();
        if (widgetValue !== undefined && widgetValue !== null && `${widgetValue}` !== "") {
          return widgetValue;
        }
      }
      const input = root?.querySelector?.("input:not([type='hidden'])") || root?.querySelector?.("input");
      if (!input) {
        return undefined;
      }
      const value = input.value;
      const numeric = Number(value);
      return value !== "" && !Number.isNaN(numeric) ? numeric : value;
    },
    readDirectGridEditorFieldValue(container, fieldName) {
      const root = this.resolveBedGridEditorContainerElement(container);
      if (!root || !fieldName) {
        return undefined;
      }
      const dropdownElement = root.matches?.("input, select, .k-dropdownlist, .k-dropdown, .k-picker")
        ? root
        : root.querySelector?.("input, select, .k-dropdownlist, .k-dropdown, .k-picker");
      if (dropdownElement) {
        const widget = $(dropdownElement).data("kendoDropDownList")
          || $(dropdownElement).closest(".k-dropdownlist, .k-dropdown, .k-picker").data("kendoDropDownList");
        if (widget && typeof widget.value === "function") {
          const widgetValue = widget.value();
          if (widgetValue !== undefined) {
            return widgetValue;
          }
        }
      }
      const inputValue = this.readDirectGridEditorValue(root);
      return inputValue;
    },
    getDirectGridFieldFromCell(cell) {
      const colIndex = Number(cell?.getAttribute?.("aria-colindex")) - 1;
      if (!Number.isFinite(colIndex) || colIndex < 0) {
        return null;
      }
      return this.columns[colIndex]?.field || null;
    },
    getDirectGridFieldFromEvent(ev) {
      const activeField = ev?.sender?.editable?.options?.fields?.field;
      if (activeField) {
        return activeField;
      }
      return this.getDirectGridFieldFromCell(ev?.container?.[0] || ev?.container);
    },
    resolveBedGridEditorContainerElement(container) {
      if (!container) {
        return null;
      }
      if (container.jquery) {
        return container[0] || null;
      }
      if (container.nodeType === 1) {
        return container;
      }
      return null;
    },
    resolveBedGridCellEditContext(container) {
      const root = this.resolveBedGridEditorContainerElement(container);
      const cell = root?.closest?.("td.k-edit-cell, td.k-grid-edit-cell, td[data-role='editable'], td[data-container-for]") || null;
      return {
        grid: this.directGridWidget,
        cell
      };
    },
    isBedGridCellStillEditing(cell) {
      return !!cell && (
        cell.classList?.contains("k-edit-cell")
        || cell.classList?.contains("k-grid-edit-cell")
        || cell.getAttribute?.("data-role") === "editable"
      );
    },
    hideBedGridDropDownPopupImmediately(widget) {
      if (!widget) {
        return;
      }
      try {
        if (widget.options) {
          widget.options.animation = false;
        }
        widget.setOptions?.({ animation: false });
      } catch (_error) {
        // noop
      }
      try {
        widget.close?.();
      } catch (_error) {
        // noop
      }
      try {
        widget.popup?.close?.();
      } catch (_error) {
        // noop
      }
      try {
        const popupElement = widget.popup?.element?.[0];
        if (popupElement instanceof HTMLElement) {
          popupElement.style.display = "none";
          popupElement.style.visibility = "hidden";
          popupElement.setAttribute("aria-hidden", "true");
        }
      } catch (_error) {
        // noop
      }
      try {
        const animationContainer = widget.list?.closest?.(".k-animation-container")?.[0]
          || widget.ul?.closest?.(".k-animation-container")?.[0]
          || widget.popup?.element?.closest?.(".k-animation-container")?.[0]
          || null;
        if (animationContainer instanceof HTMLElement) {
          animationContainer.style.display = "none";
          animationContainer.style.visibility = "hidden";
        }
      } catch (_error) {
        // noop
      }
    },
    finishBedGridCellCloseAfterDropDownSelection(container, widget) {
      const { grid, cell } = this.resolveBedGridCellEditContext(container);
      if (!grid || typeof grid.closeCell !== "function" || !this.isBedGridCellStillEditing(cell)) {
        return;
      }
      const value = typeof widget?.value === "function" ? widget.value() : widget?.element?.val?.();
      try {
        widget?.element?.val?.(value);
      } catch (_error) {
        // noop
      }
      try {
        widget?.wrapper?.trigger?.("blur");
        widget?.element?.trigger?.("blur");
        widget?.element?.[0]?.blur?.();
      } catch (_error) {
        // noop
      }
      try {
        grid.current?.($(cell));
      } catch (_error) {
        // noop
      }
      try {
        grid.closeCell();
      } catch (_error) {
        // noop
      }
    },
    closeBedGridDropDownEditor(widget, container) {
      if (!widget) {
        return;
      }
      if (widget.__ntssBedDropDownCellClosePending) {
        return;
      }
      widget.__ntssBedDropDownCellClosePending = true;
      this.hideBedGridDropDownPopupImmediately(widget);
      this.finishBedGridCellCloseAfterDropDownSelection(container, widget);
      const { cell } = this.resolveBedGridCellEditContext(container);
      if (!this.isBedGridCellStillEditing(cell)) {
        widget.__ntssBedDropDownCellClosePending = false;
        return;
      }
      const ownerWindow = cell?.ownerDocument?.defaultView || window;
      const finish = () => {
        widget.__ntssBedDropDownCellClosePending = false;
        this.hideBedGridDropDownPopupImmediately(widget);
        this.finishBedGridCellCloseAfterDropDownSelection(container, widget);
      };
      if (typeof ownerWindow.requestAnimationFrame === "function") {
        ownerWindow.requestAnimationFrame(finish);
      } else {
        ownerWindow.setTimeout(finish, 0);
      }
    },
    bindBedGridEditorDropDownToCloseCell(container) {
      const root = this.resolveBedGridEditorContainerElement(container);
      if (!root) {
        return;
      }
      const bind = () => {
        root.querySelectorAll("input, select, .k-dropdownlist, .k-dropdown, .k-picker").forEach(element => {
          const widget = $(element).data("kendoDropDownList")
            || $(element).closest(".k-dropdownlist, .k-dropdown, .k-picker").data("kendoDropDownList");
          if (!widget || element.hasAttribute("data-ntss-bed-dropdown-close-bound")) {
            return;
          }
          element.setAttribute("data-ntss-bed-dropdown-close-bound", "1");
          try {
            if (widget.options) {
              widget.options.animation = false;
            }
            widget.setOptions?.({ animation: false });
          } catch (_error) {
            // noop
          }
          const closeAfterSelection = () => this.closeBedGridDropDownEditor(widget, container);
          try {
            widget.bind?.("select", closeAfterSelection);
            widget.bind?.("change", closeAfterSelection);
          } catch (_error) {
            // noop
          }
        });
      };
      bind();
      setTimeout(bind, 0);
    },
    onDirectGridEdit(ev) {
      bindGridEditorEnterToCloseCell(ev?.sender || this.directGridWidget, ev?.container);
      this.bindBedGridEditorDropDownToCloseCell(ev?.container);
      const field = this.getDirectGridFieldFromEvent(ev);
      const cell = ev?.container?.[0] || ev?.container;
      if (!field || !cell) {
        return;
      }
      this.applyDirectGridEditorValidationMessage(cell, field);
      this.scheduleValidationTooltipPlacement();
      const inputElements = Array.from(
        cell.querySelectorAll?.("input:not([type='hidden']), textarea, input") || []
      );
      const deferSortVisualUntilBlur = this.isSortMode && field === "sortRank";
      const onValidationPlacement = () => {
        this.scheduleValidationTooltipPlacement();
      };
      const onInput = () => {
        const value = this.readDirectGridEditorValue(cell);
        const visualRecord = this.getDirectGridModelPlain(ev.model, { [field]: value });
        if (this.isSortMode && field === "sortRank") {
          this.setDirectGridSortManuallyEdited(visualRecord, this.isBedSortRankChangedFromSnapshot(visualRecord));
        }
        this.applyDirectGridRowVisualState(visualRecord, ev?.model?.uid);
      };
      inputElements.forEach(input => {
        input.addEventListener("blur", onValidationPlacement, { passive: true });
        input.addEventListener("invalid", onValidationPlacement, { passive: true });
        if (deferSortVisualUntilBlur) {
          // 並び順列はセル確定（blur）タイミングで色を反映する。
          input.addEventListener("blur", onInput, { passive: true });
          return;
        }
        input.addEventListener("input", onInput, { passive: true });
        input.addEventListener("change", onInput, { passive: true });
      });
      // NumericTextBox のスピン/変更は通常列のみ即時反映する。
      if (deferSortVisualUntilBlur) {
        return;
      }
      cell.querySelectorAll(".k-numerictextbox, input").forEach(element => {
        const widget = $(element).data("kendoNumericTextBox")
          || $(element).closest(".k-numerictextbox").data("kendoNumericTextBox");
        if (!widget || widget.__ntssBedSortLiveColorBound) {
          return;
        }
        widget.__ntssBedSortLiveColorBound = true;
        try {
          widget.bind?.("change", onInput);
          widget.bind?.("spin", onInput);
        } catch (_error) {
          // noop
        }
      });
      setTimeout(onInput, 0);
    },
    onDirectGridSave(ev) {
      const field = this.getDirectGridFieldFromEvent(ev);
      const values = { ...(ev?.values || {}) };
      const container = ev?.container?.[0] || ev?.container;
      if (field && !Object.prototype.hasOwnProperty.call(values, field)) {
        const value = this.readDirectGridEditorFieldValue(container, field);
        if (value !== undefined) {
          values[field] = value;
        } else if (ev?.model) {
          values[field] = typeof ev.model.get === "function" ? ev.model.get(field) : ev.model[field];
        }
      }
      if (field === "isDisp" && Object.prototype.hasOwnProperty.call(values, field)) {
        values[field] = values[field] === null || values[field] === undefined ? "" : String(values[field]);
      }
      if (this.isSortMode && Object.prototype.hasOwnProperty.call(values, "sortRank")) {
        const modelPlain = this.getDirectGridModelPlain(ev?.model, values);
        const original = this.findBedOriginalRecord(modelPlain);
        const sortBackToOriginal = original && this.bedCompareValuesEqual(modelPlain.sortRank, original.sortRank);
        values.sortInputTime = sortBackToOriginal ? original.sortInputTime : Date.now();
        if (typeof ev?.model?.set === "function") {
          ev.model.set("sortInputTime", values.sortInputTime);
        } else if (ev?.model) {
          ev.model.sortInputTime = values.sortInputTime;
        }
      }
      // Vue2 wrapper はセル確定時に grid 全体を走査しない。
      // direct jq でも blur では対象 model/uid の locked/non-locked 行だけ更新する。
      const preferredUid = ev?.model?.uid;
      const updatedRecord = this.updateDirectMasterRecordFromModel(ev?.model, values);
      if (this.isSortMode && Object.prototype.hasOwnProperty.call(values, "sortRank")) {
        this.setDirectGridSortManuallyEdited(updatedRecord, this.isBedSortRankChangedFromSnapshot(updatedRecord));
      }
      const savedFields = field ? [...new Set([...Object.keys(values), field])] : Object.keys(values);
      this.reconcileDirectGridEditedFields(updatedRecord, savedFields);
      if (this.isBedAddedRecord(updatedRecord) || this.isBedNonSortRecordChangedFromSnapshot(updatedRecord) || this.isDirectGridSortManuallyEdited(updatedRecord)) {
        this.markBedRowPendingEdit(updatedRecord);
      } else {
        this.clearBedRowPendingEdit(updatedRecord);
      }
      this.syncDirectGridModelDirtyState(ev?.model, updatedRecord);
      this.applyDirectGridRowVisualState(updatedRecord, preferredUid);
      this.scheduleDirectGridRowVisualRefresh(updatedRecord, preferredUid, ev?.model);
      this.scheduleDirectGridPostLayoutRefresh();
    },
    clearKendoModelDirtyFlags(model) {
      if (!model) {
        return;
      }
      model.dirty = false;
      model._dirty = false;
      ["dirtyFields", "_dirtyFields"].forEach(fieldName => {
        const fields = model[fieldName];
        if (fields && typeof fields === "object") {
          Object.keys(fields).forEach(key => delete fields[key]);
        }
      });
    },
    getDirectGridEditedFields(record) {
      const key = this.getDirectGridRecordKey(record);
      if (!key || !this.directGridEditedFieldsByCode?.has?.(key)) {
        return [];
      }
      return Array.from(this.directGridEditedFieldsByCode.get(key));
    },
    markDirectGridEditedField(record, fieldName) {
      const key = this.getDirectGridRecordKey(record);
      if (!key || !fieldName || fieldName === "dummy" || fieldName === "sortRank") {
        return;
      }
      if (!this.directGridEditedFieldsByCode) {
        this.directGridEditedFieldsByCode = markRaw(new Map());
      }
      if (!this.directGridEditedFieldsByCode.has(key)) {
        this.directGridEditedFieldsByCode.set(key, markRaw(new Set()));
      }
      this.directGridEditedFieldsByCode.get(key).add(fieldName);
    },
    unmarkDirectGridEditedField(record, fieldName) {
      const key = this.getDirectGridRecordKey(record);
      if (!key || !fieldName || !this.directGridEditedFieldsByCode?.has?.(key)) {
        return;
      }
      this.directGridEditedFieldsByCode.get(key).delete(fieldName);
      if (this.directGridEditedFieldsByCode.get(key).size === 0) {
        this.directGridEditedFieldsByCode.delete(key);
      }
    },
    reconcileDirectGridEditedFields(record, fieldNames = []) {
      if (!record || !Array.isArray(fieldNames)) {
        return;
      }
      const original = this.isBedAddedRecord(record) ? null : this.findBedOriginalRecord(record);
      fieldNames.forEach(fieldName => {
        if (!fieldName || fieldName === "dummy" || fieldName === "sortRank") {
          return;
        }
        if (original && this.bedCompareValuesEqual(record[fieldName], original[fieldName])) {
          this.unmarkDirectGridEditedField(record, fieldName);
        } else {
          this.markDirectGridEditedField(record, fieldName);
        }
      });
    },
    clearDirectGridEditedFields(record) {
      const key = this.getDirectGridRecordKey(record);
      if (key) {
        this.directGridEditedFieldsByCode?.delete?.(key);
      }
    },
    syncDirectGridModelDirtyState(model, record) {
      if (!model || !record) {
        return;
      }
      if (this.isBedAddedRecord(record)) {
        // 追加行は手動で dirty 三角を付ける。Kendo model の dirty 残存は一瞬だけ三角が出る原因になる。
        this.clearKendoModelDirtyFlags(model);
        return;
      }
      if (this.isBedNonSortRecordChangedFromSnapshot(record) || this.isDirectGridSortManuallyEdited(record)) {
        return;
      }
      // Kendo は save 後に dirty / dirtyFields / k-dirty-cell を残すことがある。
      // Vue2 と同じく A→B→A で未編集扱いに戻すため、対象 model だけをクリアする。
      this.clearKendoModelDirtyFlags(model);
    },
    scheduleDirectGridRowVisualRefresh(record, preferredUid = null, model = null) {
      const rowKey = preferredUid || record?.code || "__unknown__";
      if (!this.directGridRowVisualRafIds) {
        this.directGridRowVisualRafIds = markRaw(new Map());
      }
      const oldRaf = this.directGridRowVisualRafIds.get(rowKey);
      if (oldRaf != null) {
        cancelAnimationFrame(oldRaf);
      }
      const rafId = requestAnimationFrame(() => {
        requestAnimationFrame(() => {
          this.directGridRowVisualRafIds?.delete(rowKey);
          this.syncDirectGridModelDirtyState(model, record);
          this.applyDirectGridRowVisualState(record, preferredUid);
        });
      });
      this.directGridRowVisualRafIds.set(rowKey, rafId);
    },
    cancel() {
      this.$router?.back?.();
    },
    normalizeBedCompareValue(value) {
      if (value === undefined || value === null || value === "" || value === "null") {
        return "";
      }
      const numericValue = Number(value);
      return Number.isNaN(numericValue) ? `${value}` : `${numericValue}`;
    },
    normalizeBedDropdownNumericValue(value) {
      if (value === undefined || value === null || value === "" || value === "null") {
        return "";
      }
      const numericValue = Number(value);
      return Number.isNaN(numericValue) ? value : numericValue;
    },
    getBedMachineNoMasterValues() {
      return this.columns.find(column => column.field === "machineNo")?.values || [];
    },
    isBedMachineNoEmpty(machineNo) {
      return (
        machineNo === undefined ||
        machineNo === null ||
        machineNo === "" ||
        machineNo === "null" ||
        machineNo === 0 ||
        machineNo === "0"
      );
    },
    getBedMachineNoDisplayText(machineNo) {
      if (this.isBedMachineNoEmpty(machineNo)) {
        return "";
      }
      const values = this.getBedMachineNoMasterValues();
      const raw = String(machineNo);
      const byValue = values.find(item => item?.value != null && String(item.value) === raw);
      if (byValue?.text != null && `${byValue.text}` !== "") {
        return `${byValue.text}`;
      }
      const byText = values.find(item => item?.text != null && String(item.text) === raw);
      if (byText?.text != null) {
        return `${byText.text}`;
      }
      const machine = (this.mstMachine || []).find(item => String(item?.machineNo) === raw);
      if (machine) {
        return machine.machineSerial || machine.name || machine.dispMachineName || raw;
      }
      return raw;
    },
    formatBedMachineNoCell(machineNo) {
      const text = this.getBedMachineNoDisplayText(machineNo);
      if (text === "") {
        return "";
      }
      return kendo?.htmlEncode ? kendo.htmlEncode(text) : text;
    },
    normalizeBedNullableString(value) {
      if (value === undefined || value === null || value === "" || value === "null") {
        return "";
      }
      return `${value}`;
    },
    normalizeBedRecord(record) {
      if (!record) {
        return record;
      }
      record.machineNo = this.normalizeBedDropdownNumericValue(record.machineNo);
      record.shuntPosition = this.normalizeBedDropdownNumericValue(record.shuntPosition);
      record.isInfection = this.normalizeBedNullableString(record.isInfection);
      record.emergencyClass = this.normalizeBedDropdownNumericValue(record.emergencyClass);
      record.outputPrinter = this.normalizeBedNullableString(record.outputPrinter);
      record.isAutoprintBefore = this.normalizeBedNullableString(record.isAutoprintBefore);
      record.isAutoprintAfter = this.normalizeBedNullableString(record.isAutoprintAfter);
      record.isAutoprintCommit = this.normalizeBedNullableString(record.isAutoprintCommit);
      record.inHospitalCd1 = this.normalizeBedNullableString(record.inHospitalCd1);
      record.inHospitalCd2 = this.normalizeBedNullableString(record.inHospitalCd2);
      return record;
    },
    normalizeBedDataSource(localDataSource) {
      const normalizedDataSource = clonePlain(localDataSource);
      if (Array.isArray(normalizedDataSource.data)) {
        normalizedDataSource.data.forEach(record => this.normalizeBedRecord(record));
      }
      return normalizedDataSource;
    },
    applyBedSchemaValidationMessages(schema) {
      const fields = schema?.model?.fields;
      if (!fields || !Array.isArray(this.columns) || this.columns.length <= 1) {
        return;
      }
      Object.keys(fields).forEach(fieldName => {
        const targetField = fields[fieldName];
        if (targetField?.validation?.required) {
          const targetColumn = this.columns.find(column => column.field === fieldName);
          if (targetColumn?.title) {
            targetField.validation.validationMessage = `${targetColumn.title}は必須入力です。`;
          }
        }
      });
    },
    getDirectGridFieldValidationMessage(field) {
      if (!field) {
        return "";
      }
      const schemaFields =
        this.directGridDataSource?.schema?.model?.fields ||
        this.getMasterRecordList?.schema?.model?.fields ||
        {};
      const fieldDef = schemaFields[field];
      if (fieldDef?.validation?.validationMessage) {
        return fieldDef.validation.validationMessage;
      }
      if (fieldDef?.validation?.required) {
        const column = this.columns.find(item => item.field === field);
        if (column?.title) {
          return `${column.title}は必須入力です。`;
        }
      }
      return "";
    },
    applyDirectGridEditorValidationMessage(cell, field) {
      const message = this.getDirectGridFieldValidationMessage(field);
      if (!message || !cell) {
        return;
      }
      const root = cell?.querySelector ? cell : null;
      if (!root) {
        return;
      }
      const inputs = root.matches?.("input, select, textarea")
        ? [root]
        : Array.from(root.querySelectorAll?.("input, select, textarea") || []);
      inputs.forEach(input => {
        input.setAttribute("required", "required");
        input.setAttribute("validationMessage", message);
      });
    },
    getDirectGridSearchRoot() {
      const widget = this.directGridWidget;
      return widget?.wrapper?.[0] || widget?.element?.[0] || this.$refs.gridRoot || null;
    },
    getDirectGridDataSourceItems() {
      const collection = this.directGridWidget?.dataSource?.data?.();
      return collection ? Array.from(collection) : [];
    },
    findActiveGridEditCell(root) {
      const grid = this.directGridWidget;
      const lockedCell = grid?.lockedTable?.find?.(".k-edit-cell")?.[0];
      if (lockedCell) {
        return lockedCell;
      }
      const mainCell = grid?.table?.find?.(".k-edit-cell")?.[0];
      if (mainCell) {
        return mainCell;
      }
      const searchRoot = root || this.getDirectGridSearchRoot();
      return (
        searchRoot?.querySelector?.(".k-grid-content-locked .k-edit-cell")
        || searchRoot?.querySelector?.(".k-grid-content .k-edit-cell")
        || searchRoot?.querySelector?.(".k-edit-cell")
        || null
      );
    },
    findGridScrollContentForEditCell(root, editCell) {
      const lockedContent = editCell?.closest?.(".k-grid-content-locked");
      if (lockedContent) {
        return lockedContent;
      }
      const scrollContent = editCell?.closest?.(".k-grid-content");
      if (scrollContent) {
        return scrollContent;
      }
      return (
        root?.querySelector?.(".k-grid-content-locked")
        || root?.querySelector?.(".k-grid-content")
        || null
      );
    },
    findVisibleValidationTooltip(editCell) {
      if (!editCell) {
        return null;
      }
      const candidates = editCell.querySelectorAll(
        ".k-invalid-msg, .k-tooltip-error, .k-validator-tooltip, .k-tooltip.k-tooltip-validation"
      );
      for (const element of candidates) {
        if (element?.classList?.contains?.("k-hidden")) {
          continue;
        }
        const text = element.textContent?.trim?.() || "";
        const hasMessage = text.length > 0 || element.querySelector?.(".k-tooltip-content");
        if (hasMessage || element.classList.contains("k-tooltip-error")) {
          return element;
        }
      }
      return null;
    },
    resetValidationTooltipCalloutDirection(editCell) {
      editCell?.querySelectorAll?.(".k-callout")?.forEach?.(callout => {
        callout.classList.remove("k-callout-s", "k-callout-e", "k-callout-w");
        callout.classList.add("k-callout-n");
      });
    },
    setValidationTooltipCalloutDirection(tooltip, above) {
      const callout = tooltip?.querySelector?.(".k-callout");
      if (!callout) {
        return;
      }
      if (above) {
        callout.classList.remove("k-callout-n", "k-callout-e", "k-callout-w");
        callout.classList.add("k-callout-s");
      } else {
        callout.classList.remove("k-callout-s", "k-callout-e", "k-callout-w");
        callout.classList.add("k-callout-n");
      }
    },
    isLastDataSourceEditRow(editRow) {
      if (!editRow) {
        return false;
      }
      const grid = this.directGridWidget;
      const dataItem = grid?.dataItem?.(editRow);
      const items = this.getDirectGridDataSourceItems();
      if (!items.length) {
        return false;
      }
      const lastItem = items[items.length - 1];
      if (dataItem && lastItem) {
        return dataItem === lastItem || dataItem.uid === lastItem.uid;
      }
      const rowUid = editRow.getAttribute("data-uid");
      return !!rowUid && lastItem?.uid === rowUid;
    },
    isLastVisibleTbodyRow(editRow) {
      const tbody = editRow?.closest?.("tbody");
      if (!tbody) {
        return false;
      }
      const dataRows = tbody.querySelectorAll(":scope > tr[data-uid]");
      if (!dataRows.length) {
        return false;
      }
      return dataRows[dataRows.length - 1] === editRow;
    },
    isEditRowInVisibleBottomBand(editCell, content) {
      const editRow = editCell?.closest?.("tr");
      if (!editRow || !content) {
        return false;
      }
      const contentRect = content.getBoundingClientRect();
      const rowRect = editRow.getBoundingClientRect();
      const rowBottomGap = contentRect.bottom - rowRect.bottom;
      if (rowBottomGap < 52) {
        return true;
      }
      const tbody = editRow.closest("tbody");
      if (!tbody) {
        return false;
      }
      const dataRows = Array.from(tbody.querySelectorAll(":scope > tr[data-uid]"));
      const rowIndex = dataRows.indexOf(editRow);
      if (rowIndex < 0) {
        return false;
      }
      return rowIndex >= dataRows.length - 2;
    },
    shouldPlaceValidationTooltipAbove(editCell, content, anchor, tooltip) {
      const editRow = editCell?.closest?.("tr");
      const anchorRect = anchor.getBoundingClientRect();
      const contentRect = content.getBoundingClientRect();
      const tooltipRect = tooltip.getBoundingClientRect();
      const rowRect = editRow?.getBoundingClientRect?.() || anchorRect;
      const tooltipHeight = Math.max(
        tooltip.offsetHeight || 0,
        tooltip.scrollHeight || 0,
        tooltipRect.height || 0,
        36
      );
      const spaceBelow = contentRect.bottom - anchorRect.bottom;
      const rowBottomGap = contentRect.bottom - rowRect.bottom;
      const overflowsBelow =
        tooltipRect.height > 0 && tooltipRect.bottom > contentRect.bottom - 2;
      const projectedOverflow =
        anchorRect.bottom + tooltipHeight + 4 > contentRect.bottom;
      return (
        overflowsBelow
        || projectedOverflow
        || spaceBelow < tooltipHeight + 4
        || rowBottomGap < tooltipHeight + 8
        || this.isEditRowInVisibleBottomBand(editCell, content)
        || this.isLastDataSourceEditRow(editRow)
        || this.isLastVisibleTbodyRow(editRow)
      );
    },
    applyValidationTooltipPlacement() {
      const root = this.getDirectGridSearchRoot();
      if (!root) {
        return;
      }
      const editCell = this.findActiveGridEditCell(root);
      const content = this.findGridScrollContentForEditCell(root, editCell);
      if (!content || !editCell) {
        return;
      }
      const tooltip = this.findVisibleValidationTooltip(editCell);
      if (!tooltip) {
        return;
      }
      root.querySelectorAll(".ntss-validation-above").forEach(element => {
        if (element !== editCell) {
          element.classList.remove("ntss-validation-above");
          this.resetValidationTooltipCalloutDirection(element);
        }
      });
      const anchor =
        editCell.querySelector(".k-input.k-textbox, .k-picker, .k-input")
        || editCell.querySelector("input, textarea, select, .k-input-inner, .k-textbox")
        || editCell;
      const needsAbove = this.shouldPlaceValidationTooltipAbove(
        editCell,
        content,
        anchor,
        tooltip
      );
      if (needsAbove) {
        editCell.classList.add("ntss-validation-above");
      } else {
        editCell.classList.remove("ntss-validation-above");
      }
      this.setValidationTooltipCalloutDirection(tooltip, needsAbove);
    },
    stopValidationTooltipPlacementWatch() {
      const ownerWindow = this.getDirectGridSearchRoot()?.ownerDocument?.defaultView || window;
      if (this.validationTooltipPlacementIntervalId) {
        ownerWindow.clearInterval?.(this.validationTooltipPlacementIntervalId);
        this.validationTooltipPlacementIntervalId = null;
      }
    },
    startValidationTooltipPlacementWatch() {
      this.stopValidationTooltipPlacementWatch();
      const ownerWindow = this.getDirectGridSearchRoot()?.ownerDocument?.defaultView || window;
      let attempts = 0;
      const tick = () => {
        attempts += 1;
        this.applyValidationTooltipPlacement();
        const editCell = this.findActiveGridEditCell(this.getDirectGridSearchRoot());
        const tooltip = this.findVisibleValidationTooltip(editCell);
        if (!tooltip || attempts >= 5) {
          this.stopValidationTooltipPlacementWatch();
        }
      };
      tick();
      this.validationTooltipPlacementIntervalId = ownerWindow.setInterval?.(tick, 100);
    },
    clearValidationTooltipPlacementTimers() {
      const ownerWindow = this.getDirectGridSearchRoot()?.ownerDocument?.defaultView || window;
      this.validationTooltipPlacementTimers.forEach(timerId => {
        ownerWindow.clearTimeout?.(timerId);
      });
      this.validationTooltipPlacementTimers = [];
      if (this.validationTooltipPlacementRafId) {
        ownerWindow.cancelAnimationFrame?.(this.validationTooltipPlacementRafId);
        this.validationTooltipPlacementRafId = null;
      }
    },
    scheduleValidationTooltipPlacement() {
      this.clearValidationTooltipPlacementTimers();
      const ownerWindow = this.getDirectGridSearchRoot()?.ownerDocument?.defaultView || window;
      const run = () => this.applyValidationTooltipPlacement();
      run();
      this.$nextTick(run);
      this.validationTooltipPlacementRafId = ownerWindow.requestAnimationFrame?.(() => {
        this.validationTooltipPlacementRafId = ownerWindow.requestAnimationFrame?.(() => {
          this.validationTooltipPlacementRafId = null;
          run();
        }) || null;
      }) || null;
      const timerId = ownerWindow.setTimeout?.(run, 80);
      if (timerId) {
        this.validationTooltipPlacementTimers.push(timerId);
      }
      this.startValidationTooltipPlacementWatch();
    },
    getBedSchemaFieldKeys() {
      const fields = this.getMasterRecordList?.schema?.model?.fields;
      if (!fields) {
        return null;
      }
      return Object.keys(fields).filter(key => key !== "$modalType");
    },
    sanitizeBedCompareRecord(record) {
      const clone = clonePlain(record);
      this.normalizeBedRecord(clone);
      const schemaKeys = this.getBedSchemaFieldKeys();
      const ignore = new Set([
        "$modalType",
        "_defaultId",
        "_events",
        "_handlers",
        "dirty",
        "dirtyFields",
        "edited",
        "operation",
        "parent",
        "scaleDate",
        "scaleUserId",
        "skipSearch",
        "sortInputTime",
        "uid",
        "upDate",
        "dummy"
      ]);
      const keyList = schemaKeys || Object.keys(clone).filter(key => !ignore.has(key));
      return keyList.reduce((acc, key) => {
        if (ignore.has(key)) {
          return acc;
        }
        let value = clone[key];
        if (value === "" || value === undefined || value === "[]") {
          value = null;
        }
        acc[key] = value;
        return acc;
      }, {});
    },
    bedCompareScalarForCompare(value) {
      if (value === undefined || value === null || value === "" || value === "null") {
        return null;
      }
      if (typeof value === "string") {
        const trimmed = value.trim();
        return trimmed === "" ? null : trimmed;
      }
      return value;
    },
    bedCompareValuesEqual(a, b) {
      const na = this.bedCompareScalarForCompare(a);
      const nb = this.bedCompareScalarForCompare(b);
      if (na == nb) {
        return true;
      }
      const aEmpty = na === null || na === undefined;
      const bEmpty = nb === null || nb === undefined;
      if (aEmpty && bEmpty) {
        return true;
      }
      if (na instanceof Date || nb instanceof Date) {
        const ta = na instanceof Date ? na.getTime() : Number.NaN;
        const tb = nb instanceof Date ? nb.getTime() : Number.NaN;
        if (!Number.isNaN(ta) && !Number.isNaN(tb)) {
          return ta === tb;
        }
      }
      const numA = Number(na);
      const numB = Number(nb);
      if (
        !Number.isNaN(numA) &&
        !Number.isNaN(numB) &&
        `${na}`.trim() !== "" &&
        `${nb}`.trim() !== ""
      ) {
        return numA === numB;
      }
      return `${na}` === `${nb}`;
    },
    toStableBedCompareRecord(record) {
      const sanitizedRecord = this.sanitizeBedCompareRecord(record);
      return Object.keys(sanitizedRecord)
        .sort()
        .reduce((acc, key) => {
          acc[key] = sanitizedRecord[key];
          return acc;
        }, {});
    },
    isSameBedRecord(currentRecord, originalRecord) {
      const current = this.toStableBedCompareRecord(currentRecord);
      const original = this.toStableBedCompareRecord(originalRecord);
      const keys = new Set([...Object.keys(current), ...Object.keys(original)]);
      for (const key of keys) {
        if (!this.bedCompareValuesEqual(current[key], original[key])) {
          return false;
        }
      }
      return true;
    },
    hasBedChanges(currentRecords, originalRecords) {
      const currentList = Array.isArray(currentRecords) ? currentRecords : [];
      const originalList = Array.isArray(originalRecords) ? originalRecords : [];
      if (!Array.isArray(currentRecords) || currentList.length !== originalList.length) {
        return true;
      }
      if (originalList.length === 0) {
        return false;
      }
      const originalsByCode = new Map(
        originalList.map(record => [String(record.code), record])
      );
      return currentList.some(record => {
        const original = originalsByCode.get(String(record.code));
        return !original || !this.isSameBedRecord(record, original);
      });
    },
    findBedOriginalRecord(record) {
      if (!record || record.code === undefined || record.code === null) {
        return null;
      }
      return (this.dbBeforeData || []).find(item => String(item.code) === String(record.code)) || null;
    },
    isBedRecordChangedFromSnapshot(record) {
      const original = this.findBedOriginalRecord(record);
      if (!original) {
        return false;
      }
      return !this.isSameBedRecord(record, original);
    },
    isBedSortRankChangedFromSnapshot(record) {
      const original = this.findBedOriginalRecord(record);
      if (!original) {
        return false;
      }
      return !this.bedCompareValuesEqual(record.sortRank, original.sortRank);
    },
    getDirectGridRecordKey(record) {
      if (!record || record.code === undefined || record.code === null) {
        return null;
      }
      return String(record.code);
    },
    setDirectGridSortManuallyEdited(record, edited) {
      const key = this.getDirectGridRecordKey(record);
      if (!key) {
        return;
      }
      if (!this.directGridSortEditedCodes) {
        this.directGridSortEditedCodes = markRaw(new Set());
      }
      if (edited) {
        this.directGridSortEditedCodes.add(key);
      } else {
        this.directGridSortEditedCodes.delete(key);
      }
    },
    isDirectGridSortManuallyEdited(record) {
      const key = this.getDirectGridRecordKey(record);
      return !!key && !!this.directGridSortEditedCodes?.has?.(key);
    },
    isBedNonSortRecordChangedFromSnapshot(record) {
      const original = this.findBedOriginalRecord(record);
      if (!original) {
        return false;
      }
      const currentWithoutSort = clonePlain(record);
      const originalWithoutSort = clonePlain(original);
      currentWithoutSort.sortRank = originalWithoutSort.sortRank;
      currentWithoutSort.sortInputTime = originalWithoutSort.sortInputTime;
      return !this.isSameBedRecord(currentWithoutSort, originalWithoutSort);
    },
    clearBedRowPendingEdit(record) {
      if (!record || typeof record !== "object") {
        return;
      }
      ["operation", "edited", "dirty", "dirtyFields"].forEach(key => {
        if (Object.prototype.hasOwnProperty.call(record, key)) {
          delete record[key];
        }
      });
    },
    markBedRowPendingEdit(record) {
      if (!record || typeof record !== "object") {
        return;
      }
      if (!(record.operation === 1 || String(record.operation) === "1" || record.isAddRow === true)) {
        record.operation = 2;
      }
      record.edited = true;
    },
    getDirectGridModelPlain(model, overrides = {}) {
      const plain = typeof model?.toJSON === "function" ? model.toJSON() : clonePlain(model || {});
      Object.keys(overrides || {}).forEach(key => {
        plain[key] = overrides[key];
      });
      this.normalizeBedRecord(plain);
      return plain;
    },
    findMasterRecordByCode(code) {
      if (code === undefined || code === null || !Array.isArray(this.getMasterRecordList?.data)) {
        return null;
      }
      return this.getMasterRecordList.data.find(record => String(record.code) === String(code)) || null;
    },
    updateDirectMasterRecordFromModel(model, overrides = {}) {
      const plain = this.getDirectGridModelPlain(model, overrides);
      const target = this.findMasterRecordByCode(plain.code);
      if (!target) {
        return plain;
      }
      const internalKeys = new Set(["uid", "_events", "_handlers", "parent", "dirty", "dirtyFields"]);
      Object.keys(plain).forEach(key => {
        if (!internalKeys.has(key)) {
          target[key] = plain[key];
        }
      });
      if (this.isSortMode && Object.prototype.hasOwnProperty.call(overrides, "sortRank")) {
        target.sortInputTime = Object.prototype.hasOwnProperty.call(overrides, "sortInputTime")
          ? overrides.sortInputTime
          : Date.now();
      }
      if (this.isBedAddedRecord(target) || this.isBedNonSortRecordChangedFromSnapshot(target) || this.isDirectGridSortManuallyEdited(target)) {
        this.markBedRowPendingEdit(target);
      } else {
        this.setDirectGridSortManuallyEdited(target, false);
        this.clearBedRowPendingEdit(target);
        this.clearDirectGridEditedFields(target);
        const original = this.findBedOriginalRecord(target);
        if (original) {
          const snapshot = clonePlain(original);
          this.normalizeBedRecord(snapshot);
          const keys = this.getBedSchemaFieldKeys() || Object.keys(snapshot);
          keys.forEach(key => {
            if (Object.prototype.hasOwnProperty.call(snapshot, key)) {
              target[key] = snapshot[key];
              if (model && key in model) {
                model[key] = snapshot[key];
              }
            }
          });
        }
      }
      return target;
    },
    normalizeBedDropdownValues(values) {
      if (!Array.isArray(values)) {
        return values;
      }
      return values.reduce((list, item) => {
        const normalizedValue = item?.value === null || item?.value === "null" || item?.value === "" ? "" : item?.value;
        if (!list.some(option => option.value == normalizedValue)) {
          list.push({
            ...item,
            value: normalizedValue
          });
        }
        return list;
      }, []);
    },
    async systemUseSetting() {
      if (this.facilitylistValue) {
        // 施設のシステム利用設定を取得する
        const mstFacilityHash = await sendRequestGetMstFacilityHashByFacilityCd(this.facilitylistValue);
        this.facilitySysUseSetting = mstFacilityHash.data.systemUseSetting ? mstFacilityHash.data.systemUseSetting : "";
      } else {
        this.facilitySysUseSetting = "";
      }
    },
    // マスタ一覧のデータを取得
    findList() {
      // システム利用設定取得処理
      this.systemUseSetting().then(() => {
        // apiをコールして値を取得
        this.findRecordListByFacilityCd(this.facilitylistValue)
          .then(response => {
            const normalizedLocalDataSource = this.normalizeBedDataSource(response.data.localDataSource);
            this.directGridSortEditedCodes?.clear?.();
            this.directGridEditedFieldsByCode?.clear?.();
            this.directGridDataSource = normalizedLocalDataSource;
            this.setMasterRecordList(normalizedLocalDataSource);
            // カラム情報のJSONが未定義の場合には、ダイアログを出して画面を閉じる
            if (response.data.columns.length === 0) {
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
            const toFunction = clonePlain(response.data.columns);
            toFunction.forEach(column => {
              // 初期表示時の編集可否を退避
              column.originalEditable = column.editable;
              // 編集可否を関数化
              column.editable = column.editable ? () => true : () => false;
              // 列幅初期化
              column.width = column.width ? column.width : "0";
              if (column.field === "machineNo") {
                column.values = this.normalizeBedDropdownValues(column.values);
              }
            });
            this.columns = toFunction;

            // 横スクロールバーを表示するために列幅を指定
            this.columns.forEach(column => {
              // 「削除」のプルダウンが改行しない幅に調整
              // mod #7289-マスタの削除ボタンが縦表示になる 徐博 start
              // column.width = column.field === "isDisp" ? "8em" : (this.columnWidth + "em");
              column.width = column.field === "isDisp" ? "9em" : this.columnWidth + "em";
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
            // 連携コード１のインデックス取得
            const inHospitalCd1Index = this.columns.findIndex(col => col.field === "inHospitalCd1");
            // 連携コード２のインデックス取得
            const inHospitalCd2Index = this.columns.findIndex(col => col.field === "inHospitalCd2");
            if (this.facilitySysUseSetting === "1") {
              // 連携コード１／連携コード２を非表示
              if (inHospitalCd1Index >= 0) {
                this.columns[inHospitalCd1Index].hidden = true;
              }
              if (inHospitalCd2Index >= 0) {
                this.columns[inHospitalCd2Index].hidden = true;
              }
            }
            // Vue2 初期表示と同じく、通常モードでは sortRank を隠し dummy を表示する。
            this.applyInitialSortColumnVisibility();
            this.applyBedSchemaValidationMessages(normalizedLocalDataSource.schema);
            this.setMasterRecordList(normalizedLocalDataSource);
            // 初期データ内容を保存
            this.setComparisonRecordModel();
            //add #9594 ベッドマスタでプリンター及び自動印刷の設定を変更し、保存しようとするとメッセージが表示され保存できない zrx start
            const dataTemp = normalizedLocalDataSource.data;
            this.dbBeforeData = clonePlain(dataTemp);
            //add #9594 ベッドマスタでプリンター及び自動印刷の設定を変更し、保存しようとするとメッセージが表示され保存できない zrx end
            this.$nextTick(() => {
              this.calculateGridHeight();
              this.initDirectGridIfReady();
              this.scheduleDirectGridPostLayoutRefresh();
              const restore = () => this.restoreDirectGridScrollPosition();
              restore();
              requestAnimationFrame(restore);
            });
          })
          .catch(error => {
            if (error.response?.status === 400) {
              //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
              getErrorMessage("MstBedMainComponent.vue", "findRecordListByFacilityCd", "指定されたマスタが見つかりません。");
              //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
              this.$ons.notification.alert({
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // title: "取得失敗",
                // message: "指定されたマスタが見つかりません。"
                title: DIALOG_MESSAGES[12000003].title,
                message: messageFormat(DIALOG_MESSAGES[12000003].message)
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              });
            }
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
            else {
              getErrorMessage("MstBedMainComponent.vue", "findRecordListByFacilityCd", error);
            }
            //FNSI-修正 VUEのエラー場合のログ対応 liumx end
            this.setLoadingScreenVisible(false);
          });
        // カラム定義情報を取得
        this.findColumnInfo();
      });
    },
    findFacilityList() {
      if (this.getStateUserAccountInfo?.userType !== 1) {
        this.facilitylistValue = this.getStateUserAccountInfo?.facilityCd;
        this.findList();
        return;
      }
      this.facilityList()
        .then(() => {
          this.facilitylistValue = this.getStateUserAccountInfo?.facilityCd;
          this.findList();
        })
        .catch(error => {
          getErrorMessage("MstBedMainComponent.vue", "facilityList", error);
          if (error.response?.status === 400) {
            this.$ons.notification.alert({
              title: DIALOG_MESSAGES[12000003].title,
              message: messageFormat(DIALOG_MESSAGES[12000003].message)
            });
          }
        });
    },
    onOpenFacility(e) {
      this.prevFacilityCd = e?.sender?._old;
    },
    onChangeFacility(e) {
      if (this.prevFacilityCd == e?.sender?._old) {
        return;
      }
      const newFacilityCd = e?.sender?._old;
      if (this.isChanged) {
        e?.preventDefault?.();
        this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[13000004].title,
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          callback: answer => {
            if (answer === 1) {
              this.facilitylistValue = newFacilityCd;
              this.findList();
            } else {
              this.facilitylistValue = this.prevFacilityCd;
            }
          }
        });
      } else {
        this.facilitylistValue = newFacilityCd;
        this.findList();
      }
    },
    getFilteredBedMachineNoEditorValues(currentMachineNo) {
      const masterValues = this.getBedMachineNoMasterValues();
      if (!masterValues.length) {
        return [];
      }
      const usedMachineNos = (this.getMasterRecordList?.data || []).map(machine => String(machine.machineNo));
      return masterValues.filter(element => {
        const value = element?.value == null ? "" : String(element.value);
        return (
          (!usedMachineNos.includes(value) || String(currentMachineNo) === value) &&
          !this.exclusionListNo.includes(value)
        );
      });
    },
    machineNoEditor(container, data) {
      const currentMachineNo = data?.model?.[data.field];
      const values = this.getFilteredBedMachineNoEditorValues(currentMachineNo);
      const dataSource = values.reduce((list, item) => {
        const normalizedValue = item?.value === null || item?.value === "null" || item?.value === "" ? "" : item?.value;
        if (!list.some(option => option.value === normalizedValue)) {
          list.push({
            ...item,
            value: normalizedValue,
            text: normalizedValue === "" ? "" : item?.text
          });
        }
        return list;
      }, []);
      if (!dataSource.some(item => item?.value === "")) {
        dataSource.unshift({ value: "", text: "" });
      }
      const currentValue = data?.model?.[data.field] === null || data?.model?.[data.field] === "null" || data?.model?.[data.field] === ""
        ? ""
        : `${data?.model?.[data.field]}`;
      const input = $(`<input name="${data.field}" />`).appendTo(container);
      input.kendoDropDownList({
        dataSource,
        dataTextField: "text",
        dataValueField: "value",
        valuePrimitive: true,
        animation: false,
        value: currentValue,
        select: e => {
          const selectedValue = e.dataItem.value === null || e.dataItem.value === undefined || e.dataItem.value === ""
            ? ""
            : Number(e.dataItem.value);
          data.model.set(data.field, Number.isNaN(selectedValue) ? e.dataItem.value : selectedValue);
          this.closeBedGridDropDownEditor(e.sender, container);
        },
        change: e => {
          this.closeBedGridDropDownEditor(e.sender, container);
        }
      });
      const dropDownWidget = input.data("kendoDropDownList");
      dropDownWidget?.wrapper?.css("width", "100%");
      this.bindBedGridEditorDropDownToCloseCell(container);
    },
    isDispEditor(container, data) {
      const field = data?.field || "isDisp";
      const column = this.columns.find(item => item.field === field);
      const dataSource = clonePlain(column?.values || []);
      const currentValue = data?.model?.[field] === null || data?.model?.[field] === undefined
        ? ""
        : String(data.model[field]);
      const input = $(`<input name="${field}" />`).appendTo(container);
      input.kendoDropDownList({
        dataSource,
        dataTextField: "text",
        dataValueField: "value",
        valuePrimitive: true,
        animation: false,
        value: currentValue,
        select: e => {
          const selectedValue = e.dataItem?.value === null || e.dataItem?.value === undefined
            ? ""
            : String(e.dataItem.value);
          if (typeof data?.model?.set === "function") {
            data.model.set(field, selectedValue);
          } else if (data?.model) {
            data.model[field] = selectedValue;
          }
          this.closeBedGridDropDownEditor(e.sender, container);
        },
        change: e => {
          this.closeBedGridDropDownEditor(e.sender, container);
        }
      });
      const dropDownWidget = input.data("kendoDropDownList");
      dropDownWidget?.wrapper?.css("width", "100%");
      this.bindBedGridEditorDropDownToCloseCell(container);
    },
    modifyEditStart(e) {
      if (this.isMobileDevice && !this.allowEdit) {
        e?.preventDefault?.();
        return;
      }
      this.storeDirectGridScrollPosition();
      if (!this.exclusionListNo) {
        this.exclusionListNo = [];
      }
      // 編集時の選択肢だけ絞る。widgetColumn.values を書き換えると一覧表示も同じ values で
      // 解決されるため、他行の接続装置が空欄になる（Vue2 wrapper では起きなかった）。
    },
    showMasterEditModal(e) {
      this.storeDirectGridScrollPosition();
      const grid = this.directGridWidget;
      let selectedRowItem = null;
      if (grid && e?.currentTarget) {
        selectedRowItem = grid.dataItem(e.currentTarget.closest("tr"));
      }
      if (!selectedRowItem) {
        e?.preventDefault?.();
        return;
      }
      this.showMasterEdit();
      e?.preventDefault?.();
      if (!selectedRowItem.code) {
        this.edit({ editRecord: selectedRowItem, isSortMode: this.isSortMode });
      }
      const normalizedItem = this.normalization(selectedRowItem);
      this.setEditRecord(normalizedItem);
      this.setFacilitySysUseSetting(this.facilitySysUseSetting);
    },
    addRow() {
      if (!this.validateBeforeSortMode()) {
        return;
      }
      const fields = this.getMasterRecordList?.schema?.model?.fields || {};
      const record = {};
      Object.keys(fields).forEach(key => {
        const fieldInfo = fields[key] || {};
        if (fieldInfo.defaultValue !== undefined && fieldInfo.defaultValue !== null) {
          record[key] = fieldInfo.defaultValue;
        } else if (fieldInfo.type === "string") {
          record[key] = "";
        } else if (fieldInfo.type === "number") {
          record[key] = 0;
        } else if (fieldInfo.type === "date") {
          record[key] = new Date();
        } else {
          record[key] = null;
        }
        if (key === "sortRank") {
          record[key] = this.getMaxSortRank() + 1;
        }
      });
      record.shuntPosition = 0;
      // Vue2 store は追加時に operation=1 / skipSearch を付与する。
      // direct jq 側でも追加行判定を維持し、検索条件の対象外として表示し続ける。
      record.isAddRow = true;
      record.skipSearch = true;
      // Vue2 の追加行は保存前 operation=1 として grid 上は編集行（緑）表示する。
      record.operation = 1;
      record.edited = true;
      this.edit({ editRecord: record, isSortMode: this.isSortMode });
      this.normalizeBedRecord(record);
      this.directGridSortEditedCodes?.delete?.(String(record.code));
      this.clearDirectGridEditedFields(record);
      // 追加行: 横スクロールを先頭へ（MasterRecordComponent.addRow と同様）
      this.scrollPosition.left = 0;
      this.lastScrollLeft = 0;
      this.__pendingScrollLeftReset = true;
      this.directGridScrollAtBottom = true;
      this.refreshDirectGridDataFromMasterRecords(true);
    },
    syncDirectGridDataFromStore() {
      if (!this.directGridDataSource) {
        this.directGridDataSource = clonePlain(this.getMasterRecordList || {});
      }
      this.directGridDataSource.data = clonePlain(this.getMasterRecordList?.data || []);
      this.directGridDataSource.data.forEach(record => this.normalizeBedRecord(record));
    },
    async saveRecord() {
      this.setLoadingScreenVisible(true);
      this.storeDirectGridScrollPosition();
      try {
        this.directGridWidget?.closeCell?.();
      } catch (_error) {
        // noop
      }
      this.syncDirectGridSortValuesToMasterRecords();
      if (!this.validateBeforeSortMode()) {
        this.setLoadingScreenVisible(false);
        this.restoreDirectGridScrollPosition();
        return;
      }
      const records = this.getMasterRecordList;
      records.data = (records.data || []).filter(record => !(record.operation === 1 && !record.edited));
      this.setMasterRecordList(records);
      const validateMessage = this.validateRequired();
      const validateComboMessage = this.validateComboValue();
      let message = "";
      if (validateMessage.length !== 0) {
        message = messageFormat(DIALOG_MESSAGES[12000270].message) + validateMessage;
      }
      if (validateComboMessage.length !== 0) {
        if (message.length !== 0) {
          message += "</br>";
        }
        message += messageFormat(DIALOG_MESSAGES[12000006].message) + validateComboMessage;
      }
      if (message.length !== 0) {
        this.setLoadingScreenVisible(false);
        this.$ons.notification.alert({
          title: DIALOG_MESSAGES[12000006].title,
          message: '<div style="text-align:left;">' + message + "</div>"
        });
        this.restoreDirectGridScrollPosition();
        return;
      }
      const treatmentList = (this.getUpdateRecordList || []).filter(record => record.operation && record.operation == 2);
      let treatmentFlg = false;
      for (const item of treatmentList) {
        const beforeItem = (this.dbBeforeData || []).find(record => record.code === item.code);
        if (this.lockbedList && this.lockbedList.includes(item.code) && beforeItem && beforeItem.machineNo !== item.machineNo) {
          treatmentFlg = true;
          break;
        }
      }
      if (treatmentFlg) {
        this.setLoadingScreenVisible(false);
        this.$ons.notification.alert({
          title: DIALOG_MESSAGES[13000163].title,
          message: messageFormat(DIALOG_MESSAGES[13000163].message)
        });
        this.restoreDirectGridScrollPosition();
        return;
      }
      try {
        const recordModelList = JSON.parse(this.comparisonRecordModel || "[]");
        const machineTypeLists = await sendRequestGetMachineType();
        const upDataList = (this.getUpdateRecordList || []).filter(record => {
          const oldRecord = recordModelList.find(item => item.code == record.code);
          return record.operation && record.operation == 2 && oldRecord && oldRecord.machineNo != record.machineNo;
        });
        if (upDataList.length > 0) {
          let requestData = [];
          await sendRequestFindRecordList("mst_status_map_bed_layout").then(response => {
            upDataList.forEach(record => {
              const itemData = response.data.localDataSource.data || [];
              itemData.forEach(item => {
                const bedLayout = JSON.parse(item.bedLayout);
                const editItems = bedLayout.obj_list;
                editItems.forEach((edititem, index) => {
                  if (record.code == edititem.bed_cd) {
                    const machine = this.mstMachine.find(a => a.machineNo == record.machineNo);
                    editItems[index] = {
                      top: edititem.top,
                      left: edititem.left,
                      name: edititem.name,
                      model: machine ? machineTypeLists.data.find(c => machine.machineTypeCd == c.machineTypeCd)?.model : "",
                      width: edititem.width,
                      bed_cd: edititem.bed_cd,
                      height: edititem.height,
                      machine_no: record.machineNo ? record.machineNo : -1,
                      disp_order_no: edititem.disp_order_no,
                      machine_serial: machine ? machine.machineSerial : "",
                      machine_type_cd: machine ? machine.machineTypeCd : "",
                      is_home_dialysis: edititem.is_home_dialysis
                    };
                  }
                });
                if (JSON.stringify(bedLayout.obj_list) !== JSON.stringify(editItems)) {
                  item.operation = 2;
                  bedLayout.obj_list = editItems;
                  item.bedLayout = JSON.stringify(bedLayout);
                }
              });
            });
            requestData = response.data.localDataSource.data;
          });
          if (requestData && requestData.length > 0) {
            await sendRequestUpdateRecordListByFacilityCd("mst_status_map_bed_layout", this.getFacilitySwitch, requestData);
          }
        }
        const response = await this.updateRecordListByFacilityCd({ facilityCd: this.facilitylistValue, request: this.getUpdateRecordList });
        this.updateResponse = response.data;
        this.setLoadingScreenVisible(false);
        this.$ons.notification.alert({
          title: DIALOG_MESSAGES[12000004].title,
          message: messageFormat(DIALOG_MESSAGES[12000004].message)
        });
        this.isSorted = false;
        this.findList();
      } catch (error) {
        getErrorMessage("MstBedMainComponent.vue", "updateRecordListByFacilityCd", error);
        this.setLoadingScreenVisible(false);
        this.restoreDirectGridScrollPosition();
        if (error.response?.status === 400) {
          this.$ons.notification.alert({
            title: DIALOG_MESSAGES["00300005"].title,
            message: error.response.data.errorMessage
          });
        }
      }
    },

    buildDirectGridColumns() {
      return this.columns.map(column => {
        const gridColumn = {
          title: column.title,
          field: column.field,
          hidden: !!column.hidden,
          locked: !!column.locked,
          editable: column.editable,
          width: this.normalizeDirectGridColumnWidth(column.width),
          format: column.format,
          values: column.values || null,
          attributes: {
            "data-field": column.field
          }
        };
        if (column.field === "machineNo") {
          gridColumn.editor = this.machineNoEditor;
          gridColumn.template = dataItem => this.formatBedMachineNoCell(dataItem?.machineNo);
          // values 列の表示解決はマスタ全件を使う。editor 側だけ未使用装置に絞る。
          delete gridColumn.values;
        }
        if (column.field === "isDisp") {
          gridColumn.editor = this.isDispEditor;
        }
        if (column.field === "$modalType") {
          gridColumn.attributes = { class: "btn3-kendo-normal", "data-field": column.field };
          gridColumn.command = {
            text: "詳細",
            click: this.showMasterEditModal
          };
          delete gridColumn.values;
        }
        return gridColumn;
      });
    },
    createDirectDataSource() {
      const sourceConfig = clonePlain(this.directGridDataSource);
      sourceConfig.data = this.getDirectGridDisplayData();
      if (kendo?.data?.DataSource) {
        return markRaw(new kendo.data.DataSource(sourceConfig));
      }
      return sourceConfig;
    },
    initDirectGridIfReady() {
      if (!this.directGridMounted || this.columns.length <= 1 || !this.directGridDataSource || !this.$refs.gridRoot) {
        return;
      }
      installComponentJQuery();
      this.destroyDirectGrid();
      const $gridRoot = $(this.$refs.gridRoot);
      this.applyDirectGridLegacyShellClasses();
      const options = {
        dataSource: this.createDirectDataSource(),
        editable: true,
        selectable: true,
        reorderable: false,
        height: this.kendoGridHeight,
        scrollable: true,
        columns: this.buildDirectGridColumns(),
        beforeEdit: this.modifyEditStart,
        edit: this.onDirectGridEdit,
        save: this.onDirectGridSave,
        dataBound: () => {
          this.directGridReady = true;
          this.restoreDirectGridMachineNoColumnValues();
          this.applyDirectGridLegacyStyleContract();
          this.bindDirectGridScrollPositionTracking();
          this.scheduleDirectGridPostLayoutRefresh();
          this.$nextTick(() => {
            this.refreshDirectGridDirtyVisualState();
          });
          this.setLoadingScreenVisible(false);
        }
      };
      $gridRoot.kendoGrid(options);
      this.directGridWidget = markRaw($gridRoot.data("kendoGrid"));
      this.applyDirectGridLegacyShellClasses();
      this.bindDirectGridScrollPositionTracking();
      this.scheduleDirectGridPostLayoutRefresh();
      if (!this.directGridWidget) {
        this.setLoadingScreenVisible(false);
      }
    },
    destroyDirectGrid() {
      this.clearValidationTooltipPlacementTimers();
      this.stopValidationTooltipPlacementWatch();
      this.unbindDirectGridScrollPositionTracking();
      const grid = this.directGridWidget;
      if (grid) {
        try {
          grid.destroy();
        } catch (_error) {
          // 第1批では destroy 失敗時に追加補正をしない。
        }
      }
      if (this.$refs.gridRoot) {
        $(this.$refs.gridRoot).empty();
      }
      this.directGridWidget = null;
      this.directGridReady = false;
    },
    stage1NoopCommand(e) {
      e?.preventDefault?.();
    }
  }
};
</script>

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
.kendo-grid-toolbar-style {
  padding: 0.1em 0.3em;
}
.kendo-grid-toolbar-style span {
  margin: 0;
}

/* 第1-S批: direct jQuery Kendo Grid only. Keep the old Vue2 wrapper shell contract
   local to this screen without using the shared KendoGrid compat/helper chain. */
.mst-bed-direct-jq-toolbar.k-grid-toolbar.k-header {
  box-sizing: border-box;
  width: 100%;
}
.mst-bed-direct-jq-grid :deep(.k-grid-header table),
.mst-bed-direct-jq-grid :deep(.k-grid-content table),
.mst-bed-direct-jq-grid :deep(.k-grid-header-locked table),
.mst-bed-direct-jq-grid :deep(.k-grid-content-locked table) {
  border-collapse: separate;
}
.mst-bed-direct-jq-grid :deep(.k-grid-header),
.mst-bed-direct-jq-grid :deep(.k-grid-content),
.mst-bed-direct-jq-grid :deep(.k-grid-header-locked),
.mst-bed-direct-jq-grid :deep(.k-grid-content-locked),
.mst-bed-direct-jq-grid :deep(.k-table),
.mst-bed-direct-jq-grid :deep(.k-table-row),
.mst-bed-direct-jq-grid :deep(.k-table-th),
.mst-bed-direct-jq-grid :deep(.k-table-td),
.mst-bed-direct-jq-grid :deep(.k-td),
.mst-bed-direct-jq-grid :deep(.k-header),
.mst-bed-direct-jq-grid :deep(th),
.mst-bed-direct-jq-grid :deep(td),
.mst-bed-direct-jq-grid :deep(.k-link),
.mst-bed-direct-jq-grid :deep(.k-column-title) {
  font-size: inherit;
  line-height: inherit;
}

.mst-bed-direct-jq-grid :deep(td.master-edited-row),
.mst-bed-direct-jq-grid :deep(tr.k-selected > td.master-edited-row),
.mst-bed-direct-jq-grid :deep(tr.k-state-selected > td.master-edited-row) {
  color: #003300 !important;
  background-color: #ccffcc !important;
}
.mst-bed-direct-jq-grid :deep(.k-dirty) {
  display: none;
}
.mst-bed-direct-jq-grid :deep(td.k-dirty-cell .k-dirty),
.mst-bed-direct-jq-grid :deep(td.master-edited-cell .k-dirty) {
  display: block;
}
.mst-bed-direct-jq-grid :deep(td.k-dirty-cell),
.mst-bed-direct-jq-grid :deep(td.master-edited-cell) {
  position: relative;
}
.mst-bed-direct-jq-grid :deep(td.master-edited-cell) {
  color: #003300 !important;
  font-weight: bold !important;
}
.mst-bed-direct-jq-grid :deep(td.master-sort-edited),
.mst-bed-direct-jq-grid :deep(tr.k-selected > td.master-sort-edited),
.mst-bed-direct-jq-grid :deep(tr.k-state-selected > td.master-sort-edited) {
  background-color: #ffff66 !important;
}
 
/* add 8130 全施設マスタでフリーズする 周安寧 start */
.kendo-grid-toolbar-style :deep(.k-tooltip.k-tooltip-validation) {
  width: auto;
}
.kendo-grid-toolbar-style :deep(.k-edit-cell) {
  position: relative;
  overflow: visible;
}
.kendo-grid-toolbar-style :deep(.k-edit-cell > .k-invalid-msg:not(.k-hidden)),
.kendo-grid-toolbar-style :deep(.k-edit-cell > .k-form-error:not(.k-hidden)),
.kendo-grid-toolbar-style :deep(.k-edit-cell > .k-validator-tooltip:not(.k-hidden)),
.kendo-grid-toolbar-style :deep(.k-edit-cell > .k-tooltip-error:not(.k-hidden)),
.mst-bed-direct-jq-grid :deep(.k-edit-cell > .k-invalid-msg:not(.k-hidden)),
.mst-bed-direct-jq-grid :deep(.k-edit-cell > .k-tooltip-error:not(.k-hidden)) {
  position: absolute;
  top: calc(100% + 2px);
  bottom: auto;
  z-index: 10;
  width: auto;
  min-width: 10em;
  max-width: min(24em, 90vw);
  margin: 0;
  white-space: normal;
  display: flex !important;
  align-items: flex-start;
  font-family: inherit !important;
  font-size: inherit !important;
  font-weight: normal !important;
  line-height: 1.4 !important;
  box-sizing: border-box;
  transform: none !important;
}
/* 下端行は JS ntss-validation-above でセル上に表示 */
.kendo-grid-toolbar-style :deep(td.k-edit-cell.ntss-validation-above > .k-invalid-msg),
.kendo-grid-toolbar-style :deep(td.k-edit-cell.ntss-validation-above .k-tooltip.k-tooltip-validation),
.mst-bed-direct-jq-grid :deep(td.k-edit-cell.ntss-validation-above > .k-invalid-msg),
.mst-bed-direct-jq-grid :deep(td.k-edit-cell.ntss-validation-above .k-tooltip.k-tooltip-validation) {
  position: absolute !important;
  left: 0 !important;
  bottom: 38px !important;
  top: auto !important;
  margin-top: 0 !important;
  overflow: visible !important;
}
.kendo-grid-toolbar-style :deep(td.k-edit-cell.ntss-validation-above .k-callout.k-callout-s),
.mst-bed-direct-jq-grid :deep(td.k-edit-cell.ntss-validation-above .k-callout.k-callout-s) {
  top: auto !important;
  bottom: calc(-12px) !important;
  border-bottom-color: transparent !important;
  border-block-start-color: currentColor !important;
}
/* add 8130 全施設マスタでフリーズする 周安寧 end */
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
.kendo-grid-toolbar-style :deep(.k-grid-content > .k-selectable) {
  box-shadow: 1px 0px 0px 0px white;
  border-right: 1px solid transparent;
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
.mobile-header {
  min-height: 30px; /* モバイル用の高さ */
}
</style>
