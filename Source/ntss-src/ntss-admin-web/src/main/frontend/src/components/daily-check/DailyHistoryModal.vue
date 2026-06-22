<template>
  <div class="modal-mask custom-modal-mask daily-history-modal">
    <div class="modal-wrapper">
      <div class="modal-container">
        <!-- ヘッダ -->
        <div class="modal-header">
          <ons-toolbar>
            <div class="left toolbar__title">
              <span class="custom-h3">点検履歴</span>
            </div>
            <div class="right">
              <ons-toolbar-button class="close-btn print-none" @click="closeHistory">
                <ons-icon icon="fa-times"></ons-icon>
              </ons-toolbar-button>
            </div>
          </ons-toolbar>
        </div>

        <!-- メイン要素 -->
        <div class="modal-body">
          <div id="selectUnitArea" class="history-header-modal" style="overflow: auto;">
            <!-- 検索条件 -->
            <common-searcharea
              id="daily-history-condition-list"
              style="height: 5em; min-width: 200px; margin-top: 1px; max-height: 4.1em;"
              :conditionList="conditionList"
              @show-popover="showPopover"
            />

            <!-- 装置情報 -->
            <table class="ntss-list-detail">
              <tbody>
              <tr>
                <th class="list-header-th-center">ベッド</th>
                <th class="list-header-th-center">型式</th>
                <th class="list-header-th-center">製造番号</th>
                <th class="list-header-th-center">装置名1</th>
              </tr>
              <tr>
                <td class="ntss-list-body-td">{{ getMachine.bedName }}</td>
                <td class="ntss-list-body-td">{{ getMachine.machineType }}</td>
                <td class="ntss-list-body-td">{{ getMachine.machineSerial }}</td>
                <td class="ntss-list-body-td">{{ getMachine.machineName }}</td>
              </tr>
            
              </tbody>
            </table>
          </div>

          <div
            v-if="isDisplay"
            id="listArea"
            class="history-list-modal"
          >
            <div
              ref="historyGrid"
              class="tare-offwater daily-history-direct-grid"
            ></div>
          </div>
        </div>

        <!-- フッター -->
        <div class="modal-footer">
          <div class="flex-container">
            <div class="denial-btn-area">
              <button
                class="btn2-cancel button denial-btn"
                @click="closeHistory"
              >閉じる</button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <v-ons-popover
      cancelable
      v-model:visible="popoverVisible"
      :target="popoverTarget"
      direction="down"
      :cover-target="false"
      :class="fontSizeSet"
      style="width: auto;"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <div id="popover" style="margin: 10px;">
        <v-ons-row class="popover-row-style">
          <v-ons-col
            class="custom-ons-col"
            style="white-space: nowrap; margin-right: 0.5em;"
          >
            <div class="custom-line-height">
              <span class="dailyHistory-checkday-span">点検日:</span>
              <date-input
                type="date"
                id="input-search-date"
                class="hide-arrow-calendar search-history-date"
                max="9999-12-31"
                isRequired
                v-model="condition.inProgress.mainteDate"
              />
              <common-calendar
                class="history-date-comment"
                v-model="condition.inProgress.mainteDate"
              />
              <label> から</label>
            </div>
          </v-ons-col>
          <v-ons-col
            class="custom-ons-col"
            style="white-space: nowrap;"
          >
            <div class="custom-line-height">
              <label>過去 </label>
              <input
                type="number"
                class="distance-time"
                style="text-align: right;"
                min="1"
                max="99"
                v-model="condition.inProgress.numOfMonth"
                @change="inputValidValue"
                @mousewheel.prevent="stopScrollFun"
                @blur="handleBlur"
                @focus="handleFocus"
              />
              <label> か月</label>
            </div>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row>
          <v-ons-col width="30%" vertical-align="center">
            <div class="popover-label">
              <label
                style="align-content: center;"
                class="fab-font-color"
              >点検途中</label>
            </div>
          </v-ons-col>
          <v-ons-col width="30%" vertical-align="center">
            <v-ons-switch v-model="condition.inProgress.dailyRunning" />
          </v-ons-col>
        </v-ons-row>
        <v-ons-row>
          <v-ons-col width="30%" vertical-align="center">
            <div class="popover-label">
              <label
                style="align-content: center;"
                class="fab-font-color"
              >不合格</label>
            </div>
          </v-ons-col>
          <v-ons-col width="30%" vertical-align="center">
            <v-ons-switch v-model="condition.inProgress.dailyNotGood" />
          </v-ons-col>
        </v-ons-row>
        <v-ons-row>
          <v-ons-col width="30%" vertical-align="center">
            <div class="popover-label">
              <label
                style="align-content: center;"
                class="fab-font-color"
              >全件合格</label>
            </div>
          </v-ons-col>
          <v-ons-col width="30%" vertical-align="center">
            <v-ons-switch v-model="condition.inProgress.dailyGood" />
          </v-ons-col>
        </v-ons-row>
        <v-ons-row>
          <v-ons-col width="30%" vertical-align="center">
            <div class="popover-label">
              <label
                style="align-content: center;"
                class="fab-font-color"
              >未実施日</label>
            </div>
          </v-ons-col>
          <v-ons-col width="30%" vertical-align="center">
            <v-ons-switch v-model="condition.inProgress.notDailyDate" />
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row" style="margin: 0">
          <v-ons-col width="30%" vertical-align="center">
            <v-ons-button
              class="btn2-cancel"
              @click="dialogClear"
            >クリア</v-ons-button>
          </v-ons-col>
          <v-ons-col vertical-align="center"></v-ons-col>
          <v-ons-col width="30%" vertical-align="center">
            <v-ons-button
              class="btn1-execute"
              style="margin-bottom: 0;"
              @click="dialogOk"
            >OK</v-ons-button>
          </v-ons-col>
        </v-ons-row>
      </div>
    </v-ons-popover>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";
import commonSearchArea from "@/components/common/CommonSearchArea";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import dayjs from "@/compat/date/dayjs";

import PopoverMixin from "@/components/PopoverMixin";
import {
  popoverPreShow,
  popoverPostShow,
  popoverPosthide,
} from "@/functions/common/CommonPopoverFunctions";
import { alertByKey } from "@/functions/common/OnsenFunctions";
import { convertStatus } from "@/functions/DailyInspectionFunction";
import DateInput from "@/components/common/DateInput";
import {
  Answer,
  StatusText,
} from "@/constants/mainteConstants";
import { getCurrentFunctionCd } from "@/router/routing-helper";
import {
  getContentContainerElement,
  getScopedWindow,
  observeElementResize,
  resolveRefElement,
} from "@/functions/common/LayoutMeasureHelper";
import "@progress/kendo-ui";
import { restoreKendoGridScrollPosition } from "@/compat/kendo/grid-scroll.js";
import { markRaw } from "@/compat/vue/runtime";
import $ from "@/compat/jquery";
import PrintMixin from "@/components/PrintMixin";

const columnRowNameClass = { class: "deviceSetInfo-row-name" };
const columnRowNameHeaderClass = { class: "deviceSetInfo-header-row-name" };
const columnHeaderClass = { class: "deviceSetInfo-header-first-name" };
const columnHeaderSecendClass = { class: "deviceSetInfo-header-secound-name" };
const columnBodyClass = { class: "daily-history-grid-cell" };

