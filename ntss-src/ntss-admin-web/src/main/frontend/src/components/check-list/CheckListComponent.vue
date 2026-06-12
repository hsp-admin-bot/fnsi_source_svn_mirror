/**
 * チェックリスト画面
 */
<template>
  <div class="main-content-area master-maintenance-page" :style="{'height': mainHeight + 'px'}">
    <div class="check-list-head-content"></div>
    <div class="check-list-main-content">
      <!-- 患者一覧のグリッド -->
      <div :style="[condition.isShowUsageGuide ? { 'height':kendoGridHeight + 'px', 'overflow': 'auto', 'position': 'relative' } : {}]" class="grid-area">
        <div
          id="kendo"
          ref="grid"
          class="ntss-list check-list-main-content-list"
        ></div>
      </div>
        <div v-if="condition.isShowUsageGuide" id="area_usage_guide">
        <div class="usage-guide-div">
          <div class="usage-guide-element" style="background-color: white; border: silver solid 1px;"></div>
          ：予定
        </div>
        <div class="usage-guide-div">
          <div class="usage-guide-element" style="background-color: #42CB92; border: #42CB92 solid 1px;"></div>
          ：前体重測定済
        </div>
        <div class="usage-guide-div">
          <div class="usage-guide-element" style="background-color: #2CA06F; border: #2CA06F solid 1px;"></div>
          ：治療中
        </div>
        <div class="usage-guide-div">
          <div class="usage-guide-element" style="background-color: #557769; border: #557769 solid 1px;"></div>
          ：治療終了(未確定)
        </div>
        <div class="usage-guide-div">
          <div class="usage-guide-element" style="background-color: #808080; border: #808080 solid 1px;"></div>
          ：確定実績
        </div>
        <div class="usage-guide-div">
          <!-- mod FNSI-横展開 入院患者名の配布_チェックリスト機能分 周 start -->
          <!-- <div style="color: purple">患者名</div> -->
          <div class="pat-name-in-hospital">患者名</div>
          <!-- mod FNSI-横展開 入院患者名の配布_チェックリスト機能分 周 end -->
            <div>：入院患者</div>
        </div>
        <div style="display: flex;">
          <div>患者名</div>
          ：外来患者
        </div>
      </div>
    </div>
  </div>
</template>

<script>
// add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 start
import kendo from "@progress/kendo-ui";
import $ from "jquery";
import { markRaw } from "@/compat/vue/runtime";
// add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 end
import { mapGetters, mapActions, mapMutations } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import PatHeaderControlMixin from "@/components/common/PatHeadControlMixin";
import dayjs from "@/compat/date/dayjs";
import { dialysisState } from "@/constants/weightDefine";
import { getCurrentFunctionCd } from "@/router/routing-helper";
//FNSI-修正 左サイドバー切り替えする時、画面の右スクロールバーの表示がおかしいについての修正 xugj add start

//FNSI-修正 左サイドバー切り替えする時、画面の右スクロールバーの表示がおかしいについての修正 xugj add end
// add 5984 機能帳票でパラメータが正しく渡されていない 歴 start
import store from "@/stores";
// add 5984 機能帳票でパラメータが正しく渡されていない 歴 end
import { CHECK_LIST_FORCE_SIGNOUT } from "@/constants/facilitySetting";
import { initForceSignOutFlag } from "@/functions/common/CommonFunctions";
import { addPatNameSortToList, sortableCompare } from "@/functions/SortFunctions";

import { getLatestHeaderElement, getHeaderHeight, getFooterMenuClientHeight, getMainContentAreaElement, getScopedElementById, getScopedSessionStorage } from "@/functions/common/LayoutMeasureHelper";

const { updated: _checkListMasterMaintenanceUpdated, ...CheckListMasterMaintenanceMixin } = MasterMaintenanceMixin;

function getChecklistGridRoot(sender) {
  if (!sender) return null;
  if (sender.wrapper?.[0]) return sender.wrapper[0];
  if (sender.element?.[0]) return sender.element[0];
  if (sender.nodeType === 1) return sender;
  return null;
}

function findChecklistGridContent(root) {
  return root?.querySelector?.(".k-grid-content") || null;
}

function findChecklistLockedContent(root) {
  return root?.querySelector?.(".k-grid-content-locked") || null;
}

function captureChecklistGridScrollPosition(sender) {
  const root = getChecklistGridRoot(sender);
  const content = findChecklistGridContent(root);
  return {
    top: content?.scrollTop || 0,
    left: content?.scrollLeft || 0
  };
}

function restoreChecklistGridScrollPosition(sender, position = {}) {
  const root = getChecklistGridRoot(sender);
  const content = findChecklistGridContent(root);
  const lockedContent = findChecklistLockedContent(root);
  if (content) {
    content.scrollTop = position.top || 0;
    content.scrollLeft = position.left || 0;
    try {
      content.dispatchEvent(new Event("scroll", { bubbles: true }));
    } catch (_error) {
      $(content).trigger("scroll");
    }
  }
  if (lockedContent) {
    lockedContent.scrollTop = position.top || 0;
  }
}

function attachChecklistLockedContentScrollSync(sender, { cleanupList = [], wheel = false } = {}) {
  const root = getChecklistGridRoot(sender);
  const content = findChecklistGridContent(root);
  const lockedContent = findChecklistLockedContent(root);
  if (!content || !lockedContent) return;
  const sync = () => {
    lockedContent.scrollTop = content.scrollTop;
  };
  content.addEventListener("scroll", sync, { passive: true });
  cleanupList.push(() => content.removeEventListener("scroll", sync));
  if (wheel) {
    const wheelSync = event => {
      lockedContent.scrollTop += event.deltaY || 0;
      content.scrollTop = lockedContent.scrollTop;
    };
    lockedContent.addEventListener("wheel", wheelSync, { passive: true });
    cleanupList.push(() => lockedContent.removeEventListener("wheel", wheelSync));
  }
}

function createChecklistDataSource(options) {
  return new kendo.data.DataSource(options);
}

// ソートキー変換用のマップ
const SORT_KEY_MAP = {
  viewTreatDate: "treatDate", // 治療日 ※viewTreatDateは"MM/DD(曜日)" 形式のためtreatDateでソートする
};

const BED_DIALYSIS_STATE_CLASSES = [
  "td-send-condition",
  "td-dialysis",
  "td-after-dialysis",
  "td-after-record",
  "td-not-send-condition"
];

