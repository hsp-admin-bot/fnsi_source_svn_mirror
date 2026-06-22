import { getKendoGridDataItem } from "@/functions/common/KendoFunctions";
import { bindGridEditorEnterToCloseCell, bindGridEditorDropDownListToCloseCell } from "@/compat/kendo/grid-edit";
/**
 * 共通マスタ編集画面共通コンポーネント.
 */
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";
import { deepCopy } from "@/functions/common/CommonFunctions";

import {
  getFooterMenuElement,
  getGridFooterElement,
  getMainContentAreaElement,
  getScopedElement,
  getLayoutRootElement,
  getViewportHeight,
  getLatestHeaderElement
} from "@/functions/common/LayoutMeasureHelper";

// mod #6107 2023/03/22 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
import { messageFormat } from '@/functions/common/MessageFormat';
import {
  findKendoGridRoot,
  findKendoGridContent,
  findKendoGridLockedContent,
  findKendoGridHeader,
  findKendoGridHeaderWrap,
  findKendoGridHeaderScrollHost,
  findKendoGridLockedHeader,
  findKendoGridAutoScrollable,
  findKendoGridScrollHost,
  findKendoGridSelectables,
  findKendoGridTable,
  findKendoGridLockedTable,
  findKendoGridThead,
  findKendoGridTbody,
  findKendoGridLockedTbody,
  findKendoGridVerticalScrollbar
} from '@/functions/common/KendoFunctions';
import { appendFirstValidationCallout, queryValidationElements } from '@/functions/common/KendoFunctions';
import { createViewTimingGate } from "@/utils/viewTimingGate";
const masterGridWidthRetryTimers = new WeakMap();
const MASTER_COMPONENT_TAGS_BY_NAME = {
  MachineRecordSearchComponent: "machine-record-search",
  PersonalUserSearchComponent: "personal-user-search",
  MstTreatmentStatusLayoutComponent: "mst-treatment-status-layout",
};
// mod #6107 2023/03/22 メッセージボックス全調整 張博 end

