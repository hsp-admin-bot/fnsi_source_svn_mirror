/**
 * 検査結果一覧用メイン
 */
<template>
  <div class='main-content-area kendo-grid-style-page' style = "overflow-y: auto;">
    <div class='exam-record-head-content'>
    </div>
    <div class='exam-record-main-content'>
      <!-- チェックリスト一覧のグリッド -->
      <div id='examrecordlistgrid'>
        <!-- mod FNSI-数値ソート、文字ソート、空後方で結合してソートする 江 start -->
        <!-- mod FNSI-列幅変更、列幅移動可能にする 江 start -->
        <div
          class='exam-record-list ntss-kendo-grid-legacy'
          ref='examrecordlistgrid'
        ></div>
        <!-- mod FNSI-数値ソート、文字ソート、空後方で結合してソートする 江 end -->
      </div>
      <div id="grid-footer" style="float:right;">
        <!-- mod 編集権限の適用 劉全航 start -->
            <!-- mod #10359 編集権限の動作不正 dengshen start -->
            <!-- <v-ons-button -->
            <!--   class="common-style-select-button btn3-normal" -->
            <!--   style="width: auto; margin-right: 2em;margin-top:10px" -->
            <!--   @click="fileCapture" -->
            <!--   :disabled="isDisabled" -->
            <!-- > -->
            <v-ons-button
              class="common-style-select-button btn3-normal"
              style="width: auto; margin-right: 2em;margin-top:10px"
              @click="fileCapture"
              :disabled="isDisabled || !getItemAuthorized('ExamRecord', 'default_authority')"
            >
            <!-- mod #10359 編集権限の動作不正 dengshen end -->
              一括取込
            </v-ons-button>
          <!-- mod 編集権限の適用 劉全航 start -->
          <!-- <v-ons-button
              class="common-style-select-button"
              style="width: auto; margin-right: 1em;"
              @click="fileCapture"
            >
              一括取込
            </v-ons-button> -->
      </div>
      <input id="upload_text" type="file" @change="fileChange" style="visibility:hidden" accept=".txt,.dat" />
    </div>
    <message-dialog
      v-model:visible="isDialogVisible"
      :message-cd="messageCd"
      :type="dialogType"
    />
  </div>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
// add #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。linjunfeng start
// import { mapGetters, mapActions } from "@/compat/vue/vuex";
import { mapGetters, mapActions, mapMutations } from "@/compat/vue/vuex";
// add #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。linjunfeng end
import { EventBus } from "@/compat/vue/event-bus.js";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import PrintMixin from "@/components/PrintMixin";
import { ApiHelper } from "@/apis/AxiosHelper";
import { deepCopy } from "@/functions/common/CommonFunctions";
//import moment from "moment";
import kendo from "@progress/kendo-ui";
import $$ from "@/compat/jquery";

// del #10359 編集権限の動作不正 dengshen start
// //mod 編集権限の適用 劉全航 start
// import { AUTHORITY_CODES } from "@/constants/userAuthority.js";
// //mod 編集権限の適用 劉全航 end
// del #10359 編集権限の動作不正 dengshen end
// add 画面印刷プレビューと印刷の実現 陳 start
import { getCurrentFunctionCd } from "@/router/routing-helper";
import dayjs from "@/compat/date/dayjs";
// add 画面印刷プレビューと印刷の実現 陳 end
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
import { findExamSet } from "@/functions/exam-record/ExamRecordFunctions";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
import { sortableCompare } from "@/functions/SortFunctions";
import nameDuplicationImg from "../../assets/name_duplication.png";
import { getLatestHeaderElement, getHeaderHeight, getFooterMenuClientHeight, getGridFooterClientHeight, getScopedElementById, getScopedWindow, resolveRefElement } from "@/functions/common/LayoutMeasureHelper";
import { findKendoGridHeaderWrap, findKendoGridLockedHeader } from "@/compat/kendo/dom.js";
import {
  EXAM_RECORD_LOCKED_HEADER_FIELDS,
  isExamRecordLockedHeaderCell,
  syncMultiPatGridLockedHeaderLayout,
} from "@/components/multi-pat-list/kendoGridLockedHeaderLayout.js";
import { syncKendoGridLockedRowHeights } from "@/utils/kendoGridLockedSync.js";

function createDataSource(options) {
  return new kendo.data.DataSource(options || {});
}

function resolveGridRoot(gridOrRoot) {
  if (!gridOrRoot) {
    return null;
  }
  if (gridOrRoot.wrapper?.[0]) {
    return gridOrRoot.wrapper[0];
  }
  if (gridOrRoot.element?.[0]) {
    return gridOrRoot.element[0];
  }
  return gridOrRoot instanceof Element ? gridOrRoot : null;
}

function findKendoGridContent(gridOrRoot) {
  return resolveGridRoot(gridOrRoot)?.querySelector?.(".k-grid-content") || null;
}

function findKendoGridLockedContent(gridOrRoot) {
  return resolveGridRoot(gridOrRoot)?.querySelector?.(".k-grid-content-locked") || null;
}

function findKendoGridHeader(gridOrRoot) {
  return resolveGridRoot(gridOrRoot)?.querySelector?.(".k-grid-header") || null;
}

function findKendoGridBodyRows(gridOrRoot) {
  return Array.from(resolveGridRoot(gridOrRoot)?.querySelectorAll?.(".k-grid-content tbody tr") || []);
}

function findKendoGridLockedRows(gridOrRoot) {
  return Array.from(resolveGridRoot(gridOrRoot)?.querySelectorAll?.(".k-grid-content-locked tbody tr") || []);
}

function getKendoGridDataItem(grid, row) {
  if (!grid || !row) {
    return null;
  }
  return typeof grid.dataItem === "function" ? grid.dataItem($$(row)) : null;
}

function syncKendoGridLockedContentScroll(gridOrRoot) {
  const content = findKendoGridContent(gridOrRoot);
  const lockedContent = findKendoGridLockedContent(gridOrRoot);
  if (!content || !lockedContent) {
    return;
  }
  lockedContent.scrollTop = content.scrollTop;
  try {
    content.dispatchEvent(new Event("scroll", { bubbles: true }));
  } catch (_error) {
    $$(content).trigger("scroll");
  }
}

function attachTooltip(element, options) {
  const $element = $$(element);
  $element.kendoTooltip(options || {});
  return $element.data("kendoTooltip");
}