export default {

  mixins: [NextTransitionMixin, CheckListMasterMaintenanceMixin, PatHeaderControlMixin],
  data() {
    return {
      androidFlg: false,
      iosFlg: false,
      sendOrdNo: null,
      kendoMode: false,
      kendoGridToolbarHeight: 500,
      kendoGridHeight: 300,
      gridScrollSyncCleanup: [],
      directGridWidget: null,
      directGridColumnSignature: "",
      directGridLayoutRafId: null,
      mainHeight: 300,
      // mod FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 start
      // sort: {
      //   key: "",
      //   isAsc: true
      // },
      // mod FNSI-redmine_#3907_コンソールエラーを修正 周 start
      // listDataSource: null,
      listDataSource: [],
      getOrdMainList: [],
      // mod FNSI-redmine_#3907_コンソールエラーを修正 周 end
      // mod FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 end
      autoReload: 0,
      selfScreenName: "",
      // add #11285 機能帳票の印刷情報対応② 高 start
      bedCdListString: "",
      // add #11285 機能帳票の印刷情報対応② 高 end
      currentScrollTop: 0,
      currentScrollLeft: 0,
      currentSort: null,
      lockFlg:true
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
    // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
    ...mapGetters("periodic-inspection", ["getStorSimlpSearchQurey"]),
    // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
    // add 5984 機能帳票でパラメータが正しく渡されていない 歴 start
    ...mapGetters("check-list/medimodal", {
      getSelectOrdMainMedimodal: "getSelectOrdMain"
    }),
    ...mapGetters("check-list/modal", {
      getSelectOrdMainModal: "getSelectOrdMain",
    }),
    // add 5984 機能帳票でパラメータが正しく渡されていない 歴 end
    // add FNSI-redmine_#3908_ソート方法の改善 周 start
    selectedFontSize: {
      get() {
        return this.getFontSize;
      }
    },
    // add FNSI-redmine_#3908_ソート方法の改善 周 end
    /**
     * 現在の表示グリッドから患者選択リストを取得する
     */
    CheckListToPatList() {
      let ret = [];

      // gridの全行取得
      // FNSI-チェックリスト画面表示を修正 周 mod start
      // const view = this.listDataSource;
      const view = this.listDataSource._view;
      // FNSI-チェックリスト画面表示を修正 周 mod end
      view.forEach(function(value, index, array) {
        // 治療実績判定
        const info = array[index];
        if (info.ordNo !== null && info.ordNo !== undefined) {
          let list = {
            pat_id: info.patId,
            pat_last_name: info.patLastName,
            pat_first_name: info.patFirstName,
            ord_no: info.ordNo,
            kur_name: info.kurName,
            bed_name: info.bedName,
            is_same: info.isSame,
            in_out_class: info.inOutClass,
            ...info
          };
          ret.push(list);
        }
      });
      return ret;
    },
    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("check-list/list", [
      "getCondition",
      "getIsDisplayTreatingMode",
      // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 start
      "getIsAsynComplete",
      "getChecklistSetting",
      // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 end
      "getMstKurSelector",
      "getMstBedGroupList",
      "getChecklistColumn",
      "getChecklistColumnHeader",
      // "getOrdMainList",
      "isDispTreatData",
      "getIsDataLoading",
      "getIsDataLoadCancel",
      "getReloadInterval"
    ]),
    // add 画面印刷プレビューと印刷の実現 黄 start
    ...mapGetters("pat-info", ["searchedPatList", "selectedPatId"]),
    // add 画面印刷プレビューと印刷の実現 黄 end
    condition: {
      get() {
        return this.getCondition;
      }
    },
    ordMainList() {
      // storeからデータを取得
      let dataList = [];

      if (this.getOrdMainList) {
        /* modify by chamaojia 2024-04-24 [10456] data processing has been completed in the backend --start */
        // // 表示画面判定
        // if (this.getIsDisplayTreatingMode) {
        //   // 治療状況
        //   dataList = this.getOrdMainList.map(rec => {
        //     let ret = null;
        //     if (this.isDispTreatData(rec)) {
        //       ret = rec;
        //     }
        //     return ret;
        //   });
        // } else {
        //   // 予定日
        //   dataList = this.getOrdMainList;
        // }
        dataList = this.getOrdMainList;
        /* modify by chamaojia 2024-04-24 [10456] data processing has been completed in the backend --end */
      }

      // リストをソート
      const sortList = dataList
        .filter(data => data !== null)
        .sort(function(a, b) {
          const aOrdNo = a.ordNo === null ? 0 : a.ordNo;
          const aBedName = a.bedName === null ? "" : a.bedName;
          const aRstDialysisState =
            a.rstDialysisState === null ? "0" : a.rstDialysisState;
          const aPatName = a.patName === null ? "" : a.patName;
          const bOrdNo = b.ordNo === null ? 0 : b.ordNo;
          const bBedName = b.bedName === null ? "" : b.bedName;
          const bRstDialysisState =
            b.rstDialysisState === null ? "0" : b.rstDialysisState;
          const bPatName = b.patName === null ? "" : b.patName;

          let ret =
            aBedName < bBedName
              ? -1
              : aBedName > bBedName
              ? 1
              : aRstDialysisState < bRstDialysisState
              ? -1
              : aRstDialysisState > bRstDialysisState
              ? 1
              : aPatName < bPatName
              ? -1
              : aPatName > bPatName
              ? 1
              : aOrdNo < bOrdNo
              ? -1
              : 1;
          return ret;
        });

      return sortList;
    },
    checkGridColumns() {
      return this.getChecklistColumn;
    },
    checkGridColumnsHeader() {
      return this.getChecklistColumnHeader;
    },
    // mod FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 start
    // sortedItems() {
    //   const list = this.ordMainList.slice(); // ソート時でstate自体の順序を書き換えないため
    //   if (this.sort.key) {
    //     list.sort((a, b) => {
    //       a = a[this.sort.key];
    //       b = b[this.sort.key];

    //       let sortItem1 = 0;
    //       let sortItem2 = 0;

    //       if (a === b) {
    //         sortItem1 = 0;
    //       } else if (a > b) {
    //         sortItem1 = 1;
    //       } else {
    //         sortItem1 = -1;
    //       }
    //       if (this.sort.isAsc) {
    //         sortItem2 = 1;
    //       } else {
    //         sortItem2 = -1;
    //       }
    //       return sortItem1 * sortItem2;
    //     });
    //   }
    //   return list;
    // },
    // listDataSource() {
    //   // 選択状態最更新
    //   const retList = this.filteredScheduleList(this.sortedItems);
    //   retList.map(e => e.setDataClass = this.dialysisStateBackColor);
    //   return retList;
    // }
    getListDataSource() {
      const retList = this.filteredScheduleList(this.ordMainList.slice());
      retList.map(e => e.setDataClass = this.dialysisStateBackColor);
      return retList;
    }
    // mod FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 end
  },
  methods: {
    getCheckListPageRoot() {
      return getMainContentAreaElement(this.$el || null) || this.$el || document;
    },
    getUsageGuideElement() {
      return getScopedElementById('area_usage_guide', this.getCheckListPageRoot()) || null;
    },
    getPatientSearchSidebarButton() {
      return getScopedElementById('showPatientSearchSidebarBtn', this.getCheckListPageRoot()) || null;
    },
    ...mapActions("multi-modal", [
      "showChecklist",
      "showMedicine",
      "showSchedule"
    ]),
    ...mapActions("check-list/list", [
      "setCondition",
      "changeIsDisplayTreatingMode",
      "getCheckListSetting",
      "setStatusGridColumn",
      // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
      // "getOrderMainListTreatment",
      // "getOrderMainListByTreatDate",
      // "getOrderMainListChiryouchuu",
      // "getOrderMainListShiteibi",
      "getRequestGetOrdCheckListAll",
      "getRequestGetOrdMainChiryouchuu",
      "getRequestGetOrdMainShiteibi",
      "setIsAsynComplete",
      // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end
      // add FNSI-redmine_#3908_ソート方法の改善 周 start
      "setChecklistColumnWidth",
      "setChecklistColumnHeaderWidth",
      // add FNSI-redmine_#3908_ソート方法の改善 周 end
      "setChecklistColumn",
      "getChecklistName",
      "setIsDataLoadCancel",
      "setIsDataLoading",
      "fetchReloadInterval",
      "setReloadInterval"
    ]),
    ...mapActions("check-list/modal", ["setSelectCheckList"]),
    ...mapActions("check-list/medimodal", ["setSelectOrdNo"]),
    ...mapActions("send-condition/scale", {
      sendConditionSetSelectOrdNo: "setSelectOrdNo"
    }),
    ...mapActions("treatment-record/common", {
      //add FNSI修正 治療記録画面バッグ 房 start
      setOrd: "setOrd",
      //add FNSI修正 治療記録画面バッグ 房 end
      setTreatmentRecordOrdNo: "setOrdNo",
      setOrdNoForSideBarRecord: "setOrdNoForSideBarRecord"
    }),
    ...mapActions("schedule-assignment/modal", {
      scheduleAssignmentSetSelectOrdNo: "setSelectOrdNo"
    }),
    ...mapMutations("pat-info", {
      updateTreatmentPatList: "updateTreatmentPatList",
      setSrcFuncName: "setSrcFuncName"
    }),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount: "resetLoadingScreenVisibleCount"
    }),
    /**
     * 列ヘッダクリック時にソート順を設定
     * @param {*} e
     */
    sortHandler(e) {
      this.currentSort = e.sort;
      this.$nextTick(() => {
        requestAnimationFrame(() => {
          this.applyBedDialysisStateColors();
        });
      });
    },
    /**
     * 列ヘッダクリック時のソート処理
     * @param {*} a
     * @param {*} b
     */
    compareByField(a, b) {
      // ソートなしはreturn
      if (!this.currentSort || !this.currentSort.field) return;

      const sortField = SORT_KEY_MAP[this.currentSort.field] || this.currentSort.field;

      // 投与薬剤・チェックリスト列の場合は独自ソート
      if (sortField === "medicine" || sortField.startsWith("checklist_")) {
        const countField = sortField === "medicine" ? "medi_count" : `${sortField}_count`
        const chkField = sortField === "medicine" ? "medi_chkcount" : `${sortField}_chkcount`

        // - 第1ソートキー：分母－分子（未実施数）降順
        // - 第2ソートキー：分母　降順
        // - ↑を昇順ソートとする。(未実施の頭出し)
        const diffA = a[countField] - a[chkField];
        const diffB = b[countField] - b[chkField];
        return (diffB - diffA) || (b[countField] - a[countField]);
      }

      // 投与薬剤・チェックリスト列以外は共通関数でソート
      return sortableCompare(a, b, sortField, true);
    },
    /**
     * フィルタリング処理
     */
    filteredScheduleList(dataSource) {
      if (dataSource === null) {
        return null;
      }

      return dataSource
        .filter(dat => {
          let isFilteringKur = true;
          // 指定日の場合
          if (this.getIsDisplayTreatingMode === false) {
            // クールフィルター作成
            if (`${this.condition.kurCd}` !== "-1") {
              isFilteringKur =
                dat.kurCd !== null &&
                `${dat.kurCd}` === `${this.condition.kurCd}`;
            }
          }

          // ベッドグループフィルター作成
          let isFilteringBed = true;
          if (this.condition.bedGroupCd > -1) {
            isFilteringBed = false;
            let bedGroup = this.getMstBedGroupList.find(bg => bg.roomBedGroupCd === this.condition.bedGroupCd);
            if (bedGroup !== null && bedGroup.bedList)
            {
              for (const bedCd of bedGroup.bedList) {
                if (dat.bedCd === bedCd) {
                  isFilteringBed = true;
                  break;
                }
              }
            }
          }
          const retValue = isFilteringKur && isFilteringBed;

          return retValue;
        })
        .slice();
    },

    scheduleGridHeightCalculation() {
      // Vue3ではKendo Grid本体DOMの生成がVue2より遅れる場合があるため、
      // content DOM未生成時は次tickで再同期する。
      this.$nextTick(() => {
        this.calculateGridHeight();
      });
    },
    getGridScrollSender() {
      return this.$refs.grid?.gridWidget?.() || this.getGridRootEl?.() || this.$refs.grid?.$el || null;
    },
    captureGridScrollPosition() {
      return captureChecklistGridScrollPosition(this.getGridScrollSender());
    },
    restoreGridScrollPosition(position = {}) {
      restoreChecklistGridScrollPosition(this.getGridScrollSender(), position);
      if (Number.isFinite(position?.top)) {
        this.currentScrollTop = position.top;
      }
      if (Number.isFinite(position?.left)) {
        this.currentScrollLeft = position.left;
      }
    },
    getDirectGridRoot() {
      const ref = this.$refs.grid;
      return ref?.nodeType === 1 ? ref : ref?.$el || null;
    },
    getDirectGridColumnSignature() {
      const summarize = column => ({
        field: column.field,
        title: column.title,
        hidden: column.hidden === true,
        locked: column.field === "bedName" || column.locked === true,
        width: column.width?.[this.selectedFontSize] || column.width || "",
        hasTemplate: !!column.template
      });
      return JSON.stringify([
        ...(this.checkGridColumnsHeader || []).map(summarize),
        ...(this.getChecklistColumn || []).map(summarize)
      ]);
    },
    buildDirectGridColumns() {
      const headerColumns = (this.checkGridColumnsHeader || []).map(column => ({
        field: column.field,
        locked: column.field === "bedName",
        title: this.$sanitize ? this.$sanitize(column.title) : column.title,
        width: column.width?.[this.selectedFontSize] || column.width,
      }));
      const bodyColumns = (this.getChecklistColumn || [])
        .filter(column => column.field !== "bedName")
        .map(column => ({
          field: column.field,
          hidden: !!column.hidden,
          locked: false,
          template: column.template,
          title: this.$sanitize ? this.$sanitize(column.title) : column.title,
          attributes: column.field === "hospPatId" ? { class: "hosp-pat-id-body" } : {},
          width: column.width?.[this.selectedFontSize] || column.width,
        }));
      return [...headerColumns, ...bodyColumns];
    },
    getDirectGridHeaderFields(isLocked) {
      const root = this.getDirectGridRoot();
      if (!root) {
        return [];
      }
      const headerRoot = isLocked
        ? root.querySelector(".k-grid-header-locked")
        : root.querySelector(".k-grid-header-wrap");
      if (!headerRoot) {
        return [];
      }
      return Array.from(
        headerRoot.querySelectorAll("th[data-field][role='columnheader'], th[data-field].k-header")
      ).map(th => th.getAttribute("data-field"));
    },
    getDirectGridFieldByCell(cell) {
      if (!cell) {
        return null;
      }
      const isLocked = !!cell.closest(".k-grid-content-locked");
      const cellIndex = cell.cellIndex ?? -1;
      if (cellIndex < 0) {
        return null;
      }
      const field = this.getDirectGridHeaderFields(isLocked)[cellIndex];
      if (field) {
        return field;
      }
      const grid = this.directGridWidget;
      if (grid?.cellIndex) {
        const columnIndex = grid.cellIndex($(cell));
        if (columnIndex >= 0) {
          return grid.columns?.[columnIndex]?.field || null;
        }
      }
      return null;
    },
    installDirectGridFacade() {
      const root = this.getDirectGridRoot();
      if (!root) return;
      root.kendoWidget = () => this.directGridWidget;
      root.gridWidget = () => this.directGridWidget;
      root.gridDataSource = () => this.directGridWidget?.dataSource || null;
      root.gridRootEl = () => root;
      root.gridElement = () => root;
      root.gridContentEl = () => root.querySelector(".k-grid-content");
      root.gridLockedContentEl = () => root.querySelector(".k-grid-content-locked");
      root.gridAutoScrollableEl = () => root.querySelector(".k-grid-content");
      root.gridHeaderEl = () => root.querySelector(".k-grid-header");
      root.gridHeaderWrapEl = () => root.querySelector(".k-grid-header-wrap");
      root.gridTbodyEl = () => this.directGridWidget?.tbody?.[0] || root.querySelector(".k-grid-content tbody");
      root.gridDataItem = row => this.directGridWidget?.dataItem?.(row) || null;
      root.clearGridSelection = () => this.directGridWidget?.clearSelection?.();
      root.gridResizeTargets = () => [root.querySelector(".k-grid-header"), root.querySelector(".k-grid-content")].filter(Boolean);
    },
    getDirectGridDataSourceOption() {
      if (this.listDataSource?.data) {
        return this.listDataSource;
      }
      return createChecklistDataSource({
        data: Array.isArray(this.listDataSource) ? this.listDataSource : [],
        sort: this.currentSort || null
      });
    },
    initDirectGridIfReady() {
      const root = this.getDirectGridRoot();
      if (!root || !this.listDataSource || !this.checkGridColumnsHeader?.length) {
        return;
      }
      const nextSignature = this.getDirectGridColumnSignature();
      if (this.directGridWidget) {
        if (this.directGridColumnSignature !== nextSignature) {
          this.directGridWidget.setOptions({ columns: this.buildDirectGridColumns() });
          this.directGridColumnSignature = nextSignature;
          this.directGridWidget.refresh?.();
        }
        this.applyDirectGridDataSourceContract();
        this.installDirectGridFacade();
        this.scheduleDirectGridLayoutContract();
        return;
      }
      const $root = $(root);
      $root.kendoGrid({
        dataSource: this.getDirectGridDataSourceOption(),
        columns: this.buildDirectGridColumns(),
        scrollable: true,
        resizable: true,
        selectable: "cell",
        sortable: { compare: this.compareByField },
        height: this.kendoGridHeight,
        sort: event => this.sortHandler(event),
        columnResize: event => this.columnResizeEvevt(event),
        change: event => this.onCellClick(event),
        dataBound: () => this.gridSetting()
      });
      this.directGridWidget = markRaw($root.data("kendoGrid"));
      this.directGridColumnSignature = nextSignature;
      this.installDirectGridFacade();
      this.applyDirectGridStyleContract();
      this.scheduleDirectGridLayoutContract();
    },
    applyDirectGridDataSourceContract() {
      const grid = this.directGridWidget;
      const dataSource = this.getDirectGridDataSourceOption();
      if (!grid || !dataSource) return;
      if (grid.dataSource !== dataSource) {
        grid.setDataSource(dataSource);
        return;
      }
      const latestData = typeof dataSource.data === "function" ? dataSource.data() : [];
      if (Array.isArray(latestData) && latestData.length > 0) {
        grid.dataSource.data(latestData);
      }
      if (this.currentSort) {
        grid.dataSource.sort(this.currentSort);
      }
    },
    scheduleDirectGridLayoutContract() {
      if (this.directGridLayoutRafId != null) {
        cancelAnimationFrame(this.directGridLayoutRafId);
      }
      this.directGridLayoutRafId = requestAnimationFrame(() => {
        this.directGridLayoutRafId = null;
        this.applyDirectGridStyleContract();
        this.directGridWidget?.resize?.(true);
      });
    },
    applyDirectGridStyleContract() {
      const root = this.getDirectGridRoot();
      if (!root) return;
      root.classList.add("ntss-kendo-grid-legacy", "k-widget", "k-grid", "k-display-block");
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
      this.applyBedDialysisStateColors();
    },
    applyBedDialysisStateColors() {
      const root = this.getDirectGridRoot();
      const grid = this.directGridWidget;
      if (!root || !grid) {
        return;
      }
      const paintLockedRow = row => {
        if (!row?.closest?.(".k-grid-content-locked")) {
          return;
        }
        const dataItem = grid.dataItem?.(row) || grid.dataItem?.($(row));
        if (!dataItem) {
          return;
        }
        const firstCell = row.querySelector("td");
        if (!firstCell) {
          return;
        }
        BED_DIALYSIS_STATE_CLASSES.forEach(className => {
          firstCell.classList.remove(className);
        });
        firstCell.classList.add(this.dialysisStateBackColor(dataItem));
      };
      root.querySelectorAll(".k-grid-content-locked tbody tr[data-uid]").forEach(paintLockedRow);
      grid.tbody?.children?.().each?.((_index, row) => {
        const uid = row.getAttribute("data-uid");
        if (!uid) {
          return;
        }
        root.querySelectorAll(`.k-grid-content-locked tr[data-uid="${uid}"]`).forEach(paintLockedRow);
      });
    },
    destroyDirectGrid() {
      try {
        this.directGridWidget?.destroy?.();
      } catch (_error) {
        // noop
      }
      this.directGridWidget = null;
      this.directGridColumnSignature = "";
      const root = this.getDirectGridRoot();
      if (root) root.innerHTML = "";
    },
    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      const scrollPosition = this.captureGridScrollPosition();
      const wh = this.windowHeight;
      const hh = getHeaderHeight(getLatestHeaderElement(this.$el || document), 0);
      const fmh =
        (this.isDispMenu === 1
          ? getFooterMenuClientHeight(this.$el || null)
          : 0) + 5;
      this.kendoGridToolbarHeight = wh - hh - fmh - 3;
      this.mainHeight = wh - hh - fmh;
      this.kendoGridToolbarHeight =
        this.kendoGridToolbarHeight < 340
          ? this.mainHeight
          : this.kendoGridToolbarHeight;

      //const gfh = document.getElementById("grid-footer").clientHeight;
      //this.kendoGridHeight = this.kendoGridToolbarHeight - (gfh + 40);
      const usageGuide = this.getUsageGuideElement();
      const guideClientHeight = usageGuide
        ? usageGuide.clientHeight
        : 0;
      this.kendoGridHeight = this.kendoGridToolbarHeight - guideClientHeight;

      //FNSI-修正 左サイドバー切り替えする時、画面の右スクロールバーの表示がおかしいについての修正 xugj add start
      const gridWidget = this.getGridWidget();
      const resizeTargets = this.$refs.grid?.gridResizeTargets?.() || [];
      gridWidget?.resize?.(resizeTargets.length ? resizeTargets : [this.getGridHeaderEl(), this.getGridContentEl()].filter(Boolean));
      //FNSI-修正 左サイドバー切り替えする時、画面の右スクロールバーの表示がおかしいについての修正 xugj add end
      // add bug 6697 修正 chen start
      this.$nextTick(() => {
        const gridContent = this.getGridContentEl();
        if (!gridContent) {
          // Vue3ではKendo Grid本体DOMの生成がVue2より遅れる場合があるため、DOM生成前は次回同期に委ねる。
          requestAnimationFrame(() => {
            if (this.getGridContentEl()) {
              this.calculateGridHeight();
            }
          });
          return;
        }
        const headerHeight = (this.getGridHeaderEl()?.offsetHeight || 0) + 2;
        const isHorizontalScroll = gridContent.scrollWidth > gridContent.clientWidth;
        let lockRowHeight = this.kendoGridHeight - headerHeight;
        // PCでの表示時のみ、スクロールバー分の不要な高さが発生する為、高さの調整を行う
        if (!this.androidFlg && !this.iosFlg && isHorizontalScroll) {
          lockRowHeight -= 17;
        }
        const lockedContent = this.getGridLockedContentEl();
        const lockedRows = lockedContent ? [lockedContent] : [];
        if (lockedRows && lockedRows.length > 0) {
          lockedRows[0].style.height = lockRowHeight + "px";
        }
        // スクロール位置復帰（resize 前の実際位置を使う。currentScrollTop は dataLoad 時のみ更新される）
        this.restoreGridScrollPosition(scrollPosition);
      });
      // add bug 6697 修正 chen end
    },
    // 抽出条件変更イベント
    setFilterCondition(chgFlg) {
      // 次患者または治療日が変更された場合
      if (chgFlg) {
        // スケジュール取得
        this.dataLoad();
      } else {
        this.filteredCheckList();
        // add FNSI-横展開 表示条件のサインイン内保持_チェックリスト機能分 周 start
        this.listDataSource = createChecklistDataSource({
          data: this.getListDataSource,
          sort: this.currentSort ? this.currentSort : null // ソート条件保持
        });
        this.$nextTick(() => this.initDirectGridIfReady());
        // add FNSI-横展開 表示条件のサインイン内保持_チェックリスト機能分 周 end
      }
    },
    // データ更新(チェックリスト登録後, 投与薬剤登録後, 治療中/指定日切替)
    setCheckList(autoRefreshFlag) {
      if (this.getIsDataLoading) {
        return;
      }
      if (this.selfScreenName !== this.$route.name) {
        return;
      }
      this.endPolling();
      this.setIsDataLoading(true);
      this.setLoadingScreenVisible(true);
      this.setIsDataLoadCancel(true);
      this.dataLoad(autoRefreshFlag);
      this.setLoadingScreenVisible(false);
      this.startPolling();
    },
    async dataLoad(autoRefreshFlag) {
      // スクロール位置を保存
      const gridContent = this.getGridContentEl();
      if (gridContent) {
        this.currentScrollTop = gridContent.scrollTop;
        this.currentScrollLeft = gridContent.scrollLeft;
      } else {
        // Vue3では初期mounted時点でKendo Gridのcontent DOMが未生成の場合がある。
        // Vue2と同じスクロール復帰値を保持するため、未生成時は既存値を維持する。
        this.currentScrollTop = this.currentScrollTop || 0;
        this.currentScrollLeft = this.currentScrollLeft || 0;
      }
      // FNSI-修正 #5407 xie add start
      this.setLoadingScreenVisible(true);
      // FNSI-修正 #5407 xie add end
      // 表示モード[true:治療中, false:指定日]
      const displayModeIsDialysis = this.getIsDisplayTreatingMode;

      // チェックリストマスタ設定情報取得
      await this.getCheckListSetting({facilityCd: this.getFacilityCd, autoRefreshFlag});
      this.fetchReloadInterval(autoRefreshFlag).then(r => {
        this.setReloadInterval(r.data);
      });
      // チェックリストグリッド列作成
      await this.setStatusGridColumn();
      // 治療中の場合
      if (displayModeIsDialysis) {
        // odr_mainの情報取得(指定日)
        // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
        // await this.getOrderMainListTreatment({
        await this.getOrderMainListChiryouchuu({
        // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end
          facilityCd: this.getFacilityCd,
          nextPat: this.condition.nextPat,
          autoRefreshFlag
        });
        // 検索条件で表示内容を更新
        this.filteredCheckList();
      } else {
        // 指定日の場合
        // odr_mainの情報取得(指定日)
        // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
        // await this.getOrderMainListByTreatDate({
        await this.getOrderMainListShiteibi({
        // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end
          facilityCd: this.getFacilityCd,
          treatDate: this.condition.treatDate.replace(/-/g, ""),
          autoRefreshFlag
        });
        // 検索条件で表示内容を更新
        this.filteredCheckList();
      }
      // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 start
      this.listDataSource = createChecklistDataSource({
        data: this.getListDataSource,
        sort: this.currentSort ? this.currentSort : null // ソート条件保持
      });
      this.calculateGridHeight();
      this.$nextTick(() => this.initDirectGridIfReady());
      // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 end

      // 読み込み処理が走ってしまった時点でフラグを落とす
      this.setIsDataLoading(false);
      this.setLoadingScreenVisible(false);
    },

    /**
     * 治療中
     * ord_main情報を取得
     * facilityCd: 施設コード
     * nextPat: 次患者[0:次クール, 1:当日, 2:次クール以降]
     */
    async getOrderMainListChiryouchuu(parm) {
      // ord_main情報取得
      const response = await this.getRequestGetOrdMainChiryouchuu(parm);

      // 取得データの変換
      let dataList = response.data.copyWithin(0, 0);
      dataList.forEach(async (value, index, array) => {
        // 治療日を作成
        let tDate =
          array[index].treatDate.substr(4, 2) +
          "/" +
          array[index].treatDate.substr(6, 2);
        let weekList = ["", "月", "火", "水", "木", "金", "土", "日"];
        let tWeek = "(" + weekList[array[index].treatWeek] + ")";
        array[index].viewTreatDate = tDate + tWeek;

        // 登録されていない場合は条件送信前扱い
        if (
          array[index].rstDialysisState === "" ||
          array[index].rstDialysisState === null
        ) {
          array[index].rstDialysisState = "0";
        }

        // 指示：投与薬剤情報を取得
        if (array[index].indMediInfo !== null) {
          array[index].indMediInfo = JSON.parse(array[index].indMediInfo);
        }
        // 実績：投与薬剤情報を取得
        if (array[index].rstMediInfo !== null) {
          array[index].rstMediInfo = JSON.parse(array[index].rstMediInfo);
        }

        // 条件送信前の場合「指示：投与薬剤情報」
        // 条件送信後の場合「実績：投与薬剤情報」
        array[index].mediInfo =
          array[index].rstDialysisState === "0" ?
            array[index].indMediInfo :
            array[index].rstMediInfo;

        // 投与薬剤項目数
        let mediChkCount = 0;
        // 投与薬剤実施済み項目数
        let mediOnChkCount = 0;

        if (array[index].mediInfo !== null) {
          // 投与薬剤項目数セット
          mediChkCount = array[index].mediInfo.length;
          // 投与薬剤実施済み項目数セット
          mediOnChkCount = array[index].mediInfo.filter(item => item.effect_flg == 1).length;
        }

        array[index].medi_count = mediChkCount;
        array[index].medi_chkcount = mediOnChkCount;
        array[index].medicine = mediOnChkCount + "/" + mediChkCount;
      });

      // システム共通患者名ソート用(フリガナ優先文字列)を追加
      dataList = addPatNameSortToList(dataList);

      // 取得したord_main情報をセット
      this.setIsDataLoadCancel(false);
      this.getOrdMainList = dataList;

      // チェックリスト実績を取得
      await this.getOrderCheckListByOrdNo(parm.autoRefreshFlag);
    },
    /**
     * 治療日指定
     * ord_main情報を取得
     * facilityCd: 施設コード
     */
    async getOrderMainListShiteibi(parm) {
      // ord_main情報取得
      const response = await this.getRequestGetOrdMainShiteibi(parm);

      // 取得データの変換
      let dataList = response.data.copyWithin(0, 0);
      dataList.forEach(async (value, index, array) => {
        // 治療日を作成
        let tDate =
          array[index].treatDate.substr(4, 2) +
          "/" +
          array[index].treatDate.substr(6, 2);
        let weekList = ["", "月", "火", "水", "木", "金", "土", "日"];
        let tWeek = "(" + weekList[array[index].treatWeek] + ")";
        array[index].viewTreatDate = tDate + tWeek;

        // 登録されていない場合は条件送信前扱い
        if (
          array[index].rstDialysisState === "" ||
          array[index].rstDialysisState === null
        ) {
          array[index].rstDialysisState = "0";
        }

        // 指示：投与薬剤情報を取得
        if (array[index].indMediInfo !== null) {
          array[index].indMediInfo = JSON.parse(array[index].indMediInfo);
        }
        // 実績：投与薬剤情報を取得
        if (array[index].rstMediInfo !== null) {
          array[index].rstMediInfo = JSON.parse(array[index].rstMediInfo);
        }

        // 条件送信前の場合「指示：投与薬剤情報」
        // 条件送信後の場合「実績：投与薬剤情報」
        array[index].mediInfo =
          array[index].rstDialysisState === "0" ?
            array[index].indMediInfo :
            array[index].rstMediInfo;

        // 投与薬剤項目数
        let mediChkCount = 0;
        // 投与薬剤実施済み項目数
        let mediOnChkCount = 0;

        if (array[index].mediInfo !== null) {
          // 投与薬剤項目数セット
          mediChkCount = array[index].mediInfo.length;
          // 投与薬剤実施済み項目数セット
          mediOnChkCount = array[index].mediInfo.filter(item => item.effect_flg == 1).length;
        }

        array[index].medi_count = mediChkCount;
        array[index].medi_chkcount = mediOnChkCount;
        array[index].medicine = mediOnChkCount + "/" + mediChkCount;
      });

      // システム共通患者名ソート用(フリガナ優先文字列)を追加
      dataList = addPatNameSortToList(dataList);

      // 取得したord_main情報をセット
      this.setIsDataLoadCancel(false);
      this.getOrdMainList = dataList;

      // チェックリスト実績を取得
      await this.getOrderCheckListByOrdNo(parm.autoRefreshFlag);
    },
    /**
     * チェックリスト実績情報を取得
     */
    async getOrderCheckListByOrdNo(autoRefreshFlag) {
      let listChecklistResponse = [];
      let listChgRecord = [];
      let list = this.getOrdMainList;
      // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 start
      this.setIsAsynComplete(false);
      // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 end

      if (this.getIsDataLoadCancel) {
        // ページ切り替えなどでデータ読み込みの中断があった
        this.setIsDataLoadCancel(false);
      } else {
        listChgRecord = listChgRecord.concat(list);
        let params = list.map(item=>{
          return {
            ordNo: item.ordNo,
            rstDialysisState: item.rstDialysisState
          }
        })
        // console.log(params);
        await this.getRequestGetOrdCheckListAll({params, autoRefreshFlag}).then(checklistResponse=>{
          listChecklistResponse = listChecklistResponse.concat(checklistResponse.data);
        });
      }

      // console.log(listChecklistResponse);

      // チェックリスト
      let checkSettings = this.getChecklistSetting.checklistSettings;
      listChecklistResponse.forEach((checklistResponse, index) => {
        const chgRecord = listChgRecord[index];
        let ordChecklist = checklistResponse;

        for (let checkSetting of checkSettings) {
          // チェック表示項目数
          let checkString = "checklist_" + checkSetting.list_cd.toString();
          // チェック済み項目数
          let checkStringChecked = checkString + "_chkcount";
          chgRecord[checkStringChecked] = ordChecklist[checkSetting.list_cd][0];
          // チェック項目数
          let checkStringTotal = checkString + "_count";
          chgRecord[checkStringTotal] = ordChecklist[checkSetting.list_cd][1];

          chgRecord[checkString] =
            ordChecklist[checkSetting.list_cd][0] +
            "/" +
            ordChecklist[checkSetting.list_cd][1];
        }

        // 実績にチェックリストコードが登録されている場合
        // mod FNSI-４００エラー対応 周 start
        // if (ordChecklist[0][0] !== null) {
        //   // チェックリストコード
        //   chgRecord.checklistCd = ordChecklist[0][0];
        // }
        chgRecord.checklistCd = ordChecklist[0][0] === null ? 0 : ordChecklist[0][0];
        // mod FNSI-４００エラー対応 周 end

        if (this.getIsDataLoadCancel) {
          // ページ切り替えなどでデータ読み込みの中断があった
          return;
        }

        // データ更新
        list.splice(index, 1, chgRecord);

        // 取得したord_main情報をセット
        this.getOrdMainList = list;
      });
      // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 start
      this.setIsAsynComplete(true);
      // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 end
    },
    /**
     * ベッド名の背景色変更
     */
    dialysisStateBackColor(dataItem) {
      if (
        dataItem.rstDialysisState == dialysisState.afterSendCondition ||
        dataItem.rstDialysisState == dialysisState.checkedSendCondition
      ) {
        // 背景色変更
        // 条件送信済み
        return "td-send-condition";
      } else if (dataItem.rstDialysisState == dialysisState.dialysis) {
        // 治療中
        return "td-dialysis";
      } else if (
        dataItem.rstDialysisState == dialysisState.afterDialysis ||
        dataItem.rstDialysisState == dialysisState.afterWeight
      ) {
        // 治療終了
        return "td-after-dialysis";
      } else if (dataItem.rstDialysisState == dialysisState.afterPastRecord) {
        // 実績確定
        return "td-after-record";
      }

      return "td-not-send-condition";
    },
    /**
     * 進捗バー表示スタイル
     */
    progressBackgroundColor(column, dataItem) {
      if (column.field === "medicine") {
        // 実施済み項目の幅
        let width = dataItem.medi_count
          ? (100 / dataItem.medi_count) * dataItem.medi_chkcount
          : 0;
        let color = "var(--check-list-progress-incomplete)";

        // 実施済み項目がある場合
        if (dataItem.medi_chkcount > 0) {
          // 全て実施済みの場合
          if (dataItem.medi_count === dataItem.medi_chkcount) {
            color = "var(--check-list-progress-complete)";
          }
          return `background: linear-gradient(to right,${color} ${width}%, rgba(0,0,0,0) 0%)`;
        }
      } else if (column.field.startsWith("checklist_")) {
        const strCheck = column.field;
        const strCount = strCheck + "_count";
        const strCheckCount = strCheck + "_chkcount";

        // 実施済み項目の幅
        let width = (100 / dataItem[strCount]) * dataItem[strCheckCount];
        let color = "var(--check-list-progress-incomplete)";

        // チェック済み項目がある場合
        if (dataItem[strCheckCount] > 0) {
          // 全てチェック済みの場合
          if (dataItem[strCount] === dataItem[strCheckCount]) {
            color = "var(--check-list-progress-complete)";
          }
          return `background: linear-gradient(to right,${color} ${width}%, rgba(0,0,0,0) 0%)`;
        }
      }
    },
    // 検索条件が変更されたら表示内容を更新
    filteredCheckList() {
      // 治療日列の表示/非表示
      let colSetting = this.getChecklistColumn;
      let dateIndex = colSetting.findIndex(p => p.field === "viewTreatDate");
      if (dateIndex >= 0) {
        colSetting[dateIndex].hidden = !this.condition.viewTreatDate;
        this.setChecklistColumn(colSetting);
      }
      // 自動更新の有無
      if (this.condition.isAutoReload) {
        this.startPolling();
      } else {
        this.endPolling();
      }
    },
    // add FNSI-redmine_#3908_ソート方法の改善 周 start
    columnResizeEvevt (event) {
      if (event?.end === false) {
        return;
      }
      if (event.column.field === "bedName") {
        this.setChecklistColumnHeaderWidth({
          selectedFontSize: this.selectedFontSize,
          width: event.newWidth
        });
      } else {
        this.setChecklistColumnWidth({
          field: event.column.field,
          selectedFontSize: this.selectedFontSize,
          width: event.newWidth
        });
      }
    },
    // add FNSI-redmine_#3908_ソート方法の改善 周 end
    startPolling() {
      // add 5984 機能帳票でパラメータが正しく渡されていない 歴 start
      const funcCd = getCurrentFunctionCd();
      if (funcCd) {
        store.dispatch("report/getMstReport", {funcCd: funcCd,printFlag: 0,autoRefreshFlag:true});
      }
      // add 5984 機能帳票でパラメータが正しく渡されていない 歴 end
      this.endPolling();
      if (this.condition.isAutoReload) {
        this.autoReload = setInterval(() => {
          this.setCheckList(true)
        }, this.getReloadInterval * 60 * 1000);
      }
    },
    endPolling() {
      clearInterval(this.autoReload);
    },
    /**
     * ベッドのクリック
     */
    onClickBed(src) {
      const selOrdNo = src.ordNo;
      const selPatId = src.patId;
      // 治療状況
      const selRstDialysisState = src.rstDialysisState;
      // 治療中の次患者または条件送信済み患者の場合
      // かつ？？？？患者でない場合
      if (
        ((selRstDialysisState === dialysisState.beforeSendCondition &&
          this.getIsDisplayTreatingMode) ||
          selRstDialysisState === dialysisState.afterSendCondition ||
          selRstDialysisState === dialysisState.checkedSendCondition) &&
        selPatId !== null
      ) {
        // 患者選択リストに格納
        this.updateTreatmentPatList(this.CheckListToPatList);
        // 機能コード設定、選択 ord_no を保持
        this.setOrdNoForSideBarRecord(selOrdNo);
        this.setSrcFuncName(this.$route.name);

        // ordNoセット
        this.sendConditionSetSelectOrdNo({
          ordNo: selOrdNo,
          ordNo2: null
        }).then(() => {
          // 条件送信画面へ遷移
          this.goSpecifiedView("send-condition");
        });
      } else if (
        Number(selRstDialysisState) > Number(dialysisState.checkedSendCondition)
      ) {
        // 患者選択リストに格納
        this.updateTreatmentPatList(this.CheckListToPatList);
        // 機能コード設定、選択 ord_no を保持
        this.setOrdNoForSideBarRecord(selOrdNo);
        this.setSrcFuncName(this.$route.name);

        // 治療中以降の患者の場合
        this.setSelectedPatHeader(selPatId).then(() => {
          // ordNoセット
          this.$nextTick(() => {
            this.setTreatmentRecordOrdNo(selOrdNo);
            //add FNSI修正 治療記録画面バッグ 房 start
            this.setOrd({
              readOnly: false,
            });
            //add FNSI修正 治療記録画面バッグ 房 end
            // 治療記録画面へ遷移
            this.$router.push({ name: "treatment-record" });
          });
        });
      }
    },
    // グリッドクリック時
    onClick(src, column) {
      // add 5984 機能帳票でパラメータが正しく渡されていない 歴 start
      const funcCd = getCurrentFunctionCd();
      if (funcCd) {
        store.dispatch("report/getMstReport", {funcCd: funcCd,printFlag: 1});
      }
      // add 5984 機能帳票でパラメータが正しく渡されていない 歴 end
      const selOrdNo = src.ordNo;
      // 患者ID
      const selPatId = src.patId;
      // 治療状況
      const selRstDialysisState = src.rstDialysisState;

      // 患者名列の場合
      if (column.field === "patName") {
        if (selPatId === null) {
          // ？？？患者の場合
          // 名前割り当て画面へ遷移
          // 選択されたord_noの情報をセット
          this.scheduleAssignmentSetSelectOrdNo(selOrdNo).then(() => {
            // スケジュール・名前割り当てモーダル画面表示
            // mod FNSI-？？？？患者割り当てtitle名不正 陳 start
            // mod FNSI-？？？？患者割り当てtitle名不正 付 start
            // this.showSubModals(this.showSchedule);
            // this.showSubModals(this.showSchedule({title :"スケジュール割り当て"}));
            // FNSI-チェックリスト画面表示を修正 周 mod start
            // this.showSubModals(this.showSchedule({title :"？？？？患者治療割り当て"}));
            this.showSubModals(this.showSchedule, {title :"？？？？患者治療割り当て"});
            // FNSI-チェックリスト画面表示を修正 周 mod end
            // mod FNSI-？？？？患者割り当てtitle名不正 付 end
            // mod FNSI-？？？？患者割り当てtitle名不正 陳 end
          });
        } else if (
          selRstDialysisState === dialysisState.beforeSendCondition &&
          this.getIsDisplayTreatingMode
        ) {
          // 治療中モードの次患者の場合

          // 患者選択リストに格納
          this.updateTreatmentPatList(this.CheckListToPatList);
          // 機能コード設定、選択 ord_no を保持
          this.setOrdNoForSideBarRecord(selOrdNo);
          this.setSrcFuncName(this.$route.name);

          // ordNoセット
          this.sendConditionSetSelectOrdNo({
            ordNo: selOrdNo,
            ordNo2: null
          }).then(() => {
            // 条件送信画面へ遷移
            this.goSpecifiedView("send-condition");
          });
        } else if (
          Number(selRstDialysisState) >
          Number(dialysisState.beforeSendCondition)
        ) {
          // 条件送信以降
          // 患者選択リストに格納
          this.updateTreatmentPatList(this.CheckListToPatList);
          // 機能コード設定、選択 ord_no を保持
          this.setOrdNoForSideBarRecord(selOrdNo);
          this.setSrcFuncName(this.$route.name);

          // 条件送信以降の患者の場合
          this.setSelectedPatHeader(selPatId).then(() => {
            // ordNoセット
            this.$nextTick(() => {
              this.setTreatmentRecordOrdNo(selOrdNo);
              //add FNSI修正 治療記録画面バッグ 房 start
              this.setOrd({
                readOnly: false,
              });
              //add FNSI修正 治療記録画面バッグ 房 end
              // 治療記録画面へ遷移
              this.$router.push({ name: "treatment-record" });
            });
          });
        }
      } else if (column.field === "medicine") {
        // 投与薬剤列の場合
        // 選択されたord_noの情報をセット
        this.setSelectOrdNo(selOrdNo).then(() => {
          // 投与薬剤モーダル画面表示
          this.showSubModals(this.showMedicine);
        });
      } else if (column.field.startsWith("checklist_")) {
        // チェックリスト列の場合
        const listCd = column.code;
        const checklistCd = src.checklistCd;

        // 選択されたord_noとlist_cdの情報をセット
        this.setSelectCheckList({
          ordNo: selOrdNo,
          listCd: listCd,
          checklistCd: checklistCd
        });

        // 選択されたlist_cdのチェックリストマスタのlist_name取得
        this.getChecklistName(listCd).then(listName => {
          // チェックリストモーダル画面表示
          this.showSubModals(this.showChecklist, listName);
        });
      }
    },
    /**
     * ？？？？患者割当後の治療記録画面への遷移
     */
    moveTreatmentRecord(params) {
      this.setSelectedPatHeader(params.patId).then(() => {
        // ordNoセット
        this.$nextTick(() => {
          this.setTreatmentRecordOrdNo(params.ordNo);
          //add FNSI修正 治療記録画面バッグ 房 start
          this.setOrd({
            readOnly: false,
          });
          //add FNSI修正 治療記録画面バッグ 房 end
          // 治療記録画面へ遷移
          this.$router.push({ name: "treatment-record" });
        });
      });
    },
    /**
     * @param {function} callModalFunction コールバック関数
     * @param {any} arg コールバック関数の引数
     */
    showSubModals(callModalFunction, arg) {
      this.endPolling();
      callModalFunction(arg);
    },
    requestrReportParams(param) {
      // 機能コード判定
      if ( param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {

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
        // del #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy start
        // if(this.getStorSimlpSearchQurey.kurNames && this.getStorSimlpSearchQurey.kurNames.length > 0) {
        //   kurNames = this.getStorSimlpSearchQurey.kurNames.join("・");
        // } else {
        //   kurNames = "すべて";
        // }
        // del #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy end
        let patGroups = null;
        if(this.getStorSimlpSearchQurey.selectedPatGroupNames) {
          patGroups = this.getStorSimlpSearchQurey.selectedPatGroupNames;
        } else {
          patGroups = "すべて";
        }
        this.bedCdListString = JSON.parse(getScopedSessionStorage(this.$el || this).getItem('roomBedGroupNameCheckList')) || [];
        // add #11285 機能帳票の印刷情報対応② 高 end
        // 機能一致

        // 印刷パラメータを応答
        // add 5984 機能帳票でパラメータが正しく渡されていない 歴 start
        if (this.getSelectOrdMainMedimodal == null && this.getSelectOrdMainModal == null) {
          let treatdDte = null;
          // 治療中の場合
          if (this.getIsDisplayTreatingMode === true) {
            treatdDte = Date.now();
            // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy start
            kurNames = JSON.parse(getScopedSessionStorage(this.$el || this).getItem('kurGroupNameStatusList'));
            // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy end
          } else {
            treatdDte = this.condition.treatDate;
            // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy start
            kurNames = JSON.parse(getScopedSessionStorage(this.$el || this).getItem('kurGroupNameStatusList')) || "すべて";
            // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy end
          }
          // add 5984 機能帳票でパラメータが正しく渡されていない 歴 end
          const param = {
            // add 画面印刷プレビューと印刷の実現 黄 start
            // del #9558 機能帳票で正しく変数が引き渡されていない 2024/06/13 高　start
            // patId: this.selectedPatId,
            // del #9558 機能帳票で正しく変数が引き渡されていない 2024/06/13 高　end
            patIds: this.getListDataSource.map(({ patId }) => patId),
            ordNos: this.getListDataSource.map(({ ordNo }) => ordNo),
            // add 画面印刷プレビューと印刷の実現 黄 end
            facilityCd: this.getFacilityCd,
            // add 5984 機能帳票でパラメータが正しく渡されていない 歴 start
            functionCd: "01501",
            // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
            // mod #9558 機能帳票で正しく変数が引き渡されていない 2024/06/13 高　start
            // bedCds: this.getListDataSource.map(({ bedCd }) => bedCd),
            bedCds: this.getListDataSource.map(({ bedCd }) => bedCd),
            // mod #9558 機能帳票で正しく変数が引き渡されていない 2024/06/13 高　end
            // mod #11285 機能帳票の印刷情報対応② 高 start
            // bedCdListString:this.getStorSimlpSearchQurey.selectedBedGName,
            bedCdListString:this.bedCdListString,
            // mod #11285 機能帳票の印刷情報対応② 高 end
            // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
            // add 5984 機能帳票でパラメータが正しく渡されていない 歴 end
            // mod 5984 機能帳票でパラメータが正しく渡されていない 歴 start
            // date: dayjs(treatdDte).format("YYYY/MM/DD"),
            // fromDate: dayjs(treatdDte).format("YYYY/MM/DD"),
            // toDate: dayjs(treatdDte).format("YYYY/MM/DD")
            date: dayjs(treatdDte).format("YYYYMMDD"),
            fromDate: dayjs(treatdDte).format("YYYYMMDD"),
            toDate: dayjs(treatdDte).format("YYYYMMDD"),
            // add #11285 機能帳票の印刷情報対応② 高 start
            treatDate:this.getStorSimlpSearchQurey.treatDate,
            freeWord:this.getStorSimlpSearchQurey.freeWord,
            expressCondCdStr:expressCondCd,
            kurNames:kurNames,
            patGroups:patGroups,
            // add #11285 機能帳票の印刷情報対応② 高 end
            // mod 5984 機能帳票でパラメータが正しく渡されていない 歴 end
          };
          EventBus.$emit("sendReportParams", param);
        // add 5984 機能帳票でパラメータが正しく渡されていない 歴 start
        } else {
          if (this.getSelectOrdMainMedimodal !== null){
            const param = {
              functionCd: "01501",
              // add #11968 iPadで治療記録画面の機能帳票表示に失敗する 高　start
              facilityCd: this.getFacilityCd,
              // add #11968 iPadで治療記録画面の機能帳票表示に失敗する 高　end
              patId: this.getSelectOrdMainMedimodal.patId,
              bedCd: this.getSelectOrdMainMedimodal.bedCd,
              date: dayjs(this.getSelectOrdMainMedimodal.treatDate).format("YYYYMMDD"),
              fromDate: dayjs(this.getSelectOrdMainMedimodal.treatDate).format("YYYYMMDD"),
              toDate: dayjs(this.getSelectOrdMainMedimodal.treatDate).format("YYYYMMDD")
            };
            EventBus.$emit("sendReportParams", param);
          }

          if (this.getSelectOrdMainModal !== null){
            const param = {
              functionCd: "01501",
              // add #11968 iPadで治療記録画面の機能帳票表示に失敗する 高　start
              facilityCd: this.getFacilityCd,
              // add #11968 iPadで治療記録画面の機能帳票表示に失敗する 高　end
              patId: this.getSelectOrdMainModal.patId,
              bedCd: this.getSelectOrdMainModal.bedCd,
              date: dayjs(this.getSelectOrdMainModal.treatDate).format("YYYYMMDD"),
              fromDate: dayjs(this.getSelectOrdMainModal.treatDate).format("YYYYMMDD"),
              toDate: dayjs(this.getSelectOrdMainModal.treatDate).format("YYYYMMDD")
            };
            EventBus.$emit("sendReportParams", param);
          }
        }
        // add 5984 機能帳票でパラメータが正しく渡されていない 歴 end
      }
    },
    addCustomClass() {
      const $grid = this.getGridWidget();
      const that = this;
      const gridRoot = this.getGridRootEl();
      const gridTbody = this.getGridTbodyEl();
      if (!$grid || !gridRoot || !gridTbody) {
        return;
      }
      $(gridTbody).find("tr").each(function() {
        const uid = this.getAttribute("data-uid");
        const rows = uid ? Array.from(gridRoot?.querySelectorAll?.(`[data-uid="${uid}"]`) || []) : [this];
        const scrollRow = rows.find(row => row.closest(".k-grid-content")) || this;
        const rowData = $grid?.dataItem?.(scrollRow) || that.$refs.grid?.gridDataItem?.(scrollRow) || null;
        if (!rowData) {
          return;
        }
        rows.forEach(targetRow => {
          if (!targetRow.closest(".k-grid-content")) {
            return;
          }
          const cells = targetRow.querySelectorAll("td");
          cells.forEach((cell) => {
            const field = that.getDirectGridFieldByCell(cell);
            if (!field) {
              return;
            }
            const style = that.progressBackgroundColor({field}, rowData);
            if (style && style != null) {
              const styleSplit = style.split(':');
              cell.style.cssText = `${styleSplit[0]} : ${styleSplit[1]}`;
            }
            if (field == 'patName' && rowData['inOutClass'] == 1) {
              // mod FNSI-横展開 入院患者名の配布_チェックリスト機能分 周 start
              // cell?.classList?.add("change-color-patient");
              cell?.classList?.add("pat-name-in-hospital");
              // mod FNSI-横展開 入院患者名の配布_チェックリスト機能分 周 end
            }
            // del FNSI-入院患者名の配布表示を修正 周 start
            // // add FNSI-横展開 入院患者名の配布_チェックリスト機能分 周 start
            // if (field == 'patName' && rowData['isSame'] == 1 && cell.lastChild.tagName !== "IMG") {
            //   var img = new Image();
            //   img.src = require('../../assets/name_duplication.png');
            //   img.className = "pat-name-same-icon";
            //   cell.appendChild(img);
            // }
            // // add FNSI-横展開 入院患者名の配布_チェックリスト機能分 周 end
            // del FNSI-入院患者名の配布表示を修正 周 end
          });
        });
      });
    },
    onCellClick(event) {
      event.preventDefault();

      const grid = event?.sender || this.getGridWidget();
      if (!grid) {
        return;
      }
      const selected = grid.select?.();
      const selectedCell = selected?.closest?.("td")?.[0] || selected?.[0] || null;
      const selectedRow = selectedCell?.closest?.("tr") || selected?.closest?.("tr")?.[0] || null;
      if (!selectedRow) {
        return;
      }
      const selectedRowData = grid.dataItem?.(selectedRow) || this.$refs.grid?.gridDataItem?.(selectedRow) || null;
      if (!selectedRowData) {
        return;
      }
      const field = this.getDirectGridFieldByCell(selectedCell);
      if (!field) {
        return;
      }
      let columnCode = null;

      if (field.startsWith("checklist_")) {
        columnCode = this.getChecklistColumn.find(col => col.field === field)?.code || null;
      }
      if (field == 'bedName') {
        this.onClickBed(selectedRowData);
      } else {
        this.onClick(selectedRowData, {field, code: columnCode});
      }
      this.$nextTick(() => {
        this.clearGridSelection();
        this.applyBedDialysisStateColors();
      });
    },
    clearGridScrollSync() {
      (this.gridScrollSyncCleanup || []).forEach((cleanup) => {
        try {
          cleanup();
        } catch (_error) {
          // noop
        }
      });
      this.gridScrollSyncCleanup = [];
    },
    gridSetting(){
      this.$nextTick(() => {
        requestAnimationFrame(() => {
          this.addCustomClass();
          this.applyBedDialysisStateColors();
        });
      });
      const lockedContent = this.getGridLockedContentEl();
      const scrollableContent = this.getGridContentEl();
      this.clearGridScrollSync();
      if (!lockedContent || !scrollableContent) return;

      // Grid高さの調整
      this.$nextTick(() => {
        this.calculateGridHeight();
        const headerHeight = (this.getGridHeaderEl()?.offsetHeight || 0) + 2;
        const gridContent = this.getGridContentEl();
        if (!gridContent) {
          // Vue3ではKendo Grid本体DOMの生成がVue2より遅れる場合があるため、DOM生成前は次回同期に委ねる。
          return;
        }
        const isHorizontalScroll = gridContent.scrollWidth > gridContent.clientWidth;
        let lockRowHeight = this.kendoGridHeight - headerHeight;
        // PCでの表示時のみ、スクロールバー分の不要な高さが発生する為、高さの調整を行う
        if (!this.androidFlg && !this.iosFlg && isHorizontalScroll) {
          lockRowHeight -= 17;
        }
        if (lockedContent) {
          lockedContent.style.height = lockRowHeight + "px";
        }
        // ヘッダーにスタイル適用
        const gridHeaderEl = this.getGridHeaderEl();
        if (gridHeaderEl) {
          gridHeaderEl.style.backgroundColor = "var(--ntss-list-header-background-color)";
          if (gridHeaderEl.firstElementChild) {
            gridHeaderEl.firstElementChild.style.borderColor = "var(--ntss-base-background-color)";
          }
        }
        // 慣性スクロール用のクラスを追加
        const gridScrollEl = this.getGridAutoScrollableEl();
        if (gridScrollEl) {
          gridScrollEl.style.WebkitOverflowScrolling = "touch";
        }
      });

      attachChecklistLockedContentScrollSync(this.$refs.grid?.gridWidget?.() || this.getGridRootEl?.() || this.$refs.grid?.$el, {
        cleanupList: this.gridScrollSyncCleanup,
        wheel: false,
      });

    },
    getGridColumnResize() {
      // columnResize prop と data-bound の gridSetting で十分。drag 中の二重 gridSetting はスクロール位置をリセットする。
    },
    /**
     * 列固定切り替え(印刷時)
     */
    changeLock(){
      this.lockFlg = !this.lockFlg;
    },
    clearGridSelection() {
      const grid = this.getGridWidget();
      grid?.clearSelection?.();

      const root = this.getGridRootEl();
      if (!root) {
        return;
      }

      root.querySelectorAll(
        ".k-grid-content .k-selected, .k-grid-content .k-state-selected, " +
        ".k-grid-content .k-focus, .k-grid-content-locked .k-selected, " +
        ".k-grid-content-locked .k-state-selected, .k-grid-content-locked .k-focus, " +
        ".k-grid-content [aria-selected='true'], .k-grid-content-locked [aria-selected='true']"
      ).forEach(el => {
        el.classList.remove("k-selected", "k-state-selected", "k-focus");
        if (el.getAttribute?.("aria-selected") === "true") {
          el.removeAttribute("aria-selected");
        }
      });
    }
  },
  watch: {
    listDataSource() {
      this.$nextTick(() => this.initDirectGridIfReady());
    },
    getChecklistColumn() {
      this.$nextTick(() => this.initDirectGridIfReady());
    },
    windowHeight() {
      this.calculateGridHeight();
    },
    windowWidth() {
      this.calculateGridHeight();
    },
    isDispMenu() {
      this.calculateGridHeight();
    },
    getFontSize() {
      this.calculateGridHeight();
    },
    getIsDisplayTreatingMode() {
      this.$nextTick(() => {
        this.calculateGridHeight();
      });
    },
    // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 start
    getIsAsynComplete(value) {
      if (value) {
        this.$nextTick(() => {
          this.listDataSource = createChecklistDataSource({
            data: this.getListDataSource
          });
          this.initDirectGridIfReady();
          // FNSI-修正 #5407 xie add start
          this.setLoadingScreenVisible(false);
          // FNSI-修正 #5407 xie add end
        });
      }
    },
    // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 end
    condition() {
      this.$nextTick(() => {
        this.calculateGridHeight();
      });
    }
  },
  created() {
    // FNSI-修正 #5407 xie add start
    this.setLoadingScreenMessage("処理中・・・");
    //FNSI-修正 #5407 xie add end
    const ua = ((this?.$el?.ownerDocument?.defaultView?.navigator?.userAgent) || globalThis?.navigator?.userAgent || "").toLowerCase();
    if (/android/.test(ua)) {
      this.androidFlg = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.iosFlg = true;
    }
    // add 性能改善メモリ不足 shan start
    EventBus.$off("filterCheckList", this.setFilterCondition);
    EventBus.$off("dataUpdate", this.setCheckList);
    EventBus.$off("refresh", this.setCheckList);
    EventBus.$off("closeModal", this.startPolling);
    EventBus.$off("requestReportParams", this.requestrReportParams);
    EventBus.$off("ScheduleAssignment", this.moveTreatmentRecord);
    // add 性能改善メモリ不足 shan end

    EventBus.$on("filterCheckList", this.setFilterCondition);
    EventBus.$on("dataUpdate", this.setCheckList);
    EventBus.$on("refresh", this.setCheckList);
    // 印刷パラメータ要求
    EventBus.$on("requestReportParams", this.requestrReportParams);

    // スケジュール割当後の治療記録への遷移
    EventBus.$on("ScheduleAssignment", this.moveTreatmentRecord);

    // 画面名称取得
    this.selfScreenName = this.$route.name;

    // del FNSI-横展開 表示条件のサインイン内保持_チェックリスト機能分 周 start
    // let today = dayjs(new Date());
    // this.condition.treatDate = today.format("YYYY-MM-DD");
    // // 抽出条件セット
    // this.setCondition(this.condition);
    // // 初期表示を治療中にセット
    // this.changeIsDisplayTreatingMode(true);
    // del FNSI-横展開 表示条件のサインイン内保持_チェックリスト機能分 周 end

  },
  async mounted() {
    this.closeModalHandler = () => {
      this.clearGridSelection();
      this.startPolling();
    };
    /* 自動更新サインアウトフラグ取得 */
    await initForceSignOutFlag("check-list/list/setForceSignOutFlag", CHECK_LIST_FORCE_SIGNOUT);
    // データ取得
    this.dataLoad();
    this.$nextTick(() => {
      this.calculateGridHeight();
    });
    this.getGridColumnResize();
    // Rootページのサイドバーボタン要素のイベントリスナー設定
    // ※「左サイドバー切り替えする時、画面の右スクロールバーの表示がおかしいについての修正」をリファクタ
    const rootSideBarBtn = this.getPatientSearchSidebarButton();
    rootSideBarBtn?.addEventListener('click', this.calculateGridHeight);
    EventBus.$on("print-start", this.changeLock);
    EventBus.$on("print-end", this.changeLock);
    EventBus.$on("closeModal", this.closeModalHandler);
  },
  beforeUnmount() {
    this.clearGridScrollSync();
    if (this.directGridLayoutRafId != null) {
      cancelAnimationFrame(this.directGridLayoutRafId);
      this.directGridLayoutRafId = null;
    }
    this.destroyDirectGrid();
    EventBus.$off("filterCheckList", this.setFilterCondition);
    EventBus.$off("dataUpdate", this.setCheckList);
    EventBus.$off("refresh", this.setCheckList);
    EventBus.$off("closeModal", this.closeModalHandler);
    EventBus.$off("print-start", this.changeLock);
    EventBus.$off("print-end", this.changeLock);
    // 印刷パラメータ要求
    EventBus.$off("requestReportParams", this.requestrReportParams);

    // スケジュール割当後の治療記録への遷移
    EventBus.$off("ScheduleAssignment", this.moveTreatmentRecord);

    this.setIsDataLoadCancel(true);
    this.setIsDataLoading(false);
    this.endPolling();

    // dataの初期化
    Object.assign(this.$data, this.$options.data());
    // Rootページのサイドバーボタン要素のイベントリスナー解除
    const rootSideBarBtn = this.getPatientSearchSidebarButton();
    rootSideBarBtn?.removeEventListener('click', this.calculateGridHeight);
  }
};
</script>
<style scoped>
.master-maintenance-page :deep(.k-grid .k-table-th),
.master-maintenance-page :deep(.k-grid .k-table-td),
.master-maintenance-page :deep(.k-grid th),
.master-maintenance-page :deep(.k-grid td) {
  padding: 0.28125rem 0.84375rem !important;
}
div :deep(.k-i-sort-asc-sm::before) {
  content: "▲" !important;
  color: #ffffff;
}

