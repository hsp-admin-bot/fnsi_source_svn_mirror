/**
 * 測定チェックマスタ編集tab画面
 */
<template>
  <div class="disp-item-list" :style="ntssListStyles">
    <kendo-grid-toolbar class="k-grid-toolbar kendo-grid-toolbar-style">
      <div class="header-btn-area right" ref="headerBtnArea">
        <v-ons-button
          modifier="outline"
          class="btn3-normal toolbar-btn"
          style="float: left;"
          v-show="true"
          @click="addRow()"
        >追加</v-ons-button>
      </div>
      <div
        ref="grid"
        id="check-grid"
        :class="[fontSizeSet, 'ntss-kendo-grid-legacy', 'mst-weight-tab-check-direct-grid']"
      ></div>
    </kendo-grid-toolbar>
  </div>
</template>

<script>
import { markRaw } from "@/compat/vue/runtime";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import kendo from "@progress/kendo-ui";
import $ from "jquery";
import { EventBus } from "@/compat/vue/event-bus.js";
import { getLatestHeaderElement, getHeaderHeight, getFooterMenuClientHeight, queryScopedSelectorAll, getScopedElementById, getScopedNumericTextBox } from "@/functions/common/LayoutMeasureHelper";

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
      kendoValidatorSetup: {
        rules: {},
        messages: {}
      },
      columns: [],
      editCheckContent: "",
      kendoGridHeight: 300,
      gridData: [],
      //Android端末で編集中であることを示すフラグ
      isAndroid: false,
      isIOS: false,
      savedScrollTop: 0,
      savedScrollLeft: 0,
      directGridWidget: null,
      directGridDataSource: null,
      directGridColumnSignature: "",
      directGridLayoutRafId: null,
      directGridPaintRafId: null
    };
  },
  computed: {
    ...mapGetters("master-maintenance", {
      editRecord: "getEditRecord"
    }),
    ...mapGetters("mst-weight/check", {
      getColumns: "getColumns",
      getCurrentData: "getCurrentData",
      getSettingDataCheck: "getSettingDataCheck"
    }),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    ...mapGetters("mst-weight", {
      getIsGridEditing: "getIsGridEditing"
    }),
    dispColumns() {
      this.$nextTick(() => {
        this.calculateGridHeight();
      });

      return this.getColumns;
    },
    dispCheckSetting() {
      return this.getSettingDataCheck;
    },
    ntssListStyles() {
      return { display: "inherit", fontSize: "1em" };
    },
    getGridData() {
      return this.gridData;
    },
    fontSizeSet() {
      const names = ["small", "medium", "large", "x-large"];
      return `font-size-set-${names[this.getFontSize] || names[0]}`;
    }
  },
  methods: {
    getWeightTabScopeRoot() {
      return this.$el || this.$refs.grid || null;
    },
    getGridRootEl() {
      return this.$refs.grid || null;
    },
    getGridWidget() {
      return this.directGridWidget;
    },
    getGridContentEl() {
      return this.getGridRootEl()?.querySelector?.(".k-grid-content") || null;
    },
    getGridHeaderEl() {
      return this.getGridRootEl()?.querySelector?.(".k-grid-header") || null;
    },
    getGridHeaderWrapEl() {
      return this.getGridRootEl()?.querySelector?.(".k-grid-header-wrap") || null;
    },
    getGridTbodyEl() {
      return this.getGridRootEl()?.querySelector?.(".k-grid-content tbody") || null;
    },
    getGridTableEl() {
      return this.getGridRootEl()?.querySelector?.(".k-grid-content table") || null;
    },
    getGridScrollPosition() {
      const content = this.getGridContentEl();
      return {
        top: content?.scrollTop || 0,
        left: content?.scrollLeft || 0
      };
    },
    setGridScrollPosition(position = {}) {
      const content = this.getGridContentEl();
      if (!content) {
        return;
      }
      if (Number.isFinite(position.top)) {
        content.scrollTop = position.top;
      }
      if (Number.isFinite(position.left)) {
        content.scrollLeft = position.left;
      }
      try {
        $(content).trigger("scroll");
      } catch (_error) {
        // noop
      }
    },
    getDirectGridColumnSignature() {
      return (this.dispColumns || []).map(column => [
        column.field,
        column.title,
        column.hidden ? 1 : 0,
        column.editable ? 1 : 0,
        column.width || "",
        column.format || ""
      ].join(":"))
        .join("|");
    },
    buildDirectGridColumns() {
      return (this.dispColumns || []).map(column => {
        const gridColumn = { ...column };
        if (gridColumn.field === "delBtn") {
          gridColumn.attributes = { class: "text-align: center;" };
          gridColumn.command = {
            name: "customDelete",
            text: "",
            iconClass: "fa fa-trash",
            click: event => this.deleteRow(event)
          };
        } else if (gridColumn.field === "modal") {
          gridColumn.attributes = { class: "btn3-kendo-normal ntss-check-grid-modal-command" };
          gridColumn.command = {
            text: "詳細",
            click: event => this.showCheckEditModal(event)
          };
        }
        return gridColumn;
      });
    },
    initDirectGridIfReady() {
      const root = this.getGridRootEl();
      if (!root || !this.dispColumns?.length) {
        return;
      }
      if (this.directGridWidget) {
        this.applyDirectGridColumnsContract();
        this.refreshDirectGridDataFromStore(false);
        this.scheduleDirectGridLayoutContract();
        return;
      }
      installComponentJQuery();
      this.directGridDataSource = markRaw(new kendo.data.DataSource({
        data: this.dispCheckSetting || []
      }));
      $(root).empty();
      $(root).kendoGrid({
        dataSource: this.directGridDataSource,
        editable: true,
        selectable: true,
        reorderable: false,
        height: this.kendoGridHeight,
        scrollable: true,
        beforeEdit: event => this.editStart(event),
        cellClose: event => this.editEnd(event),
        edit: event => this.addInputAssist(event),
        save: event => this.onSave(event),
        columns: this.buildDirectGridColumns(),
        dataBound: () => {
          this.applyDirectGridStyleContract();
          this.scheduleDirectGridVisualRefresh();
        }
      });
      this.directGridWidget = markRaw($(root).data("kendoGrid"));
      this.directGridColumnSignature = this.getDirectGridColumnSignature();
      this.installDirectGridFacade();
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
      const root = this.getGridRootEl();
      if (root) {
        $(root).empty();
      }
      this.directGridWidget = null;
      this.directGridDataSource = null;
      this.directGridColumnSignature = "";
    },
    installDirectGridFacade() {
      const root = this.getGridRootEl();
      if (!root) {
        return;
      }
      root.kendoWidget = () => this.directGridWidget;
      root.gridWidget = () => this.directGridWidget;
      root.gridContentEl = () => this.getGridContentEl();
      root.refreshGrid = () => this.refreshDirectGridDataFromStore(false);
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
      }
    },
    refreshDirectGridDataFromStore(restoreScroll = true) {
      const grid = this.directGridWidget;
      if (!grid?.dataSource) {
        return;
      }
      const position = this.getGridScrollPosition();
      grid.dataSource.data(this.dispCheckSetting || []);
      this.$nextTick(() => {
        this.applyDirectGridStyleContract();
        if (restoreScroll) {
          this.setGridScrollPosition(position);
        }
      });
    },
    applyDirectGridStyleContract() {
      const root = this.getGridRootEl();
      if (!root) {
        return;
      }
      root.classList.add("ntss-kendo-grid-legacy", "k-widget", "k-grid", "k-editable", "k-display-block");
      root.querySelectorAll(".k-grid-header th, .k-grid-header .k-table-th").forEach(th => th.classList.add("k-header"));
      root.querySelectorAll(".k-grid-content tbody").forEach(tbody => {
        Array.from(tbody.rows || []).forEach((row, index) => {
          row.classList.add("k-master-row");
          row.classList.toggle("k-alt", index % 2 === 1);
        });
      });
      root.querySelectorAll(".k-grid-content tbody td").forEach(td => td.classList.add("k-td", "k-table-td"));
      this.changeHeaderAndContentWidth();
    },
    scheduleDirectGridLayoutContract() {
      if (this.directGridLayoutRafId != null) {
        cancelAnimationFrame(this.directGridLayoutRafId);
      }
      this.directGridLayoutRafId = requestAnimationFrame(() => {
        this.directGridLayoutRafId = null;
        const grid = this.directGridWidget;
        if (grid) {
          grid.setOptions({ height: this.kendoGridHeight });
          grid.resize?.(true);
        }
        this.applyDirectGridStyleContract();
        this.directGridLayoutRafId = requestAnimationFrame(() => {
          this.directGridLayoutRafId = null;
          this.applyDirectGridStyleContract();
          this.setGridScrollPosition({ top: this.savedScrollTop, left: this.savedScrollLeft });
        });
      });
    },
    ...mapActions("master-maintenance", [
      "findRecordList",
      "setMasterRecordList",
      "edit",
      "setCondition",
      "updateRecordList",
      "setEditRecord",
      "editRecordBeEmpty"
    ]),
    ...mapActions("multi-modal", ["showMstWeightCheckEdit"]),
    ...mapActions("mst-weight/check", [
      "clearData",
      "setSettingData",
      "setCurrentRowData",
      "setCurrentData",
      "setCurrentNewRowData"
    ]),
    ...mapActions("mst-weight", {
      setIsGridEditing: "setIsGridEditing"
    }),
    // 測定値チェックグリッドクリック時
    showCheckEditModal(e) {
      e.preventDefault();
      const row = this.getGridWidget();
      const selectedRowItem = row?.dataItem?.(e.currentTarget.closest("tr"));

      if (!selectedRowItem) {
        return;
      }
      // ストアに保存する。
      this.setCurrentRowData(selectedRowItem.toJSON?.() || selectedRowItem);
      // 測定チェック設定画面表示
      this.showModal();
    },
    // 測定値チェック新規登録
    addRow() {
      this.savedScrollTop = this.getGridContentEl()?.scrollTop || 0;
      this.setCurrentNewRowData();
      // 測定チェック設定画面表示
      this.showModal();
    },
    showModal() {
      // モーダル表示
      this.showMstWeightCheckEdit();
    },
    onSave(ev) {
      this.setIsGridEditing(false);
      /** Grid内のデータを変更した際の処理 */

      // 編集内容取得
      const editRowInfo = ev.model;
      const editId = editRowInfo.ctl_no;
      const editObject = ev.values;
      const editKey = Object.keys(editObject)[0];

      // 現在の表示データ取得
      let currentData = this.getSettingDataCheck;

      // 編集箇所判定
      // 表示項目選択コンボボックス以外の場合
      const editValue = editObject[editKey];
      currentData.forEach(data => {
        if (data.ctl_no == editId) {
          data[editKey] = editValue;
        }
      });

      if (editKey == "disp_order") {
        // 表示順が変更された場合表示データをソートする
        currentData = this.sortDispDataByDispOrder(currentData);
      }

      // カレントデータ更新
      this.setCurrentData(currentData);

      // DB登録時に使用されるストアの情報を更新
      this.applyCheckConfigEdit();
      this.refreshDirectGridDataFromStore(true);
      // 状態に合わせて背景色を変更
      this.editBackgroundColor();
    },
    /**
     * 行を削除する
     */
    deleteRow(ev) {
      this.savedScrollTop = this.getGridContentEl()?.scrollTop || 0;
      this.savedScrollLeft = this.getGridContentEl()?.scrollLeft || 0;
      // ボタンを押した行のデータを取得する
      ev.preventDefault();
      const row = this.getGridWidget();
      const rowData = row?.dataItem?.(ev.currentTarget.closest("tr"));
      if (!rowData) {
        return;
      }
      // 選択された行のデータのデータに付与しているidを取得
      const selectedDataId = rowData.ctl_no;

      // カレントデータ取得
      const currentData = this.getSettingDataCheck;

      // カレントデータから対象のidのデータを削除
      const newCurrentData = currentData.filter(
        data => data.ctl_no !== selectedDataId
      );

      // カレントデータ更新
      this.setCurrentData(newCurrentData);
      this.refreshDirectGridDataFromStore(true);

      // DB登録時に使用されるストアの情報を更新
      this.applyCheckConfigEdit();
    },
    createEditedRecord() {
      // 現在の設定値を文字列化して登録用データ作成
      this.editCheckContent = JSON.stringify(this.getSettingDataCheck);
    },
    scheduleDirectGridVisualRefresh() {
      if (this.directGridPaintRafId != null) {
        cancelAnimationFrame(this.directGridPaintRafId);
      }
      this.directGridPaintRafId = requestAnimationFrame(() => {
        this.directGridPaintRafId = null;
        if (this.getIsGridEditing) {
          return;
        }
        this.editBackgroundColor();
      });
    },
    editBackgroundColor() {
      this.$nextTick(() => {
        const gridHeader = this.getGridHeaderEl() || this.getGridRootEl()?.firstElementChild;
        gridHeader?.classList?.add("master-grid-header");
        //add 測定時チェックタブの表で列幅変更できないため、内容全文が確認できない 鞠 4730 start
        this.changeHeaderAndContentWidth()
        //add 測定時チェックタブの表で列幅変更できないため、内容全文が確認できない 鞠 4730 end
        const gridContent = this.getGridContentEl();
        if (gridContent) {
          gridContent.scrollTop = this.savedScrollTop;
          gridContent.scrollLeft = this.savedScrollLeft;
        }
      });
    },
    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      if (!this.getIsGridEditing) {
        const wh = this.windowHeight;
        const hh = getHeaderHeight(getLatestHeaderElement(this.$el || document), 0);
        const th = Array.prototype.slice
          .call(queryScopedSelectorAll('.tab_item', this.getWeightTabScopeRoot()))
          .shift()?.offsetHeight || 0;
        const fmh =
          this.isDispMenu === 1
            ? getFooterMenuClientHeight(this.$el || null)
            : 0;
        const gfh = getScopedElementById('detail-footer', this.getWeightTabScopeRoot())?.offsetHeight || 0;
        const headerBtnAreaHeight = this.$refs.headerBtnArea.offsetHeight;

        // kendoGridの高さ設定(ウィンドウ高さ－ヘッダー高さ－タブ高さ－追加ボタンエリア高さ－メニューバー高さ－確定/キャンセルボタンエリア高さ)
        this.kendoGridHeight = wh - hh - th - headerBtnAreaHeight - fmh - gfh;

        // kendoGridのheader行高とbody行高を取得(ただし、body行高が行毎に可変の場合は対応できない。あくまで目安高。)
        const firstTh = this.getGridHeaderEl()?.querySelector('tr');
        const thHeight = firstTh ? firstTh.offsetHeight : 0;
        const firstTd = this.getGridTbodyEl()?.querySelector('tr');
        const tdHeight = firstTd ? firstTd.offsetHeight : 0;
        // kendoGrid最低5行分の高さ(header高さ＋5行分の高さ＋横スクロールの高さ目安17px)
        const gridMinHeight = thHeight + (tdHeight * 5) + 17;

        // kendoGridの高さが最低5行分より小さいか(ウィンドウ高が極端に小さい時や文字サイズ特大の場合等に起こりえる)
        if (this.kendoGridHeight < gridMinHeight) {
          // 最低5行表示されるよう5行分の高さをkendoGridの高さに設定
          this.kendoGridHeight = gridMinHeight;
        }
      }
    },
    //add 測定時チェックタブの表で列幅変更できないため、内容全文が確認できない 鞠 4730 start
    changeHeaderAndContentWidth() {
      const colHeader = this.getGridHeaderWrapEl()?.querySelector('table colgroup');
      const colContent = this.getGridTableEl()?.querySelector('colgroup');
      if (!colHeader || !colContent) {
        return;
      }
      for (let i = 0; i < colContent.children.length; i++) {
        switch (parseInt(this.getFontSize)) {
          case 0 :
            if (colContent.children[i].style.width == "60px") {
              colContent.children[i].style.width = "64px"
              colHeader.children[i].style.width = "64px"
            }
            if (colContent.children[i].style.width == "100px") {
              colContent.children[i].style.width = "110px"
              colHeader.children[i].style.width = "110px"
            }
            break;
          case 1 :
            if (colContent.children[i].style.width == "60px") {
              colContent.children[i].style.width = "65px"
              colHeader.children[i].style.width = "65px"
            }
            if (colContent.children[i].style.width == "80px") {
              colContent.children[i].style.width = "87px"
              colHeader.children[i].style.width = "87px"
            }
            if (colContent.children[i].style.width == "100px") {
              colContent.children[i].style.width = "124px"
              colHeader.children[i].style.width = "124px"
            }
            if (colContent.children[i].style.width == "120px") {
              colContent.children[i].style.width = "130px"
              colHeader.children[i].style.width = "130px"
            }
            break;
          case 2 :
            if (colContent.children[i].style.width == "60px") {
              colContent.children[i].style.width = "66px"
              colHeader.children[i].style.width = "66px"
            }
            if (colContent.children[i].style.width == "80px") {
              colContent.children[i].style.width = "90px"
              colHeader.children[i].style.width = "90px"
            }
            if (colContent.children[i].style.width == "100px") {
              colContent.children[i].style.width = "135px"
              colHeader.children[i].style.width = "135px"
            }
            if (colContent.children[i].style.width == "120px") {
              colContent.children[i].style.width = "141px"
              colHeader.children[i].style.width = "141px"
            }
            if (colContent.children[i].style.width == "150px") {
              colContent.children[i].style.width = "158px"
              colHeader.children[i].style.width = "158px"
            }
            break;
          case 3 :
            if (colContent.children[i].style.width == "60px") {
              colContent.children[i].style.width = "69px"
              colHeader.children[i].style.width = "69px"
            }
            if (colContent.children[i].style.width == "80px") {
              colContent.children[i].style.width = "97px"
              colHeader.children[i].style.width = "97px"
            }
            if (colContent.children[i].style.width == "100px") {
              colContent.children[i].style.width = "155px"
              colHeader.children[i].style.width = "155px"
            }
            if (colContent.children[i].style.width == "120px") {
              colContent.children[i].style.width = "163px"
              colHeader.children[i].style.width = "163px"
            }
            if (colContent.children[i].style.width == "150px") {
              colContent.children[i].style.width = "182px"
              colHeader.children[i].style.width = "182px"
            }
            break;
        }
      }
    },
    //add 測定時チェックタブの表で列幅変更できないため、内容全文が確認できない 鞠 4730 end
    async editStart() {
      await this.setIsGridEditing(true);
    },
    editEnd() {
      this.setIsGridEditing(false);
    },
    addInputAssist() {
      // iOS/PWA環境でスピナーをタップすると編集が終了してしまう現象の対策
      if (this.isIOS) {
        const numericTextBox = getScopedNumericTextBox(this.getWeightTabScopeRoot());
        if (numericTextBox) {
          let spinnerObj = numericTextBox.getElementsByClassName("k-select")[0];
          // 編集が終了するとオブジェクトが削除されるため、removeEvent処理は不要
          spinnerObj.ontouchend = event => event.stopPropagation();
        }
      }
    },
    /**
     * 表示データを表示順で並べ替える
     */
    sortDispDataByDispOrder(jsonData) {
      let buf = [];
      let buf_temp = [];
      const cnt = jsonData.length;
      for (let lop = 0; lop < cnt; lop++) {
        const data = jsonData[lop];
        if (lop == 0) {
          // ループの1回目は無条件でバッファに入れる
          buf.push(data);
        } else {
          // ループの2回目以降
          let isPushed = false;
          for (let bufLop = 0; bufLop < buf.length; bufLop++) {
            const bufData = buf[bufLop];
            if (data.disp_order < bufData.disp_order && !isPushed) {
              buf_temp.push(data);
              isPushed = true;
              buf_temp.push(bufData);
            } else {
              buf_temp.push(bufData);
            }
          }
          if (buf_temp.length == buf.length) {
            buf_temp.push(data);
          }

          // 値渡し
          buf = buf_temp.slice();
          // temp初期化
          buf_temp = [];
        }
      }
      return buf;
    },
    /* ストアに登録する */
    setDispSettingData(editRecord) {
      let jsonData = { check: [] };
      // JSON文字列を管理用Index付きJSONオブジェクトに変換
      jsonData.check = JSON.parse(editRecord.checkContent);

      // JSONオブジェクトを表示順でソート
      jsonData.check = this.sortDispDataByDispOrder(jsonData.check);

      this.setSettingData(jsonData);
    },
    updateEditRecord(key, value) {
      this.editRecord[key] = value;
      this.setEditRecord(this.editRecord);
    },
    applyCheckConfigEdit() {
      this.createEditedRecord();
      this.updateEditRecord("checkContent", this.editCheckContent);
      this.$nextTick(() => {
        this.refreshDirectGridDataFromStore(true);
      });
    },
    updateWidget() {
      this.$nextTick(() => {
        this.calculateGridHeight();
        this.initDirectGridIfReady();
        this.refreshDirectGridDataFromStore(true);
        this.scheduleDirectGridLayoutContract();
        this.scheduleDirectGridVisualRefresh();
      });
    }
  },
  watch: {
    windowHeight() {
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
    dispColumns() {
      this.$nextTick(() => {
        this.initDirectGridIfReady();
        this.scheduleDirectGridLayoutContract();
      });
    },
    getSettingDataCheck() {
      this.$nextTick(() => {
        this.refreshDirectGridDataFromStore(true);
      });
    }
  },
  created() {
    // 端末判別
    const ua = ((this?.$el?.ownerDocument?.defaultView?.navigator?.userAgent) || globalThis?.navigator?.userAgent || "");
    if (ua.match(/Android/)) {
      this.isAndroid = true;
    } else if (ua.match(/iPhone|iPad/)) {
      this.isIOS = true;
    }
    EventBus.$on("applyCheckConfigEdit", this.applyCheckConfigEdit);
    // 親画面から装置設定JSONデータ取得
    this.editCheckContent = this.editRecord.checkContent;
    this.setDispSettingData(this.editRecord);
  },
  mounted() {
    // Gridの高さを調整する
    this.$nextTick(() => {
      this.calculateGridHeight();
      this.initDirectGridIfReady();
      this.scheduleDirectGridLayoutContract();
    });
  },
  updated() {
    // Storeの更新等で画面が再描画された場合に背景色を変更
    this.scheduleDirectGridVisualRefresh();
  },
  // add 性能改善メモリ不足 shan start
  beforeUnmount() {
    EventBus.$off("applyCheckConfigEdit", this.applyCheckConfigEdit);
    if (this.directGridLayoutRafId != null) {
      cancelAnimationFrame(this.directGridLayoutRafId);
      this.directGridLayoutRafId = null;
    }
    if (this.directGridPaintRafId != null) {
      cancelAnimationFrame(this.directGridPaintRafId);
      this.directGridPaintRafId = null;
    }
    this.destroyDirectGrid();
  },
  // add 性能改善メモリ不足 shan end
  unmounted() {
    this.clearData();

  }
};
</script>
<style scoped>
/* グリッドのスタイル */
#check-grid {
  margin: 0; /* ライブラリのスタイル打消し */
  width: 100%;
}
.disp-item-list {
  border-collapse: collapse;
  margin: 0 auto;
  font-size: 1.5em;
  background-color: var(--ntss-list-header-backgroud-color);
}
.right {
  text-align: right;
}
.header-btn-area {
  height: 2em;
  padding: 0.3em 0 0.1em; /* 他タブとボタンの位置合わせ */
}
#grid-footer {
  margin: 0;
  padding: 5px;
  bottom: 0;
  position: absolute;
  width: inherit;
}
.kendo-grid-toolbar-style {
  border-bottom: none;
}
.toolbar-btn {
  font-size: 1.0em;
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  width: auto;
}
.kendo-grid-toolbar-style {
  padding: 0; /* ライブラリのスタイル打消し */
}
/* 測定チェック Grid: 「詳細」command ボタンを横並び（狭い列／テンプレ併存時の縦積みを抑止） */
:deep(#check-grid .k-command-cell) {
  white-space: nowrap;
  display: flex;
  flex-direction: row;
  flex-wrap: nowrap;
  align-items: center;
  justify-content: center;
  gap: 0.35rem;
}
:deep(#check-grid .k-command-cell .k-button) {
  flex: 0 0 auto;
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

</style>
