<template>
  <div class="main-area">
    <div class="tabs">
      <input id="dcs" type="radio" name="tab_item" checked @click="changeTabSelect(1)" />
      <label class="tab_item" for="dcs">透析装置</label>
      <input id="dab" type="radio" name="tab_item" @click="changeTabSelect(2)" />
      <label class="tab_item" for="dab">供給装置</label>
      <input id="dad" type="radio" name="tab_item" @click="changeTabSelect(3)" />
      <label class="tab_item" for="dad">溶解装置</label>
      <input id="dro" type="radio" name="tab_item" @click="changeTabSelect(4)" />
      <label class="tab_item" for="dro">ＲＯ装置</label>
    </div>
    <div class="disp-item-list" :style="ntssListStyles" v-kendo-validator="kendoValidatorSetup">
      <kendo-grid-toolbar class="k-grid-toolbar kendo-grid-toolbar-style" :style="heightStyles">
        <div v-show="popoverVisible" id="item-box-list" :style="addListHeightStyles">
          <p id="select-text">表示項目を選択してください:</p>
            <div class="selected-list flex-1 d-flex">
              <div class="selected-item-list flex-1">
                <div class="list-wrapper">
                  <div
                    :class="[
                      'display-list',
                      { selected: selectedSelection.includes(option.value) }
                    ]"
                    v-for="(option, index) in multiSelectList"
                    :key="option.length"
                    :value="option.value"
                    @click.exact="singleSelect(index, option.value)"
                    @click.shift.exact="rangeSelect(index)"
                  >{{ option.text }}
                  </div>
                </div>
              </div>
            </div>
        </div>
        <div v-show="popoverVisible" id="item-box-conf">
          <div id="list-footer">
            <div class="dialog-cancel">
              <ons-button class="nik-btn cancel btn2-cancel" style="color: white" @click="selectCancel">キャンセル</ons-button>
            </div>
            <div class="dialog-conf">
              <ons-button class="nik-btn save btn1-execute" @click="addMultiSelect">確定</ons-button>
            </div>
          </div>
        </div>
        <div v-show="gridVisible">
        <div class="header-btn-area right">
          <v-ons-button
            modifier="outline"
            class="toolbar-btn btn3-normal"
            style="float: left; margin-right: 10px;"
            v-show="true"
            @click="addRow()"
          >追加</v-ons-button>
          <div v-show="isMobileDevice" class="custom-switch-wrapper">
            <label class="fab-font-color">編集</label>
            <v-ons-switch modifier="outline" v-model="allowEdit" />
          </div>
        </div>
        <div
          id="grid-font-size"
          ref="grid"
          :class="[
            fontSizeSet,
            'ntss-kendo-grid-legacy',
            'mst-treatment-status-layout-direct-jq-grid'
          ]"
          :style="ntssListStyles"
        ></div>
        </div>
      </kendo-grid-toolbar>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import {EventBus} from "@/compat/vue/event-bus.js";
// add #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 start

import {
  getModalBodyElement,
  getModalContainerElement,
  getModalFooterElement,
  getScopedElementById,
  queryScopedSelector,
  queryScopedSelectorAll
} from "@/functions/common/LayoutMeasureHelper";
import { markRaw } from "@/compat/vue/runtime";
import kendo from "@progress/kendo-ui";
import $ from "@/compat/jquery";

// add #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 end

/**
 * @description 治療状況レイアウトマスタの装置設定用モーダルコンポーネント
 */