div :deep(.k-i-sort-desc-sm::before) {
  content: "▼" !important;
  color: #ffffff;
}
.check-list-main-content {
  flex: 1;
}

.k-grid :deep(.change-color-patient){
  /* mod FNSI-障害票一覧_チェックリスト#2。 周 start */
  /* color: mediumorchid; */
  color: purple;
  /* mod FNSI-障害票一覧_チェックリスト#2。 周 end */
}

.check-list-main-content-list :deep(td.k-selected),
.check-list-main-content-list :deep(td.k-state-selected),
.check-list-main-content-list :deep(td.k-focus),
.check-list-main-content-list :deep(.k-table-td.k-selected),
.check-list-main-content-list :deep(.k-table-td.k-state-selected),
.check-list-main-content-list :deep(.k-table-td.k-focus) {
  background-color: unset !important;
  color: inherit !important;
  box-shadow: none !important;
  outline: none !important;
}

.check-list-main-content-list :deep(td.k-selected:hover),
.check-list-main-content-list :deep(td.k-state-selected:hover),
.check-list-main-content-list :deep(td.k-focus:hover) {
  background-color: unset !important;
}

.check-list-main-content-list :deep(td.k-selected.td-not-send-condition),
.check-list-main-content-list :deep(td.k-state-selected.td-not-send-condition) {
  color: #050505 !important;
  background-color: white !important;
}