export default {
  components: {
    "common-searcharea": commonSearchArea,
    "common-calendar": commonCalender,
    "date-input": DateInput,
  },
  mixins: [PopoverMixin, PrintMixin],
  data() {
    return {
      popoverVisible: false,
      popoverTarget: null,
      condition: {
        // 入力中の検索条件
        inProgress: createDefaultConditon(),
        // 検索に使用される条件
        inUsed: createDefaultConditon(),
      },
      isDisplay: true,
      localDataSource: {
        schema: {
          model: {
            id: "rowNum",
          },
        },
        data: [],
      },
      minValue: 1,
      maxValue: 99,
      focusFlg: false,
      columnRowNameClass,
      columnRowNameHeaderClass,
      columnHeaderClass,
      historyGridCleanup: [],
      historyGridWidget: null,
      historyGridColumnSignature: "",
      historyGridLayoutRafId: null,
      historyGridSyncRafId: null,
      historyGridSettingRafId: null,
      historyGridAppliedDataSource: null,
      parentModalResizeCleanup: null,
      scrollQuerySelector: ".k-grid-content",
      addClassTargetQuerySelector: [".k-grid-header-wrap table, .k-grid-content table"],
    };
  },
  computed: {
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("daily-check", [
      "getMachine",
      "getMachineResult",
      "getUserAccountInfo",
      "getResultMasterHis",
      "getLayoutParams",
      "getCondition",
      "getConditionForReportParams",
    ]),
    ...mapGetters("mst-holiday", ["getHolidays"]),
    ...mapGetters("account-edit", ["getFontSize"]),
    ...mapGetters("window-size", [
      "getWindowHeight",
      "getWindowWidth",
    ]),
    ...mapGetters("periodic-inspection", ["getStorSimlpSearchQurey"]),

    conditionList() {
      const conditionList = [];
      const layoutParams = this.getLayoutParams;
      if (!layoutParams) return conditionList;

      conditionList.push({
        text: dayjs(layoutParams.mainteDate).format("YYYY/MM/DD"),
      });
      conditionList.push({
        text: `過去${layoutParams.numOfMonth}か月`,
      });

      if (layoutParams.dailyRunning) {
        conditionList.push({ text: "点検途中" });
      }
      if (layoutParams.dailyNotGood) {
        conditionList.push({ text: "不合格" });
      }
      if (layoutParams.dailyGood) {
        conditionList.push({ text: "全件合格" });
      }
      if (layoutParams.notDailyDate) {
        conditionList.push({ text: "未実施日" });
      }

      return conditionList;
    },
    layoutList() {
      return this.getResultMasterHis.map((item, index) => ({
        columns: createMultiColumnInfo(item, index),
        title: item.layoutName,
        headerTemplate: `<span class="daily-history-layout-header">${item.layoutName}</span>`,
      }));
    },
  },
  methods: {
    ...mapActions("daily-check", [
      "setLayoutParams",
      "sendRequestGetDetailHistory",
      "sendRequestGetMachineResult",
      "setUserAccountInfo",
    ]),
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,

    showPopover(event) {
      // 入力値を初期化する
      Object.assign(this.condition.inProgress, this.condition.inUsed);
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
    handleEditable() {
      return false;
    },
    getHistoryGridRootEl() {
      const ref = this.$refs.historyGrid;
      if (ref?.nodeType === 1) {
        return ref;
      }
      return ref?.gridRootEl?.() || resolveRefElement(this, "historyGrid") || null;
    },
    getHistoryScrollableContentEl() {
      const root = this.getHistoryGridRootEl();
      return this.$refs.historyGrid?.gridAutoScrollableEl?.()
        || this.$refs.historyGrid?.gridContentEl?.()
        || root?.querySelector?.(".k-grid-content")
        || null;
    },
    getHistoryLockedContentEl() {
      const root = this.getHistoryGridRootEl();
      return this.$refs.historyGrid?.gridLockedContentEl?.()
        || root?.querySelector?.(".k-grid-content-locked")
        || null;
    },
    resetHistoryGridScrollTop() {
      const gridRoot = this.getHistoryGridRootEl();
      if (gridRoot) {
        restoreKendoGridScrollPosition(gridRoot, { top: 0, left: 0 });
      }
      const modalBody = this.getHistoryModalBodyEl();
      if (modalBody) {
        modalBody.scrollTop = 0;
      }
    },
    scheduleHistoryGridScrollReset() {
      const ownerWindow = this.$el?.ownerDocument?.defaultView || window;
      return new Promise((resolve) => {
        ownerWindow.requestAnimationFrame(() => {
          ownerWindow.requestAnimationFrame(() => {
            this.resetHistoryGridScrollTop();
            resolve();
          });
        });
      });
    },
    waitHistoryGridFrame() {
      const ownerWindow = this.$el?.ownerDocument?.defaultView || window;
      return new Promise(resolve => ownerWindow.requestAnimationFrame(() => resolve()));
    },
    async waitHistoryGridInitialRenderComplete() {
      // Vue2 は kendo-grid wrapper の dataBound/gridSetting が終わった状態で履歴画面が操作可能になる。
      // Vue3 direct jq では Grid 生成後の layout/paint が rAF 後に残るため、loading をここまで維持する。
      await this.$nextTick();
      await this.waitHistoryGridFrame();
      await this.$nextTick();
      await this.waitHistoryGridFrame();
      await this.$nextTick();
    },
    getHistoryHeaderEl() {
      const root = this.getHistoryGridRootEl();
      return this.$refs.historyGrid?.gridHeaderEl?.()
        || root?.querySelector?.(".k-grid-header-wrap")
        || root?.querySelector?.(".k-grid-header")
        || null;
    },
    getHistoryHeaderRootEl() {
      const root = this.getHistoryGridRootEl();
      return root?.querySelector?.(".k-grid-header") || null;
    },
    getHistoryHeaderWrapEl() {
      const root = this.getHistoryGridRootEl();
      return root?.querySelector?.(".k-grid-header-wrap") || null;
    },
    getHistoryLockedHeaderEl() {
      const root = this.getHistoryGridRootEl();
      return this.$refs.historyGrid?.gridLockedHeaderEl?.()
        || root?.querySelector?.(".k-grid-header-locked")
        || null;
    },
    getHistoryModalBodyEl() {
      return this.$el?.querySelector?.('.modal-body') || null;
    },
    getHistoryListAreaEl() {
      return this.$el?.querySelector?.('.history-list-modal') || null;
    },
    getHistoryFooterEl() {
      return this.$el?.querySelector?.('.modal-footer') || null;
    },
    getParentModalContainer() {
      return this.$el?.closest?.('.modal-container') || null;
    },
    installHistoryGridFacade() {
      const root = this.$refs.historyGrid;
      if (!root || root.nodeType !== 1) {
        return;
      }
      root.kendoWidget = () => this.historyGridWidget;
      root.gridWidget = () => this.historyGridWidget;
      root.gridRootEl = () => root;
      root.gridContentEl = () => root.querySelector(".k-grid-content");
      root.gridAutoScrollableEl = () => root.querySelector(".k-grid-content");
      root.gridLockedContentEl = () => root.querySelector(".k-grid-content-locked");
      root.gridHeaderEl = () => root.querySelector(".k-grid-header-wrap") || root.querySelector(".k-grid-header");
      root.gridLockedHeaderEl = () => root.querySelector(".k-grid-header-locked");
      root.refreshGrid = () => this.historyGridWidget?.refresh?.();
      root.requestGridResize = () => this.historyGridWidget?.resize?.(true);
    },
    buildHistoryGridColumns() {
      return [
        {
          field: "rowTitle",
          title: "点検項目<br>点検日1",
          width: 125,
          attributes: this.columnRowNameClass,
          headerAttributes: this.columnRowNameHeaderClass,
          editable: () => false,
          locked: true,
        },
        {
          field: "rowTitle2",
          title: "総合合否",
          width: 120,
          attributes: this.columnRowNameClass,
          headerAttributes: this.columnRowNameHeaderClass,
          editable: () => false,
          locked: false,
        },
        ...this.layoutList.map(item => ({
          title: item.title,
          headerAttributes: this.columnHeaderClass,
          headerTemplate: item.headerTemplate,
          columns: item.columns,
        })),
      ];
    },
    getHistoryGridColumnSignature() {
      const summarize = column => ({
        field: column.field || "",
        title: column.title || "",
        width: column.width || "",
        locked: column.locked === true,
        headerTemplate: !!column.headerTemplate,
        columns: Array.isArray(column.columns) ? column.columns.map(summarize) : [],
      });
      return JSON.stringify(this.buildHistoryGridColumns().map(summarize));
    },
    getHistoryDataSourceOption() {
      return {
        ...this.localDataSource,
        data: Array.isArray(this.localDataSource.data) ? this.localDataSource.data : [],
      };
    },
    initHistoryDirectGridIfReady() {
      const root = this.getHistoryGridRootEl();
      if (!this.isDisplay || !root) {
        return;
      }
      const nextColumns = this.buildHistoryGridColumns();
      const nextSignature = this.getHistoryGridColumnSignature();
      if (this.historyGridWidget) {
        if (this.historyGridColumnSignature !== nextSignature) {
          this.clearHistoryHeaderInlineHeights();
          this.historyGridWidget.setOptions({ columns: nextColumns });
          this.historyGridColumnSignature = nextSignature;
          this.historyGridAppliedDataSource = null;
        }
        this.applyHistoryGridDataSourceContract();
        this.installHistoryGridFacade();
        this.scheduleHistoryGridLayoutContract();
        return;
      }
      const $root = $(root);
      $root.kendoGrid({
        dataSource: this.getHistoryDataSourceOption(),
        columns: nextColumns,
        scrollable: true,
        resizable: true,
        dataBound: () => this.gridDataBound(),
        columnResize: () => this.onColumnResize(),
      });
      this.historyGridWidget = markRaw($root.data("kendoGrid"));
      this.historyGridColumnSignature = nextSignature;
      this.historyGridAppliedDataSource = Array.isArray(this.localDataSource.data)
        ? this.localDataSource.data
        : [];
      this.installHistoryGridFacade();
      this.scheduleHistoryGridLayoutContract();
    },
    applyHistoryGridDataSourceContract() {
      const dataSource = this.historyGridWidget?.dataSource;
      if (!dataSource) {
        return;
      }
      const nextData = Array.isArray(this.localDataSource.data) ? this.localDataSource.data : [];
      if (this.historyGridAppliedDataSource === nextData) {
        return;
      }
      dataSource.data(nextData);
      this.historyGridAppliedDataSource = nextData;
    },
    applyHistoryGridStyleContract() {
      const root = this.getHistoryGridRootEl();
      if (!root) {
        return;
      }
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
      // Vue2 wrapper では body 全セルへの class 後付け走査は行わない。
      // Vue3 direct jq で 320 leaf columns × 履歴行の全 td を初期表示後に走査すると、
      // loading 解除後の巨大 layout task を誘発するため Kendo 生成 DOM に任せる。
      root.querySelectorAll(".k-grid-header-wrap, .k-grid-content").forEach((el) => {
        el.classList.add("k-auto-scrollable");
      });
    },
    scheduleHistoryGridLayoutContract() {
      const ownerWindow = this.$el?.ownerDocument?.defaultView || window;
      if (this.historyGridLayoutRafId != null) {
        ownerWindow.cancelAnimationFrame(this.historyGridLayoutRafId);
      }
      // Vue2 wrapper は初期 dataBound 後に grid.resize(true) を同期実行していない。
      // Vue3 direct jq で 320 leaf columns の Grid に対して loading 解除前後で即時 resize すると、
      // 表示完了後のブラウザ layout/paint が長時間 main thread を占有する。
      // 初期表示は Kendo の生成結果に任せ、Vue2 と同じく必要な外枠/行高調整だけを後続フレームで行う。
      this.historyGridLayoutRafId = ownerWindow.requestAnimationFrame(() => {
        this.applyHistoryGridStyleContract();
        this.historyGridLayoutRafId = ownerWindow.requestAnimationFrame(() => {
          this.historyGridLayoutRafId = null;
          this.gridSetting();
        });
      });
    },
    destroyHistoryDirectGrid() {
      try {
        this.historyGridWidget?.destroy?.();
      } catch (_error) {
        // noop
      }
      this.historyGridWidget = null;
      this.historyGridColumnSignature = "";
      this.historyGridAppliedDataSource = null;
      const root = this.$refs.historyGrid;
      if (root?.nodeType === 1) {
        root.innerHTML = "";
      }
    },
    getHistoryGridBodyRows() {
      return Array.from(this.getHistoryGridRootEl()?.querySelectorAll?.(".k-grid-content tbody tr") || []);
    },
    getHistoryGridLockedRows() {
      return Array.from(this.getHistoryGridRootEl()?.querySelectorAll?.(".k-grid-content-locked tbody tr") || []);
    },
    getHistoryGridScrollSources() {
      const gridContent = this.getHistoryScrollableContentEl();
      if (!gridContent) {
        return [];
      }
      const sources = [gridContent];
      const inner = gridContent.firstElementChild;
      if (inner && inner !== gridContent) {
        sources.push(inner);
      }
      return sources;
    },
    readHistoryGridBodyScrollLeft() {
      const sources = this.getHistoryGridScrollSources();
      for (const source of sources) {
        const left = source.scrollLeft;
        if (left) {
          return left;
        }
      }
      return sources[0]?.scrollLeft || 0;
    },
    rebindHistoryGridWidgetScrollables() {
      const widget = this.historyGridWidget;
      const root = this.getHistoryGridRootEl();
      if (!widget || !root) {
        return;
      }
      const headerWrap = $(root).find(".k-grid-header-wrap");
      const content = widget.content?.length
        ? widget.content
        : $(root).find(".k-grid-content").not(".k-grid-content-locked");
      if (headerWrap.length && content?.length) {
        widget.scrollables = headerWrap.add(content);
        widget.content = content;
      }
    },
    applyHistoryGridHorizontalScrollLeft(left) {
      const headerWrap = this.getHistoryHeaderWrapEl();
      if (!headerWrap || !Number.isFinite(left)) {
        return;
      }
      let changed = false;
      if (headerWrap.scrollLeft !== left) {
        headerWrap.scrollLeft = left;
        changed = true;
      }
      const sources = this.getHistoryGridScrollSources();
      sources.forEach((source) => {
        if (source !== headerWrap && source.scrollLeft !== left) {
          source.scrollLeft = left;
          changed = true;
        }
      });
      const widget = this.historyGridWidget;
      const kendo = window.kendo;
      if (changed && widget?.scrollables?.length && kendo?.scrollLeft) {
        kendo.scrollLeft(widget.scrollables.not(headerWrap), left);
      }
    },
    syncHistoryGridHeaderScrollLeft() {
      this.applyHistoryGridHorizontalScrollLeft(this.readHistoryGridBodyScrollLeft());
    },
    attachHistoryGridLockedContentScrollSync() {
      const gridContent = this.getHistoryScrollableContentEl();
      const headerWrap = this.getHistoryHeaderWrapEl();
      const lockedContent = this.getHistoryLockedContentEl();
      if (!gridContent || !headerWrap) {
        return;
      }
      this.rebindHistoryGridWidgetScrollables();

      const onScrollableScroll = () => {
        if (lockedContent && lockedContent !== gridContent) {
          lockedContent.scrollTop = gridContent.scrollTop;
        }
        this.syncHistoryGridHeaderScrollLeft();
      };
      const onHeaderScroll = () => {
        this.applyHistoryGridHorizontalScrollLeft(headerWrap.scrollLeft);
        if (lockedContent && lockedContent !== gridContent) {
          lockedContent.scrollTop = gridContent.scrollTop;
        }
      };

      this.getHistoryGridScrollSources().forEach((target) => {
        target.addEventListener("scroll", onScrollableScroll, { passive: true });
        this.historyGridCleanup.push(() => target.removeEventListener("scroll", onScrollableScroll));
      });
      headerWrap.addEventListener("scroll", onHeaderScroll, { passive: true });
      this.historyGridCleanup.push(() => headerWrap.removeEventListener("scroll", onHeaderScroll));

      // 初期表示時点の scrollLeft は 0。ここで header/body scrollLeft を同期書き込みすると、
      // 320 leaf columns の表で強制 layout が走るため、Vue2 と同じく実スクロール発生時だけ同期する。
    },
    /**
     * 親（点検）モーダルと同じ位置・サイズに履歴モーダルを合わせる
     */
    syncWithParentModal() {
      const historyMask = this.$el;
      if (!historyMask || !this.getParentModalContainer()) {
        return;
      }

      // 親 .modal-container に transform があるため fixed の基準はビューポートではなく親コンテナ。
      // getBoundingClientRect の座標を使うと位置がずれるので、親全体を 0,0〜100% で覆う。
      Object.assign(historyMask.style, {
        position: "fixed",
        top: "0",
        left: "0",
        width: "100%",
        height: "100%",
        right: "auto",
        bottom: "auto",
        display: "block",
      });

      const historyWrapper = historyMask.querySelector(".modal-wrapper");
      const historyContainer = historyMask.querySelector(".modal-container");
      if (historyWrapper) {
        Object.assign(historyWrapper.style, {
          display: "block",
          width: "100%",
          height: "100%",
        });
      }
      if (historyContainer) {
        Object.assign(historyContainer.style, {
          width: "100%",
          height: "100%",
          margin: "0",
        });
      }
    },
    getHistoryComputedStyle(element) {
      if (!element) {
        return null;
      }
      const ownerWindow = element.ownerDocument?.defaultView || this.$el?.ownerDocument?.defaultView || window;
      return ownerWindow.getComputedStyle(element);
    },
    setArrRow() {
      const arrRow = Array.from(this.getHistoryGridRootEl()?.getElementsByClassName("deviceSetInfo-row-name") || []);
      arrRow.forEach(item => {
        item.style.color = "var(--ntss-list-body-color)";

        // 日付色変更
        const dateCurrent = dayjs().format("YYYYMMDD");
        const date = dayjs(item.textContent.substring(0, 10));
        if (date.isSame(dateCurrent)) {
          item.style.backgroundColor = "#2ca06f";
          item.style.color = "#FFF";
        }
        if (date.day() === 6) {
          item.style.color = "var(--ntss-saturday-color-n)";
        }
        if (date.day() === 0) {
          item.style.color = "var(--ntss-sunday-color)";
        }

        const holidays = this.getHolidays;
        if (holidays[date.format("YYYY-MM-DD")] != null) {
          item.style.color = "var(--ntss-holiday-color)";
        }
      });
    },
    /**
     * サイズ調整用のパーツ
     */
    // padding取得(スクロール要素)
    getPaddingList() {
      // padding要素のpxを取得
      const elm = this.getHistoryScrollableContentEl();
      if (!elm) {
        return { x: 0, y: 0 };
      }
      const paddingY = elm.getBoundingClientRect().height - parseFloat(this.getHistoryComputedStyle(elm)?.height || 0);
      const paddingX = elm.getBoundingClientRect().width - parseFloat(this.getHistoryComputedStyle(elm)?.width || 0);
      return {
        x: paddingX,
        y: paddingY,
      };
    },
    // padding取得(モーダル要素)
    getPaddingBody() {
      // padding要素のpxを取得
      const elm = this.getHistoryModalBodyEl();
      if (!elm) {
        return { x: 0, y: 0 };
      }
      const paddingY = elm.getBoundingClientRect().height - parseFloat(this.getHistoryComputedStyle(elm)?.height || 0);
      const paddingX = elm.getBoundingClientRect().width - parseFloat(this.getHistoryComputedStyle(elm)?.width || 0);
      return {
        x: paddingX,
        y: paddingY,
      };
    },
    /**
     * テーブル内の各行の高さの調節を行う
     */
    setElementsHeight(elements, heightText) {
      (elements || []).forEach((element) => {
        if (!element) {
          return;
        }
        element.style.height = heightText;
        element.style.minHeight = heightText;
        element.style.boxSizing = "border-box";
      });
    },
    getHistoryHeaderCellRowSpan(cell) {
      if (!cell) {
        return 1;
      }
      const rowSpan = Number(cell.rowSpan || cell.getAttribute?.("rowspan") || 1);
      return Number.isFinite(rowSpan) && rowSpan > 0 ? rowSpan : 1;
    },
    /** rowspan>1・総合合否などは行高同期から除外し、該当行の表头クラスのみ対象にする */
    getHistoryHeaderSyncableCells(cells, rowIndex = 0) {
      return (cells || []).filter((cell) => {
        if (this.getHistoryHeaderCellRowSpan(cell) > 1) {
          return false;
        }
        if (cell.classList?.contains("deviceSetInfo-header-row-name")) {
          return false;
        }
        if (rowIndex === 0) {
          return cell.classList?.contains("deviceSetInfo-header-first-name");
        }
        if (rowIndex === 1) {
          return cell.classList?.contains("deviceSetInfo-header-secound-name");
        }
        return true;
      });
    },
    clearHistoryHeaderInlineHeights() {
      const root = this.getHistoryGridRootEl();
      if (!root) {
        return;
      }
      root.querySelectorAll(
        ".k-grid-header th, .k-grid-header .k-table-th, .k-grid-header-locked th, .k-grid-header-locked .k-table-th",
      ).forEach((cell) => {
        cell.style.removeProperty("height");
        cell.style.removeProperty("min-height");
      });
      const lockedHeader = this.getHistoryLockedHeaderEl();
      lockedHeader?.style?.removeProperty("height");
      lockedHeader?.querySelector?.("table")?.style?.removeProperty("height");
      lockedHeader?.querySelector?.("table")?.style?.removeProperty("min-height");
    },
    isHistoryGridVisibleForLayout() {
      if (!this.isDisplay) {
        return false;
      }
      const headerWrap = this.getHistoryHeaderWrapEl();
      return !!(headerWrap && headerWrap.offsetParent != null && headerWrap.getBoundingClientRect().height > 0);
    },
    scheduleHistoryGridLayoutSync() {
      const ownerWindow = this.$el?.ownerDocument?.defaultView || window;
      if (this.historyGridSyncRafId != null) {
        ownerWindow.cancelAnimationFrame(this.historyGridSyncRafId);
      }
      this.historyGridSyncRafId = ownerWindow.requestAnimationFrame(() => {
        this.historyGridSyncRafId = ownerWindow.requestAnimationFrame(() => {
          this.historyGridSyncRafId = null;
          if (!this.isHistoryGridVisibleForLayout()) {
            return;
          }
          this.syncGridColumnHeights();
        });
      });
    },
    repairHistoryGridLockedColumnLayout() {
      const lockedHeader = this.getHistoryLockedHeaderEl();
      const lockedContent = this.getHistoryLockedContentEl();
      [lockedHeader, lockedContent].forEach(container => {
        const table = container?.querySelector?.("table");
        if (table && container?.style?.width) {
          table.style.width = container.style.width;
          table.style.minWidth = container.style.width;
        }
      });
    },
    /** 表头：锁定列（跨行）高度 = 右侧两级表头总高；同级表头格等高 */
    syncHeaderCellHeights() {
      if (!this.isHistoryGridVisibleForLayout()) {
        return;
      }
      const lockedHeader = this.getHistoryLockedHeaderEl();
      const headerWrap = this.getHistoryHeaderWrapEl();
      if (!lockedHeader || !headerWrap) {
        return;
      }

      this.clearHistoryHeaderInlineHeights();
      void headerWrap.offsetHeight;

      const headerRows = Array.from(headerWrap.querySelectorAll("thead tr"));
      headerRows.forEach((row, rowIndex) => {
        const cells = Array.from(row.querySelectorAll("th, .k-table-th"));
        const syncableCells = this.getHistoryHeaderSyncableCells(cells, rowIndex);
        if (!syncableCells.length) {
          return;
        }
        let rowMax = 0;
        syncableCells.forEach((cell) => {
          rowMax = Math.max(rowMax, Math.ceil(cell.getBoundingClientRect().height));
        });
        if (rowMax > 0) {
          this.setElementsHeight(syncableCells, `${rowMax}px`);
        }
      });

      void headerWrap.offsetHeight;
      const headerWrapHeight = Math.ceil(headerWrap.getBoundingClientRect().height);
      if (headerWrapHeight <= 0) {
        return;
      }
      const heightText = `${headerWrapHeight}px`;
      const lockedCells = Array.from(lockedHeader.querySelectorAll("th, .k-table-th"));
      this.setElementsHeight(lockedCells, heightText);
    },
    rowHeightResize() {
      this.repairHistoryGridLockedColumnLayout();

      const lockTrs = Array.from(this.getHistoryLockedContentEl()?.querySelectorAll?.("tr") || []);
      const scrollTrs = Array.from(this.getHistoryScrollableContentEl()?.querySelectorAll?.("tr") || []);

      for (let i = 0; i < lockTrs.length; i++) {
        const lockTr = lockTrs[i];
        const scrollTr = scrollTrs[i];
        if (!scrollTr) {
          continue;
        }

        // Vue2 は高さ同期を tr のみに限定している。
        // td 全件へ height/min-height を書くと 320 leaf columns × 履歴行分の style 書き換えになり、
        // Grid 表示直後の巨大 layout task を誘発する。
        lockTr.style.height = "auto";
        scrollTr.style.height = "auto";

        const lockH = Math.ceil(lockTr.getBoundingClientRect().height);
        const scrollH = Math.ceil(scrollTr.getBoundingClientRect().height);
        if (lockH < scrollH) {
          lockTr.style.height = `${scrollH}px`;
        } else if (scrollH < lockH) {
          scrollTr.style.height = `${lockH}px`;
        }
      }
    },
    syncGridColumnHeights() {
      // Vue2 の履歴 Grid は data 行の locked/scroll 側 tr 高さ同期だけを行う。
      // 表头全セルの高さ同期は 320 leaf columns で強い再計算を誘発するため Kendo の header layout に任せる。
      this.rowHeightResize();
    },
    /**
     * スクロール可能部分の縦スクロールがヘッダとズレる場合があるため
     * スクロール可能部分のヘッダと、一覧の幅を調整する
     */
    getVerticalScrollbarWidth() {
      const scrollableContent = this.getHistoryScrollableContentEl();
      if (!scrollableContent) {
        return 0;
      }
      const gutter = scrollableContent.offsetWidth - scrollableContent.clientWidth;
      if (gutter > 0) {
        return Math.round(gutter);
      }
      return Math.max(0, Math.round(this.getPaddingList().x));
    },
    scrollAbleWidthResize() {
      const gridHeader = this.getHistoryHeaderRootEl() || this.getHistoryHeaderEl();
      const scrollableContent = this.getHistoryScrollableContentEl();
      const headerWrap = this.getHistoryHeaderWrapEl();
      if (!gridHeader || !scrollableContent) {
        return;
      }

      const scrollbarWidth = this.getVerticalScrollbarWidth();
      if (scrollbarWidth > 0) {
        const gutterText = `${scrollbarWidth}px`;
        if (gridHeader.style.paddingRight !== gutterText) {
          gridHeader.style.paddingRight = gutterText;
        }
        if (gridHeader.style.getPropertyValue("--history-header-scrollbar-gutter") !== gutterText) {
          gridHeader.style.setProperty("--history-header-scrollbar-gutter", gutterText);
        }
      } else {
        if (gridHeader.style.paddingRight) {
          gridHeader.style.removeProperty("padding-right");
        }
        if (gridHeader.style.getPropertyValue("--history-header-scrollbar-gutter") !== "0px") {
          gridHeader.style.setProperty("--history-header-scrollbar-gutter", "0px");
        }
      }

      const fixW = headerWrap
        ? Math.round(headerWrap.clientWidth)
        : Math.round(scrollableContent.clientWidth);
      if (fixW > 0) {
        const widthText = `${fixW}px`;
        if (scrollableContent.style.width !== widthText) {
          scrollableContent.style.width = widthText;
        }
      } else {
        if (scrollableContent.style.width) {
          scrollableContent.style.removeProperty("width");
        }
      }
      // 初期表示時点の scrollLeft は 0。ここで header/body scrollLeft を同期書き込みすると、
      // 320 leaf columns の表で強制 layout が走るため、Vue2 と同じく実スクロール発生時だけ同期する。
    },
    /**
     * 表全体の幅の調整
     */
    setTableWidth() {
      // 幅の調整
      const MIN_WIDTH = 400;
      const modalBody = this.getHistoryModalBodyEl();
      if (!modalBody) {
        return;
      }
      // 現在の要素の幅を取得
      const allW = modalBody.getBoundingClientRect().width;

      // 最小幅を下回った場合
      if (allW < MIN_WIDTH) {
        const locked = $(this.getHistoryLockedContentEl());
        const listArea = this.getHistoryListAreaEl();
        // 親のdiv要素の幅を一覧の幅に合わせる
        if (listArea) {
          listArea.style.width = "fit-content";
        }
        // widthをautoで上書き
        const scrollableContent = this.getHistoryScrollableContentEl();
        if (scrollableContent) {
          scrollableContent.style.width = "auto";
        }
        // 一覧部分の横スクロールが消えるため、固定列とスクロール列の高さを合わせる
        if (scrollableContent) {
          scrollableContent.style.height = `${locked.innerHeight()}px`;
        }
        // カラムヘッダの横幅を明細部分に合わせる
        const scrollW = scrollableContent?.getBoundingClientRect().width || 0;
        const lockedW = locked.get(0)?.getBoundingClientRect().width || 0;
        const gridHeader = this.getHistoryHeaderEl();
        if (gridHeader) {
          gridHeader.style.width = `${scrollW + lockedW}px`;
        }
      } else {
        // widthをautoで上書き
        const gridHeader = this.getHistoryHeaderEl();
        if (gridHeader) {
          gridHeader.style.width = "auto";
        }
        // 親のdiv要素の幅をリセット
        const listArea = this.getHistoryListAreaEl();
        if (listArea) {
          listArea.style.width = "";
        }
      }
    },
    /**
     * 表全体の高さの調整
     */
    setTableHeight() {
      // 最小高さの設定
      const MIN_HEIGHT = 100;
      // min-heightの適用
      const scrollableContent = this.getHistoryScrollableContentEl();
      if (scrollableContent) {
        scrollableContent.style.minHeight = `${MIN_HEIGHT}px`;
      }
      const lockedContent = this.getHistoryLockedContentEl();
      if (lockedContent) {
        lockedContent.style.minHeight = `${MIN_HEIGHT - this.getPaddingList().y}px`;
      }

      // 高さの調整
      // 座標計算の為スクロール位置を0指定
      const modalBody = this.getHistoryModalBodyEl();
      const footerEl = this.getHistoryFooterEl();
      if (!modalBody || !footerEl) {
        return;
      }
      const mBodyScrollPosition = modalBody.scrollTop;
      modalBody.scrollTop = 0;

      // 目標の高さの計算
      const fotterTop = footerEl.getBoundingClientRect().top;
      const scrollTop = scrollableContent?.getBoundingClientRect().top;
      const fixH = Math.floor(fotterTop - scrollTop - this.getPaddingBody().y);

      // スクロール位置を元に戻す
      modalBody.scrollTop = mBodyScrollPosition;

      // 最小の高さを下回る場合autoで設定
      if (fixH <= MIN_HEIGHT) {
        if (scrollableContent) scrollableContent.style.height = "auto";
        if (lockedContent) lockedContent.style.height = "auto";
      } else {
        if (scrollableContent) scrollableContent.style.height = `${fixH}px`;
        if (lockedContent) lockedContent.style.height = `${fixH - this.getPaddingList().y}px`;
      }
    },
    /**
     * 表全体の高さ/幅の設定を行う
     * 縦スクロール制御
     * 　・通常時
     * 　　フッター要素のギリギリまで伸ばす
     * 　・2重の縦スクロールが発生しそうになった場合
     * 　　heightをautoとし
     * 　　外側のスクロールで表全体を見るようにする
     * 横スクロール制御
     *  ・最小の幅よりも小さくなった場合widthをautoとし
     *   外側のスクロールで表全体を見るようにする
     */
    setTableWidthHeight() {
      // 高さの調整(1回目)
      this.setTableHeight();
      // 幅の調整
      this.setTableWidth();
      // スクロール可能幅の調整
      this.scrollAbleWidthResize();
      // 高さの調整(2回目)
      //  幅の調整が完了するまでモーダルの横スクロールが出るため
      //  スクロールバーの分だけ高さが不足してしまう
      //  幅の調整完了後、再度高さの調整が必要となる
      this.setTableHeight();
    },
    gridSetting() {
      const ownerWindow = this.$el?.ownerDocument?.defaultView || window;
      if (this.historyGridSettingRafId != null) {
        ownerWindow.cancelAnimationFrame(this.historyGridSettingRafId);
      }
      this.historyGridSettingRafId = ownerWindow.requestAnimationFrame(() => {
        this.historyGridSettingRafId = null;
        this.$nextTick(() => {
          if (!this.historyGridWidget || !this.getHistoryGridRootEl()) {
            return;
          }
          // 一覧部分にスタイル設定(文字列を改行して全体表示)
          const gridRoot = this.getHistoryGridRootEl();
          const rowNames = Array.from(gridRoot?.getElementsByClassName("deviceSetInfo-row-name") || []);
          rowNames.forEach(item => {
            item.style = "word-break: break-all; word-wrap: break-word; white-space: normal;";
          });
          const headerStyle = "word-break: break-all; word-wrap: break-word; white-space: normal; text-align: center; padding: 2px 0; overflow: visible; text-overflow: clip;";
          Array.from(gridRoot?.getElementsByClassName("deviceSetInfo-header-first-name") || []).forEach(item => {
            item.style.cssText = headerStyle;
          });
          Array.from(gridRoot?.getElementsByClassName("deviceSetInfo-header-secound-name") || []).forEach(item => {
            item.style.cssText = headerStyle;
          });
          const lockedContent = this.getHistoryLockedContentEl();
          if (lockedContent) lockedContent.style.overflowX = "none";
          resolveRefElement(this, "historyGrid")?.style?.setProperty("border-style", "none");
          // 全体の調整
          this.setTableWidthHeight();
          // 行・表头高度（表示完了後に1回だけ同期）
          this.scheduleHistoryGridLayoutSync();
          // スタイル設定
          this.setArrRow();
          // ヘッダーにスタイル適用
          const gridHeaderEl = this.getHistoryHeaderEl();
          if (gridHeaderEl) {
            gridHeaderEl.style.backgroundColor = "var(--ntss-list-header-background-color)";
            const headerTable = gridHeaderEl.querySelector("table");
            if (headerTable) {
              headerTable.style.borderColor = "var(--ntss-base-background-color)";
            }
          }
          // 慣性スクロール用のクラスを追加
          const scrollableContent = this.getHistoryScrollableContentEl();
          if (scrollableContent) {
            scrollableContent.style.WebkitOverflowScrolling = "touch";
          }
        });
      });
    },
    onColumnResize() {
      this.gridSetting();
      this.syncHistoryLockedResizeWidth();
    },
    // 固定列幅変更中のtable幅にdiv幅を追随させるためのイベントハンドラ
    onColumnResizingMouseMove(event) {
      if (event.buttons !== 1) {
        return;
      }
      this.syncHistoryLockedResizeWidth();
    },
    syncHistoryLockedResizeWidth() {
      const root = this.getHistoryGridRootEl();
      if (!root) {
        return;
      }
      ["k-grid-header-locked", "k-grid-content-locked"].forEach(className => {
        const lockedDiv = root.getElementsByClassName(className)[0];
        const lockedTable = lockedDiv?.getElementsByTagName("table")[0];
        if (!lockedDiv || !lockedTable) {
          return;
        }
        const tableWidth = getComputedStyle(lockedTable).width;
        if (tableWidth && getComputedStyle(lockedDiv).width !== tableWidth) {
          lockedDiv.style.width = tableWidth;
        }
      });
      this.repairHistoryGridLockedColumnLayout();
    },
    clearHistoryGridListeners() {
      (this.historyGridCleanup || []).forEach((cleanup) => {
        try {
          cleanup();
        } catch (_error) {
          // noop
        }
      });
      this.historyGridCleanup = [];
    },
    gridDataBound() {
      this.clearHistoryGridListeners();
      // clickイベントの設定
      const gridContent = this.getHistoryScrollableContentEl();
      const gridLocked = this.getHistoryLockedContentEl();
      const localData = this.localDataSource.data;
      const addListener = (target, eventName, handler, options = undefined) => {
        target?.addEventListener(eventName, handler, options);
        if (target) {
          this.historyGridCleanup.push(() => target.removeEventListener(eventName, handler, options));
        }
      };
      const bindRowClick = (contentEl) => {
        const tbody = contentEl?.querySelector?.("tbody");
        if (!tbody) {
          return;
        }
        const handleClick = (event) => {
          const row = event.target?.closest?.("tr");
          if (!row || !tbody.contains(row)) {
            return;
          }
          const rowIndex = Array.prototype.indexOf.call(tbody.children, row);
          const rowTitle = localData[rowIndex]?.rowTitle;
          if (!rowTitle) {
            return;
          }
          const rowDate = dayjs(rowTitle.split("(")[0]).format("YYYY-MM-DD");
          this.goToBack(rowDate);
        };
        addListener(tbody, "click", handleClick);
      };
      bindRowClick(gridContent);
      bindRowClick(gridLocked);
      this.applyHistoryGridStyleContract();

      if (!gridLocked || !gridContent) return;
      this.attachHistoryGridLockedContentScrollSync();
    },
    goToBack(rowDate) {
      // 点検項目入力画面に点検日を渡して点検履歴を閉じる
      this.closeHistoryWithParams({ date: rowDate });
    },
    async refreshHistoryGridLayout() {
      this.renewLocalDataSource();
      // Vue2 と同じく、検索中はいったん v-if を落とし、データ準備後に Grid を作り直す。
      this.isDisplay = true;
      await this.$nextTick();
      await this.$nextTick();
      this.clearHistoryHeaderInlineHeights();
      this.initHistoryDirectGridIfReady();
      await this.waitHistoryGridInitialRenderComplete();
    },
    async search() {
      this.setLoadingScreenVisible(true);
      // Vue2 と同じく検索中はいったん履歴 Grid を非表示にする。
      // direct jq Grid は Vue が DOM を外す前に destroy して旧 320 列 DOM を残さない。
      this.isDisplay = false;
      this.clearHistoryGridListeners();
      this.destroyHistoryDirectGrid();
      await this.$nextTick();
      try {
        const {
          mainteDate,
          numOfMonth,
        } = this.condition.inUsed;
        const endDate = dayjs(mainteDate)
          .subtract(numOfMonth, "month")
          .format("YYYY-MM-DD");
        const params = {
          machineNo: this.getMachine.machineNo,
          date: mainteDate,
          numOfMonth,
        };
        const machine = {
          machineNo: this.getMachine.machineNo,
          startDate: mainteDate,
          endDate,
          facilityCd: this.getFacilityCd,
        };
        await Promise.all([
          // 点検レイアウトマスタと点検項目マスタの情報を取得
          this.sendRequestGetDetailHistory(params),
          // 点検結果の情報を取得
          this.sendRequestGetMachineResult(machine),
          // 最終更新者の氏名取得用のユーザー情報を取得
          this.setUserAccountInfo(this.getFacilityCd),
        ]);
        await this.refreshHistoryGridLayout();
        await this.scheduleHistoryGridScrollReset();
        await this.waitHistoryGridInitialRenderComplete();
      } finally {
        // loading は Grid 初期生成・scroll reset・後続 rAF まで待ってから解除する。
        // これで「履歴の初期表示がまだ終わっていないのに loading だけ消える」状態を避ける。
        this.setLoadingScreenVisible(false);
      }
    },
    dialogOk() {
      const inProgress = this.condition.inProgress;
      let validate = true;
      if (!inProgress.mainteDate) {
        validate = false;
        // title: "チェックエラー",
        // message: "日付を無効にする。"
        alertByKey("00200005");
      }
      // stringからnumberに変換しておく
      inProgress.numOfMonth = Number(inProgress.numOfMonth);
      if (inProgress.numOfMonth < 1) {
        validate = false;
        // title: "チェックエラー",
        // message: "過去年数を無効にする。"
        alertByKey("03400006");
      }
      if (inProgress.numOfMonth > 120) {
        inProgress.numOfMonth = 120;
      }
      if (validate) {
        // 入力エラーがなければ検索を実行する
        const inUsed = this.condition.inUsed;
        Object.assign(inUsed, inProgress);
        this.setLayoutParams({ ...inUsed });

        this.popoverVisible = false;
        this.search();
      }
    },
    dialogClear() {
      // 検索条件をデフォルト値にして検索
      Object.assign(this.condition.inProgress, createDefaultConditon());
      this.dialogOk();
    },
    closeHistory() {
      EventBus.$emit("closeHistory");
    },
    closeHistoryWithParams(params) {
      EventBus.$emit("closeHistory", params);
    },
    inputValidValue(event) {
      const valueString = event.target.value;
      let valueNumber = (valueString === "")
        ? createDefaultConditon().numOfMonth
        : Number(valueString);
      // 範囲内の数値に補正する
      if (this.maxValue != null && valueNumber > this.maxValue) {
        valueNumber = this.maxValue;
      }
      if (this.minValue != null && valueNumber < this.minValue) {
        valueNumber = this.minValue;
      }
      // 入力値をnumber値に更新する
      this.condition.inProgress.numOfMonth = valueNumber;
    },
    stopScrollFun(event) {
      if (!this.focusFlg) {
        return;
      }
      const delta = (event.wheelDelta && (event.wheelDelta > 0 ? 1 : -1))
        || (event.detail && (event.detail > 0 ? -1 : 1));
      if (!event.target.value) {
        event.target.value = 0;
      }
      let value = parseFloat(event.target.value);
      const parameterStep = 1;
      if (delta > 0) {
        // 滑ります
        value += parameterStep;
      } else {
        // 下がります
        value -= parameterStep;
      }
      // 数値範囲内かどうかの確認
      if (value > this.maxValue) {
        value = this.minValue;
      }
      if (value < this.minValue) {
        value = this.maxValue;
      }
      this.condition.inProgress.numOfMonth = value;
    },
    handleBlur() {
      this.focusFlg = false;
    },
    handleFocus() {
      this.focusFlg = true;
    },
    initCondition() {
      // created時はdata項目生成処理で検索条件のデフォルト値が設定されている
      const inUsed = this.condition.inUsed;
      if (this.getLayoutParams) {
        // Storeに保存された情報があればinUseに上書きする
        // （ inProgress は入力UIのための変数なので
        // 　showPopover の時点で inUse の内容が反映されるだけで問題ない）
        const {
          mainteDate,
          numOfMonth,
          dailyRunning,
          dailyNotGood,
          dailyGood,
          notDailyDate,
        } = this.getLayoutParams;
        if (mainteDate) {
          inUsed.mainteDate = mainteDate;
        }
        if (numOfMonth) {
          inUsed.numOfMonth = numOfMonth;
        }
        if (dailyRunning != null) {
          inUsed.dailyRunning = dailyRunning;
        }
        if (dailyNotGood != null) {
          inUsed.dailyNotGood = dailyNotGood;
        }
        if (dailyGood != null) {
          inUsed.dailyGood = dailyGood;
        }
        if (notDailyDate != null) {
          inUsed.notDailyDate = notDailyDate;
        }
      } else {
        // 初期状態をStoreに保存する
        this.setLayoutParams({ ...inUsed });
      }
    },
    renewLocalDataSource() {
      const inUsed = this.condition.inUsed;
      // 表示対象期間に対応する初期状態のデータを作成
      const localData = createInitLocalData(inUsed);
      // 点検結果データを反映する
      convertGridData(
        localData,
        this.getResultMasterHis,
        this.getMachineResult,
        this.getUserAccountInfo
      );
      // フィルター条件を適用する
      applyFilterLocalData(localData, inUsed);
      this.localDataSource.data = localData;
    },
    requestReportParams(param) {
      // 機能コード判定
      if (param.substring(0, 3) !== getCurrentFunctionCd().substring(0, 3)) return;

      // 印刷パラメータを応答
      const toDate = (this.getLayoutParams?.mainteDate != null)
        ? dayjs(this.getLayoutParams.mainteDate)
        : dayjs();
      let fromDate = dayjs(toDate);
      if (this.getLayoutParams?.numOfMonth != null) {
        fromDate = fromDate.subtract(this.getLayoutParams.numOfMonth, "months");
      }
      const mainteNos = (this.getMachineResult?.length)
        ? this.getMachineResult.map(x => x.devMenteNo)
        : [];
      const {
        rstDialysisState,
        kurNames,
        selectedPatGroupNames,
        treatDate,
      } = this.getStorSimlpSearchQurey;
      const expressCondCdStr = (rstDialysisState?.length) ? (
        (rstDialysisState.length === 2) ? "予定・実績" : (
          (rstDialysisState[0] === "1") ? "予定" : "実績")) : "";
      const kurNamesStr = (kurNames?.length) ? kurNames.join("・") : "すべて";
      const patGroups = selectedPatGroupNames || "すべて";
      const {
        bedCdListString,
        machineTypeName,
      } = this.getConditionForReportParams;
      const date = toDate.format("YYYYMMDD");
      const reportParams = {
        functionCd: "03401",
        facilityCd: this.getFacilityCd,
        date,
        fromDate: fromDate.format("YYYYMMDD"),
        toDate: date,
        machineNos: [this.getMachine.machineNo],
        mainteNos,
        treatDate,
        bedCdListString,
        freeWord: this.getCondition.keyword,
        expressCondCdStr,
        kurNames: kurNamesStr,
        patGroups,
        type: machineTypeName.replaceAll("、", "・"),
      };
      EventBus.$emit("sendReportParams", reportParams);
    },
    /** 画面印刷の処理 */
    handleBeforePrint() {
      const contentContainer = getContentContainerElement(this.$el || this);
      if (contentContainer) {
        contentContainer.style.display = "none";
      }

      const modal = this.$el?.classList?.contains("daily-history-modal")
        ? this.$el
        : (this.$el?.ownerDocument || document).querySelector(".daily-history-modal");
      if (!modal?.parentNode?.children) return;

      Array.from(modal.parentNode.children).forEach(el => {
        if (el !== modal) {
          el.dataset.printHidden = "true";
          el.style.display = "none";
        }
      });
    },
    handleAfterPrint() {
      const contentContainer = getContentContainerElement(this.$el || this);
      if (contentContainer) {
        contentContainer.style.display = "block";
      }

      const scopedDocument = this.$el?.ownerDocument || document;
      scopedDocument.querySelectorAll('[data-print-hidden="true"]').forEach(el => {
        el.style.display = "";
        delete el.dataset.printHidden;
      });
    },
  },
  watch: {
    /**
     * @description フォントサイズ切り替え時
     */
    getFontSize() {
      this.syncWithParentModal();
      this.gridSetting();
    },
    getWindowHeight() {
      this.syncWithParentModal();
      this.gridSetting();
    },
    getWindowWidth() {
      this.syncWithParentModal();
      this.gridSetting();
    },
  },
  created() {
    // 検索条件の初期化
    this.initCondition();
    // 初期検索を実行
    this.search();

    EventBus.$on("requestReportParams", this.requestReportParams);
  },
  mounted() {
    this.$el?.ownerDocument?.addEventListener(
      "mousemove",
      this.onColumnResizingMouseMove,
    );

    this.$nextTick(() => {
      this.syncWithParentModal();
      const parentContainer = this.getParentModalContainer();
      if (parentContainer) {
        this.parentModalResizeCleanup = observeElementResize(
          parentContainer,
          () => {
            this.syncWithParentModal();
            this.gridSetting();
          },
        );
      }
    });

    const scopedWindow = getScopedWindow(this.$el || this);
    if (scopedWindow) {
      scopedWindow.addEventListener("beforeprint", this.handleBeforePrint);
      scopedWindow.addEventListener("afterprint", this.handleAfterPrint);
    }
  },
  beforeUnmount() {
    this.$el?.ownerDocument?.removeEventListener(
      "mousemove",
      this.onColumnResizingMouseMove,
    );

    this.parentModalResizeCleanup?.();
    this.parentModalResizeCleanup = null;
    if (this.historyGridLayoutRafId != null) {
      (this.$el?.ownerDocument?.defaultView || window).cancelAnimationFrame(this.historyGridLayoutRafId);
      this.historyGridLayoutRafId = null;
    }
    if (this.historyGridSyncRafId != null) {
      (this.$el?.ownerDocument?.defaultView || window).cancelAnimationFrame(this.historyGridSyncRafId);
      this.historyGridSyncRafId = null;
    }
    if (this.historyGridSettingRafId != null) {
      (this.$el?.ownerDocument?.defaultView || window).cancelAnimationFrame(this.historyGridSettingRafId);
      this.historyGridSettingRafId = null;
    }
    this.clearHistoryGridListeners();
    this.destroyHistoryDirectGrid();
    EventBus.$off("requestReportParams", this.requestReportParams);

    const scopedWindow = getScopedWindow(this.$el || this);
    if (scopedWindow) {
      scopedWindow.removeEventListener("beforeprint", this.handleBeforePrint);
      scopedWindow.removeEventListener("afterprint", this.handleAfterPrint);
    }
  },
};

// 検索条件のデフォルト値を生成
const createDefaultConditon = () => ({
  mainteDate: dayjs().format("YYYY-MM-DD"),
  numOfMonth: 1,
  dailyRunning: true,
  dailyNotGood: true,
  dailyGood: true,
  notDailyDate: true,
});

// Kendo DataSource の Model から行データを取得する
const getHistoryRowData = (dataItem) => {
  if (dataItem == null) {
    return {};
  }
  if (typeof dataItem.toJSON === "function") {
    return dataItem.toJSON();
  }
  return dataItem;
};

// グリッドのレイアウトごとのカラム定義を生成
const createMultiColumnInfo = (masterItem, masterIndex) => {
  const disabledSpan = "<span class='cell-disabled'></span>";
  const createTemplete = (field, itemIndex) => (dataItem) => {
    const row = getHistoryRowData(dataItem);
    if (row.cellDisable?.[masterIndex]?.[itemIndex]) {
      return disabledSpan;
    }
    const value = row[field];
    return value == null ? "" : String(value);
  };
  const columns = masterItem.items.map((item, itemIndex) => {
    const field = `column${masterIndex}${itemIndex}`;
    return {
      field,
      title: item.menteContent1,
      width: "100px",
      headerAttributes: columnHeaderSecendClass,
      attributes: columnBodyClass,
      template: createTemplete(field, itemIndex),
    };
  });
  const lastUserNameIndex = masterItem.items.length;
  const lastUserNameField = `column${masterIndex}${lastUserNameIndex}`;
  columns.push({
    field: lastUserNameField,
    title: "最終更新者",
    width: "100px",
    headerAttributes: columnHeaderSecendClass,
    attributes: columnBodyClass,
    template: createTemplete(lastUserNameField, lastUserNameIndex),
  });
  const lastUpdateIndex = masterItem.items.length + 1;
  const lastUpdateField = `column${masterIndex}${lastUpdateIndex}`;
  columns.push({
    field: lastUpdateField,
    title: "最終更新日時",
    width: "9em",
    headerAttributes: columnHeaderSecendClass,
    attributes: columnBodyClass,
    template: createTemplete(lastUpdateField, lastUpdateIndex),
  });
  return columns;
};

// 表示対象期間に対応する初期状態のデータを作成する
const createInitLocalData = ({ mainteDate, numOfMonth }) => {
  const origin = dayjs(mainteDate).startOf("day");
  const month = dayjs(origin).subtract(numOfMonth, "months");
  const days = origin.diff(month, "days") + 1;
  const result = [];
  let rowDate = dayjs(origin);
  for (let i = 0; i < days; i++) {
    result.push({
      rowNum: i + 1,
      rowTitle: rowDate.format("YYYY/MM/DD(dd)"),
      cellDisable: [],
    });
    rowDate = rowDate.subtract(1, "days");
  }
  return result;
};

const getRowMainteDate = rowData => rowData.rowTitle.split("(")[0].replaceAll("/", "-");

const normalizeMainteDate = (value) => {
  if (value == null || value === "") return "";
  const parsed = dayjs(value);
  if (parsed.isValid()) {
    return parsed.format("YYYY-MM-DD");
  }
  return String(value).split("T")[0].replaceAll("/", "-");
};

const createMainteMainKey = (mainteDate, menteLayoutCd) => `${mainteDate}|${menteLayoutCd}`;

const createMainteMainEditionKey = (mainteDate, menteLayoutCd, mainteLayoutEdition) => (
  `${mainteDate}|${menteLayoutCd}|${mainteLayoutEdition}`
);

const createDetailHistoryKey = (menteDetailCd, editionNo) => (
  `${menteDetailCd}|${editionNo}`
);

const createDetailIdentityKey = (detailCd, cateCd, cateEdi, detailEdi) => (
  `${detailCd}|${cateCd}|${cateEdi}|${detailEdi}`
);

const createResultItemIdentityKey = resultItem => createDetailIdentityKey(
  resultItem.menteDetailCd,
  resultItem.cateCd,
  resultItem.cateEdi,
  resultItem.detailEdi
);

const parseMainteMainDetail = (mainteMain) => {
  if (!mainteMain?.detail) return [];
  try {
    const detail = JSON.parse(mainteMain.detail);
    return Array.isArray(detail) ? detail : [];
  } catch (e) {
    return [];
  }
};

const createMainteMainIndex = (mainteMainList) => {
  const byLayout = new Map();
  const byLayoutEdition = new Map();

  (mainteMainList || []).forEach((mainteMain) => {
    const mainteDate = normalizeMainteDate(mainteMain.menteDate);
    const detailList = parseMainteMainDetail(mainteMain);
    const detailByIdentity = new Map();
    detailList.forEach((detailItem) => {
      detailByIdentity.set(
        createDetailIdentityKey(
          detailItem.detail_cd,
          detailItem.cate_cd,
          detailItem.cate_edi,
          detailItem.detail_edi
        ),
        detailItem
      );
    });
    const indexedMainteMain = {
      source: mainteMain,
      detailList,
      detailByIdentity,
    };
    byLayout.set(
      createMainteMainKey(mainteDate, mainteMain.menteLayoutCd),
      indexedMainteMain
    );
    byLayoutEdition.set(
      createMainteMainEditionKey(
        mainteDate,
        mainteMain.menteLayoutCd,
        mainteMain.mainteLayoutEdition
      ),
      indexedMainteMain
    );
  });

  return {
    get(rowMainteDate, layoutResult) {
      return byLayoutEdition.get(
        createMainteMainEditionKey(
          rowMainteDate,
          layoutResult.menteLayoutCd,
          layoutResult.mainteLayoutEdition
        )
      ) || byLayout.get(
        createMainteMainKey(rowMainteDate, layoutResult.menteLayoutCd)
      );
    },
  };
};

const createUserAccountMap = userAccount => new Map(
  (userAccount || []).map(user => [String(user.userId), user])
);

const createDetailHistoryNameMap = (layoutResult) => {
  const detailNameMap = new Map();
  (layoutResult?.detailHst || []).forEach((detailHst) => {
    detailNameMap.set(
      createDetailHistoryKey(detailHst.menteDetailCd, detailHst.editionNo),
      detailHst.menteContent1
    );
  });
  return detailNameMap;
};

const getHistoryDetailName = (detailItem, detailHistoryNameMap) => (
  detailHistoryNameMap.get(
    createDetailHistoryKey(detailItem.detail_cd, detailItem.detail_edi)
  )
);

const countItemNames = (items) => {
  const result = new Map();
  (items || []).forEach((item) => {
    const name = item.menteContent1;
    result.set(name, (result.get(name) || 0) + 1);
  });
  return result;
};

const createItemNameOrderList = (items) => {
  const countMap = new Map();
  return (items || []).map((item) => {
    const name = item.menteContent1;
    const nextCount = (countMap.get(name) || 0) + 1;
    countMap.set(name, nextCount);
    return nextCount;
  });
};

const createDetailItemsByName = (detailList, detailHistoryNameMap) => {
  const detailItemsByName = new Map();
  (detailList || []).forEach((detailItem) => {
    const name = getHistoryDetailName(detailItem, detailHistoryNameMap);
    if (!name) return;
    if (!detailItemsByName.has(name)) {
      detailItemsByName.set(name, []);
    }
    detailItemsByName.get(name).push(detailItem);
  });
  return detailItemsByName;
};

// 点検結果から追加された点検項目の列のうち
// 最新マスタ分の同一項目名の列数を考慮して
// 点検結果を表示するのに必要な列数だけを残す補正を行う
const deleteTrailingItems = (localData, resultMaster, mainteMainIndex) => {
  resultMaster.forEach((layoutResult) => {
    if (!layoutResult) return;
    const latestCount = layoutResult.detailLatestCount;
    if (
      latestCount == null
      || layoutResult.items.length === latestCount
    ) return;

    const itemsNew = layoutResult.items.slice(0, latestCount);
    const itemsRest = layoutResult.items.slice(latestCount);
    const baseNameCounts = countItemNames(itemsNew);
    const requiredNameCounts = new Map();
    const detailHistoryNameMap = createDetailHistoryNameMap(layoutResult);

    for (const rowData of localData) {
      const mainteMain = mainteMainIndex.get(getRowMainteDate(rowData), layoutResult);
      if (!mainteMain?.detailList?.length) continue;

      const rowNameCounts = new Map();
      mainteMain.detailList.forEach((detailItem) => {
        const name = getHistoryDetailName(detailItem, detailHistoryNameMap);
        if (!name) return;
        rowNameCounts.set(name, (rowNameCounts.get(name) || 0) + 1);
      });

      rowNameCounts.forEach((count, name) => {
        if ((requiredNameCounts.get(name) || 0) < count) {
          requiredNameCounts.set(name, count);
        }
      });
    }

    requiredNameCounts.forEach((requiredCount, name) => {
      let currentCount = baseNameCounts.get(name) || 0;
      while (currentCount < requiredCount) {
        const index = itemsRest.findIndex(resultItem => (
          resultItem.menteContent1 === name
        ));
        if (index < 0) break;
        itemsNew.push(...itemsRest.splice(index, 1));
        currentCount++;
      }
    });

    layoutResult.items = itemsNew;
  });
};

// グループごとの点検項目の点検結果からグループ単位での合否を決定する
const decideGroupAnswer = (answerArray) => {
  // 「不合格」が存在する場合は「不合格」とする
  if (answerArray.includes(Answer.NotGood)) {
    return Answer.NotGood;
  }
  // 「不合格」の条件に該当せず、
  // 「点検途中」が存在する、もしくは
  // 未実施と「合格」がいずれも存在する場合は「点検途中」とする
  if (
    answerArray.includes(Answer.Running)
    || (
      answerArray.includes(Answer.NotDateForDb)
      && answerArray.includes(Answer.Good))) {
    return Answer.Running;
  }
  // 「不合格」と「点検途中」の条件に該当せず、
  // 「合格」が存在する場合は
  // （未実施は存在しないはずなので）「合格」とする
  if (answerArray.includes(Answer.Good)) {
    return Answer.Good;
  }
  // 「不合格」と「点検途中」と「合格」の条件に該当しない場合は
  // （「未実施」もしくはダミー値しか存在しないはずなので）「未実施」とする
  return Answer.NotDateForDb;
};
// 点検日の点検項目ごとの点検結果から総合合否を決定する
const decideTotalAnswer = (answerArrayMap) => {
  // グループごとの点検結果を決定する
  const groupAnswerArray = Object.values(answerArrayMap).map(decideGroupAnswer);

  // 「不合格」が存在する場合は「不合格」とする
  if (groupAnswerArray.includes(Answer.NotGood)) {
    return StatusText.NotGood;
  }
  // 「不合格」の条件に該当せず、
  // 「点検途中」が存在する場合は「点検途中」とする
  if (groupAnswerArray.includes(Answer.Running)) {
    return StatusText.Running;
  }
  // 「不合格」と「点検途中」の条件に該当せず、
  // 「合格」が存在する場合は「合格」とする
  if (groupAnswerArray.includes(Answer.Good)) {
    return StatusText.Good;
  }
  // #9451対応時の仕様メモ：
  // 臨時的に対応するレイアウト・グループを登録するケースもあるので、
  // （「不合格」や「点検途中」のグループがない場合に）
  // グループ内がすべて合格のグループがある場合は総合合否を合格にする

  // 「不合格」と「点検途中」と「合格」の条件に該当しない場合は
  // （「未実施」しか存在しないはずなので）空欄（未実施日）とする
  return StatusText.NotDate;
};
// 点検結果履歴データを反映する
const convertGridData = (localData, resultMaster, mainteMainList, userAccount) => {
  if (!resultMaster.length) return localData;

  const mainteMainIndex = createMainteMainIndex(mainteMainList);
  const userAccountMap = createUserAccountMap(userAccount);

  // 点検結果から追加された点検項目の列のうち
  // 最新マスタ分の同一項目名の列数を考慮して
  // 点検結果を表示するのに必要な列数だけを残す補正を行う
  deleteTrailingItems(localData, resultMaster, mainteMainIndex);

  for (const rowData of localData) {
    // 検査日に対応する１行分のグリッド用データを生成する
    const rowMainteDate = getRowMainteDate(rowData);
    const answerArrayMap = {};
    let isDateFound = false;
    resultMaster.forEach((layoutResult, masterIndex) => {
      // １レイアウト分の列のデータを生成する
      if (!layoutResult) return;

      let lastUpdate = null;
      let lastUserId = null;
      const cellDisable = [];
      const layoutKey = `${layoutResult.menteLayoutCd}`;
      const mainteMain = mainteMainIndex.get(rowMainteDate, layoutResult);
      const detailHistoryNameMap = createDetailHistoryNameMap(layoutResult);
      const detailItemsByName = createDetailItemsByName(
        mainteMain?.detailList,
        detailHistoryNameMap
      );
      const itemNameOrderList = createItemNameOrderList(layoutResult.items);
      layoutResult.items.forEach((resultItem, itemIndex) => {
        // レイアウト内の点検項目の列のデータを生成する
        // 点検項目に対応する点検結果情報を探す
        let judge = Answer.NotDateForDb;
        let judgeStatus = StatusText.NotDate;

        // 点検項目は項目名ごとに列を作成するので、
        // 履歴明細側の当時の項目名と現在の列名を突き合わせる。
        const sameNameDetailItems = detailItemsByName.get(resultItem.menteContent1);
        const nameOrder = itemNameOrderList[itemIndex] || 1;
        let detailItem = sameNameDetailItems
          && nameOrder <= sameNameDetailItems.length
          && sameNameDetailItems[nameOrder - 1];
        if (!detailItem && mainteMain) {
          detailItem = mainteMain.detailByIdentity.get(createResultItemIdentityKey(resultItem));
        }
        if (detailItem) {
          // 点検日とレイアウトのコードが一致する点検結果情報の
          // 処理対象の列に対応する点検項目の点検結果情報が見つかった場合

          // 最終更新日時の情報を更新
          if (mainteMain.source.upDate) {
            lastUpdate = mainteMain.source.upDate;
          }
          // 最終更新者の情報を更新
          if (mainteMain.source.checkerId1) {
            lastUserId = mainteMain.source.checkerId1;
          }
          judge = detailItem.judge;
          // Answer.NotDate の値が残っていた場合はこの後の総合合否判定処理のために
          // Answer.NotDateForDb に置き換えておく
          if (judge === Answer.NotDate) {
            judge = Answer.NotDateForDb;
          }
          judgeStatus = convertStatus(judge);
        } else if (mainteMain) {
          // 点検日とレイアウトのコードが一致する点検結果情報が見つかったが
          // 列と項目名が一致する、点検結果が持つ点検項目数が列数に満たない場合は
          // 残りの列は点検結果登録時点では対象ではなかった項目を示すための
          // ダミー値を設定する
          judge = Answer.Dummy;
        }
        const itemKey = `${layoutKey}`;
        // #12550対応時のメモ
        // ここは本来グループごとに answerArrayMap のキー文字列を生成する場面だが
        // グループ重複排除処理によりレイアウトごとの点検結果には
        // 1グループ分しか入っていない想定でもあり、
        // レイアウト単位のキー文字列をそのまま使用することで
        // グループの情報を感知しない画面仕様と
        // 総合合否判定ロジックとの整合性を保つ
        if (!answerArrayMap[itemKey]) {
          answerArrayMap[itemKey] = [];
        }
        answerArrayMap[itemKey].push(judge);

        rowData[`column${masterIndex}${itemIndex}`] = judgeStatus;
        cellDisable[itemIndex] = !detailItem;
      });
      // レイアウト単位で点検結果が存在しなかったかどうかの判定
      const lastCellDisable = !cellDisable.includes(false);
      if (!lastCellDisable) {
        isDateFound = true;
      }

      const itemsLength = layoutResult.items.length;
      // 最終更新者列の情報を生成
      const lastUser = lastUserId && userAccountMap.get(String(lastUserId));
      const lastUserNameIndex = itemsLength;
      rowData[`column${masterIndex}${lastUserNameIndex}`] = lastUser
        ? `${lastUser.userLastName} ${lastUser.userFirstName}`
        : "";
      cellDisable[lastUserNameIndex] = lastCellDisable;
      // 最終更新日時列の情報を生成
      const lastUpdateIndex = itemsLength + 1;
      rowData[`column${masterIndex}${lastUpdateIndex}`] = lastUser && lastUpdate
        ? dayjs(lastUpdate).format("YYYY/MM/DD(dd) HH:mm")
        : "";
      cellDisable[lastUpdateIndex] = lastCellDisable;

      // グレー表示判定用のデータを入れる
      rowData.cellDisable[masterIndex] = cellDisable;
    });
    // 点検日の点検項目ごとの点検結果から総合合否を決定する
    rowData.rowTitle2 = decideTotalAnswer(answerArrayMap);

    if (!isDateFound) {
      // 点検日単位で点検結果が存在しなかった場合は
      // （点検項目が0件のレイアウトを除いて）
      // 最新のマスタに存在するレイアウトのみグレー判定結果を無効化する
      resultMaster.forEach((layoutResult, masterIndex) => {
        if (
          !layoutResult?.isCurrent
          || !layoutResult?.items?.length) return;
        // １レイアウト分の列のデータを生成する
        const latestCount = layoutResult.detailLatestCount;
        const itemCount = layoutResult.items.length;
        for (let i = 0; i < rowData.cellDisable[masterIndex].length; i++) {
          // 点検結果から追加された（最新のマスタ状態には存在しない）
          // 点検項目はグレーアウトのままにする
          if (latestCount <= i && i < itemCount) continue;
          rowData.cellDisable[masterIndex][i] = false;
        }
      });
    }
  }

  return localData;
};
// フィルター条件を適用する
const applyFilterLocalData = (localData, { dailyRunning, dailyNotGood, dailyGood, notDailyDate }) => {
  for (let i = localData.length - 1; i >= 0; i--) {
    const { rowTitle2 } = localData[i];
    if (
      (rowTitle2 === StatusText.Running && !dailyRunning)
      || (rowTitle2 === StatusText.NotGood && !dailyNotGood)
      || (rowTitle2 === StatusText.Good && !dailyGood)
      || (rowTitle2 === StatusText.NotDate && !notDailyDate)
    ) {
      localData.splice(i, 1);
    }
  }
  return localData;
};
</script>

<style>
@media print {
  /* 親(点検項目入力)のヘッダを背面に移動 */
  body:has(.daily-history-modal) .modal-mask.custom-modal .modal-header:first-of-type {
    z-index: 9;
  }
  /* ヘッダとbodyでページわかれるのを防止 */
  body:has(.daily-history-modal) .modal-mask.custom-modal .modal-wrapper {
    display: inline-block !important;
    margin-top: 1.5vh !important;
  }
}

/* 横印刷時 */
@media print and (orientation: landscape) {
  body:has(.daily-history-modal) .modal-mask.custom-modal .modal-wrapper {
    margin-top: 3vh !important;
  }
}
</style>

<style scoped>
@import "../../assets/styles/modal.css";
/* モーダル全体の設定 */
.daily-history-modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 10000;
  display: block;
}
.daily-history-modal :deep(.modal-wrapper) {
  display: block;
  width: 100%;
  height: 100%;
}
.daily-history-modal :deep(.modal-container) {
  margin: 0;
  width: 100%;
  height: 100%;
}
.modal-footer {
  border-top: 1px solid;
  border-color: var(--ntss-footer-border-color) !important;
  background-color: var(--ntss-base-background-color);
  display: flex;
  justify-content: right;
}