export default {
  name: "MstTreatmentStatusLayoutComponent",
  data() {
    return {
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
      dummyDivHeight: 40,
      kendoGridToolbarHeight: 500,
      addListHeight: 400,
      kendoGridHeight: 300,
      kendoGridMinHeight: 300,
      kendoValidatorSetup: {
        rules: {},
        messages: {}
      },
      // 編集失敗時のマスタ/列/スキーマ情報のバックアップ
      backupMasterRecordList: [],
      editRecordOnComponent: [],
      refDispItemList: [],
      //Android端末で編集中であることを示すフラグ
      editingFlg: false,
      isAndroid: false,
      isIOS: false,
      popoverVisible: false,
      gridVisible: true,
      multiSelectList: [],
      allMultiSelectList: [],
      selectedSelection: [],
      singleIndex: "",
      groupIndex: [],
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
      lastScrollTop: 0,
      lastScrollLeft: 0,
      directGridWidget: null,
      directGridColumnSignature: "",
      directGridAppliedHeight: null,
      directGridLayoutRafId: null,
      directGridStyleRefreshRafId: null,
      directGridDataRefreshRafId: null,
      directGridNumericEditKeepUntil: 0,
      directGridNumericEditValue: null
    };
  },

  computed: {
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("account-edit", {
      getFontSize: "getFontSize"
    }),
    ...mapGetters("master-maintenance", ["getEditRecord"]),
    ...mapGetters("mst-treatment-status-layout", [
      "getSettingDataDcs",
      "getSettingDataDab",
      "getSettingDataDad",
      "getSettingDataDro",
      "getCurrentData",
      "getTabSelectedId",
      "getColumns",
      "getSelectedIndex"
    ]),
    dispMachineSetting() {
      const currentData = this.getCurrentData;
      return new kendo.data.DataSource({
        data: currentData,
        schema: {
          model: {
            fields: {
              order_no: {
                type: "number",
                // mod redmine 4660 治療状況レイアウトマスタの並び順で1行目に並び替えできない 孔 start
                // validation: { max: 30, min: 1 }
                // #11047 ⑥治療状況レイアウトマスタ＞詳細 全タブ　表示順　入力範囲が不正　30では足りない。 linjunfeng start
                // validation: { max: 30, min: 0 }
                validation: { min: 0 }
                // #11047 ⑥治療状況レイアウトマスタ＞詳細 全タブ　表示順　入力範囲が不正　30では足りない。 linjunfeng  end
                // mod redmine 4660 治療状況レイアウトマスタの並び順で1行目に並び替えできない 孔 end
              },
              width: {
                type: "number",
                validation: { max: 30, min: 1 }
              }
            }
          }
        }
      });
    },
    dispColumns() {
      return this.getColumns;
    },
    tabSelectedId() {
      return this.getTabSelectedId;
    },
    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },
    addListHeightStyles() {
      // main部の高さをCSS変数を利用して書き換え：装置表示項目リスト画面
      return { "--height": `${this.addListHeight}px` };
    },
    ntssListStyles() {
      return { display: "inherit" };
      // return { display: this.columns.length == 1 ? "none" : "inherit" };
    },
    isMobileDevice() {
      return this.isIOS || this.isAndroid;
    },
    fontSizeSet() {
      const names = ["small", "medium", "large", "x-large"];
      return `font-size-set-${names[this.getFontSize]}`;
    },
  },
  methods: {
    ...mapActions("master-maintenance", [
      "findRecordList",
      "setMasterRecordList",
      "edit",
      "updateRecordList",
      "setEditRecord",
      "editRecordBeEmpty"
    ]),
    ...mapActions("mst-treatment-status-layout", [
      "setSettingData",
      "changeCurrentData",
      "setCurrentData",
      "fetchDispItemList",
      "setColumnDispItemList",
      "remountCurrentData",
      "clearData",
      "setComboItemList_Act"
    ]),
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    getDirectGridRoot() {
      return this.$refs.grid || null;
    },
    getGridWidget() {
      return this.directGridWidget || null;
    },
    getDirectGridContent() {
      return this.getDirectGridRoot()?.querySelector?.(".k-grid-content") || null;
    },
    getGridHeaderEl() {
      return this.getDirectGridRoot()?.querySelector?.(".k-grid-header") || this.getDirectGridRoot()?.firstElementChild || null;
    },
    getGridScrollPosition() {
      const content = this.getDirectGridContent();
      return {
        top: content?.scrollTop || 0,
        left: content?.scrollLeft || 0
      };
    },
    restoreGridScrollPosition(top = this.lastScrollTop, left = this.lastScrollLeft) {
      const content = this.getDirectGridContent();
      if (!content) {
        return;
      }
      content.scrollTop = top || 0;
      content.scrollLeft = left || 0;
      try {
        $(content).trigger("scroll");
      } catch (_error) {
        // noop
      }
    },
    createDirectGridDataSource() {
      const currentData = this.getCurrentData || [];
      return markRaw(new kendo.data.DataSource({
        data: currentData,
        schema: {
          model: {
            fields: {
              order_no: {
                type: "number",
                validation: { min: 0 }
              },
              width: {
                type: "number",
                validation: { max: 30, min: 1 }
              }
            }
          }
        }
      }));
    },
    getDirectGridColumnSignature() {
      const columnsPart = (this.dispColumns || []).map(column => [
        column.field,
        column.hidden ? 1 : 0,
        column.locked ? 1 : 0,
        column.width || "",
        column.editable === false ? 0 : 1,
        Array.isArray(column.values) ? column.values.length : 0
      ].join(":")).join("|");
      return `tab:${this.tabSelectedId || 1}|${columnsPart}`;
    },
    pushDispItemComboOption(targetList, data) {
      if (!Array.isArray(targetList) || !data) {
        return;
      }
      if (targetList.some(entry => entry.value == data.itemCd)) {
        return;
      }
      // 下拉仅注册 itemCd；旧 data_class 中的 jsonKeyName 在 normalize 时映射到 itemCd。
      targetList.push({
        value: data.itemCd,
        text: data.itemName
      });
    },
    resolveTabDispItemComboList(tabId = this.tabSelectedId) {
      const lists = this.allMultiSelectList;
      if (!lists || typeof lists !== "object") {
        return [];
      }
      const map = {
        1: lists.DCS,
        2: lists.DAB,
        3: lists.DAD,
        4: lists.DRO
      };
      return map[tabId] || lists.DCS || [];
    },
    normalizeDispItemComboValues(values) {
      if (!Array.isArray(values)) {
        return [];
      }
      const uniqueByValue = new Map();
      const uniqueByText = new Map();
      values.forEach(entry => {
        if (entry?.value === null || entry?.value === undefined || entry?.value === "") {
          return;
        }
        const text = entry?.text ?? String(entry.value);
        const valueKey = String(entry.value);
        if (uniqueByValue.has(valueKey) || uniqueByText.has(text)) {
          return;
        }
        const normalized = {
          value: entry.value,
          text
        };
        uniqueByValue.set(valueKey, normalized);
        uniqueByText.set(text, normalized);
      });
      return Array.from(uniqueByValue.values());
    },
    resolveRowDispItem(row) {
      if (!row || !this.refDispItemList?.length) {
        return null;
      }
      const fromClass =
        row.data_class !== null &&
        row.data_class !== undefined &&
        row.data_class !== ""
          ? this.searchDispItem(row.data_class)
          : null;
      if (fromClass) {
        return fromClass;
      }
      const fromKey = row.key_name ? this.searchDispItem(row.key_name) : null;
      if (fromKey) {
        return fromKey;
      }
      const titleMatches = row.title
        ? this.refDispItemList.filter(item => item.itemName === row.title)
        : [];
      if (titleMatches.length === 1) {
        return titleMatches[0];
      }
      return null;
    },
    normalizeDispItemRowFields(row) {
      const item = this.resolveRowDispItem(row);
      if (!item) {
        return row;
      }
      row.data_class = item.itemCd;
      row.table_name = item.tableName;
      row.column_name = item.fieldName;
      row.key_name = item.jsonKeyName;
      row.vital_monitor_class = item.vitalMonitorClass;
      row.conv_type = item.dataClass;
      row.data_type = item.dataType;
      return row;
    },
    normalizeDispItemRows(rows) {
      if (!Array.isArray(rows)) {
        return [];
      }
      return rows.map(row => this.normalizeDispItemRowFields({ ...row }));
    },
    normalizeAllDispItemRows() {
      if (!this.refDispItemList?.length) {
        return;
      }
      const jsonData = {
        dcs: this.normalizeDispItemRows(this.getSettingDataDcs),
        dab: this.normalizeDispItemRows(this.getSettingDataDab),
        dad: this.normalizeDispItemRows(this.getSettingDataDad),
        dro: this.normalizeDispItemRows(this.getSettingDataDro)
      };
      this.setSettingData(jsonData);
      this.changeCurrentData(this.tabSelectedId || 1);
    },
    formatDataClassDisplay(itemCd, record = null) {
      const item = record
        ? this.resolveRowDispItem(record)
        : this.searchDispItem(itemCd);
      if (item?.itemName) {
        return item.itemName;
      }
      if (itemCd === null || itemCd === undefined || itemCd === "") {
        return "";
      }
      const comboValues = this.normalizeDispItemComboValues(
        this.resolveTabDispItemComboList()
      );
      const matched = comboValues.find(entry => entry.value == itemCd);
      return matched?.text ?? String(itemCd);
    },
    buildDirectGridColumns() {
      return (this.dispColumns || []).map(column => {
        const directColumn = { ...column };
        if (column.field === "delBtn") {
          directColumn.attributes = { style: "text-align: center;" };
          directColumn.command = {
            name: "customDelete",
            text: "",
            iconClass: "fa fa-trash",
            click: event => this.deleteRow(event)
          };
        }
        if (column.field === "data_class") {
          const comboValues = column.values?.length
            ? column.values
            : this.resolveTabDispItemComboList();
          directColumn.values = this.normalizeDispItemComboValues(comboValues);
          directColumn.template = dataItem => this.formatDataClassDisplay(
            dataItem?.data_class,
            dataItem
          );
        }
        if (column.field === "width" || column.field === "order_no") {
          directColumn.editor = (container, options) => this.numericEditor(container, options);
        }
        return directColumn;
      });
    },
    initDirectGridIfReady() {
      const root = this.getDirectGridRoot();
      if (!root || !this.gridVisible || !this.dispColumns?.length) {
        return;
      }
      if (this.directGridWidget) {
        this.applyDirectGridColumnsContract();
        this.refreshDirectGridDataFromStore();
        this.scheduleDirectGridLayoutContract();
        return;
      }
      $(root).empty();
      $(root).kendoGrid({
        dataSource: this.createDirectGridDataSource(),
        editable: true,
        selectable: true,
        reorderable: false,
        height: this.kendoGridHeight,
        scrollable: true,
        resizable: true,
        beforeEdit: event => this.editStart(event),
        cellClose: event => this.editEnd(event),
        edit: event => this.addInputAssist(event),
        save: event => this.onSave(event),
        dataBound: () => this.onDataBoundKendoGrid(),
        columns: this.buildDirectGridColumns()
      });
      this.directGridWidget = markRaw($(root).data("kendoGrid"));
      this.directGridColumnSignature = this.getDirectGridColumnSignature();
      this.directGridAppliedHeight = this.kendoGridHeight;
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
      const root = this.getDirectGridRoot();
      if (root) {
        $(root).empty();
      }
      this.directGridWidget = null;
      this.directGridColumnSignature = "";
      this.directGridAppliedHeight = null;
    },
    applyDirectGridColumnsContract(options = {}) {
      const grid = this.directGridWidget;
      if (!grid) {
        return;
      }
      const signature = this.getDirectGridColumnSignature();
      const nextColumns = this.buildDirectGridColumns();
      if (options.force || signature !== this.directGridColumnSignature) {
        grid.setOptions({ columns: nextColumns });
        this.directGridColumnSignature = signature;
        return;
      }
      nextColumns.forEach(column => {
        const gridColumn = (grid.columns || []).find(col => col.field === column.field);
        if (!gridColumn) {
          return;
        }
        if (column.field === "data_class") {
          gridColumn.values = column.values;
          gridColumn.template = column.template;
        }
      });
    },
    refreshDirectGridDataFromStore(restoreScroll = true) {
      const grid = this.directGridWidget;
      if (!grid?.dataSource) {
        return;
      }
      const position = this.getGridScrollPosition();
      if (position.top !== 0) {
        this.lastScrollTop = position.top;
      }
      if (position.left !== 0) {
        this.lastScrollLeft = position.left;
      }
      grid.setDataSource(this.createDirectGridDataSource());
      if (restoreScroll) {
        this.$nextTick(() => this.restoreGridScrollPosition());
      }
      this.scheduleDirectGridLayoutContract();
    },
    onDataBoundKendoGrid() {
      this.applyDirectGridStyleContract();
      this.scheduleDirectGridLayoutContract();
    },
    applyDirectGridStyleContract() {
      const root = this.getDirectGridRoot();
      if (!root) {
        return;
      }
      root.classList.add("ntss-kendo-grid-legacy", "k-widget", "k-grid", "k-editable", "k-display-block");
      const header = this.getGridHeaderEl();
      header?.classList?.add("master-grid-header");
      root.querySelectorAll(".k-grid-content tbody").forEach(tbody => {
        Array.from(tbody.rows || []).forEach((row, index) => {
          row.classList.add("k-master-row");
          row.classList.toggle("k-alt", index % 2 === 1);
        });
      });
      root.querySelectorAll(".k-grid-content tbody td").forEach(cell => {
        cell.classList.add("k-td", "k-table-td");
      });
    },
    scheduleDirectGridLayoutContract() {
      if (this.directGridLayoutRafId != null) {
        cancelAnimationFrame(this.directGridLayoutRafId);
      }
      this.directGridLayoutRafId = requestAnimationFrame(() => {
        this.directGridLayoutRafId = requestAnimationFrame(() => {
          this.directGridLayoutRafId = null;
          if (this.directGridWidget) {
            if (this.directGridAppliedHeight !== this.kendoGridHeight) {
              this.directGridWidget.setOptions({ height: this.kendoGridHeight });
              this.directGridAppliedHeight = this.kendoGridHeight;
            }
            this.directGridWidget.resize?.(true);
            this.applyDirectGridStyleContract();
          }
        });
      });
    },
    getLayoutModalDocument() {
      return this.$el?.ownerDocument || document;
    },
    getCurrentModalContainer() {
      return (
        getModalContainerElement(this.$el) ||
        this.$el?.closest?.(".modal-container") ||
        this.getLayoutModalDocument().querySelector(".modal-container") ||
        null
      );
    },
    getCurrentModalBody() {
      return (
        getModalBodyElement(this.$el) ||
        this.getCurrentModalContainer()?.querySelector?.(
          ".modal-body, .modal-body-search, .modal-body-no-footer"
        ) ||
        this.getLayoutModalDocument().querySelector(".modal-body") ||
        null
      );
    },
    getCurrentModalFooter() {
      return (
        getModalFooterElement(this.$el) ||
        this.getCurrentModalContainer()?.querySelector?.(".modal-footer") ||
        this.getLayoutModalDocument().querySelector(".modal-footer") ||
        null
      );
    },
    getGridFontSizeElement() {
      return (
        this.getDirectGridRoot() ||
        this.$el?.querySelector?.("#grid-font-size") ||
        getScopedElementById("grid-font-size", this.$el)
      );
    },
    /** Kendo Grid が data-source 更新を拾わない場合の再描画（editEnd と同手法） */
    refreshCurrentTabGrid() {
      const selectedIndex = this.getSelectedIndex;
      let dummyIndex = selectedIndex < 4 ? selectedIndex + 1 : 3;
      this.changeCurrentData(dummyIndex);
      this.changeCurrentData(selectedIndex);
      this.$nextTick(() => {
        this.applyDirectGridColumnsContract({ force: true });
        this.refreshDirectGridDataFromStore();
      });
    },
    singleSelect(index, values) {
      this.selectedSelection.includes(values)
        ? this.selectedSelection.splice(
            this.selectedSelection.indexOf(values),
            1
          )
        : this.selectedSelection.push(values); this.singleIndex = index;
    },
    rangeSelect(index) {
      const firstIndex = this.singleIndex;
      this.groupIndex = [];
      if(index < firstIndex){
        this.groupIndex = Array.from(
          { length: firstIndex - index + 1},
          (v, i) => i + index
        );
      } else {
        this.groupIndex = Array.from(
          { length: index - firstIndex + 1},
          (v, i) => i + firstIndex
        );
      }

      const allList = this.multiSelectList;
      for (let l = 0; l < this.groupIndex.length; l++) {
        let shiftItem = this.groupIndex[l];
        let shiftValue = allList[shiftItem].value;
        // 存在しない場合、配列にpushする
        if(this.selectedSelection.indexOf(shiftValue) == -1) {
          this.selectedSelection.push(shiftValue);
        }
      }
    },
    /**
     * タブ切り替え時、表示内容を切り替える
     */
    changeTabSelect(selectedId) {
      const currentId = this.tabSelectedId;
      this.selectedSelection = [];
      // 選択中のタブがクリックされた場合は処理しない
      if (selectedId != currentId) {
        // 表示データの切り替え
        this.changeCurrentData(selectedId);
        const tabLists = {
          1: this.allMultiSelectList.DCS,
          2: this.allMultiSelectList.DAB,
          3: this.allMultiSelectList.DAD,
          4: this.allMultiSelectList.DRO
        };
        const activeTabList = tabLists[selectedId] || tabLists[1] || [];
        this.multiSelectList = activeTabList;
        this.setColumnDispItemList(activeTabList);
        this.$nextTick(() => {
          this.applyDirectGridColumnsContract({ force: true });
          this.refreshDirectGridDataFromStore(false);
        });
      }
    },
    /* ストアに登録する */
    setDispSettingData(editRecord) {
      let jsonData = {};
      // JSON文字列を管理用Index付きJSONオブジェクトに変換
      jsonData.dcs = this.createDispJson(editRecord.dcsViewItems);
      jsonData.dab = this.createDispJson(editRecord.dabViewItems);
      jsonData.dad = this.createDispJson(editRecord.dadViewItems);
      jsonData.dro = this.createDispJson(editRecord.droViewItems);

      // JSONオブジェクトを表示順でソート
      jsonData.dcs = this.sortDispDataByDispOrder(jsonData.dcs);
      jsonData.dab = this.sortDispDataByDispOrder(jsonData.dab);
      jsonData.dad = this.sortDispDataByDispOrder(jsonData.dad);
      jsonData.dro = this.sortDispDataByDispOrder(jsonData.dro);

      this.setSettingData(jsonData);
    },
    /**
     * 表示データを表示順で並べ替える
     */
    sortDispDataByDispOrder(jsonData) {
      // 表示順でソート
      // add #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou start
      if (jsonData) {
      // add #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou end
        return jsonData.sort((a, b) => a.order_no - b.order_no);
      // add #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou start
      } else {
        return [];
      }
      // add #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou end
    },
    /**
     * 表示順を振りなおす
     */
    reorderDispOrder( jsonData) {
      // 表示順を振りなおす
      for( let idx = 0; idx < jsonData.length; idx++) {
        jsonData[idx].order_no = idx + 1;
      }
      return jsonData;
    },

    /**
     * 表示するデータを構築
     */
    createDispJson(jsonString) {
      // JSON文字列をJSONオブジェクトに変換
      // add #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou start
      if (jsonString) {
      // add #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou end
        const bufJson = JSON.parse(jsonString);
        // キー情報が無いためインデックスを付与
        for (let lop = 0; lop < bufJson.length; lop++) {
          let buf = bufJson[lop];
          buf.index = lop;
        }
        return bufJson;
      // add #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou start
      } else {
        return [];
      }
      // add #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou end
    },
    onSave(ev) {
      const editObject = ev.values;
      const editKey = Object.keys(editObject)[0];
      const keepNumericEdit = this.shouldKeepDirectGridNumericEdit(editKey);
      this.editingFlg = keepNumericEdit;
      /** Grid内のデータを変更した際の処理 */

      // スクロール位置が先頭でない場合、その位置を保持する
      const position = this.getGridScrollPosition();
      const scrollTop = position.top;
      const scrollLeft = position.left;
      if (scrollTop != 0) {
        this.lastScrollTop = scrollTop;
      }
      if (scrollLeft != 0) {
        this.lastScrollLeft = scrollLeft;
      }

      // 編集内容取得
      const editRowInfo = ev.model;
      const editIndex = editRowInfo.index;

      // 現在の表示データ取得
      let currentData = this.getCurrentData;

      // 編集箇所判定
      if (editKey == "data_class") {
        // 表示項目選択コンボボックスの場合
        const editData = editObject.data_class ?? editRowInfo?.data_class;
        const editValue = this.extractDispItemEditValue(editData);
        if (editValue === null || editValue === undefined || editValue === "") {
          return;
        }

        // 表示項目一覧から該当のdata_classを探し、各値をセットする
        const dispItem = this.searchDispItem(editValue);
        if (!dispItem) {
          return;
        }
        currentData.forEach(data => {
          if (data.index == editIndex) {
            data.data_class = dispItem.itemCd;
            data.table_name = dispItem.tableName;
            data.column_name = dispItem.fieldName;
            data.key_name = dispItem.jsonKeyName;
            data.vital_monitor_class = dispItem.vitalMonitorClass;
            data.conv_type = dispItem.dataClass;
            data.data_type = dispItem.dataType;
            // 表示名が空の場合はコンボボックスの選択した表示項目をセット
            if (!data.title) {
              data.title = dispItem.itemName;
            }
          }
        });
      } else {
        // 表示項目選択コンボボックス以外の場合
        const editValue = this.isDirectGridNumericField(editKey)
          ? this.getDirectGridNumericEditValue(editRowInfo, editKey, editObject[editKey])
          : editObject[editKey];
        currentData.forEach(data => {
          if (data.index == editIndex) {
            data[editKey] = editValue;
          }
        });
      }

      // 表示順が変更された場合表示データをソートする
      if (editKey == "order_no") {
        currentData = this.sortDispDataByDispOrder(currentData);

        // JSONオブジェクトの表示順を振り直し
        currentData = this.reorderDispOrder(currentData);
      }

      // カレントデータ更新
      this.setCurrentData(currentData);

      if (!keepNumericEdit && !this.isDirectGridNumericField(editKey)) {
        /** コンボボックスの項目で編集前に値がない場合、選択確定後に選択内容が表示されない対策 */
        this.refreshCurrentTabGrid();

        // 状態に合わせて背景色を変更
        this.editBackgroundColor();
      }
      // this.changeEditColor
      // DB登録時に使用されるストアの情報を更新
      this.createEditedRecord();
      this.setEditRecord(this.editRecordOnComponent);
      this.changeButton();
    },
    /**
     * 表示項目一覧から指定したitemCdの項目情報を取得する
     */
    searchDispItem(identifier) {
      if (identifier === null || identifier === undefined || identifier === "") {
        return null;
      }
      const itemListMaster = this.refDispItemList || [];
      return itemListMaster.find(item =>
        item.itemCd == identifier ||
        item.jsonKeyName == identifier ||
        String(item.jsonKeyName) === String(identifier) ||
        item.itemName === identifier
      ) || null;
    },
    extractDispItemEditValue(editData) {
      if (editData === null || editData === undefined || editData === "") {
        return null;
      }
      if (typeof editData === "object") {
        const nestedValue = editData.value ?? editData.itemCd;
        return nestedValue === null || nestedValue === undefined || nestedValue === ""
          ? null
          : nestedValue;
      }
      return editData;
    },
    createEditedRecord() {
      // 各装置の現在の設定値を取得
      let jsonDcs = JSON.parse(JSON.stringify(this.getSettingDataDcs));
      let jsonDab = JSON.parse(JSON.stringify(this.getSettingDataDab));
      let jsonDad = JSON.parse(JSON.stringify(this.getSettingDataDad));
      let jsonDro = JSON.parse(JSON.stringify(this.getSettingDataDro));
      // 内部処理用のindexを取り除く
      jsonDcs = this.removeIndexForSettingData(jsonDcs);
      jsonDab = this.removeIndexForSettingData(jsonDab);
      jsonDad = this.removeIndexForSettingData(jsonDad);
      jsonDro = this.removeIndexForSettingData(jsonDro);
      // 文字列化
      const stringDcs = JSON.stringify(jsonDcs);
      const stringDab = JSON.stringify(jsonDab);
      const stringDad = JSON.stringify(jsonDad);
      const stringDro = JSON.stringify(jsonDro);
      // 登録用データ作成
      this.editRecordOnComponent.dcsViewItems = stringDcs;
      this.editRecordOnComponent.dabViewItems = stringDab;
      this.editRecordOnComponent.dadViewItems = stringDad;
      this.editRecordOnComponent.droViewItems = stringDro;
    },
    removeIndexForSettingData(jsonData) {
      jsonData.forEach(data => {
        delete data.index;
      });

      return jsonData;
    },
    setDispItemColumnValues() {
      const self = this;
      // 装置設定で選択する表示項目一覧を取得
      this.fetchDispItemList().then(response => {
        const responseData = response.data;
        // コンボボックス表示用データ作成
        let itemLists = { DCS: [], DAB: [], DAD: [], DRO: [] };
        responseData.forEach(data => {
          // 機種別に itemCd 単位で候補を登録（同名は normalizeDispItemComboValues で除外）
          switch (data.machineClass) {
            case "0": // 透析装置
              self.pushDispItemComboOption(itemLists.DCS, data);
              break;
            case "1": // 供給装置
              self.pushDispItemComboOption(itemLists.DAB, data);
              break;
            case "2": // 溶解装置
              self.pushDispItemComboOption(itemLists.DAD, data);
              break;
            case "3": // RO装置
              self.pushDispItemComboOption(itemLists.DRO, data);
              break;
          }
        });
        // 保存時の参照用に取得データをdataに保持
        self.refDispItemList = responseData;
        // 機種別全コンボボックス表示用データをストアにセット
        this.setComboItemList_Act(itemLists);
        self.allMultiSelectList = itemLists;
        const activeTabList = self.resolveTabDispItemComboList(self.tabSelectedId || 1);
        // コンボボックス表示用データを現在タブ分をストアにセット
        this.setColumnDispItemList(activeTabList);
        self.multiSelectList = activeTabList;
        self.normalizeAllDispItemRows();
        self.$nextTick(() => {
          self.applyDirectGridColumnsContract({ force: true });
          self.refreshDirectGridDataFromStore(false);
        });
      });
    },
    cancel() {
      // 前画面に戻る
      // 編集破棄確認はMasterRecordView.vueで行う
      this.$router.go(-1);
    },
    /**
     * 行を追加する
     */
    // 追加ボタンタップ時複数選択画面に切替える
    addRow() {
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        return;
      }
      this.popoverVisible = true;
      this.gridVisible = false;
    },
    // gridに複数行追加する
    addMultiSelect() {
      this.popoverVisible = false;
      this.gridVisible = true;
      const currentData = [...this.getCurrentData];

      // カレントデータのindexと表示順の最大値を取得
      let maxIndex = 0;
      let maxDispOrder = 0;
      const len = currentData.length;
      for (let lop = 0; lop < len; lop++) {
        const data = currentData[lop];
        if (data.index > maxIndex) {
          maxIndex = data.index;
        }
        if (data.order_no > maxDispOrder) {
          maxDispOrder = data.order_no;
        }
      }

      const selectLen = this.selectedSelection.length;
      const newRows = [];

      // 複数選択したデータをgridに表示
      for (let i = 0; i < selectLen; i++) {
        const dispItem = this.searchDispItem(this.selectedSelection[i]);
        if (!dispItem) {
          continue;
        }

        newRows.push({
          index: maxIndex + (i + 1),
          order_no: maxDispOrder + (i + 1),
          title: dispItem.itemName,
          data_class: dispItem.itemCd,
          width: 11,
          table_name: dispItem.tableName,
          column_name: dispItem.fieldName,
          key_name: dispItem.jsonKeyName,
          vital_monitor_class: dispItem.vitalMonitorClass,
          conv_type: dispItem.dataClass,
          data_type: dispItem.dataType
        });
      }

      this.setCurrentData([...currentData, ...newRows]);
      this.refreshCurrentTabGrid();

      // DB登録時に使用されるストアの情報を更新
      this.createEditedRecord();
      this.setEditRecord(this.editRecordOnComponent);

      // 追加した行を表示するよう、最下部までスクロールする
      this.$nextTick(() => {
        const modal = this.getCurrentModalContainer();
        const scrollAreas = modal?.getElementsByClassName?.("k-auto-scrollable") || [];
        let scrollArea = scrollAreas[1] || scrollAreas[0];
        if (scrollArea) {
          scrollArea.scrollTop = scrollArea.scrollHeight;
        }
      });
      this.selectedSelection = [];
      this.changeButton();
    },
    selectCancel() {
      // 複数追加画面を何もしないで閉じる
      // grid画面に戻る
      this.popoverVisible = false;
      this.gridVisible = true;
      this.selectedSelection = []
    },
    /**
     * 行を削除する
     */
    deleteRow(ev) {
      // ボタンを押した行のデータを取得する
      ev.preventDefault();
      const row = this.getGridWidget();
      const rowData = row?.dataItem?.(ev.currentTarget.closest("tr"));
      // 選択された行のデータのデータに付与しているIndexを取得
      const selectedDataIndex = rowData.index;

      // カレントデータ取得
      let currentData = this.getCurrentData;

      // カレントデータから対象のIndexのデータを削除
      const newCurrentData = currentData.filter(
        data => data.index !== selectedDataIndex
      );

      // カレントデータ更新
      this.setCurrentData(newCurrentData);
      this.refreshCurrentTabGrid();

      // DB登録時に使用されるストアの情報を更新
      this.createEditedRecord();
      this.setEditRecord(this.editRecordOnComponent);
      this.changeButton();
    },
    scheduleDirectGridStyleRefresh() {
      if (this.directGridStyleRefreshRafId != null) {
        cancelAnimationFrame(this.directGridStyleRefreshRafId);
      }
      this.directGridStyleRefreshRafId = requestAnimationFrame(() => {
        this.directGridStyleRefreshRafId = null;
        if (this.editingFlg) {
          return;
        }
        this.editBackgroundColor();
      });
    },
    editBackgroundColor() {
      this.$nextTick(() => this.applyDirectGridStyleContract());
    },
    // モーダルの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      if (!this.editingFlg) {
        const modal = this.getCurrentModalContainer();
        if (!modal) {
          return;
        }
        const modalHeight = modal.clientHeight;
        const modalHeaderHeight = modal.firstElementChild?.clientHeight || 0;
        const modalFooterHeight = modal.lastElementChild?.clientHeight || 0;
        const tabHeight = 66;
        const modalBody = this.getCurrentModalBody();
        const btnArea = modalBody?.querySelector?.('.header-btn-area') || queryScopedSelector('.header-btn-area', modalBody) || queryScopedSelector('.header-btn-area', this.getCurrentModalContainer());
        const btnHeight = btnArea ? btnArea.clientHeight : 45;
        // add GRIDリスト内容がブロックされるのことを対応 劉 start
        const modalFooter = this.getCurrentModalFooter();
        const btnToolBar = (modalFooter?.querySelector?.('.bottom-bar') || queryScopedSelector('.bottom-bar', modalFooter))?.clientHeight || 0;
        // add GRIDリスト内容がブロックされるのことを対応 劉 end
        const offset = 0;
        const gridHeight =
          modalHeight -
          modalHeaderHeight -
          tabHeight -
          btnHeight -
          modalFooterHeight -
          // add GRIDリスト内容がブロックされるのことを対応 劉 start
          btnToolBar -
          // add GRIDリスト内容がブロックされるのことを対応 劉 end
          offset;

        this.kendoGridToolbarHeight =
          modalHeight -
          modalHeaderHeight -
          tabHeight -
          modalFooterHeight -
          offset;

        this.kendoGridHeight =
          gridHeight > this.kendoGridMinHeight
            ? gridHeight
            : this.kendoGridMinHeight;

        this.addListHeight =
          modalHeight -
          modalHeaderHeight -
          tabHeight -
          modalFooterHeight -
          145 -
          offset;
      }
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
      const editField = e?.sender?.editable?.options?.fields?.field;
      if (editField === "data_class" && e?.model && !this.searchDispItem(e.model.data_class)) {
        this.normalizeDispItemRowFields(e.model);
      }
      this.editingFlg = true;
    },
    addInputAssist() {
      // iOS/PWA環境でスピナーをタップすると編集が終了してしまう現象の対策
      if (this.isIOS) {
        const numericTextboxes = queryScopedSelectorAll('.k-numerictextbox', this.$el);
        if (numericTextboxes.length !== 0) {
          let spinnerObj = numericTextboxes[0].getElementsByClassName("k-select")[0];
          // 編集が終了するとオブジェクトが削除されるため、removeEvent処理は不要
          spinnerObj.ontouchend = event => event.stopPropagation();
        }
      }
    },
    getDirectGridEditingField(container) {
      const root = container?.jquery ? container[0] : container;
      const input = root?.querySelector?.("input[data-bind^='value:']");
      const bindText = input?.getAttribute?.("data-bind") || "";
      const match = bindText.match(/value\s*:\s*([A-Za-z0-9_]+)/);
      return match?.[1] || "";
    },
    isDirectGridNumericField(field) {
      return field === "width" || field === "order_no";
    },
    markDirectGridNumericEdit() {
      this.directGridNumericEditKeepUntil = Date.now() + 250;
    },
    shouldKeepDirectGridNumericEdit(field) {
      return this.isDirectGridNumericField(field) && Date.now() <= this.directGridNumericEditKeepUntil;
    },
    getDirectGridNumericEditKey(model, field) {
      return `${model?.uid || model?.index || ""}:${field}`;
    },
    setDirectGridNumericEditValue(model, field, value) {
      this.directGridNumericEditValue = {
        key: this.getDirectGridNumericEditKey(model, field),
        value
      };
    },
    getDirectGridNumericEditValue(model, field, fallbackValue) {
      const key = this.getDirectGridNumericEditKey(model, field);
      return this.directGridNumericEditValue?.key === key
        ? this.directGridNumericEditValue.value
        : fallbackValue;
    },
    getDirectGridNumericTextInputs(widget, extraInputs = []) {
      const elements = [];
      const add = (input) => {
        const inputType = (input?.getAttribute?.("type") || input?.type || "text").toLowerCase();
        const canWriteValue = ["", "number", "text", "tel", "search"].includes(inputType);
        if (input && canWriteValue && !elements.includes(input)) {
          elements.push(input);
        }
      };
      const addInputOrChildren = (element) => {
        if (!element) {
          return;
        }
        if (element.tagName === "INPUT") {
          add(element);
        }
        element.querySelectorAll?.("input.k-input-inner, input.k-input, input.text-input, input[type='number'], input[type='text'], input:not([type])").forEach(add);
      };
      add(widget?.element?.get?.(0));
      add(widget?._text?.get?.(0));
      addInputOrChildren(widget?.wrapper?.get?.(0));
      addInputOrChildren(widget?.mountNode);
      extraInputs.forEach(addInputOrChildren);
      const activeElement = this.$el?.ownerDocument?.activeElement;
      if (activeElement?.tagName === "INPUT") {
        add(activeElement);
      }
      return elements;
    },
    setDirectGridNumericInputValue(input, value) {
      const inputWindow = input.ownerDocument?.defaultView || window;
      const setter = Object.getOwnPropertyDescriptor(
        inputWindow.HTMLInputElement.prototype,
        "value"
      )?.set;
      if (setter) {
        setter.call(input, value);
      } else {
        input.value = value;
      }
    },
    syncDirectGridNumericTextBoxDisplay(widget, value, extraInputs = []) {
      const text = value === null || value === undefined ? "" : String(value);
      this.getDirectGridNumericTextInputs(widget, extraInputs).forEach(input => {
        this.setDirectGridNumericInputValue(input, text);
      });
    },
    getDirectGridNumericWheelInputs(nativeEvent) {
      const inputs = [];
      const add = (element) => {
        if (!element || inputs.includes(element)) {
          return;
        }
        inputs.push(element);
      };
      const collect = (element) => {
        if (!element) {
          return;
        }
        if (element.tagName === "INPUT") {
          add(element);
        }
      };
      collect(nativeEvent?.target);
      nativeEvent?.composedPath?.().forEach(collect);
      return inputs;
    },
    syncDirectGridNumericTextBoxDisplayAfterRender(widget, value, extraInputs = []) {
      this.syncDirectGridNumericTextBoxDisplay(widget, value, extraInputs);
      const ownerWindow = extraInputs[0]?.ownerDocument?.defaultView || this.$el?.ownerDocument?.defaultView || window;
      ownerWindow.requestAnimationFrame?.(() => {
        this.syncDirectGridNumericTextBoxDisplay(widget, value, extraInputs);
      });
      ownerWindow.setTimeout?.(() => {
        this.syncDirectGridNumericTextBoxDisplay(widget, value, extraInputs);
      }, 0);
    },
    editEnd(e) {
      const editField = this.getDirectGridEditingField(e?.container);
      if (this.shouldKeepDirectGridNumericEdit(editField)) {
        // NumericTextBox の spin/wheel/key 操作ではセル編集を維持し、blur 時のみ確定する。
        e?.preventDefault?.();
        this.editingFlg = true;
        return;
      }
      this.editingFlg = false;
    },
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },
    // add #5589 2023/04/10 数値IFのスタイル全不正 林峻峰 start
    numericEditor(container, options) {
      const $input = $(`<input id="myInputNumber" type="number" style="text-align:right" data-bind="value:${options.field}"/>`)
        .appendTo(container);
      const masterField = this.dispMachineSetting.options.schema.model.fields[options.field];
      const parameterMin = masterField.validation.min;
      const parameterMax = masterField.validation.max;
      let parameterStep = 1;
      const parameter = {
        step: parameterStep,
        format: "n0",
        min: null,
        max: null,
        loopBounds: null,
        ignoreFieldValidationBounds: true
      };
      let numericTextBox = null;
      this.setDirectGridNumericEditValue(options.model, options.field, options.model?.[options.field]);
      const clampValue = (value) => {
        if (value > parameterMax) {
          return parameterMax;
        }
        if (value < parameterMin) {
          return parameterMin;
        }
        return value;
      };
      const loopValue = (value) => {
        if (value > parameterMax) {
          return parameterMin;
        }
        if (value < parameterMin) {
          return parameterMax;
        }
        return value;
      };
      parameter.spin = () => {
        this.markDirectGridNumericEdit();
        const value = loopValue(numericTextBox.value());
        numericTextBox.value(value);
        this.syncDirectGridNumericTextBoxDisplay(numericTextBox, value);
        options.model.set(options.field, value);
        this.setDirectGridNumericEditValue(options.model, options.field, value);
        const gridFontSizeEl = this.getGridFontSizeElement();
        if (gridFontSizeEl) {
          gridFontSizeEl.onmousewheel = () => true;
        }
      };
      parameter.change = (e) => {
        const value = e.sender._value;
        const editValue = this.getDirectGridNumericEditValue(options.model, options.field, value);
        const normalizedValue = clampValue(editValue);
        numericTextBox.value(normalizedValue);
        this.syncDirectGridNumericTextBoxDisplay(numericTextBox, normalizedValue);
        options.model.set(options.field, normalizedValue);
        this.setDirectGridNumericEditValue(options.model, options.field, normalizedValue);
        const gridFontSizeEl = this.getGridFontSizeElement();
        if (gridFontSizeEl) {
          gridFontSizeEl.onmousewheel = () => true;
        }
      };
      $input.kendoNumericTextBox(parameter);
      numericTextBox = $input.data("kendoNumericTextBox");
      this.$nextTick(() => {
        const gridFontSizeEl = this.getGridFontSizeElement();
        if (gridFontSizeEl) {
          gridFontSizeEl.onmousewheel = () => false;
        }
        const closeNumericCellEditor = () => {
          this.directGridNumericEditKeepUntil = 0;
          numericTextBox.trigger("change");
          container.closest(".k-grid").data("kendoGrid")?.closeCell?.();
        };
        const handleNativeWheel = (nativeEvent) => {
          this.markDirectGridNumericEdit();
          nativeEvent.preventDefault();
          nativeEvent.stopPropagation();
          nativeEvent.stopImmediatePropagation?.();
          const wheelDelta = nativeEvent.wheelDelta;
          const deltaY = nativeEvent.deltaY;
          const detail = nativeEvent.detail;
          const delta = (wheelDelta && (wheelDelta > 0 ? 1 : -1)) ||
            (deltaY && (deltaY < 0 ? 1 : -1)) ||
            (detail && (detail < 0 ? 1 : -1)) ||
            0;
          let value = parseFloat(numericTextBox.value());
          if (Number.isNaN(value)) {
            value = 0;
          }
          if (!parameterStep) {
            parameterStep = 1;
          }
          const nextValue = loopValue(value + (delta > 0 ? parameterStep : -parameterStep));
          const wheelInputs = this.getDirectGridNumericWheelInputs(nativeEvent);
          numericTextBox.value(nextValue);
          this.syncDirectGridNumericTextBoxDisplayAfterRender(numericTextBox, nextValue, wheelInputs);
          this.setDirectGridNumericEditValue(options.model, options.field, nextValue);
        };
        [numericTextBox.wrapper?.[0], numericTextBox.element?.[0]].forEach(element => {
          element?.addEventListener?.("wheel", handleNativeWheel, { capture: true, passive: false });
          element?.addEventListener?.("mousewheel", handleNativeWheel, { capture: true, passive: false });
          element?.addEventListener?.("DOMMouseScroll", handleNativeWheel, { capture: true, passive: false });
        });
        numericTextBox.element.on("keydown", (event) => {
          if (event.key === "Enter") {
            event.preventDefault();
            closeNumericCellEditor();
            return;
          }
          this.markDirectGridNumericEdit();
        });
        numericTextBox.element.on("input mousewheel wheel DOMMouseScroll", () => {
          this.markDirectGridNumericEdit();
        });
        numericTextBox.element.on("input", () => {
          const inputValue = parseFloat(numericTextBox.element.val());
          if (!Number.isNaN(inputValue)) {
            this.setDirectGridNumericEditValue(options.model, options.field, inputValue);
          }
        });
        numericTextBox.element.on("mousewheel wheel DOMMouseScroll", (event) => {
          event.preventDefault();
          event.stopPropagation();
          event.stopImmediatePropagation();
          let delta = (event.originalEvent.wheelDelta && (event.originalEvent.wheelDelta > 0 ? 1 : -1)) ||
                      (event.originalEvent.deltaY && (event.originalEvent.deltaY < 0 ? 1 : -1)) ||
                      (event.originalEvent.detail && (event.originalEvent.detail < 0 ? 1 : -1));
          let value = parseFloat(numericTextBox.value());
          if (Number.isNaN(value)) {
            value = 0;
          }
          if (!parameterStep) {
            parameterStep = 1;
          }
          const nextValue = loopValue(value + (delta > 0 ? parameterStep : -parameterStep));
          const wheelInputs = this.getDirectGridNumericWheelInputs(event.originalEvent);
          numericTextBox.value(nextValue);
          this.syncDirectGridNumericTextBoxDisplayAfterRender(numericTextBox, nextValue, wheelInputs);
          this.setDirectGridNumericEditValue(options.model, options.field, nextValue);
        });
        numericTextBox.element.on("blur", () => {
          const gridFontSizeEl = this.getGridFontSizeElement();
          if (gridFontSizeEl) {
            gridFontSizeEl.onmousewheel = () => true;
          }
          this.directGridNumericEditKeepUntil = 0;
          numericTextBox.trigger("change");
        });
      });
    },
    // add #5589 2023/04/10 数値IFのスタイル全不正 林峻峰 end
  },
  watch: {
    windowHeight() {
      this.calculateGridHeight();
    }
  },
  created() {
    this.setLoadingScreenVisible(true);
    // 親画面から装置設定JSONデータ取得
    const editRecord = this.getEditRecord;
    this.editRecordOnComponent = editRecord;
    this.setDispSettingData(editRecord);
    // 端末判別
    const ua = ((this?.$el?.ownerDocument?.defaultView?.navigator?.userAgent) || globalThis?.navigator?.userAgent || "").toLowerCase();
    if (/android/.test(ua)) {
      this.isAndroid = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.isIOS = true;
    }
  },
  beforeMount() {
    // 起動時は透析装置のデータを表示する
    this.changeCurrentData(1);
    // 列定義をセット
    this.setDispItemColumnValues();
  },
  mounted() {
    // Gridの高さをモーダルの大きさによって調整する
    this.$nextTick(() => {
      this.calculateGridHeight();
      this.initDirectGridIfReady();
      this.refreshDirectGridDataFromStore(false);
      this.scheduleDirectGridLayoutContract();
    });
    setTimeout(() => {
      EventBus.$emit("mstHolidayRegistered", true);
      this.setLoadingScreenVisible(false);
    }, 200);
  },
  updated() {
    // Storeの更新等で画面が再描画された場合に背景色を変更
    this.scheduleDirectGridStyleRefresh();
  },

  unmounted() {
    if (this.directGridLayoutRafId != null) {
      cancelAnimationFrame(this.directGridLayoutRafId);
      this.directGridLayoutRafId = null;
    }
    if (this.directGridStyleRefreshRafId != null) {
      cancelAnimationFrame(this.directGridStyleRefreshRafId);
      this.directGridStyleRefreshRafId = null;
    }
    if (this.directGridDataRefreshRafId != null) {
      cancelAnimationFrame(this.directGridDataRefreshRafId);
      this.directGridDataRefreshRafId = null;
    }
    this.destroyDirectGrid();
    this.clearData();
  }
};
</script>