.check-list-main-content-list :deep(td.k-selected.td-send-condition),
.check-list-main-content-list :deep(td.k-state-selected.td-send-condition) {
  color: white !important;
  background-color: #42CB92 !important;
}

.check-list-main-content-list :deep(td.k-selected.td-dialysis),
.check-list-main-content-list :deep(td.k-state-selected.td-dialysis) {
  color: white !important;
  background-color: #2CA06F !important;
}

.check-list-main-content-list :deep(td.k-selected.td-after-dialysis),
.check-list-main-content-list :deep(td.k-state-selected.td-after-dialysis) {
  color: white !important;
  background-color: #557769 !important;
}

.check-list-main-content-list :deep(td.k-selected.td-after-record),
.check-list-main-content-list :deep(td.k-state-selected.td-after-record) {
  color: white !important;
  background-color: #808080 !important;
}

.check-list-main-content-list :deep(td.k-selected.pat-name-in-hospital),
.check-list-main-content-list :deep(td.k-state-selected.pat-name-in-hospital) {
  color: rgb(163, 86, 163) !important;
}

.master-maintenance-page :deep(.k-grid-header) {
  background: var(--ntss-list-header-background-color);
  background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,0.1) 100%);
}

#area_usage_guide {
  position: absolute;
  bottom: 0;
  width: 100%;
  padding-top: 3px;
  display: flex;
  flex-wrap: wrap;
  color: var(--ntss-list-body-color);
}

