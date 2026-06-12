/**
 * 体重計マスタ（上部の一覧）ページ  MainContent
 */
<template>
  <div class="ntss-list weight-scale-grid" :style="ntssListStyles" v-kendo-validator="kendoValidatorSetup">
    <kendo-grid-toolbar class="k-grid-toolbar kendo-grid-toolbar-style" :style="heightStyles">
      <div
        v-show="columns.length > 1"
        ref="grid"
        :class="[
          fontSizeSet,
          'ntss-kendo-grid-legacy',
          'mst-weight-scale-direct-jq-grid',
          'k-widget k-grid k-editable k-display-block'
        ]"
      ></div>
    </kendo-grid-toolbar>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
// add #11515 体重計マスタ>2回測定チェック許容範囲値でスピナーでは小数点が入力できない linjunfeng start

import { getScopedAlertDialogs, getScopedNumericTextBox } from "@/functions/common/LayoutMeasureHelper";
import { markRaw } from "@/compat/vue/runtime";
import kendo from "@progress/kendo-ui";
import $ from "@/compat/jquery";

// add #11515 体重計マスタ>2回測定チェック許容範囲値でスピナーでは小数点が入力できない linjunfeng end

const WEIGHT_SCALE_COMPARE_OMIT_KEYS = [
  "operation",
  "edited",
  "dirty",
  "dirtyFields",
  "uid",
  "_events",
  "_handlers",
  "sortInputTime"
];

/**
 * TODO
 * more: モーダルで編集した項目が、一覧上で「編集済み（三角マーク）」をつけたい。
 */