<style scoped>
@media print {
  .disp-item-list{
    position: relative;
    top: 5px;
  }
  #grid-font-size .k-grid-content {
    height: auto !important;
  }
}
#grid-font-size {
  font-size: 1em;
}
.right {
  text-align: right;
}
.header-btn-area {
  height: 2.5em;
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
  background-color: var(--ntss-base-background-color);
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

/* [メイン] タブ切り替え全体のスタイル*/
.tabs {
  margin-top: 40px;
  /* background-color: #fff; */
  width: auto;
  margin: 0 auto;
  display: flex;
}
/* [メイン] タブのスタイル*/
.tab_item {
  flex: 1;
  /* width: calc(100% / 4); */
  height: 50px;
  border-bottom: 3px solid #5ab4bd;
  background-color: #d9d9d9;
  line-height: 50px;
  text-align: center;
  color: #565656;
  display: block;
  /* float: left; */
  text-align: center;
  font-weight: bold;
  transition: all 0.2s ease;
}
.tab_item:hover {
  opacity: 0.75;
}
/* [メイン] ラジオボタンを全て消す*/
input[name="tab_item"] {
  display: none;
}
/* [メイン] タブ切り替えの中身のスタイル*/
.tab_content {
  display: none;
  padding: 40px 40px 0;
  clear: both;
  overflow-y: auto;
}
/* [メイン] 選択されているタブのスタイルを変える*/
.tabs input:checked + .tab_item {
  background-color: #2a8bc4;
  color: #fff;
}

/* グリッドのスタイル */
.disp-item-list {
  overflow: auto;
  width: calc(100% - 15px);
  border-collapse: collapse;
  margin: 0 auto;
  position: absolute;
  top: 60px;
  background-color: var(--ntss-list-header-backgroud-color);
}

.bed-name-area,
.machine-no-area {
  padding-left: 8px;
}

.main-area {
  margin: 0 5px;
}
.main-area :deep(.k-grid) {
  background-color: var(--main-background-color);
}
.main-area :deep(.k-grid tr) {
  height: 2em;
  border-color: var(--master-maintenance-kgrid-border-color);
  color: var(--master-maintenance-kgrid-body-color);
  background-color: var(--master-maintenance-kgrid-item-background-color);
}
.main-area :deep(.k-grid tr.k-alt) {
  background-color: var(--ntss-list-content-2nd-background-color);
}
.main-area :deep(.k-grid a) {
  color: var(--master-maintenance-kgrid-item-color);
}
.main-area :deep(.k-grouping-row a) {
  color: var(--master-maintenance-kgrid-item-a-color);
}
.main-area :deep(.k-grid div.k-grouping-header) {
  color: var(--master-maintenance-kgrid-item-a-color);
  background-color: var(--master-maintenance-kgrid-item-background-color);
}
.main-area :deep(.k-grid td.k-group-cell) {
  text-overflow: clip;
  color: var(--master-maintenance-kgrid-item-a-color);
  background-color: var(--master-maintenance-kgrid-item-background-color);
}
.main-area :deep(.k-grid tr.k-state-selected>td) {
  color: var(--master-maintenance-kgrid-body-color);
  background-color: var(--master-maintenance-kgrid-selected-background-color);
}

.main-area :deep(.k-grid .k-table-row.k-selected>.k-table-td),
.main-area :deep(.k-grid .k-table-row.k-state-selected>.k-table-td) {
  color: var(--master-maintenance-kgrid-body-color);
  background-color: var(--master-maintenance-kgrid-selected-background-color);
}
.main-area :deep(.k-grid tr:hover) {
  background-color: var(--master-maintenance-kgrid-item-hover-background-color);
  color: var(--master-maintenance-kgrid-body-color);
}
.main-area :deep(.k-grid th) {
  color: #fff;
  background-color: var(--master-maintenance-kgrid-header-background-color);
}

.main-area :deep(.k-grid .k-table-th) {
  color: #fff;
  background-color: var(--master-maintenance-kgrid-header-background-color);
}
.main-area :deep(.k-grid th a) {
  color: #fff;
}

.main-area :deep(.k-grid .k-table-th .k-link),
.main-area :deep(.k-grid .k-column-title) {
  color: #fff;
}

.machine-no,
.k-textbox {
  width: 100%;
}

.machine-area {
  width: 100%;
  border-collapse: collapse;
}

.selecting-row {
  background-color: rgba(0, 225, 255, 0.5);
}

.select-input {
  height: 70%;
}

.display-list {
  background-color: var(--ntss-list-background-color);
  color: var(--ntss-list-body-color);
}

.display-list:hover {
  background-color: #e4e7eb;
}

.display-list.selected {
  color: #fff;
  background-color: #0076ff;
}

.selected-list {
  height: 93%;
}

.selected-item-list {
  position: relative;
  border: 1px solid var(--ntss-list-border-color);
  overflow: auto;
}

ons-button.cancel {
  color: #333333;
  background-color: #add8e6;
}

#item-box-list{
  --height: 200px;
  height: var(--height);
  border: solid gray;
  padding: 20px;
  border-width: 2px 2px 1px;
  margin: 0px auto;
  width: 50%;
  /* mod redmine 5098 スマホ、詳細モーダル内のプルダウンメニューが見切れる 宋qy start */
  min-width: 260px;
  /* mod redmine 5098 スマホ、詳細モーダル内のプルダウンメニューが見切れる 宋qy end */
}

#item-box-conf{
  border: solid gray;
  padding: 10px 20px;
  border-width: 1px 2px 2px;
  margin: 0px auto;
  width: 50%;
  /* mod redmine 5098 スマホ、詳細モーダル内のプルダウンメニューが見切れる 宋qy start */
  min-width: 260px;
  /* mod redmine 5098 スマホ、詳細モーダル内のプルダウンメニューが見切れる 宋qy end */
}

#select-text{
  margin-bottom: 5px;
  margin-top: 0px;
  background-color: var(--ntss-list-background-color);
  color: var(--ntss-list-body-color);
}

.dialog-cancel,.dialog-conf{
  background:none;
}

#list-footer{
  display: flex;
  justify-content: space-between;
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

.mst-treatment-status-layout-direct-jq-grid {
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