export default {
  props: {
    // NOTE: コンソールエラー対策
    historyKey: null
  },
  components: {
    "message-dialog": messageDialog
  },
  mixins: [NextTransitionMixin, PrintMixin],
  beforeRouteLeave(to, from, next) {
    if(to.fullPath.indexOf("exam-record") > -1){
      // 遷移先が検査結果系画面：初期化しない
    }else{
      // 遷移先が検査結果系画面以外：listを初期化
      this.storeReset();
    }
    next();
  },
  data() {
    return {
      sendOrdNo: null,
      debugmode: false,
      kendoGridToolbarHeight: 500,
      kendoGridHeight: 300,
      bulkImportFlg: false,
      androidFlg: false,
      iosFlg: false
      //同姓同名アイコン
      ,image_src_same: nameDuplicationImg
      // add FNSI-数値ソート、文字ソート、空後方で結合してソートする 江 start
      ,examDataSource: null
      ,examRecordGridColumns: null
      ,orderdir:null
      ,resultOrderdir:null
      ,resultField:null
      ,initExamDataSource:null
      // add FNSI-数値ソート、文字ソート、空後方で結合してソートする 江 end
      //mod 編集権限の適用 劉全航 start
      // del #10359 編集権限の動作不正 dengshen start
      // ,isAuthorized: null
      // del #10359 編集権限の動作不正 dengshen end
      //mod 編集権限の適用 劉全航 end
      ,isDialogVisible: false
      ,messageCd: null
      ,dialogType: null
      // 一括取込で取込み可能な最大ファイルサイズ(5MB = 1024x1024x5)
      ,maxFileSize: 5242880
      ,selfScreenName: ""
      ,currentSort: null
      ,scrollQuerySelector: ".k-grid-content"
      ,addClassTargetQuerySelector: [".k-grid-header-wrap table, .k-grid-content table"]
      ,examTooltipWidget: null
      ,directGridWidget: null
      ,directGridColumnSignature: ""
      ,directGridLayoutRafId: null
      // 検査項目が locked 側に入った後の表头修復が必要なとき true（右側のみの並べ替えでは修復しない）
      ,examRecordHeaderLayoutDirty: false
      ,isLoadingTriggered: false
    };
  },
  computed: {
    // add #11285 機能帳票の印刷情報対応② 高 start
    ...mapGetters("periodic-inspection", ["getStorSimlpSearchQurey"]),
    // add #11285 機能帳票の印刷情報対応② 高 end
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      sidebarWidth: "getSidebarWidth"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo",
      //add FNSI-検査結果一覧画面に最新の検査結果が表示されない 江 start
      getDefaultSetting: "getDefaultSetting",
      //add FNSI-検査結果一覧画面に最新の検査結果が表示されない 江 end
      getTheme: "getTheme",
      getPatientShareMode: "getPatientShareMode",
    }),
    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },
    ...mapGetters("user", ["getFacilityCd"]),
    // mod 機能帳票パラメータ確認 陳 start
    ...mapGetters("pat-info", [
      "searchedPatList",
      "selectedPatId",
      "getIsOtherFacility",
      "getOtherFacilityCd",
    ]),
    // mod 機能帳票パラメータ確認 陳 end
    ...mapGetters("exam-record/list", [
      "getComponentInitialized",
      "getCondition",
      "getExamRecordColumn",
      "getExamDataSource",
      "getExamSetNameList",
      "getExamDefaultSex",
      "getCheckResultForFacility",
      // add #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。linjunfeng start
      "getExamRouteFlg"
      // add #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。linjunfeng end
    ]),
    // del FNSI-数値ソート、文字ソート、空後方で結合してソートする 江 start
    // examDataSource() {
    //   // storeからデータを取得
    //   return createDataSource({
    //     data: this.getExamDataSource
    //   });
    // },
    // examRecordGridColumns() {
    //   return this.getExamRecordColumn;
    // }
    // del FNSI-数値ソート、文字ソート、空後方で結合してソートする 江 end
    //mod 編集権限の適用 劉全航 start
    isDisabled(){
      // mod #10053 破棄確認・保存活性(複数変更含む 編集権限)・削除対応_検査結果（↓） 20240117 ztc start
      // return this.bulkImportFlg;
      // mod #10359 編集権限の動作不正 dengshen start
      // return this.bulkImportFlg || !this.isAuthorized;
      return this.bulkImportFlg;
      // mod #10359 編集権限の動作不正 dengshen end
      // mod #10053 破棄確認・保存活性(複数変更含む 編集権限)・削除対応_検査結果（↓） 20240117 ztc end
    },
    //mod 編集権限の適用 劉全航 end
    /** フォントサイズを返却する処理 */
    fontSize() {
      const sizes = ["0.8", "1", "1.1", "1.3"];
      return sizes[Number(this.getFontSize)] || "1";
    },
    /** ホワイトモード判定処理 */
    isWhiteTheme() {
      return this.getTheme === 0;
    },
  },
  methods: {
    getExamRecordListGridRef() {
      return this.$refs.examrecordlistgrid || null;
    },
    getExamRecordListGridWidget() {
      return this.getExamRecordListGridRef()?.gridWidget?.() || this.getExamRecordListGridRef()?.kendoWidget?.() || this.directGridWidget || null;
    },
    getExamRecordGridRootEl() {
      return resolveRefElement(this, "examrecordlistgrid") || null;
    },
    buildDirectExamRecordColumns(columns = this.examRecordGridColumns || []) {
      return (columns || []).map(category => {
        const column = {
          ...category,
          columns: Array.isArray(category.columns) ? this.buildDirectExamRecordColumns(category.columns) : category.columns,
        };
        if (category.field === "pat_name") {
          column.template = '<i class="#: i_class #">#: pat_name # <img src="' + this.image_src_same + '" style="#: img_display #" class="pat-name-same-icon"></i>';
        } else if (category.field === "hosp_pat_id") {
          column.attributes = { ...(category.attributes || {}), class: [category.attributes?.class, "hosp-pat-id-body"].filter(Boolean).join(" ") };
        }
        return column;
      });
    },
    getDirectExamRecordColumnSignature(columns = this.examRecordGridColumns || []) {
      return (columns || []).map(category => [
        category.field || "",
        category.title || "",
        category.width || "",
        category.hidden ? 1 : 0,
        category.locked ? 1 : 0,
        category.lockable ? 1 : 0,
        Array.isArray(category.columns) ? this.getDirectExamRecordColumnSignature(category.columns) : ""
      ].join(":")) .join("|");
    },
    installDirectExamRecordGridFacade() {
      const root = this.getExamRecordGridRootEl();
      const grid = this.directGridWidget;
      if (!root || !grid) {
        return;
      }
      root.kendoWidget = () => grid;
      root.gridWidget = () => grid;
      root.gridRootEl = () => root;
      root.gridContentEl = () => findKendoGridContent(grid);
      root.gridLockedContentEl = () => findKendoGridLockedContent(grid);
      root.gridHeaderEl = () => findKendoGridHeader(grid);
      root.gridColumns = () => grid.columns || [];
      this.bindDirectExamRecordColumnReorderHandler(grid);
      this.disableExamRecordColumnReorderAutoScroll(grid);
    },
    bindDirectExamRecordColumnReorderHandler(grid) {
      if (!grid || grid.__examRecordColumnReorderBound) {
        return;
      }
      grid.bind("columnReorder", (event) => this.columnReorderHandler(event));
      grid.__examRecordColumnReorderBound = true;
    },
    /**
     * 列ドラッグ並べ替え時の自動スクロールを無効化する。
     * Kendo は列並べ替え用 Draggable に autoScroll:true を設定するが、
     * locked 列ありの場合 .k-grid-header-wrap が k-auto-scrollable 扱いとなり、
     * ヘッダ高さ(<50px)が自動スクロール判定域(AUTO_SCROLL_AREA)より小さいため、
     * ドラッグ中ずっと縦スクロール速度が加わり scrollable 側ヘッダだけが上下にずれる。
     * ヘッダは再描画のたびに _draggable で Draggable を作り直すため、メソッドを差し替えて維持する。
     */
    disableExamRecordColumnReorderAutoScroll(grid = this.directGridWidget) {
      if (!grid) {
        return;
      }
      const disable = () => {
        if (grid._draggableInstance?.options) {
          grid._draggableInstance.options.autoScroll = false;
        }
      };
      disable();
      if (grid.__examRecordAutoScrollPatched || typeof grid._draggable !== "function") {
        return;
      }
      const originalDraggable = grid._draggable;
      grid._draggable = function patchedExamRecordDraggable() {
        const result = originalDraggable.apply(this, arguments);
        if (this._draggableInstance?.options) {
          this._draggableInstance.options.autoScroll = false;
        }
        return result;
      };
      grid.__examRecordAutoScrollPatched = true;
    },
    hasGroupedExamColumnInLocked(grid = this.directGridWidget) {
      return (grid?.columns || []).some(column => (
        column?.locked === true
        && column?.hidden !== true
        && Array.isArray(column.columns)
        && column.columns.length > 0
        && String(column.field || "").startsWith("item_")
      ));
    },
    hasPatientColumnUnlocked(grid = this.directGridWidget) {
      return (grid?.columns || []).some(column => (
        column?.hidden !== true
        && column?.locked !== true
        && EXAM_RECORD_LOCKED_HEADER_FIELDS.includes(column.field)
      ));
    },
    shouldRepairExamRecordHeaderAfterReorder() {
      const grid = this.directGridWidget;
      if (!grid) {
        return false;
      }
      if (this.hasGroupedExamColumnInLocked(grid)) {
        this.examRecordHeaderLayoutDirty = true;
        return true;
      }
      if (this.hasPatientColumnUnlocked(grid)) {
        return true;
      }
      return this.examRecordHeaderLayoutDirty;
    },
    /**
     * 検査項目列を locked 側へドラッグした後、表头 inline 高さの累積と
     * locked/scrollable ヘッダのずれを修復する。
     */
    columnReorderHandler() {
      if (!this.shouldRepairExamRecordHeaderAfterReorder()) {
        return;
      }
      this.scheduleExamRecordPostColumnReorderLayout();
    },
    scheduleExamRecordPostColumnReorderLayout() {
      this.$nextTick(() => {
        requestAnimationFrame(() => {
          this.repairExamRecordLockedHeaderLayout();
        });
      });
    },
    repairExamRecordLockedHeaderLayout() {
      const root = this.getExamRecordGridRootEl();
      const grid = this.directGridWidget;
      if (!root || !grid) {
        return;
      }
      const headerWrap = findKendoGridHeaderWrap(root);
      const lockedHeader = findKendoGridLockedHeader(root);
      if (headerWrap && lockedHeader) {
        syncMultiPatGridLockedHeaderLayout(headerWrap, lockedHeader, {
          lockedHeaderCellFilter: isExamRecordLockedHeaderCell,
        });
        syncKendoGridLockedRowHeights(root, { skipHeader: true });
      }
      // 列並べ替え後は locked 内容域の高さだけ更新（grid.resize 二重実行は省略して表头の抖動を抑える）
      this.applyDirectExamRecordLockedHeightContract();
      if (!this.hasGroupedExamColumnInLocked(grid) && !this.hasPatientColumnUnlocked(grid)) {
        this.examRecordHeaderLayoutDirty = false;
      }
    },
    initDirectExamRecordGridIfReady() {
      const root = this.getExamRecordGridRootEl();
      if (!root || !this.examDataSource || !Array.isArray(this.examRecordGridColumns) || this.examRecordGridColumns.length === 0) {
        return;
      }
      const existingGrid = $$(root).data("kendoGrid");
      if (existingGrid) {
        this.directGridWidget = existingGrid;
        this.applyDirectExamRecordColumnsContract();
        this.applyDirectExamRecordDataSourceContract();
        this.installDirectExamRecordGridFacade();
        this.scheduleDirectExamRecordLayoutContract();
        return;
      }
      $$(root).kendoGrid({
        dataSource: this.examDataSource,
        columns: this.buildDirectExamRecordColumns(),
        editable: false,
        reorderable: true,
        resizable: true,
        sortable: { allowUnsort: true, showIndexes: true, compare: this.compareByField },
        selectable: "cell",
        height: this.kendoGridHeight,
        scrollable: true,
        change: event => this.onClick(event),
        dataBound: event => {
          this.applyDirectExamRecordStyleContract();
          this.setFontColor(event);
        },
        sort: event => this.sortHandler(event)
      });
      this.directGridWidget = $$(root).data("kendoGrid") || null;
      this.directGridColumnSignature = this.getDirectExamRecordColumnSignature();
      this.installDirectExamRecordGridFacade();
      this.scheduleDirectExamRecordLayoutContract();
    },
    destroyDirectExamRecordGrid() {
      this.examTooltipWidget?.destroy?.();
      this.examTooltipWidget = null;
      if (this.directGridLayoutRafId != null) {
        cancelAnimationFrame(this.directGridLayoutRafId);
        this.directGridLayoutRafId = null;
      }
      try {
        this.directGridWidget?.destroy?.();
      } catch (_error) {
        // noop
      }
      const root = this.getExamRecordGridRootEl();
      if (root) {
        $$(root).empty();
        delete root.kendoWidget;
        delete root.gridWidget;
      }
      this.directGridWidget = null;
      this.directGridColumnSignature = "";
      this.examRecordHeaderLayoutDirty = false;
    },
    refreshDirectExamGrid() {
      this.initDirectExamRecordGridIfReady();
    },
    applyDirectExamRecordColumnsContract() {
      const grid = this.directGridWidget;
      if (!grid) {
        return;
      }
      const nextSignature = this.getDirectExamRecordColumnSignature();
      if (this.directGridColumnSignature !== nextSignature) {
        grid.setOptions({ columns: this.buildDirectExamRecordColumns() });
        this.directGridColumnSignature = nextSignature;
      }
    },
    applyDirectExamRecordDataSourceContract() {
      const grid = this.directGridWidget;
      if (!grid || !this.examDataSource) {
        return;
      }
      if (grid.dataSource !== this.examDataSource) {
        grid.setDataSource(this.examDataSource);
      } else {
        grid.refresh?.();
      }
    },
    applyDirectExamRecordStyleContract() {
      const root = this.getExamRecordGridRootEl();
      if (!root) {
        return;
      }
      root.classList.add("ntss-kendo-grid-legacy", "k-widget", "k-grid", "k-display-block", "exam-record-list");
      root.querySelectorAll(".k-grid-header th, .k-grid-header .k-table-th").forEach(th => th.classList.add("k-header"));
      [".k-grid-content tbody", ".k-grid-content-locked tbody"].forEach(selector => {
        root.querySelectorAll(selector).forEach(tbody => {
          Array.from(tbody.children || []).forEach((tr, index) => {
            tr.classList.add("k-master-row");
            tr.classList.toggle("k-alt", index % 2 === 1);
          });
        });
      });
      root.querySelectorAll(".k-grid-content tbody td, .k-grid-content-locked tbody td").forEach(td => td.classList.add("k-td", "k-table-td"));
      this.applyDirectExamRecordLockedHeightContract();
    },
    applyDirectExamRecordLockedHeightContract() {
      const root = this.getExamRecordGridRootEl();
      const lockedPane = findKendoGridLockedContent(root);
      const header = findKendoGridHeader(root);
      const content = findKendoGridContent(root);
      if (!lockedPane || !header || !content) {
        return;
      }
      let height = this.kendoGridHeight - (header.offsetHeight + 2);
      if (!this.androidFlg && !this.iosFlg && content.scrollWidth > content.clientWidth) {
        height -= 17;
      }
      if (height > 0) {
        lockedPane.style.height = `${height}px`;
      }
      syncKendoGridLockedContentScroll(root);
    },
    scheduleDirectExamRecordLayoutContract() {
      if (this.directGridLayoutRafId != null) {
        cancelAnimationFrame(this.directGridLayoutRafId);
      }
      this.directGridLayoutRafId = requestAnimationFrame(() => {
        this.directGridWidget?.setOptions?.({ height: this.kendoGridHeight });
        this.directGridWidget?.resize?.(true);
        this.applyDirectExamRecordStyleContract();
        this.directGridLayoutRafId = requestAnimationFrame(() => {
          this.directGridLayoutRafId = null;
          this.directGridWidget?.resize?.(true);
          this.applyDirectExamRecordStyleContract();
        });
      });
    },
    ...mapActions("exam-record/list", [
      "setListComponentInitialized",
      "resetExamRecordGridColumn",
      "setExamRecordColumn",
      "setExamSetNameList",
      "resetExamDataSource",
      "storeReset",
      "setExamSelectData",
      "examSelectDefaultSex",
      "patIdJudgSetting"
    ]),
    ...mapActions("pat-info", ["selectPat"]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    ...mapActions("master-maintenance",["findRecordListByFacilityCd"]),
    // add #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。linjunfeng start
    ...mapMutations("exam-record/list", ["setExamRouteFlg"]),
    // add #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。linjunfeng end
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

      const field = this.currentSort.field;
      const isDesc = this.currentSort.dir === "desc";
      
      // 共通ソート関数に渡すオプション設定
      // - sortable.compareのコールバック関数でsortableCompareを呼ぶ場合、常に空欄を後方にするために降順の場合はisDescをtrueで渡して空欄判定結果を反転する必要あり
      const nullOrderRule = { [field]: "last", isDesc: isDesc}; // 空欄位置の制御
      const orderAsNumberFields = !["hosp_pat_id", "pat_name", "viewTreatDate"].includes(field) ? [ field ] : []; // 検査結果 数値化できるものは数値でソート
      const options = { nullOrderRule, orderAsNumberFields };
      
      return sortableCompare(a, b, field, true, options);
    },
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    // add #7035-検査結果の値がない項目も画面に表示される（exam_rst連携で受信した検査結果（空値）の項目） 徐博 start
    replaceObjData(obj, val, replace) {
      if (typeof obj === "object") {
        if (Array.isArray(obj)) {
          for (let i = 0; i < obj.length; i++) {
            obj[i] = this.replaceObjData(obj[i], val, replace);
          }
        } else {
          for (let key in obj) {
            obj[key] = this.replaceObjData(obj[key], val, replace);
          }
        }
        return obj
      } else {
        return obj === val ? replace : obj;
      }
    },
	  // add #7035-検査結果の値がない項目も画面に表示される（exam_rst連携で受信した検査結果（空値）の項目） 徐博 end
    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      const wh = this.windowHeight;
      const hh = getHeaderHeight(getLatestHeaderElement(this.$el || document), 0);
      const fmh =
        (this.isDispMenu === 1
          ? getFooterMenuClientHeight(this.$el || null)
          : 0) + 5;
      this.kendoGridToolbarHeight = wh - hh - fmh - 3;
      this.kendoGridToolbarHeight =
        this.kendoGridToolbarHeight < 340 ? 340 : this.kendoGridToolbarHeight;

      let gfhPx = getGridFooterClientHeight(this.$el || null) || 40;
      this.kendoGridHeight = this.kendoGridToolbarHeight - gfhPx;
      this.scheduleDirectExamRecordLayoutContract?.();
    },
    // add ##11152 検査結果(個別)で機能帳票のパラメータに「検査セット」を追加 limingzhe start
    getselectedExamSetName(examSetCd){
      var name = "";
      if (examSetCd != -1) {
        this.getExamSetNameList.forEach(everySet => {
          if (everySet.examSetCd == examSetCd) {
            name = everySet.examSetName;
          }
        });
      }
      return name;
    },
    // add ##11152 検査結果(個別)で機能帳票のパラメータに「検査セット」を追加 limingzhe end
     // add 画面印刷プレビューと印刷の実現 陳 start
     requestrReportParams(param) {
      // 機能コード判定
      if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {
        // add #11285 機能帳票の印刷情報対応② 高 start
        var expressCondCd="";
        if (null != this.getStorSimlpSearchQurey.rstDialysisState && this.getStorSimlpSearchQurey.rstDialysisState.length > 0) {
          if (this.getStorSimlpSearchQurey.rstDialysisState.length == 2) {
            expressCondCd = "予定・実績";
          } else {
            if (this.getStorSimlpSearchQurey.rstDialysisState[0] == 1) {
              expressCondCd = "予定";
            } else {
              expressCondCd = "実績";
            }
          }
        }
        let kurNames = null;
        if(this.getStorSimlpSearchQurey.kurNames && this.getStorSimlpSearchQurey.kurNames.length > 0) {
          kurNames = this.getStorSimlpSearchQurey.kurNames.join("・");
        } else {
          kurNames = "すべて";
        }
        let patGroups = null;
        if(this.getStorSimlpSearchQurey.selectedPatGroupNames) {
          patGroups = this.getStorSimlpSearchQurey.selectedPatGroupNames;
        } else {
          patGroups = "すべて";
        }
        // add #11285 機能帳票の印刷情報対応② 高 end
        // 機能一致
        //mod #9558 patIds が選択中患者しか渡されない 杜 start
        // var patFalg;
        // if (this.selectedPatId === null){
        //   patFalg = this.searchedPatList.map(({ pat_id }) => pat_id);
        // } else{
        //   patFalg = null;
        // }
        var patFalg = this.searchedPatList.map(({ pat_id }) => pat_id);
        //mod #9558 patIds が選択中患者しか渡されない 杜 end
        // 印刷パラメータを応答
        const condition = this.getCondition;
        const params = {
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
          //mod #9558 patIds が選択中患者しか渡されない 杜 start
          //patId: this.selectedPatId,
          // patId: null,
          //mod #9558 patIds が選択中患者しか渡されない 杜 end
          patIds: patFalg,
          facilityCd: this.getFacilityCd,
          // date: dayjs(condition.examDateSt).format("YYYY/MM/DD"),
          // fromDate: dayjs(condition.examDateSt).format("YYYY/MM/DD"),
          // toDate: dayjs(condition.examDateEd).format("YYYY/MM/DD"),
          date: condition.examDateSt != null ? dayjs(condition.examDateSt).format("YYYYMMDD") : (condition.examDateEd != null ? dayjs(condition.examDateEd).format("YYYYMMDD") : dayjs(new Date()).format("YYYYMMDD")),
          fromDate: condition.examDateSt != null ? dayjs(condition.examDateSt).format("YYYYMMDD") : (condition.examDateEd != null ? dayjs(condition.examDateEd).format("YYYYMMDD") : dayjs(new Date()).format("YYYYMMDD")),
          toDate: condition.examDateEd != null ? dayjs(condition.examDateEd).format("YYYYMMDD") : (condition.examDateSt != null ? dayjs(condition.examDateSt).format("YYYYMMDD") : dayjs(new Date()).format("YYYYMMDD")),
          // mod #11679 複数患者帳票で「透析条件.補液量」が出ない 20250527 limingzhe start
          //dialysisDate: dayjs(new Date()).format("YYYYMMDD"),
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
          //dialysisDate: condition.examDateSt != null ? dayjs(condition.examDateSt).format("YYYYMMDD") : (condition.examDateEd != null ? dayjs(condition.examDateEd).format("YYYYMMDD") : dayjs(new Date()).format("YYYYMMDD")),
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
          // mod #11679 複数患者帳票で「透析条件.補液量」が出ない 20250527 limingzhe end
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
          //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
          functionCd:"01801",
          //add 5984 機能帳票でパラメータが正しく渡されていない 吉 end
          // add ##11152 検査結果(個別)で機能帳票のパラメータに「検査セット」を追加 limingzhe start
          selectExamSetCd: condition.examSetCd,
          selectedExamSetName: this.getselectedExamSetName(condition.examSetCd),
          // add ##11152 検査結果(個別)で機能帳票のパラメータに「検査セット」を追加 limingzhe end
          // add #11285 機能帳票の印刷情報対応② 高 start
          treatDate:this.getStorSimlpSearchQurey.treatDate,
          bedCdListString:this.getStorSimlpSearchQurey.selectedBedGName,
          freeWord:this.getStorSimlpSearchQurey.freeWord,
          expressCondCdStr:expressCondCd,
          kurNames:kurNames,
          patGroups:patGroups,
          // add #11285 機能帳票の印刷情報対応② 高 end
        };
        EventBus.$emit("sendReportParams", params);
      }
    },
     // add 画面印刷プレビューと印刷の実現 陳 end
    setHeaderStyle() {
      // ヘッダーにスタイル適用
      resolveRefElement(this, "examrecordlistgrid")?.firstElementChild?.classList?.add(
        "master-grid-header");
    },
    // 抽出条件変更イベント
    setFilterCondition(chgflg) {
      // 検査日が変更された場合
      if (chgflg) {
        // 検査結果取得
        this.dataLoad();
      } else {
        this.filteredExamRecord();
      }
    },
    // データ更新
    setExamRecord() {
      this.dataLoad();
    },
    async dataLoad() {
      if (this.selfScreenName !== this.$route.name) {
        return;
      }
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      await this.setExamSelectData({
        facilityCd: this.getFacilityCd,
        patIdList: deepCopy(this.searchedPatList),
        patientShareMode:
          this.getIsOtherFacility === false ||
          (this.getOtherFacilityCd !== null &&
            this.getOtherFacilityCd !== this.getFacilityCd)
            ? 1
            : this.getPatientShareMode,
        selectedPatId: this.selectedPatId,
      });
      // 共通ローダー:表示終了
      this.setLoadingScreenVisible(false);

      // 検索条件で表示内容を更新
      this.filteredExamRecord();
      // add FNSI-数値ソート、文字ソート、空後方で結合してソートする 江 start
      //del 10389 患者リストのソートが遅い gjn start
      // let ExamDataSourceForNoKana = this.getExamDataSource.filter(e => e.pat_last_name_kana === null && e.pat_first_name_kana === null);
      // let ExamDataSourceForKana = this.getExamDataSource.filter(e => e.pat_last_name_kana != null || e.pat_first_name_kana != null);
      //
      // let ExamDataSourceForSortKana = orderBy(ExamDataSourceForKana, [{ field: "viewTreatDate", dir: "desc" }]);
      // this.initExamDataSource = orderBy(ExamDataSourceForSortKana,[{ field: "pat_full_name", dir: "asc" }]);
      // // add #7035-検査結果の値がない項目も画面に表示される（exam_rst連携で受信した検査結果（空値）の項目） 徐博 start
      // this.initExamDataSource = this.replaceObjData(this.initExamDataSource, "NaN", "")
      // // add #7035-検査結果の値がない項目も画面に表示される（exam_rst連携で受信した検査結果（空値）の項目） 徐博 end
      // let ExamDataSourceForSortNoKana = orderBy(ExamDataSourceForNoKana, [{ field: "viewTreatDate", dir: "desc" }]);
      // orderBy(ExamDataSourceForSortNoKana,[{ field: "pat_name", dir: "asc" }]).forEach(element => {
      //     this.initExamDataSource.push(element);
      // });
      this.examDataSource = createDataSource({
        data:this.getExamDataSource,
        sort: this.currentSort ? this.currentSort : null // ソート条件保持
      });
      //del 10389 患者リストのソートが遅い gjn end
      this.examRecordGridColumns = this.getExamRecordColumn;
      // add FNSI-数値ソート、文字ソート、空後方で結合してソートする 江 end
      //mod検査結果一覧ページで単位を追加する 劉全航 start
      await this.addUnit();
      //mod検査結果一覧ページで単位を追加する 劉全航 end
      this.$nextTick(() => this.refreshDirectExamGrid());
    },
    /**
     * 検査結果の正常範囲外の色指定
     * - 現在の画面上の列の並び順を取得して色指定する
     * @param {*} e 
     */
    setFontColor(e){
      //文字色制御
      
      const lockedRows = findKendoGridLockedRows(e.sender);
      const scrollableRows = findKendoGridBodyRows(e.sender);
      if (lockedRows.length === 0 && scrollableRows.length === 0) return;
      
      // 表示中の列の順に field を取得
      const lockedFields = ["hosp_pat_id", "pat_name", "viewTreatDate"]; // デフォルトは固定列だが列移動可能
      const fieldOrderLocked = []; // 固定列 現在の画面並び順通りにfield格納
      const fieldOrderScrollable = []; // スクロール列 現在の画面並び順通りにfield格納
      
      // theadから現在の画面並び順でfieldを取得する関数
      const processThead = (thead) => {
        const rows = Array.from(thead?.querySelectorAll?.("tr") || []);
        const ths1 = Array.from(rows[0]?.querySelectorAll?.("th") || []);
        const ths2 = Array.from(rows[1]?.querySelectorAll?.("th") || []);
        
        // 固定列はrowspan="2"でセル結合されている
        // - 1行目のfieldが固定列の場合 -> 無条件でresultに追加
        // - 1行目のfieldが可変列の場合 -> 2行目から対象のfield群（透析前/透析後/その他）を検索してresultに追加
        const result = [];
        ths1.forEach((th) => {
          const field = th?.getAttribute?.("data-field");
          if (!field) return;
      
          if (lockedFields.includes(field)) {
            result.push(field);
          } else if (field.startsWith("item_")) {
            const matches = ths2.filter(th2 => {
              const f = th2?.getAttribute?.("data-field");
              return f?.startsWith(field + "_order");
            });
            matches.forEach(th2 => result.push(th2?.getAttribute?.("data-field")));
          }
        });
        
        return result;
      };
            
      // thead[0] = 固定列, thead[1] = スクロール列
      const gridRoot = this.$refs.examrecordlistgrid?.gridRootEl?.() || resolveRefElement(this, "examrecordlistgrid") || null;
      const theads = Array.from(gridRoot?.querySelectorAll?.("thead") || []);
      if (theads.length > 0) {
        fieldOrderLocked.push(...processThead(theads[0]));
      }
      if (theads.length > 1) {
        fieldOrderScrollable.push(...processThead(theads[1]));
      }
      
      // 行ごとのセルに正常範囲外のスタイルを適用する関数
      const applyCellStyles = (rows, fieldOrder, hiddenCount) => {
        rows.forEach((row) => {
          const dataItem = getKendoGridDataItem(e.sender, row);
          // 非表示列はfieldOrderに含まれていないためカウンタ値を調整
          for (let i = hiddenCount; i < row.cells.length; i++) {
            const field = fieldOrder[i - hiddenCount];
            const classValue = dataItem?.[field + "_class"];
            const cell = row.cells[i];
      
            if (classValue === "H") {
              cell.style.color = "var(--kendo-grid-style-high-class-color)";
            } else if (classValue === "L") {
              cell.style.color = "var(--kendo-grid-style-low-class-color)";
            }
          }
        });
      };
      // 固定列、可変列にスタイル適用
      
      applyCellStyles(lockedRows, fieldOrderLocked, 0);
      applyCellStyles(scrollableRows, fieldOrderScrollable, 3); // 3は非表示(hidden = true)の列数、非表示列は処理スキップ
      
      // 高さの調整処理もdata-boundに連動して実施(kendo-gridのlockedオプション使用時に高さがずれる件の対応)
      this.$nextTick(() => {
        const gridRoot = resolveRefElement(this, "examrecordlistgrid");
        const lockedPane = findKendoGridLockedContent(gridRoot);
        const header = findKendoGridHeader(gridRoot);
        const scrolObj = findKendoGridContent(gridRoot);
        if (!lockedPane || !header || !scrolObj) {
          return;
        }
        let headerHeight = header.offsetHeight + 2;
        let lockRowHeight = this.kendoGridHeight - headerHeight;
        if (!this.androidFlg && !this.iosFlg && (scrolObj.scrollWidth > scrolObj.clientWidth)) {
          lockRowHeight -= 17;
        }
        lockedPane.style.height = lockRowHeight + "px";
      });
      syncKendoGridLockedContentScroll(gridRoot, { touch: true });
      
      // ツールチップ初期化
      this.initializeGridTooltip();
    },
    /** ツールチップ初期化 */
    initializeGridTooltip() {
      this.$nextTick(() => {
        const gridElement = resolveRefElement(this, "examrecordlistgrid");
        if (!gridElement) return;
        this.examTooltipWidget?.destroy?.();
        const grid = this.$refs.examrecordlistgrid?.kendoWidget?.();
        if (!grid) {
          return;
        }

        const getFieldByIndex = (colIndex) => {
          const adjustedIndex = colIndex + 3;
          const flatColumns = grid.columns.flatMap((col) => (col.columns?.length ? col.columns : [col]));
          return adjustedIndex >= 0 ? flatColumns[adjustedIndex]?.field : null;
        };

        const gridContent = findKendoGridContent(gridElement);
        gridContent?.querySelectorAll('td').forEach((element) => {
          element.removeAttribute('data-has-tooltip');
          const field = getFieldByIndex(element.cellIndex);
          if (!field) return;
          const dataItem = getKendoGridDataItem(grid, element.closest('tr'));
          if (dataItem?.[field] && dataItem[`${field}_date`]) {
            element.setAttribute('data-has-tooltip', 'true');
          }
        });

        const tooltip = attachTooltip(gridElement, {
          filter: ".k-grid-content td[data-has-tooltip='true']",
          showAfter: 200,
          position: 'top',
          content: ({ target }) => {
            let getIndex = target.cellIndex ?target.cellIndex:target[0].cellIndex?target[0].cellIndex:null
            const field = getFieldByIndex(getIndex);
            const dataItem = getKendoGridDataItem(grid, target.closest('tr'));
            return `検査日: ${this.formatExamDate(dataItem?.[`${field}_date`])}`;
          }
        });
        tooltip?.bind('show', (e) => {
          const left = e.sender.popup.wrapper[0].style.left;
          const result = parseFloat(left) - 32;
          e.sender.popup.wrapper[0].style.left = result + 'px';
        });
        tooltip?.bind('show', ({ tooltip: tooltipEl }) => {
          if (!tooltipEl) {
            return;
          }
          Object.assign(tooltipEl.style, {
            textAlign: 'center',
            backgroundColor: 'var(--kendo-input-color)',
            color: 'var(--kendo-input-background-color)',
            fontSize: `${this.fontSize * 1.5}em`,
            width: '13em',
            borderRadius: '8px',
            boxShadow: '0 4px 8px rgba(0,0,0,0.2)',
            padding: '6px 8px'
          });
        });
        this.examTooltipWidget = tooltip;
      });
    },
    /** YYYYMMddhhmmss -> YYYY/MM/dd hh:mm に変換 */
    formatExamDate(dateStr) {
      if (!dateStr || dateStr.length < 12) return "";
      const y = dateStr.slice(0, 4);
      const m = dateStr.slice(4, 6);
      const d = dateStr.slice(6, 8);
      const hh = dateStr.slice(8, 10);
      const mm = dateStr.slice(10, 12);
      return `${y}/${m}/${d} ${hh}:${mm}`;
    },
    // 検索条件が変更されたら表示内容を更新
    filteredExamRecord() {
      // 治療日列の表示/非表示
      let colsetting = this.getExamRecordColumn;
      if (!Array.isArray(colsetting) || colsetting.length < 6) {
        return;
      }
      colsetting[1].hidden = !this.getCondition.viewPatId;
      colsetting[5].hidden = !this.getCondition.viewExamDate;

      // 検査セットの表示/非表示
      const examSet = findExamSet(this.getCondition.examSetCd, this.getExamSetNameList);
      if (!examSet) {
        for (let i = 6; i < colsetting.length; i++) {
          colsetting[i].hidden = false;
        }
      } else {
        const itemNoList = JSON.parse(examSet.examItemInfo);

          for (let col = 6; col < colsetting.length; col++) {
            colsetting[col].hidden = true;
            for (let itemkey = 0; itemkey < itemNoList.length; itemkey++) {
              if ("item_"+ itemNoList[itemkey].exam_item_cd === colsetting[col].field) {
                colsetting[col].hidden = false;
              }
            }
          }
        }
      this.setExamRecordColumn(colsetting);
      // 列表示のみ変更時は store と local が同一参照のため hidden は既に反映済み。Grid 再描画のみ行う。
      if (Array.isArray(this.examRecordGridColumns) && this.examRecordGridColumns.length > 0) {
        this.$nextTick(() => this.refreshDirectExamGrid());
      }
    },
    // グリッドクリック時
    onClick(event) {
      if (event.sender) {
        // 選択行取得
        const examRecordGrid = this.getExamRecordListGridWidget();
        const selrow = examRecordGrid?.select?.().closest("tr");
        const patId = examRecordGrid?.dataItem?.(selrow)?.pat_id;
        this.selectPat(patId).then(() => {
          // 検査結果画面へ遷移
          this.goSpecifiedView("exam-record-detail");
        });
      }
    },
    // 検査結果ファイル取り込み処理
    fileCapture(){
      const fileDialogBtn = getScopedElementById("upload_text", this.$el || this);
      fileDialogBtn.value="";
      fileDialogBtn.click();
    },
    //mod検査結果一覧ページで単位を追加する 劉全航 start
    async addUnit(){
    var response = await ApiHelper.get(`/exam/examRecord/examItem/${this.getFacilityCd}`, { selectedPatId: this.selectedPatId });
    response.data.forEach(obj=>{
      let unit = obj.unit;
      let examItemName = obj.examItemName;
      if(examItemName !== null & unit !== null & unit !== ''){
        this.examRecordGridColumns.forEach((object)=>{
              if(object.title === examItemName){
                object.title += ` [${unit}]`;
                return;
              }
          });
        }
    });

    },
    triggerLoad() {
      if (this.isLoadingTriggered) return;
      this.isLoadingTriggered = true;

      this.setLoadingScreenMessage("処理中・・・");
      this.dataLoad();

      this.$nextTick(() => {
        this.isLoadingTriggered = false;
      });
    },
    //mod検査結果一覧ページで単位を追加する 劉全航 end
    fileChange(e){
      const file = e.target.files[0]
      if (!file) { return false }
      // ファイルサイズチェック
      if (file.size > this.maxFileSize) {
        // ファイルサイズオーバー
        this.messageCd = 72000004;
        this.dialogType = "1";
        this.isDialogVisible = true;
        return;
      }
      const reader = new FileReader();
      let workers = [];
      const checkResultForFacility = this.getCheckResultForFacility;

      //ファイル分割処理
      const loadFunc = async () => {
        //共通ローダー：表示開始
        // del FNSI-終了およびその結果を通知機能で教える 江 start
        // this.setLoadingScreenMessage("ファイル取り込み中");
        // del FNSI-終了およびその結果を通知機能で教える 江 end
        this.setLoadingScreenVisible(true);
        // ファイルスキップ件数(レコード長でのチェックエラー)
        var cntSkip = 0;

        const lines = reader.result.split("\n");
        //1行ファイル取込
        await lines.forEach(element => {
          if (element.length < 258 && element.length > 1) {
            const worker = {
              recordKbn:element.substr(0,2),
              centerCd: element.substr(2,6),
              examDate:element.substr(8,8),
              examTime:element.substr(16,4),
              orderClass:element.substr(20,1),
              reserve1:element.substr(21,7),
              recieverKey:element.substr(28,20),
              hospPatId:element.substr(48,12),
              reserve2:element.substr(60,8),
              reportCd:element.substr(68,1),
              kentaiNyubi:element.substr(69,3),
              kentaiYoketu:element.substr(72,3),
              kentaiBilirubin:element.substr(75,3),
              examItemCd1:element.substr(78,10),
              examReserve1:element.substr(88,7),
              examResult1:btoa(element.substr(95,8)),
              examCheck1:element.substr(103,1),
              examComment1_1:btoa(element.substr(104,3)),
              examComment2_1:btoa(element.substr(107,3)),
              examItemCd2:element.substr(110,10),
              examReserve2:element.substr(120,7),
              examResult2:btoa(element.substr(127,8)),
              examCheck2:element.substr(135,1),
              examComment1_2:btoa(element.substr(136,3)),
              examComment2_2:btoa(element.substr(139,3)),
              examItemCd3:element.substr(142,10),
              examReserve3:element.substr(152,7),
              examResult3:btoa(element.substr(159,8)),
              examCheck3:element.substr(167,1),
              examComment1_3:btoa(element.substr(168,3)),
              examComment2_3:btoa(element.substr(171,3)),
              examItemCd4:element.substr(174,10),
              examReserve4:element.substr(184,7),
              examResult4:btoa(element.substr(191,8)),
              examCheck4:element.substr(199,1),
              examComment1_4:btoa(element.substr(200,3)),
              examComment2_4:btoa(element.substr(203,3)),
              examItemCd5:element.substr(206,10),
              examReserve5:element.substr(216,7),
              examResult5:btoa(element.substr(223,8)),
              examCheck5:element.substr(231,1),
              examComment1_5:btoa(element.substr(232,3)),
              examComment2_5:btoa(element.substr(235,3)),
              space:element.substr(238,18)
            };
            workers.push(worker);
          }
        });
        if (workers.length > 0) {
          //共通ローダー：表示終了
          this.setLoadingScreenVisible(false);
          // 施設設定の検査結果ファイル取込時患者ID判定設定が「1」の場合、患者番号の重複チェックを行う
          const duplicateFlg = await this.duplicateCheck(workers, checkResultForFacility);
          if (duplicateFlg) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "登録失敗",
              // message: "患者の番号は重複しています"
              title: DIALOG_MESSAGES['00200019'].title,
              message: messageFormat(DIALOG_MESSAGES['00200019'].message),
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            });
            return;
          }
          // 下記メッセージを表示して、コントロールを戻す。完了は通知にて行う。
          this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "取り込み開始",
            // message: "検査結果のファイル取り込みを開始しました。取り込みが完了しましたら、通知にて結果をお知らせいたします。"
            title: DIALOG_MESSAGES['00100006'].title,
            message: messageFormat(DIALOG_MESSAGES['00100006'].message),
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          });
          // データ登録APIをリクエスト
          ApiHelper.put("/exam/examRecord/fileCapture", workers)
            .then(response => {
              // del FNSI-終了およびその結果を通知機能で教える 江 start
              // // 画面再読込
              // this.dataLoad();
              // del FNSI-終了およびその結果を通知機能で教える 江 end

              const updateResponse = response.data;
              // add FNSI-終了およびその結果を通知機能で教える 江 start
              if(response.data == "患者の番号は重複しています"){
                this.$ons.notification.alert({
                  // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                  // title: "登録失敗",
                  // message: "患者の番号は重複しています"
                  title: DIALOG_MESSAGES['00200019'].title,
                  message: messageFormat(DIALOG_MESSAGES['00200019'].message),
                  // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
                });
                return;
              }
              // add FNSI-終了およびその結果を通知機能で教える 江 end
              const arrResult = updateResponse.split(",");
              // add FNSI-終了およびその結果を通知機能で教える 江 start
              this.registration(arrResult[0],parseInt(cntSkip) + parseInt(arrResult[1]))
                .catch(error => {
                  //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
                  getErrorMessage('ExamRecordComponent.vue', 'fileChange', error);
                  //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
                  throw error;
                });
              // add FNSI-終了およびその結果を通知機能で教える 江 end
              // del FNSI-終了およびその結果を通知機能で教える 江 start
              //共通ローダー：表示終了
              // this.setLoadingScreenVisible(false);
              // this.$ons.notification.alert({
              //   title: "登録完了",
              //   message: "成功件数:" + arrResult[0] + "件</br>失敗件数:" + (parseInt(cntSkip) + parseInt(arrResult[1])) + "件"
              // });
              // del FNSI-終了およびその結果を通知機能で教える 江 end
            })
            .catch(error => {
              //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
              getErrorMessage('ExamRecordComponent.vue', 'fileChange', error);
              //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
              // add FNSI-終了およびその結果を通知機能で教える 江 start
              // console.log(error);
              // ファイル取り込み処理失敗の場合
              this.registration(0, 0)
                .catch(error => {
                  //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
                  getErrorMessage('ExamRecordComponent.vue', 'fileChange', error);
                  //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
                  throw error;
                });
              // add FNSI-終了およびその結果を通知機能で教える 江 end
              // del FNSI-終了およびその結果を通知機能で教える 江 start
              // //共通ローダー：表示終了
              // this.setLoadingScreenVisible(false);
              // this.$ons.notification.alert({
              //   title: "ファイル取り込み処理失敗",
              //   message: error.response.data
              // });
              // del FNSI-終了およびその結果を通知機能で教える 江 end
            });
        } else {
          // 共通ローダー：表示終了
          this.setLoadingScreenVisible(false);
          // 登録対象のデータ件数が0件の場合
          this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "登録失敗",
            // message: "登録対象となるデータが1件もありません。"
            title: DIALOG_MESSAGES['00200020'].title,
            message: messageFormat(DIALOG_MESSAGES['00200020'].message),
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          });
        }
      }
      reader.onload = loadFunc;
      reader.readAsBinaryString(file);
    }
    // 検査結果ファイル取込時患者ID判定設定が「1:12桁前方ゼロ詰め」だった場合のチェック
    ,async duplicateCheck(workers, checkResultForFacility) {
      let rtn = false;
      if (checkResultForFacility == 1) {
        let hashSet = [];
        for (const item of workers) {
          const hospPatId = item.hospPatId.replaceAll(/^[ {2}]+/g, '');
          // スペース埋めされていないhospPatIdを格納
          if(hospPatId.length != 12 && hospPatId.substring(0,1) == "0"){
            continue;
          }else if (!isNaN(hospPatId)){
            hashSet.push(parseInt(hospPatId));
          }
        }
        for (const item of workers) {
          const hospPatId = item.hospPatId.replaceAll(/^[ {2}]+/g, '');
          if(hospPatId.length != 12 && hospPatId.substring(0,1) == "0" && !isNaN(hospPatId)){
            // スペース埋めされているhospPatIdと重複している場合は true を応答する
            if(hashSet.indexOf(parseInt(hospPatId)) > -1){
              rtn = true;
            }
          }
        }
      }
      return rtn;
    }
    // add FNSI-終了およびその結果を通知機能で教える 江 start
    /**
     * 通知登録実行
     */
    ,async registration(successfulConut,failedCount) {
      // 通知登録APIをリクエスト
      ApiHelper.put(`/exam/examRecord/fileCapture/${this.getFacilityCd}/${successfulConut}/${failedCount}`)
      .catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('ExamRecordComponent.vue', 'registration', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });
    },
    // add FNSI-終了およびその結果を通知機能で教える 江 end
    startInitialize() {
      this.setListComponentInitialized(false);
    },
    finishInitialize() {
      this.setListComponentInitialized(true);
      if (this.getComponentInitialized) {
        // すでにExamRecordHeaderComponentの初期化も完了している場合は検索を実行する
        this.dataLoad();
      }
    },
  },
  watch: {
    windowHeight() {
      // iosPWA時の画面幅変更時:
      // app.vueのhandleResizeWindow実行後にcalculateGridHeightを実行するため、200ミリ秒待つ
      const ownerWindow = this.$el?.ownerDocument?.defaultView || window;
      if(this.iosFlg && ownerWindow.matchMedia('(display-mode: standalone)').matches){
        ownerWindow.setTimeout(() => {
          this.calculateGridHeight();
        }, 200);
      }else{
        this.calculateGridHeight();
      }
    },
    isDispMenu() {
      this.calculateGridHeight();
    },
    getFontSize() {
      // 印刷中はスキップ
      if (this.isPrint) return;

      this.calculateGridHeight();
    },
    sidebarWidth(){
      $$(getScopedWindow(this.$el || this)).trigger('resize');
    },
    searchedPatList(){
      this.dataLoad();
    },
    getPatientShareMode() {
      this.triggerLoad();
    },
    getOtherFacilityCd() {
      this.triggerLoad();
    }
  },
  created() {
    this.startInitialize();
    // 画面名称取得
    this.selfScreenName = this.$route.name;
    // add 画面印刷プレビューと印刷の実現 陳 start
    // 印刷パラメータ要求
    // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
    EventBus.$off("requestReportParams", this.requestrReportParams);
    // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
    EventBus.$on("requestReportParams", this.requestrReportParams);
    // add 画面印刷プレビューと印刷の実現 陳 end
    EventBus.$on("filterExamRecord", this.setFilterCondition);
    EventBus.$on("dataUpdate", this.setExamRecord);
    //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 start
    // 遷移先が検査結果系画面以外：listを初期化
    this.storeReset();
    //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 end
    // 端末判別
    const ua = getScopedWindow(this.$el || this)?.navigator?.userAgent || "";
    if (ua.match(/Android/)) {
      this.androidFlg = true;
    } else if (ua.match(/iPhone/)) {
      this.iosFlg = true;
    }else if(ua.match(/iPad/)){
      this.iosFlg = true;
    }

    if(ua.indexOf('Safari') > -1 && ua.indexOf('Chrome') === -1){
      this.iosFlg = true;
    }
    if(this.androidFlg || this.iosFlg){
      this.bulkImportFlg = true;
    }

    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    // 一覧ヘッダ名をセット
    this.resetExamRecordGridColumn();
    this.resetExamDataSource();
    //mod 編集権限の適用 劉全航 start
    // del #10359 編集権限の動作不正 dengshen start
    // this.isAuthorized = this.getStateUserAccountInfo
    // .userSettings
    // .authorized_authorities
    // .includes(AUTHORITY_CODES.RST_EXAM_EDIT);
    // del #10359 編集権限の動作不正 dengshen end
    //mod 編集権限の適用 劉全航 end
  },
  async mounted() {
    // add #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。linjunfeng start
    if (this.selectedPatId && this.getExamRouteFlg) {
      this.$router.push({ name: "exam-record-detail" });
      return;
    }
    // add #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。linjunfeng end
    // パンくずリストのrefreshイベントをcreatedでリッスンすると検知しない
    EventBus.$on("refresh", this.dataLoad);
    
    this.setLoadingScreenVisible(true);
    if(this.getExamDefaultSex == null){
      await this.examSelectDefaultSex({
        facilityCd: this.getFacilityCd,
        selectedPatId: this.selectedPatId
      });
    }
    if(this.getCheckResultForFacility == null){
      await this.patIdJudgSetting({
        facilityCd: this.getFacilityCd,
        selectedPatId: this.selectedPatId
      });
    }
    this.$nextTick(() => {
      this.calculateGridHeight();
      // ヘッダーにスタイル適用
      this.setHeaderStyle();
      this.refreshDirectExamGrid();
    });
    this.setLoadingScreenVisible(false);
    this.finishInitialize();
  },
  updated() {
    this.$nextTick(() => {
      // ヘッダーにスタイル適用
      this.setHeaderStyle();
    });
  },
  // add 性能改善メモリ不足 shan start
  beforeUnmount() {
    this.destroyDirectExamRecordGrid();
    EventBus.$off("filterExamRecord", this.setFilterCondition);
    EventBus.$off("dataUpdate", this.setExamRecord);
    // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
    // EventBus.$off("requestReportParams");
    EventBus.$off("requestReportParams", this.requestrReportParams);
    // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
    // #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start
    // EventBus.$off("refresh");
    EventBus.$off("refresh", this.dataLoad);
    // #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end
    // add #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。linjunfeng start
    this.setExamRouteFlg(true)

    // add #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。linjunfeng end
  }
  // add 性能改善メモリ不足 shan end
};
</script>
<style>
@media print {
  /** 検査結果 tableレイアウト崩れ回避 */
  body:has(#examrecordlistgrid) #main-id {
    display: inline-block;
  }
}
</style>
<style scoped>