.list-header-th-center {
  text-align: center;
  background-color: var(--ntss-list-header-background-color);
  height: 20px;
  color: #fff;
  border: solid 1px #cccccc;
  font-weight: normal;
  white-space: nowrap;
}
.ntss-list {
  border-collapse: collapse;
  margin: 80px 0px 10px 15px;
  background-color: #fff;
}
.ntss-list-body-td {
  border: solid 1px #cccccc;
  word-break: break-all;
  white-space: nowrap;
}
.ntss-list-detail {
  border-collapse: collapse;
  margin: 0 auto;
  width: -webkit-fill-available;
  top: 0px;
  background-color: var(--ntss-list-background-color);
  height: 57px;
}
.history-header-modal {
  font-size: 1.5em;
  display: flex;
  width: 100%;
  margin-inline: 0;
}
.history-list-modal {
  width: 100%;
  padding-top: 6px;
  margin-inline: 0;
}
.distance-time {
  width: 48px;
  text-align: left;
}
.custom-ons-col {
  height: auto;
}
.custom-line-height {
  line-height: 35px;
}
.custom-h3 {
  color: #ffffff;
}
.deviceSetInfo-row-name {
  border: solid 1px var(--ntss-list-border-color);
  background-color: var(--ntss-list-background-color);
  color: var(--ntss-list-body-color);
}

