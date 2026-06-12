/**
 * チェックリスト設定画面
 */
<template>
  <div class="main-content-area master-maintenance-page">
    <div class="mst-checklist-main-content-area">
      <div class="header-btn-area right" :class="{ 'mobile-header': isMobileDevice }">
        <div v-show="isMobileDevice" class="custom-switch-wrapper">
          <label class="fab-font-color">編集</label>
          <v-ons-switch modifier="outline" v-model="allowEdit" />
        </div>
        <v-ons-button
          modifier="outline"
          class="btn3-normal toolbar-btn"
          v-show="!isSortMode"
          @click="toRankEditBtnClick()"
        >並び順表示</v-ons-button>
        <v-ons-button
          modifier="outline"
          class="btn3-normal toolbar-btn"
          v-show="isSortMode"
          @click="sortBtnClick()"
        >反映</v-ons-button>
      </div>
      <div
        ref="mstChecklistGrid"
        :class="[fontSizeSet, 'ntss-kendo-grid-legacy', 'mst-checklist-direct-jq-grid']"
        :style="{ height: kendoGridHeight + 'px' }"
      ></div>
    </div>
    <div id="grid-footer" class="btn-area nowrap-block">
      <v-ons-row width="100%" v-show="!isSortMode">
        <v-ons-col width="50%">
          <v-ons-button class="btn2-cancel button denial-btn" style="width: auto;" v-show="!isSortMode" @click="cancel()">キャンセル</v-ons-button>
        </v-ons-col>
        <v-ons-col width="50%" class="right">
          <v-ons-button
            class="btn1-execute button registration-btn" style="width: auto;"
            v-show="!isSortMode"
            :disabled="isPreservation"
            @click="registration()"
          >保存</v-ons-button>
        </v-ons-col>
      </v-ons-row>
    </div>
  </div>
</template>