export default {
  props: {
    /**
     * 親コンポーネントから渡される編集モードのフラグ。
     * true の場合は編集可能、false の場合は閲覧モードとして編集を禁止する。
     * モバイル端末での誤操作防止のため、editStart イベントで使用。
     */
    allowEdit: {
      type: Boolean,
      default: true
    },
    /**
     * モバイル端末かどうかの判定（true: モバイル、false: PC）
     */
    isMobileDevice: {
      type: Boolean,
      default: false
    },
    // NOTE: コンソールエラー対策
    historyKey: null
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
      kendoValidatorSetup: {
        rules: {},
        messages: {}
      },
      //Android端末で編集中であることを示すフラグ
      isAndroid: false,
      isIOS: false,
      scrollPosition: {
        top: 0,
        left: 0
      },
      //自画面の名称
      selfScreenName: "",
      facilitylistValue: "",
      editingFlg: false,
      directGridWidget: null,
      directGridDataSource: null,
      directGridColumnSignature: "",
      directGridLayoutRafId: null,
      directGridLayoutRefreshRafId: null,
      directGridVisualRafId: null,
      directGridBodyColumnFields: null,
      directGridLockedColumnFields: null,
      directGridEditOriginals: markRaw(new Map()),
      kendoValidator: { validate: () => true },
      scaleComparisonRecordModel: ""
    };
  },
  computed: {
    ...mapGetters("master-maintenance", { getFacilitySwitch: "getFacilitySwitch",}),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return {
        "--height": "auto",
        "padding-left": 0
      };
    },
    fontSizeSet() {
      const names = ["small", "medium", "large", "x-large"];
      return `font-size-set-${names[this.getFontSize] || names[1]}`;
    },
    ntssListStyles() {
      return {
        display: this.columns.length == 1 ? "none" : "inherit",
        fontSize: "1em",
        padding: "0 0 0 0.375rem"
      };
    },
    ...mapGetters("mst-weight-scale", {
      getMasterRecordList: "getMasterRecordList",
      getFilteredMasterRecordList: "getFilteredMasterRecordList",
      getUpdateRecordList: "getUpdateRecordList",
      masterPhysicalName: "getMasterName",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord",
      isEdited: "isEdited",
      hasValueColumn: "hasValueColumn"
    }),
    isScaleRecordModified() {
      if (!this.scaleComparisonRecordModel) {
        return false;
      }
      const data = this.collectScaleRecordsForCompare();
      return this.serializeScaleRecordsForCompare(data) !== this.scaleComparisonRecordModel;
    },
    masterRecords() {
      // storeからデータを取得
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
      const data = this.getMasterRecordList.data;
      return (
        this.getStateUserAccountInfo !== null &&
        data !== undefined &&
        this.isScaleRecordModified
      );
    }
  },
  methods: {
    collectScaleRecordsForCompare() {
      const storeRows = [...(this.getMasterRecordList?.data || [])];
      const grid = this.getGridWidget();
      if (!grid?.dataSource) {
        return storeRows;
      }
      const merged = new Map(storeRows.map(row => [String(row.code), { ...row }]));
      (grid.dataSource.data() || []).forEach(model => {
        const plain = typeof model?.toJSON === "function" ? model.toJSON() : { ...model };
        if (plain.code === undefined || plain.code === null || plain.code === "") {
          return;
        }
        const key = String(plain.code);
        merged.set(key, { ...(merged.get(key) || {}), ...plain });
      });
      return Array.from(merged.values());
    },
    normalizeScaleRecordForCompare(record) {
      if (!record || typeof record !== "object") {
        return record;
      }
      const normalized = { ...record };
      WEIGHT_SCALE_COMPARE_OMIT_KEYS.forEach(key => {
        delete normalized[key];
      });
      const fields = this.getMasterRecordList?.schema?.model?.fields || {};
      Object.keys(normalized).forEach(key => {
        const fieldInfo = fields[key];
        if (!fieldInfo) {
          return;
        }
        const value = normalized[key];
        if (fieldInfo.type === "number") {
          if (value === null || value === undefined || value === "") {
            normalized[key] = null;
            return;
          }
          const numberValue = Number(String(value).replace(/,/g, "").trim());
          normalized[key] = Number.isFinite(numberValue) ? numberValue : value;
          return;
        }
        if (fieldInfo.type === "string") {
          normalized[key] = value === null || value === undefined || value === ""
            ? null
            : String(value);
        }
      });
      return normalized;
    },
    serializeScaleRecordsForCompare(data) {
      return JSON.stringify(
        (data || []).map(record => this.normalizeScaleRecordForCompare(record))
      );
    },
    isGridRecordMatchingSnapshot(record) {
      if (!this.scaleComparisonRecordModel || !record) {
        return false;
      }
      const snapshot = JSON.parse(this.scaleComparisonRecordModel);
      const snap = snapshot.find(item => String(item.code) === String(record.code));
      if (!snap) {
        return false;
      }
      return JSON.stringify(this.normalizeScaleRecordForCompare(record)) === JSON.stringify(snap);
    },
    syncDirectGridModelToStore(ev) {
      const model = ev?.model;
      if (!model) {
        return;
      }
      const payload = typeof model.toJSON === "function" ? model.toJSON() : { ...model };
      const editRecord = { ...payload };
      WEIGHT_SCALE_COMPARE_OMIT_KEYS.forEach(key => {
        delete editRecord[key];
      });
      this.edit({
        editRecord,
        isSortMode: this.isSortMode,
        skipOperationMark: this.isGridRecordMatchingSnapshot(editRecord)
      });
    },
    getScaleSnapshotFieldValue(code, fieldName) {
      if (!this.scaleComparisonRecordModel || code === undefined || code === null) {
        return undefined;
      }
      const snapshot = JSON.parse(this.scaleComparisonRecordModel);
      const snap = snapshot.find(item => String(item.code) === String(code));
      if (!snap || !Object.prototype.hasOwnProperty.call(snap, fieldName)) {
        return undefined;
      }
      return snap[fieldName];
    },
    setScaleComparisonRecordModel() {
      const data = this.collectScaleRecordsForCompare();
      this.scaleComparisonRecordModel = this.serializeScaleRecordsForCompare(data);
    },
    ...mapActions("multi-modal", ["showMasterEdit"]),
    ...mapActions("mst-weight-scale", [
      "setMasterName",
      "findRecordList",
      "setMasterRecordList",
      "edit",
      "setCondition",
      "updateRecordList",
      "setEditRecord",
      "editRecordBeEmpty",
      "findRecordListByFacilityCd",
      "updateRecordListByFacilityCd"
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    ...mapActions("mst-weight", {
      setIsGridEditing: "setIsGridEditing"
    }),
    getGridRoot() {
      return this.$refs.grid || null;
    },
    getGridWidget() {
      return this.directGridWidget || null;
    },
    getGridHeaderEl() {
      return this.getGridRoot()?.querySelector?.(".k-grid-header") || null;
    },
    getGridContentEl() {
      return this.getGridRoot()?.querySelector?.(".k-grid-content") || null;
    },
    getGridLockedContentEl() {
      return this.getGridRoot()?.querySelector?.(".k-grid-content-locked") || null;
    },
    getGridTableEl() {
      return this.getGridTbodyEl()?.closest?.("table") || null;
    },
    getGridTbodyEl() {
      return this.getGridRoot()?.querySelector?.(".k-grid-content tbody") || null;
    },
    getGridLockedTbodyEl() {
      return this.getGridRoot()?.querySelector?.(".k-grid-content-locked tbody") || null;
    },
    getGridDataItem(row) {
      return this.directGridWidget?.dataItem?.(row) || null;
    },
    getGridScrollPosition() {
      const content = this.getGridContentEl();
      return { top: content?.scrollTop || 0, left: content?.scrollLeft || 0 };
    },
    setGridScrollPosition(position = {}) {
      const content = this.getGridContentEl();
      if (!content) {
        return;
      }
      if (Number.isFinite(position.left)) {
        content.scrollLeft = position.left;
      }
      if (Number.isFinite(position.top)) {
        content.scrollTop = position.top;
        this.syncDirectGridLockedScrollPosition(position.top);
      }
      try {
        $(content).trigger("scroll");
      } catch (_error) {
        // noop
      }
    },
    getDirectGridDataSourceOption() {
      const source = this.masterRecords || {};
      return {
        ...source,
        data: Array.isArray(source.data) ? source.data : []
      };
    },
    createDirectGridDataSource() {
      this.directGridDataSource = markRaw(new kendo.data.DataSource(this.getDirectGridDataSourceOption()));
      return this.directGridDataSource;
    },
    getDirectGridColumnSignature() {
      return (this.columns || []).map(column => [
        column.field,
        column.hidden ? 1 : 0,
        column.locked ? 1 : 0,
        column.width || ""
      ].join(":" )).join("|");
    },
    buildDirectGridColumns() {
      return (this.columns || []).map(column => {
        const gridColumn = { ...column };
        if (column.field === "$modalType") {
          gridColumn.command = { text: "詳細", click: event => this.showMasterEditModal(event) };
          delete gridColumn.values;
        } else if (column.field === "doubleCheckTolerance") {
          gridColumn.editor = (container, options) => this.numericEditor(container, options);
        }
        return gridColumn;
      });
    },
    initDirectGridIfReady() {
      const root = this.getGridRoot();
      if (!root || this.columns.length <= 1) {
        return;
      }
      if (this.directGridWidget) {
        this.applyDirectGridColumnsContract();
        this.refreshDirectGridDataSource();
        this.scheduleDirectGridLayoutContract();
        return;
      }
      $(root).empty();
      $(root).kendoGrid({
        dataSource: this.createDirectGridDataSource(),
        editable: true,
        selectable: true,
        reorderable: false,
        scrollable: true,
        beforeEdit: event => this.editStart(event),
        cellClose: event => this.editEnd(event),
        edit: event => this.onDirectGridEdit(event),
        save: event => this.onSave(event),
        change: () => this.onDirectGridChange(),
        dataBound: event => this.onDataBoundKendoGrid(event),
        columns: this.buildDirectGridColumns()
      });
      this.directGridWidget = markRaw($(root).data("kendoGrid"));
      this.directGridColumnSignature = this.getDirectGridColumnSignature();
      this.applyDirectGridStyleContract();
      this.scheduleDirectGridLayoutContract();
    },
    destroyDirectGrid() {
      if (this.directGridWidget) {
        try {
          this.directGridWidget.destroy();
        } catch (_error) {
          // noop
        }
      }
      const root = this.getGridRoot();
      if (root) {
        $(root).empty();
      }
      this.directGridWidget = null;
      this.directGridDataSource = null;
      this.directGridColumnSignature = "";
    },
    applyDirectGridColumnsContract() {
      const grid = this.directGridWidget;
      if (!grid) {
        return;
      }
      const nextSignature = this.getDirectGridColumnSignature();
      if (nextSignature !== this.directGridColumnSignature) {
        grid.setOptions({ columns: this.buildDirectGridColumns() });
        this.directGridColumnSignature = nextSignature;
        this.invalidateDirectGridColumnFieldCache();
      }
    },
    refreshDirectGridDataSource() {
      const grid = this.directGridWidget;
      if (!grid?.dataSource) {
        return;
      }
      const source = this.getDirectGridDataSourceOption();
      grid.dataSource.data(source.data || []);
      this.scheduleDirectGridVisualRefresh();
    },
    onDataBoundKendoGrid() {
      this.invalidateDirectGridColumnFieldCache();
      this.applyDirectGridStyleContract();
      this.scheduleDirectGridVisualRefresh();
    },
    flattenDirectGridLeafColumns(columns = []) {
      const result = [];
      (columns || []).forEach(column => {
        if (Array.isArray(column?.columns) && column.columns.length) {
          result.push(...this.flattenDirectGridLeafColumns(column.columns));
          return;
        }
        result.push(column);
      });
      return result;
    },
    invalidateDirectGridColumnFieldCache() {
      this.directGridBodyColumnFields = null;
      this.directGridLockedColumnFields = null;
    },
    getDirectGridBodyColumnFields() {
      if (Array.isArray(this.directGridBodyColumnFields)) {
        return this.directGridBodyColumnFields;
      }
      const sourceColumns = this.directGridWidget?.columns || this.columns || [];
      this.directGridBodyColumnFields = this.flattenDirectGridLeafColumns(sourceColumns)
        .filter(column => !column.hidden && !column.locked)
        .map(column => column.field)
        .filter(Boolean);
      return this.directGridBodyColumnFields;
    },
    getDirectGridLockedColumnFields() {
      if (Array.isArray(this.directGridLockedColumnFields)) {
        return this.directGridLockedColumnFields;
      }
      const sourceColumns = this.directGridWidget?.columns || this.columns || [];
      this.directGridLockedColumnFields = this.flattenDirectGridLeafColumns(sourceColumns)
        .filter(column => !column.hidden && !!column.locked)
        .map(column => column.field)
        .filter(Boolean);
      return this.directGridLockedColumnFields;
    },
    getDirectGridVisibleColumns(locked) {
      return (this.columns || []).filter(column => !column.hidden && (!!column.locked) === locked);
    },
    getDirectGridDomColumns(locked) {
      return this.getDirectGridVisibleColumns(locked);
    },
    isDirectGridExcludedVisualField(fieldName) {
      return fieldName === "dummy" || fieldName === "sortRank" || fieldName === "$modalType";
    },
    resolveDirectGridCellField(cell, locked) {
      if (!cell) {
        return null;
      }
      const dataField = cell.getAttribute("data-field");
      if (dataField) {
        return dataField;
      }
      const row = cell.parentElement;
      if (!row) {
        return null;
      }
      const cellIndex = Array.from(row.children || []).indexOf(cell);
      if (cellIndex < 0) {
        return null;
      }
      const fields = locked ? this.getDirectGridLockedColumnFields() : this.getDirectGridBodyColumnFields();
      return fields[cellIndex] || null;
    },
    shouldPaintDirectGridCell(cell, locked, sortRankIndex) {
      const fieldName = this.resolveDirectGridCellField(cell, locked);
      if (fieldName && this.isDirectGridExcludedVisualField(fieldName)) {
        return false;
      }
      if (!locked) {
        return true;
      }
      const column = fieldName
        ? (this.columns || []).find(item => item.field === fieldName && !item.hidden)
        : null;
      return !!column && this.shouldApplyDirectGridRowBackground(column, sortRankIndex);
    },
    applyDirectGridCellRowVisual(cell, locked, sortRankIndex, options = {}) {
      if (!this.shouldPaintDirectGridCell(cell, locked, sortRankIndex)) {
        return;
      }
      const fieldName = this.resolveDirectGridCellField(cell, locked);
      const { deleted, edited, highlightSelected } = options;
      if (edited && fieldName && fieldName !== "sortRank") {
        cell.classList.add("master-edited-cell");
      }
      if (deleted) {
        cell.classList.add("master-deleted-row");
      } else if (edited) {
        cell.classList.add("master-edited-row");
      } else if (highlightSelected) {
        cell.classList.add("master-selected-row", "k-selected", "k-state-selected");
      }
    },
    getDirectGridSelectedUid() {
      const grid = this.directGridWidget;
      const selected = grid?.select?.();
      if (!selected?.length) {
        return null;
      }
      return grid.dataItem(selected)?.uid || null;
    },
    onDirectGridChange() {
      this.scheduleDirectGridVisualRefresh();
    },
    escapeDirectGridFieldName(fieldName) {
      if (typeof CSS !== "undefined" && typeof CSS.escape === "function") {
        return CSS.escape(String(fieldName));
      }
      return String(fieldName).replace(/\\/g, "\\\\").replace(/"/g, '\\"');
    },
    getDirectGridRowsForField(row, lockedRow, column) {
      const primaryRow = column?.locked ? lockedRow : row;
      const secondaryRow = column?.locked ? row : lockedRow;
      return [primaryRow, secondaryRow].filter(Boolean);
    },
    findDirectGridCellInRow(targetRow, fieldName, sourceIndex = -1, column = null) {
      if (!targetRow) {
        return null;
      }
      const escapedField = this.escapeDirectGridFieldName(fieldName);
      const byDataField = targetRow.querySelector?.(`td[data-field="${escapedField}"]`);
      if (byDataField) {
        return byDataField;
      }
      const cells = Array.from(targetRow.children || []);
      if (sourceIndex >= 0) {
        const ariaColIndex = String(sourceIndex + 1);
        const byAria = cells.find(cell => cell.getAttribute("aria-colindex") === ariaColIndex);
        if (byAria) {
          return byAria;
        }
      }
      if (column) {
        const visibleColumns = this.getDirectGridVisibleColumns(!!column.locked);
        const visibleIndex = visibleColumns.findIndex(item => item.field === fieldName);
        if (visibleIndex >= 0 && cells[visibleIndex]) {
          return cells[visibleIndex];
        }
      }
      return null;
    },
    isRecordDifferentFromSnapshot(rowData) {
      if (!rowData || !this.scaleComparisonRecordModel) {
        return false;
      }
      const plain = typeof rowData.toJSON === "function" ? rowData.toJSON() : rowData;
      return !this.isGridRecordMatchingSnapshot(plain);
    },
    isDirectGridRecordEdited(rowData) {
      if (!rowData) {
        return false;
      }
      if (this.isRecordDifferentFromSnapshot(rowData)) {
        return true;
      }
      const codeValue = rowData.code;
      if (codeValue !== null && codeValue !== undefined && codeValue !== "" && this.isEdited(codeValue)) {
        return true;
      }
      if (rowData.operation === 2) {
        return true;
      }
      if (rowData.operation === 1 && rowData.edited) {
        return true;
      }
      return false;
    },
    getDirectGridFieldFromCell(cell) {
      if (!cell) {
        return null;
      }
      const locked = !!cell.closest?.(".k-grid-content-locked");
      return this.resolveDirectGridCellField(cell, locked);
    },
    getDirectGridEditField(ev = {}, fallbackCell = null) {
      return ev?.sender?.editable?.options?.fields?.field
        || ev?.sender?.editable?.options?.field
        || ev?.container?.find?.("input[name], textarea[name], select[name]")?.first?.()?.attr?.("name")
        || this.getDirectGridFieldFromCell(fallbackCell);
    },
    getDirectGridEditKey(model, fieldName) {
      if (!model || !fieldName) {
        return "";
      }
      return `${model.uid || model.code || "__row__"}:${fieldName}`;
    },
    getDirectGridOriginalValue(model, fieldName) {
      const key = this.getDirectGridEditKey(model, fieldName);
      if (key && this.directGridEditOriginals.has(key)) {
        return this.directGridEditOriginals.get(key);
      }
      return model?.[fieldName];
    },
    normalizeDirectGridCompareValue(value, fieldName) {
      if (value instanceof Date) {
        return Number.isNaN(value.getTime()) ? "" : `date:${value.getTime()}`;
      }
      if (value == null) {
        return "";
      }
      const fieldInfo = this.getMasterRecordList?.schema?.model?.fields?.[fieldName];
      const rawValue = typeof value === "string" ? value.replace(/,/g, "").trim() : value;
      if (fieldInfo?.type === "number" || typeof rawValue === "number") {
        if (rawValue === "") {
          return "";
        }
        const numberValue = Number(rawValue);
        return Number.isFinite(numberValue) ? `number:${numberValue}` : String(rawValue);
      }
      return String(value);
    },
    isDirectGridSameValue(oldValue, newValue, fieldName) {
      return this.normalizeDirectGridCompareValue(oldValue, fieldName)
        === this.normalizeDirectGridCompareValue(newValue, fieldName);
    },
    captureDirectGridEditOriginal(ev = {}) {
      const model = ev?.model;
      if (!model) {
        return;
      }
      const container = ev?.container;
      const currentCell = container?.closest?.("td")?.[0] || ev?.sender?.current?.()?.[0] || null;
      const fieldName = this.getDirectGridEditField(ev, currentCell);
      if (!fieldName) {
        return;
      }
      const key = this.getDirectGridEditKey(model, fieldName);
      if (key && !this.directGridEditOriginals.has(key)) {
        const snapshotValue = this.getScaleSnapshotFieldValue(model.code, fieldName);
        this.directGridEditOriginals.set(
          key,
          snapshotValue !== undefined ? snapshotValue : model[fieldName]
        );
      }
    },
    clearDirectGridEditOriginal(model, fieldName) {
      const key = this.getDirectGridEditKey(model, fieldName);
      if (key) {
        this.directGridEditOriginals.delete(key);
      }
    },
    getDirectGridSaveFieldNames(ev = {}) {
      const fields = new Set();
      Object.keys(ev?.values || {}).forEach(field => fields.add(field));
      Object.keys(ev?.model?.dirtyFields || {}).forEach(field => fields.add(field));
      const containerCell = ev?.container?.closest?.("td")?.[0] || null;
      const fieldName = this.getDirectGridEditField(ev, containerCell || ev?.sender?.current?.()?.[0] || null);
      if (fieldName) {
        fields.add(fieldName);
      }
      return Array.from(fields).filter(Boolean);
    },
    getDirectGridNewValue(ev = {}, model, fieldName) {
      if (ev?.values && Object.prototype.hasOwnProperty.call(ev.values, fieldName)) {
        return ev.values[fieldName];
      }
      const container = ev?.container;
      const input = container
        ?.find?.("input[name], textarea[name], select[name]")
        ?.filter?.((_, element) => !element.disabled && element.type !== "hidden")
        ?.first?.();
      if (input?.length) {
        const widget = input.data?.("kendoNumericTextBox") || input.data?.("kendoDropDownList") || input.data?.("kendoComboBox");
        if (widget && typeof widget.value === "function") {
          return widget.value();
        }
        const value = input.val?.();
        const fieldInfo = this.getMasterRecordList?.schema?.model?.fields?.[fieldName];
        if (fieldInfo?.type === "number") {
          const numberValue = Number(value);
          return Number.isNaN(numberValue) ? value : numberValue;
        }
        return value;
      }
      return model?.[fieldName];
    },
    clearDirectGridUnchangedField(ev = {}, fieldName = null) {
      const model = ev?.model;
      if (model?.dirtyFields && fieldName) {
        delete model.dirtyFields[fieldName];
        if (Object.keys(model.dirtyFields).length === 0) {
          model.dirty = false;
        }
      }
      const cell = ev?.container?.closest?.("td")?.[0] || ev?.sender?.current?.()?.[0] || null;
      if (cell) {
        cell.classList.remove("k-dirty-cell", "master-edited-cell", "master-sort-edited");
        cell.querySelectorAll?.(".k-dirty").forEach(element => element.remove());
      }
    },
    getDirectGridActualChangedFields(ev = {}) {
      const model = ev?.model;
      if (!model) {
        return [];
      }
      return this.getDirectGridSaveFieldNames(ev).filter(fieldName => {
        const oldValue = this.getDirectGridOriginalValue(model, fieldName);
        const newValue = this.getDirectGridNewValue(ev, model, fieldName);
        const changed = !this.isDirectGridSameValue(oldValue, newValue, fieldName);
        if (!changed) {
          this.clearDirectGridUnchangedField(ev, fieldName);
          this.clearDirectGridEditOriginal(model, fieldName);
        }
        return changed;
      });
    },
    getDirectGridCellFromDomRow(tr, domColumns, fieldName) {
      if (!tr || !fieldName) {
        return null;
      }
      const index = (domColumns || []).findIndex(column => column.field === fieldName);
      return index >= 0 ? tr.children?.[index] || null : null;
    },
    getDirectGridCell(row, lockedRow, fieldName) {
      const column = (this.columns || []).find(item => item.field === fieldName && !item.hidden);
      if (!column) {
        return null;
      }
      const sourceIndex = this.columns.findIndex(item => item.field === fieldName);
      for (const targetRow of this.getDirectGridRowsForField(row, lockedRow, column)) {
        const cell = this.findDirectGridCellInRow(targetRow, fieldName, sourceIndex, column);
        if (cell) {
          return cell;
        }
      }
      const columns = this.getDirectGridVisibleColumns(!!column.locked);
      const visibleIndex = columns.findIndex(item => item.field === fieldName);
      const fallbackRow = column.locked ? lockedRow : row;
      return visibleIndex >= 0 ? fallbackRow?.children?.[visibleIndex] || null : null;
    },
    forEachDirectGridRowCell(row, lockedRow, callback) {
      [
        { targetRow: lockedRow, locked: true },
        { targetRow: row, locked: false }
      ].filter(item => item.targetRow).forEach(({ targetRow, locked }) => {
        const visibleColumns = this.getDirectGridVisibleColumns(locked);
        Array.from(targetRow.children || []).forEach((cell, cellIndex) => {
          let fieldName = cell.getAttribute("data-field");
          let column = fieldName
            ? (this.columns || []).find(item => item.field === fieldName && !item.hidden)
            : null;
          if (!column) {
            column = visibleColumns[cellIndex] || null;
            fieldName = column?.field || fieldName;
          }
          callback({ cell, fieldName, column, targetRow });
        });
      });
    },
    getDirectGridCells(row, lockedRow) {
      return (this.columns || [])
        .filter(column => !column.hidden)
        .map(column => ({ column, cell: this.getDirectGridCell(row, lockedRow, column.field) }))
        .filter(item => item.cell);
    },
    isDirectGridRowDeleted(row, lockedRow, rowData) {
      if (String(rowData?.isDisp ?? "") === "0") {
        return true;
      }
      const isDispCell = this.getDirectGridCell(row, lockedRow, "isDisp");
      return !!isDispCell?.classList?.contains("k-dirty-cell") && isDispCell.textContent.includes("削除");
    },
    shouldApplyDirectGridRowBackground(column, sortRankIndex) {
      if (!column?.field) {
        return false;
      }
      const field = column.field;
      if (field === "dummy" || field === "sortRank" || field === "$modalType") {
        return false;
      }
      const columnIndex = this.columns.findIndex(item => item.field === field);
      if (column.locked) {
        return sortRankIndex >= 0 && columnIndex > sortRankIndex;
      }
      // 可変列は sortRank より前の列も含めて行背景を付与（MasterMaintenanceMixin.changeRowColor と同様）
      return true;
    },
    applyDirectGridRowVisual(row, lockedRow) {
      const rowData = this.getGridDataItem(row) || this.getGridDataItem(lockedRow);
      if (!rowData?.uid) {
        return;
      }
      const selectedUid = this.getDirectGridSelectedUid();
      this.applyDirectGridRowVisualByUid(rowData.uid, rowData, selectedUid === rowData.uid);
    },
    applyDirectGridRowVisualByUid(uid, rowData = null, isSelected = null) {
      const root = this.getGridRoot();
      const grid = this.directGridWidget;
      if (!root || !uid) {
        return;
      }
      const escapedUid = this.escapeDirectGridFieldName(uid);
      const rows = Array.from(root.querySelectorAll(`tr[data-uid="${escapedUid}"]`) || []);
      if (!rows.length) {
        return;
      }
      const record = rowData || grid?.dataItem?.(rows[0]) || null;
      if (!record) {
        return;
      }
      if (isSelected === null) {
        isSelected = this.getDirectGridSelectedUid() === uid;
      }
      const sortRankIndex = this.columns.findIndex(column => column.field === "sortRank");
      const edited = this.isDirectGridRecordEdited(record);
      const { row, lockedRow } = this.getDirectGridRowsByUid(uid);
      const deleted = this.isDirectGridRowDeleted(row, lockedRow, record);
      const codeValue = String(record.code ?? this.getDirectGridCell(row, lockedRow, "code")?.textContent ?? "").replaceAll(",", "");
      const highlightSelected = !!isSelected && !edited && !deleted;

      const visualOptions = { deleted, edited, highlightSelected };

      rows.forEach(tr => {
        const locked = !!tr.closest(".k-grid-content-locked");
        const sortRankCell = tr.querySelector('td[data-field="sortRank"]')
          || this.getDirectGridCellFromDomRow(tr, this.getDirectGridDomColumns(locked), "sortRank");
        const dummyCell = tr.querySelector('td[data-field="dummy"]')
          || this.getDirectGridCellFromDomRow(tr, this.getDirectGridDomColumns(locked), "dummy");

        Array.from(tr.children || []).forEach(cell => {
          cell.classList.remove(
            "master-edited-row",
            "master-deleted-row",
            "master-selected-row",
            "master-edited-cell",
            "master-sort-edited",
            "master-deleted-combo",
            "k-selected",
            "k-state-selected"
          );
        });

        if (sortRankCell?.classList?.contains("k-dirty-cell")) {
          sortRankCell.classList.add("master-sort-edited");
          dummyCell?.classList?.add("master-sort-edited");
        }

        Array.from(tr.children || []).forEach(cell => {
          this.applyDirectGridCellRowVisual(cell, locked, sortRankIndex, visualOptions);
        });

        tr.classList.toggle("k-selected", highlightSelected);
        tr.classList.toggle("k-state-selected", highlightSelected);
      });

      if (!deleted && codeValue !== "") {
        rows.forEach(tr => {
          const locked = !!tr.closest(".k-grid-content-locked");
          Array.from(tr.children || []).forEach(cell => {
            const fieldName = this.resolveDirectGridCellField(cell, locked);
            if (!fieldName) {
              return;
            }
            const column = (this.columns || []).find(item => item.field === fieldName && !item.hidden);
            if (!column || column.values === null) {
              return;
            }
            const hasValue = this.hasValueColumn(codeValue, fieldName);
            if (hasValue && cell.textContent === "") {
              cell.classList.add("master-deleted-combo");
            }
          });
        });
      }
    },
    scheduleDirectGridVisualRefresh() {
      if (this.editingFlg) {
        return;
      }
      if (this.directGridVisualRafId != null) {
        cancelAnimationFrame(this.directGridVisualRafId);
      }
      this.directGridVisualRafId = requestAnimationFrame(() => {
        this.directGridVisualRafId = null;
        this.editBackgroundColor();
      });
    },
    applyDirectGridStyleContract() {
      const root = this.getGridRoot();
      if (!root) {
        return;
      }
      root.classList.add("ntss-kendo-grid-legacy", "k-widget", "k-grid", "k-editable", "k-display-block");
      root.querySelectorAll(".k-grid-header th, .k-grid-header .k-table-th").forEach(cell => {
        cell.classList.add("k-header");
      });
      [".k-grid-content tbody", ".k-grid-content-locked tbody"].forEach(selector => {
        root.querySelectorAll(selector).forEach(tbody => {
          Array.from(tbody.children).forEach((row, index) => {
            row.classList.add("k-master-row");
            row.classList.toggle("k-alt", index % 2 === 1);
          });
        });
      });
      root.querySelectorAll(".k-grid-content tbody td, .k-grid-content-locked tbody td").forEach(cell => {
        cell.classList.add("k-td", "k-table-td");
      });
      this.applyDirectGridLockedWidthContract();
      this.applyDirectGridLockedHeightContract();
      this.syncDirectGridLockedScrollPosition();
    },
    applyDirectGridLockedWidthContract() {
      const root = this.getGridRoot();
      if (!root) {
        return;
      }
      const width = this.getDirectGridVisibleColumns(true).reduce((sum, column) => {
        const raw = `${column.width || ""}`;
        if (raw.endsWith("em")) {
          const fontSize = parseFloat(root.ownerDocument?.defaultView?.getComputedStyle(root).fontSize || "16") || 16;
          return sum + parseFloat(raw) * fontSize;
        }
        if (raw.endsWith("px")) {
          return sum + parseFloat(raw);
        }
        const parsed = parseFloat(raw);
        return sum + (Number.isFinite(parsed) ? parsed : 0);
      }, 0);
      if (!width) {
        return;
      }
      const widthPx = `${Math.ceil(width)}px`;
      root.querySelectorAll(".k-grid-header-locked,.k-grid-content-locked,.k-grid-header-locked table,.k-grid-content-locked table").forEach(element => {
        element.style.width = widthPx;
        element.style.minWidth = widthPx;
      });
    },
    applyDirectGridLockedHeightContract() {
      const content = this.getGridContentEl();
      const lockedContent = this.getGridLockedContentEl();
      if (!content || !lockedContent) {
        return;
      }
      lockedContent.style.height = `${content.clientHeight}px`;
      lockedContent.style.maxHeight = `${content.clientHeight}px`;
    },
    syncDirectGridLockedScrollPosition(scrollTop = null) {
      const lockedContent = this.getGridLockedContentEl();
      if (!lockedContent) {
        return;
      }
      const content = this.getGridContentEl();
      lockedContent.scrollTop = scrollTop !== null && scrollTop !== undefined ? scrollTop : (content?.scrollTop || 0);
    },
    storeDirectGridScrollPosition() {
      const pos = this.getGridScrollPosition();
      this.scrollPosition.top = pos.top;
      this.scrollPosition.left = pos.left;
    },
    restoreDirectGridScrollPosition() {
      this.setScrollPosition(this.scrollPosition);
    },
    scheduleDirectGridPostLayoutRefresh() {
      if (this.directGridLayoutRefreshRafId != null) {
        cancelAnimationFrame(this.directGridLayoutRefreshRafId);
      }
      this.directGridLayoutRefreshRafId = requestAnimationFrame(() => {
        this.applyDirectGridStyleContract();
        this.directGridLayoutRefreshRafId = requestAnimationFrame(() => {
          this.directGridLayoutRefreshRafId = null;
          this.applyDirectGridStyleContract();
          this.restoreDirectGridScrollPosition();
        });
      });
    },
    scheduleDirectGridLayoutContract() {
      if (this.directGridLayoutRafId != null) {
        cancelAnimationFrame(this.directGridLayoutRafId);
      }
      this.directGridLayoutRafId = requestAnimationFrame(() => {
        this.applyDirectGridStyleContract();
        this.directGridLayoutRafId = requestAnimationFrame(() => {
          this.directGridLayoutRafId = null;
          this.applyDirectGridStyleContract();
        });
      });
    },
    // add #11515 体重計マスタ>2回測定チェック許容範囲値でスピナーでは小数点が入力できない linjunfeng start
    numericEditor(container, options) {
      let strinput= '<input id="myInputNumber" type="number" style="text-align:right" data-bind="value:' + options.field + '"/> ';
      const masterField = this.getMasterRecordList.schema.model.fields[options.field];
      const decimalPlaces = options.format.slice(4, options.format.length - 1);
      let parameterMin = masterField.validation.min
      let parameterMax = masterField.validation.max
      let parameterStep = Math.pow(10, -decimalPlaces);
      let parameter = {step: parameterStep, format: "n"+decimalPlaces}
      let numericTextBox = null;
      parameter.spin = ()=> {
        let value = numericTextBox?.value?.()
        // 数値範囲内かどうかの確認
        let newValue = value;
        if (value > parameterMax) {
          newValue = parameterMin;
        } else if (value <  parameterMin) {
          newValue = parameterMax;
        }
        if (numericTextBox?.element[0]?.value != null) {
          numericTextBox.element[0].value = newValue.toFixed(decimalPlaces);
        } else {
          numericTextBox?.value(newValue);
        }
      }
      parameter.change = (e) => {
        let value = e.sender._value;
        if (value > parameterMax) {
          value = parameterMax;
        } else if (value < parameterMin) {
          value = parameterMin;
        }
        const oldValue = options.model[options.field];
        if (!this.isDirectGridSameValue(oldValue, value, options.field)) {
          options.model.set(options.field, value);
        }
      };
      $(strinput).appendTo(container).kendoNumericTextBox(parameter);
      numericTextBox = $(container).find("#myInputNumber").data("kendoNumericTextBox");
      this.$nextTick(() => {
        let value = options.model[options.field];
        if (numericTextBox?.element[0]?.value != null) {
          numericTextBox.element[0].value = value.toFixed(decimalPlaces);
        }
        numericTextBox.element.on("mousewheel", (event)=>{
          let delta = (event.originalEvent.wheelDelta && (event.originalEvent.wheelDelta > 0 ? 1 : -1)) ||
                      (event.originalEvent.detail && (event.originalEvent.wheelDelta > 0 ? -1 : 1))
          let value = parseFloat(event.target.value)
          if (isNaN(value)) {
            value = 0;
          }
          if (delta > 0) {
            // 滑ります
            value += parameterStep
          } else {
            // 下がります
            value -= parameterStep
          }
          // 数値範囲内かどうかの確認
          if (value > parameterMax) {
            value = parameterMin
          } else if (value <  parameterMin) {
            value = parameterMax
          }
          if (numericTextBox?.element[0]?.value != null) {
            numericTextBox.element[0].value = value.toFixed(decimalPlaces);
          } else {
            numericTextBox?.value(value);
          }
        })
        numericTextBox.element.on("blur", () => {
          if (numericTextBox) {
            numericTextBox.trigger('change');
          }
        })
      })
    },
    // #11515 体重計マスタ>2回測定チェック許容範囲値でスピナーでは小数点が入力できない linjunfeng end
    onDirectGridEdit(ev) {
      this.captureDirectGridEditOriginal(ev);
      this.addInputAssist(ev);
    },
    async editStart(e) {
      if (this.isMobileDevice && !this.allowEdit) {
        e.preventDefault();
        return;
      }
      this.editingFlg = true;
      if (this.isAndroid) {
        await this.setIsGridEditing(true);
      }
      const model = e?.model;
      if (model?.uid) {
        this.$nextTick(() => {
          const selectedUid = this.getDirectGridSelectedUid();
          this.applyDirectGridRowVisualByUid(model.uid, model, selectedUid === model.uid);
        });
      }
    },
    editEnd() {
      this.editingFlg = false;
      this.setIsGridEditing(false);
      this.scheduleDirectGridVisualRefresh();
    },
    addInputAssist() {
      // iOS/PWA環境でスピナーをタップすると編集が終了してしまう現象の対策
      if (this.isIOS) {
        const numericTextBox = getScopedNumericTextBox(this.$el || this);
        if (numericTextBox) {
          let spinnerObj = numericTextBox.getElementsByClassName("k-select")[0];
          // 編集が終了するとオブジェクトが削除されるため、removeEvent処理は不要
          spinnerObj.ontouchend = event => event.stopPropagation();
        }
      }
    },
    // マスタ一覧のデータを取得
    findList() {
      this.setMasterName("mst_weight_scale");
      // apiをコールして値を取得
      // mod マスタ一覧 1･施設切替を可能とする 孔 this.findRecordList => this.findRecordListByFacilityCd
      // this.findRecordList()
      this.findRecordListByFacilityCd(this.facilitylistValue)
        .then(response => {
          // editableをKendoUI用にfunctionオブジェクトに変換
          const toFunction = response.data.columns;
          toFunction.forEach(column => {
            // 初期表示時の編集可否を退避
            column.originalEditable = column.editable;
            // 編集可否を関数化
            column.editable = column.editable ? () => true : () => false;
            // 列幅初期化
            column["width"] = column.width ? column.width : "0";
          });
          this.columns = toFunction;

          // 横スクロールバーを表示するために列幅を指定
          this.columns.forEach(column => {
            // 「削除」のプルダウンが改行しない幅に調整
            // add FNSI-redmine3987 徐 start
            // mod #7289-マスタの削除ボタンが縦表示になる 徐博 start
            // column.width = column.field === "isDisp" ? "8em" : "14em";
            column.width = column.field === "isDisp" ? "9em" : "15em";
            // mod #7289-マスタの削除ボタンが縦表示になる 徐博 end
            // add FNSI-redmine3987 徐 end
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
            editable: () => false,
            width: "10px",
            format: "",
            values: null
          });
          // カラム幅等初期調整
          this.showSortColumn();
          this.invalidateDirectGridColumnFieldCache();
          this.$nextTick(() => {
            this.initDirectGridIfReady();
            this.refreshDirectGridDataSource();
            this.scheduleDirectGridLayoutContract();
            this.scheduleDirectGridPostLayoutRefresh();
            this.restoreDirectGridScrollPosition();
            requestAnimationFrame(() => {
              this.restoreDirectGridScrollPosition();
            });
            // 初期データが1件もなければ追加
            if (this.getMasterRecordList.data.length === 0) {
              this.addRow();
            }
            // Kendo 初期化後の uid / dirty 等を除いたスナップショットを保存
            this.$nextTick(() => {
              this.setScaleComparisonRecordModel();
            });
          });
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstWeightScaleListRecordComponent.vue', 'findList', '指定されたマスタが見つかりません。');
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
    setFilterCondition(condition) {
      this.condition.recordName = condition.recordName;
      this.condition.includeDeleted = condition.includeDeleted;
    },
    async saveRecord() {
      this.storeDirectGridScrollPosition();
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        return {
          response: -2,
          message: "不正な値があります"
        };
      }

      // 新規追加＆未入力のレコードを除外
      const records = this.getMasterRecordList;
      records.data = records.data.filter(
        r => !(r.operation === 1 && !r.edited)
      );
      this.setMasterRecordList(records);

      // 必須エラーをチェック
      const validateMessage = this.validateRequired();
      // コンボで削除済みのレコードが指定されていないかをチェック
      const validateComboMessage = this.validateComboValue();

      let message = "";
      if (validateMessage.length !== 0) {
        message = "以下の列に未入力項目が存在します。" + validateMessage;
      }
      if (validateComboMessage.length !== 0) {
        if (message.length !== 0) message = message + "</br>";
        message =
          message + "以下の列の選択を見直してください。" + validateComboMessage;
      }
      // エラーメッセージは左寄せで表示
      if (message.length !== 0) {
        return {
          response: -1,
          message: message
        };
      }

      // apiをコールして値を保存
      // add マスタ一覧 1･施設切替を可能とする 孔 start
      const params = {
        request: this.getUpdateRecordList,
        facilityCd: this.facilitylistValue
      }
      // add マスタ一覧 1･施設切替を可能とする 孔 start
      // mod マスタ一覧 1･施設切替を可能とする 孔 this.updateRecordList => this.updateRecordListByFacilityCd
      // return this.updateRecordList(this.getUpdateRecordList)
      return this.updateRecordListByFacilityCd(params)
        .then(response => {
          this.updateResponse = response.data;

          this.findList();
          return {
            response: 1,
            message: response.data
          };
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstWeightScaleListRecordComponent.vue', 'saveRecord', error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
            return {
              response: 0,
              message: error.response.data.errorMessage
            };
          }
        });
    },
    validateRequired() {
      let validateMessageArr = [];
      const gridData = this.getMasterRecordList;
      // ストアに保存されているデータについて必須項目の未入力をチェックする
      for (let idx = 0; idx < gridData.data.length; idx++) {
        // スキーマ情報の件数分をチェック
        const keys = Object.keys(gridData.schema.model.fields);
        for (let keyCount = 0; keyCount < keys.length; keyCount++) {
          // バリデーションで必須が定義されている項目を対象
          const validation =
            gridData.schema.model.fields[keys[keyCount]].validation;
          if (typeof validation !== "undefined" && validation.required) {
            if (
              gridData.data[idx][keys[keyCount]] !== null &&
              gridData.data[idx][keys[keyCount]] === ""
            ) {
              // カラム名からタイトルを取得
              const columnInfo = this.columns.find(
                e => e.field == keys[keyCount]
              );
              // 項目名が重複していなければ、メッセージに追加
              validateMessageArr.push(columnInfo.title);
            }
          }
        }
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
          values: column.values
        }));

      // 削除されていないレコード
      const gridData = this.getMasterRecordList;
      const rows = gridData.data.filter(row => row.isDisp !== "0");
      // コンボの列を対象に、ストアの値がコンボのvaluesに存在することをチェック
      let validateMessageArr = [];
      for (let rowIdx = 0; rowIdx < rows.length; rowIdx++) {
        for (let comboIdx = 0; comboIdx < comboFields.length; comboIdx++) {
          const columnValue = rows[rowIdx][comboFields[comboIdx].field];
          // valuesにデータ値が存在せず、データ値がNullか空文字でなければエラー
          const index = comboFields[comboIdx].values.findIndex(
            e => e.value == columnValue
          );
          if (index < 0 && (columnValue !== null && columnValue !== "")) {
            validateMessageArr.push(comboFields[comboIdx].title);
          }
        }
      }
      return this.convertToStr(validateMessageArr);
    },
    convertToStr(messageArr) {
      if (messageArr.length === 0) return "";

      const unique = messageArr.reduce((acc, cur) => {
        if (acc.indexOf(cur) === -1) {
          acc.push(cur);
        }
        return acc;
      }, []);

      const prefix = "</br>&nbsp&nbsp・";
      return prefix + unique.join(prefix);
    },
    sort() {
      const compare = (a, b) =>
        a.sortRank - b.sortRank || a.sortInputTime - b.sortInputTime;
      //グリッドデータの並び替え
      this.getMasterRecordList.data.sort(compare);
    },
    getDirectGridRowsByUid(uid) {
      const root = this.getGridRoot();
      if (!root || !uid) {
        return { row: null, lockedRow: null };
      }
      const escapedUid = typeof CSS !== "undefined" && typeof CSS.escape === "function"
        ? CSS.escape(String(uid))
        : String(uid);
      return {
        row: root.querySelector(`.k-grid-content:not(.k-grid-content-locked) tr[data-uid="${escapedUid}"]`),
        lockedRow: root.querySelector(`.k-grid-content-locked tr[data-uid="${escapedUid}"]`)
      };
    },
    onSave(ev) {
      this.editingFlg = false;
      this.setIsGridEditing(false);
      const changedFields = this.getDirectGridActualChangedFields(ev);
      if (changedFields.length === 0) {
        this.syncDirectGridModelToStore(ev);
        this.$nextTick(() => {
          const selectedUid = this.getDirectGridSelectedUid();
          this.applyDirectGridRowVisualByUid(ev.model?.uid, ev.model, selectedUid === ev.model?.uid);
          this.scheduleDirectGridLayoutContract();
        });
        return;
      }
      if (ev.model.operation === 1) {
        ev.model["edited"] = true;
      }
      if (ev.model.operation !== 1 && !this.isSortMode) {
        ev.model.operation = 2;
      }
      this.edit({ editRecord: ev.model, isSortMode: this.isSortMode });
      this.$nextTick(() => {
        this.applyDirectGridRowVisualByUid(ev.model?.uid, ev.model);
        this.scheduleDirectGridVisualRefresh();
        this.scheduleDirectGridLayoutContract();
      });
    },
    showMasterEditModal(e) {
      // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      const { top: scrollTop, left: scrollLeft } = this.getGridScrollPosition();
      this.scrollPosition.top = scrollTop;
      this.scrollPosition.left = scrollLeft;
      // モーダルを表示
      this.showMasterEdit();

      /**
       * 「詳細」ボタンを押下したレコードのデータを取得する。
       * see: https://www.telerik.com/forums/selected-row-at-wrappers-for-vue
       */
      e.preventDefault();
      const row = e.currentTarget.closest("tr");
      const selectedRowItem = this.getGridDataItem(row);
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
    onCloseMasterEditModal() {
      this.$nextTick(() => {
        this.setScrollPosition(this.scrollPosition);
      });
      // Androidでスクロール位置が戻らない場合があるのでもう一度設定
      setTimeout(() => {
        this.setScrollPosition(this.scrollPosition);
      }, 1000);
      this.scheduleDirectGridVisualRefresh();
    },
    setScrollPosition(position) {
      this.setGridScrollPosition({ top: position.top, left: position.left });
    },
    addRow() {
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        return;
      }

      // 空レコードをストアに登録
      let d = new Object();
      const fields = this.getMasterRecordList.schema.model.fields;
      Object.keys(fields).forEach(k => {
        if (fields[k].defaultValue) {
          d[k] = fields[k].defaultValue;
        } else if (fields[k].type === "string") {
          d[k] = "";
        } else if (fields[k].type === "number") {
          d[k] = 0;
        } else if (fields[k].type === "date") {
          d[k] = new Date();
        } else {
          d[k] = null;
        }

        if (k === "patIdDigit") {
          d[k] = 12;
        } else if (k === "isDoubleCheck" || k === "isDuringDialysisView") {
          d[k] = "0";
        } else if (
          k === "name" ||
          k === "defaultScreenClass" ||
          k === "tareUnitClass" ||
          k === "waterUnitClass" ||
          k === "previousWeightSourceClass"
        ) {
          d[k] = 0;
        }
      });
      if (Object.prototype.hasOwnProperty.call(d, "code")) {
        d.code = null;
      }
      this.edit({ editRecord: d, isSortMode: this.isSortMode });
      // 変更とする
      d["edited"] = true;
      this.$nextTick(() => {
        this.refreshDirectGridDataSource();
        const content = this.getGridContentEl();
        if (content) {
          content.scrollTop = content.scrollHeight;
          this.syncDirectGridLockedScrollPosition(content.scrollTop);
        }
        this.scheduleDirectGridVisualRefresh();
      });
    },
    showSortColumn() {
      // 編集・並び順設定モードによって並び順項目の表示・非表示を切り替える
      // （先頭ダミー要素列と並び順列を交互に表示・非表示する）
      const sortRankIndex = this.columns.findIndex(
        col => col.field === "sortRank"
      );
      if (sortRankIndex >= 0) {
        this.columns[sortRankIndex].hidden = !(
          this.isAllowSort && this.isSortMode
        );
        const dummyIndex = this.columns.findIndex(col => col.field === "dummy");
        if (dummyIndex >= 0) {
          this.columns[dummyIndex].hidden = !this.columns[sortRankIndex].hidden;
        }
      }
      this.applyDirectGridColumnsContract();
      this.invalidateDirectGridColumnFieldCache();
      this.scheduleDirectGridLayoutContract();
    },
    disableColumns() {
      this.columns.forEach(column => {
        // 並び順列を編集可、並び順列以外を編集不可に。
        column.editable =
          column.field == "sortRank"
            ? this.isAllowSort
              ? () => true
              : () => false
            : () => false;
      });
    },
    editableColumns() {
      this.columns.forEach(column => {
        // 編集可否の設定を初期表示時の状態に戻す
        column.editable =
          column.field == "sortRank"
            ? () => false
            : column.originalEditable
              ? () => true
              : () => false;
      });
    },
    getColumnIndex(fieldName) {
      // 指定された項目がない場合はマイナスが返る
      return this.columns.findIndex(e => e.field === fieldName);
    },
    editBackgroundColor() {
      if (this.editingFlg) {
        return;
      }
      this.$nextTick(() => {
        const gridHeader = this.getGridHeaderEl();
        if (!gridHeader || gridHeader.textContent === " ") {
          return;
        }
        gridHeader.classList.add("master-grid-header");
        const selectedUid = this.getDirectGridSelectedUid();
        const grid = this.directGridWidget;
        const processed = new Set();
        const paintRecord = record => {
          if (!record?.uid || processed.has(record.uid)) {
            return;
          }
          processed.add(record.uid);
          this.applyDirectGridRowVisualByUid(record.uid, record, record.uid === selectedUid);
        };
        (grid?.dataSource?.data?.() || []).forEach(paintRecord);
        const root = this.getGridRoot();
        if (root) {
          root.querySelectorAll("tbody tr[data-uid]").forEach(tr => {
            const uid = tr.getAttribute("data-uid");
            if (!uid || processed.has(uid)) {
              return;
            }
            const record = grid?.dataItem?.(tr);
            if (record) {
              paintRecord(record);
            }
          });
        }
      });
    },
    getDirectSortColorRowFromCells(currentTrc) {
      return Array.from(currentTrc || [])[0]?.parentElement || null;
    },
    isDirectSortColorLockedRow(row) {
      return !!row?.closest?.(".k-grid-content-locked");
    },
    getDirectSortColorVisibleColumnsForRow(row) {
      const locked = this.isDirectSortColorLockedRow(row);
      return (this.columns || []).filter(column => !column.hidden && !!column.locked === locked);
    },
    getDirectSortColorCellByField(row, fieldName) {
      if (!row || !fieldName) {
        return null;
      }
      const index = this.getDirectSortColorVisibleColumnsForRow(row).findIndex(column => column.field === fieldName);
      if (index < 0) {
        return null;
      }
      return Array.from(row.children || [])[index] || null;
    },
    changeSortColorByRow(row) {
      const sortCell = this.getDirectSortColorCellByField(row, "sortRank");
      if (!sortCell || !this.isEditRow(sortCell)) {
        return false;
      }
      sortCell.classList.add("master-sort-edited");
      const dummyCell = this.getDirectSortColorCellByField(row, "dummy");
      dummyCell?.classList?.add("master-sort-edited");
      return true;
    },
    changeSortColor(currentTrc, currentLockTrc = null) {
      [currentTrc, currentLockTrc].forEach(cells => {
        this.changeSortColorByRow(this.getDirectSortColorRowFromCells(cells));
      });
    },
    changeEditColor(currentTrc) {
      let edited = false;
      // 変更されたセルの文字色を変更
      for (let clCount = 0; clCount < currentTrc.length; clCount++) {
        if (
          this.isEditRow(currentTrc[clCount]) &&
          clCount !== this.getColumnIndex("sortRank")
        ) {
          currentTrc[clCount]?.classList?.add("master-edited-cell");
          edited = true;
        }
      }
      return edited;
    },
    isDeleteRow(currentTrc) {
      let deleted = false;
      // 削除カラムで削除が選択されている場合は削除フラグを設定
      for (let clCount = 0; clCount < currentTrc.length; clCount++) {
        if (
          this.isEditRow(currentTrc[clCount]) &&
          clCount !== this.getColumnIndex("sortRank")
        ) {
          if (
            currentTrc[clCount].children[0].nextSibling &&
            currentTrc[clCount].children[0].nextSibling.data === "削除" &&
            this.getColumnIndex("isDisp") === clCount
          ) {
            deleted = true;
          }
        }
      }
      return deleted;
    },
    changeRowColor(currentTrc, currentLockTrc, edited, deleted) {
      if (!(edited || deleted)) {
        return;
      }
      const addClass = deleted ? "master-deleted-row" : "master-edited-row";
      const sortRankIndex = this.getColumnIndex("sortRank");
      const applyToCells = (cells, locked) => {
        Array.from(cells || []).forEach((cell, visibleIndex) => {
          const columns = this.getDirectGridVisibleColumns(locked);
          const column = columns[visibleIndex];
          if (column && this.shouldApplyDirectGridRowBackground(column, sortRankIndex)) {
            cell?.classList?.add(addClass);
          }
        });
      };
      applyToCells(currentLockTrc, true);
      applyToCells(currentTrc, false);
    },
    // mod #9863 編集時背景色表示異常の横展開 蔡 start
    // changeRefErrorComboColor(currentTrc, rowDeleted) {
    // currentLockTrc：左gridのリストを取得する
    changeRefErrorComboColor(currentUnLockTrc, rowDeleted, currentLockTrc) {
    // mod #9863 編集時背景色表示異常の横展開 蔡 end
      // 削除行は処理対象外
      if (rowDeleted) {
        return;
      }
      // add #9863 編集時背景色表示異常の横展開 蔡 start
      let currentTrc = [];
      for (let clCount = 0; clCount < currentLockTrc.length; clCount++) {
        currentTrc.push(currentLockTrc[clCount]);
      }
      for (let clCount = 0; clCount < currentUnLockTrc.length; clCount++) {
        currentTrc.push(currentUnLockTrc[clCount]);
      }
      if (currentTrc.length !== this.columns.length) {
        return;
      }
      // add #9863 編集時背景色表示異常の横展開 蔡 end
      const codeIndex = this.getColumnIndex('code');
      const codeCell = codeIndex >= 0 ? currentTrc[codeIndex] : null;
      if (!codeCell) {
        return;
      }
      const codeValue = String(codeCell.textContent ?? '').replaceAll(",", "");
      // コンボリストが設定されていてデータが存在するが、画面表示上は空の場合は削除済みレコードを参照として背景色を変更
      for (let clCount = 0; clCount < currentTrc.length; clCount++) {
        const columnInfo = this.columns[clCount];
        const hasValueColumn = this.hasValueColumn(
          // mod #9863 編集時背景色表示異常の横展開 蔡 start
          // currentTrc[this.getColumnIndex("code")].textContent,
          codeValue,
          // mod #9863 編集時背景色表示異常の横展開 蔡 end
          columnInfo.field
        );
        if (
          columnInfo.values !== null &&
          hasValueColumn &&
          currentTrc[clCount].textContent === ""
        ) {
          currentTrc[clCount]?.classList?.add("master-deleted-combo");
        }
      }
    },
    isEditRow(currentTd) {
      // 編集した行を判定
      return currentTd.classList.contains("k-dirty-cell");
    },
    normalization(items) {
      // columnの定義にあわせてデータを正規化する。
      const columnNames = this.columnDefinition.map(column => column.field);

      return Object.keys(items)
        .filter(key => columnNames.includes(key))
        .reduce((acc, key) => {
          acc[key] = items[key];
          return acc;
        }, {});
    },
    loadGridData(){
      // delete start #9590
        // this.setCondition(this.condition);
        // delete end #9590
      this.findList();
    },
    // パンくずリストをクリックされた場合に呼び出される関数
    refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      if (this.selfScreenName === this.$route.name
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
                this.loadGridData();
              }
            }
          });
        } else {
          this.loadGridData();
        }
      }
    }
  },
  created() {
    // add マスタ一覧 1･施設切替を可能とする 孔 start
    this.facilitylistValue = this.getFacilitySwitch;
    // add マスタ一覧 1･施設切替を可能とする 孔 end
    this.loadGridData();
    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    // 端末判別
    const ua = ((this?.$el?.ownerDocument?.defaultView?.navigator?.userAgent) || globalThis?.navigator?.userAgent || "");
    if (ua.match(/Android/)) {
      this.isAndroid = true;
    } else if (ua.match(/iPhone|iPad/)) {
      this.isIOS = true;
    }
    this.selfScreenName = this.$route.name;
    EventBus.$on("onCloseMasterEditModal", this.onCloseMasterEditModal);
  },
  mounted() {
    this.$nextTick(() => this.initDirectGridIfReady());
  },
  updated() {
    this.scheduleDirectGridVisualRefresh();
  },
  // add 性能改善メモリ不足 shan start
  beforeUnmount() {
    EventBus.$off("onCloseMasterEditModal", this.onCloseMasterEditModal);
    if (this.directGridLayoutRafId != null) {
      cancelAnimationFrame(this.directGridLayoutRafId);
      this.directGridLayoutRafId = null;
    }
    if (this.directGridLayoutRefreshRafId != null) {
      cancelAnimationFrame(this.directGridLayoutRefreshRafId);
      this.directGridLayoutRefreshRafId = null;
    }
    if (this.directGridVisualRafId != null) {
      cancelAnimationFrame(this.directGridVisualRafId);
      this.directGridVisualRafId = null;
    }
    this.destroyDirectGrid();
    this.directGridEditOriginals?.clear?.();
  }
  // add 性能改善メモリ不足 shan start
};
</script>