.modal-body :deep(.k-grid-content > table > tbody > tr > td:has(.cell-disabled)) {
  background-color: var(--pat-viewer-ind-cond-info-disabled);
}
.modal-body {
  margin: 0;
  position: absolute;
  top: 50px;
  width: 100%;
  height: calc(100% - 70px - 2em);
  overflow-y: auto;
  color: var(--ntss-base-color);
  box-sizing: border-box;
  padding-inline: 16px;
}
.popover-row-style {
  flex-wrap: nowrap;
}
@media screen and (max-width: 624px) {
  .ntss-list {
    margin: 133px 0px 10px 15px;
  }
  .popover-row-style {
    flex-wrap: wrap;
  }
}

.custom-modal-mask {
  background: rgba(0, 0, 0, 0.8);
}

.hide-arrow-calendar::-webkit-inner-spin-button,
.hide-arrow-calendar::-webkit-calendar-picker-indicator {
  display: none;
  -webkit-appearance: none;
}

.dailyHistory-checkday-span {
  margin-right: 10px;
}
.condition-search-icon-area-here {
  float: left;
  position: absolute;
  line-height: 4em;
  margin-left: 5px;
  margin-right: 5px;
}
.modal-body :deep(.k-grid td),
.modal-body :deep(.k-grid tr) {
  border: solid 1px var(--ntss-list-border-color) !important;
  background-color: var(--ntss-list-background-color);
  color: var(--ntss-list-body-color);
}