<script>
import { markRaw } from "@/compat/vue/runtime";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import kendo from "@progress/kendo-ui";
import $ from "jquery";
import { deepCopy } from "@/functions/common/CommonFunctions";
import { EventBus } from "@/compat/vue/event-bus.js";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
import { getScopedAlertDialogs, getScopedNumericTextBox, queryScopedSelector } from "@/functions/common/LayoutMeasureHelper";
import { bindGridEditorEnterToCloseCell } from "@/compat/kendo/grid-edit";

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
  data() {
    return {
      isSortMode: false,
      editingFlg: false,
      isAndroid: false,
      isIOS: false,
      scrollPosition: {
        top: 0,
        left: 0
      },
      //自画面の名称
      selfScreenName: "",
      kendoGridHeight: 300,
      // 選択中の施設コード
      facilitylistValue: "",
      isPreservation: true,
      MstChecklistColumn:"",
      errorMessage: "",
      getChecklistSettingOld: null,
      // add #11001 並び順の変更後反映を押しても並び順が切り替わらない。 linjunfeng start
      dispNoListCd: [],
      // add #11001 並び順の変更後反映を押しても並び順が切り替わらない。 linjunfeng end
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
      saveFlg: false,
      directGridWidget: null,
      directGridMounted: false,
      directGridDataSource: null,
      directGridLayoutRafId: null,
      directGridFilterRefreshRafId: null,
      directGridScrollSyncRafId: null,
      directGridDomStructureKey: null,
      suppressChecklistGridRefresh: false,
      directGridRowVisualRafIds: markRaw(new Map())
    };
  },
  computed: {
    ...mapGetters("master-maintenance", { getFacilitySwitch: "getFacilitySwitch" }),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize"
    }),
    ...mapGetters("mst-checklist", [
      "getChecklistSetting",
      "getMstChecklistColumn",
      "getChangeFlg",
      "getSchema"
    ]),
    ...mapGetters("user", ["getFacilityCd"]),
    fontSizeSet() {
      const names = ["small", "medium", "large", "x-large"];
      return `font-size-set-${names[this.getFontSize] || "medium"}`;
    },
    // 変更フラグ
    isChanged() {
      return this.getChangeFlg;
    },
    isMobileDevice() {
      return this.isIOS || this.isAndroid;
    },
  },
  watch: {
    getChecklistSetting () {
      this.getChecklistSetting && this.getChecklistSetting.forEach((item, index) => {
        item.funclist.forEach((ita, idx) => {
         this.getChecklistSettingOld && this.getChecklistSettingOld[index] ? this.getChecklistSettingOld[index].funclist[idx].chgflg = ita.chgflg : undefined
         this.getChecklistSettingOld && this.getChecklistSettingOld[index] ? this.getChecklistSettingOld[index].funclist[idx].chgflg_disp_no = ita.chgflg_disp_no : undefined
         this.getChecklistSettingOld && this.getChecklistSettingOld[index] ? this.getChecklistSettingOld[index].funclist[idx].chgflg_func_class = ita.chgflg_func_class : undefined
         this.getChecklistSettingOld && this.getChecklistSettingOld[index] ? this.getChecklistSettingOld[index].funclist[idx].chgflg_list_name = ita.chgflg_list_name : undefined
         this.getChecklistSettingOld && this.getChecklistSettingOld[index] ? this.getChecklistSettingOld[index].funclist[idx].chgflg_class_cd = ita.chgflg_class_cd : undefined
        })
        this.getChecklistSettingOld && this.getChecklistSettingOld[index] ? this.getChecklistSettingOld[index].dummy_disp_no = item.dummy_disp_no : undefined
        this.getChecklistSettingOld && this.getChecklistSettingOld[index] ? this.getChecklistSettingOld[index].chgflg = item.chgflg : undefined
        this.getChecklistSettingOld && this.getChecklistSettingOld[index] ? this.getChecklistSettingOld[index].chgflg_listname = item.chgflg_listname : undefined
      })
      if (this.getChecklistSettingOld && (JSON.stringify(this.getChecklistSetting) == JSON.stringify(this.getChecklistSettingOld))) {
        this.isPreservation = true;
      } else if (this.getChecklistSettingOld && (JSON.stringify(this.getChecklistSetting) != JSON.stringify(this.getChecklistSettingOld))) {
        this.isPreservation = false;
      }
      this.setisPreservation(this.isPreservation)
      // add #9539 チェックリストマスタの設定を変更して保存しても保存できない dengshen start
      this.getChecklistSetting && this.getChecklistSettingOld &&
      // add #9539 チェックリストマスタの設定を変更して保存しても保存できない dengshen end
      this.getChecklistSetting.forEach((item) => {
        const oldItem = this.getChecklistSettingOld?.find(old => old.list_cd === item.list_cd);
        if (!oldItem) {
          return;
        }
        if (this.isPreservation && item.chgflg !== undefined) {
          item.chgflg = false;
        }
        if (
          item.dialysis_prog_name == oldItem.dialysis_prog_name
          && item.list_name == oldItem.list_name
          && JSON.stringify(item.funclist) == JSON.stringify(oldItem.funclist)
        ) {
          item.chgflg = false;
        }
      });
      if (!this.suppressChecklistGridRefresh && !this.editingFlg) {
        this.scheduleDirectGridFilterRefresh();
      }
    },
    // getChangeFlg(val) {
    //   if(val) this.isPreservation = true;
    // },
    MstChecklistColumn(val) {
      this.$nextTick(() => {
        if (val) {
          this.setLoadingScreenVisible(false);
        }
        this.getChecklistSettingOld = deepCopy(this.getChecklistSetting);
        this.initDirectGridIfReady();
        this.scheduleDirectGridLayoutContract();
      });
    },
    // add redmine 5005 一覧画面で2重スクロールになる 孔 start
    windowHeight() {
      this.calculateGridHeight();
      this.scheduleDirectGridLayoutContract();
    },
    windowWidth() {
      this.calculateGridHeight();
      this.scheduleDirectGridLayoutContract();
    },
    isDispMenu() {
      this.calculateGridHeight();
      this.scheduleDirectGridLayoutContract();
    },
    getFontSize() {
      this.calculateGridHeight();
      this.scheduleDirectGridLayoutContract();
    },
    // add redmine 5005 一覧画面で2重スクロールになる 孔 end
  },
  methods: {
    ...mapActions("multi-modal", ["showChecklistEdit"]),
    ...mapActions("master-maintenance", ["setisPreservation"]),
    //DEL チェックリストマスタ データ種別に「投与薬剤」を「医療材料」の下の選択肢に追加する。 孔s start
    // ...mapActions("mst-checklist", [
    //   "setChangeFlg",
    //   "setMstCheckListColumn",
    //   "fetchMstEquipClassList",
    //   "fetchCheckSettingList",
    //   "setNewflg",
    //   "setEditChecklist",
    //   "mstChecklistSortData",
    //   "regChecklistSetting",
    //   "getDeviceEdgeNoList",
    //   "mstSyncDeviceEdge"
    // ]),
    //DEL チェックリストマスタ データ種別に「投与薬剤」を「医療材料」の下の選択肢に追加する。 孔s end
    //ADD チェックリストマスタ 1.データ種別に「投与薬剤」を「医療材料」の下の選択肢に追加する。2.工程、リスト名を一覧で修正可能とする 孔s start
    ...mapActions("mst-checklist", [
      "getDeviceEdgeNoListByFacilityCd",
      "setChangeFlg",
      "setMstCheckListColumn",
      "fetchMstEquipClassList",
      "fetchCheckSettingList",
      "setNewflg",
      "setEditChecklist",
      "mstChecklistSortData",
      "regChecklistSetting",
      "getDeviceEdgeNoList",
      "mstSyncDeviceEdge",
      "fetchMstMedicineClassList",
      "edit",
      "deleteOrdCheckList",
      "cleanCheckSettingList"
    ]),
    //ADD チェックリストマスタ 1.データ種別に「投与薬剤」を「医療材料」の下の選択肢に追加する。2.工程、リスト名を一覧で修正可能とする 孔s end
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount: "resetLoadingScreenVisibleCount"
    }),
    getCurrentRouteName() {
      return this.$router?.currentRoute?.value?.name || this.$router?.currentRoute?.name || this.$route?.name || "";
    },
    getGridRootEl() {
      return this.$refs.mstChecklistGrid || null;
    },
    getChecklistScopeRoot() {
      return this.getGridRootEl() || this.$el || null;
    },
    getChecklistTextBoxElement() {
      return queryScopedSelector('.k-input.k-textbox', this.getChecklistScopeRoot()) || null;
    },
    getChecklistNumericTextboxElement() {
      return getScopedNumericTextBox(this.getChecklistScopeRoot()) || null;
    },
    getDirectGridScrollContent() {
      return this.getGridRootEl()?.querySelector?.(".k-grid-content") || null;
    },
    getDirectGridLockedScrollContent() {
      return this.getGridRootEl()?.querySelector?.(".k-grid-content-locked") || null;
    },
    getGridWidget() {
      return this.directGridWidget || null;
    },
    getGridScrollPosition() {
      const content = this.getDirectGridScrollContent();
      return { top: content?.scrollTop || 0, left: content?.scrollLeft || 0 };
    },
    setGridScrollPosition(position = {}) {
      const content = this.getDirectGridScrollContent();
      if (!content) return;
      content.scrollTop = position.top || 0;
      content.scrollLeft = position.left || 0;
      this.syncDirectGridLockedScrollPosition(content.scrollTop);
      this.dispatchDirectGridContentScroll();
    },
    restoreDirectGridScrollPosition() {
      const top = this.scrollPosition.top || 0;
      const left = this.scrollPosition.left || 0;
      const content = this.getDirectGridScrollContent();
      if (!content) return;
      content.scrollTop = top;
      content.scrollLeft = left;
      this.syncDirectGridLockedScrollPosition(top);
      this.dispatchDirectGridContentScroll();
    },
    dispatchDirectGridContentScroll() {
      const content = this.getDirectGridScrollContent();
      if (!content) return;
      try {
        content.dispatchEvent(new Event("scroll", { bubbles: true }));
      } catch (_error) {}
      try {
        $(content).trigger("scroll");
      } catch (_error) {}
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
    getDirectGridColumnStructureKey() {
      return (this.getMstChecklistColumn || []).map(column => `${column.field}:${column.hidden ? 1 : 0}`).join("|");
    },
    createDirectGridDataSource() {
      this.directGridDataSource = markRaw(new kendo.data.DataSource({
        data: this.getChecklistSetting || [],
        schema: {
          model: {
            fields: this.getSchema
          }
        }
      }));
      return this.directGridDataSource;
    },
    buildDirectGridColumns() {
      return (this.getMstChecklistColumn || []).map(category => {
        const gridColumn = { ...category };
        if (category.title === "詳細") {
          gridColumn.attributes = { class: "btn3-kendo-normal" };
          gridColumn.command = { text: "詳細", click: event => this.onClick(event) };
          delete gridColumn.values;
        }
        return gridColumn;
      });
    },
    initDirectGridIfReady() {
      const root = this.getGridRootEl();
      if (!this.directGridMounted || !root || !Array.isArray(this.getMstChecklistColumn) || this.getMstChecklistColumn.length === 0) return;
      if (this.directGridWidget) {
        this.applyDirectGridColumnsContract();
        this.scheduleDirectGridFilterRefresh();
        this.scheduleDirectGridLayoutContract();
        return;
      }
      installComponentJQuery();
      $(root).empty();
      $(root).kendoGrid({
        dataSource: this.createDirectGridDataSource(),
        editable: true,
        selectable: "row",
        scrollable: true,
        height: this.kendoGridHeight,
        beforeEdit: event => this.editStart(event),
        cellClose: event => this.editEnd(event),
        edit: event => this.addInputAssist(event),
        save: event => this.onSave(event),
        dataBound: event => this.onDirectGridDataBound(event),
        columns: this.buildDirectGridColumns()
      });
      this.directGridWidget = markRaw($(root).data("kendoGrid"));
      this.installDirectGridFacade();
      this.directGridDomStructureKey = null;
      this.applyDirectGridDomClassContract();
      this.applyDirectGridScrollLayoutContract();
      this.scheduleDirectGridLayoutContract();
    },
    destroyDirectGrid() {
      if (this.directGridWidget) {
        try { this.directGridWidget.destroy(); } catch (_error) {}
      }
      const root = this.getGridRootEl();
      if (root) $(root).empty();
      this.directGridWidget = null;
      this.directGridDataSource = null;
      this.directGridDomStructureKey = null;
    },
    installDirectGridFacade() {
      const root = this.getGridRootEl();
      if (!root) return;
      root.kendoWidget = () => this.directGridWidget;
      root.gridWidget = () => this.directGridWidget;
      root.gridRootEl = () => root;
      root.gridDataItem = row => this.directGridWidget?.dataItem?.(row);
      root.gridContentEl = () => this.getDirectGridScrollContent();
      root.gridAutoScrollableEl = () => this.getDirectGridScrollContent();
      root.gridLockedContentEl = () => this.getDirectGridLockedScrollContent();
      root.scrollGridTo = position => this.setGridScrollPosition(position);
    },
    applyDirectGridColumnsContract() {
      const grid = this.directGridWidget;
      if (!grid) return;
      const before = (grid.columns || []).map(column => `${column.field}:${column.hidden ? 1 : 0}`).join("|");
      const after = this.getDirectGridColumnStructureKey();
      if (before !== after) {
        this.scrollPosition = this.getGridScrollPosition();
        grid.setOptions({ columns: this.buildDirectGridColumns() });
        this.directGridDomStructureKey = null;
        this.$nextTick(() => {
          this.applyDirectGridDomClassContract();
          this.scheduleDirectGridPostColumnScrollSync();
          this.scheduleChecklistRowVisualRefresh();
        });
      }
    },
    scheduleDirectGridFilterRefresh() {
      if (this.editingFlg || !this.directGridWidget?.dataSource) return;
      if (this.directGridFilterRefreshRafId != null) cancelAnimationFrame(this.directGridFilterRefreshRafId);
      this.directGridFilterRefreshRafId = requestAnimationFrame(() => {
        this.directGridFilterRefreshRafId = null;
        this.refreshDirectGridDataFromStore(false);
      });
    },
    refreshDirectGridDataFromStore(resetScroll = false) {
      const grid = this.directGridWidget;
      if (!grid?.dataSource) return;
      grid.dataSource.data(this.getChecklistSetting || []);
      if (resetScroll) this.setGridScrollPosition({ top: 0, left: 0 });
      this.$nextTick(() => {
        if (!this.editingFlg) {
          this.editBackgroundColor();
        }
      });
    },
    applyDirectGridLockedWidthContract() {
      const root = this.getGridRootEl();
      if (!root) return;
      const lockedWidth = (this.getMstChecklistColumn || []).reduce((sum, column) => {
        if (!column.locked || column.hidden) return sum;
        const width = `${column.width || ""}`.trim();
        if (width.endsWith("em")) {
          const fontSize = parseFloat(getComputedStyle(root).fontSize || "16") || 16;
          return sum + parseFloat(width) * fontSize;
        }
        if (width.endsWith("px")) return sum + parseFloat(width);
        const numeric = parseFloat(width);
        return sum + (Number.isFinite(numeric) ? numeric : 0);
      }, 0);
      if (!lockedWidth) return;
      const px = `${Math.ceil(lockedWidth)}px`;
      root.querySelectorAll(
        ".k-grid-header-locked,.k-grid-content-locked,.k-grid-header-locked table,.k-grid-content-locked table"
      ).forEach(element => {
        element.style.width = px;
        element.style.minWidth = px;
      });
    },
    applyDirectGridLockedHeightContract() {
      const content = this.getDirectGridScrollContent();
      const locked = this.getDirectGridLockedScrollContent();
      if (!content || !locked) return;
      locked.style.height = `${content.clientHeight}px`;
      locked.style.maxHeight = `${content.clientHeight}px`;
    },
    syncDirectGridLockedScrollPosition(scrollTop = null) {
      const locked = this.getDirectGridLockedScrollContent();
      if (!locked) return;
      const content = this.getDirectGridScrollContent();
      locked.scrollTop = scrollTop !== null && scrollTop !== undefined ? scrollTop : (content?.scrollTop || 0);
    },
    applyDirectGridDomClassContract() {
      const root = this.getGridRootEl();
      if (!root) return;
      root.classList.add("ntss-kendo-grid-legacy", "k-widget", "k-grid", "k-editable", "k-display-block");
      const structureKey = this.getDirectGridColumnStructureKey();
      if (this.directGridDomStructureKey !== structureKey) {
        root.querySelectorAll("th").forEach(th => th.classList.add("k-header"));
        this.directGridDomStructureKey = structureKey;
      }
      [".k-grid-content tbody tr", ".k-grid-content-locked tbody tr"].forEach(selector => {
        root.querySelectorAll(selector).forEach((tr, index) => {
          tr.classList.add("k-master-row");
          tr.classList.toggle("k-alt", index % 2 === 1);
        });
      });
      root.querySelectorAll(".k-grid-content tbody td, .k-grid-content-locked tbody td").forEach(td => td.classList.add("k-td", "k-table-td"));
    },
    applyDirectGridScrollLayoutContract() {
      this.applyDirectGridLockedWidthContract();
      this.applyDirectGridLockedHeightContract();
      this.syncDirectGridLockedScrollPosition();
    },
    scheduleDirectGridLayoutContract() {
      if (this.directGridLayoutRafId != null) cancelAnimationFrame(this.directGridLayoutRafId);
      this.directGridLayoutRafId = requestAnimationFrame(() => {
        this.directGridLayoutRafId = null;
        this.resizeDirectGrid();
        this.applyDirectGridScrollLayoutContract();
      });
    },
    resizeDirectGrid() {
      const grid = this.directGridWidget;
      if (!grid) return;
      try {
        grid.setOptions({ height: this.kendoGridHeight });
        grid.resize(true);
      } catch (_error) {}
    },
    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      if (this.editingFlg) return;
      const wh = Number(this.windowHeight) || window.innerHeight || 0;
      const header = document.getElementsByClassName("header");
      const headerHeight = header?.length ? header[header.length - 1].clientHeight : 0;
      const footerMenu = document.getElementById("footer-menu");
      const footerMenuHeight = (this.isDispMenu === 1 && footerMenu ? footerMenu.clientHeight : 0) + 5;
      const toolbar = document.querySelector(".mst-checklist-main-content-area .header-btn-area");
      const toolbarHeight = toolbar ? toolbar.clientHeight : 0;
      const gridFooter = document.getElementById("grid-footer");
      const gridFooterHeight = gridFooter ? gridFooter.clientHeight : 0;
      this.kendoGridHeight = Math.max(160, wh - headerHeight - footerMenuHeight - toolbarHeight - gridFooterHeight - 1);
    },
    loadData() {
      // mod マスタ一覧 1･施設切替を可能とする 孔 this.getFacilityCd => this.facilitylistValue start
      // 医療材料マスタ情報取得
      return this.fetchMstEquipClassList(this.facilitylistValue).then(async() => {
        //ADD チェックリストマスタ データ種別に「投与薬剤」を「医療材料」の下の選択肢に追加する。 孔s start
        await this.fetchMstMedicineClassList(this.facilitylistValue);
        //ADD チェックリストマスタ データ種別に「投与薬剤」を「医療材料」の下の選択肢に追加する。 孔s end
        // チェックリスト設定情報取得
        await this.fetchCheckSettingList(this.facilitylistValue);

        this.getChecklistSettingOld = deepCopy(this.getChecklistSetting);
        this.MstChecklistColumn = this.getMstChecklistColumn;
        this.setLoadingScreenVisible(false);
      }).catch(() => {
        this.setLoadingScreenVisible(false);
      });
      // mod マスタ一覧 1･施設切替を可能とする 孔 this.getFacilityCd => this.facilitylistValue end
    },
    // 背景色セット
    editBackgroundColor() {
      if (this.editingFlg) {
        return;
      }
      if (this.directGridRowVisualRafIds.has("edit-background")) {
        cancelAnimationFrame(this.directGridRowVisualRafIds.get("edit-background"));
      }
      const rafId = requestAnimationFrame(() => {
        this.directGridRowVisualRafIds.delete("edit-background");
        this.paintChecklistEditBackgroundColor();
      });
      this.directGridRowVisualRafIds.set("edit-background", rafId);
    },
    scheduleChecklistRowVisualRefresh() {
      if (this.directGridRowVisualRafIds.has("row-visual-refresh")) {
        cancelAnimationFrame(this.directGridRowVisualRafIds.get("row-visual-refresh"));
      }
      const rafId = requestAnimationFrame(() => {
        requestAnimationFrame(() => {
          this.directGridRowVisualRafIds.delete("row-visual-refresh");
          if (!this.editingFlg) {
            this.editBackgroundColor();
          }
        });
      });
      this.directGridRowVisualRafIds.set("row-visual-refresh", rafId);
    },
    paintChecklistEditBackgroundColor() {
      const root = this.getGridRootEl();
      const grid = this.directGridWidget;
      const checklistSettings = this.getChecklistSetting;
      if (!root || !grid || !Array.isArray(checklistSettings) || checklistSettings.length === 0) {
        return;
      }
      root.querySelector(".k-grid-header")?.classList?.add("master-grid-header");
      const rows = Array.from(root.querySelectorAll(".k-grid-content tbody tr[data-uid]"));
      const lockedRows = Array.from(root.querySelectorAll(".k-grid-content-locked tbody tr[data-uid]"));
      const lockedRowByUid = new Map();
      lockedRows.forEach(lockedRow => {
        const uid = lockedRow.getAttribute("data-uid");
        if (uid) lockedRowByUid.set(uid, lockedRow);
      });
      rows.forEach((row, index) => {
        const rowData = grid.dataItem(row);
        if (!rowData) {
          return;
        }
        const currentTrc = row.children;
        const rowUid = row.getAttribute("data-uid");
        const lockedRow = (rowUid && lockedRowByUid.get(rowUid)) || lockedRows[index] || null;
        let edited = rowData.chgflg_dispno;
        !this.isPreservation && this.changeDispCellColor(row, lockedRow, edited, rowData.list_cd);
        edited = rowData.chgflg;
        !this.isPreservation && this.changeRowColor(currentTrc, lockedRow, edited);
        if (!this.isPreservation && edited) {
          this.getChecklistGridCell(row, lockedRow, "disp_no")
            ?.classList?.remove("master-edited-row");
          this.getChecklistGridCell(row, lockedRow, "dummy_disp_no")
            ?.classList?.remove("master-edited-row");
        }
        !this.isPreservation && this.changeCellFont(row, lockedRow, rowData);
      });
    },
    isEditRow(currentTd) {
      if (!currentTd) {
        return false;
      }
      return currentTd.classList.contains("k-dirty-cell")
        || currentTd.classList.contains("k-edit-cell");
    },
    //ADD チェックリストマスタ 工程名の左のセルのセル色を変更する。 孔s START
    // changeDispCellColor(currentTrc, edited) {
    // #11001 並び順の変更後反映を押しても並び順が切り替わらない。 linjunfeng start
    // changeDispCellColor(currentTrc, edited,currentFrontTrc) {
    changeDispCellColor(row, lockedRow, edited, listCd) {
    // #11001 並び順の変更後反映を押しても並び順が切り替わらない。 linjunfeng end
    //ADD チェックリストマスタ 工程名の左のセルのセル色を変更する。 孔s END
      const noCell = this.getChecklistGridCell(row, lockedRow, "disp_no");
      const dummyCell = this.getChecklistGridCell(row, lockedRow, "dummy_disp_no");
      // 並び順が変更されていれば並び順とダミー項目背景色を変更0
      // #11001 並び順の変更後反映を押しても並び順が切り替わらない。 linjunfeng start
      // 並び順の黄色はユーザーが並び順の値を変更した行のみ（dispNoListCd）。
      // chgflg_dispno / k-dirty-cell は工程変更や未変更の失焦でも立つため使わない。
      const shouldHighlight = listCd != null && this.dispNoListCd.includes(listCd);
      // #11001 並び順の変更後反映を押しても並び順が切り替わらない。 linjunfeng end
      if (shouldHighlight) {
        noCell?.classList?.add("master-sort-edited");
        dummyCell?.classList?.add("master-sort-edited");
        //ADD チェックリストマスタ 工程名の左のセルのセル色を変更する。 孔s START
        lockedRow?.classList?.add("master-sort-edited");
        //ADD チェックリストマスタ 工程名の左のセルのセル色を変更する。 孔s END
      } else {
        noCell?.classList?.remove("master-sort-edited");
        dummyCell?.classList?.remove("master-sort-edited");
        lockedRow?.classList?.remove("master-sort-edited");
      }
    },
    changeRowColor(currentTrc, lockedRow, edited) {
      const addClass = "master-edited-row";
      const toggleCell = cell => {
        if (!cell) return;
        cell.classList.toggle(addClass, !!edited);
      };
      Array.from(lockedRow?.children || []).forEach(toggleCell);
      Array.from(currentTrc || []).forEach(toggleCell);
    },
    getChecklistGridCell(row, lockedRow, fieldName) {
      const column = (this.getMstChecklistColumn || []).find(item => item.field === fieldName && !item.hidden);
      if (!column) {
        return null;
      }
      const targetRow = column.locked ? lockedRow : row;
      if (!targetRow) {
        return null;
      }
      const sectionColumns = (this.getMstChecklistColumn || []).filter(item => !item.hidden && !!item.locked === !!column.locked);
      const columnIndex = sectionColumns.findIndex(item => item.field === fieldName);
      if (columnIndex < 0) {
        return null;
      }
      const cells = Array.from(targetRow.children || []);
      return cells.find(cell => {
        const ariaIndex = Number(cell.getAttribute("aria-colindex")) - 1;
        const effectiveIndex = Number.isFinite(ariaIndex) ? ariaIndex : cells.indexOf(cell);
        return effectiveIndex === columnIndex;
      }) || cells[columnIndex] || null;
    },
    changeCellFont(row, lockedRow, data) {
      const addClass = "master-edited-cell";
      const progCell = this.getChecklistGridCell(row, lockedRow, "dialysis_prog_cd");
      const listCell = this.getChecklistGridCell(row, lockedRow, "list_name");
      progCell?.classList.toggle(addClass, !!data.chgflg_progcd);
      listCell?.classList.toggle(addClass, !!data.chgflg_listname);
    },
    getColumnIndex(fieldName) {
      // 指定された項目がない場合はマイナスが返る
      return this.getMstChecklistColumn.findIndex(e => e.field === fieldName);
    },
    // グリッドクリック時
    onClick(event) {
      this.scrollPosition = this.getGridScrollPosition();
      if (!this.isSortMode) {
        event.preventDefault();
        const targetRow = event.currentTarget.closest("tr");
        const selRow = this.directGridWidget?.dataItem?.(targetRow);
        if (!selRow) return;
        const selectedRowIndex = this.getChecklistSetting.findIndex(e => e.list_cd === selRow.list_cd);
        this.setEditChecklist(selectedRowIndex);
        this.showChecklistEdit("チェックリストマスタ詳細");
      }
    },
    onCloseMasterEditModal() {
      this.$nextTick(() => {
        this.setScrollPosition(this.scrollPosition);
      });
      // Androidでスクロール位置が戻らない場合があるのでもう一度設定
      setTimeout(() => {
        this.setScrollPosition(this.scrollPosition);
      }, 1000);
    },
    setScrollPosition(position) {
      this.setGridScrollPosition(position);
    },
    onSave(ev) {
      this.scrollPosition = this.getGridScrollPosition();
      const editedField = Object.keys(ev.values)[0];
      //ADD チェックリストマスタ 工程、リスト名を一覧で修正可能とする 孔s START
      if (editedField !== "disp_no") {
          this.editingFlg = false;
          this.suppressChecklistGridRefresh = true;
          this.edit({ editRecord: ev.model, isSortMode: false, value: ev.values });
          if (ev.model.operation === 1) {
            ev.model.edited = true;
          }
          this.mstChecklistSortData(this.getChecklistSetting);
          this.suppressChecklistGridRefresh = false;
          this.refreshDirectGridDataFromStore(false);
      // add #11001 並び順の変更後反映を押しても並び順が切り替わらない。 linjunfeng start
      } else {
        const newValue = ev.values.disp_no;
        const oldValue = ev.model.disp_no;
        if (oldValue == newValue) {
          this.clearDispNoCellDirtyState(ev);
          this.$nextTick(() => this.editBackgroundColor());
          return;
        }
        const baselineItem = this.getChecklistSettingOld?.find(old => old.list_cd === ev.model.list_cd);
        const baselineValue = baselineItem?.disp_no;
        if (newValue != baselineValue) {
          if (!this.dispNoListCd.includes(ev.model.list_cd)) {
            this.dispNoListCd.push(ev.model.list_cd);
          }
          this.isPreservation = false;
        } else {
          const idx = this.dispNoListCd.indexOf(ev.model.list_cd);
          if (idx >= 0) {
            this.dispNoListCd.splice(idx, 1);
          }
        }
        this.$nextTick(() => this.editBackgroundColor());
      }
      // add #11001 並び順の変更後反映を押しても並び順が切り替わらない。 linjunfeng end
      //ADD チェックリストマスタ 工程、リスト名を一覧で修正可能とする 孔s END
    },
    onDirectGridDataBound(event) {
      this.installDirectGridFacade();
      this.applyDirectGridDomClassContract();
      this.applyDirectGridScrollLayoutContract();
      this.onDataBoundKendoGrid(event);
    },
    onDataBoundKendoGrid() {
      if (this.scrollPosition.top > 0 || this.scrollPosition.left > 0) {
        this.$nextTick(() => this.restoreDirectGridScrollPosition());
      }
    },
    // 並び順表示
    toRankEditBtnClick() {
      this.isSortMode = true;
      this.showSortColumn();
    },
    showSortColumn() {
      this.scrollPosition = this.getGridScrollPosition();
      // 並び順列の表示/非表示
      let colSetting = this.getMstChecklistColumn;
      colSetting[0].hidden = this.isSortMode;
      colSetting[1].hidden = !this.isSortMode;
      this.setMstCheckListColumn(colSetting);
      //ADD チェックリストマスタ 工程、リスト名を一覧で修正可能とする 孔s START
      if (this.isSortMode) {
        this.disableColumns();
      } else {
        this.editableColumns();
      }
      //ADD チェックリストマスタ 工程、リスト名を一覧で修正可能とする 孔s END
      this.$nextTick(() => {
        this.calculateGridHeight();
        this.applyDirectGridColumnsContract();
        this.scheduleDirectGridLayoutContract();
        this.scheduleDirectGridPostColumnScrollSync();
        this.scheduleChecklistRowVisualRefresh();
      });
    },
    // 反映
    sortBtnClick() {
      // グリッドデータ取得
      const gridData = this.directGridWidget?.dataSource?.data?.();
      const plainData = typeof gridData?.toJSON === "function" ? gridData.toJSON() : Array.from(gridData || []);
      this.mstChecklistSortData(plainData);
      this.isSortMode = false;
      this.refreshDirectGridDataFromStore(false);
      this.showSortColumn();
    },
    //ADD チェックリストマスタ 工程、リスト名を一覧で修正可能とする 孔s START
    editableColumns() {
      this.getMstChecklistColumn.forEach(column => {
        // 編集可否の設定を初期表示時の状態に戻す
        column.editable =
          column.field == "disp_no"
            ? () => false
            : () => true;
      });
    },
    disableColumns() {
      this.getMstChecklistColumn.forEach(column => {
        // 並び順列を編集可、並び順列以外を編集不可に。
        column.editable =
          column.field == "disp_no"
            ? () => true
            : () => false;
      });
    },
    //ADD チェックリストマスタ 工程、リスト名を一覧で修正可能とする 孔s END
    // マスタ同期
    syncMaster() {
      this.setLoadingScreenVisible(true);
      // mod マスタ一覧 1･施設切替を可能とする 孔 getDeviceEdgeNoList => getDeviceEdgeNoListByFacilityCd
      // this.getDeviceEdgeNoList().then(res => {
      this.getDeviceEdgeNoListByFacilityCd(this.facilitylistValue).then(res => {
        let array = res.data;
        if (array && array.length > 0) {
          array = array.sort((a,b) => {
            if (a.deviceEdgeNo < b.deviceEdgeNo) return -1;

            if (a.deviceEdgeNo > b.deviceEdgeNo) return 1;

            return 0;
          })
          this.synchroMstToDeviceEdge(array, 0);
        }else {
          /* mod #8666 by zhangruixue 2023-05-24 -- start */
          this.resetLoadingScreenVisibleCount();
          let title = messageFormat(DIALOG_MESSAGES['00100009'].title, 'チェックリストマスタ');
          this.$ons.notification.alert({
            title: title,
            message: 'mst_device_edgeテーブルの中にデータをクエリーできない',
          });
          /* mod #8666 by zhangruixue 2023-05-24 -- end */
        }
      })
    },
    // 指定したデバイスエッジとのマスタ同期
    synchroMstToDeviceEdge(list, idx) {
      // mod #6107 2023/04/04 メッセージボックス全調整 林峻峰 start
      // let title = "チェックリストマスタ同期";
      let title = messageFormat(DIALOG_MESSAGES['00100009'].title, 'チェックリストマスタ');
      // mod #6107 2023/04/04 メッセージボックス全調整 林峻峰 end
      const infos = list;
      if (infos.length <= idx) {
        return;
      }
      const info = infos[idx];
      let name = "デバイスエッジ：" + this.errorMessage + "</br></br>";

      // マスタ同期
      this.mstSyncDeviceEdge({
        // facilityCd: this.getFacilityCd,
        facilityCd: this.facilitylistValue,
        deviceEdgeNo: info.deviceEdgeNo
      })
          /* upd EOL対応内部 #6976 by ztc 2023-07-08 --start */
        .then((rep) => {
          if(rep.data.isSuccess){
            if (infos.length === idx + 1) {
              name = "デバイスエッジ：" + this.errorMessage + "</br></br>";
              // 共通ローダー：表示終了
              this.setLoadingScreenVisible(false);
              if (this.errorMessage === "") {
                this.$ons.notification.alert({
                  title: title,
                  // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                  // message: "マスタ同期が完了しました。"
                  message: messageFormat(DIALOG_MESSAGES['00100009'].message),
                  // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
                });
              } else {
                this.$ons.notification.alert({
                  title: title,
                  // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                  // message:
                  //   name +
                  //   "との同期に失敗しました。<br>デバイスエッジの装置と整合性が<br>取れていないので<br>再度「保存」を行ってください。"
                  message: messageFormat(DIALOG_MESSAGES[12000320].message, name),
                  // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
                });
                this.errorMessage = "";
              }
              this.setLoadingScreenVisible(false);
            } else {
              // 次のデバイスエッジ
              this.synchroMstToDeviceEdge(list, idx + 1);
            }
            // add 8344【デグレ】チェックリストマスタの保存までが長い zhao start
            if(list.length === (idx+1)){
              this.refresh();
            }
            // add 8344【デグレ】チェックリストマスタの保存までが長い zhao end
          }else {
            if (this.errorMessage === "") {
              this.errorMessage += "</br>" + info.deviceName + "</br>";
            } else {
              this.errorMessage += info.deviceName + "</br>";
            }
            this.synchroMstToDeviceEdge(list, idx + 1);
            // add 8344【デグレ】チェックリストマスタの保存までが長い zhao start
            if(list.length === (idx+1)){
              this.refresh();
            }
            // add 8344【デグレ】チェックリストマスタの保存までが長い zhao end
            if (infos.length === idx + 1) {
              getErrorMessage('MstChecklistMainComponent.vue', 'synchroMstToDeviceEdge', name +'との同期に失敗しました。デバイスエッジの装置と整合性が取れていないので再度「保存」を行ってください。');
              name = "デバイスエッジ：" + this.errorMessage + "</br></br>";
              // 共通ローダー：表示終了
              this.$ons.notification.alert({
                title: title,
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // message:
                //   name +
                //   "との同期に失敗しました。<br>デバイスエッジの装置と整合性が<br>取れていないので<br>再度「保存」を行ってください。"
                message: messageFormat(DIALOG_MESSAGES[12000320].message, name),
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              });
              this.errorMessage = "";
              this.setLoadingScreenVisible(false);
            }
          }
          setTimeout(() => {
            this.saveFlg = false;
          }, 1500);
        })
        .catch(error => {
          getErrorMessage('MstChecklistMainComponent.vue', 'synchroMstToDeviceEdge', error);
          return error;
          // if (this.errorMessage === "") {
          //   this.errorMessage += "</br>" + info.deviceName + "</br>";
          // } else {
          //   this.errorMessage += info.deviceName + "</br>";
          // }
          // this.synchroMstToDeviceEdge(list, idx + 1);
          // // add 8344【デグレ】チェックリストマスタの保存までが長い zhao start
          // if(list.length === (idx+1)){
          //     this.refresh();
          // }
          // // add 8344【デグレ】チェックリストマスタの保存までが長い zhao end
          // if (infos.length === idx + 1) {
          //   if (error.response.status === 400) {
          //     getErrorMessage('MstChecklistMainComponent.vue', 'synchroMstToDeviceEdge', name +'との同期に失敗しました。デバイスエッジの装置と整合性が取れていないので再度「保存」を行ってください。');
          //
          //     name = "デバイスエッジ：" + this.errorMessage + "</br></br>";
          //     // 共通ローダー：表示終了
          //     this.$ons.notification.alert({
          //       title: title,
          //       // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          //       // message:
          //       //   name +
          //       //   "との同期に失敗しました。<br>デバイスエッジの装置と整合性が<br>取れていないので<br>再度「保存」を行ってください。"
          //       message: messageFormat(DIALOG_MESSAGES[12000320].message, name),
          //       // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          //     });
          //     this.errorMessage = "";
          //     this.setLoadingScreenVisible(false);
          //   } else {
          //     getErrorMessage('MstChecklistMainComponent.vue', 'synchroMstToDeviceEdge', error);
          //   }
          // }
          /* upd EOL対応内部 #6976 by ztc 2023-07-08 --end */
        });
    },
    // チェックリスト設定登録
    // mod #7783 2022-07-13 チェックリストマスタを保存するとWebAppサーバーがダウンする。 dou start
    // registration() {
    //   // 共通ローダー:表示開始
    //   this.setLoadingScreenVisible(true);
    //   // チェックリストマスタ設定登録
    //   this.regChecklistSetting().then(async res => {
    async registration() {
      //イベント発生前のスクロールバーの位置を保持
      const { top: scrollTop, left: scrollLeft } = this.getGridScrollPosition();
      this.scrollPosition.top = scrollTop;
      this.scrollPosition.left = scrollLeft;
      this.saveFlg = true;
      // 共通ローダー:表示開始
      await this.setLoadingScreenVisible(true);
      // チェックリストマスタ 未入力チェックがない start zhao
      let messageflag=false;
      const regSetting = deepCopy(this.getChecklistSetting);
      for (let i=0;i<regSetting.length;i++){
          let listName = regSetting[i].list_name
          if(!listName){
            messageflag=true
          }
        }
        if(messageflag){
          this.setLoadingScreenVisible(false);
          this.$ons.notification.alert({
          title: DIALOG_MESSAGES['00200100'].title,
          message: messageFormat(DIALOG_MESSAGES['00200100'].message),
          });
          // チェックリストマスタ 未入力チェックがない zhao start
          return;
          // チェックリストマスタ 未入力チェックがない zhao end
        }
      // チェックリストマスタ 未入力チェックがない end zhao
      // チェックリストマスタ設定登録
      await this.regChecklistSetting().then(async res => {
        // mod #7783 2022-07-13 チェックリストマスタを保存するとWebAppサーバーがダウンする。 dou end
        if (res === true) {
          //共通ローダー：表示終了
          // del #8344 【デグレ】チェックリストマスタの保存までが長い dou start
          // this.setLoadingScreenVisible(false);
          // del #8344 【デグレ】チェックリストマスタの保存までが長い dou end

          // ADD チェックリストマスタ 指示変更、実績変更に伴うチェックリストの反映 孔 START
          // mod マスタ一覧 1･施設切替を可能とする 孔 this.getFacilityCd => this.facilitylistValue start
          // this.deleteOrdCheckList(this.getFacilityCd);
          // mod 8344【デグレ】チェックリストマスタの保存までが長い zhao start
          // this.deleteOrdCheckList(this.facilitylistValue);
          // del 8344【デグレ】チェックリストマスタの保存までが長い dou start
          // await this.deleteOrdCheckList(this.facilitylistValue);
          // del 8344【デグレ】チェックリストマスタの保存までが長い dou end
          // mod 8344【デグレ】チェックリストマスタの保存までが長い zhao end
          // mod マスタ一覧 1･施設切替を可能とする 孔 this.getFacilityCd => this.facilitylistValue end
          // ADD チェックリストマスタ 指示変更、実績変更に伴うチェックリストの反映 孔 END
          // 登録成功
          // this.$ons.notification.alert({
          //   title: "設定完了",
          //   message: "チェックリスト設定を更新しました"
          // });
          // マスタ画面へ戻る
          //this.$router.push({ name: "master-maintenance" });
          // マスタ同期
          await this.syncMaster();
          // リロード
          this.refresh();
        } else {
          //共通ローダー：表示終了
          this.setLoadingScreenVisible(false);

          // 登録失敗
          this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "登録失敗",
            // message: "チェックリスト設定の登録に失敗しました"
            title: DIALOG_MESSAGES['00200043'].title,
            message: messageFormat(DIALOG_MESSAGES['00200043'].message),
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          });
        }
      });
      // add #7783 2022-07-13 チェックリストマスタを保存するとWebAppサーバーがダウンする。 dou start
      await this.setLoadingScreenVisible(false);
      // add #7783 2022-07-13 チェックリストマスタを保存するとWebAppサーバーがダウンする。 dou end
    },
    /**
     * キャンセル
     */
    cancel() {
      // TODO: 編集破棄確認
      // this.$router.go(-1);
      this.$router.push({ name: "master-maintenance" });
    },
    editStart(e) {
      if (this.isMobileDevice && !this.allowEdit) {
        /* NOTE:
         * モバイル系は、スワイプ・フリック操作で入力パッドが表示される。
         * そのため、スクロール操作が損なわれるので、閲覧モードのときは
         * 後続のイベントを発火させないように制御する。
         */
        e.preventDefault();
        return;
      }
      this.editingFlg = true;
      // #9185 マウスが止まるとのtipsが現れました linjunfeng start
      this.$nextTick(()=>{
        const textBox = this.getChecklistTextBoxElement();
        if (textBox) {
          textBox.setAttribute('title', '');
        }
      })
      // #9185 マウスが止まるとのtipsが現れました linjunfeng end
    },
    editEnd() {
      this.editingFlg = false;
      if (this.isSortMode) {
        this.$nextTick(() => this.editBackgroundColor());
      }
    },
    clearDispNoCellDirtyState(ev) {
      const uid = ev?.model?.uid;
      const root = this.getGridRootEl();
      const row = uid
        ? root?.querySelector(`.k-grid-content tbody tr[data-uid="${uid}"]`)
        : ev?.container?.closest?.("tr[data-uid]") || null;
      const lockedRow = uid
        ? root?.querySelector(`.k-grid-content-locked tbody tr[data-uid="${uid}"]`)
        : null;
      [
        this.getChecklistGridCell(row, lockedRow, "disp_no"),
        this.getChecklistGridCell(row, lockedRow, "dummy_disp_no")
      ].forEach(cell => {
        cell?.classList?.remove("k-dirty-cell", "master-sort-edited");
        cell?.querySelectorAll?.(".k-dirty")?.forEach(element => element.remove());
      });
      lockedRow?.classList?.remove("master-sort-edited");
      if (ev?.model?.dirtyFields?.disp_no != null) {
        delete ev.model.dirtyFields.disp_no;
        if (Object.keys(ev.model.dirtyFields).length === 0) {
          ev.model.dirty = false;
        }
      }
    },
    addInputAssist(event) {
      bindGridEditorEnterToCloseCell(event?.sender || this.directGridWidget, event?.container);
      // iOS/PWA環境でスピナーをタップすると編集が終了してしまう現象の対策
      if (this.isIOS) {
        const numericTextbox = this.getChecklistNumericTextboxElement();
        const spinnerObj = numericTextbox?.getElementsByClassName?.("k-select")?.[0] || null;
        if (spinnerObj) {
          // 編集が終了するとオブジェクトが削除されるため、removeEvent処理は不要
          spinnerObj.ontouchend = event => event.stopPropagation();
        }
      }
    },
    loadGridData(){
      // 並べ替えクリア
      this.isSortMode = false;
      this.dispNoListCd = [];
      this.showSortColumn();
      // 変更フラグクリア
      this.setChangeFlg(false);
      // チェックリストマスタ情報取得
      this.loadData()?.finally?.(() => {
        this.$nextTick(() => {
          this.calculateGridHeight();
          this.initDirectGridIfReady();
          this.refreshDirectGridDataFromStore();
          this.scheduleDirectGridLayoutContract();
        });
      });
    },
    // パンくずリストをクリックされた場合に呼び出される関数
    refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      if (this.selfScreenName === this.getCurrentRouteName()
          && getScopedAlertDialogs(this.$el || this).length === 0) {
        if (this.isChanged) {
          this.$ons.notification.confirm({
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
            // title: "内容破棄",
            title: DIALOG_MESSAGES[13000004].title,
            // message: "編集内容が破棄されます。</br>よろしいですか？",
            message: messageFormat(DIALOG_MESSAGES[13000004].message),
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
            callback: answer => {
              if (answer === 1) {
                this.scrollPosition.top = 0;
                this.scrollPosition.left = 0;
                this.cleanCheckSettingList();
                this.loadGridData();
              }
            }
          });
        } else {
          if(!this.saveFlg){
            this.scrollPosition.top = 0;
            this.scrollPosition.left = 0;
          }
          this.cleanCheckSettingList();
          this.loadGridData();
        }
      }
    }
  },
  created() {
    this.setLoadingScreenVisible(true);
    // add マスタ一覧 1･施設切替を可能とする 孔 start
    this.cleanCheckSettingList();
    this.facilitylistValue = this.getFacilitySwitch;
    // add マスタ一覧 1･施設切替を可能とする 孔 end
    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    // 端末判別
    const ua = ((this?.$el?.ownerDocument?.defaultView?.navigator?.userAgent) || globalThis?.navigator?.userAgent || "").toLowerCase();
    if (/android/.test(ua)) {
      this.isAndroid = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.isIOS = true;
    }
    this.selfScreenName = this.getCurrentRouteName();
    EventBus.$on("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$on("refresh", this.refresh);
  },
  mounted() {
    this.directGridMounted = true;
    this.loadGridData();
  },
  // add 性能改善メモリ不足 shan start
  beforeUnmount() {
    EventBus.$off("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$off("refresh", this.refresh);
    [this.directGridLayoutRafId, this.directGridFilterRefreshRafId, this.directGridScrollSyncRafId].forEach(id => {
      if (id != null) cancelAnimationFrame(id);
    });
    this.directGridScrollSyncRafId = null;
    this.directGridRowVisualRafIds?.forEach?.(id => cancelAnimationFrame(id));
    this.directGridRowVisualRafIds?.clear?.();
    this.destroyDirectGrid();
  }
  // add 性能改善メモリ不足 shan end
};
</script>
<style scoped>
.btn-area {
  /* position: absolute; */
  display: flex;
  justify-content: space-between;
  left: 8px;
  bottom: 3px;
  flex-basis: 80%;
  padding: 5px 0;
}

.vertical-div {
  display: flex;
  flex-direction: column;
  align-content: flex-start;
}

.labelGroup {
  margin-left: auto;
  margin-right: auto;
  font-size: 1.5em;
  margin: 5px 10px;
  width: 230px;
  height: 20px;
  text-align: left;
}

.inputGroup {
  font-size: 1.5em;
  margin: 5px 10px;
  width: 120px;
  height: 25px;
  text-align: left;
}

.wrap-block {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
}
.nowrap-block {
  display: flex;
  flex-direction: row;
  flex-wrap: nowrap;
}
.right {
  text-align: right;
}
/* 並び順/反映ボタン */
.toolbar-btn {
  font-size: 1.0em;
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  width: auto;
  right: 0em;
}

/* キャンセルボタン */
#cancel-button {
  position: absolute;
  left: 0px;
  bottom: 0px;
  width: 160px;
  margin: 10px;
  background-color: crimson;
}

/* 登録ボタン */
#update-button {
  position: absolute;
  right: 10px;
  bottom: 0px;
  width: 160px;
  margin: 10px;
}

.hidden-item {
  display: none;
}

.mst-checklist-main-content-area :deep(.k-selectable) {
  box-shadow: 1px 0px 0px 0px white;
  border-right: 1px solid transparent;
}

.mst-checklist-main-content-area :deep(.k-grid-content-locked) {
  border-right: 0px solid transparent !important;
}

.mst-checklist-main-content-area :deep(.k-grid-header-locked) {
  border-right-width: 0px;
}
.custom-switch-wrapper {
  display: flex;
  float: left;
  align-items: center;
  min-width: 7em;
}
.custom-switch {
  transform: scale(0.85);
  transform-origin: center;
  touch-action: manipulation;
}
.mobile-header {
  min-height: 35px; /* モバイル用の高さ */
}

.mst-checklist-direct-jq-grid {
  width: 100%;
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