<!-- 個別スタイル定義 -->
<style scoped>
.ntss-list{
  position: relative;
}
.right {
  text-align: right;
}
.header-btn-area {
  height: 2.5em;
  padding: 0.1em 0.1em 0.1em 0.1em;
}
.kendo-grid-toolbar-style {
  --height: 200px;
  height: var(--height);
  border-bottom: none;
}
.kendo-grid-toolbar-style {
  padding: 0;
}
.weight-scale-grid :deep(.k-grid-content) {
  max-height: 120px;
}

.mst-weight-scale-direct-jq-grid {
  width: 100%;
}
.mst-weight-scale-direct-jq-grid :deep(td.master-selected-row),
.mst-weight-scale-direct-jq-grid :deep(tr.k-selected > td.master-selected-row),
.mst-weight-scale-direct-jq-grid :deep(tr.k-state-selected > td.master-selected-row),
.mst-weight-scale-direct-jq-grid :deep(tr.k-table-row.k-selected > td.master-selected-row),
.mst-weight-scale-direct-jq-grid :deep(tr.k-alt > td.master-selected-row) {
  color: var(--master-maintenance-kgrid-selected-color);
  background-color: var(--master-maintenance-kgrid-selected-background-color) !important;
}
.mst-weight-scale-direct-jq-grid :deep(tr.k-selected td.k-edit-cell),
.mst-weight-scale-direct-jq-grid :deep(tr.k-state-selected td.k-edit-cell) {
  color: var(--master-maintenance-kgrid-selected-color);
  background-color: var(--master-maintenance-kgrid-selected-background-color) !important;
}
.mst-weight-scale-direct-jq-grid :deep(td.master-edited-row),
.mst-weight-scale-direct-jq-grid :deep(tr.k-selected > td.master-edited-row),
.mst-weight-scale-direct-jq-grid :deep(tr.k-state-selected > td.master-edited-row),
.mst-weight-scale-direct-jq-grid :deep(tr.k-table-row.k-selected > td.master-edited-row),
.mst-weight-scale-direct-jq-grid :deep(tr.k-alt > td.master-edited-row) {
  color: #003300 !important;
  background-color: #ccffcc !important;
}
.mst-weight-scale-direct-jq-grid :deep(td.master-edited-cell) {
  color: #003300 !important;
  font-weight: normal !important;
}
.mst-weight-scale-direct-jq-grid :deep(td.master-sort-edited),
.mst-weight-scale-direct-jq-grid :deep(tr.k-selected > td.master-sort-edited),
.mst-weight-scale-direct-jq-grid :deep(tr.k-state-selected > td.master-sort-edited),
.mst-weight-scale-direct-jq-grid :deep(tr.k-table-row.k-selected > td.master-sort-edited) {
  background-color: #ffff66 !important;
}
.mst-weight-scale-direct-jq-grid :deep(td.master-deleted-row),
.mst-weight-scale-direct-jq-grid :deep(tr.k-selected > td.master-deleted-row),
.mst-weight-scale-direct-jq-grid :deep(tr.k-state-selected > td.master-deleted-row),
.mst-weight-scale-direct-jq-grid :deep(tr.k-table-row.k-selected > td.master-deleted-row) {
  color: #333333 !important;
  background-color: #9d9d9d !important;
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