.modal-body :deep(.k-grid .k-table-td) {
  border: solid 1px var(--ntss-list-border-color) !important;
  background-color: var(--ntss-list-background-color);
  color: var(--ntss-list-body-color);
}
.modal-body :deep(.k-grid .k-alt),
.modal-body :deep(.k-grid .k-alt td) {
  background-color: var(--ntss-list-content-2nd-background-color);
}

.modal-body :deep(.k-grid .k-alt .k-table-td) {
  background-color: var(--ntss-list-content-2nd-background-color);
}
.history-list-modal :deep(.k-grid-content td),
.history-list-modal :deep(.k-grid-content .k-table-td),
.history-list-modal :deep(.k-grid-content-locked td),
.history-list-modal :deep(.k-grid-content-locked .k-table-td),
.history-list-modal :deep(td.deviceSetInfo-row-name),
.history-list-modal :deep(td.daily-history-grid-cell) {
  height: 2em !important;
  min-height: 2em;
  box-sizing: border-box;
}

.history-list-modal :deep(.k-grid-header-wrap th),
.history-list-modal :deep(.k-grid-header-wrap .k-table-th) {
  height: auto !important;
  box-sizing: border-box;
  vertical-align: middle !important;
}

.history-list-modal :deep(.k-grid-header-locked th),
.history-list-modal :deep(.k-grid-header-locked .k-table-th),
.history-list-modal :deep(.deviceSetInfo-header-row-name) {
  box-sizing: border-box;
  vertical-align: middle !important;
}