export default {
  data() {
    return {
      __masterTimingGate: null,
      __masterRawNextTick: null,
      __masterLastLayoutMetrics: {
        headerHeight: 0,
        footerMenuHeight: 0,
        gridHeaderHeight: 45,
        gridFooterHeight: 0,
        headerButtonHeight: 0
      },
      __masterValidateArrowHandler: null,
      __masterEditedRowStateFrame: null
    };
  },
  created() {
    this.__masterTimingGate = createViewTimingGate(this.$options?.name || this.masterPhysicalName || 'master-maintenance');
    this.__masterRawNextTick = this.$nextTick ? this.$nextTick.bind(this) : null;
    if (this.__masterRawNextTick) {
      const rawNextTick = this.__masterRawNextTick;
      this.$nextTick = (callback) => {
        if (typeof callback !== 'function') {
          return rawNextTick();
        }
        const token = this.captureMasterTimingToken();
        return rawNextTick(() => {
          if (!this.isMasterTimingActive(token)) {
            return;
          }
          return callback.call(this);
        });
      };
    }
  },
  computed: {
    ...mapGetters('account-edit', {
      getFontSize: 'getFontSize',
    }),
    // 内部 背景色と保存ボタンの状態が異常です start
    ...mapGetters("master-maintenance", {
      isRecordModified: "isRecordModified",
    }),
    // 内部 背景色と保存ボタンの状態が異常です end
    /**
     * フォントサイズに応じたCSSセレクタを返す.
     */
    fontSizeSet() {
      const names = ['small', 'medium', 'large', 'x-large'];
      return `font-size-set-${names[this.getFontSize]}`;
    },
  },
  // #8745 表示内容が画面上半分にしか表示されない。 林峻峰 start
  mounted() {
    // add #9590 start
    const componentTag = this.$options?._componentTag || MASTER_COMPONENT_TAGS_BY_NAME[this.$options?.name];
    if (!["machine-record-search",
          "personal-user-search",
          "mst-treatment-status-layout"].includes(componentTag)) {
      this.condition && this.setCondition(this.condition || {})
    }
    // add #9590 end
    // Vue2 と同じく document click 時に k-invalid-msg へ callout を追加する。
    // MutationObserver ではなくクリックイベントで Vue2 とトリガー条件を完全に合わせる。
    this.__masterValidateArrowHandler = () => this.handleAddValidateArrow();
    const ownerDocument = this.getMasterOwnerDocument();
    ownerDocument?.addEventListener?.('click', this.__masterValidateArrowHandler);
  },
  updated () {
    if (!this.isRecordModified) {
      const kDirtyCell = this.queryMasterAll('.k-dirty');
      if (kDirtyCell.length > 0) {
        for(let i=0; i<kDirtyCell.length; i++){
          kDirtyCell[i].setAttribute('class', '');
        }
      }
    }
  },
  beforeUnmount() {
    const gridWidthRetryTimer = masterGridWidthRetryTimers.get(this);
    if (gridWidthRetryTimer) {
      clearTimeout(gridWidthRetryTimer);
      masterGridWidthRetryTimers.delete(this);
    }
    this.__masterTimingGate?.destroy?.();
    const ownerDocument = this.getMasterOwnerDocument();
    if (this.__masterValidateArrowHandler) {
      ownerDocument?.removeEventListener?.('click', this.__masterValidateArrowHandler);
    }
    this.__masterValidateArrowHandler = null;
    if (this.__masterEditedRowStateFrame != null) {
      const ownerWindow = this.getMasterOwnerWindow?.() || globalThis;
      ownerWindow.cancelAnimationFrame?.(this.__masterEditedRowStateFrame);
      this.__masterEditedRowStateFrame = null;
    }
  },
  // #8745 表示内容が画面上半分にしか表示されない。 林峻峰 end
  methods: {
    getMasterOwnerDocument() {
      return this.getMasterScopeRoot?.()?.ownerDocument || this.$el?.ownerDocument || (typeof document !== 'undefined' ? document : null);
    },
    getMasterOwnerWindow(element = null) {
      return element?.ownerDocument?.defaultView || this.getMasterOwnerDocument?.()?.defaultView || (typeof window !== 'undefined' ? window : null);
    },
    getMasterComputedStyle(element) {
      if (!element) {
        return null;
      }
      return this.getMasterOwnerWindow(element)?.getComputedStyle?.(element) || null;
    },
    captureMasterTimingToken() {
      return this.__masterTimingGate?.capture?.() ?? 0;
    },
    isMasterTimingActive(token = null) {
      if (!this.__masterTimingGate) {
        return true;
      }
      return token == null
        ? this.__masterTimingGate.isAlive()
        : this.__masterTimingGate.isCurrent(token);
    },
    // Vue2 `handleAddValidateArrow` と同じ意図: k-invalid-msg が表示されていたら
    // callout(矢印)を追加する。Vue2 は innerHTML 置換だったが、Vue3 では scope 内の
    // 要素に limit して createElement で追加する。生成される DOM と class 名は同一。
    handleAddValidateArrow() {
      // Vue2 の実装と完全一致させる: scope 配下の最初の .k-invalid-msg に対してのみ、
      // innerHTML 末尾に <div class="k-callout k-callout-n"></div> を追加する。
      // Kendo validator は validate 時に k-invalid-msg を毎回再描画するため、
      // 追記方式でも callout が二重で積み上がることはない。
      const scope = this.getMasterScopeRoot?.() || this.$el || (typeof document !== 'undefined' ? document : null);
      this.$nextTick(() => {
        appendFirstValidationCallout(scope);
      });
    },
    // 互換維持: 旧 Vue3 実装で直接呼ばれていた API 名を、Vue2 の handleAddValidateArrow へ委譲する。
    decorateMasterValidationMessages() {
      this.handleAddValidateArrow();
      return queryValidationElements(this.getMasterScopeRoot?.() || null);
    },
    runMasterGuarded(callback, token = this.captureMasterTimingToken()) {
      if (!this.isMasterTimingActive(token) || typeof callback !== 'function') {
        return false;
      }
      callback.call(this);
      return true;
    },
    masterNextTick(callback, options = {}) {
      const scheduler = this.__masterRawNextTick || (this.$nextTick ? this.$nextTick.bind(this) : null);
      if (!scheduler || typeof callback !== 'function') {
        return Promise.resolve(false);
      }
      const token = options.token ?? this.captureMasterTimingToken();
      return scheduler(() => {
        if (!this.isMasterTimingActive(token)) {
          return false;
        }
        return callback.call(this);
      });
    },
    getMasterScopeRoot() {
      return this.$el || null;
    },
    getMasterDocument() {
      return this.getMasterScopeRoot()?.ownerDocument
        || this.getMasterLayoutRootEl()?.ownerDocument
        || null;
    },
    getMasterLayoutRootEl() {
      return getLayoutRootElement(this.getMasterScopeRoot())
        || this.getMasterScopeRoot()?.closest?.('[data-ntss-layout-root]')
        || null;
    },
    getMasterSearchRoots() {
      const roots = [];
      const pushRoot = (candidate) => {
        if (!candidate || roots.includes(candidate)) {
          return;
        }
        roots.push(candidate);
      };
      pushRoot(this.getGridRootEl());
      pushRoot(this.getMasterScopeRoot());
      pushRoot(this.getMasterLayoutRootEl());
      pushRoot(this.getMasterAppRootEl());
      pushRoot(this.getMasterDocument()?.body || null);
      return roots.filter(Boolean);
    },
    queryMasterDocument(selector) {
      if (!selector) {
        return null;
      }
      for (const scope of this.getMasterSearchRoots()) {
        const found = scope?.querySelector?.(selector);
        if (found) {
          return found;
        }
      }
      return null;
    },
    queryMasterDocumentAll(selector) {
      if (!selector) {
        return [];
      }
      const results = [];
      this.getMasterSearchRoots().forEach((scope) => {
        scope?.querySelectorAll?.(selector)?.forEach?.((element) => {
          if (!results.includes(element)) {
            results.push(element);
          }
        });
      });
      return results;
    },
    getMasterAppRootEl() {
      const scopeRoot = this.getMasterScopeRoot?.() || null;
      const ownerDocument = scopeRoot?.ownerDocument || document;
      const scopedAppRoot = scopeRoot?.nodeType === 1
        ? scopeRoot.closest?.('#app')
        : null;
      return scopedAppRoot
        || ownerDocument?.getElementById?.('app')
        || null;
    },
    getMasterVirtualScrollableWrapEl() {
      return this.getGridWidget()?.virtualScrollable?.element?.[0]
        || this.getGridScrollHostEl()?.closest?.('.k-virtual-scrollable-wrap')
        || this.getGridContentEl()?.closest?.('.k-virtual-scrollable-wrap')
        || this.getGridRootEl()?.querySelector?.('.k-virtual-scrollable-wrap')
        || this.queryMaster('.k-virtual-scrollable-wrap')
        || null;
    },
    getMasterAlertDialogs() {
      const doc = this.getMasterDocument?.() || document;
      return Array.from(doc?.getElementsByTagName?.("ons-alert-dialog") || []);
    },
    queryMaster(selector) {
      return this.getMasterScopeRoot()?.querySelector?.(selector) || null;
    },
    queryMasterAll(selector) {
      return Array.from(this.getMasterScopeRoot()?.querySelectorAll?.(selector) || []);
    },
    getMasterLayoutElements() {
      const root = this.$el || null;
      const localAll = (selector) => Array.from(root?.querySelectorAll?.(selector) || []);
      const local = (selector) => root?.querySelector?.(selector) || null;
      return {
        header: getLatestHeaderElement(root),
        footerMenu: getFooterMenuElement(root),
        gridHeader: local('#grid-header') || getScopedElement(root, '#grid-header', '[data-ntss-role="grid-header"]'),
        gridFooter: local('#grid-footer') || getGridFooterElement(root),
        headerButtonArea: local('.header-btn-area') || getScopedElement(root, '.header-btn-area'),
        mainContentArea: getMainContentAreaElement(root) || local('.main-content-area') || null
      };
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
        .map((child) => child.getBoundingClientRect?.())
        .filter(Boolean)
        .map((rect) => rect.bottom)
        .filter((value) => Number.isFinite(value));
      if (Number.isFinite(rectTop) && childBottoms.length) {
        const visualHeight = Math.max(...childBottoms) - rectTop;
        if (Number.isFinite(visualHeight) && visualHeight > 0) {
          return visualHeight;
        }
      }
      return defaultValue;
    },
    getMasterCssPixelValue(element, propertyName) {
      if (!element || !propertyName) {
        return NaN;
      }
      const inlineValue = element.style?.getPropertyValue?.(propertyName);
      const computedValue = this.getMasterComputedStyle(element)?.getPropertyValue?.(propertyName);
      const value = inlineValue || computedValue || "";
      const parsed = parseFloat(String(value).replace("px", ""));
      return Number.isFinite(parsed) ? parsed : NaN;
    },
    getMasterMainContentBaseHeight() {
      const scopeRoot = this.getMasterScopeRoot?.() || null;
      const ownerDocument = scopeRoot?.ownerDocument || document;
      const mainEl = scopeRoot?.closest?.("#main-id")
        || ownerDocument?.getElementById?.("main-id")
        || null;
      const cssHeight = this.getMasterCssPixelValue(mainEl, "--height");
      if (Number.isFinite(cssHeight) && cssHeight > 0) {
        // Vue2 と同じく footer menu 調整分 5px を差し引いた値を
        // kendo-grid-toolbar の基準高さにする。
        return cssHeight - 5;
      }
      const mainContentArea = this.getMasterLayoutElements?.().mainContentArea || null;
      const measuredHeight = this.measureMasterElementHeight(mainContentArea, NaN);
      return Number.isFinite(measuredHeight) && measuredHeight > 0 ? measuredHeight : NaN;
    },
    getMasterLayoutMetrics() {
      const elements = this.getMasterLayoutElements();
      const cache = this.__masterLastLayoutMetrics || {};
      const metrics = {
        headerHeight: this.measureMasterElementHeight(elements.header, cache.headerHeight ?? 0),
        footerMenuHeight: this.measureMasterElementHeight(elements.footerMenu, cache.footerMenuHeight ?? 0),
        gridHeaderHeight: this.measureMasterElementHeight(elements.gridHeader, cache.gridHeaderHeight ?? 45),
        gridFooterHeight: this.measureMasterElementHeight(elements.gridFooter, cache.gridFooterHeight ?? 0),
        headerButtonHeight: this.measureMasterElementHeight(elements.headerButtonArea, cache.headerButtonHeight ?? 0)
      };
      this.__masterLastLayoutMetrics = metrics;
      return { ...metrics, elements };
    },
    isMasterLayoutReady(options = {}) {
      const { requireGridFooter = false, requireGridHeader = false } = options;
      if (!this.isMasterTimingActive()) {
        return false;
      }
      const { elements, headerHeight, gridFooterHeight, gridHeaderHeight } = this.getMasterLayoutMetrics();
      if (!elements.header && !headerHeight) {
        return false;
      }
      if (requireGridFooter && !elements.gridFooter && !gridFooterHeight) {
        return false;
      }
      if (requireGridHeader && !elements.gridHeader && !gridHeaderHeight) {
        return false;
      }
      return true;
    },
    runWhenMasterLayoutReady(callback, options = {}) {
      if (!this.__masterTimingGate || typeof callback !== 'function') {
        return Promise.resolve(false);
      }
      const token = options.token ?? this.captureMasterTimingToken();
      return this.__masterTimingGate.schedule(
        options.name || 'master-layout-ready',
        () => {
          if (!this.isMasterLayoutReady(options)) {
            return false;
          }
          return this.runMasterGuarded(callback, token);
        },
        {
          token,
          retries: options.retries ?? 6,
          delay: options.delay ?? 16,
          scheduler: (job) => (this.__masterRawNextTick || this.$nextTick.bind(this))(job)
        }
      );
    },
    getMasterViewportBaseHeight(menuOffset = 0) {
      const metrics = this.getMasterLayoutMetrics();
      return {
        wh: this.windowHeight || getViewportHeight(),
        hh: metrics.headerHeight || 0,
        fmh: ((this.isDispMenu === 1 ? metrics.footerMenuHeight : 0) || 0) + menuOffset
      };
    },
    getMasterGridHeaderHeight(defaultValue = 45) {
      const value = this.getMasterLayoutMetrics().gridHeaderHeight;
      return Number.isFinite(value) ? value : defaultValue;
    },
    getMasterGridFooterHeight(defaultValue = 0) {
      const value = this.getMasterLayoutMetrics().gridFooterHeight;
      return Number.isFinite(value) ? value : defaultValue;
    },
    getMasterHeaderButtonAreaHeight(defaultValue = 0) {
      const metrics = this.getMasterLayoutMetrics();
      const value = metrics.headerButtonHeight;
      if (Number.isFinite(value) && value > 0) {
        return value;
      }
      // Vue3/Kendo 2026 の toolbar は flex 化され、Vue2 と同じ float 子要素を
      // 持つ .header-btn-area の clientHeight が 0 になる場合がある。
      // Vue2 の計算意味は「toolbar 上端から grid 上端までのボタン領域高さ」を
      // 引くことなので、DOM タグ差分ではなく実表示位置から同じ値を復元する。
      const gridRoot = this.getGridRootEl?.() || null;
      const toolbar = gridRoot?.closest?.('.k-grid-toolbar, kendo-grid-toolbar')
        || metrics.elements?.headerButtonArea?.closest?.('.k-grid-toolbar, kendo-grid-toolbar')
        || null;
      if (gridRoot && toolbar) {
        const toolbarTop = toolbar.getBoundingClientRect?.().top;
        const gridTop = gridRoot.getBoundingClientRect?.().top;
        const diff = gridTop - toolbarTop;
        if (Number.isFinite(diff) && diff > 0) {
          return diff;
        }
      }
      const headerButtonArea = metrics.elements?.headerButtonArea || null;
      if (headerButtonArea) {
        const childBottoms = Array.from(headerButtonArea.children || [])
          .map((child) => child.getBoundingClientRect?.())
          .filter(Boolean)
          .map((rect) => rect.bottom);
        const ownTop = headerButtonArea.getBoundingClientRect?.().top;
        const maxBottom = childBottoms.length ? Math.max(...childBottoms) : NaN;
        const visualHeight = maxBottom - ownTop;
        if (Number.isFinite(visualHeight) && visualHeight > 0) {
          return visualHeight;
        }
      }
      return defaultValue;
    },
    requestGridResize() {
      const gridRef = this.getGridRef();
      if (gridRef?.requestGridResize) {
        return gridRef.requestGridResize();
      }
      const widget = this.getGridWidget();
      if (widget?.resize) {
        return widget.resize();
      }
      return null;
    },
    // add #9590 start
    ...mapActions("master-maintenance", [
      "setCondition"]),
    // add #9590 end
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc start
    ...mapActions("pat-info", {
      selectPatToHeader: "selectPat",
      clearSelectedPatToHeader: "clearSelectedPat",
      setIsNullPat: "setIsNullPat"
    }),
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc end
    // 全レコードの並び順の最大値を取得
    getGridRef() {
      return this.$refs?.grid || null;
    },
    getGridWidget() {
      return this.getGridRef()?.gridWidget?.() || this.getGridRef()?.kendoWidget?.() || null;
    },
    getGridRootEl() {
      return this.getGridRef()?.gridRootEl?.() || findKendoGridRoot(this.$el) || null;
    },
    getGridElement() {
      return this.getGridRef()?.gridElement?.() || this.getGridWidget()?.element || null;
    },
    getGridWrapper() {
      return this.getGridRef()?.gridWrapper?.() || this.getGridWidget()?.wrapper || null;
    },
    getGridContentEl() {
      return this.getGridRef()?.gridContentEl?.() || findKendoGridContent(this.getGridRootEl()) || null;
    },
    getGridLockedContentEl() {
      return this.getGridLockedContentEls()[0] || null;
    },
    getGridLockedContentEls() {
      const gridRef = this.getGridRef();
      if (gridRef?.gridLockedContentEls) {
        return gridRef.gridLockedContentEls();
      }
      const gridRoot = this.getGridRootEl();
      return Array.from(gridRoot?.querySelectorAll?.('.k-grid-content-locked') || []);
    },
    getGridHeaderEl() {
      return this.getGridRef()?.gridHeaderEl?.() || findKendoGridHeader(this.getGridRootEl()) || null;
    },
    getGridHeaderWrapEl() {
      return this.getGridRef()?.gridHeaderWrapEl?.() || findKendoGridHeaderWrap(this.getGridRootEl()) || null;
    },
    getGridHeaderScrollHostEl() {
      return this.getGridRef()?.gridHeaderScrollHostEl?.() || findKendoGridHeaderScrollHost(this.getGridRootEl()) || this.getGridHeaderWrapEl() || null;
    },
    getGridLockedHeaderEl() {
      return this.getGridLockedHeaderEls()[0] || null;
    },
    getGridLockedHeaderEls() {
      const gridRef = this.getGridRef();
      if (gridRef?.gridLockedHeaderEls) {
        return gridRef.gridLockedHeaderEls();
      }
      const gridRoot = this.getGridRootEl();
      return Array.from(gridRoot?.querySelectorAll?.('.k-grid-header-locked') || []);
    },
    isMasterGridLockedLayoutReady() {
      const lockedColumns = Array.isArray(this.columns)
        ? this.columns.filter((column) => column?.locked === true && column?.hidden !== true)
        : [];
      if (lockedColumns.length === 0) {
        return !!(this.getGridRootEl() && this.getGridContentEl());
      }
      const lockedContents = this.getGridLockedContentEls();
      const lockedHeaders = this.getGridLockedHeaderEls();
      const lockedHeader = this.getGridLockedHeaderEl();
      const lockedTbody = this.getGridLockedTbodyEl();
      const lockedVisibleHeaderCount = Array.from(lockedHeader?.querySelectorAll?.('th, [role="columnheader"]') || []).filter((element) => element?.style?.display !== 'none').length;
      const lockedFirstRow = lockedTbody?.querySelector?.('tr');
      const lockedVisibleBodyCount = Array.from(lockedFirstRow?.children || []).filter((element) => element?.style?.display !== 'none').length;
      return !!(
        this.getGridWidget()
        && this.getGridRootEl()
        && this.getGridContentEl()
        && this.getGridHeaderWrapEl()
        && this.getGridLockedTableEl()
        && this.getGridLockedTbodyEl()
        && lockedContents.length === 1
        && lockedHeaders.length === 1
        && lockedVisibleHeaderCount === lockedColumns.length
        && (lockedVisibleBodyCount === 0 || lockedVisibleBodyCount === lockedColumns.length)
      );
    },
    runWhenMasterGridLockedLayoutReady(callback, options = {}) {
      if (!this.__masterTimingGate || typeof callback !== 'function') {
        return Promise.resolve(false);
      }
      const token = options.token ?? this.captureMasterTimingToken();
      return this.__masterTimingGate.schedule(
        options.name || 'master-grid-locked-layout-ready',
        () => {
          if (!this.isMasterGridLockedLayoutReady()) {
            return false;
          }
          return this.runMasterGuarded(callback, token);
        },
        {
          token,
          retries: options.retries ?? 10,
          delay: options.delay ?? 16,
          scheduler: (job) => ((globalThis.requestAnimationFrame || ((cb) => setTimeout(cb, 16)))(() => (this.__masterRawNextTick || this.$nextTick.bind(this))(job)))
        }
      );
    },
    getGridAutoScrollableEl() {
      return this.getGridRef()?.gridAutoScrollableEl?.() || findKendoGridAutoScrollable(this.getGridRootEl()) || this.getGridContentEl();
    },
    getGridScrollHostEl() {
      return this.getGridRef()?.gridScrollHostEl?.() || findKendoGridScrollHost(this.getGridRootEl()) || this.getGridAutoScrollableEl() || this.getGridContentEl();
    },
    getGridSelectableTables() {
      return this.getGridRef()?.gridSelectableTables?.() || findKendoGridSelectables(this.getGridRootEl());
    },
    isMasterGridEditInteractionActive() {
      const gridRef = this.getGridRef();
      if (gridRef?.isGridEditInteractionActive) {
        return gridRef.isGridEditInteractionActive();
      }
      const gridRoot = this.getGridRootEl();
      if (!gridRoot || typeof gridRoot.querySelector !== 'function') {
        return false;
      }
      return !!gridRoot.querySelector('.k-edit-cell, .k-grid-edit-row, .k-grid-edit-cell, td.k-edit-cell, tr.k-grid-edit-row');
    },
    isMasterGridStructuralRebuildPending() {
      const gridRef = this.getGridRef();
      return !!(gridRef?.isStructuralRebuildPending?.());
    },
    requestMasterGridStructuralRebuild(options = {}) {
      const gridRef = this.getGridRef();
      if (!gridRef?.rebuildGrid) {
        return Promise.resolve(false);
      }
      return gridRef.rebuildGrid({ preserveScroll: options?.preserveScroll !== false });
    },
    getGridTableEl() {
      return this.getGridRef()?.gridTableEl?.() || this.getGridWidget()?.table?.[0] || findKendoGridTable(this.getGridRootEl()) || null;
    },
    getGridLockedTableEl() {
      return this.getGridRef()?.gridLockedTableEl?.() || findKendoGridLockedTable(this.getGridRootEl()) || null;
    },
    getGridTheadEl() {
      return this.getGridRef()?.gridTheadEl?.() || this.getGridWidget()?.thead?.[0] || findKendoGridThead(this.getGridRootEl()) || null;
    },
    getGridTbodyEl() {
      return this.getGridRef()?.gridTbodyEl?.() || this.getGridWidget()?.tbody?.[0] || findKendoGridTbody(this.getGridRootEl()) || null;
    },
    getGridLockedTbodyEl() {
      return this.getGridRef()?.gridLockedTbodyEl?.() || findKendoGridLockedTbody(this.getGridRootEl()) || null;
    },
    getGridVerticalScrollbarEl() {
      return this.getGridRef()?.gridVerticalScrollbarEl?.() || this.getGridWidget()?.virtualScrollable?.verticalScrollbar?.[0] || findKendoGridVerticalScrollbar(this.getGridRootEl()) || null;
    },
    getGridBodyRows() {
      return Array.from(this.getGridTbodyEl()?.children || []);
    },
    getGridLockedBodyRows() {
      return Array.from(this.getGridLockedTbodyEl()?.children || []);
    },
    getGridVirtualScrollable() {
      return this.getGridRef()?.gridVirtualScrollable?.() || this.getGridWidget()?.virtualScrollable || null;
    },
    getGridDataSource() {
      return this.getGridRef()?.gridDataSource?.() || this.getGridWidget()?.dataSource || this.getGridRef()?.dataSource || null;
    },
    setGridDataSource(dataSource) {
      const gridRef = this.getGridRef();
      if (gridRef?.setGridDataSource) {
        return gridRef.setGridDataSource(dataSource);
      }
      const widget = this.getGridWidget();
      if (widget?.setDataSource && dataSource && widget.dataSource !== dataSource) {
        widget.setDataSource(dataSource);
      } else if (widget && dataSource !== undefined) {
        widget.dataSource = dataSource;
      }
      if (gridRef && Object.prototype.hasOwnProperty.call(gridRef, 'dataSource')) {
        gridRef.dataSource = dataSource;
      }
      return dataSource;
    },
    getGridColumns() {
      return this.getGridRef()?.gridColumns?.() || this.getGridWidget()?.columns || [];
    },
    getGridColumnByField(field) {
      return this.getGridRef()?.gridColumnByField?.(field) || this.getGridColumns().find((item) => item?.field === field) || null;
    },
    getGridFirstVisibleColumn() {
      return this.getGridRef()?.gridFirstVisibleColumn?.() || this.getGridColumns().find((item) => item?.hidden !== true && item?.field !== 'dummy') || null;
    },
    resizeGridColumn(column, width) {
      if (!column) return null;
      return this.getGridRef()?.resizeGridColumn?.(column, width) || this.getGridWidget()?.resizeColumn?.(column, width) || null;
    },
    resizeGridColumnByField(field, width) {
      const column = this.getGridColumnByField(field);
      return column ? this.resizeGridColumn(column, width) : null;
    },
    resizeFirstVisibleGridColumn(width = null) {
      const column = this.getGridFirstVisibleColumn();
      if (!column) return null;
      const nextWidth = width == null ? this.resolveGridColumnResizeWidth(column) : width;
      return this.resizeGridColumn(column, nextWidth);
    },
    resolveGridColumnResizeWidth(column, sourceColumn = null) {
      if (!column) {
        return null;
      }
      const baseColumn = sourceColumn
        || (Array.isArray(this.columns)
          ? this.columns.find((item) => item?.field === column?.field && item?.hidden !== true)
          : null);
      const normalizeWidth = (candidate) => {
        if (typeof candidate === 'number' && Number.isFinite(candidate) && candidate > 0) {
          return `${candidate}px`;
        }
        if (typeof candidate !== 'string') {
          return null;
        }
        const raw = candidate.trim();
        if (!raw) {
          return null;
        }
        if (/^-?\d+(\.\d+)?(px|em|rem|%)$/i.test(raw)) {
          return raw;
        }
        const numeric = Number.parseFloat(raw);
        if (Number.isFinite(numeric) && numeric > 0) {
          return `${numeric}px`;
        }
        return null;
      };
      return normalizeWidth(baseColumn?.width) || normalizeWidth(column?.width);
    },
    autoFitGridColumn(column) {
      if (!column) return null;
      return this.getGridRef()?.autoFitGridColumn?.(column) || this.getGridWidget()?.autoFitColumn?.(column) || null;
    },
    clearGridSelection() {
      return this.getGridRef()?.clearGridSelection?.() || this.getGridWidget()?.clearSelection?.() || null;
    },
    getGridSelectedRow() {
      return this.getGridRef()?.gridSelectedRow?.() || (() => {
        const selection = this.getGridWidget()?.select?.();
        if (!selection) return null;
        if (selection.closest) {
          const row = selection.closest('tr');
          return row?.[0] || row || null;
        }
        return selection?.[0] || selection || null;
      })();
    },
    getGridDataItem(row) {
      return this.getGridRef()?.gridDataItem?.(row) || this.getGridWidget()?.dataItem?.(row) || null;
    },
    getGridSelectedDataItem() {
      return this.getGridRef()?.gridSelectedDataItem?.() || this.getGridDataItem(this.getGridSelectedRow()) || null;
    },
    refreshGrid() {
      return this.getGridRef()?.refreshGrid?.() || this.getGridRef()?.refresh?.() || this.getGridWidget()?.refresh?.() || null;
    },
    getGridScrollContainer() {
      return this.getGridScrollHostEl() || this.getGridAutoScrollableEl() || this.getGridContentEl();
    },
    getGridScrollPosition() {
      if (this.getGridRef()?.gridScrollPosition) {
        return this.getGridRef().gridScrollPosition();
      }
      const scrollable = this.getGridScrollContainer();
      const verticalScrollbar = this.getGridVerticalScrollbarEl();
      return {
        left: scrollable?.firstChild?.scrollLeft ?? scrollable?.scrollLeft ?? 0,
        top: verticalScrollbar?.scrollTop ?? scrollable?.lastChild?.scrollTop ?? scrollable?.scrollTop ?? 0
      };
    },
    cacheGridScrollPosition(target = null) {
      const position = this.getGridScrollPosition();
      if (target && typeof target === 'object') {
        target.top = position.top;
        target.left = position.left;
      }
      return position;
    },
    setGridScrollPosition(position = {}) {
      if (this.getGridRef()?.scrollGridTo) {
        this.getGridRef().scrollGridTo(position);
        return;
      }
      const scrollable = this.getGridScrollContainer();
      const left = Number.isFinite(position?.left) ? position.left : null;
      const top = Number.isFinite(position?.top) ? position.top : null;
      if (scrollable) {
        if (left !== null) {
          if (scrollable.firstChild) scrollable.firstChild.scrollLeft = left;
          scrollable.scrollLeft = left;
        }
        if (top !== null) {
          if (scrollable.lastChild) scrollable.lastChild.scrollTop = top;
          scrollable.scrollTop = top;
        }
      }
      const verticalScrollbar = this.getGridVerticalScrollbarEl();
      if (verticalScrollbar && top !== null) {
        verticalScrollbar.scrollTop = top;
      }
    },
    getMasterGridBottomScrollTop() {
      const scrollable = this.getGridScrollContainer();
      const verticalScrollbar = this.getGridVerticalScrollbarEl();
      return Math.max(
        Number(scrollable?.scrollHeight || 0),
        Number(scrollable?.lastChild?.scrollHeight || 0),
        Number(verticalScrollbar?.scrollHeight || 0)
      );
    },
    scheduleMasterGridScrollToAddedRow() {
      this.__masterScrollToAddedRow = true;
      const token = this.captureMasterTimingToken?.();
      const run = (done = false) => {
        if (this.isMasterTimingActive && !this.isMasterTimingActive(token)) {
          return;
        }
        if (!this.__masterScrollToAddedRow) {
          return;
        }
        const top = Math.max(Number(this.lastScrollTop || 0), this.getMasterGridBottomScrollTop());
        this.setGridScrollPosition({ top, left: Number(this.lastScrollLeft || this.scrollPosition?.left || 0) });
        if (done) {
          this.__masterScrollToAddedRow = false;
        }
      };
      const ownerWindow = this.getMasterOwnerWindow?.(this.getGridRootEl?.()) || globalThis;
      this.$nextTick?.(() => {
        run();
        (ownerWindow.requestAnimationFrame || ((callback) => ownerWindow.setTimeout?.(callback, 16) || setTimeout(callback, 16)))(() => run());
        ownerWindow.setTimeout?.(() => run(true), 80);
      });
    },
    setGridScrollPositionLeft(position = {}) {
      this.setGridScrollPosition({ left: position?.left || 0 });
    },
    syncMasterGridEditedRowState() {
      this.getGridRef?.()?.syncLegacyDirtyCellMarkers?.();
      this.editBackgroundColor?.();
    },
    scheduleMasterGridEditedRowStateSync() {
      if (this.__masterEditedRowStateFrame != null) {
        return;
      }
      const token = this.captureMasterTimingToken?.();
      const ownerWindow = this.getMasterOwnerWindow?.(this.getGridRootEl?.()) || globalThis;
      const scheduleFrame = ownerWindow.requestAnimationFrame || ((callback) => ownerWindow.setTimeout?.(callback, 16) || setTimeout(callback, 16));
      this.__masterEditedRowStateFrame = scheduleFrame(() => {
        this.__masterEditedRowStateFrame = null;
        if (this.isMasterTimingActive && !this.isMasterTimingActive(token)) {
          return;
        }
        this.syncMasterGridEditedRowState();
      });
    },
    onDataBoundKendoGrid() {
      this.scheduleMasterGridEditedRowStateSync();
    },
    getMaxSortRank() {
      if (this.getFilteredMasterRecordList.data.length > 0) {
        return this.getFilteredMasterRecordList.data.reduce(
          (a, b) => Math.max(a, +b.sortRank),
          0,
        );
      }
      return 0;
    },
    calculateColumnsWidth() {
      // mod redmine 4529 小窓表示にすると設定項目が見切れる 宋qy start
      // mod redmine 4530 小窓時に並び順表示ボタンを押下するとレイアウトが崩れる 宋qy start
      if (this.masterPhysicalName == 'mst_taboo_allergy' || this.masterPhysicalName == 'mst_transport' ) {
        this.columnWidth = 12;
      // mod redmine 4530 小窓時に並び順表示ボタンを押下するとレイアウトが崩れる 宋qy end
      // mod redmine 4552 並び順を表示するとレイアウトが崩れる 宋qy start
      } else if (this.masterPhysicalName == 'mst_medicine') {
        this.columnWidth = 13;
      // mod redmine 4552 並び順を表示するとレイアウトが崩れる 宋qy end
      } else {
        const appRootEl = this.getMasterAppRootEl?.();
        const ownerWindow = this.getMasterOwnerWindow(appRootEl);
        const appRootWidth = appRootEl?.nodeType === 1
          ? parseFloat(ownerWindow?.getComputedStyle?.(appRootEl, null)?.getPropertyValue?.('width') || 0)
          : ownerWindow?.innerWidth || globalThis?.innerWidth || 0;
        this.columnWidth = appRootWidth > 1000 ? 14 : 9;
      }
      // mod redmine 4529 小窓表示にすると設定項目が見切れる 宋qy end
      // add redmine 4562 小窓時にマスタ画面を開くと一部の項目が見切れる 孔 start
      // 最大7文字
      if (
        this.masterPhysicalName === 'sys_facility'
        || this.masterPhysicalName === 'mst_wheel_chair'
        || this.masterPhysicalName === 'mst_insurance'
        || this.masterPhysicalName === 'mst_pat_event_sub_category'
        || this.masterPhysicalName === 'mst_pat_event_data_template'
        || this.masterPhysicalName === 'mst_medicine_mix'
        || this.masterPhysicalName === 'mst_medicine_group'
        || this.masterPhysicalName === 'mst_spitz'
        || this.masterPhysicalName === 'mst_trend_graph_template'
        || this.masterPhysicalName === 'mst_water_survey_point'
      ) {
        this.columnWidth = this.columnWidth > 10 ? this.columnWidth : 10
      }
      // 最大8文字
      if (
        this.masterPhysicalName === 'mst_user'
        || this.masterPhysicalName === 'mst_machine'
        || this.masterPhysicalName === 'mst_infection'
        || this.masterPhysicalName === 'mst_course'
        || this.masterPhysicalName === 'mst_treatment_set'
        || this.masterPhysicalName === 'mst_medicine_set'
        || this.masterPhysicalName === 'mst_monitor_graph'
        || this.masterPhysicalName === 'mst_vital_graph'
        || this.masterPhysicalName === 'mst_exam_set'
        || this.masterPhysicalName === 'mst_destination_group'
        || this.masterPhysicalName === 'mst_mainte_detail'
        || this.masterPhysicalName === 'mst_water_survey_type'
      ) {
        this.columnWidth = this.columnWidth > 11 ? this.columnWidth : 11
      }
      // 最大9文字
      if (
        this.masterPhysicalName === 'mst_device_edge'
        || this.masterPhysicalName === 'mst_medicine_support'
        || this.masterPhysicalName === 'mst_equipment'
        || this.masterPhysicalName === 'mst_rad_set'
        || this.masterPhysicalName === 'mst_bbs_kind'
      ) {
        this.columnWidth = this.columnWidth > 12 ? this.columnWidth : 12
      }
      // 最大10文字
      if (
        this.masterPhysicalName === 'mst_disease'
        || this.masterPhysicalName === 'mst_dialyzer'
        || this.masterPhysicalName === 'mst_equipment_set'
      ) {
        this.columnWidth = this.columnWidth > 13 ? this.columnWidth : 13
      }
      // 最大11文字
      if (
        this.masterPhysicalName === 'mst_facility'
        || this.masterPhysicalName === 'mst_job'
        || this.masterPhysicalName === 'mst_implant'
        || this.masterPhysicalName === 'mst_medicate_timing'
        || this.masterPhysicalName === 'mst_round_type'
        || this.masterPhysicalName === 'mst_add_monitor'
      ) {
        this.columnWidth = 14
      }
      // 最大12文字
      if (this.masterPhysicalName === 'mst_room_bed_group') {
        this.columnWidth = 15
      }
      // 最大18文字
      if (this.masterPhysicalName === 'sys_medicine') {
        this.columnWidth = 19
      }
      // add redmine 4562 小窓時にマスタ画面を開くと一部の項目が見切れる 孔 start
    },
    calculateGridWidth() {
      // 描画後に実行
      const token = this.captureMasterTimingToken();
      if (this.isMasterGridEditInteractionActive()) {
        return;
      }
      const scheduleGridWidthRetry = () => {
        if (masterGridWidthRetryTimers.has(this)) {
          return;
        }
        const timer = setTimeout(() => {
          masterGridWidthRetryTimers.delete(this);
          this.masterNextTick(() => {
            if (!this.isMasterTimingActive(token)) {
              return;
            }
            this.calculateGridWidth();
          }, { token });
        }, 16);
        masterGridWidthRetryTimers.set(this, timer);
      };
      if (this.isMasterGridStructuralRebuildPending()) {
        // Vue3/Kendo Native では構造再構築中に ready 判定が一瞬 true になる場合がある。
        // timing gate 経由で自分自身を同期再入させず、Vue2 と同じ描画後再計算に寄せる。
        scheduleGridWidthRetry();
        return;
      }
      const hasLockedColumns = Array.isArray(this.columns)
        && this.columns.some((column) => column?.locked === true && column?.hidden !== true);
      if (hasLockedColumns && !this.isMasterGridLockedLayoutReady()) {
        if (!masterGridWidthRetryTimers.has(this)) {
          this.runWhenMasterGridLockedLayoutReady(() => {
            scheduleGridWidthRetry();
          }, {
            token,
            name: 'master-grid-width-layout-ready'
          });
        }
        return;
      }
      const gridRootEl = this.getGridRootEl();
      const gridContentEl = this.getGridContentEl();
      const gridLockedContentEl = this.getGridLockedContentEl();
      const gridHeaderWrapEl = this.getGridHeaderWrapEl();
      const gridLockedHeaderEl = this.getGridLockedHeaderEl();
      const gridScrollEl = this.getGridScrollContainer();
      if (gridLockedContentEl) {
        const visibleLockedColumns = this.columns
          .filter(col => col.locked === true && col.hidden === false);
        const lockedColumns = visibleLockedColumns.length;

        // Vue3/Kendo 2026 では、前回計算時に付与した scroll/header 幅が
        // k-grid 自体の clientWidth に再流入し、1e+06px のような異常幅に増幅する場合がある。
        // Vue2 は親コンテナ幅を基準に固定列/可変列を再配分していたため、ここでも画面側コンテナ幅を基準にする。
        const parseWidthPx = (value) => {
          if (typeof value === 'number') {
            return Number.isFinite(value) ? value : NaN;
          }
          if (typeof value !== 'string') {
            return NaN;
          }
          const normalizedValue = value.trim();
          const matched = normalizedValue.match(/^([-+]?\d+(?:\.\d+)?(?:e[-+]?\d+)?)px$/i);
          if (matched) {
            return Number(matched[1]);
          }
          return Number.parseFloat(normalizedValue);
        };
        const resolveStableGridBaseWidth = () => {
          const candidates = [
            gridRootEl?.parentElement?.clientWidth,
            gridRootEl?.closest?.('.k-grid-toolbar')?.clientWidth,
            gridRootEl?.closest?.('.ntss-list')?.clientWidth,
            gridRootEl?.closest?.('.main-content-area')?.clientWidth,
            this.getMasterAppRootEl?.()?.clientWidth,
            gridRootEl?.clientWidth
          ];
          return candidates.find((value) => Number.isFinite(value) && value > 0 && value < 100000) || 0;
        };
        const resetRunawayWidth = (element, baseWidth) => {
          if (!element || !baseWidth) return;
          const width = parseWidthPx(element.style?.width || '');
          if (Number.isFinite(width) && width > baseWidth * 2) {
            element.style.width = '';
          }
        };

        // Vue2 と同じく、固定列幅は「表示固定列数 - ダミー列」× columnWidth で算出する。
        // Kendo 2026 の colgroup には hidden 列や dummy 列の px 幅が混在するため、列ごとの DOM 幅を合算しない。
        const sortColumn = this.isSortMode ? 0 : 1;
        let lockedColumnWidth = (lockedColumns - sortColumn) * this.columnWidth;
        if (this.lockedColumnsWidth) {
          lockedColumnWidth = this.lockedColumnsWidth;
        }
        // リサイズする前のscroll値を取得する
        let tmpScrollLeft = 0;
        let tmpScrollTop = 0;
        if (this.editFlg) {
          tmpScrollLeft = this.scrollLeft;
          tmpScrollTop = this.scrollTop;
          this.editFlg = false;
        } else {
          const scrollPosition = this.getGridScrollPosition();
          tmpScrollLeft = scrollPosition.left || 0;
          tmpScrollTop = scrollPosition.top || 0;
        }

        // スマートフォン以外で固定行有：空白行幅の調整値
        const targetWidth = ((this.androidFlg || this.iosFlg) || lockedColumnWidth == 0) ? 0 : 14;
        // kendoGridのリサイズを呼び出して自動リサイズがされないケースがある問題に対応
        if (this.getGridWidget() != null) {
          const firstVisibleColumn = this.getGridFirstVisibleColumn();
          if (firstVisibleColumn) {
            const setWidth = this.resolveGridColumnResizeWidth(firstVisibleColumn);
            const currentWidth = typeof firstVisibleColumn.width === 'string'
              ? firstVisibleColumn.width.trim()
              : (Number.isFinite(firstVisibleColumn.width) ? `${firstVisibleColumn.width}px` : '');
            if (setWidth && currentWidth !== setWidth) {
              this.resizeGridColumn(firstVisibleColumn, setWidth);
            }
          }
        }
        // 固定列の幅確保
        // Vue2 と同じく、isSortMode の場合は純粋な em 幅、それ以外は末尾に +10px する。
        // Vue3 では width が px 指定された列も存在し得るため、既存の em 幅と px 幅をまとめる。
        const lockedWidthStyle = (() => {
          if (lockedColumnWidth === 0) {
            return '10px';
          }
          return this.isSortMode ? `${lockedColumnWidth}em` : `calc(${lockedColumnWidth}em + 10px)`;
        })();
        if (gridLockedHeaderEl) gridLockedHeaderEl.style.width = lockedWidthStyle;
        if (gridLockedContentEl) gridLockedContentEl.style.width = lockedWidthStyle;
        // 画面幅よりも固定列の幅が大きくなった場合、可変列のヘッダが見切れるため
        // グリッドサイズを画面幅以上に拡張する
        let stableGridBaseWidth = resolveStableGridBaseWidth();
        resetRunawayWidth(gridHeaderWrapEl, stableGridBaseWidth);
        resetRunawayWidth(gridScrollEl, stableGridBaseWidth);
        if (gridRootEl && gridLockedHeaderEl && stableGridBaseWidth < gridLockedHeaderEl.clientWidth) {
          // グリッドサイズ拡張
          gridRootEl.style.width = `${gridLockedHeaderEl.clientWidth + 100 + targetWidth}px`;
          stableGridBaseWidth = gridLockedHeaderEl.clientWidth + 100 + targetWidth;
          if (gridHeaderWrapEl) {
            gridHeaderWrapEl.style.width = `${100 + targetWidth}px`;
          }
        } else {
          gridRootEl.style.width = 'auto';
          stableGridBaseWidth = resolveStableGridBaseWidth() || stableGridBaseWidth || gridRootEl.clientWidth;
          const headerLockWidth = Math.max(0, (stableGridBaseWidth - (gridLockedHeaderEl?.clientWidth || 0)) + targetWidth);
          if (gridHeaderWrapEl) {
            gridHeaderWrapEl.style.width = `${headerLockWidth}px`;
          }
          let contentScrollableWidth = Math.max(0, stableGridBaseWidth - (gridLockedContentEl?.clientWidth || 0));
          const arr = ['sys_facility', 'mst_facility', 'mst_favorite_facility'];
          let mstArr = ['mst_user', 'mst_dialyzer', 'mst_medicine', 'mst_equipment', 'mst_obs_kind', 'mst_procedure',
                        'mst_water_survey_type', 'mst_water_survey_point', 'mst_pat_memo', 'mst_pat_list_layout'];
          if (arr.includes(this.masterPhysicalName) && !this.androidFlg && !this.iosFlg && lockedColumnWidth !== 0 ||
              ((lockedColumns === 1 && this.isSortMode) || mstArr.includes(this.masterPhysicalName))
            ) {
            contentScrollableWidth += 17;
          }
          if (gridScrollEl) {
            gridScrollEl.style.width = `${contentScrollableWidth}px`;
          }
        }

        if (gridContentEl
          && gridLockedContentEl
          && gridLockedContentEl.clientHeight !== gridContentEl.clientHeight
          && !this.androidFlg && !this.iosFlg
        ) {
          gridLockedContentEl.style.height = `${gridContentEl.offsetHeight - 17}px`;
          }
        // add 医療材料セットマスタ スクロール位置を取得 start 鞠
        if (this.masterPhysicalName == 'mst_equipment') {
          this.setScrollPositionLeft(this.scrollPosition);
        }
        // add 医療材料セットマスタ スクロール位置を取得 end 鞠
        // 固定列の幅確保後、リサイズする前のscroll値を設定
        setTimeout(() => {
            if (gridScrollEl) {
            gridScrollEl.scrollLeft = tmpScrollLeft;
            gridScrollEl.scrollTop = tmpScrollTop;
          }
        });
        // 施設マスタ 並び順の行と行がずれる 宋qy start
        if (this.masterPhysicalName == 'mst_facility') {
          const selectableTables = this.getGridSelectableTables();
          var table0 = selectableTables[0];// 固定列table
          var rows0 = table0?.rows || [];
          var table1 = selectableTables[1];// 左右移動列table
          var rows1 = table1.rows;
          for(var i=0; i < rows0.length; i++){
            var row0 = rows0[i];
            var row1 = rows1[i];
            if (row0.clientHeight < 65 && row1.clientHeight >= 65) {
              row0.style.height = `${65}px`;
            }
          }
        }
        // 施設マスタ 並び順の行と行がずれる 宋qy end
      }
    },
    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      if (this.editingFlg || this.isMasterGridEditInteractionActive() || this.isMasterGridStructuralRebuildPending()) {
        return false;
      }
      if (!this.isMasterLayoutReady()) {
        this.runWhenMasterLayoutReady(() => {
          this.calculateGridHeight();
        }, {
          name: `${this.$options?.name || this.masterPhysicalName || 'master'}:calculate-grid-height`,
          retries: 8,
          delay: 16
        });
        return false;
      }
      const { wh, hh, fmh } = this.getMasterViewportBaseHeight(5);
      let kendoToolbarHeight = wh - hh - fmh;
      const mainContentBaseHeight = this.getMasterMainContentBaseHeight();
      if (Number.isFinite(mainContentBaseHeight) && mainContentBaseHeight > 0) {
        // Vue3 では windowHeight / footer menu の取得時差により Vue2 より大きい値が
        // 入ることがある。Vue2 の DOM では #main-id の --height から 5px を引いた値が
        // toolbar 基準高さなので、その上限でクランプする。
        kendoToolbarHeight = Math.min(kendoToolbarHeight, mainContentBaseHeight);
      }
      this.kendoGridToolbarHeight = kendoToolbarHeight > 100 ? kendoToolbarHeight : 100;
      // 追加ボタンや並び替えボタンエリアの高さ
      let ghd = this.getMasterGridHeaderHeight(45);
      // キャンセルボタンや保存ボタンエリアの高さ
      let gfh = this.getMasterGridFooterHeight(0);
      // グリッドの高さ
      // add 鞠 start 患者メモの一覧と保存ボタンの間に無駄な余白がある 4550
      let tableToolbar = this.getMasterHeaderButtonAreaHeight(0);
      if (this.masterPhysicalName == 'mst_pat_memo') {
        /** 
         * NOTE: 患者メモマスタ
         * 本画面は、一覧上部に追加などのボタンが無いため、そのエリアの高さ分の調整をここで実施
         * ただし、モバイルでアクセスした場合、トグルが表示されるため、その考慮も含めて調整している
         * (let ghd = 45)
         */
        const headerHeight = this.getMasterLayoutElements().gridHeader ? 0 : 45;
        this.kendoGridHeight = this.kendoGridToolbarHeight - (gfh + ghd) + headerHeight;
      }else{
      // add 鞠 end 患者メモの一覧と保存ボタンの間に無駄な余白がある 4550
        // this.kendoGridHeight = this.kendoGridToolbarHeight - gfh;
        this.kendoGridHeight = this.kendoGridToolbarHeight - (gfh + tableToolbar);
      }
      const gridRootForHeight = this.getGridRootEl();
      if (gridRootForHeight && Number.isFinite(this.kendoGridHeight)) {
        gridRootForHeight.style.height = `${this.kendoGridHeight}px`;
        this.requestGridResize();
      }
        // mod redmine 6238 標準医薬品マスタでデータが表示されない 宋qy start
        const virtualScrollableWrap = this.getMasterVirtualScrollableWrapEl();
        if((this.masterPhysicalName == 'mst_medicine' || this.masterPhysicalName == 'mst_disease') && virtualScrollableWrap){
        // mod redmine 6238 標準医薬品マスタでデータが表示されない 宋qy end
          virtualScrollableWrap.scrollTop = 0;
        }
        // add 鞠 start 外スクロールを隠す 4559文字サイズ：特大の際にレイアウトが崩れる
        // mod #8745 【デグレ】マスタにて追加をし行が増えると縦横のスクロールが発生する。テキストボックスが切れる。 林峻峰 start
        // if (this.masterPhysicalName == 'mst_medicine_set' || this.masterPhysicalName == 'mst_treatment') {
        const masterPhysicalNameGroup = ['mst_medicine_set', 'mst_device_edge', 'mst_treatment', 'mst_job', 'mst_machine', 'mst_bed', 'mst_room_bed_group', 'mst_wheel_chair', 'mst_relationship', 'mst_taboo_allergy', 'mst_infection', 'mst_implant', 'mst_severity', 'mst_transport', 'mst_dialysis_difficulty', 'mst_course', 'mst_ward', 'mst_disease', 'mst_insurance', 'mst_va', 'mst_medicate_timing', 'mst_medicine_class', 'mst_equipment_class', 'mst_equipment_set', 'mst_round_type', 'mst_add_monitor', 'mst_bbs_kind', 'mst_pat_viewer_layout', 'mst_treatment_status_layout', 'mst_com_fixed_phrase', 'mst_destination_group'];
        if (masterPhysicalNameGroup.includes(this.masterPhysicalName)) {
        // mod #8745 【デグレ】マスタにて追加をし行が増えると縦横のスクロールが発生する。テキストボックスが切れる。 林峻峰 end
          const mainContentArea = this.getMasterLayoutElements().mainContentArea || getMainContentAreaElement(this.getMasterScopeRoot());
          if (mainContentArea) {
            mainContentArea.style.overflowY = 'hidden';
            mainContentArea.style.overflowX = 'hidden';
          }
        }
        // add 鞠 end 外スクロールを隠す 4559文字サイズ：特大の際にレイアウトが崩れる
        const verticalScrollbar = this.getGridVerticalScrollbarEl();
        if((this.masterPhysicalName == 'mst_machine_record_control') && this.iosFlg && verticalScrollbar) {
          verticalScrollbar.style.width = '100%';
          verticalScrollbar.style.zIndex = '-1';
        }
    },
    changeEditColor(currentTrc, currentLockTrc) {
      let edited = false;
      // 変更されたセルの文字色を変更(固定列と可変列の行数は一致)
      for (let lockClCount = 0; lockClCount < currentLockTrc.length; lockClCount++) {
        // 固定列セル:並び順以外の編集列
        if (
          this.isEditRow(currentLockTrc[lockClCount])
          && lockClCount !== this.getColumnIndex('sortRank')
        ) {
          currentLockTrc[lockClCount]?.classList?.add('master-edited-cell');
          edited = true;
        }
      }

      for (let clCount = 0; clCount < currentTrc.length; clCount++) {
        // 可変列セル
        if (
          this.isEditRow(currentTrc[clCount])
        ) {
          currentTrc[clCount]?.classList?.add('master-edited-cell');
          edited = true;
        }
      }
      return edited;
    },
    editBackgroundColor(masterName = null) {
      this.$nextTick(() => {
        // グリッドが表示されていなかったら処理終了
        const gridHeader = this.getGridHeaderEl();
        // gridを使用していないマスタ(e.g.愁訴処置マスタ)があるため、gridHeaderの存在有無もチェックする
        if (!gridHeader || gridHeader.textContent === ' ') {
          return;
        }
        gridHeader?.classList?.add('master-grid-header');

        const tbodyc = this.getGridBodyRows();
        const lockTbodyc = this.getGridLockedBodyRows();
        if (!tbodyc.length || !lockTbodyc.length) {
          return;
        }
        // 固定列、可変列、データソースの取得
        const gridData = this.getGridDataSource();
        const dataItem = this.masterPhysicalName === 'mst_exam_item' ? gridData._data : gridData.data
        // 列の行数は固定・可変で同一なため可変列の行数を使用
        let newArr = this.getMasterRecordList?.data?.filter(item => {
          return item.isDisp === "1"
        })
        // newArr.forEach(item => {
        //   item.wheelChairWeight = Number(item.wheelChairWeight).toFixed(2)
        // })
        let oldArr = this.getMasterRecordListOld && this.getMasterRecordListOld.filter(item => {
          return item.isDisp === "1"
        })
        for (let rwCount = 0; rwCount < tbodyc.length; rwCount++) {
          const currentTrc = tbodyc[rwCount].children;
          const currentLockTrc = lockTbodyc[rwCount].children;
          // 並び順の色変更
          this.changeSortColor(currentLockTrc);
          // 編集項目の色を変更
          let edited = this.changeEditColor(currentTrc, currentLockTrc);
          // 削除対象を判定
          const deleted = this.isDeleteRow(currentTrc);

          // モーダルからの編集も色を変更する
          if (
            dataItem[rwCount] && this.isEdited(dataItem[rwCount].code)
          ) {
            edited = true;
          }
          // 対応範囲のテーブルのみ、operation = 1 (新規) の行に、k-dirty-cell" を入れる
          if (masterName != null
              && masterName === 'mst_alarm_notification'
              && dataItem[rwCount].operation
              && dataItem[rwCount].operation === 1) {
            edited = true;
          }
          // mod #9605 2023/08/30 EOL対応 朴 start
          // if (this.pageTypeName === 'MstWheelChairMainComponent') {
          if (this.pageTypeName === 'MstWheelChairMainComponent' && oldArr && newArr) {
          // mod #9605 2023/08/30 EOL対応 朴 end
            // Vue2 では this.$refs.grid.$el.children[1].children[0].children[1] を使用していた。
            // これは .k-grid-content-locked 配下の table の tbody を指す。
            // Vue3 では getGridLockedTbodyEl() が同じ要素を返すため、こちらを使用する。
            const gridLock = this.getGridLockedTbodyEl();
            // #9863 vue.esm.js:1906 TypeError: Cannot read properties of undefined (reading 'upDate') 横展開2 linjunfeng start
            // if (oldArr && oldArr[rwCount] && oldArr[rwCount].upDate && !newArr[rwCount].upDate) {
              if (oldArr && oldArr[rwCount] && oldArr[rwCount].upDate && newArr[rwCount] && !newArr[rwCount].upDate) {
            // #9863 vue.esm.js:1906 TypeError: Cannot read properties of undefined (reading 'upDate') 横展開2 linjunfeng end
              delete oldArr[rwCount].upDate
            }
            // #9863 Error in nextTick: "TypeError: Cannot set properties of undefined (setting 'scaleDate')" 横展開2 linjunfeng start
            // if (newArr && newArr[rwCount] && newArr[rwCount].scaleDate) {
              if (newArr && newArr[rwCount] && newArr[rwCount].scaleDate && oldArr[rwCount]) {
            // #9863 Error in nextTick: "TypeError: Cannot set properties of undefined (setting 'scaleDate')" 横展開2 linjunfeng end 
              oldArr[rwCount].scaleDate = newArr[rwCount].scaleDate
            }
            // #9863 Error in nextTick: "TypeError: Cannot set properties of undefined (setting 'scaleUserId')" 横展開2 linjunfeng start
            // if (newArr && newArr[rwCount] && newArr[rwCount].scaleUserId) {
              if (newArr && newArr[rwCount] && newArr[rwCount].scaleUserId && oldArr[rwCount]) {
            // #9863 Error in nextTick: "TypeError: Cannot set properties of undefined (setting 'scaleUserId')" 横展開2 linjunfeng end
              oldArr[rwCount].scaleUserId = newArr[rwCount].scaleUserId
            }
            // #9863 Error in nextTick: "TypeError: Cannot set properties of undefined (setting 'scaleUserId')" 横展開2 linjunfeng start
            // if (newArr && newArr[rwCount] && newArr[rwCount].patId) {
              if (newArr && newArr[rwCount] && newArr[rwCount].patId && oldArr[rwCount]) {
            // #9863 Error in nextTick: "TypeError: Cannot set properties of undefined (setting 'scaleUserId')" 横展開2 linjunfeng end
              oldArr[rwCount].patId = newArr[rwCount].patId
            }
            // #9863 Cannot set properties of undefined (setting 'operation') 横展開2 linjunfeng start
            // if (newArr && newArr[rwCount] && newArr[rwCount].operation) {
              if (newArr && newArr[rwCount] && newArr[rwCount].operation && oldArr[rwCount] && oldArr[rwCount].operation) {
            // #9863 Cannot set properties of undefined (setting 'operation') 横展開2 linjunfeng end
              oldArr[rwCount].operation = newArr[rwCount].operation
            }
            if (JSON.stringify(oldArr[rwCount]) === JSON.stringify(newArr[rwCount])) {
              edited = false;
              if (gridLock.children[rwCount].children[3].children[0]) {
                gridLock.children[rwCount].children[3].children[0].remove();
                gridLock.children[rwCount].children[3].setAttribute('class', '');
              }
            }
          }
          // 並び順以外の項目が変更されていた場合は、削除か修正にあわせて並び順より後の項目の背景色を変更
          this.changeRowColor(currentTrc, currentLockTrc, edited, deleted);
          // add FNSI-8131 劉全航 start
          if(dataItem[rwCount] && dataItem[rwCount].operation && dataItem[rwCount].operation == 1){
            continue;
          }
          // add FNSI-8131 劉全航 end
          // データ参照エラーコンボの背景色を変更
          this.changeRefErrorComboColor(currentTrc, deleted, currentLockTrc);
        }
      });
    },
    /* add スクロール位置を保存 楊 start */
    setLastScroll() {
      if(this.scrollTop !== 0) {
        this.lastScrollTop = this.scrollTop;
      }
      if(this.scrollLeft !== 0) {
        this.lastScrollLeft = this.scrollLeft;
      }
    },
    /* add スクロール位置を保存 楊 end */
    editableColumns() {
      this.columns.forEach(column => {
        // 編集可否の設定を初期表示時の状態に戻す
        column.editable = column.field == 'sortRank'
            ? () => false
            : column.originalEditable
              ? () => true
              : () => false;
      });
      // add 治療記録バイタルグラフマスタ 1、6つの初期データを固定表示するようにしました。 と削除できません start
      if (this.masterPhysicalName == 'mst_vital_graph') {
        this.columns.filter(column => (column.field=='name' || column.field=='isDisp'))
        .forEach(column => {
          const temp = this.getMasterRecordList.data.filter(item => item.isDisp == '1').sort((a, b) => a.code-b.code);
          const maxCode = temp.length>6 ? temp[5].code : temp[temp.length-1].code;
          column.editable = (e) => e.code > maxCode;
        });
      }
      // add 治療記録バイタルグラフマスタ 1、6つの初期データを固定表示するようにしました。 と削除できません end
    },
    disableColumns() {
      this.columns.forEach(column => {
        // 並び順列を編集可、並び順列以外を編集不可に。
        column.editable = column.field == 'sortRank'
            ? this.isAllowSort
              ? () => true
              : () => false
            : () => false;
      });
    },
    showSortColumn() {
      // 編集・並び順設定モードによって並び順項目の表示・非表示を切り替える
      // （先頭ダミー要素列と並び順列を交互に表示・非表示する）
      const sortRankIndex = this.columns.findIndex(
        col => col.field === 'sortRank',
      );
      if (sortRankIndex >= 0) {
        this.columns[sortRankIndex].hidden = !(
          this.isAllowSort && this.isSortMode
        );
        const dummyIndex = this.columns.findIndex(col => col.field === 'dummy');
        if (dummyIndex >= 0) {
          this.columns[dummyIndex].hidden = !this.columns[sortRankIndex].hidden;
        }
      }
    },
    setScrollPosition(position) {
      this.setGridScrollPosition(position);
    },
    // add 医療材料セットマスタ スクロール位置を取得 start 鞠
    setScrollPositionLeft(position) {
      this.setGridScrollPositionLeft(position);
    },
    // add 医療材料セットマスタ スクロール位置を取得 end 鞠
    changeSortColor(currentTrc) {
      // 並び順が変更されていれば並び順とダミー項目背景色を変更
      for (let clCount = 0; clCount < currentTrc.length; clCount++) {
        if (
          this.isEditRow(currentTrc[clCount])
          && clCount === this.getColumnIndex('sortRank')
        ) {
          currentTrc[clCount]?.classList?.add('master-sort-edited');
          const dummyIndex = this.getColumnIndex('dummy');
          if (dummyIndex > -1) {
            currentTrc[dummyIndex]?.classList?.add('master-sort-edited');
          }
        }
      }
    },
    changeRowColor(currentTrc, currentLockTrc, edited, deleted) {
      // 並び順より後の項目の背景色を変更
      if (edited || deleted) {
        const addClass = deleted ? 'master-deleted-row' : 'master-edited-row';

        // 固定列（ソート順付）：ソート順後のみ
        for (
          let lockClCount = this.getColumnIndex('sortRank') + 1;
          lockClCount < currentLockTrc.length;
          lockClCount++
        ) {
          currentLockTrc[lockClCount]?.classList?.add(addClass);
        }
        // 可変列：全列対象
        for (
          let clCount = 0;
          clCount < currentTrc.length;
          clCount++
        ) {
          currentTrc[clCount]?.classList?.add(addClass);
        }
      }
      //// add kang 9074 start
      else {
        const removeClass = deleted ? 'master-deleted-row' : 'master-edited-row';

        const removeEditCellClass = "master-edited-cell";
        const removeDirtyCellClass = "k-dirty-cell";
        // 固定列（ソート順付）：ソート順後のみ
        for (
            let lockClCount = this.getColumnIndex('sortRank') + 1;
            lockClCount < currentLockTrc.length;
            lockClCount++
        ) {
          currentLockTrc[lockClCount]?.classList?.remove(removeClass);
          currentLockTrc[lockClCount]?.classList?.remove(removeEditCellClass);
          currentLockTrc[lockClCount]?.classList?.remove(removeDirtyCellClass);
        }
        // 可変列：全列対象
        for (
            let clCount = 0;
            clCount < currentTrc.length;
            clCount++
        ) {
          currentTrc[clCount]?.classList?.remove(removeClass);
          currentTrc[clCount]?.classList?.remove(removeEditCellClass);
          currentTrc[clCount]?.classList?.remove(removeDirtyCellClass);
        }
      }
      // add kang 9074 end
    },
    changeRefErrorComboColor(currentTrc, rowDeleted, ...[currentLockTrc]) {
      // 削除行は処理対象外
      if (rowDeleted) {
        return;
      }

      let mergedCurrentTrc = currentTrc;
      if (currentLockTrc) {
          // 固定例、可変列のカラムをマージする
          // データ参照エラーコンボの背景色を変更でstate.columnsを元にチェックを実施しているためstate.columnsと合わせる必要がある
          mergedCurrentTrc = [...currentLockTrc, ...currentTrc];
      }
      // 固定例、可変列のDOMのカラム数とapiから取得したカラム数が違う場合は処理しない
      if (mergedCurrentTrc.length != this.columns.length) {
        console.log("プルダウンチェックskip -> DOM column数:::" + mergedCurrentTrc.length + ":::API取得 column数:::" + this.columns.length);
        return;
      }

      // DOMのcodeの位置取得
      // state.columnsでcodeより後ろの項目が固定列に設定されている場合、codeも固定列に設定されていないとDOMとstate.columnsでcodeの位置に差異が生じる
      // DOMでは固定列が可変列よりも前に表示されるのを考慮してcodeの位置を取得する
      let indexColCode = this.getColumnIndex('code');
      if (indexColCode == -1) {
        return;
      }

      const colCode = this.columns[this.getColumnIndex('code')];
      if (!colCode.locked) {
        // codeより後ろの項目が固定列に指定されている場合はDOMのcodeの位置を後ろにずらす
        for (let clCount = this.getColumnIndex('code')+1; clCount < this.columns.length; clCount++) {
          let colCodeNext = this.columns[clCount];
          if (colCodeNext.locked) {
            indexColCode++;
          }
        }
      }

      // コンボリストが設定されていてデータが存在するが、画面表示上は空の場合は削除済みレコードを参照として背景色を変更
      for (let clCount = 0; clCount < mergedCurrentTrc.length; clCount++) {
        const columnInfo = this.columns[clCount];
        const hasValueColumn = this.hasValueColumn(
          // #9863 加算マスタ詳細を開くとtypeエラーが発生する linjunfeng start
          // mergedCurrentTrc[indexColCode].textContent,
          mergedCurrentTrc[this.getColumnIndex('code')].textContent.replaceAll(",", ""),
          // #9863 加算マスタ詳細を開くとtypeエラーが発生する linjunfeng end
          columnInfo.field,
        );
        if (
          columnInfo.values !== null
          && hasValueColumn
          && mergedCurrentTrc[clCount].textContent === ''
        ) {
          mergedCurrentTrc[clCount]?.classList?.add('master-deleted-combo');
        }
      }
    },
    getColumnIndex(fieldName) {
      // 指定された項目がない場合はマイナスが返る
      return this.columns.findIndex(e => e.field === fieldName);
    },
    isEditRow(currentTd) {
      // 編集した行を判定
      return currentTd.classList.contains('k-dirty-cell');
    },
    normalization(items) {
      // columnの定義にあわせてデータを正規化する。
      const columnNames = this.columnDefinition.map(column => column.field);

      return Object.keys(items)
        .filter(key => columnNames.includes(key) || key == 'isAddRow')
        .reduce((acc, key) => {
          acc[key] = items[key];
          return acc;
        }, {});
    },
    convertToStr(messageArr) {
      if (messageArr.length === 0) return '';

      const unique = messageArr.reduce((acc, cur) => {
        if (acc.indexOf(cur) === -1) {
          acc.push(cur);
        }
        return acc;
      }, []);

      const prefix = '</br>&nbsp&nbsp・';
      return prefix + unique.join(prefix);
    },
    toRankEditBtnClick() {
      // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      this.cacheGridScrollPosition(this.scrollPosition);
      EventBus.$emit('onCloseMasterEditModal', this.onCloseMasterEditModal);

      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        return;
      }

      this.isSortMode = true;
      this.disableColumns();
      this.showSortColumn();
      EventBus.$emit('setSortMode', this.isSortMode);
      this.$nextTick(() => this.calculateGridWidth());
    },
    sort() {
      const compare = (a, b) => a.sortRank - b.sortRank || a.sortInputTime - b.sortInputTime;
      // グリッドデータの並び替え
      this.getMasterRecordList.data.sort(compare);
      // 並び順を採番しなおす
      for (let i = 0; i < this.getMasterRecordList.data.length; i++) {
        if(this.getMasterRecordList.data[i].isDisp === '1' ) { this.getMasterRecordList.data[i].sortRank = i + 1; }
      }
    },
    sortBtnClick() {
      // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      this.cacheGridScrollPosition(this.scrollPosition);
      EventBus.$emit('onCloseMasterEditModal', this.onCloseMasterEditModal);

      const tempData = deepCopy(this.getMasterRecordList.data);
      this.isSortMode = false;
      this.editableColumns();
      this.showSortColumn();
      this.sort();
      this.isSorted = this.sortChange(tempData);
      EventBus.$emit('setSortMode', this.isSortMode);
      this.$nextTick(() => this.calculateGridWidth());
    },
    sortChange(tempData){
      let flag = false;
      this.getMasterRecordList.data.forEach( item => {
        tempData.forEach( tempItem => {
          if(item.code === tempItem.code && item.sortRank !== tempItem.sortRank) { flag = true; }
        })
      })
      return flag;
    },
    cancel() {
      // 前画面に戻る
      // 編集破棄確認はMasterRecordView.vueで行う
      this.$router.go(-1);
    },
    // 共同マスターBUG修正 Du start
    getisChanged() {
      const hasComponentChangedState = !!(
        Object.prototype.hasOwnProperty.call(this.$options?.computed || {}, "isChanged")
        || Object.prototype.hasOwnProperty.call(this.$options?.props || {}, "isChanged")
        || Object.prototype.hasOwnProperty.call(this.$data || {}, "isChanged")
      );
      if (hasComponentChangedState) {
        return !!this.isChanged;
      }

      const {data} = this.getMasterRecordList || {};
      return (
        this.getStateUserAccountInfo !== null
        && data !== undefined
        && (this.$store.getters['master-maintenance/isRecordModified'] || !this.kendoValidator.validate())
      );
    },
    // 共同マスターBUG修正 Du end
    // パンくずリストをクリックされた場合に呼び出される関数
    refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      if (this.selfScreenName === this.$route.name
        && this.getMasterAlertDialogs().length === 0) {
        if (this.getisChanged()) {
          this.$ons.notification.confirm({
            // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
            // title: "内容破棄",
            title: DIALOG_MESSAGES[13000004].title,
            // message: "編集内容が破棄されます。</br>よろしいですか？",
            message: messageFormat(DIALOG_MESSAGES[13000004].message),
            // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
            callback: answer => {
              if (answer === 1) {
                this.findList();
              }
            },
          });
        }
        else {
          this.findList();
        }
      }
    },
    editStart(e) {
      if (this.androidFlg) {
        this.editingFlg = true;
      }
      let dirtyNum = this.queryMasterAll('.k-dirty-cell').length;
      if (dirtyNum > 0) {
         let count = 0;
          while(dirtyNum > count){
            // document.getElementsByClassName('k-dirty-cell')[count].style.overflow = 'hidden';
            count++;
          }
      }
      // #8745 マウスが止まると中国語のtipsが現れました 林峻峰 start
      this.$nextTick(()=>{
        // add start #9185
        if (e.sender?.editable?.options?.fields?.field === 'isDisp') {
          const element = this.getGridScrollContainer();
          element?.scrollTo?.({
            left: element.scrollWidth - element.clientWidth,
            behavior: 'smooth'
          });
        }
        // add end #9185
        const textInput = this.queryMaster('.k-input.k-textbox');
        if (textInput) {
          textInput.setAttribute('title', '');
        }
        // #9185 マウスが止まるとのtipsが現れました linjunfeng start
        // Vue2 は .k-edit-cell[0]?.children[0]?.title を参照していた。
        // Vue3 でも同じく「最初の .k-edit-cell の最初の子要素」のみを対象とする。
        const editCell = this.queryMaster('.k-edit-cell');
        const editTarget = editCell?.children?.[0];
        if (editTarget?.title) {
          editTarget.title = ""
        }
        // #9185 マウスが止まるとのtipsが現れました linjunfeng end
      })
      // #8745 マウスが止まると中国語のtipsが現れました 林峻峰 end
    },
    editEnd() {
      this.editingFlg = false;
    },
    isDeleteRow(currentTrc) {
      let deleted = false;
      // 削除カラムで削除が選択されている場合は削除フラグを設定
      for (let clCount = 0; clCount < currentTrc.length; clCount++) {
        if (this.isEditRow(currentTrc[clCount])) {
          const firstChild = currentTrc[clCount]?.children?.[0];
          const nextSibling = firstChild?.nextSibling;
          if (
            nextSibling
            && nextSibling.data === '削除'
            && this.getColumnIndex('isDisp') === clCount
          ) {
            deleted = true;
          }
        }
      }
      return deleted;
    },
    validateRequired() {
      let validateMessageArr = [];
      const gridData = this.getMasterRecordList;
      // add マスタ障害対応 No274 王 start
      let rows = null;
      if (this.masterPhysicalName === 'mst_medicate_timing') {
        rows = gridData.data.filter(row => row.isDisp !== '0' && row.isDel !== '1');
      } else {
        rows = gridData.data.filter(row => row.isDisp !== '0');
      }
      // add マスタ障害対応 No274 王 end
      // ストアに保存されているデータについて必須項目の未入力をチェックする
      for (let idx = 0; idx < rows.length; idx++) {
        if(this.masterPhysicalName =='mst_mainte_layout_group' && !rows[idx].layoutList) {
          validateMessageArr.push(this.columns.find( e => e.field == 'layoutList').title);
        }
        // スキーマ情報の件数分をチェック
        const keys = Object.keys(gridData.schema.model.fields);
        for (let keyCount = 0; keyCount < keys.length; keyCount++) {
          // バリデーションで必須が定義されている項目を対象
          const {validation} = gridData.schema.model.fields[keys[keyCount]];
          if (typeof validation !== 'undefined' && validation.required) {
            if (
              rows[idx][keys[keyCount]] !== null
              && rows[idx][keys[keyCount]] === ''
            ) {
              // カラム名からタイトルを取得
              const columnInfo = this.columns.find(
                e => e.field == keys[keyCount],
              );
              if (keys[keyCount] === 'additionKind') {
                validateMessageArr.push('加算種別');
              } else {
                // 項目名が重複していなければ、メッセージに追加
                validateMessageArr.push(columnInfo.title);
              }
            }
          }
        }
        // add redmine 10_障害一覧.No42 帳票名未入力メッセージ 宋qy start
        if(this.masterPhysicalName == 'mst_function_report' && !rows[idx].reportCd){
          validateMessageArr.push(this.columns.find( e => e.field == 'reportCd').title);
        }
        // add redmine 10_障害一覧.No42 帳票名未入力メッセージ 宋qy end
        // add ＃9184 治療記録モニタグラフマスタにて1項目のグラフが生成できない dou start
        if (this.masterPhysicalName === "mst_monitor_graph") {
          if (validateMessageArr.includes("左項目") && !validateMessageArr.includes("右項目")) {
            validateMessageArr = validateMessageArr.filter(x => x.includes("右"));
          }
          if (validateMessageArr.includes("右項目") && !validateMessageArr.includes("左項目")) {
            validateMessageArr = validateMessageArr.filter(x => x.includes("左"));
          }
          if (validateMessageArr.includes("右項目") && validateMessageArr.includes("左項目")) {
            validateMessageArr = ["左項目または右項目"];
          }
        }
        // add ＃9184 治療記録モニタグラフマスタにて1項目のグラフが生成できない dou end
      }
      return this.convertToStr(validateMessageArr);
    },
    validateComboValue() {
      // コンボ項目のfieldを取り出す
      const comboFields = this.columns
        .filter(column => column.values != null)
        .map(column => ({
          field: column.field,
          title: column.title,
          values: column.values,
        }));

      // 削除されていないレコード
      const gridData = this.getMasterRecordList;
      // mod 6379 【機能帳票マスタ】プルダウンメニューの選択肢、動作の不正 周安寧 start
      // let rows = gridData.data.filter(row => row.isDisp !== "0");
      let rows = gridData.data.filter(row => row.isDisp !== '0' && row.isDel === '0');
      // mod 6379 【機能帳票マスタ】プルダウンメニューの選択肢、動作の不正 周安寧 end
      // add  No4355 患者イベントカテゴリマスタでカテゴリ名を削除すると患者イベントサブカテゴリマスタで削除できなくなる 鞠 start
      if (this.masterPhysicalName === 'mst_pat_event_sub_category'){
        rows = gridData.data.filter(row => row.isDel !== '0' && row.categoryCd);
      }
      // add  No4355 鞠 end

      // コンボの列を対象に、ストアの値がコンボのvaluesに存在することをチェック
      let validateMessageArr = [];
      for (let rowIdx = 0; rowIdx < rows.length; rowIdx++) {
        for (let comboIdx = 0; comboIdx < comboFields.length; comboIdx++) {
          const columnValue = rows[rowIdx][comboFields[comboIdx].field];
          // valuesにデータ値が存在せず、データ値がNullか空文字でなければエラー
          const index = comboFields[comboIdx].values.findIndex(
            e => e.value == columnValue,
          );
          if (this.masterPhysicalName == 'mst_wheel_chair' && rows[rowIdx].isPersonal == '0' && comboFields[comboIdx].field == 'patId') {
            continue;
          }
          //EOL対応内部 6951 add start ljx
          //別のマスタを用いる場合がある。利用する別のマスタが削除される場合、全チェックのため、編集行以外は保存不可の制御がある。
          //今回の修正としては、全チェックではなく、編集行のみにチェックを行うことにする。
          //編集行の場合、operationは値がある。1（追加）・2（編集）
          if(rows[rowIdx].operation == undefined){
            continue;
          }
          //EOL対応内部 6951 add end ljx
          if (index < 0 && (columnValue !== null && columnValue !== '')) {
            validateMessageArr.push(comboFields[comboIdx].title);
          }
        }
      }
      return this.convertToStr(validateMessageArr);
    },
    isKendoSaveDefaultPrevented(ev) {
      try {
        if (typeof ev?.isDefaultPrevented === "function") {
          return ev.isDefaultPrevented();
        }
      } catch (_error) {
        // noop
      }
      return ev?.defaultPrevented === true || ev?._defaultPrevented === true;
    },
    writeKendoSaveValueToModel(model, field, value) {
      if (!model || field == null) {
        return false;
      }
      try {
        if (typeof model.set === "function") {
          model.set(field, value);
        } else {
          model[field] = value;
        }
      } catch (_error) {
        model[field] = value;
      }
      return true;
    },
    applyKendoSaveValuesToModel(ev) {
      const values = ev?.values && typeof ev.values === "object" && !Array.isArray(ev.values)
        ? ev.values
        : null;
      const model = ev?.model;
      if (!values || !model || this.isKendoSaveDefaultPrevented(ev)) {
        return false;
      }
      let applied = false;
      Object.keys(values).forEach(field => {
        if (model[field] == values[field]) {
          return;
        }
        applied = this.writeKendoSaveValueToModel(model, field, values[field]) || applied;
      });
      return applied;
    },
    onSave(ev) {
      // スクロールの位置を維持
      const currentScrollPosition = this.getGridScrollPosition();
      this.scrollLeft = currentScrollPosition.left ?? ev.sender?._scrollLeft ?? 0;
      this.scrollTop = currentScrollPosition.top ?? 0;
      this.editFlg = true;

      this.editingFlg = false;
      this.applyKendoSaveValuesToModel(ev);
      this.edit({ editRecord: ev.model, isSortMode: this.isSortMode });
      ev.sender.refresh();
      this.scheduleMasterGridEditedRowStateSync?.();
      if (ev.model.operation === 1) {
        ev.model.edited = true;
      }
      // 状態に合わせて背景色を変更
      // 内部 背景色と保存ボタンの状態が異常です start
      !this.isRecordModified && this.editBackgroundColor();
      // 内部 背景色と保存ボタンの状態が異常です end
    },
    showMasterEditModal(e) {
      // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      this.cacheGridScrollPosition(this.scrollPosition);

      // モーダルを表示
      this.showMasterEdit();

      /**
       * 「詳細」ボタンを押下したレコードのデータを取得する。
       * see: https://www.telerik.com/forums/selected-row-at-wrappers-for-vue
       */
      e.preventDefault();
      const row = this.getGridWidget();
      let selectedRowItem = getKendoGridDataItem(row, e.currentTarget.closest('tr'));
      let {code} = selectedRowItem;
      // add start #9301
      if (this.masterPhysicalName === 'mst_medicine_mix') {
        if (selectedRowItem.isAddRow) {
          selectedRowItem.medicateTimingCd = this.defaultMedicateTimingDataCd;
          selectedRowItem.procedureCd = this.defaultProcedureCd
        }
      }
      // add end #9301
      let newHoliday = [];
      if(this.masterPhysicalName == 'mst_holiday') {
        let editMstHoliday = this.getMasterRecordList.data.filter(e => e.code == selectedRowItem.code+1);
        if (editMstHoliday.length > 0 && editMstHoliday[0].holiday){
          JSON.parse(selectedRowItem.holiday).forEach(e => {
            if(!e.class) e.class = selectedRowItem.class;
            if(e.class == selectedRowItem.class) { newHoliday.push(e); }
          })
          JSON.parse(editMstHoliday[0].holiday).forEach(e => {
            if(!e.class) e.class = editMstHoliday[0].class;
            newHoliday.push(e);
          })
        }
      }
      if (newHoliday.length > 0) {
        selectedRowItem.holiday = JSON.stringify(newHoliday);
      }
      // codeがない場合はcodeを付番
      if (!code) {
        this.edit({ editRecord: selectedRowItem, isSortMode: this.isSortMode });
      }

      // プロパティを正規化する。
      const normalizedItem = this.normalization(selectedRowItem);

      // ストアに保存する。
      this.setEditRecord(normalizedItem);
    },
    onCloseMasterEditModal() {
      this.$nextTick(() => {
        this.setScrollPosition(this.scrollPosition);
      });
      // Androidでスクロール位置が戻らない場合があるのでもう一度設定
      setTimeout(() => {
        this.setScrollPosition(this.scrollPosition);
        // #9863 Error in nextTick: "TypeError: Cannot read properties of undefined (reading '$el')" 横展開2 linjunfeng start
        // this.editBackgroundColor()
        // #9863 Error in nextTick: "TypeError: Cannot read properties of undefined (reading '$el')" 横展開2 linjunfeng end
      }, 1000);
    },
    importCsv() {
      // グリッドでエラーが発生している場合は処理を中断
      if (this.kendoValidator && !this.kendoValidator.validate()) {
        return;
      }

      this.masterCsvTarget = event.target;
      this.masterCsvVisible = true;
    },
    prehideCsvPopover() {
      this.masterCsvVisible = false;
      this.editBackgroundColor();
    },
    addInputAssist(ev) {
      /* add スクロール位置を保存 楊 start */
      this.lastInputScrollLeft = this.getGridScrollPosition().left || 0;
      /* add スクロール位置を保存 楊 end */
      bindGridEditorEnterToCloseCell(ev?.sender || this.getGridWidget(), ev?.container);
      bindGridEditorDropDownListToCloseCell(ev?.sender || this.getGridWidget(), ev?.container);
      // iOS/PWA環境でスピナーをタップすると編集が終了してしまう現象の対策
      if (this.iosFlg) {
        const spinnerObj = this.queryMaster('.k-numerictextbox .k-select');
        if (spinnerObj) {
          // 編集が終了するとオブジェクトが削除される為、removeEvent処理は不要
          spinnerObj.ontouchend = event => event.stopPropagation();
        }
      }
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc start
    /**
     * @description 患者選択
     * @summary 選択した患者の患者情報レコードをストアに格納する
     * @param {Number} selectedPatId 患者ＩＤ
     */
    async setSelectedPatHeader(selectedPatId) {
      this.setLoadingScreenMessage("処理中・・・");
      this.setLoadingScreenVisible(true);
      try {
        await this.clearSelectedPatToHeader();
        if (selectedPatId === null) {
          // ？？？？患者
          await this.setIsNullPat(true);
        } else {
          await this.selectPatToHeader(selectedPatId);
        }
      } catch {
        // TODO: エラー処理ちゃんと考える
        throw new Error("[PatHeader.vue]setSelectedPat(): 患者選択失敗");
      } finally {
        this.setLoadingScreenVisible(false);
      }
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc end
    /**
     * コピー追加ボタン押下時処理
     */
    copyAdd(e) {
      // グリッドでエラーが発生している場合は処理を中断
      if (this.kendoValidator && !this.kendoValidator.validate()) {
        return;
      }
      this.masterCopyAddTarget = e.target;
      this.masterCopyAddVisible = true;
    },
    prehideCopyAddPopover() {
      this.masterCopyAddVisible = false;
      this.editBackgroundColor();
    },
  },
}