#examrecordlistgrid :deep(.k-cell-inner){
margin-inline:auto!important;
}

:deep(.k-grid th),
:deep(.k-grid td) {
    padding: 0.25rem 0.75rem !important;
    height: 2em!important;
}

/* :deep(.k-grid .k-table-th),
:deep(.k-grid .k-table-td) {
    padding: 0.25rem 0.75rem !important;
    height: 2em;
} */

:deep(.kendo-grid-style-page .k-grid-header-wrap th) {
    
    height: 2em!important;
}

:deep(.kendo-grid-style-page .k-grid tr) {
    height: 2em!important;
}

#examrecordlistgrid :deep(.k-grid-header-wrap .k-grid-header-table tr){
  padding: 1px 3px 3px 3px;
  height: 2em!important;
}
#examrecordlistgrid :deep(.k-grid-header-wrap .k-grid-header-table .k-table-th){
  border-color:#fff;
}

#examrecordlistgrid :deep(.k-grid .k-header .k-link) {
  white-space: normal !important;
  overflow: visible !important;
  text-overflow: unset !important;
}

#examrecordlistgrid :deep(.k-grid .k-column-title) {
  white-space: normal !important;
  display: inline-block;
}



/* :deep(.kendo-grid-style-page .k-grid-header-wrap .k-table-th) {
    padding: 1px 3px 3px 3px;
    height: 2em;
} */