.history-list-modal :deep(.daily-history-layout-header),
.history-list-modal :deep(.deviceSetInfo-header-first-name),
.history-list-modal :deep(.deviceSetInfo-header-secound-name) {
  text-align: center !important;
  vertical-align: middle !important;
}

.history-list-modal :deep(.deviceSetInfo-header-row-name .k-link),
.history-list-modal :deep(.deviceSetInfo-header-row-name .k-cell-inner),
.history-list-modal :deep(.deviceSetInfo-header-first-name .k-link),
.history-list-modal :deep(.deviceSetInfo-header-secound-name .k-link),
.history-list-modal :deep(.deviceSetInfo-header-first-name .k-cell-inner),
.history-list-modal :deep(.deviceSetInfo-header-secound-name .k-cell-inner) {
  display: flex !important;
  justify-content: center !important;
  align-items: center !important;
  width: 100% !important;
  height: auto !important;
  min-height: 100%;
  padding: 2px 0 !important;
  box-sizing: border-box;
  overflow: visible;
}

.history-list-modal :deep(.k-grid-header table),
.history-list-modal :deep(.k-grid-header-locked table),
.history-list-modal :deep(.k-grid-content table),
.history-list-modal :deep(.k-grid-content-locked table) {
  border-collapse: collapse;
}