.usage-guide-div {
  margin-right: 1em;
  display: flex;
}

.usage-guide-element {
  width: 1em;
  height: 1em;
  margin-top: 0.2em;
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

:deep(.k-grid .k-table-th) {
  border-color: white !important;
}

@media print {
  /* 背景の高さ固定を解除 */
  .main-content-area
  ,.grid-area
  , .check-list-main-content-list
  ,.check-list-main-content-list :deep(.k-grid-content-locked)
  , .check-list-main-content-list :deep(.k-auto-scrollable){
    height: auto !important;
  }

  /* 各セルの横幅設定を削除 */
  .check-list-main-content-list :deep(colgroup){
    display: none;
  }

  /* 見切れ文字改行設定 */
  .check-list-main-content-list :deep(.k-grid-header th)
  ,  .check-list-main-content-list :deep(.k-grid-header th)
  ,  .check-list-main-content-list :deep(.k-grid-content td){
    white-space: normal;
    word-break: break-all;
  }

  /* テーブルの横幅をレスポンシブ化 */
  .check-list-main-content-list :deep(table){
    width: 100% !important;
  }

  /* テーブル内部の横幅を微調整 */
  .check-list-main-content-list :deep(.k-grid-content){
    width: calc(100% - 16px) !important;
  }

    /* テーブル内部の横幅を微調整 */
  .check-list-main-content-list :deep(.k-grid-content){
    width: calc(100% - 16px) !important;
  }

    /* 配置設定を修正 */
  .check-list-main-content-list, #area_usage_guide {
    position: static !important;
  }
}

:deep(.k-svg-icon) {
  width: 1em !important;
  height: 1em !important;
  -moz-osx-font-smoothing: grayscale;
  -webkit-font-smoothing: antialiased;
  font-size: 16px !important;
  font-family: "WebComponentsIcons";
  font-style: normal;
  font-variant: normal;
  font-weight: normal;
  line-height: 1 !important;
  text-transform: none;
  text-decoration: none;
  display: inline-block !important;
  vertical-align: middle;
  position: relative;
}

:deep(.k-svg-i-sort-asc-small svg),
:deep(.k-svg-i-sort-desc-small svg) {
  display: none !important;
}

:deep(.k-svg-i-sort-asc-small)::before {
  content: "▲" !important;;
  color: #ffffff;
  /* font-size: 12px; */
}

:deep(.k-svg-i-sort-desc-small)::before {
  content: "▼" !important;;
  color: #ffffff;
  /* font-size: 12px; */
}
:deep(.k-grid-content){
  background-color: inherit !important;
}
:deep(.k-table-td){
  box-sizing: border-box !important;
  height: 40px !important;
}
#kendo{
  height: 100% !important;
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