:deep(.k-link) {
    margin: -.75rem -.75rem;
    padding: 0rem .75rem !important;
    line-height: inherit;
    display: block;
    overflow: hidden;
    text-overflow: ellipsis;
    outline: 0;
}
:deep(.kendo-grid-style-page .k-grid-header) {
    /* height: 86px; */
    min-height: 4em;
}

.exam-record-main-content :deep(.master-grid-header) {
  background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%);
}
.exam-record-main-content :deep(th[data-field*="order"]) {
  background-color: #333333;
  background-image: none;
}

.exam-record-main-content :deep(.k-i-sort-asc-sm::before) {
  content: "▲" !important;
  color: #ffffff;
  font-size:16px;
  font-family: WebComponentsIcons;
}
.exam-record-main-content :deep(.k-i-sort-desc-sm::before) {
  content: "▼" !important;
  color: #ffffff;
  font-size:16px;
  font-family: WebComponentsIcons;
}
.exam-record-list-head-content {
  margin-bottom: 25px;
  margin-left: 10px;
  margin-right: 10px;
  background-color: var(--ntss-base-background-color);
}
.exam-record-main-content {
  overflow-y: hidden;
  flex: 1;
  background-color: var(--ntss-base-background-color);
}
.exam-record-footer-content {
  margin-top: 5px;
  margin-right: 5px;
  flex: 0;
  background-color: var(--ntss-base-background-color);
}
/* スマホスタイル */
@media screen and (max-width: 480px) {
  .exam-record-list {
    font-size : 10px;
    word-wrap: break-word;
    white-space: normal;
  }
}
:deep(td i){
  font-style: normal;
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



:deep(.k-grid-header-locked .k-cell-inner){
  height:stretch;
}
:deep(.k-grid-header-locked .k-grid-header-table){
  height:stretch;
}

:deep(.k-grid-header){
  background-image: linear-gradient(hsla(0, 0%, 100%, .3), transparent 50%, transparent 0, rgba(0, 0, 0, .1));
  background-color: var(--ntss-list-header-background-color);
}
:deep(.k-grid-header-wrap){
  border-right:1px solid #fff;
}
:deep(.k-grid-header-wrap .k-grid-header-table){
  height:stretch;
}
:deep(.k-grid-header-wrap .k-cell-inner){
  height:stretch;
}


.exam-record-main-content :deep(.k-svg-i-sort-asc-small::before){
    content: "▲" !important;
    color: rgb(255, 255, 255);
    font-size:16px;
    font-family: WebComponentsIcons;
}

.exam-record-main-content :deep(.k-svg-i-sort-desc-small::before){
    content: "▼" !important;
    color: rgb(255, 255, 255);
    font-size:16px;
    font-family: WebComponentsIcons;
}


:deep(.k-grid .k-grid-content-locked ){
  border-color: rgba(33, 37, 41, .125)!important;
}
.exam-record-main-content :deep(.k-grid-content ){
  background-color: transparent!important;
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

@media print {
  /** スクロールコンテナ */
  .exam-record-main-content :deep(.k-grid-header-wrap),
  .exam-record-main-content :deep(.k-grid-content) {
    overflow: hidden !important;
    height: auto !important;
  }

  /** 固定列調整 */
  .exam-record-main-content :deep(.k-grid-content-locked) {
    height: auto !important;
  }

  /** 固定列枠線 */
  .exam-record-main-content :deep(.k-grid-header-locked::after) {
    content: "";
    position: absolute;
    top: 0;
    right: 0;
    width: 1px;
    height: 100%;
    background: var(--master-maintenance-kgrid-header-background-color);
    pointer-events: none;
  }
  .exam-record-main-content :deep(.k-grid-content-locked::after) {
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
  .exam-record-main-content :deep(.k-grid-header) {
    padding-right: 0 !important;
  }

  /** gridの幅 */
  .exam-record-main-content :deep(.k-grid) {
    width: 100vw;
    height: auto !important;
  }

  /** 印刷時に横スクロール右端時に強制的にスクロール位置を調整 */
  .exam-record-main-content:has(table.scroll-rightmost) :deep(.k-grid-content-locked),
  .exam-record-main-content:has(table.scroll-rightmost) :deep(.k-grid-header-locked) {
    z-index: 1;
  }
  .main-content-area:has(table.scroll-rightmost) {
    margin-left: -1px !important;
  }
  .exam-record-main-content :deep(.k-grid-header-wrap:has(table.scroll-rightmost)),
  .exam-record-main-content :deep(.k-grid-content:has(table.scroll-rightmost)) {
    position: static;
  }
}
</style>