/* 表头最外层右侧占位（绿色区域） */
.history-list-modal :deep(.k-grid-header) {
  position: relative;
}

.history-list-modal :deep(.k-grid-header)::after {
  content: "";
  position: absolute;
  top: 0;
  right: 0;
  bottom: 0;
  width: var(--history-header-scrollbar-gutter, 0px);
  background-color: var(--ntss-list-header-background-color);
  background-image: none;
  pointer-events: none;
}

/* 表头可横向滚动但不显示滚动条，仅保留表体底部横向滚动条 */
.history-list-modal :deep(.k-grid-header) {
  overflow: hidden;
}

/* 表头 wrap 本体不额外盖色 */
.history-list-modal :deep(.k-grid-header-wrap) {
  margin-right: 0 !important;
  overflow-x: scroll;
  scrollbar-width: none;
  -ms-overflow-style: none;
}

.history-list-modal :deep(.k-grid-header-wrap::-webkit-scrollbar) {
  display: none;
  height: 0;
}

.history-list-modal :deep(.k-grid-content),
.history-list-modal :deep(.k-grid-content-locked) {
  padding-right: 0 !important;
}

.history-list-modal :deep(.k-grid-header th),
.history-list-modal :deep(.k-grid-header .k-table-th),
.history-list-modal :deep(.deviceSetInfo-header-row-name),
.history-list-modal :deep(.deviceSetInfo-header-first-name),
.history-list-modal :deep(.deviceSetInfo-header-secound-name) {
  border-right: 1px solid #fff !important;
  border-left: none !important;
}

.history-list-modal :deep(.deviceSetInfo-header-first-name .k-column-title),
.history-list-modal :deep(.deviceSetInfo-header-secound-name .k-column-title),
.history-list-modal :deep(.daily-history-layout-header) {
  display: block;
  width: 100%;
  margin: 0;
  padding: 0;
  white-space: normal !important;
  word-break: break-all !important;
  word-wrap: break-word !important;
  text-align: center !important;
  line-height: 1.35;
  overflow: visible;
  text-overflow: clip;
}

.history-list-modal :deep(.daily-history-grid-cell) {
  text-align: center !important;
  word-break: break-all;
  white-space: normal;
}
.history-list-modal :deep(.k-grid-content-locked) {
  overflow-y: scroll !important;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: none;
  -ms-overflow-style: none;
}
.history-list-modal :deep(.k-grid-content-locked::-webkit-scrollbar) {
  display: none;
}

/* ヘッダー抽出条件 */
#daily-history-condition-list :deep(.condition-search-icon-area) {
  line-height: 4.2em;
}
#daily-history-condition-list :deep(.condition-items-area) {
  margin-left: 1.8em;
  color: #333333 !important;
}

@media print {
  /* モーダル全般 */
  .custom-modal-mask {
    background: unset;
    top: -88px;
  }
  .custom-modal-mask .modal-container {
    width: 100% !important;
  }
  .daily-history-modal {
    z-index: 9998;
  }
  .modal-footer {
    display: none;
  }

  /* ヘッダとbodyでページわかれるのを防止 */
  .daily-history-modal .modal-wrapper {
    display: inline-block !important;
    margin-top: 1.5vh !important;
  }
  /* ヘッダ */
  .ntss-list-detail .ntss-list-body-td {
    white-space: normal;
  }
  /* ベッド */
  .ntss-list-detail th:nth-child(1),
  .ntss-list-detail td:nth-child(1) { min-width: 7em; width: 7em; }
  /* 型式 */
  .ntss-list-detail th:nth-child(2),
  .ntss-list-detail td:nth-child(2) { min-width: 7em; width: 7em; }
  /* 製造番号 */
  .ntss-list-detail th:nth-child(3),
  .ntss-list-detail td:nth-child(3) { min-width: 6em; width: 6em; }
  /* 装置名 */
  .ntss-list-detail th:nth-child(4),
  .ntss-list-detail td:nth-child(4) { min-width: 8em; width: 8em; }

  /* 表部分 */
  .history-list-modal {
    width: 100%;
  }

  /** スクロールコンテナ */
  .history-list-modal :deep(.k-grid-header-wrap),
  .history-list-modal :deep(.k-grid-content) {
    overflow: hidden !important;
    height: auto !important;
  }

  /** 固定列調整 */
  .history-list-modal :deep(.k-grid-content-locked) {
    height: auto !important;
  }
  /** ヘッダのズレ原因を除去 */
  .history-list-modal :deep(.k-grid-header) {
    padding-right: 0 !important;
  }
  /** gridの幅 */
  .history-list-modal :deep(.k-grid) {
    width: 100vw;
    height: auto !important;
  }

  /** 印刷時に横スクロール右端時に強制的にスクロール位置を調整 */
  /* 右端時固定列最前面表示*/
  .history-list-modal:has(table.scroll-rightmost) :deep(.k-grid-content-locked) {
    z-index: 1;
  }
  .history-list-modal :deep(.k-grid-header-wrap:has(table.scroll-rightmost)),
  .history-list-modal :deep(.k-grid-content:has(table.scroll-rightmost)) {
    position: static;
  }
  .history-list-modal :deep(.k-grid-header-wrap .scroll-rightmost) {
    position: relative;
    float: right;
  }
}

/* 横印刷時 */
@media print and (orientation: landscape) {
  .daily-history-modal .modal-wrapper {
    margin-top: 3vh !important;
  }
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
